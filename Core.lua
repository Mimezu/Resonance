local ADDON_NAME, ns = ...

local lifecycleFrame = CreateFrame("Frame")
local playerFrame = CreateFrame("Frame")
ns.lifecycleFrame = lifecycleFrame
ns.playerFrame = playerFrame

local EVENT_NAMES = {
    CASTING_START = {
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_EMPOWER_START",
    },
    SUCCEEDED = "UNIT_SPELLCAST_SUCCEEDED",
    CHANNEL_START = "UNIT_SPELLCAST_CHANNEL_START",
    EMPOWER_START = "UNIT_SPELLCAST_EMPOWER_START",
    EMPOWER_STOP = "UNIT_SPELLCAST_EMPOWER_STOP",
    AURA = "UNIT_AURA",
    AURA_STACK = "UNIT_AURA",
    POWER = "UNIT_POWER_UPDATE",
}

local function GetSpecID()
    local specializationIndex = GetSpecialization and GetSpecialization()
    if not ns:IsSafeValue(specializationIndex) or type(specializationIndex) ~= "number" then
        return nil
    end
    local specID = GetSpecializationInfo(specializationIndex)
    if ns:IsSafeValue(specID) and type(specID) == "number" then
        return specID
    end
    return nil
end

local function IncrementEventCount(event)
    local counts = ns.Runtime.eventCounts
    counts[event] = (counts[event] or 0) + 1
end

function ns:CompileRules()
    playerFrame:UnregisterAllEvents()
    self.Runtime.activeRules = {}
    self.Runtime.eventRules = {}
    self.Runtime.auraInstances = {}
    self.Runtime.lastRulePlay = {}
    self.Runtime.empowerSpellID = nil

    local specID = GetSpecID()
    self.Runtime.specID = specID
    if not specID or not self.SUPPORTED_SPECS[specID] then
        return
    end
    if not self.DB.enabled or not self.DB.specEnabled[specID] then
        return
    end

    local eventsNeeded = {}
    for _, rule in ipairs(self.RulesBySpec[specID] or {}) do
        if self:GetRuleEnabled(rule) and (not rule.capability or self:HasCapability(rule.capability)) then
            self.Runtime.activeRules[#self.Runtime.activeRules + 1] = rule
            self.Runtime.eventRules[rule.event] = self.Runtime.eventRules[rule.event] or {}
            table.insert(self.Runtime.eventRules[rule.event], rule)
            local eventNames = EVENT_NAMES[rule.event]
            if type(eventNames) == "table" then
                for _, eventName in ipairs(eventNames) do
                    eventsNeeded[eventName] = true
                end
            elseif eventNames then
                eventsNeeded[eventNames] = true
            end
        end
    end

    for event in pairs(eventsNeeded) do
        playerFrame:RegisterUnitEvent(event, "player")
    end

    if specID == 62 then
        local powerType = Enum and Enum.PowerType and Enum.PowerType.ArcaneCharges or 16
        local value = UnitPower("player", powerType)
        if self:IsSafeValue(value) and type(value) == "number" then
            self.Runtime.lastArcaneCharges = value
        end
    end
end

function ns:Refresh(reason)
    self.Runtime.refreshQueued = false
    self:ScanCapabilities()
    self:CompileRules()
    if self.RefreshOptions then
        self:RefreshOptions()
    end
    if self.DB and self.DB.debug and reason then
        self:Print("Refreshed: " .. reason)
    end
end

function ns:QueueRefresh(reason)
    if not self.DB or self.Runtime.refreshQueued then
        return
    end
    self.Runtime.refreshQueued = true
    C_Timer.After(0, function()
        ns:Refresh(reason)
    end)
end

local function RouteSpellEvent(routeName, spellID)
    if not ns:IsSafeValue(spellID) or type(spellID) ~= "number" then
        return false
    end
    local matched = false
    for _, rule in ipairs(ns.Runtime.eventRules[routeName] or {}) do
        if rule.spellSet[spellID] then
            matched = true
            ns:PlayRule(rule)
        end
    end
    return matched
end

local function SpellMatchesRoute(routeName, spellID)
    if not ns:IsSafeValue(spellID) or type(spellID) ~= "number" then return false end
    for _, rule in ipairs(ns.Runtime.eventRules[routeName] or {}) do
        if rule.spellSet[spellID] then return true end
    end
    return false
end

local function GetPlayerEmpowerSpellID(routeName, eventSpellID, allowStored)
    if SpellMatchesRoute(routeName, eventSpellID) then return eventSpellID end

    -- Empower casts are represented by UnitChannelInfo on Retail. This fallback
    -- also avoids depending on an event spell ID that may be unavailable.
    local _, _, _, _, _, _, _, channelSpellID, isEmpowered = UnitChannelInfo("player")
    if ns:IsSafeValue(isEmpowered) and isEmpowered and SpellMatchesRoute(routeName, channelSpellID) then
        return channelSpellID
    end

    local castingSpellID = select(9, UnitCastingInfo("player"))
    if SpellMatchesRoute(routeName, castingSpellID) then return castingSpellID end

    if allowStored and SpellMatchesRoute(routeName, ns.Runtime.empowerSpellID) then
        return ns.Runtime.empowerSpellID
    end
    return nil
end

local function HandleEmpowerStart(eventSpellID)
    local spellID = GetPlayerEmpowerSpellID("EMPOWER_START", eventSpellID, false)
        or GetPlayerEmpowerSpellID("CASTING_START", eventSpellID, false)
    if not spellID then return false end
    ns.Runtime.empowerSpellID = spellID
    local matched = RouteSpellEvent("EMPOWER_START", spellID)
    return RouteSpellEvent("CASTING_START", spellID) or matched
end

local function HandleEmpowerStop(eventSpellID, empowerComplete)
    local completed = ns:IsSafeValue(empowerComplete) and empowerComplete == true
    local spellID = GetPlayerEmpowerSpellID("EMPOWER_STOP", eventSpellID, true)
    ns.Runtime.empowerSpellID = nil
    if not completed or not spellID then return false end
    return RouteSpellEvent("EMPOWER_STOP", spellID)
end

local function IsWatchedAura(spellID)
    for _, rule in ipairs(ns.Runtime.eventRules.AURA or {}) do
        if rule.auraSet[spellID] then
            return true
        end
    end
    for _, rule in ipairs(ns.Runtime.eventRules.AURA_STACK or {}) do
        if rule.auraSet[spellID] then
            return true
        end
    end
    return false
end

local function ProcessAura(aura, isNew)
    if not ns:IsSafeTable(aura) then
        return
    end
    local spellID = aura.spellId
    local instanceID = aura.auraInstanceID
    if not ns:IsSafeValue(spellID) or type(spellID) ~= "number" then
        return
    end
    if not IsWatchedAura(spellID) then
        return
    end

    local applications = aura.applications
    if not ns:IsSafeValue(applications) or type(applications) ~= "number" then
        applications = 0
    end

    local previousApplications = 0
    if ns:IsSafeValue(instanceID) and type(instanceID) == "number" and ns.Runtime.auraInstances[instanceID] then
        previousApplications = ns.Runtime.auraInstances[instanceID].applications or 0
    end

    for _, rule in ipairs(ns.Runtime.eventRules.AURA or {}) do
        if isNew and rule.auraSet[spellID] then
            ns:PlayRule(rule)
        end
    end
    for _, rule in ipairs(ns.Runtime.eventRules.AURA_STACK or {}) do
        if rule.auraSet[spellID] and applications >= rule.stackThreshold and previousApplications < rule.stackThreshold then
            ns:PlayRule(rule)
        end
    end

    if ns:IsSafeValue(instanceID) and type(instanceID) == "number" then
        ns.Runtime.auraInstances[instanceID] = { spellID = spellID, applications = applications }
    end
end

local function HandleAuraUpdate(updateInfo)
    if not ns:IsSafeTable(updateInfo) then
        return
    end

    local isFullUpdate = updateInfo.isFullUpdate
    if ns:IsSecret(isFullUpdate) or isFullUpdate then
        return
    end

    local addedAuras = updateInfo.addedAuras
    if ns:IsSafeTable(addedAuras) then
        for _, aura in ipairs(addedAuras) do
            ProcessAura(aura, true)
        end
    end

    local updatedAuraInstanceIDs = updateInfo.updatedAuraInstanceIDs
    if ns:IsSafeTable(updatedAuraInstanceIDs) then
        for _, instanceID in ipairs(updatedAuraInstanceIDs) do
            if ns:IsSafeValue(instanceID) and type(instanceID) == "number"
                and ns.Runtime.auraInstances[instanceID] then
                local ok, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, "player", instanceID)
                if ok and aura then
                    ProcessAura(aura, false)
                end
            end
        end
    end

    local removedAuraInstanceIDs = updateInfo.removedAuraInstanceIDs
    if ns:IsSafeTable(removedAuraInstanceIDs) then
        for _, instanceID in ipairs(removedAuraInstanceIDs) do
            if ns:IsSafeValue(instanceID) and type(instanceID) == "number" then
                ns.Runtime.auraInstances[instanceID] = nil
            end
        end
    end
end

local function HandlePowerUpdate(powerToken)
    if not ns:IsSafeValue(powerToken) or powerToken ~= "ARCANE_CHARGES" or ns.Runtime.specID ~= 62 then
        return
    end
    local powerType = Enum and Enum.PowerType and Enum.PowerType.ArcaneCharges or 16
    local charges = UnitPower("player", powerType)
    if not ns:IsSafeValue(charges) or type(charges) ~= "number" then
        return
    end
    local previous = ns.Runtime.lastArcaneCharges or charges
    ns.Runtime.lastArcaneCharges = charges
    if charges >= 4 and previous < 4 then
        for _, rule in ipairs(ns.Runtime.eventRules.POWER or {}) do
            ns:PlayRule(rule)
        end
    end
end

playerFrame:SetScript("OnEvent", function(_, event, unit, arg2, arg3, arg4)
    if not ns:IsSafeValue(unit) or unit ~= "player" then
        return
    end
    IncrementEventCount(event)
    if event == "UNIT_SPELLCAST_START" then
        RouteSpellEvent("CASTING_START", arg3)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        RouteSpellEvent("SUCCEEDED", arg3)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        RouteSpellEvent("CHANNEL_START", arg3)
        RouteSpellEvent("CASTING_START", arg3)
    elseif event == "UNIT_SPELLCAST_EMPOWER_START" then
        if not HandleEmpowerStart(arg3) then
            -- Some clients populate UnitChannelInfo one frame after the event.
            C_Timer.After(0, function()
                if not HandleEmpowerStart(arg3) and ns.DB and ns.DB.debug then
                    ns:Print("Empower start received, but its player spell could not be resolved.")
                end
            end)
        end
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        if not HandleEmpowerStop(arg3, arg4) and ns.DB and ns.DB.debug then
            ns:Print("Empower stopped without a completed watched release.")
        end
    elseif event == "UNIT_AURA" then
        HandleAuraUpdate(arg2)
    elseif event == "UNIT_POWER_UPDATE" then
        HandlePowerUpdate(arg2)
    end
end)

lifecycleFrame:RegisterEvent("ADDON_LOADED")
lifecycleFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then
            return
        end
        ns:InitializeDatabase()
        ns:RecoverSoloMode()
        lifecycleFrame:RegisterEvent("PLAYER_LOGIN")
        lifecycleFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        lifecycleFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        lifecycleFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
        lifecycleFrame:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")
        lifecycleFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
        lifecycleFrame:RegisterEvent("SPELLS_CHANGED")
        lifecycleFrame:RegisterEvent("PLAYER_LOGOUT")
    elseif event == "PLAYER_LOGIN" then
        if ns.RegisterCommands then ns:RegisterCommands() end
        if ns.CreateMinimapButton then ns:CreateMinimapButton() end
        if ns.CreateOptions then
            local ok, buildError = pcall(ns.CreateOptions, ns)
            if not ok then
                ns.OptionsBuildError = buildError or true
                if ns.OptionsPanel then ns.OptionsPanel:Hide() end
                ns:Print("Options UI failed to build; commands and gameplay sounds remain available.")
            end
        end
        ns:QueueRefresh("login")
    elseif event == "PLAYER_LOGOUT" then
        if ns.DB and ns.DB.soloMode then ns:DisableSoloMode(true) end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        if arg1 == "player" then ns:QueueRefresh("specialization") end
    elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        local activeConfigID = C_ClassTalents and C_ClassTalents.GetActiveConfigID()
        if not ns:IsSafeValue(arg1) or not ns:IsSafeValue(activeConfigID) or arg1 == activeConfigID then
            ns:QueueRefresh("talents")
        end
    else
        ns:QueueRefresh(event)
    end
end)
