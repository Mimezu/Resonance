local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.VERSION = "1.9.0"
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
ns.PROFILE_SCHEMA_VERSION = 1
ns.RULE_CATALOG_VERSION = 1
ns.SOUND_CATALOG_VERSION = 1
ns.CURATED_PRESETS = {
    { key = "subtle", name = "Resonance Subtle" },
    { key = "medium", name = "Resonance Medium" },
    { key = "expressive", name = "Resonance Expressive" },
}

local DEFAULTS = {
    version = 6,
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
    version = 4,
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

-- Compatibility registries are intentionally permanent. Never reuse a retired
-- rule ID for another spell; point it at its successor here instead. Removed
-- sounds should be remapped here or retained as hidden catalog tombstones.
local SOUND_ID_REMAP = {
    [1884443] = 568175, -- encrypted Avenging Wrath revamp take -> verified legacy impact
}
local RULE_ID_ALIASES = {}
local CATEGORY_ID_ALIASES = {}
ns.SoundIDRemap = SOUND_ID_REMAP
ns.RuleIDAliases = RULE_ID_ALIASES
ns.CategoryIDAliases = CATEGORY_ID_ALIASES

local function ResolveAlias(mapping, value)
    local seen = {}
    while mapping[value] ~= nil and not seen[value] do
        seen[value] = true
        value = mapping[value]
    end
    return value
end

local function ValidateAliasMap(name, mapping)
    for start in pairs(mapping) do
        local seen, value = {}, start
        while mapping[value] ~= nil do
            if seen[value] then
                error("Resonance " .. name .. " alias cycle at " .. tostring(value))
            end
            seen[value] = true
            value = mapping[value]
        end
    end
end

local function ValidateCompatibilityRegistries(owner)
    ValidateAliasMap("sound", SOUND_ID_REMAP)
    ValidateAliasMap("rule", RULE_ID_ALIASES)
    ValidateAliasMap("category", CATEGORY_ID_ALIASES)

    local validCategories = {}
    for _, category in ipairs(owner.SoundCategories or {}) do validCategories[category.id] = true end
    for oldID in pairs(SOUND_ID_REMAP) do
        local target = ResolveAlias(SOUND_ID_REMAP, oldID)
        if not (owner.SoundByID and owner.SoundByID[target]) then
            owner:Print("Compatibility warning: sound " .. oldID .. " maps to missing " .. tostring(target))
        end
    end
    for oldID in pairs(RULE_ID_ALIASES) do
        local target = ResolveAlias(RULE_ID_ALIASES, oldID)
        if not (owner.RuleByID and owner.RuleByID[target]) then
            owner:Print("Compatibility warning: rule " .. oldID .. " maps to missing " .. tostring(target))
        end
    end
    for oldID in pairs(CATEGORY_ID_ALIASES) do
        local target = ResolveAlias(CATEGORY_ID_ALIASES, oldID)
        if not validCategories[target] then
            owner:Print("Compatibility warning: category " .. oldID .. " maps to missing " .. tostring(target))
        end
    end
end

local function RemapNumericKeyedTable(source)
    if type(source) ~= "table" then return {} end
    local migrated = {}
    -- Canonical keys win if an old and a new identifier coexist.
    for key, value in pairs(source) do
        local soundID = tonumber(key)
        if not soundID or ResolveAlias(SOUND_ID_REMAP, soundID) == soundID then
            migrated[soundID or key] = value
        end
    end
    for key, value in pairs(source) do
        local soundID = tonumber(key)
        if soundID then
            local resolved = ResolveAlias(SOUND_ID_REMAP, soundID)
            if migrated[resolved] == nil then migrated[resolved] = value end
        end
    end
    return migrated
end

local function NormalizeAccountSoundReferences(database)
    database.favorites = RemapNumericKeyedTable(database.favorites)
    database.categoryDraft = RemapNumericKeyedTable(database.categoryDraft)
    database.deleteDraft = RemapNumericKeyedTable(database.deleteDraft)
    if type(database.categoryExport) == "table" then
        local export = database.categoryExport
        local hadCompactMaps = type(export.moves) == "table" or type(export.deletions) == "table"
        if not hadCompactMaps and type(export.sounds) == "table" then
            export.moves, export.deletions = {}, {}
            for _, entry in ipairs(export.sounds) do
                if type(entry) == "table" and tonumber(entry.id) then
                    local soundID = ResolveAlias(SOUND_ID_REMAP, tonumber(entry.id))
                    local categoryID = ResolveAlias(CATEGORY_ID_ALIASES, entry.category)
                    local canonical = ns.SoundByID and ns.SoundByID[soundID]
                    if canonical and categoryID and categoryID ~= canonical.category then
                        export.moves[soundID] = categoryID
                    end
                    if entry.deleted then export.deletions[soundID] = true end
                end
            end
        else
            export.moves = RemapNumericKeyedTable(export.moves)
            export.deletions = RemapNumericKeyedTable(export.deletions)
        end
        for soundID, categoryID in pairs(export.moves) do
            export.moves[soundID] = ResolveAlias(CATEGORY_ID_ALIASES, categoryID)
        end
        if type(export.sounds) == "table" then
            for _, sound in ipairs(export.sounds) do
                if type(sound) == "table" and tonumber(sound.id) then
                    sound.id = ResolveAlias(SOUND_ID_REMAP, tonumber(sound.id))
                    sound.category = ResolveAlias(CATEGORY_ID_ALIASES, sound.category)
                end
            end
        end
    end

    local validCategories = {}
    for _, category in ipairs(ns.SoundCategories or {}) do validCategories[category.id] = true end
    database.legacyCategoryDraft = type(database.legacyCategoryDraft) == "table"
        and database.legacyCategoryDraft or {}
    for soundID, categoryID in pairs(database.categoryDraft) do
        local migratedCategory = ResolveAlias(CATEGORY_ID_ALIASES, categoryID)
        if validCategories[migratedCategory] then
            database.categoryDraft[soundID] = migratedCategory
        else
            -- Preserve the old value for a future alias while returning the
            -- sound to its canonical category instead of hiding it.
            database.legacyCategoryDraft[soundID] = categoryID
            database.categoryDraft[soundID] = nil
        end
    end
end

local ACCOUNT_MIGRATIONS = {
    [6] = function() end, -- Introduced ordered migrations and compatibility metadata.
}

local function RunOrderedMigrations(database, previousVersion, currentVersion, migrations)
    previousVersion = math.max(0, math.floor(tonumber(previousVersion) or 0))
    for version = previousVersion + 1, currentVersion do
        local migrate = migrations[version]
        if migrate then migrate(database) end
        -- Advance one step at a time. If a later migration errors, WoW will not
        -- falsely claim the database reached a schema it never completed.
        database.version = version
    end
end

local function MigrateAccountDatabase(database, previousVersion)
    if previousVersion > DEFAULTS.version then return end
    RunOrderedMigrations(database, previousVersion, DEFAULTS.version, ACCOUNT_MIGRATIONS)
    -- Identifier aliases may grow without changing the surrounding table shape.
    NormalizeAccountSoundReferences(database)
    database.version = DEFAULTS.version
end

function ns:InitializeDatabase()
    ValidateCompatibilityRegistries(self)
    local previousAccountVersion
    if type(ResonanceDB) ~= "table" then
        ResonanceDB = CopyDefaults(DEFAULTS)
        previousAccountVersion = DEFAULTS.version
    else
        previousAccountVersion = tonumber(ResonanceDB.version) or 0
        MigrateAccountDatabase(ResonanceDB, previousAccountVersion)
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
    self:InitializeProfiles(previousAccountVersion)
    self:InitializeCharacterProfiles()
    if type(ResonanceDB.minimap.hide) ~= "boolean" then ResonanceDB.minimap.hide = DEFAULTS.minimap.hide end
    if type(ResonanceDB.minimap.angle) ~= "number" then ResonanceDB.minimap.angle = DEFAULTS.minimap.angle end

    if (tonumber(ResonanceDB.version) or 0) < DEFAULTS.version then
        ResonanceDB.version = DEFAULTS.version
    end

    self.DB = ResonanceDB
    self.CharDB = ResonanceCharDB
end

function ns:InitializeProfiles(previousVersion)
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

    if (tonumber(previousVersion) or 0) < 3 and hadLegacy then
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

local function RemapSetSounds(set)
    if type(set) ~= "table" or type(set.rules) ~= "table" then return end
    for _, config in pairs(set.rules) do
        if type(config) == "table" and type(config.layers) == "table" then
            for _, layer in pairs(config.layers) do
                if type(layer) == "table" and tonumber(layer.soundID) then
                    layer.soundID = ResolveAlias(SOUND_ID_REMAP, tonumber(layer.soundID))
                end
            end
        end
    end
end

local function NormalizeProfileSet(set, allowNewRuleDefaults)
    if type(set) ~= "table" then return end
    if type(set.rules) ~= "table" then set.rules = {} end

    local migratedRules = {}
    -- Keep an already-current configuration if both old and new IDs exist.
    for ruleID, config in pairs(set.rules) do
        if ResolveAlias(RULE_ID_ALIASES, ruleID) == ruleID then
            migratedRules[ruleID] = config
        end
    end
    for ruleID, config in pairs(set.rules) do
        local resolved = ResolveAlias(RULE_ID_ALIASES, ruleID)
        if migratedRules[resolved] == nil then
            migratedRules[resolved] = config
        end
    end
    set.rules = migratedRules

    for _, config in pairs(set.rules) do
        if type(config) == "table" and type(config.layers) == "table" then
            for _, layer in pairs(config.layers) do
                if type(layer) == "table" and tonumber(layer.soundID) then
                    local soundID = tonumber(layer.soundID)
                    layer.soundID = ResolveAlias(SOUND_ID_REMAP, soundID)
                    local sound = ns.SoundByID and ns.SoundByID[layer.soundID]
                    if sound then
                        layer.soundKind = sound.kind or "file"
                        layer.soundLabel = sound.label
                        layer.missingSound = nil
                    else
                        -- Keep the original choice recoverable, but mark it so
                        -- runtime playback can fail closed until it is restored
                        -- or explicitly remapped in a future migration.
                        layer.soundKind = layer.soundKind or "file"
                        layer.soundLabel = layer.soundLabel or ("Sound " .. layer.soundID)
                        layer.missingSound = true
                    end
                end
            end
        end
    end

    set.schemaVersion = math.max(tonumber(set.schemaVersion) or 0, ns.PROFILE_SCHEMA_VERSION)
    set.ruleCatalogVersion = math.max(tonumber(set.ruleCatalogVersion) or 0, ns.RULE_CATALOG_VERSION)
    set.soundCatalogVersion = math.max(tonumber(set.soundCatalogVersion) or 0, ns.SOUND_CATALOG_VERSION)
    if set.ruleFallback == nil then
        set.ruleFallback = allowNewRuleDefaults and "current-defaults" or "disabled"
    end
end

local function FreezeProfileSet(set, specID, includeMissingRules)
    if type(set) ~= "table" then return end
    if type(set.rules) ~= "table" then set.rules = {} end
    for _, rule in ipairs(ns.RulesBySpec[specID] or {}) do
        local existing = set.rules[rule.id]
        if existing ~= nil or includeMissingRules then
            local config = type(existing) == "table" and existing or {}
            set.rules[rule.id] = config
            if type(config.enabled) ~= "boolean" then
                config.enabled = set.ruleFallback == "disabled" and false or rule.defaultOn == true
            end
            if type(config.layers) ~= "table" then config.layers = {} end

            local layerCount = tonumber(config.layerCount)
            if not layerCount then
                layerCount = math.max(2, #(rule.defaultSounds or {}))
                for index in pairs(config.layers) do
                    if type(index) == "number" and index > layerCount then layerCount = index end
                end
            end
            layerCount = math.max(2, math.min(ns.MAX_RULE_LAYERS or 8, math.floor(layerCount)))
            config.layerCount = layerCount
            for index = 1, layerCount do
                local layer = config.layers[index]
                local defaultSound = rule.defaultSounds and rule.defaultSounds[index]
                local defaultDelay = rule.defaultDelays and tonumber(rule.defaultDelays[index])
                    or (index == 1 and math.floor((rule.delay or 0) * 1000 + 0.5) or 0)
                if type(layer) ~= "table" then
                    layer = {
                        enabled = defaultSound ~= nil,
                        soundID = defaultSound or false,
                        delayMs = defaultDelay,
                    }
                    config.layers[index] = layer
                else
                    if type(layer.enabled) ~= "boolean" then layer.enabled = defaultSound ~= nil end
                    if layer.soundID == nil then layer.soundID = defaultSound or false end
                    if tonumber(layer.delayMs) == nil then layer.delayMs = defaultDelay end
                end
            end
            for index in pairs(config.layers) do
                if type(index) == "number" and index > layerCount then config.layers[index] = nil end
            end
        end
    end
    set.ruleFallback = "disabled"
end

local CHARACTER_STORE_MIGRATIONS = {
    [4] = function(store, specID)
        for _, set in pairs(store.savedSets or {}) do
            if type(set) == "table" and set.builtin ~= true then
                -- Generated sets already stored explicit toggles. Ambiguous
                -- sparse legacy entries fail closed instead of inheriting a
                -- possibly changed default from the new addon release.
                set.ruleFallback = "disabled"
                FreezeProfileSet(set, specID, false)
                NormalizeProfileSet(set, false)
            end
        end
        local loadedSet = store.loadedName and store.savedSets and store.savedSets[store.loadedName]
        if type(store.working) == "table" and not (loadedSet and loadedSet.builtin == true) then
            store.working.ruleFallback = "disabled"
            FreezeProfileSet(store.working, specID, false)
            NormalizeProfileSet(store.working, false)
        end
    end,
}

local function RunCharacterStoreMigrations(store, specID, previousVersion)
    previousVersion = math.max(0, math.floor(tonumber(previousVersion) or 0))
    for version = previousVersion + 1, CHARACTER_DEFAULTS.version do
        local migrate = CHARACTER_STORE_MIGRATIONS[version]
        if migrate then migrate(store, specID) end
    end
end

local PRESET_RANK = { subtle = 1, medium = 2, expressive = 3 }

local function BuildCuratedPreset(specID, presetKey)
    local targetRank = PRESET_RANK[presetKey] or 2
    local preset = {
        rules = {}, builtin = true, builtinVersion = ns.BUILTIN_SET_VERSION, preset = presetKey,
        schemaVersion = ns.PROFILE_SCHEMA_VERSION,
        ruleCatalogVersion = ns.RULE_CATALOG_VERSION,
        soundCatalogVersion = ns.SOUND_CATALOG_VERSION,
        ruleFallback = "current-defaults",
    }
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
    local previousCharacterVersion
    if type(ResonanceCharDB) ~= "table" then
        ResonanceCharDB = CopyDefaults(CHARACTER_DEFAULTS)
        previousCharacterVersion = CHARACTER_DEFAULTS.version
    else
        previousCharacterVersion = tonumber(ResonanceCharDB.version) or 0
    end
    if type(ResonanceCharDB.specs) ~= "table" then ResonanceCharDB.specs = {} end
    for specID in pairs(self.SUPPORTED_SPECS) do
        local store = ResonanceCharDB.specs[specID]
        local createdStore = type(store) ~= "table"
        local legacyStore = ResonanceDB.specProfiles and ResonanceDB.specProfiles[specID]
        local legacyProfile = legacyStore and legacyStore.profiles and legacyStore.profiles[legacyStore.active]
        local hasLegacyProfile = type(legacyProfile) == "table" and type(legacyProfile.rules) == "table"
            and next(legacyProfile.rules) ~= nil
        if type(store) ~= "table" then
            store = { working = nil, savedSets = {}, loadedName = nil }
            ResonanceCharDB.specs[specID] = store
        end
        if type(store.savedSets) ~= "table" then store.savedSets = {} end
        if type(store.working) ~= "table" then
            store.working = hasLegacyProfile and DeepCopy(legacyProfile) or { rules = {} }
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
            NormalizeProfileSet(set, set.builtin == true)
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
            if hasLegacyProfile then
                store.savedSets.Migrated = DeepCopy(store.working)
                store.loadedName = "Migrated"
            else
                store.working = DeepCopy(store.savedSets["Resonance Medium"])
                store.loadedName = "Resonance Medium"
            end
        elseif refreshLoadedBuiltin then
            -- Editing any layer clears loadedName, so this only refreshes an
            -- untouched built-in preset and never overwrites custom work.
            store.working = DeepCopy(store.savedSets[refreshLoadedBuiltin])
            store.loadedName = refreshLoadedBuiltin
        end
        local loadedSet = store.loadedName and store.savedSets[store.loadedName]
        NormalizeProfileSet(store.working, loadedSet and loadedSet.builtin == true)
        RunCharacterStoreMigrations(store, specID, previousCharacterVersion)
    end
    ResonanceCharDB.version = math.max(previousCharacterVersion, CHARACTER_DEFAULTS.version)
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

local function CountProfileCompatibility(owner, profile, specID)
    local report = { missingSounds = 0, retiredRules = 0, newRules = 0 }
    if not profile or type(profile.rules) ~= "table" then return report end
    for ruleID, config in pairs(profile.rules) do
        if not owner.RuleByID[ruleID] then report.retiredRules = report.retiredRules + 1 end
        if type(config) == "table" and type(config.layers) == "table" then
            for _, layer in pairs(config.layers) do
                if type(layer) == "table" and tonumber(layer.soundID)
                    and not owner.SoundByID[tonumber(layer.soundID)] then
                    report.missingSounds = report.missingSounds + 1
                end
            end
        end
    end
    for _, rule in ipairs(owner.RulesBySpec[specID] or {}) do
        if profile.rules[rule.id] == nil then report.newRules = report.newRules + 1 end
    end
    return report
end

function ns:GetProfileCompatibility(specID)
    return CountProfileCompatibility(self, self:GetActiveProfile(specID), specID)
end

function ns:GetSavedSetsCompatibility(specID)
    local store = self:GetSpecProfileStore(specID)
    local total = { missingSounds = 0, retiredRules = 0, newRules = 0, affectedSets = 0 }
    for _, set in pairs((store and store.savedSets) or {}) do
        local report = CountProfileCompatibility(self, set, specID)
        if report.missingSounds > 0 or report.retiredRules > 0 or report.newRules > 0 then
            total.affectedSets = total.affectedSets + 1
            total.missingSounds = total.missingSounds + report.missingSounds
            total.retiredRules = total.retiredRules + report.retiredRules
            total.newRules = total.newRules + report.newRules
        end
    end
    return total
end

ns.MAX_RULE_LAYERS = 8

function ns:GetRuleLayerCount(rule)
    local config = self:GetRuleConfig(rule.id, false)
    if config and tonumber(config.layerCount) then
        return math.max(2, math.min(self.MAX_RULE_LAYERS, math.floor(tonumber(config.layerCount))))
    end
    local count = math.max(2, #(rule.defaultSounds or {}))
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
        soundLabel = layer and layer.soundLabel,
        missingSound = layer and layer.missingSound == true,
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
    config.layerCount = count + 1
    local store = self:GetSpecProfileStore(rule.spec)
    if store then store.loadedName = nil end
    return true
end

function ns:RemoveRuleLayer(rule, index)
    local count = self:GetRuleLayerCount(rule)
    if index < 3 or index > count then return false end
    local config = self:GetRuleConfig(rule.id, true)
    config.layers = config.layers or {}
    for fill = 1, count do
        if config.layers[fill] == nil then
            local current = self:GetLayerConfig(rule, fill)
            config.layers[fill] = { enabled = current.enabled, soundID = current.soundID or false, delayMs = current.delayMs or 0 }
        end
    end
    table.remove(config.layers, index)
    config.layerCount = count - 1
    local store = self:GetSpecProfileStore(rule.spec)
    if store then store.loadedName = nil end
    return true
end

function ns:SetLayerConfig(rule, index, values)
    local config = self:GetRuleConfig(rule.id, true)
    config.layers = config.layers or {}
    local layer = config.layers[index] or {}
    config.layers[index] = layer
    config.layerCount = math.max(tonumber(config.layerCount) or self:GetRuleLayerCount(rule), index)
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
    local snapshot = DeepCopy(store.working)
    FreezeProfileSet(snapshot, specID, true)
    NormalizeProfileSet(snapshot, false)
    store.savedSets[name] = snapshot
    store.savedSets[name].builtin = nil
    store.savedSets[name].builtinVersion = nil
    store.savedSets[name].baseVersion = nil
    store.savedSets[name].preset = nil
    store.savedSets[name].ruleFallback = "disabled"
    store.savedSets[name].schemaVersion = self.PROFILE_SCHEMA_VERSION
    store.savedSets[name].ruleCatalogVersion = self.RULE_CATALOG_VERSION
    store.savedSets[name].soundCatalogVersion = self.SOUND_CATALOG_VERSION
    store.savedSets[name].savedAt = GetServerTime and GetServerTime() or 0
    store.working = DeepCopy(store.savedSets[name])
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
    local profile = self:GetActiveProfile(rule.spec)
    if profile and profile.ruleFallback == "disabled" then
        return false
    end
    return rule.defaultOn
end

function ns:SetRuleEnabled(ruleID, enabled)
    local rule = self.RuleByID[ruleID]
    if not rule then
        return
    end
    local config = self:GetRuleConfig(ruleID, true)
    local profile = self:GetActiveProfile(rule.spec)
    if profile and profile.ruleFallback == "disabled" then
        config.enabled = enabled and true or false
    else
        config.enabled = enabled == rule.defaultOn and nil or (enabled and true or false)
    end
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
