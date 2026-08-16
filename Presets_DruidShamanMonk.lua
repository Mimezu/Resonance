local _, ns = ...

-- Hand-curated sound sets for Druid, Shaman and Monk.  These deliberately
-- favour the class's own sound vocabulary and leave rotational spam quiet.
ns.CuratedRulePresets = ns.CuratedRulePresets or {}
local presets = ns.CuratedRulePresets

local function L(soundID, delayMs)
    return { soundID = soundID, delayMs = delayMs or 0, enabled = true }
end

local function S(id, subtleOn, subtle, mediumOn, medium, expressiveOn, expressive)
    presets[id] = {
        subtle = { enabled = subtleOn, layers = subtle },
        medium = { enabled = mediumOn, layers = medium },
        expressive = { enabled = expressiveOn, layers = expressive },
    }
end

-- Balance: clean lunar/solar punctuation. Fillers and DoT refreshes stay quiet.
S("balance_starsurge", true, {L(1597457)}, true, {L(1597454),L(1597457,85)}, true, {L(1597454),L(1597457,75),L(5259954,145)})
S("balance_starfall", false, {L(568377)}, true, {L(568377)}, true, {L(568377),L(1417215,75)})
S("balance_celestial_alignment", true, {L(1597431)}, true, {L(1597431),L(5259954,120)}, true, {L(1597431),L(1417215,70),L(5259954,145)})
S("balance_moonfire_sunfire", false, {L(1597438)}, false, {L(1597438)}, false, {L(1597438)})
S("balance_force_of_nature", false, {L(4556842)}, true, {L(4556842)}, true, {L(4556842),L(568813,80)})
S("balance_fury_of_elune", true, {L(1417215)}, true, {L(1417215),L(5259954,95)}, true, {L(1417215),L(568377,60),L(5259954,140)})
S("balance_convoke", true, {L(4556842)}, true, {L(4556842),L(568377,100)}, true, {L(4556842),L(568377,85),L(5259954,165)})
S("balance_wrath_starfire", false, {L(1597438)}, false, {L(1597438)}, false, {L(1597438)})

-- Feral: breath, rush and dust rather than extra weapon impacts on every bite.
S("feral_feral_frenzy", false, {L(4556842)}, true, {L(4556842),L(568813,75)}, true, {L(4556842),L(568813,65),L(4556844,125)})
S("feral_berserk", true, {L(4556844)}, true, {L(4556844),L(4556842,90)}, true, {L(4556844),L(4556842,80),L(568813,145)})
S("feral_tigers_fury", false, {L(4556842)}, true, {L(4556842)}, true, {L(4556842),L(4556844,70)})
S("feral_rake_rip", false, {L(568813)}, false, {L(568813)}, false, {L(568813)})
S("feral_shred", false, {L(4556842)}, false, {L(4556842)}, false, {L(4556842)})
S("feral_ferocious_bite", false, {L(568813)}, true, {L(568813)}, true, {L(568813),L(4556844,65)})
S("feral_convoke", true, {L(4556842)}, true, {L(4556842),L(568377,100)}, true, {L(4556842),L(568377,85),L(5259954,160)})
S("feral_apex_predator", false, {L(5259954)}, false, {L(5259954)}, true, {L(5259954)})

-- Guardian: low, grounded weight; frequent builders remain unaccented.
S("guardian_rage_of_the_sleeper", true, {L(4577695)}, true, {L(4577695),L(4553587,105)}, true, {L(4577695),L(4553587,90),L(568813,155)})
S("guardian_berserk", true, {L(4556549)}, true, {L(4556549),L(4553587,95)}, true, {L(4556549),L(4553587,80),L(4577695,145)})
S("guardian_lunar_beam", false, {L(1417215)}, true, {L(1417215),L(5259954,105)}, true, {L(1417215),L(568377,65),L(5259954,140)})
S("guardian_mangle_thrash", false, {L(4553587)}, false, {L(4553587)}, false, {L(4553587)})
S("guardian_raze", false, {L(4553587)}, false, {L(4553587),L(568813,75)}, true, {L(4553587),L(568813,65),L(4577695,120)})
S("guardian_ironfur", false, {L(4553587)}, false, {L(4553587)}, true, {L(4553587),L(4556549,60)})
S("guardian_frenzied_regeneration", false, {L(4556842)}, true, {L(4556842)}, true, {L(4556842),L(1687855,80)})
S("guardian_convoke", true, {L(4556842)}, true, {L(4556842),L(568377,100)}, true, {L(4556842),L(568377,85),L(5259954,160)})

-- Restoration Druid: soft living blooms, with richer growth on major heals.
S("resto_druid_wild_growth", false, {L(1687858)}, false, {L(1687858),L(1687861,85)}, true, {L(1687858),L(1687861,75),L(4556842,135)})
S("resto_druid_flourish", true, {L(1694578)}, true, {L(1694578),L(1694579,105)}, true, {L(1694578),L(1694579,90),L(5259954,160)})
S("resto_druid_tranquility", true, {L(568379)}, true, {L(568379),L(4556842,120)}, true, {L(568379),L(4556842,105),L(5259954,175)})
S("resto_druid_swiftmend", false, {L(1687855)}, false, {L(1687855)}, true, {L(1687855),L(1687861,75)})
S("resto_druid_lifebloom_rejuvenation", false, {L(1687855)}, false, {L(1687855)}, true, {L(1687855)})
S("resto_druid_efflorescence", false, {L(1687858)}, false, {L(1687858)}, true, {L(1687858),L(4556842,95)})
S("resto_druid_cooldowns", true, {L(1694578)}, true, {L(1694578),L(5259954,110)}, true, {L(1694578),L(1694579,85),L(5259954,155)})
S("resto_druid_convoke", true, {L(4556842)}, true, {L(4556842),L(568377,100)}, true, {L(4556842),L(568377,85),L(5259954,160)})

-- Elemental: each spell keeps its own element; no generic alert chimes.
S("ele_lava_burst", false, {L(1100352)}, true, {L(1100351),L(1100352,85)}, true, {L(1100351),L(1100352,70),L(568813,130)})
S("ele_earth_shock", false, {L(2576255)}, true, {L(2576266),L(2576255,75)}, true, {L(2576266),L(2576255,65),L(4553587,120)})
S("ele_stormkeeper", true, {L(1369107)}, true, {L(1369107),L(1715016,115)}, true, {L(1369107),L(1369104,70),L(1715016,140)})
S("ele_ascendance", true, {L(1369107)}, true, {L(1369107),L(1715016,110)}, true, {L(1369107),L(1715016,90),L(5259954,165)})
S("ele_lightning_chain", false, {L(1369104)}, false, {L(1369104)}, false, {L(1369104)})
S("ele_flame_shock", false, {L(1100351)}, false, {L(1100351)}, false, {L(1100351)})
S("ele_elemental_blast", false, {L(1100351)}, true, {L(1100351),L(2576255,90)}, true, {L(1100351),L(2576255,75),L(1715016,140)})
S("ele_tempest", false, {L(1369104)}, true, {L(1369104),L(1715016,85)}, true, {L(1369107),L(1369104,65),L(1715016,125)})

-- Enhancement: storm, flame and stone augment the melee mix without masking it.
S("enh_crash_lightning", false, {L(1369104)}, true, {L(1369104),L(1715016,80)}, true, {L(1369107),L(1369104,60),L(1715016,120)})
S("enh_sundering", true, {L(1377102)}, true, {L(1377102),L(4553587,90)}, true, {L(1377102),L(4553587,75),L(568813,135)})
S("enh_feral_spirit_doom_winds", true, {L(569157)}, true, {L(569157),L(4556842,100)}, true, {L(569157),L(4556842,80),L(1715016,145)})
S("enh_stormstrike_windstrike", false, {L(1369104)}, true, {L(1369104)}, true, {L(1369104),L(1715016,70)})
S("enh_lava_lash", false, {L(1100351)}, false, {L(1100351)}, true, {L(1100351)})
S("enh_fire_nova", false, {L(1100352)}, true, {L(1100351),L(1100352,80)}, true, {L(1100351),L(1100352,65),L(568813,125)})
S("enh_primordial_storm", true, {L(1369107)}, true, {L(1369107),L(1715016,105)}, true, {L(1369107),L(1715016,85),L(4553587,150)})
S("enh_ascendance", true, {L(1369107)}, true, {L(1369107),L(5259954,120)}, true, {L(1369107),L(1715016,85),L(5259954,160)})

-- Restoration Shaman: flowing water and resonant totems, never notification tones.
S("resto_shaman_chain_heal", false, {L(1965224)}, true, {L(1965221),L(1965224,95)}, true, {L(1965221),L(1965224,80),L(569183,150)})
S("resto_spirit_link_healing_tide", true, {L(568624)}, true, {L(568624),L(1965231,115)}, true, {L(568624),L(1965231,95),L(569183,165)})
S("resto_riptide_rain", false, {L(1937566)}, true, {L(1937566),L(1965221,90)}, true, {L(1937566),L(1965221,75),L(569183,145)})
S("resto_healing_wave_unleash", false, {L(1965224)}, false, {L(1965224)}, true, {L(1965224)})
S("resto_ascendance", true, {L(1965231)}, true, {L(1965231),L(569183,115)}, true, {L(1965231),L(1965221,80),L(569183,155)})
S("resto_stormstream", true, {L(1965231)}, true, {L(1965231),L(569183,105)}, true, {L(1965231),L(1715016,80),L(569183,150)})
S("resto_call_ancestors", true, {L(1965231)}, true, {L(1965231),L(5259954,110)}, true, {L(1965231),L(569183,85),L(5259954,155)})

-- Brewmaster: jade protection and grounded keg weight; basic strikes stay quiet.
S("brew_breath_of_fire", false, {L(613882)}, true, {L(613882)}, true, {L(613882),L(568813,85)})
S("brew_celestial_brew", false, {L(606881)}, true, {L(606881),L(613937,95)}, true, {L(606881),L(613937,80),L(5259954,145)})
S("brew_invoke_niuzao", true, {L(1369101)}, true, {L(1369101),L(4577695,115)}, true, {L(1369101),L(4577695,90),L(4553587,155)})
S("brew_exploding_keg", false, {L(4553587)}, true, {L(4553587),L(568813,75)}, true, {L(4553587),L(568813,60),L(4556844,125)})
S("brew_keg_smash", false, {L(4553587)}, true, {L(4553587)}, true, {L(4553587),L(568813,65)})
S("brew_blackout_tiger_palm", false, {L(1369372)}, false, {L(1369372)}, false, {L(1369372)})
S("brew_purifying_brew", false, {L(606881)}, true, {L(606881)}, true, {L(606881),L(613937,75)})
S("brew_fortifying_brew", true, {L(4577695)}, true, {L(4577695),L(606881,110)}, true, {L(4577695),L(606881,85),L(4553587,150)})

-- Windwalker: airy chi flourishes around finishers and celestial moments.
S("ww_fists_of_fury", false, {L(1369372)}, true, {L(1369372),L(4556842,95)}, true, {L(1369372),L(4556842,75),L(4556844,135)})
S("ww_strike_of_windlord", true, {L(1378203)}, true, {L(1378203),L(1715016,90)}, true, {L(1378203),L(1715016,75),L(4556844,135)})
S("ww_rising_sun_kick", false, {L(1369372)}, false, {L(1369372)}, true, {L(1369372),L(4556842,65)})
S("ww_whirling_dragon_punch", false, {L(1369372)}, true, {L(1369372),L(4556842,85)}, true, {L(1369372),L(4556842,70),L(4556844,130)})
S("ww_invoke_xuen", true, {L(606881)}, true, {L(606881),L(5259954,115)}, true, {L(606881),L(4556842,75),L(5259954,150)})
S("ww_zenith", true, {L(606881)}, true, {L(606881),L(5259954,100)}, true, {L(606881),L(1378203,70),L(5259954,145)})
S("ww_touch_of_death", true, {L(1378203)}, true, {L(1378203),L(1715016,90)}, true, {L(1378203),L(1715016,75),L(4556844,135)})
S("ww_celestial_conduit", true, {L(606881)}, true, {L(606881),L(5259954,110)}, true, {L(606881),L(4556842,75),L(5259954,155)})

-- Mistweaver: jade mist and soft celestial resolution; routine healing is sparse.
S("mw_enveloping_renewing_mist", false, {L(628392)}, true, {L(628392)}, true, {L(628392),L(606791,80)})
S("mw_revival_invoke_celestial", true, {L(613904)}, true, {L(613904),L(613937,100)}, true, {L(613904),L(613937,85),L(5259954,155)})
S("mw_celestial_conduit", true, {L(606881)}, true, {L(606881),L(5259954,110)}, true, {L(606881),L(613937,80),L(5259954,155)})
S("mw_soothing_mist", false, {L(606881)}, false, {L(606881)}, false, {L(606881)})
S("mw_thunder_focus_tea", false, {L(606881)}, true, {L(606881),L(613937,90)}, true, {L(606881),L(613937,75),L(5259954,140)})
S("mw_rising_sun_kick", false, {L(1369372)}, true, {L(1369372)}, true, {L(1369372),L(606881,75)})
S("mw_life_cocoon", true, {L(606881)}, true, {L(606881),L(613937,100)}, true, {L(606881),L(613937,85),L(5259954,150)})
S("mw_vivify_sheiluns_gift", false, {L(628392)}, true, {L(628392)}, true, {L(628392),L(606791,80)})
