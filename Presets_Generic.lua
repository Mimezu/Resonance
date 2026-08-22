local _, ns = ...

-- Shared presets stay restrained. Travel sounds should feel like a small
-- flourish at the end of an action, not compete with normal world audio.
ns.CuratedRulePresets = ns.CuratedRulePresets or {}

local function layer(soundID, delayMs)
    return { soundID = soundID, delayMs = delayMs or 0, enabled = true }
end

local function config(enabled, ...)
    return { enabled = enabled, layers = { ... } }
end

local function presets(ruleID, subtle, medium, expressive)
    assert(not ns.CuratedRulePresets[ruleID], "Duplicate curated preset: " .. ruleID)
    ns.CuratedRulePresets[ruleID] = { subtle = subtle, medium = medium, expressive = expressive }
end

-- Skyriding deliberately avoids extra wind beds. WoW already owns the sense
-- of speed; these are small, distinct colour accents under each action.
presets("generic_surge_forward",
    config(false),
    config(true, layer(5453442)),
    config(true, layer(5453442)))
presets("generic_skyward_ascent",
    config(true, layer(5520041)),
    config(false),
    config(true, layer(5520041)))
presets("generic_whirling_surge",
    config(false),
    config(true, layer(1378203)),
    config(true, layer(1378203)))
presets("generic_aerial_halt",
    config(false),
    config(false),
    config(true, layer(5013972)))

-- Hearthstone toys are deliberately quiet: one sustained thematic Casting
-- layer, then one small completion sound only in Medium and Expressive.
local function hearthstone(itemID, castingSound, mediumCastSound, expressiveCastSound)
    local id = "generic_hearth_item_" .. itemID
    presets(id,
        config(false),
        config(true, layer(mediumCastSound)),
        config(true, layer(expressiveCastSound)))
    presets(id .. "_casting",
        config(true, layer(castingSound)),
        config(true, layer(castingSound)),
        config(true, layer(castingSound)))
end

hearthstone(6948, 565425, 1668194, 5259954)
hearthstone(64488, 565875, 2428610, 5259956)
hearthstone(54452, 566646, 959721, 959725)
hearthstone(93672, 6906701, 985226, 6758093)
hearthstone(168907, 565489, 2428623, 5145512)
hearthstone(235016, 566889, 2428611, 1668194)
hearthstone(245970, 937448, 5259958, 2428624)
hearthstone(140192, 566790, 1417215, 1417217)
hearthstone(162973, 568119, 568760, 5259954)
hearthstone(163045, 4199287, 568040, 568984)
hearthstone(165669, 569692, 1417215, 5259956)
hearthstone(165670, 565489, 5207969, 5259960)
hearthstone(165802, 7050101, 3500715, 1602212)
hearthstone(166746, 2066563, 2428607, 568023)
hearthstone(166747, 568819, 569132, 569132)
hearthstone(209035, 5115828, 593904, 2428618)
hearthstone(236687, 5115828, 2428607, 2428618)
hearthstone(172179, 4392624, 4392652, 5259962)
hearthstone(190196, 568334, 567991, 568608)
hearthstone(190237, 4392604, 3500748, 6908866)
hearthstone(193588, 4558583, 903728, 1064331)
hearthstone(246565, 4392644, 959725, 5259964)
hearthstone(184353, 4392604, 5207969, 567985)
hearthstone(206195, 565489, 5205686, 568608)
hearthstone(210455, 566646, 937442, 5259958)
hearthstone(257736, 568450, 2066680, 5205690)
hearthstone(263489, 568334, 567991, 568608)
hearthstone(276371, 569692, 5207969, 567985)
hearthstone(180290, 3811972, 3500715, 1602212)
hearthstone(200630, 4556360, 4544016, 4556844)
hearthstone(264367, 7050101, 568437, 4554211)
hearthstone(183716, 4199287, 3548439, 3500748)
hearthstone(182773, 4186950, 568040, 975307)
hearthstone(188952, 4280311, 4181048, 4181054)
hearthstone(228940, 6907105, 631618, 5887953)
hearthstone(263933, 1695572, 6758093, 985266)
hearthstone(110560, 565425, 4548276, 4556549)
hearthstone(208704, 568819, 4556549, 3610647)
hearthstone(212337, 4556549, 4548276, 4553587)
hearthstone(265100, 4556553, 4555859, 568813)

-- Other shared actions
presets("generic_arcantina",
    config(true, layer(4558583)),
    config(true, layer(4558583), layer(2428623, 100)),
    config(true, layer(4558583), layer(2428623, 90), layer(4686040, 170)))
presets("generic_recuperate",
    config(true, layer(1661243)),
    config(true, layer(1661243), layer(568405, 90)),
    config(true, layer(1661243), layer(568405, 80), layer(1602212, 160)))

-- Arcantina has a fixed cast spell. Keep its optional sustained accent off
-- in the two quieter presets.
if ns.RuleByID and ns.RuleByID.generic_arcantina_casting then
    presets("generic_arcantina_casting",
        config(false, layer(566646)),
        config(false, layer(566646)),
        config(true, layer(566646)))
end
