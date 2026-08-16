local _, ns = ...

-- Curated Hunter, Rogue, and Demon Hunter sound sets.  These presets favour
-- native class vocabulary and short, textural accents.  Frequent builders stay
-- quiet until Expressive, and even there generally receive only one layer.
ns.CuratedRulePresets = ns.CuratedRulePresets or {}

local function C(enabled, ...)
    local layers = {}
    local values = { ... }
    for index = 1, #values, 2 do
        layers[#layers + 1] = {
            soundID = values[index],
            delayMs = values[index + 1] or 0,
            enabled = true,
        }
    end
    return { enabled = enabled, layers = layers }
end

local function P(id, subtle, medium, expressive)
    ns.CuratedRulePresets[id] = {
        subtle = subtle,
        medium = medium,
        expressive = expressive,
    }
end

-- Beast Mastery Hunter
P("bm_bestial_wrath",       C(true, 1661243, 0), C(true, 1661243, 0, 4556842, 65), C(true, 1661243, 0, 1602214, 70))
P("bm_call_of_the_wild",    C(true, 1602212, 0), C(true, 1602212, 0, 4556360, 85), C(true, 1602212, 0, 1602214, 95))
P("bm_black_arrow",         C(true, 1594749, 0), C(true, 1594749, 0, 1594755, 85), C(true, 1594749, 0, 1594755, 75))
P("bm_kill_command",        C(false, 1602214, 0), C(false, 1602214, 0), C(true, 1602214, 0))
P("bm_barbed_shot",         C(false, 922086, 0), C(false, 922086, 0), C(true, 922086, 0))
P("bm_cobra_shot",          C(false, 1591691, 0), C(false, 1591691, 0), C(true, 1591691, 0))
P("bm_wild_thrash",         C(false, 1602214, 0), C(true, 1602214, 0), C(true, 1602214, 0, 4556842, 55))

-- Marksmanship Hunter
P("mm_trueshot",            C(true, 4556360, 0), C(true, 4556360, 0, 922086, 75), C(true, 4556360, 0, 1590095, 65))
P("mm_explosive_shot",      C(true, 1603347, 0), C(true, 1603347, 0, 2145571, 65), C(true, 1603347, 0, 2145572, 80))
P("mm_black_arrow",         C(true, 1594749, 0), C(true, 1594749, 0, 1594755, 85), C(true, 1594749, 0, 1594755, 70))
P("mm_lunar_storm",         C(true, 1597432, 0), C(true, 1597432, 0, 1597435, 100), C(true, 1597432, 0, 2139090, 85))
P("mm_deadly_insight",      C(false, 5259954, 0), C(false, 5259954, 0), C(false, 5259954, 0))
P("mm_aimed_shot",          C(false, 1590095, 0), C(true, 1590095, 0), C(true, 1590095, 0, 1313130, 70))
P("mm_rapid_fire",          C(false, 1318264, 0), C(true, 1318264, 0), C(true, 1318264, 0, 1315082, 55))
P("mm_arcane_shot",         C(false, 1591691, 0), C(false, 1591691, 0), C(true, 1591691, 0, 1591768, 55))
P("mm_kill_shot",           C(false, 922086, 0), C(true, 922086, 0), C(true, 922086, 0, 1313130, 55))
P("mm_steady_shot",         C(false, 1590095, 0), C(false, 1590095, 0), C(true, 1590095, 0))
P("mm_multishot",           C(false, 1318264, 0), C(false, 1318264, 0), C(true, 1318264, 0, 1318266, 55))
P("mm_moonlight_chakram",   C(true, 2139089, 0), C(true, 2139089, 0, 2139090, 85), C(true, 1597432, 0, 2139090, 85))
P("mm_wailing_arrow",       C(true, 1594749, 0), C(true, 1594749, 0, 1594755, 90), C(true, 1594749, 0, 1594755, 70))

-- Survival Hunter
P("sv_wildfire_bomb",       C(false, 2145570, 0), C(true, 2145570, 0), C(true, 2145570, 0, 2145572, 75))
P("sv_coordinated_assault", C(true, 1602212, 0), C(true, 1602212, 0, 4556842, 75), C(true, 1602212, 0, 1602214, 80))
P("sv_spearhead",           C(true, 1302244, 0), C(true, 1302244, 0, 1602214, 65), C(true, 1302244, 0, 1602214, 55))
P("sv_lunar_storm",         C(true, 1597432, 0), C(true, 1597432, 0, 1597435, 100), C(true, 1597432, 0, 2139090, 85))
P("sv_raptor_swipe",        C(false, 1302244, 0), C(false, 1302244, 0), C(true, 1302244, 0, 1602214, 55))
P("sv_kill_command",        C(false, 1602214, 0), C(false, 1602214, 0), C(true, 1602214, 0))
P("sv_takedown",            C(true, 1302244, 0), C(true, 1302244, 0, 1602214, 70), C(true, 1302244, 0, 1602214, 55))
P("sv_boomstick",           C(false, 2145571, 0), C(false, 2145571, 0), C(true, 2145571, 0, 1603347, 65))
P("sv_moonlight_chakram",   C(true, 2139089, 0), C(true, 2139089, 0, 2139090, 85), C(true, 1597432, 0, 2139090, 85))

-- Assassination Rogue
P("assa_deathmark",          C(true, 568406, 0), C(true, 568406, 0, 1315156, 85), C(true, 568406, 0, 1315153, 70))
P("assa_kingsbane",          C(true, 1301161, 0), C(true, 1301161, 0, 1301162, 70), C(true, 1301161, 0, 1361062, 85))
P("assa_envenom",            C(false, 1301162, 0), C(true, 1301162, 0), C(true, 1301161, 0, 1301162, 55))
P("assa_deathstalkers_mark", C(true, 568406, 0), C(true, 568406, 0, 1315153, 70), C(true, 568406, 0, 1315156, 75))
P("assa_implacable",         C(true, 983489, 0), C(true, 983489, 0, 568984, 80), C(true, 1301161, 0, 568984, 70))
P("assa_garrote",            C(false, 1305792, 0), C(false, 1305792, 0), C(true, 1305792, 0))
P("assa_mutilate",           C(false, 1305792, 0), C(false, 1305792, 0), C(true, 1305792, 0))
P("assa_rupture",            C(false, 1311840, 0), C(true, 1311840, 0), C(true, 1311840, 0, 983489, 55))
P("assa_shiv",               C(false, 983489, 0), C(true, 983489, 0), C(true, 983489, 0, 1301162, 55))

-- Outlaw Rogue
P("outlaw_adrenaline_rush", C(true, 903896, 0), C(true, 903896, 0, 1348442, 70), C(true, 903896, 0, 1348442, 55))
P("outlaw_roll_the_bones",  C(true, 937448, 0), C(true, 937448, 0, 5259954, 85), C(true, 937448, 0, 5259954, 65))
P("outlaw_killing_spree",   C(true, 1301167, 0), C(true, 1301167, 0, 1348442, 60), C(true, 1301167, 0, 1311840, 75))
P("outlaw_slice_and_dice", C(false, 1348442, 0), C(true, 1348442, 0), C(true, 1348442, 0, 903896, 55))
P("outlaw_blade_flurry",   C(false, 1348442, 0), C(true, 1348442, 0), C(true, 1301167, 0, 1348442, 55))
P("outlaw_between_the_eyes", C(false, 1537119, 0), C(true, 1537119, 0), C(true, 1360714, 0, 1537119, 45))
P("outlaw_pistol_shot",     C(false, 1360714, 0), C(false, 1360714, 0), C(true, 1360714, 0))
P("outlaw_keep_it_rolling", C(true, 937448, 0), C(true, 937448, 0, 5259954, 80), C(true, 937448, 0, 5259954, 60))

-- Subtlety Rogue
P("sub_shadow_dance",       C(true, 1315153, 0), C(true, 1315153, 0, 1315156, 80), C(true, 1315153, 0, 1305797, 65))
P("sub_shadow_blades",      C(true, 1315153, 0), C(true, 1315153, 0, 1315156, 90), C(true, 1315153, 0, 1311840, 70))
P("sub_secret_technique",  C(false, 1305797, 0), C(true, 1305797, 0), C(true, 1305797, 0, 1311840, 75))
P("sub_deathstalkers_mark", C(true, 568406, 0), C(true, 568406, 0, 1315153, 70), C(true, 568406, 0, 1315156, 75))
P("sub_ancient_arts",       C(false, 1315156, 0), C(false, 1315156, 0), C(false, 1315156, 0))
P("sub_goremaws_bite",     C(true, 1305797, 0), C(true, 1305797, 0, 568984, 75), C(true, 1305797, 0, 1311840, 65))
P("sub_shadowstrike",       C(false, 1305792, 0), C(false, 1305792, 0), C(true, 1305797, 0))
P("sub_backstab",           C(false, 1305792, 0), C(false, 1305792, 0), C(true, 1305792, 0))
P("sub_eviscerate",         C(false, 1311840, 0), C(true, 1311840, 0), C(true, 1311840, 0, 568984, 55))
P("sub_shuriken_storm",     C(false, 1367895, 0), C(false, 1367895, 0), C(true, 1367895, 0))
P("sub_black_powder",       C(false, 1367899, 0), C(true, 1367899, 0), C(true, 1367895, 0, 568984, 55))

-- Havoc Demon Hunter
P("havoc_dh_eye_beam",      C(true, 1303784, 0), C(true, 1303784, 0, 1307165, 80), C(true, 1303784, 0, 1307165, 65))
P("havoc_dh_meta",          C(true, 1259931, 0), C(true, 1259931, 0, 1477375, 90), C(true, 1259931, 0, 568123, 105))
P("havoc_dh_the_hunt",      C(true, 1455091, 0), C(true, 1455091, 0, 903900, 80), C(true, 1455091, 0, 568902, 65))
P("havoc_dh_chaos_nova",   C(false, 1306190, 0), C(true, 1306190, 0), C(true, 1306190, 0, 568281, 70))
P("havoc_dh_fury_aldrachi", C(false, 1455091, 0), C(false, 1455091, 0), C(false, 1455091, 0))
P("havoc_dh_demonsurge",   C(false, 1477375, 0), C(false, 1477375, 0), C(false, 1477375, 0))
P("audit12_hav_reavers_glaive", C(false, 1349577, 0), C(true, 1349577, 0), C(true, 1349577, 0, 1305200, 55))
P("audit12_hav_annihilation", C(false, 1305200, 0), C(true, 1305200, 0), C(true, 1305200, 0, 568281, 50))
P("audit12_hav_death_sweep", C(false, 1305200, 0), C(true, 1305200, 0), C(true, 1305200, 0, 568902, 55))
P("audit12_hav_blade_dance", C(false, 1305200, 0), C(true, 1305200, 0), C(true, 1305200, 0, 568902, 55))
P("audit12_hav_chaos_strike", C(false, 568281, 0), C(false, 568281, 0), C(true, 568281, 0))
P("audit12_hav_essence_break", C(true, 1455091, 0), C(true, 1455091, 0, 568281, 75), C(true, 1455091, 0, 568984, 70))
P("audit12_hav_felblade",   C(false, 1349577, 0), C(false, 1349577, 0), C(true, 1349577, 0))
P("audit12_hav_immolation_aura", C(false, 1363142, 0), C(true, 1363142, 0), C(true, 1363142, 0, 568902, 65))
P("audit12_hav_vengeful_retreat", C(false, 903900, 0), C(false, 903900, 0), C(true, 903900, 0))
P("audit12_hav_fel_rush",   C(false, 903900, 0), C(false, 903900, 0), C(true, 903900, 0))

-- Vengeance Demon Hunter
P("vengeance_dh_meta",      C(true, 1365177, 0), C(true, 1365177, 0, 568123, 90), C(true, 1365177, 0, 1477375, 100))
P("vengeance_dh_fel_devastation", C(true, 1363142, 0), C(true, 1363142, 0, 568902, 75), C(true, 1363142, 0, 568281, 85))
P("vengeance_dh_fiery_brand", C(false, 1360219, 0), C(true, 1360219, 0), C(true, 1360219, 0, 568902, 65))
P("vengeance_dh_soul_carver", C(true, 1467059, 0), C(true, 1467059, 0, 1455091, 75), C(true, 1467059, 0, 568281, 70))
P("vengeance_dh_fury_aldrachi", C(false, 1455091, 0), C(false, 1455091, 0), C(false, 1455091, 0))
P("audit12_ven_infernal_strike", C(false, 1349041, 0), C(true, 1349041, 0), C(true, 1349041, 0, 568902, 65))
P("audit12_ven_fracture",   C(false, 568281, 0), C(false, 568281, 0), C(true, 568281, 0))
P("audit12_ven_spirit_bomb", C(false, 1467589, 0), C(true, 1467589, 0), C(true, 1467589, 0, 568281, 70))
P("audit12_ven_soul_cleave", C(false, 568281, 0), C(false, 568281, 0), C(true, 568281, 0))
P("audit12_ven_immolation_aura", C(false, 1363142, 0), C(true, 1363142, 0), C(true, 1363142, 0, 568902, 65))
P("audit12_ven_sigil_flame", C(false, 1360225, 0), C(true, 1360225, 0), C(true, 1360225, 0, 1360227, 80))
P("audit12_ven_sigil_spite", C(true, 1360225, 0), C(true, 1360225, 0, 1455091, 75), C(true, 1360225, 0, 568281, 80))
P("audit12_ven_felblade",   C(false, 1349577, 0), C(false, 1349577, 0), C(true, 1349577, 0))
P("audit12_ven_demon_spikes", C(true, 568123, 0), C(true, 568123, 0, 568281, 80), C(true, 568123, 0, 1305200, 60))
P("audit12_ven_darkness",   C(true, 1449735, 0), C(true, 1449735, 0, 568123, 95), C(true, 1449735, 0, 5342340, 85))

-- Devourer Demon Hunter
P("devourer_dh_void_meta",  C(true, 1449735, 0), C(true, 1449735, 0, 5342340, 100), C(true, 1449735, 0, 5342340, 80, 568751, 125))
P("devourer_dh_void_ray",   C(true, 6907105, 0), C(true, 6907105, 0, 5342340, 75), C(true, 6907105, 0, 5342340, 65))
P("devourer_dh_collapsing_star", C(true, 7079699, 0), C(true, 7079699, 0, 7123875, 110), C(true, 7079699, 0, 7123875, 95, 6758093, 140))
P("devourer_dh_midnight",   C(false, 5342340, 0), C(false, 5342340, 0), C(false, 5342340, 0))
P("audit12_devourer_reap",  C(false, 5917414, 0), C(false, 5917414, 0), C(true, 5917414, 0, 6995073, 50))
P("audit12_devourer_consume", C(false, 7569671, 0), C(true, 7569671, 0), C(true, 7569671, 0, 5342340, 75))
P("audit12_devourer_soul_immolation", C(true, 5342340, 0), C(true, 5342340, 0, 5141255, 75), C(true, 5342340, 0, 5141255, 60))
P("audit12_devourer_voidblade", C(false, 5917414, 0), C(false, 5917414, 0), C(true, 5917414, 0, 6022528, 50))
P("audit12_devourer_hunt",  C(true, 6908118, 0), C(true, 6908118, 0, 903900, 70), C(true, 6908118, 0, 5342340, 80))
P("audit12_devourer_hungering_slash", C(false, 5917414, 0), C(false, 5917414, 0), C(true, 5917414, 0))
P("audit12_devourer_devour", C(false, 7569671, 0), C(false, 7569671, 0), C(true, 7569671, 0, 5342340, 70))
P("audit12_devourer_cull",  C(false, 5917414, 0), C(false, 5917414, 0), C(true, 5917414, 0, 1664264, 50))
P("audit12_devourer_reapers_toll", C(false, 6908644, 0), C(false, 6908644, 0), C(true, 6908644, 0, 568751, 65))
P("audit12_devourer_pierce_veil", C(false, 5917414, 0), C(false, 5917414, 0), C(true, 5917414, 0, 6022528, 50))
P("audit12_devourer_predator_wake", C(true, 6908118, 0), C(true, 6908118, 0, 5342340, 75), C(true, 6908118, 0, 5141255, 70))
