local _, ns = ...

ns.CapabilityGroups = {
    sunfury = { 448601, 449849 },
    spellslinger = { 443739, 443783, 1247908 },
    frostfire = { 1295925, 431095, 431176, 431177 },
    flameshaper = { 1264269, 444088 },
    scalecommander = { 436335, 436336, 442254, 442255 },
    chronowarden = { 431442, 431875 },
    prismaticBolt = { 1295923, 1295944, 1295946 },
    handOfFrost = { 1262935, 1262981, 1263249, 1263263 },
    risingFury = { 1271687, 1271783, 1271788, 1271796 },
    -- 1256577 is the selected passive talent; 1256579/1256581 are
    -- its resulting active/replacement spell variants.
    merithrasBlessing = { 1256577, 1256579, 1256581 },
    pal_lightsmith = { 431377, 431380, 431381, 431460, 431522, 431581, 1289728, 1289890, 1289892 },
    pal_templar = { 427441, 1217116, 1246643 },
    dk_deathbringer = { 434765, 448473 },
    dk_sanlayn = { 433899, 433901, 434674, 445669 },
    dk_rider = { 444010, 444347, 461461 },
    dh_aldrachi = { 442290, 444661, 442718 },
    dh_felscarred = { 452416, 452435, 452443, 452449, 452452, 452462, 452463,
        452489, 452491, 452492, 452493, 452499, 456641, 469995, 1245496, 1245511,
        1245514, 1245628, 1245630 },
    dh_devourer_midnight = { 1242486, 1250088, 1250094, 1263514, 1266382, 1266623 },
    monk_conduit = { 443028 },
}

for name, spellIDs in pairs(ns.AdditionalCapabilityGroups or {}) do
    ns.CapabilityGroups[name] = spellIDs
end

-- Labels are data-driven so a new specialization never needs hardcoded UI logic.
-- A label appears only when the selected trait scan proves the capability.
ns.HeroTreesBySpec = {
    [62]={{capability="sunfury",label="Sunfury"},{capability="spellslinger",label="Spellslinger"}},
    [63]={{capability="sunfury",label="Sunfury"},{capability="frostfire",label="Frostfire"}},
    [64]={{capability="frostfire",label="Frostfire"},{capability="spellslinger",label="Spellslinger"}},
    [71]={{capability="colossus",label="Colossus"}},
    [72]={{capability="mountainThane",label="Mountain Thane"}},
    [73]={{capability="colossus",label="Colossus"},{capability="mountainThane",label="Mountain Thane"}},
    [65]={{capability="pal_lightsmith",label="Lightsmith"}},
    [66]={{capability="pal_lightsmith",label="Lightsmith"},{capability="pal_templar",label="Templar"}},
    [70]={{capability="pal_templar",label="Templar"},{capability="pal_lightsmith",label="Herald of the Sun"}},
    [250]={{capability="dk_sanlayn",label="San'layn"},{capability="dk_rider",label="Rider of the Apocalypse"}},
    [251]={{capability="dk_deathbringer",label="Deathbringer"},{capability="dk_rider",label="Rider of the Apocalypse"}},
    [252]={{capability="dk_sanlayn",label="San'layn"},{capability="dk_rider",label="Rider of the Apocalypse"}},
    [253]={{capability="darkRanger",label="Dark Ranger"}},
    [254]={{capability="darkRanger",label="Dark Ranger"},{capability="sentinel",label="Sentinel"}},
    [255]={{capability="sentinel",label="Sentinel"}},
    [256]={{capability="priest_oracle",label="Oracle"},{capability="priest_voidweaver",label="Voidweaver"}},
    [257]={{capability="priest_archon",label="Archon"},{capability="priest_oracle",label="Oracle"}},
    [258]={{capability="priest_archon",label="Archon"},{capability="priest_voidweaver",label="Voidweaver"}},
    [259]={{capability="deathstalker",label="Deathstalker"}},
    [260]={{capability="trickster",label="Trickster"}},
    [261]={{capability="deathstalker",label="Deathstalker"},{capability="trickster",label="Trickster"}},
    [265]={{capability="warlock_hellcaller",label="Hellcaller"},{capability="warlock_soul_harvester",label="Soul Harvester"}},
    [266]={{capability="warlock_diabolist",label="Diabolist"},{capability="warlock_soul_harvester",label="Soul Harvester"}},
    [267]={{capability="warlock_diabolist",label="Diabolist"},{capability="warlock_hellcaller",label="Hellcaller"}},
    [269]={{capability="monk_conduit",label="Conduit of the Celestials"}},
    [270]={{capability="monk_conduit",label="Conduit of the Celestials"}},
    [577]={{capability="dh_aldrachi",label="Aldrachi Reaver"},{capability="dh_felscarred",label="Fel-Scarred"}},
    [581]={{capability="dh_aldrachi",label="Aldrachi Reaver"},{capability="dh_felscarred",label="Fel-Scarred"}},
    [1467]={{capability="flameshaper",label="Flameshaper"},{capability="scalecommander",label="Scalecommander"}},
    [1468]={{capability="chronowarden",label="Chronowarden"},{capability="flameshaper",label="Flameshaper"}},
}

ns.ApexBySpec = {
    [62]={capability="prismaticBolt",label="Prismatic Bolt"},
    [63]={capability="fired_up",label="Fired Up"},
    [64]={capability="handOfFrost",label="Hand of Frost"},
    [71]={capability="masterOfWarfare",label="Master of Warfare"},
    [72]={capability="rampagingBerserker",label="Rampaging Berserker"},
    [73]={capability="phalanx",label="Phalanx"},
    [254]={capability="deadlyInsight",label="Deadly Insight"},
    [255]={capability="raptorSwipe",label="Raptor Swipe"},
    [256]={capability="priest_master_darkness",label="Master of Darkness"},
    [257]={capability="priest_benediction",label="Benediction"},
    [258]={capability="priest_void_apparitions",label="Void Apparitions"},
    [259]={capability="implacable",label="Implacable"},
    [260]={capability="gravedigger",label="Gravedigger"},
    [261]={capability="ancientArts",label="Ancient Arts"},
    [265]={capability="warlock_shadow_nathreza",label="Wrath of Nathreza"},
    [266]={capability="warlock_dominion_argus",label="Dominion of Argus"},
    [267]={capability="warlock_embers_nihilam",label="Embers of Nihilam"},
    [1467]={capability="risingFury",label="Rising Fury"},
    [1468]={capability="merithrasBlessing",label="Merithra's Blessing"},
    [1480]={capability="dh_devourer_midnight",label="Midnight"},
}

ns.SoundPalettes = {
    subtle = {
        label = "Subtle",
        proc = { "UI_TRANSMOG_ITEM_CLICK", "U_CHAT_SCROLL_BUTTON" },
        ready = { "UI_CLASS_TALENT_LEARN_TALENT", "IG_ABILITY_ICON_DROP" },
        release = { "IG_MAINMENU_CLOSE", "IG_CHARACTER_INFO_CLOSE", "GS_TITLE_OPTION_EXIT" },
        major = { "UI_CLASS_TALENT_APPLY_COMPLETE", "UI_ORDERHALL_TALENT_READY_TOAST" },
        apex = { "UI_AZERITE_EMPOWERED_ITEM_LOOT_TOAST", "UI_EPICLOOT_TOAST" },
        frost = { "UI_MAP_WAYPOINT_SUPER_TRACK_ON", "UI_TRANSMOG_ITEM_CLICK" },
        bronze = { "UI_RUNECARVING_OPEN_MAIN_WINDOW", "IG_SPELLBOOK_OPEN" },
        draconic = { "UI_WORLDQUEST_COMPLETE", "UI_CLASS_TALENT_APPLY_COMPLETE" },
        bronzeEcho = { "UI_TRANSMOG_ITEM_CLICK", "UI_MAP_WAYPOINT_SUPER_TRACK_ON" },
        nature = { "UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST", "UI_TRANSMOG_ITEM_CLICK" },
        water = { "UI_MAP_WAYPOINT_SUPER_TRACK_ON", "U_CHAT_SCROLL_BUTTON" },
        deepfire = { "UI_RUNECARVING_OPEN_MAIN_WINDOW", "IG_MAINMENU_CLOSE" },
    },
    native = {
        label = "Native",
        proc = { "UI_CLASS_TALENT_LEARN_TALENT", "UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST" },
        ready = { "UI_CLASS_TALENT_APPLY_COMPLETE", "UI_ORDERHALL_TALENT_READY_TOAST" },
        release = { "UI_SCENARIO_ENDING", "UI_WORLDQUEST_COMPLETE", "IG_MAINMENU_CLOSE" },
        major = { "UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE", "UI_EPICLOOT_TOAST" },
        apex = { "UI_LEGENDARY_LOOT_TOAST", "UI_AZERITE_EMPOWERED_ITEM_LOOT_TOAST" },
        frost = { "UI_MAP_WAYPOINT_SUPER_TRACK_ON", "UI_CLASS_TALENT_LEARN_TALENT" },
        bronze = { "UI_ORDERHALL_TALENT_READY_TOAST", "UI_RUNECARVING_OPEN_MAIN_WINDOW" },
        draconic = { "UI_WORLDQUEST_COMPLETE", "UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE" },
        bronzeEcho = { "UI_RUNECARVING_OPEN_MAIN_WINDOW", "UI_TRANSMOG_ITEM_CLICK" },
        nature = { "UI_WORLDQUEST_COMPLETE", "UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST" },
        water = { "UI_MAP_WAYPOINT_SUPER_TRACK_ON", "UI_RUNECARVING_OPEN_MAIN_WINDOW" },
        deepfire = { "UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE", "UI_WORLDQUEST_COMPLETE" },
    },
    bold = {
        label = "Bold",
        proc = { "UI_CLASS_TALENT_APPLY_COMPLETE", "UI_CLASS_TALENT_LEARN_TALENT" },
        ready = { "UI_ORDERHALL_TALENT_READY_TOAST", "UI_AZERITE_EMPOWERED_ITEM_LOOT_TOAST" },
        release = { "UI_WORLDQUEST_COMPLETE", "UI_SCENARIO_ENDING" },
        major = { "UI_EPICLOOT_TOAST", "UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE" },
        apex = { "UI_LEGENDARY_LOOT_TOAST", "UI_EPICLOOT_TOAST" },
        frost = { "UI_CLASS_TALENT_APPLY_COMPLETE", "UI_MAP_WAYPOINT_SUPER_TRACK_ON" },
        bronze = { "UI_RUNECARVING_OPEN_MAIN_WINDOW", "UI_ORDERHALL_TALENT_READY_TOAST" },
        draconic = { "UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE", "UI_WORLDQUEST_COMPLETE" },
        bronzeEcho = { "UI_ORDERHALL_TALENT_READY_TOAST", "UI_TRANSMOG_ITEM_CLICK" },
        nature = { "UI_WORLDQUEST_COMPLETE", "UI_CLASS_TALENT_APPLY_COMPLETE" },
        water = { "UI_ORDERHALL_TALENT_READY_TOAST", "UI_MAP_WAYPOINT_SUPER_TRACK_ON" },
        deepfire = { "UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE", "UI_EPICLOOT_TOAST" },
    },
}

local rules = {
    -- Arcane Mage
    { id = "arcane_clearcasting", spec = 62, name = "Clearcasting", event = "AURA", auraIDs = { 263725 }, cue = "proc", preset="medium", cooldown = 1.2, defaultOn = true, description = "A soft accent when Clearcasting is newly gained." },
    { id = "arcane_four_charges", spec = 62, name = "Four Arcane Charges", event = "POWER", cue = "ready", preset="medium", cooldown = 1.5, defaultOn = true, description = "Sounds only when crossing into four Arcane Charges." },
    { id = "arcane_surge", spec = 62, name = "Arcane Surge", event = "SUCCEEDED", spellIDs = { 365350, 365362 }, cue = "major", preset="subtle", cooldown = 4.0, defaultOn = true, description = "Major cooldown punctuation; palette adapts to the active hero tree." },
    { id = "arcane_barrage", spec = 62, name = "Arcane Barrage", event = "SUCCEEDED", spellIDs = { 44425 }, cue = "release", preset="medium", cooldown = 0.8, defaultOn = true, description = "A restrained resolution when Arcane Charges are released." },
    { id = "arcane_missiles", spec = 62, name = "Arcane Missiles", event = "CHANNEL_START", spellIDs = { 5143 }, cue = "proc", preset="expressive", cooldown = 1.5, defaultOn = false, description = "One channel-start sparkle, never individual missile ticks." },
    { id = "arcane_prismatic_bolt", spec = 62, name = "Prismatic Bolt (Apex)", event = "SUCCEEDED", spellIDs = { 1295924 }, capability = "prismaticBolt", cue = "apex", preset="subtle", cooldown = 5.0, defaultOn = true, description = "A rare Apex accent on the confirmed Prismatic Bolt cast." },

    -- Frost Mage
    { id = "frost_frozen_orb", spec = 64, name = "Frozen Orb", event = "SUCCEEDED", spellIDs = { 84714 }, cue = "frost", preset="medium", cooldown = 1.5, defaultOn = true, description = "One launch accent; Orb ticks stay silent." },
    { id = "frost_ray", spec = 64, name = "Ray of Frost", event = "CHANNEL_START", spellIDs = { 205021 }, cue = "major", preset="subtle", cooldown = 3.0, defaultOn = true, description = "The modern Frost major-cooldown cue. Hand of Frost alters its Apex context." },
    { id = "frost_glacial_spike", spec = 64, name = "Glacial Spike", event = "SUCCEEDED", spellIDs = { 199786 }, cue = "release", preset="medium", cooldown = 1.2, defaultOn = true, description = "A brittle release when the periodic replacement spell is cast." },
    { id = "frostfire_empowerment", spec = 64, name = "Frostfire Empowerment", event = "AURA", auraIDs = { 431176, 431177 }, capability = "frostfire", cue = "ready", preset="medium", cooldown = 1.5, defaultOn = true, description = "Frostfire-only readiness cue." },
    { id = "frost_fingers", spec = 64, name = "Fingers of Frost", event = "AURA", auraIDs = { 44544 }, cue = "proc", preset="expressive", cooldown = 1.2, defaultOn = false, description = "Optional; disabled by default because it can be frequent." },

    -- Devastation Evoker
    { id = "dev_essence_burst", spec = 1467, name = "Essence Burst", event = "AURA", auraIDs = { 359618, 369297, 369299, 392268, 396187, 417402, 430835 }, cue = "proc", preset="medium", cooldown = 1.2, defaultOn = true, description = "Sounds only when the proc is newly gained." },
    { id = "dev_fire_breath", spec = 1467, name = "Fire Breath release", event = "EMPOWER_STOP", spellIDs = { 357208, 382266 }, cue = "draconic", preset="subtle", cooldown = 1.5, defaultOn = true, description = "Plays only when the empower stop event confirms a completed Fire Breath release." },
    { id = "dev_eternity_surge", spec = 1467, name = "Eternity Surge release", event = "EMPOWER_STOP", spellIDs = { 359073, 359077 }, cue = "release", preset="subtle", cooldown = 1.5, defaultOn = true, description = "Plays only when the empower stop event confirms a completed Eternity Surge release." },
    { id = "dev_shattering_stars", spec = 1467, name = "Shattering Stars", event = "SUCCEEDED", spellIDs = { 1265802 }, cue = "release", preset="medium", cooldown = 1.2, defaultOn = true, description = "A crisp impact accent for the current Shattering Stars cast." },
    { id = "dev_disintegrate", spec = 1467, name = "Disintegrate", event = "CHANNEL_START", spellIDs = { 356995 }, cue = "ready", preset="expressive", cooldown = 1.2, defaultOn = false, description = "Optional one-time beam lock; no continuous added sound." },
    { id = "dev_dragonrage", spec = 1467, name = "Dragonrage", event = "SUCCEEDED", spellIDs = { 375087 }, cue = "major", preset="subtle", cooldown = 5.0, defaultOn = true, description = "Major draconic burst-window accent." },
    { id = "dev_rising_fury", spec = 1467, name = "Rising Fury (Apex)", event = "AURA_STACK", auraIDs = { 1271687, 1271783, 1271788, 1271796 }, capability = "risingFury", stackThreshold = 5, cue = "apex", preset="subtle", cooldown = 8.0, defaultOn = false, description = "A restrained Apex accent when Rising Fury reaches five stacks." },

    -- Preservation Evoker
    { id = "pres_echo", spec = 1468, name = "Echo", event = "SUCCEEDED", spellIDs = { 364343, 364446 }, cue = "bronzeEcho", preset="medium", cooldown = 0.6, delay = 0.085, defaultOn = true, description = "A subtle bronze afterimage about 85 ms after Echo's original cast sound." },
    { id = "pres_verdant_embrace", spec = 1468, name = "Verdant Embrace", event = "SUCCEEDED", spellIDs = { 360995, 1242514 }, cue = "nature", preset="medium", cooldown = 0.8, defaultOn = true, description = "A soft living-nature accent on the verdant leap." },
    { id = "pres_fire_breath_release", spec = 1468, name = "Fire Breath release", event = "EMPOWER_STOP", spellIDs = { 357208, 382266 }, cue = "deepfire", preset="subtle", cooldown = 1.0, defaultOn = true, description = "A deeper impact when the empower stop event confirms a completed breath." },
    { id = "pres_emerald_blossom", spec = 1468, name = "Emerald Blossom", event = "SUCCEEDED", spellIDs = { 355913 }, cue = "nature", preset="medium", cooldown = 0.8, defaultOn = true, description = "A soft, resonant nature bloom without a sharp alert edge." },
    { id = "pres_dream_breath", spec = 1468, name = "Dream Breath release", event = "EMPOWER_STOP", spellIDs = { 355936, 382614 }, cue = "draconic", preset="subtle", cooldown = 1.5, defaultOn = true, description = "Plays only when the empower stop event confirms a completed Dream Breath release." },
    { id = "pres_temporal_anomaly", spec = 1468, name = "Temporal Anomaly", event = "SUCCEEDED", spellIDs = { 373861, 373862 }, cue = "bronze", preset="medium", cooldown = 1.2, defaultOn = true, description = "A short bronze-time ripple." },
    { id = "pres_stasis_capture", spec = 1468, name = "Stasis capture", event = "SUCCEEDED", spellIDs = { 370537 }, cue = "ready", preset="subtle", cooldown = 3.0, defaultOn = true, description = "The opening half of the Stasis phrase." },
    { id = "pres_stasis_release", spec = 1468, name = "Stasis release", event = "SUCCEEDED", spellIDs = { 370564 }, cue = "release", preset="subtle", cooldown = 3.0, defaultOn = true, description = "The resolving half of the Stasis phrase." },
    { id = "pres_rewind", spec = 1468, name = "Rewind", event = "SUCCEEDED", spellIDs = { 363534 }, cue = "major", preset="subtle", cooldown = 5.0, defaultOn = true, description = "A restrained temporal major-cooldown accent." },
    { id = "pres_dream_flight", spec = 1468, name = "Dream Flight", event = "SUCCEEDED", spellIDs = { 359816 }, cue = "draconic", preset="medium", cooldown = 5.0, defaultOn = false, description = "Optional verdant flight accent." },
    { id = "pres_merithra", spec = 1468, name = "Merithra's Blessing", event = "SUCCEEDED", spellIDs = { 1256581, 1256579 }, capability = "merithrasBlessing", cue = "water", preset="subtle", cooldown = 2.0, defaultOn = true, description = "A gentle watery-nature phrase on the current Apex cast variants." },
}

for _, rule in ipairs(ns.AdditionalSpecRules or {}) do
    rules[#rules + 1] = rule
end

-- Additional editable moments that are not represented by the primary cast rows.
local extraMoments = {
    { id="pres_dream_breath_init", spec=1468, spell="Dream Breath", moment="Initiation", event="EMPOWER_START", spellIDs={355936,382614}, cue="nature", preset="medium", cooldown=1, defaultOn=true, description="The first breath of magic when empowerment begins." },
}
for _, rule in ipairs(extraMoments) do rules[#rules + 1] = rule end

local defaultCueSounds = {
    proc={5520066}, ready={4558561}, release={4686040}, major={5520037,4686044}, apex={4612501,4686040},
    frost={4612975}, bronze={4558551}, bronzeEcho={4558561}, nature={4614320}, water={568405},
    deepfire={4553204,4569652}, draconic={4555731,4612501},
}

local names = {
    pres_echo={"Echo","Cast"}, pres_verdant_embrace={"Verdant Embrace","Cast"},
    pres_fire_breath_release={"Fire Breath","Release"},
    pres_emerald_blossom={"Emerald Blossom","Cast"}, pres_dream_breath={"Dream Breath","Release"},
    pres_temporal_anomaly={"Temporal Anomaly","Cast"}, pres_stasis_capture={"Stasis","Capture"},
    pres_stasis_release={"Stasis","Release"}, pres_rewind={"Rewind","Release"},
    pres_dream_flight={"Dream Flight","Cast"}, pres_merithra={"Merithra's Blessing","Cast"},
    dev_fire_breath={"Fire Breath","Release"}, dev_eternity_surge={"Eternity Surge","Release"},
    arcane_prismatic_bolt={"Prismatic Bolt (Apex)","Cast"},
}
for _, rule in ipairs(rules) do
    local explicit = names[rule.id]
    rule.spell = rule.spell or (explicit and explicit[1]) or rule.name
    rule.moment = rule.moment or (explicit and explicit[2]) or ((rule.event == "AURA" or rule.event == "AURA_STACK") and "Proc" or "Cast")
    -- "Ready" used to mean cooldown readiness. Aura-driven accents are
    -- ordinary proc moments, so keep the trigger but present the honest name.
    if rule.moment == "Ready" then
        rule.moment = "Proc"
    end
    rule.defaultSounds = rule.defaultSounds or defaultCueSounds[rule.cue] or defaultCueSounds.proc
end

-- Give only spells with a real cast, channel, or empower bar an optional
-- Casting accent.  C_Spell is the installed client's authoritative spell
-- metadata, so this follows current-patch cast-time changes instead of a stale
-- hand-maintained list.  Explicit channel/empower rules are retained even when
-- their special cast-time representation reports zero milliseconds.
local function RuleHasCastBar(rule)
    -- Channels already expose an explicit Channeling moment.  Generating a
    -- second Casting row for the same UNIT_SPELLCAST_CHANNEL_START would make
    -- both layers fire together and add no useful control.
    if rule.event == "CHANNEL_START" then
        return false
    end
    if rule.event == "EMPOWER_START" or rule.event == "EMPOWER_STOP" then
        return true
    end
    if not C_Spell or not C_Spell.GetSpellInfo then
        return false
    end
    for _, spellID in ipairs(rule.spellIDs or {}) do
        local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
        if ok and ns:IsSafeTable(info) then
            local castTime = info.castTime
            if ns:IsSafeValue(castTime) and type(castTime) == "number" and castTime > 0 then
                return true
            end
        end
    end
    return false
end

local castingGroups = {}
local castingOrder = {}
for _, rule in ipairs(rules) do
    if rule.spellIDs and #rule.spellIDs > 0 and RuleHasCastBar(rule) then
        local key = tostring(rule.spec) .. ":" .. rule.spell
        local group = castingGroups[key]
        if not group then
            group = { source = rule, spellIDs = {}, spellSet = {} }
            castingGroups[key] = group
            castingOrder[#castingOrder + 1] = group
        end
        for _, spellID in ipairs(rule.spellIDs) do
            if not group.spellSet[spellID] then
                group.spellSet[spellID] = true
                group.spellIDs[#group.spellIDs + 1] = spellID
            end
        end
    end
end

for _, group in ipairs(castingOrder) do
    local source = group.source
    rules[#rules + 1] = {
        id = source.id .. "_casting",
        spec = source.spec,
        spell = source.spell,
        name = source.spell .. " casting",
        moment = "Casting",
        event = "CASTING_START",
        spellIDs = group.spellIDs,
        capability = source.capability,
        cue = source.cue,
        preset = "custom",
        cooldown = 0.5,
        defaultOn = false,
        -- Casting is a distinct sonic moment. Do not inherit release/impact
        -- layers from the source rule; users can opt in and choose a texture
        -- that actually suits the spell's cast bar.
        defaultSounds = {},
        description = "Plays once when WoW starts this spell's current cast, channel, or empower bar.",
    }
end

ns.Rules = rules
ns.RuleByID = {}
ns.RulesBySpec = {}

local function ToSet(values)
    local set = {}
    for _, value in ipairs(values or {}) do
        set[value] = true
    end
    return set
end

for _, rule in ipairs(rules) do
    rule.spellSet = ToSet(rule.spellIDs)
    rule.auraSet = ToSet(rule.auraIDs)
    ns.RuleByID[rule.id] = rule
    ns.RulesBySpec[rule.spec] = ns.RulesBySpec[rule.spec] or {}
    table.insert(ns.RulesBySpec[rule.spec], rule)
end
