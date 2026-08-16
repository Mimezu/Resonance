local ADDON, ns = ...

-- Curated class-fantasy presets for Mage, Priest, and Warlock.  The first
-- layer is always the spell's own vocabulary; later layers are short,
-- compatible sweeteners rather than alerts, voices, ambience, or loops.
ns.CuratedRulePresets = ns.CuratedRulePresets or {}
local presets = ns.CuratedRulePresets

local function layer(soundID, delayMs)
    return { soundID = soundID, delayMs = delayMs or 0, enabled = true }
end

local function state(enabled, count, sounds)
    local layers = {}
    for index = 1, math.min(count, #sounds) do
        local sound = sounds[index]
        layers[index] = layer(sound[1], sound[2])
    end
    return { enabled = enabled, layers = layers }
end

-- flags: s = Subtle, m = Medium, e = Expressive.  Subtle uses one layer,
-- Medium up to two, and Expressive up to three.  Supplying fewer sounds is
-- intentional for effects that become muddy when layered.
local function add(id, flags, ...)
    local sounds = { ... }
    presets[id] = {
        subtle = state(flags:find("s", 1, true) ~= nil, 1, sounds),
        medium = state(flags:find("m", 1, true) ~= nil, 2, sounds),
        expressive = state(flags:find("e", 1, true) ~= nil, 3, sounds),
    }
end

-- Arcane Mage: crystalline pressure, controlled mana releases, and restrained
-- cosmic bloom.  Frequent resource/proc cues are never part of the base mix.
add("arcane_clearcasting",       "",    {5520066, 0})
add("arcane_four_charges",      "",    {959721, 0})
add("arcane_surge",             "sme", {5520037, 0}, {4686044, 95}, {5259954, 155})
add("arcane_barrage",           "me",  {4686040, 45}, {959721, 0})
add("arcane_missiles",          "e",   {5520066, 0}, {5259954, 90})
add("arcane_prismatic_bolt",    "sme", {4612501, 0}, {5520037, 65}, {5259954, 145})
add("arcane_orb_12_1",          "me",  {959721, 0}, {5520066, 70})
add("arcane_pulse_12_1",        "me",  {568678, 0}, {5520037, 65})
add("arcane_touch_of_the_magi_12_1", "sme", {5520037, 0}, {4686044, 105})
add("arcane_blast_12_1",        "e",   {5520066, 0})
add("arcane_evocation_12_1",    "sme", {5520041, 0}, {5259954, 130})
add("arcane_presence_of_mind_12_1", "e", {5259954, 0})

-- Fire Mage: ignition, combustion, and impact.  Fireball/Scorch remain lean;
-- their native cadence should not become an added percussion track.
add("fire_pyroblast",           "me",  {1392377, 0}, {4573332, 70})
add("fire_combustion",          "sme", {1390656, 0}, {4573332, 75}, {2428623, 145})
add("fire_meteor",              "sme", {568024, 0}, {4573332, 115})
add("fire_frostfire_bolt",      "me",  {1631379, 0}, {1685531, 65})
add("fire_fired_up",            "",    {1390656, 0})
add("fire_fire_blast",          "e",   {568023, 0})
add("fire_fireball",            "e",   {1685528, 0})
add("fire_scorch",              "e",   {568023, 0})
add("fire_flamestrike",         "me",  {568024, 0}, {4573332, 105})
add("fire_hot_streak",          "",    {2428623, 0})

-- Frost Mage: brittle launches and ice fracture, avoiding bright UI-like proc
-- cues.  Core shatter spells enter at Medium; filler and procs stay optional.
add("frost_frozen_orb",         "me",  {4612975, 0}, {4613005, 85})
add("frost_ray",                "sme", {4612975, 0}, {568047, 95})
add("frost_glacial_spike",      "sme", {4613005, 0}, {568047, 60})
add("frostfire_empowerment",    "",    {4612975, 0})
add("frost_fingers",            "",    {5259954, 0})
add("frost_frostbolt_12_1",     "e",   {4612975, 0})
add("frost_frostfire_bolt_12_1", "me", {4612975, 0}, {568023, 65})
add("frost_flurry_12_1",        "e",   {4612975, 0}, {5259954, 80})
add("frost_ice_lance_12_1",     "e",   {4613005, 0})
add("frost_comet_storm_12_1",   "me",  {4613005, 0}, {568047, 75})
add("frost_blizzard_12_1",      "e",   {4612975, 0})
add("frost_hand_of_frost_12_1", "",    {4612975, 0})
add("frost_brain_freeze_12_1",  "",    {5259954, 0})
add("frost_fingers_12_1",       "",    {5259954, 0})

-- Discipline Priest: luminous force tempered by void.  Shields and Penance
-- remain recognizable; spammed Smite/Flash Heal only appear in Expressive.
add("disc_penance",             "me",  {1708148, 0}, {5205686, 80})
add("disc_radiance",            "me",  {1709039, 0}, {5205686, 85})
add("disc_evangelism",          "sme", {5207969, 0}, {5205686, 95})
add("disc_ultimate_penitence",  "sme", {1708148, 0}, {5205686, 110}, {5259954, 170})
add("disc_void_blast",          "me",  {1714480, 0}, {5342340, 75})
add("disc_void_shield",         "sme", {1708158, 0}, {5342340, 95})
add("disc_power_word_shield",   "me",  {1708158, 0})
add("disc_flash_heal",          "e",   {1709039, 0})
add("disc_mind_blast",          "e",   {1714480, 0})
add("disc_shadow_word_death",   "me",  {568184, 0}, {5342340, 65})
add("disc_smite",               "e",   {1708148, 0})
add("disc_archangel",           "sme", {5207969, 0}, {5205686, 95}, {5259954, 160})
add("disc_mindbender",          "sme", {1717716, 0}, {5342340, 90})
add("disc_power_word_barrier",  "sme", {5207969, 0}, {5205686, 110})

-- Holy Priest: soft radiance on routine healing, broader resonance only for
-- Holy Words and major cooldowns.
add("holy_serenity",            "me",  {1698678, 0}, {5205686, 75})
add("holy_sanctify",            "me",  {1698676, 0}, {5205686, 90})
add("holy_hymn",                "sme", {1698674, 0}, {5205686, 120}, {5259954, 175})
add("holy_apotheosis",          "sme", {1698671, 0}, {5205686, 95})
add("holy_archon_halo",         "sme", {567985, 0}, {5259954, 110})
add("holy_chastise",            "me",  {567985, 0})
add("holy_prayer_of_mending",   "me",  {1698678, 0})
add("holy_prayer_of_healing",   "e",   {1698676, 0})
add("holy_flash_heal",          "e",   {1698678, 0})
add("holy_holy_fire",           "e",   {567985, 0})
add("holy_guardian_spirit",     "sme", {5207969, 0}, {5205686, 100}, {5259954, 165})
add("holy_power_infusion",      "sme", {5207969, 0}, {5259954, 105})
add("holy_benediction",         "",    {5207969, 0}, {5259954, 100})

-- Shadow Priest: dense void pressure with short, dry accents.  DoTs and Mind
-- Blast are held for Expressive so the rotation retains space.
add("shadow_voidform",          "sme", {1717716, 0}, {5342340, 85}, {6982611, 150})
add("shadow_void_torrent",      "sme", {568751, 0}, {1716507, 100})
add("shadow_tentacle_slam",     "me",  {5342340, 0}, {568184, 70})
add("shadow_void_blast",        "me",  {1714480, 0}, {5342340, 70})
add("shadow_archon_halo",       "sme", {567985, 0}, {5342340, 105})
add("shadow_vampiric_touch",    "me",  {568984, 0})
add("shadow_shadow_word_pain",  "e",   {568040, 0})
add("shadow_shadow_word_madness", "me", {568184, 0}, {5342340, 65})
add("shadow_void_volley",       "me",  {5342340, 0}, {6995073, 80})
add("shadow_mind_blast",        "e",   {1714480, 0})
add("shadow_shadow_word_death", "me",  {568184, 0}, {5342340, 65})
add("shadow_shadowfiend",       "sme", {568751, 0}, {5342340, 95})
add("shadow_void_apparitions",  "",    {5342340, 0}, {5259954, 100})

-- Affliction Warlock: curses remain soft and textural; detonations, summons,
-- and soul-harvest moments supply the weight.
add("aff_haunt",                "me",  {2068359, 0}, {568984, 75})
add("aff_unstable_affliction",  "me",  {2068359, 0})
add("aff_seed",                 "me",  {2068305, 0}, {568984, 90})
add("aff_darkglare",            "sme", {568751, 0}, {5342340, 95})
add("aff_malevolence",          "sme", {568281, 0}, {568123, 85})
add("aff_agony",                "e",   {568984, 0})
add("aff_corruption",           "e",   {2101386, 0})
add("aff_wither",               "me",  {2101386, 0}, {568984, 70})
add("aff_dark_harvest",         "sme", {568751, 0}, {5342340, 90})
add("aff_malefic_grasp",        "e",   {2068359, 0})
add("aff_drain_soul",           "e",   {568751, 0})
add("aff_shadow_bolt",          "e",   {568406, 0})
add("aff_shadow_nathreza",      "",    {568184, 0}, {5342340, 90})

-- Demonology Warlock: compact fel summons and implosive weight.  Builders are
-- expressive-only; demons and shard spenders define Medium.
add("demo_hand_of_guldan",      "me",  {2114932, 0}, {568058, 70})
add("demo_dreadstalkers",       "me",  {2132136, 0}, {568123, 90})
add("demo_tyrant",              "sme", {568123, 0}, {568181, 90}, {5342340, 155})
add("demo_implosion",           "sme", {568181, 0}, {568718, 65})
add("demo_grimoire_imp_lord",   "sme", {568123, 0}, {568181, 90})
add("demo_grimoire_fel_ravager", "sme", {568123, 0}, {568181, 90})
add("demo_doomguard",           "sme", {568123, 0}, {5342340, 95})
add("demo_power_siphon",        "me",  {2114932, 0}, {568058, 70})
add("demo_demonbolt",           "e",   {568058, 0})
add("demo_infernal_bolt",       "e",   {568181, 0})
add("demo_shadow_bolt",         "e",   {568406, 0})
add("demo_dominion_argus",      "sme", {568123, 0}, {5342340, 95}, {568181, 155})

-- Destruction Warlock: fel projectile weight and infernal flame.  Repeated
-- maintenance spells stay restrained while Chaos Bolt keeps its two-stage arc.
add("dest_chaos_bolt",          "sme", {2068257, 0}, {2068263, 80})
add("dest_infernal",            "sme", {2068356, 0}, {2068353, 105}, {568123, 165})
add("dest_rain_of_fire",        "me",  {2114941, 0}, {4573332, 105})
add("dest_cataclysm",           "sme", {2144923, 0}, {2144927, 100})
add("dest_wither",              "me",  {2101386, 0}, {568984, 70})
add("dest_immolate",            "me",  {2101386, 0})
add("dest_conflagrate",         "e",   {2068257, 0})
add("dest_shadowburn",          "me",  {2068257, 0}, {2068263, 70})
add("dest_soul_fire",           "me",  {2068356, 0}, {2068257, 75})
add("dest_channel_demonfire",   "sme", {2068356, 0}, {2068353, 100})
add("dest_havoc",               "sme", {2068305, 0}, {2068257, 85})
add("dest_malevolence",         "sme", {568281, 0}, {568123, 85})
add("dest_embers_nihilam",      "",    {2068356, 0}, {5342340, 95})
