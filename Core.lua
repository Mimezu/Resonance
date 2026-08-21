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
    local specializationIndex
    if type(GetSpecialization) == "function" then
        local ok, value = pcall(GetSpecialization)
        if ok then specializationIndex = value end
    end
    if not ns:IsSafeValue(specializationIndex) or type(specializationIndex) ~= "number" then
        return nil
    end
    local specID
    if type(GetSpecializationInfo) == "function" then
        local ok, value = pcall(GetSpecializationInfo, specializationIndex)
        if ok then specID = value end
    end
    if ns:IsSafeValue(specID) and type(specID) == "number" then
        return specID
    end
    return nil
end

function ns:CompileRules()
    if self.InvalidateRuntimeAudio then
        self:InvalidateRuntimeAudio(true)
    elseif self.CancelDelayedSoundTimers then
        self:CancelDelayedSoundTimers()
    end
    if self.StopCastingSounds then
        self:StopCastingSounds(0.08)
    end
    playerFrame:UnregisterAllEvents()
    self.Runtime.activeRules = {}
    self.Runtime.eventRules = {}
    self.Runtime.eventSpellRules = {}
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
            local spellRules = self.Runtime.eventSpellRules[rule.event]
            if not spellRules then
                spellRules = {}
                self.Runtime.eventSpellRules[rule.event] = spellRules
            end
            for spellID in pairs(rule.spellSet or {}) do
                local matching = spellRules[spellID]
                if not matching then
                    matching = {}
                    spellRules[spellID] = matching
                end
                matching[#matching + 1] = rule
            end
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

-- A current action can be an override of the spell ID stored in a rule (for
-- example a talent/Apex replacement).  Exact IDs always win: the base-ID
-- lookup is only a safe fallback when no rule owns the active spell itself.
-- This avoids conflating two separately exposed moments while still allowing
-- a base rule to survive a client-side spell morph.
local function GetRouteRules(routeName, spellID)
    if not ns:IsSafeValue(spellID) or type(spellID) ~= "number" then
        return nil
    end
    local bySpell = ns.Runtime.eventSpellRules[routeName]
    if not bySpell then
        return nil
    end
    local rules = bySpell and bySpell[spellID]
    if rules then
        return rules
    end

    local getBaseSpell = C_Spell and C_Spell.GetBaseSpell
    if type(getBaseSpell) ~= "function" then
        return nil
    end
    local ok, baseSpellID = pcall(getBaseSpell, spellID)
    if not ok or not ns:IsSafeValue(baseSpellID) or type(baseSpellID) ~= "number"
        or baseSpellID <= 0 or baseSpellID == spellID then
        return nil
    end
    return bySpell[baseSpellID]
end

local function RouteSpellEvent(routeName, spellID)
    local rules = GetRouteRules(routeName, spellID)
    if not rules then return false end
    local played = false
    for _, rule in ipairs(rules) do
        local rulePlayed, _, replacedCasting = ns:PlayRule(rule)
        if replacedCasting then
            -- CASTING_START playback deliberately replaces any prior casting
            -- accent, so the latest rule that reached that boundary owns the
            -- final played state. Cooldown/unresolved early exits do not.
            played = rulePlayed == true
        else
            played = rulePlayed == true or played
        end
    end
    return true, played
end

local function TrackCastingRule(castGUID, spellID)
    if ns:IsSafeValue(castGUID) and type(castGUID) == "string" then
        ns.Runtime.castingCastGUID = castGUID
    else
        ns.Runtime.castingCastGUID = nil
    end
    ns.Runtime.castingSpellID = ns:IsSafeValue(spellID) and type(spellID) == "number" and spellID or nil
end

local function StopTrackedCasting(castGUID, spellID)
    local trackedGUID = ns.Runtime.castingCastGUID
    local trackedSpellID = ns.Runtime.castingSpellID
    if not trackedGUID and not trackedSpellID then return false end
    if trackedGUID and ns:IsSafeValue(castGUID) and type(castGUID) == "string" and castGUID ~= trackedGUID then
        return false
    end
    if not trackedGUID and trackedSpellID and ns:IsSafeValue(spellID)
        and type(spellID) == "number" and spellID ~= trackedSpellID then
        return false
    end
    ns:StopCastingSounds(0.08)
    return true
end

local function SpellMatchesRoute(routeName, spellID)
    return GetRouteRules(routeName, spellID) ~= nil
end

local function ReadPlayerSpellInfo(api, spellIndex, flagIndex)
    if type(api) ~= "function" then return nil end
    local ok, a, b, c, d, e, f, g, h, i = pcall(api, "player")
    if not ok then return nil end
    local value = spellIndex == 8 and h or spellIndex == 9 and i or nil
    if not ns:IsSafeValue(value) or type(value) ~= "number" then value = nil end
    local flag = flagIndex == 9 and i or nil
    return value, flag
end

local function GetPlayerEmpowerSpellID(routeName, eventSpellID, allowStored)
    if SpellMatchesRoute(routeName, eventSpellID) then return eventSpellID end

    -- Empower casts are represented by UnitChannelInfo on Retail. This fallback
    -- also avoids depending on an event spell ID that may be unavailable.
    local channelSpellID, isEmpowered = ReadPlayerSpellInfo(UnitChannelInfo, 8, 9)
    if ns:IsSafeValue(isEmpowered) and isEmpowered and SpellMatchesRoute(routeName, channelSpellID) then
        return channelSpellID
    end

    local castingSpellID = ReadPlayerSpellInfo(UnitCastingInfo, 9)
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
    local castingMatched, castingPlayed = RouteSpellEvent("CASTING_START", spellID)
    return castingMatched or matched, castingPlayed, spellID
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
    if event == "UNIT_SPELLCAST_START" then
        local _, played = RouteSpellEvent("CASTING_START", arg3)
        if played then TrackCastingRule(arg2, arg3) end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        RouteSpellEvent("SUCCEEDED", arg3)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        RouteSpellEvent("CHANNEL_START", arg3)
        local _, played = RouteSpellEvent("CASTING_START", arg3)
        if played then TrackCastingRule(arg2, arg3) end
    elseif event == "UNIT_SPELLCAST_EMPOWER_START" then
        local matched, castingPlayed, spellID = HandleEmpowerStart(arg3)
        if castingPlayed then TrackCastingRule(arg2, spellID) end
        if not matched then
            -- Some clients populate UnitChannelInfo one frame after the event.
            C_Timer.After(0, function()
                local delayedMatched, delayedCastingPlayed, delayedSpellID = HandleEmpowerStart(arg3)
                if delayedCastingPlayed then TrackCastingRule(arg2, delayedSpellID) end
                if not delayedMatched and ns.DB and ns.DB.debug then
                    ns:Print("Empower start received, but its player spell could not be resolved.")
                end
            end)
        end
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        StopTrackedCasting(arg2, arg3)
        if not HandleEmpowerStop(arg3, arg4) and ns.DB and ns.DB.debug then
            ns:Print("Empower stopped without a completed watched release.")
        end
    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_FAILED_QUIET"
        or event == "UNIT_SPELLCAST_INTERRUPTED"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        StopTrackedCasting(arg2, arg3)
    end
end)

lifecycleFrame:RegisterEvent("ADDON_LOADED")
lifecycleFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then
            return
        end
        lifecycleFrame:UnregisterEvent("ADDON_LOADED")
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
        if ns.RegisterSettingsLauncher then
            local ok, buildError = pcall(ns.RegisterSettingsLauncher, ns)
            if not ok then
                ns.SettingsLauncherError = buildError or true
                ns:Print("Settings launcher failed to register; /res and gameplay sounds remain available.")
            end
        end
        ns:QueueRefresh("login")
    elseif event == "PLAYER_LOGOUT" then
        if ns.DB and ns.DB.soloMode then ns:DisableSoloMode(true) end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        if arg1 == "player" then ns:QueueRefresh("specialization") end
    elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        local activeConfigID
        if C_ClassTalents and type(C_ClassTalents.GetActiveConfigID) == "function" then
            local ok, value = pcall(C_ClassTalents.GetActiveConfigID)
            if ok then activeConfigID = value end
        end
        if not ns:IsSafeValue(arg1) or not ns:IsSafeValue(activeConfigID) or arg1 == activeConfigID then
            ns:QueueRefresh("talents")
        end
    else
        ns:QueueRefresh(event)
    end
end)
