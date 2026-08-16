local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.VERSION = "1.8.3"
ns.COLOR = "|cff9d7cff"
ns.SPEC_ORDER = {
    71, 72, 73,       -- Warrior
    65, 66, 70,       -- Paladin
    253, 254, 255,    -- Hunter
    259, 260, 261,    -- Rogue
    256, 257, 258,    -- Priest
    250, 251, 252,    -- Death Knight
    262, 263, 264,    -- Shaman
    62, 63, 64,       -- Mage
    265, 266, 267,    -- Warlock
    268, 269, 270,    -- Monk
    102, 103, 104, 105, -- Druid
    577, 581, 1480,   -- Demon Hunter
    1467, 1468, 1473, -- Evoker
}
ns.SUPPORTED_SPECS = {
    [71] = "Arms Warrior",
    [72] = "Fury Warrior",
    [73] = "Protection Warrior",
    [65] = "Holy Paladin",
    [66] = "Protection Paladin",
    [70] = "Retribution Paladin",
    [253] = "Beast Mastery Hunter",
    [254] = "Marksmanship Hunter",
    [255] = "Survival Hunter",
    [259] = "Assassination Rogue",
    [260] = "Outlaw Rogue",
    [261] = "Subtlety Rogue",
    [256] = "Discipline Priest",
    [257] = "Holy Priest",
    [258] = "Shadow Priest",
    [250] = "Blood Death Knight",
    [251] = "Frost Death Knight",
    [252] = "Unholy Death Knight",
    [262] = "Elemental Shaman",
    [263] = "Enhancement Shaman",
    [264] = "Restoration Shaman",
    [62] = "Arcane Mage",
    [63] = "Fire Mage",
    [64] = "Frost Mage",
    [265] = "Affliction Warlock",
    [266] = "Demonology Warlock",
    [267] = "Destruction Warlock",
    [268] = "Brewmaster Monk",
    [269] = "Windwalker Monk",
    [270] = "Mistweaver Monk",
    [102] = "Balance Druid",
    [103] = "Feral Druid",
    [104] = "Guardian Druid",
    [105] = "Restoration Druid",
    [577] = "Havoc Demon Hunter",
    [581] = "Vengeance Demon Hunter",
    [1480] = "Devourer Demon Hunter",
    [1467] = "Devastation Evoker",
    [1468] = "Preservation Evoker",
    [1473] = "Augmentation Evoker",
}
ns.BUILTIN_SET_VERSION = 4
ns.CURATED_PRESETS = {
    { key = "subtle", name = "Resonance Subtle" },
    { key = "medium", name = "Resonance Medium" },
    { key = "expressive", name = "Resonance Expressive" },
}

local DEFAULTS = {
    version = 5,
    enabled = true,
    palette = "subtle",
    channel = "SFX",
    specEnabled = {},
    ruleOverrides = {},
    ruleSettings = {},
    specProfiles = {},
    favorites = {},
    soundSortDebug = false,
    categoryDraft = {},
    deleteDraft = {},
    categoryExport = nil,
    minimap = {
        hide = false,
        angle = 225,
    },
    debug = false,
    soloMode = false,
}

for specID in pairs(ns.SUPPORTED_SPECS) do
    DEFAULTS.specEnabled[specID] = true
end

local CHARACTER_DEFAULTS = {
    version = 3,
    specs = {},
}

ns.DEFAULTS = DEFAULTS
ns.Runtime = {
    capabilities = { hasSpellID = {}, rankBySpellID = {} },
    activeRules = {},
    auraInstances = {},
    lastRulePlay = {},
    refreshQueued = false,
    eventCounts = {},
    castingSoundGeneration = 0,
    castingSoundHandles = {},
    castingSoundTimers = {},
}

local function CopyDefaults(source)
    local result = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyDefaults(value)
        else
            result[key] = value
        end
    end
    return result
end

local function FillDefaults(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = type(value) == "table" and CopyDefaults(value) or value
        elseif type(value) == "table" and type(target[key]) == "table" then
            FillDefaults(target[key], value)
        end
    end
end

function ns:InitializeDatabase()
    if type(ResonanceDB) ~= "table" then
        ResonanceDB = CopyDefaults(DEFAULTS)
    else
        if type(ResonanceDB.specEnabled) ~= "table" then ResonanceDB.specEnabled = {} end
        if type(ResonanceDB.ruleOverrides) ~= "table" then ResonanceDB.ruleOverrides = {} end
        if type(ResonanceDB.ruleSettings) ~= "table" then ResonanceDB.ruleSettings = {} end
        if type(ResonanceDB.specProfiles) ~= "table" then ResonanceDB.specProfiles = {} end
        if type(ResonanceDB.favorites) ~= "table" then ResonanceDB.favorites = {} end
        if type(ResonanceDB.categoryDraft) ~= "table" then ResonanceDB.categoryDraft = {} end
        if type(ResonanceDB.deleteDraft) ~= "table" then ResonanceDB.deleteDraft = {} end
        if type(ResonanceDB.minimap) ~= "table" then ResonanceDB.minimap = {} end
        FillDefaults(ResonanceDB, DEFAULTS)
    end

    if not self.SoundPalettes[ResonanceDB.palette] then ResonanceDB.palette = DEFAULTS.palette end
    -- Density was a runtime filter before 1.1. Presets now own actual rule toggles.
    ResonanceDB.density = nil
    if ResonanceDB.channel ~= "SFX" and ResonanceDB.channel ~= "Dialog" and ResonanceDB.channel ~= "Master" then
        ResonanceDB.channel = DEFAULTS.channel
    end
    if type(ResonanceDB.enabled) ~= "boolean" then ResonanceDB.enabled = DEFAULTS.enabled end
    if type(ResonanceDB.debug) ~= "boolean" then ResonanceDB.debug = DEFAULTS.debug end
    if type(ResonanceDB.soloMode) ~= "boolean" then ResonanceDB.soloMode = false end
    if type(ResonanceDB.soundSortDebug) ~= "boolean" then ResonanceDB.soundSortDebug = false end
    for specID, defaultValue in pairs(DEFAULTS.specEnabled) do
        if type(ResonanceDB.specEnabled[specID]) ~= "boolean" then
            ResonanceDB.specEnabled[specID] = defaultValue
        end
    end
    for ruleID, enabled in pairs(ResonanceDB.ruleOverrides) do
        if type(ruleID) ~= "string" or type(enabled) ~= "boolean" then
            ResonanceDB.ruleOverrides[ruleID] = nil
        end
    end
    self:InitializeProfiles()
    self:InitializeCharacterProfiles()
    if type(ResonanceDB.minimap.hide) ~= "boolean" then ResonanceDB.minimap.hide = DEFAULTS.minimap.hide end
    if type(ResonanceDB.minimap.angle) ~= "number" then ResonanceDB.minimap.angle = DEFAULTS.minimap.angle end

    if ResonanceDB.version ~= DEFAULTS.version then
        ResonanceDB.version = DEFAULTS.version
    end

    self.DB = ResonanceDB
    self.CharDB = ResonanceCharDB
end

function ns:InitializeProfiles()
    local hadLegacy = next(ResonanceDB.ruleOverrides or {}) ~= nil or next(ResonanceDB.ruleSettings or {}) ~= nil
    for specID in pairs(self.SUPPORTED_SPECS) do
        local store = ResonanceDB.specProfiles[specID]
        if type(store) ~= "table" then
            store = { active = hadLegacy and "Migrated" or "Default", profiles = {} }
            ResonanceDB.specProfiles[specID] = store
        end
        if type(store.profiles) ~= "table" then store.profiles = {} end
        if type(store.active) ~= "string" or store.active == "" then store.active = "Default" end
        if type(store.profiles[store.active]) ~= "table" then
            store.profiles[store.active] = { rules = {} }
        end
        for name, profile in pairs(store.profiles) do
            if type(name) ~= "string" or type(profile) ~= "table" then
                store.profiles[name] = nil
            elseif type(profile.rules) ~= "table" then
                profile.rules = {}
            end
        end
    end

    if ResonanceDB.version and ResonanceDB.version < 3 and hadLegacy then
        for ruleID, rule in pairs(self.RuleByID or {}) do
            local legacyEnabled = ResonanceDB.ruleOverrides[ruleID]
            local legacy = ResonanceDB.ruleSettings[ruleID]
            if legacyEnabled ~= nil or type(legacy) == "table" then
                local profile = ResonanceDB.specProfiles[rule.spec].profiles.Migrated
                profile.rules[ruleID] = profile.rules[ruleID] or {}
                profile.rules[ruleID].enabled = legacyEnabled
                if legacy and legacy.layers == 2 then profile.rules[ruleID].layerCount = 2 end
            end
        end
    end
end

local function DeepCopy(source)
    if type(source) ~= "table" then return source end
    local copy = {}
    for key, value in pairs(source) do copy[key] = DeepCopy(value) end
    return copy
end

local SOUND_ID_REMAP = {
    [1884443] = 568175, -- encrypted Avenging Wrath revamp take -> verified legacy impact
}

local function RemapSetSounds(set)
    if type(set) ~= "table" or type(set.rules) ~= "table" then return end
    for _, config in pairs(set.rules) do
        if type(config) == "table" and type(config.layers) == "table" then
            for _, layer in pairs(config.layers) do
                if type(layer) == "table" and SOUND_ID_REMAP[layer.soundID] then
                    layer.soundID = SOUND_ID_REMAP[layer.soundID]
                end
            end
        end
    end
end

local PRESET_RANK = { subtle = 1, medium = 2, expressive = 3 }

local function BuildCuratedPreset(specID, presetKey)
    local targetRank = PRESET_RANK[presetKey] or 2
    local preset = { rules = {}, builtin = true, builtinVersion = ns.BUILTIN_SET_VERSION, preset = presetKey }
    for _, rule in ipairs(ns.RulesBySpec[specID] or {}) do
        local curated = ns.CuratedRulePresets and ns.CuratedRulePresets[rule.id]
        local curatedPreset = curated and curated[presetKey]
        if type(curatedPreset) == "table" then
            local config = { enabled = curatedPreset.enabled == true, layers = {} }
            local layerCount = math.max(2, #(rule.defaultSounds or {}), #(curatedPreset.layers or {}))
            for index = 1, math.min(ns.MAX_RULE_LAYERS or 8, layerCount) do
                local source = curatedPreset.layers and curatedPreset.layers[index]
                if type(source) == "table" and tonumber(source.soundID) and ns.SoundByID[tonumber(source.soundID)] then
                    config.layers[index] = {
                        enabled = source.enabled ~= false,
                        soundID = tonumber(source.soundID),
                        delayMs = math.max(0, math.min(5000, math.floor(tonumber(source.delayMs) or 0))),
                    }
                else
                    config.layers[index] = { enabled = false, soundID = false, delayMs = 0 }
                end
            end
            preset.rules[rule.id] = config
        else
            -- Compatibility fallback for rules awaiting a dedicated curation.
            local ruleRank = PRESET_RANK[rule.preset]
            local enabled = false
            if rule.defaultOn and ruleRank and ruleRank <= targetRank then
                enabled = true
            elseif presetKey == "expressive" and rule.preset ~= "custom" then
                enabled = true
            end
            preset.rules[rule.id] = { enabled = enabled }
        end
    end
    return preset
end

function ns:InitializeCharacterProfiles()
    if type(ResonanceCharDB) ~= "table" then ResonanceCharDB = CopyDefaults(CHARACTER_DEFAULTS) end
    if type(ResonanceCharDB.specs) ~= "table" then ResonanceCharDB.specs = {} end
    for specID in pairs(self.SUPPORTED_SPECS) do
        local store = ResonanceCharDB.specs[specID]
        local createdStore = type(store) ~= "table"
        if type(store) ~= "table" then
            store = { working = nil, savedSets = {}, loadedName = nil }
            ResonanceCharDB.specs[specID] = store
        end
        if type(store.savedSets) ~= "table" then store.savedSets = {} end
        if type(store.working) ~= "table" then
            local legacyStore = ResonanceDB.specProfiles and ResonanceDB.specProfiles[specID]
            local legacy = legacyStore and legacyStore.profiles and legacyStore.profiles[legacyStore.active]
            store.working = type(legacy) == "table" and DeepCopy(legacy) or { rules = {} }
        end
        if type(store.working.rules) ~= "table" then store.working.rules = {} end
        RemapSetSounds(store.working)
        for name, set in pairs(store.savedSets) do
            if type(name) ~= "string" or type(set) ~= "table" then
                store.savedSets[name] = nil
            elseif type(set.rules) ~= "table" then
                set.rules = {}
            end
            RemapSetSounds(set)
        end
        local oldBase = store.savedSets["Resonance Base"]
        if type(oldBase) == "table" and oldBase.builtin == true then
            store.savedSets["Resonance Base"] = nil
            if store.loadedName == "Resonance Base" then store.loadedName = nil end
        end
        local refreshLoadedBuiltin
        for _, definition in ipairs(self.CURATED_PRESETS) do
            local existing = store.savedSets[definition.name]
            if existing == nil or (type(existing) == "table" and existing.builtin == true
                and (tonumber(existing.builtinVersion) or 0) < self.BUILTIN_SET_VERSION) then
                store.savedSets[definition.name] = BuildCuratedPreset(specID, definition.key)
                if store.loadedName == definition.name then refreshLoadedBuiltin = definition.name end
            end
        end
        if createdStore then
            store.working = DeepCopy(store.savedSets["Resonance Medium"])
            store.loadedName = "Resonance Medium"
        elseif refreshLoadedBuiltin then
            -- Editing any layer clears loadedName, so this only refreshes an
            -- untouched built-in preset and never overwrites custom work.
            store.working = DeepCopy(store.savedSets[refreshLoadedBuiltin])
            store.loadedName = refreshLoadedBuiltin
        end
    end
    ResonanceCharDB.version = CHARACTER_DEFAULTS.version
end

function ns:GetSpecProfileStore(specID)
    specID = specID or self.Runtime.specID
    return specID and self.CharDB and self.CharDB.specs[specID]
end

function ns:GetActiveProfile(specID)
    local store = self:GetSpecProfileStore(specID)
    return store and store.working, store and store.loadedName
end

function ns:GetRuleConfig(ruleID, create)
    local rule = self.RuleByID[ruleID]
    if not rule then return nil end
    local profile = self:GetActiveProfile(rule.spec)
    if not profile then return nil end
    local config = profile.rules[ruleID]
    if not config and create then
        config = {}
        profile.rules[ruleID] = config
    end
    return config
end

ns.MAX_RULE_LAYERS = 8

function ns:GetRuleLayerCount(rule)
    local count = math.max(2, #(rule.defaultSounds or {}))
    local config = self:GetRuleConfig(rule.id, false)
    if config and type(config.layers) == "table" then
        for index in pairs(config.layers) do
            if type(index) == "number" and index > count then count = index end
        end
    end
    return math.min(self.MAX_RULE_LAYERS, count)
end

function ns:GetLayerConfig(rule, index)
    local config = self:GetRuleConfig(rule.id, false)
    local layer = config and config.layers and config.layers[index]
    local default = rule.defaultSounds and rule.defaultSounds[index]
    local soundID = default
    if layer ~= nil then soundID = layer.soundID end
    return {
        enabled = layer ~= nil and layer.enabled ~= false or (layer == nil and default ~= nil),
        soundID = soundID,
        delayMs = layer and tonumber(layer.delayMs)
            or (rule.defaultDelays and tonumber(rule.defaultDelays[index]))
            or (index == 1 and math.floor((rule.delay or 0) * 1000 + 0.5) or 0),
    }
end

function ns:AddRuleLayer(rule)
    local count = self:GetRuleLayerCount(rule)
    if count >= self.MAX_RULE_LAYERS then return false end
    local config = self:GetRuleConfig(rule.id, true)
    config.layers = config.layers or {}
    config.layers[count + 1] = { enabled = false, soundID = false, delayMs = 0 }
    local store = self:GetSpecProfileStore(rule.spec)
    if store then store.loadedName = nil end
    return true
end

function ns:RemoveRuleLayer(rule, index)
    if index < 3 or index > self:GetRuleLayerCount(rule) then return false end
    local config = self:GetRuleConfig(rule.id, true)
    config.layers = config.layers or {}
    for fill = 1, self:GetRuleLayerCount(rule) do
        if config.layers[fill] == nil then
            local current = self:GetLayerConfig(rule, fill)
            config.layers[fill] = { enabled = current.enabled, soundID = current.soundID or false, delayMs = current.delayMs or 0 }
        end
    end
    table.remove(config.layers, index)
    local store = self:GetSpecProfileStore(rule.spec)
    if store then store.loadedName = nil end
    return true
end

function ns:SetLayerConfig(rule, index, values)
    local config = self:GetRuleConfig(rule.id, true)
    config.layers = config.layers or {}
    local layer = config.layers[index] or {}
    config.layers[index] = layer
    if values.enabled ~= nil then layer.enabled = values.enabled and true or false end
    if values.soundID ~= nil then layer.soundID = tonumber(values.soundID) end
    if values.clearSound then layer.soundID = false end
    if values.delayMs ~= nil then layer.delayMs = math.max(0, math.min(5000, math.floor(tonumber(values.delayMs) or 0))) end
    local store = self:GetSpecProfileStore(rule.spec)
    if store then store.loadedName = nil end
end

function ns:SaveSoundSet(specID, name)
    local store = self:GetSpecProfileStore(specID)
    name = type(name) == "string" and name:match("^%s*(.-)%s*$") or ""
    if not store or name == "" then return false end
    if store.savedSets[name] and store.savedSets[name].builtin == true then
        return false, "builtin"
    end
    store.savedSets[name] = DeepCopy(store.working)
    store.savedSets[name].builtin = nil
    store.savedSets[name].builtinVersion = nil
    store.savedSets[name].baseVersion = nil
    store.savedSets[name].preset = nil
    store.savedSets[name].savedAt = GetServerTime and GetServerTime() or 0
    store.loadedName = name
    self:QueueRefresh("sound set saved")
    return true
end

function ns:LoadSoundSet(specID, name)
    local store = self:GetSpecProfileStore(specID)
    if not store or type(store.savedSets[name]) ~= "table" then return false end
    store.working = DeepCopy(store.savedSets[name])
    store.loadedName = name
    self:QueueRefresh("sound set loaded")
    return true
end

function ns:DeleteSoundSet(specID, name)
    local store = self:GetSpecProfileStore(specID)
    if not store or not store.savedSets[name] then return false end
    if store.savedSets[name].builtin == true then return false, "builtin" end
    store.savedSets[name] = nil
    if store.loadedName == name then store.loadedName = nil end
    return true
end

function ns:GetSoundSetNames(specID)
    local store = self:GetSpecProfileStore(specID)
    local names = {}
    if store then for name in pairs(store.savedSets) do names[#names + 1] = name end end
    local presetOrder = {
        ["Resonance Subtle"] = 1,
        ["Resonance Medium"] = 2,
        ["Resonance Expressive"] = 3,
    }
    table.sort(names, function(left, right)
        local leftOrder, rightOrder = presetOrder[left], presetOrder[right]
        if leftOrder or rightOrder then
            return (leftOrder or 99) < (rightOrder or 99)
        end
        return left < right
    end)
    return names
end

function ns:ResetDatabase()
    if self.DB and self.DB.soloMode and self.DisableSoloMode then
        self:DisableSoloMode(true)
    end
    ResonanceDB = CopyDefaults(DEFAULTS)
    self:InitializeProfiles()
    ResonanceCharDB = CopyDefaults(CHARACTER_DEFAULTS)
    self:InitializeCharacterProfiles()
    self.DB = ResonanceDB
    self.CharDB = ResonanceCharDB
    self:QueueRefresh("reset")
    if self.RefreshOptions then
        self:RefreshOptions()
    end
    if self.UpdateMinimapButton then
        self:UpdateMinimapButton()
    end
end

function ns:GetRuleTone(ruleID)
    local settings = self.DB.ruleSettings[ruleID]
    return settings and settings.tone or "default"
end

function ns:SetRuleTone(ruleID, tone)
    local valid = tone == "soft" or tone == "bright" or tone == "impact" or tone == "apex"
    local settings = self.DB.ruleSettings[ruleID]
    if not valid then
        if settings then settings.tone = nil end
        return
    end
    if type(settings) ~= "table" then
        settings = {}
        self.DB.ruleSettings[ruleID] = settings
    end
    settings.tone = tone
end

function ns:GetRuleLayers(ruleID)
    local settings = self.DB.ruleSettings[ruleID]
    return settings and settings.layers == 2 and 2 or 1
end

function ns:SetRuleLayers(ruleID, layers)
    local settings = self.DB.ruleSettings[ruleID]
    if layers ~= 2 then
        if settings then settings.layers = nil end
        return
    end
    if type(settings) ~= "table" then
        settings = {}
        self.DB.ruleSettings[ruleID] = settings
    end
    settings.layers = 2
end

function ns:IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

function ns:IsSafeValue(value)
    if self:IsSecret(value) then
        return false
    end
    return value ~= nil
end

function ns:IsSafeTable(value)
    if self:IsSecret(value) then
        return false
    end
    return type(value) == "table"
end

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(self.COLOR .. "Resonance:|r " .. tostring(message))
end

function ns:GetRuleEnabled(rule)
    local config = self:GetRuleConfig(rule.id, false)
    local override = config and config.enabled
    if override ~= nil then
        return override
    end
    return rule.defaultOn
end

function ns:SetRuleEnabled(ruleID, enabled)
    local rule = self.RuleByID[ruleID]
    if not rule then
        return
    end
    local config = self:GetRuleConfig(ruleID, true)
    config.enabled = enabled == rule.defaultOn and nil or (enabled and true or false)
    local store = self:GetSpecProfileStore(rule.spec)
    if store then store.loadedName = nil end
    self:QueueRefresh("rule")
end

function ns:GetCharacterLabel()
    local name = UnitName("player")
    local realm = GetRealmName()
    if not self:IsSafeValue(name) or type(name) ~= "string" then name = "Unknown" end
    if not self:IsSafeValue(realm) or type(realm) ~= "string" then realm = "Unknown Realm" end
    return name .. " - " .. realm
end
