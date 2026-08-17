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
}

local CASTING_END_EVENTS = {
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_FAILED_QUIET",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_STOP",
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
    if self.StopCastingSounds then
        self:StopCastingSounds(0.08)
    end
    playerFrame:UnregisterAllEvents()
    self.Runtime.activeRules = {}
    self.Runtime.eventRules = {}
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
            if rule.event == "CASTING_START" then
                for _, eventName in ipairs(CASTING_END_EVENTS) do
                    eventsNeeded[eventName] = true
                end
            end
        end
    end

    for event in pairs(eventsNeeded) do
        playerFrame:RegisterUnitEvent(event, "player")
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
        ns:StopCastingSounds(0.08)
        if not HandleEmpowerStop(arg3, arg4) and ns.DB and ns.DB.debug then
            ns:Print("Empower stopped without a completed watched release.")
        end
    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_FAILED_QUIET"
        or event == "UNIT_SPELLCAST_INTERRUPTED"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        ns:StopCastingSounds(0.08)
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
