local _, ns = ...

-- Curated Evoker sound sets.  These deliberately stay close to the spell's
-- native dragonflight: red/fire, blue/arcane, green/nature, bronze/time and
-- black/earth.  No UI alerts, voices, novelty clips or looping state assets.
ns.CuratedRulePresets = ns.CuratedRulePresets or {}

local function layer(soundID, delayMs)
    return { soundID = soundID, delayMs = delayMs or 0, enabled = true }
end

local function config(enabled, ...)
    return { enabled = enabled, layers = { ... } }
end

local function presets(ruleID, subtle, medium, expressive)
    assert(not ns.CuratedRulePresets[ruleID], "Duplicate curated preset: " .. ruleID)
    ns.CuratedRulePresets[ruleID] = {
        subtle = subtle,
        medium = medium,
        expressive = expressive,
    }
end

-- Devastation: blue spellcraft and red-dragon force, with bronze reserved for
-- time/Apex moments. Frequent fillers remain opt-in until Expressive.
presets("dev_fire_breath",
    config(true, layer(4569632)),
    config(true, layer(4569632), layer(4573362, 65)),
    config(true, layer(4569632), layer(4573362, 55), layer(4569652, 105)))
presets("dev_eternity_surge",
    config(true, layer(4612987)),
    config(true, layer(4612987), layer(4556716, 65)),
    config(true, layer(4612987), layer(4613005, 90)))
presets("dev_shattering_stars",
    config(false, layer(4613001)),
    config(true,  layer(4613001)),
    config(true,  layer(4613001), layer(5520066, 55)))
presets("dev_disintegrate",
    config(false, layer(5520066)),
    config(false, layer(5520066)),
    config(true,  layer(5520066), layer(4612975, 65)))
presets("dev_dragonrage",
    config(true, layer(4553204)),
    config(true, layer(4553204), layer(4569652, 85)),
    config(true, layer(4553204), layer(4569652, 80), layer(4555731, 135)))
presets("audit12_dev_deep_breath",
    config(true, layer(4526046)),
    config(true, layer(4526046), layer(4569628, 90)),
    config(true, layer(4526046), layer(4569628, 80), layer(4555731, 135)))
presets("audit12_dev_tip_scales",
    config(true, layer(4558561)),
    config(true, layer(4558561), layer(4686040, 70)),
    config(true, layer(4558561), layer(4686040, 65)))
presets("audit12_dev_pyre",
    config(false, layer(4613267)),
    config(true,  layer(4613267)),
    config(true,  layer(4613267), layer(568023, 70)))
presets("audit12_dev_living_flame",
    config(false, layer(4553204)),
    config(false, layer(4553204)),
    config(true,  layer(4553204)))
presets("audit12_dev_azure_strike",
    config(false, layer(4519347)),
    config(false, layer(4519347)),
    config(true,  layer(4519347)))
presets("audit12_dev_unbound_flame",
    config(false, layer(4613269)),
    config(true,  layer(4613269)),
    config(true,  layer(4613269), layer(4573362, 65)))
presets("audit12_dev_hover",
    config(false, layer(4555731)),
    config(false, layer(4555731)),
    config(true,  layer(4555731)))
presets("audit12_dev_mass_disintegrate",
    config(true, layer(5520066)),
    config(true, layer(5520066), layer(4612987, 75)),
    config(true, layer(5520066), layer(4612987, 70), layer(4613005, 120)))

-- Preservation: green healing breath and bloom, bronze temporal healing, red
-- Fire Breath.  Movement receives only a light wing/air accent.
presets("pres_echo",
    config(true, layer(4565275, 85)),
    config(true, layer(4565275, 85), layer(4731834, 130)),
    config(true, layer(4565275, 75), layer(4731834, 125)))
presets("pres_verdant_embrace",
    config(true, layer(3857677)),
    config(true, layer(3857677), layer(4612501, 65)),
    config(true, layer(3857677), layer(4612501, 60), layer(4556842, 105)))
presets("pres_fire_breath_release",
    config(true, layer(4569632)),
    config(true, layer(4569632), layer(4573362, 65)),
    config(true, layer(4569632), layer(4573362, 55), layer(4569652, 105)))
presets("pres_emerald_blossom",
    config(true, layer(3857677)),
    config(true, layer(3857677), layer(4612501, 70)),
    config(true, layer(3857677), layer(4612501, 65), layer(1661243, 120)))
presets("pres_dream_breath",
    config(true, layer(4614157)),
    config(true, layer(4614157), layer(3811964, 90)),
    config(true, layer(4614157), layer(3811964, 80), layer(4612501, 135)))
presets("pres_temporal_anomaly",
    config(false, layer(1064331)),
    config(true,  layer(1064331)),
    config(true,  layer(1064331), layer(4686040, 75)))
presets("pres_stasis_capture",
    config(true, layer(903726)),
    config(true, layer(903726), layer(4558551, 70)),
    config(true, layer(903726), layer(4558551, 65)))
presets("pres_stasis_release",
    config(true, layer(903728)),
    config(true, layer(903728), layer(3060609, 75)),
    config(true, layer(903728), layer(3060609, 70), layer(4686044, 125)))
presets("pres_rewind",
    config(true, layer(4565256)),
    config(true, layer(4565256), layer(3060607, 80)),
    config(true, layer(4565256), layer(3060607, 75), layer(569728, 130)))
presets("pres_dream_flight",
    config(false, layer(4555731)),
    config(true,  layer(4555731), layer(3811972, 90)),
    config(true,  layer(4555731), layer(3811972, 85), layer(4612501, 145)))
presets("pres_merithra",
    config(true, layer(3811972)),
    config(true, layer(3811972), layer(568405, 85)),
    config(true, layer(3811972), layer(568405, 80), layer(4612501, 135)))
presets("pres_dream_breath_init",
    config(false, layer(4632529)),
    config(true,  layer(4632529)),
    config(true,  layer(4632529), layer(1661243, 70)))
presets("audit12_pres_reversion",
    config(false, layer(4558577)),
    config(true,  layer(4558577)),
    config(true,  layer(4558577), layer(4558561, 65)))
presets("audit12_pres_living_flame",
    config(false, layer(4553204)),
    config(false, layer(4553204)),
    config(true,  layer(4553204)))
presets("audit12_pres_tip_scales",
    config(true, layer(4558561)),
    config(true, layer(4558561), layer(4686040, 70)),
    config(true, layer(4558561), layer(4686040, 65)))
presets("audit12_pres_hover",
    config(false, layer(4555731)),
    config(false, layer(4555731)),
    config(true,  layer(4555731)))
presets("audit12_pres_rescue",
    config(false, layer(4555731)),
    config(false, layer(4555731)),
    config(true,  layer(4555731), layer(4556842, 65)))
presets("audit12_pres_zephyr",
    config(true, layer(4556360)),
    config(true, layer(4556360), layer(4556842, 70)),
    config(true, layer(4556360), layer(4556842, 65), layer(4612501, 120)))
presets("audit12_pres_cauterizing_flames",
    config(false, layer(4553204)),
    config(false, layer(4553204)),
    config(true,  layer(4553204), layer(568023, 65)))

-- Augmentation: black-dragon earth gives weight to Eruption and scales;
-- bronze/time remains the support language, with red and blue used literally.
presets("aug_ebon_might",
    config(true, layer(5141281)),
    config(true, layer(5141281), layer(5277906, 80)),
    config(true, layer(5141281), layer(5277906, 75), layer(4686040, 130)))
presets("aug_prescience",
    config(false, layer(4558561)),
    config(true,  layer(4558561)),
    config(true,  layer(4558561), layer(4558551, 60)))
presets("aug_breath_of_eons",
    config(true, layer(4686040)),
    config(true, layer(4686040), layer(4526046, 90)),
    config(true, layer(4686040), layer(4526046, 85), layer(1064331, 145)))
presets("aug_upheaval_release",
    config(true, layer(4553587)),
    config(true, layer(4553587), layer(4577695, 80)),
    config(true, layer(4553587), layer(4577695, 75), layer(4555859, 125)))
presets("audit12_aug_fire_breath",
    config(true, layer(4569632)),
    config(true, layer(4569632), layer(4573362, 65)),
    config(true, layer(4569632), layer(4573362, 55), layer(4569652, 105)))
presets("audit12_aug_tip_scales",
    config(true, layer(4558561)),
    config(true, layer(4558561), layer(4686040, 70)),
    config(true, layer(4558561), layer(4686040, 65)))
presets("audit12_aug_time_skip",
    config(true, layer(3060607)),
    config(true, layer(3060607), layer(3060609, 90)),
    config(true, layer(3060607), layer(3060609, 85), layer(4686040, 140)))
presets("audit12_aug_eruption",
    config(true, layer(5141335)),
    config(true, layer(5141335), layer(4553587, 75)),
    config(true, layer(5141335), layer(4553587, 70), layer(4555859, 120)))
presets("audit12_aug_living_flame",
    config(false, layer(4553204)),
    config(false, layer(4553204)),
    config(true,  layer(4553204)))
presets("audit12_aug_azure_strike",
    config(false, layer(4519347)),
    config(false, layer(4519347)),
    config(true,  layer(4519347)))
presets("audit12_aug_blistering_scales",
    config(true, layer(4552893)),
    config(true, layer(4552893), layer(5277906, 75)),
    config(true, layer(4552893), layer(5277906, 70), layer(4555859, 120)))
presets("audit12_aug_hover",
    config(false, layer(4555731)),
    config(false, layer(4555731)),
    config(true,  layer(4555731)))
presets("audit12_aug_mass_eruption",
    config(true, layer(5141335)),
    config(true, layer(5141335), layer(4577695, 80)),
    config(true, layer(5141335), layer(4577695, 75), layer(4555859, 125)))
