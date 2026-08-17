local _, ns = ...

-- Hunter, Rogue, and Warrior: keep the base set on transformations, elemental
-- effects, poisons, shadow magic and memorable releases.  Repeating weapon
-- builders are deliberately excluded.
--
-- 12.1 PTR verification: Wowhead's class guides and talent records.  The Apex
-- groups include only spell IDs that can be discovered in the active trait tree;
-- their attached rules use a player-visible cast/aura rather than pretending a
-- passive talent itself is a cast event.
local capabilityGroups = {
    darkRanger = { 466930, 468572 }, -- Black Arrow (button/aura variants)
    sentinel = { 450385, 1253732, 1253733, 1253734 }, -- Lunar Storm (12.1 variants)
    deathstalker = { 457052 }, -- Deathstalker's Mark
    trickster = { 441146 }, -- Unseen Blade
    colossus = { 436358 }, -- Demolish
    mountainThane = { 435607 }, -- Thunder Blast

    raptorSwipe = { 1259003, 1259017, 1259019 },
    implacable = { 1265385, 1265386, 1265387 },
    gravedigger = { 1265861, 1265862, 1265863, 1265935 },
    ancientArts = { 1268932, 1268936, 1268939 },
    masterOfWarfare = { 1269306, 1269307, 1269314, 1269383, 1269394 },
    rampagingBerserker = { 1269308, 1269309, 1269310 },
    phalanx = { 1269311, 1269312, 1269313 },
    deadlyInsight = { 1277136 }, -- Marksmanship's player buff
}

local rules = {
    -- Beast Mastery Hunter: companion-command scale, with the Dark Ranger
    -- shadow arrow as the only hero-tree punctuation.  Builders are opt-in so
    -- the default profile keeps the pet cadence expressive rather than noisy.
    { id="bm_bestial_wrath", spec=253, spell="Bestial Wrath", moment="Transformation", event="SUCCEEDED", spellIDs={19574}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={1661243,4556842}, defaultDelays={0,70}, description="A living, wind-touched lift for the pet-rage transformation." },
    { id="bm_call_of_the_wild", spec=253, spell="Call of the Wild", moment="Summoning", event="SUCCEEDED", spellIDs={359844}, preset="subtle", cooldown=5, defaultOn=true, defaultSounds={1602212,4556360}, defaultDelays={0,95}, description="A restrained nature call for the full companion summon." },
    { id="bm_black_arrow", spec=253, spell="Black Arrow", moment="Cast", event="SUCCEEDED", spellIDs={466930}, capability="darkRanger", preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1594748,1594754}, defaultDelays={0,90}, description="Dark Ranger only: a shadowed arrow phrase, not an ordinary shot cue." },
    { id="bm_kill_command", spec=253, spell="Kill Command", moment="Command", event="SUCCEEDED", spellIDs={34026}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={922086,4556842}, defaultDelays={0,55}, description="Optional BM command cadence; disabled by default because it is frequent." },
    { id="bm_barbed_shot", spec=253, spell="Barbed Shot", moment="Barbs", event="SUCCEEDED", spellIDs={217200}, preset="expressive", cooldown=1.2, defaultOn=false, defaultSounds={1590095,4556842}, defaultDelays={0,55}, description="Optional BM bleed/buff cadence; disabled by default." },
    { id="bm_cobra_shot", spec=253, spell="Cobra Shot", moment="Filler", event="SUCCEEDED", spellIDs={193455}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1591691,1591768}, defaultDelays={0,60}, description="Optional instant BM focus spender; disabled by default." },
    { id="bm_wild_thrash", spec=253, spell="Wild Thrash", moment="AoE release", event="SUCCEEDED", spellIDs={1264355,357508,357509,256882}, preset="medium", cooldown=1.5, defaultOn=true, defaultSounds={1602212,4556842}, defaultDelays={0,70}, description="Current 12.1 Wild Thrash button variants; one restrained AoE release cue." },

    -- Marksmanship Hunter: precision is represented by the big window, explosive
    -- payloads, and the actual cast/channel bars rather than every rapid shot.
    { id="mm_trueshot", spec=254, spell="Trueshot", moment="Transformation", event="SUCCEEDED", spellIDs={288613}, preset="subtle", cooldown=5, defaultOn=true, defaultSounds={4556360,5259954}, defaultDelays={0,85}, description="A clear wind-and-spark lift for the precision window." },
    { id="mm_explosive_shot", spec=254, spell="Explosive Shot", moment="Detonation", event="SUCCEEDED", spellIDs={212431}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1603347,4573332}, defaultDelays={0,75}, description="One compact fire punctuation for the delayed payload." },
    { id="mm_black_arrow", spec=254, spell="Black Arrow", moment="Cast", event="SUCCEEDED", spellIDs={466930}, capability="darkRanger", preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1594748,1594754}, defaultDelays={0,90}, description="Dark Ranger only: black-arrow shadow magic." },
    { id="mm_lunar_storm", spec=254, spell="Lunar Storm", moment="Cast", event="SUCCEEDED", spellIDs={450385,1253732,1253733,1253734}, capability="sentinel", preset="subtle", cooldown=2, defaultOn=true, defaultSounds={1597432,1597435}, defaultDelays={0,110}, description="Sentinel only: current 12.1 moonlit storm release variants." },
    { id="mm_aimed_shot", spec=254, spell="Aimed Shot", moment="Release", event="SUCCEEDED", spellIDs={19434}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1590095,1313130}, defaultDelays={0,85}, description="The current 2.5-second precision cast; its generated Casting option is intentional." },
    { id="mm_rapid_fire", spec=254, spell="Rapid Fire", moment="Channel start", event="CHANNEL_START", spellIDs={257044}, preset="medium", cooldown=1.5, defaultOn=true, defaultSounds={1590095,1313130}, defaultDelays={0,85}, description="One cue at the start of the current Rapid Fire channel; ticks remain silent." },
    { id="mm_arcane_shot", spec=254, spell="Arcane Shot", moment="Precise release", event="SUCCEEDED", spellIDs={185358}, preset="expressive", cooldown=1.2, defaultOn=false, defaultSounds={1591691,1591768}, defaultDelays={0,55}, description="Optional Precise Shots spender; disabled by default because it is frequent." },
    { id="mm_kill_shot", spec=254, spell="Kill Shot", moment="Execute", event="SUCCEEDED", spellIDs={53351}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={922086,1591768}, defaultDelays={0,65}, description="Execute punctuation; no cue is produced outside the execute window." },
    { id="mm_steady_shot", spec=254, spell="Steady Shot", moment="Cast", event="SUCCEEDED", spellIDs={56641}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1590095,922086}, defaultDelays={0,55}, description="Optional 1.7-second filler cast; disabled by default." },
    { id="mm_multishot", spec=254, spell="Multi-Shot", moment="Trick Shots", event="SUCCEEDED", spellIDs={2643}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1318266,922086}, defaultDelays={0,55}, description="Optional AoE/Trick Shots spender; disabled by default." },
    { id="mm_moonlight_chakram", spec=254, spell="Moonlight Chakram", moment="Apex release", event="SUCCEEDED", spellIDs={1264902,1264946,1264949,1266081,1266082}, capability="sentinel", preset="medium", cooldown=2, defaultOn=true, defaultSounds={1597432,1597435}, defaultDelays={0,95}, description="Sentinel replacement/proc spell variants after Trueshot; one release cue." },
    { id="mm_wailing_arrow", spec=254, spell="Wailing Arrow", moment="Release", event="SUCCEEDED", spellIDs={355839,355596,357616,459805,459808}, capability="darkRanger", preset="medium", cooldown=2, defaultOn=true, defaultSounds={1594748,1594754}, defaultDelays={0,90}, description="Dark Ranger Wailing Arrow player-cast variants." },

    -- Survival Hunter: bombs and coordinated animal attacks, with a single Apex
    -- accent for the Raptor Strike replacement.
    { id="sv_wildfire_bomb", spec=255, spell="Wildfire Bomb", moment="Release", event="SUCCEEDED", spellIDs={259495}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={2145570,2145572}, defaultDelays={0,90}, description="A fire-and-pheromone accent for the alchemical bomb, never its periodic damage." },
    { id="sv_coordinated_assault", spec=255, spell="Coordinated Assault", moment="Transformation", event="SUCCEEDED", spellIDs={360952}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={1602212,4556360}, defaultDelays={0,85}, description="A nature-and-motion lift for fighting in concert with the pet." },
    { id="sv_spearhead", spec=255, spell="Spearhead", moment="Transformation", event="SUCCEEDED", spellIDs={360966}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={1661243,4556842}, defaultDelays={0,70}, description="A lean primal accent for the survival burst window." },
    { id="sv_lunar_storm", spec=255, spell="Lunar Storm", moment="Cast", event="SUCCEEDED", spellIDs={450385,1253732,1253733,1253734}, capability="sentinel", preset="subtle", cooldown=2, defaultOn=true, defaultSounds={1597432,1597435}, defaultDelays={0,110}, description="Sentinel only: current 12.1 moonlit storm release variants." },
    { id="sv_raptor_swipe", spec=255, spell="Raptor Swipe", moment="Release", event="SUCCEEDED", spellIDs={1259003,1259017,1259019}, capability="raptorSwipe", preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1602214,4556842}, defaultDelays={0,65}, description="Apex replacement variants; one primal flourish, not a weapon-hit layer." },
    { id="sv_kill_command", spec=255, spell="Kill Command", moment="Command", event="SUCCEEDED", spellIDs={34026}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={922086,4556842}, defaultDelays={0,55}, description="Optional Survival resource/buff builder; disabled by default." },
    { id="sv_takedown", spec=255, spell="Takedown", moment="Major release", event="SUCCEEDED", spellIDs={1250646}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={1661243,4556842}, defaultDelays={0,85}, description="Current 12.1 Survival primary cooldown; Sentinel replaces it with Moonlight Chakram." },
    { id="sv_boomstick", spec=255, spell="Boomstick", moment="Release", event="SUCCEEDED", spellIDs={1261215}, preset="medium", cooldown=1.5, defaultOn=true, defaultSounds={2145570,1603347}, defaultDelays={0,75}, description="Current 12.1 Survival rotational explosive button." },
    { id="sv_moonlight_chakram", spec=255, spell="Moonlight Chakram", moment="Apex release", event="SUCCEEDED", spellIDs={1264902,1264946,1264949,1266081,1266082}, capability="sentinel", preset="medium", cooldown=2, defaultOn=true, defaultSounds={1597432,1597435}, defaultDelays={0,95}, description="Sentinel Takedown replacement/proc variants." },

    -- Assassination Rogue: poison and death magic take priority over rotational
    -- stabs.  Implacable is an Apex chain-falloff state, not a Kingsbane cast.
    { id="assa_deathmark", spec=259, spell="Deathmark", moment="Mark", event="SUCCEEDED", spellIDs={360194}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={568406,1315156}, defaultDelays={0,100}, description="A quiet shadow seal for the assassination window." },
    { id="assa_kingsbane", spec=259, spell="Kingsbane", moment="Cast", event="SUCCEEDED", spellIDs={385627}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={1301161,1301162}, defaultDelays={0,85}, description="A concentrated poison bloom for Kingsbane." },
    { id="assa_envenom", spec=259, spell="Envenom", moment="Release", event="SUCCEEDED", spellIDs={32645}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1301161,1301162}, defaultDelays={0,70}, description="Poison magic release; its normal weapon contact remains untouched." },
    { id="assa_garrote", spec=259, spell="Garrote", moment="Bleed", event="SUCCEEDED", spellIDs={703}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1305792,1301162}, defaultDelays={0,55}, description="Optional stealth/opening bleed cue; disabled by default." },
    { id="assa_mutilate", spec=259, spell="Mutilate", moment="Builder", event="SUCCEEDED", spellIDs={1329}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1305792,1301162}, defaultDelays={0,55}, description="Optional energy builder; disabled by default." },
    { id="assa_rupture", spec=259, spell="Rupture", moment="Bleed release", event="SUCCEEDED", spellIDs={1943}, preset="medium", cooldown=1.5, defaultOn=true, defaultSounds={1301161,568406}, defaultDelays={0,70}, description="Finisher-driven bleed maintenance cue." },
    { id="assa_shiv", spec=259, spell="Shiv", moment="Poison window", event="SUCCEEDED", spellIDs={5938}, preset="medium", cooldown=2, defaultOn=true, defaultSounds={1301161,1301162}, defaultDelays={0,70}, description="Short poison-window punctuation." },

    -- Outlaw Rogue: magical chance, alacrity, and cinematic finishers—not pistol
    -- spam.  Gravedigger's server-side automatic strike has no player event, so
    -- the base set does not falsely announce every Dispatch as a proc.
    { id="outlaw_adrenaline_rush", spec=260, spell="Adrenaline Rush", moment="Transformation", event="SUCCEEDED", spellIDs={13750}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={4556360,5259954}, defaultDelays={0,80}, description="A quick, bright lift for the swashbuckling burst window." },
    { id="outlaw_roll_the_bones", spec=260, spell="Roll the Bones", moment="Roll", event="SUCCEEDED", spellIDs={315508}, preset="medium", cooldown=2, defaultOn=true, defaultSounds={937448,5259954}, defaultDelays={0,100}, description="A small arcane-dice shimmer for the random buff roll." },
    { id="outlaw_killing_spree", spec=260, spell="Killing Spree", moment="Channel start", event="CHANNEL_START", spellIDs={51690}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={903896,1416760}, defaultDelays={0,85}, description="One cue at the start of the channel; individual jumps remain silent." },
    { id="outlaw_slice_and_dice", spec=260, spell="Slice and Dice", moment="Buff", event="SUCCEEDED", spellIDs={315496}, preset="medium", cooldown=1.5, defaultOn=true, defaultSounds={937448,5259954}, defaultDelays={0,70}, description="Finisher buff maintenance cue." },
    { id="outlaw_blade_flurry", spec=260, spell="Blade Flurry", moment="Cleave", event="SUCCEEDED", spellIDs={13877}, preset="medium", cooldown=2, defaultOn=true, defaultSounds={1348442,4556842}, defaultDelays={0,65}, description="AoE cleave toggle punctuation." },
    { id="outlaw_between_the_eyes", spec=260, spell="Between the Eyes", moment="Shot", event="SUCCEEDED", spellIDs={315341}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1537119,1360714}, defaultDelays={0,75}, description="Signature pistol-finisher shot." },
    { id="outlaw_pistol_shot", spec=260, spell="Pistol Shot", moment="Shot", event="SUCCEEDED", spellIDs={185763}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1360714,1537119}, defaultDelays={0,55}, description="Optional Pistol Shot cast accent; disabled by default." },
    { id="outlaw_keep_it_rolling", spec=260, spell="Keep It Rolling", moment="Roll extension", event="SUCCEEDED", spellIDs={381989}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={937448,5259954}, defaultDelays={0,90}, description="Major Outlaw roll-extension talent; available across current hero-tree builds." },

    -- Subtlety Rogue: shadow forms, cloned techniques, and a precise Apex spend.
    { id="sub_shadow_dance", spec=261, spell="Shadow Dance", moment="Transformation", event="SUCCEEDED", spellIDs={185313}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={1315153,1315156}, defaultDelays={0,90}, description="A shadow veil for entering the dance." },
    { id="sub_shadow_blades", spec=261, spell="Shadow Blades", moment="Transformation", event="SUCCEEDED", spellIDs={121471}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={1315153,1315156}, defaultDelays={0,95}, description="A dark magical armament lift." },
    { id="sub_secret_technique", spec=261, spell="Secret Technique", moment="Release", event="SUCCEEDED", spellIDs={280719}, preset="medium", cooldown=2, defaultOn=true, defaultSounds={1305797,568984}, defaultDelays={0,85}, description="A single shadow-clone release accent." },
    { id="sub_goremaws_bite", spec=261, spell="Goremaw's Bite", moment="Opening bite", event="SUCCEEDED", spellIDs={426591}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={1305797,568984}, defaultDelays={0,90}, description="Major pre-window shadow bite." },
    { id="sub_shadowstrike", spec=261, spell="Shadowstrike", moment="Builder", event="SUCCEEDED", spellIDs={185438}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1305792,1305797}, defaultDelays={0,55}, description="Optional Stealth/Shadow Dance builder; disabled by default." },
    { id="sub_backstab", spec=261, spell="Backstab", moment="Builder", event="SUCCEEDED", spellIDs={53}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1305792,1348442}, defaultDelays={0,55}, description="Optional filler builder; disabled by default." },
    { id="sub_eviscerate", spec=261, spell="Eviscerate", moment="Finisher", event="SUCCEEDED", spellIDs={196819}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1311840,568984}, defaultDelays={0,75}, description="Core combo-point finisher." },
    { id="sub_shuriken_storm", spec=261, spell="Shuriken Storm", moment="AoE builder", event="SUCCEEDED", spellIDs={197835}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={1367895,1305792}, defaultDelays={0,55}, description="Optional AoE builder; disabled by default." },
    { id="sub_black_powder", spec=261, spell="Black Powder", moment="AoE finisher", event="SUCCEEDED", spellIDs={216230,1269565,1269634}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={1311840,568984}, defaultDelays={0,75}, description="Current Subtlety AoE finisher variants." },

    -- Arms Warrior: the elemental identity is Avatar/Warbreaker/Colossus; base
    -- strikes are excluded.  Master of Warfare uses its verified 30-second buff.
    { id="arms_avatar", spec=71, spell="Avatar", moment="Transformation", event="SUCCEEDED", spellIDs={107574}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={620872,4548280}, defaultDelays={0,85}, description="Stone-and-power transformation, with no melee-hit overlay." },
    { id="arms_warbreaker", spec=71, spell="Warbreaker", moment="Impact", event="SUCCEEDED", spellIDs={262161}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4553587,4555859}, defaultDelays={0,85}, description="A contained earth fracture for the armor-breaking release." },
    { id="arms_demolish", spec=71, spell="Demolish", moment="Channel start", event="CHANNEL_START", spellIDs={436358}, capability="colossus", preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4556549,4553587}, defaultDelays={0,115}, description="Colossus only: one earth-magic start cue; the channel's repeated impacts remain silent." },
    { id="arms_mortal_strike", spec=71, spell="Mortal Strike", moment="Release", event="SUCCEEDED", spellIDs={12294}, preset="medium", cooldown=1.0, defaultOn=true, defaultSounds={4553587}, description="Core Arms identity spender; one restrained weapon release cue." },
    { id="arms_execute", spec=71, spell="Execute", moment="Execute", event="SUCCEEDED", spellIDs={163201}, preset="medium", cooldown=1.0, defaultOn=true, defaultSounds={4555859}, description="Arms execute-window finisher." },
    { id="arms_overpower", spec=71, spell="Overpower", moment="Strike", event="SUCCEEDED", spellIDs={7384}, preset="expressive", cooldown=1.2, defaultOn=false, defaultSounds={4553587}, description="Optional frequent strike; disabled by default and throttled." },
    { id="arms_cleave", spec=71, spell="Cleave", moment="AoE strike", event="SUCCEEDED", spellIDs={845}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={4553587}, description="Optional physical AoE filler; disabled by default and throttled." },
    { id="arms_slam", spec=71, spell="Slam", moment="Filler", event="SUCCEEDED", spellIDs={1464}, preset="expressive", cooldown=1.2, defaultOn=false, defaultSounds={4553587}, description="Optional physical filler; disabled by default and throttled." },
    { id="arms_colossus_smash", spec=71, spell="Colossus Smash", moment="Armor break", event="SUCCEEDED", spellIDs={167105}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4553587,4555859}, description="Core armor-break window." },
    { id="arms_bladestorm", spec=71, spell="Bladestorm", moment="Release", event="SUCCEEDED", spellIDs={227847}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4543791,4553587}, description="Instant Arms burst release; this is not a cast-bar event." },

    -- Fury Warrior: fight frenzy as wind, stone and thunder punctuation instead
    -- of a cue on every Rampage.
    { id="fury_avatar", spec=72, spell="Avatar", moment="Transformation", event="SUCCEEDED", spellIDs={107574}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={620872,4548280}, defaultDelays={0,85}, description="Stone-and-power transformation." },
    { id="fury_recklessness", spec=72, spell="Recklessness", moment="Transformation", event="SUCCEEDED", spellIDs={1719}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={4556360,4543791}, defaultDelays={0,95}, description="A storm-bright opening for the berserker window." },
    { id="fury_thunderous_roar", spec=72, spell="Thunderous Roar", moment="Roar", event="SUCCEEDED", spellIDs={384318}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4543791,1362397}, defaultDelays={0,70}, description="Elemental thunder only; no ordinary cleave cue." },
    { id="fury_rampage", spec=72, spell="Rampage", moment="Rage spender", event="SUCCEEDED", spellIDs={184367}, preset="medium", cooldown=1.0, defaultOn=true, defaultSounds={4543791,4556846}, description="Fury identity spender; one restrained berserk release." },
    { id="fury_raging_blow", spec=72, spell="Raging Blow", moment="Strike", event="SUCCEEDED", spellIDs={85288}, preset="expressive", cooldown=1.2, defaultOn=false, defaultSounds={4556846}, description="Optional frequent strike; disabled by default and throttled." },
    { id="fury_bloodthirst", spec=72, spell="Bloodthirst", moment="Builder", event="SUCCEEDED", spellIDs={23881}, preset="expressive", cooldown=1.2, defaultOn=false, defaultSounds={4553587}, description="Optional frequent Fury builder; disabled by default and throttled." },
    { id="fury_whirlwind", spec=72, spell="Whirlwind", moment="AoE strike", event="SUCCEEDED", spellIDs={190411}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={4543791}, description="Optional physical AoE filler; disabled by default and throttled." },
    { id="fury_execute", spec=72, spell="Execute", moment="Execute", event="SUCCEEDED", spellIDs={5308}, preset="medium", cooldown=1.0, defaultOn=true, defaultSounds={4555859}, description="Fury execute-window finisher." },
    { id="fury_bladestorm", spec=72, spell="Bladestorm", moment="Release", event="SUCCEEDED", spellIDs={227847}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4543791,4553587}, description="Instant Fury burst release; this is not a cast-bar event." },
    { id="fury_odyns_fury", spec=72, spell="Odyn's Fury", moment="Release", event="SUCCEEDED", spellIDs={385059}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4543791,4553587}, description="Major Fury elemental burst release." },

    -- Protection Warrior: defensive transformations and thunder are audible;
    -- Shield Slam/Thunder Clap repetition remains quiet.  The Phalanx passive is
    -- capability-detected but lacks a player-visible unique aura in 12.1 PTR.
    { id="prot_avatar", spec=73, spell="Avatar", moment="Transformation", event="SUCCEEDED", spellIDs={107574}, preset="subtle", cooldown=4, defaultOn=true, defaultSounds={620872,4548280}, defaultDelays={0,85}, description="Stone-and-power transformation." },
    { id="prot_last_stand", spec=73, spell="Last Stand", moment="Transformation", event="SUCCEEDED", spellIDs={12975}, preset="subtle", cooldown=5, defaultOn=true, defaultSounds={4556549,4548280}, defaultDelays={0,95}, description="A grounded defensive transformation." },
    { id="prot_thunderous_roar", spec=73, spell="Thunderous Roar", moment="Roar", event="SUCCEEDED", spellIDs={384318}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4543791,1362397}, defaultDelays={0,70}, description="Elemental thunder only; ordinary shield impacts stay silent." },
    { id="prot_shield_slam", spec=73, spell="Shield Slam", moment="Builder", event="SUCCEEDED", spellIDs={23922}, preset="medium", cooldown=1.2, defaultOn=true, defaultSounds={4553587}, description="Core Protection builder; one restrained shield impact." },
    { id="prot_thunder_clap", spec=73, spell="Thunder Clap", moment="AoE strike", event="SUCCEEDED", spellIDs={6343}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={4543791}, description="Optional frequent physical AoE builder; disabled by default and throttled." },
    { id="prot_revenge", spec=73, spell="Revenge", moment="Strike", event="SUCCEEDED", spellIDs={6572}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={4553587}, description="Optional frequent strike; disabled by default and throttled." },
    { id="prot_ignore_pain", spec=73, spell="Ignore Pain", moment="Defensive spender", event="SUCCEEDED", spellIDs={190456}, preset="expressive", cooldown=1.5, defaultOn=false, defaultSounds={4556549}, description="Optional frequent defensive spender; disabled by default and throttled." },
    { id="prot_execute", spec=73, spell="Execute", moment="Execute", event="SUCCEEDED", spellIDs={163201}, preset="medium", cooldown=1.0, defaultOn=true, defaultSounds={4555859}, description="Protection execute-window finisher." },
    { id="prot_demoralizing_shout", spec=73, spell="Demoralizing Shout", moment="Defensive window", event="SUCCEEDED", spellIDs={1160}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4543791,4556549}, description="Major Protection mitigation window." },
    { id="prot_shield_charge", spec=73, spell="Shield Charge", moment="Charge", event="SUCCEEDED", spellIDs={385952}, preset="subtle", cooldown=3, defaultOn=true, defaultSounds={4553587,4555859}, description="Major Protection burst/mitigation charge." },
}

ns.AdditionalCapabilityGroups = ns.AdditionalCapabilityGroups or {}
for name, spellIDs in pairs(capabilityGroups) do
    ns.AdditionalCapabilityGroups[name] = spellIDs
end

ns.AdditionalSpecRules = ns.AdditionalSpecRules or {}
for _, rule in ipairs(rules) do
    ns.AdditionalSpecRules[#ns.AdditionalSpecRules + 1] = rule
end
