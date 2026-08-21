local _, ns = ...

-- Midnight 12.1 Arcane/Frost supplement.  This file is intentionally kept
-- separate from Data.lua so the large class table can be integrated without
-- editing the shared data file.  Load it before Data.lua in the TOC.
ns.AdditionalSpecRules = ns.AdditionalSpecRules or {}

local rules = {
    -- Arcane Mage (62): the current rotation's resource builders, cooldowns,
    -- and movement tools.  Arcane Missiles/Barrage/Surge/Prismatic Bolt are
    -- already represented by the base Data.lua rules.
    { id="arcane_orb_12_1", spec=62, spell="Arcane Orb", moment="Cast", event="SUCCEEDED", spellIDs={153626}, preset="medium", cooldown=1.2, defaultOn=true,
      defaultSounds={959721}, defaultDelays={0}, description="One arcane-orb launch accent; periodic orb hits remain silent." },
    { id="arcane_pulse_12_1", spec=62, spell="Arcane Pulse", moment="Cast", event="SUCCEEDED", spellIDs={1241462}, preset="medium", cooldown=1.2, defaultOn=true,
      defaultSounds={568678,5520037}, defaultDelays={0,70}, description="The current AoE pulse release." },
    { id="arcane_touch_of_the_magi_12_1", spec=62, spell="Touch of the Magi", moment="Cast", event="SUCCEEDED", spellIDs={321507}, preset="subtle", cooldown=4, defaultOn=true,
      defaultSounds={5520037,4686044}, defaultDelays={0,90}, description="A major Arcane burst-window declaration." },
    { id="arcane_blast_12_1", spec=62, spell="Arcane Blast", moment="Cast", event="SUCCEEDED", spellIDs={30451}, preset="expressive", cooldown=1.2, defaultOn=false,
      defaultSounds={5520066}, defaultDelays={0}, description="Optional hard-cast Arcane Charge builder accent." },
    { id="arcane_evocation_12_1", spec=62, spell="Evocation", moment="Channel", event="CHANNEL_START", spellIDs={12051}, preset="subtle", cooldown=4, defaultOn=true,
      defaultSounds={5520041,4686044}, defaultDelays={0,100}, description="One mana-channel opening; individual ticks remain silent." },
    { id="arcane_presence_of_mind_12_1", spec=62, spell="Presence of Mind", moment="Cast", event="SUCCEEDED", spellIDs={205025}, preset="expressive", cooldown=2, defaultOn=false,
      defaultSounds={5259954}, defaultDelays={0}, description="Optional movement/instant-cast setup cue." },

    -- Frost Mage (64): current Frostfire/Spellslinger direct player casts.
    { id="frost_frostbolt_12_1", spec=64, spell="Frostbolt", moment="Cast", event="SUCCEEDED", spellIDs={116}, preset="expressive", cooldown=1.2, defaultOn=false,
      defaultSounds={4612975}, defaultDelays={0}, description="Optional Frostbolt filler accent." },
    { id="frost_frostfire_bolt_12_1", spec=64, spell="Frostfire Bolt", moment="Cast", event="SUCCEEDED", spellIDs={431044}, capability="frostfire", preset="medium", cooldown=1.1, defaultOn=true,
      defaultSounds={4612975,568023}, defaultDelays={0,55}, description="Frostfire's current hard-cast bolt." },
    { id="frost_flurry_12_1", spec=64, spell="Flurry", moment="Cast", event="SUCCEEDED", spellIDs={44614}, preset="expressive", cooldown=1.1, defaultOn=false,
      defaultSounds={4612975}, defaultDelays={0}, description="Optional Brain Freeze shatter setup accent." },
    { id="frost_ice_lance_12_1", spec=64, spell="Ice Lance", moment="Cast", event="SUCCEEDED", spellIDs={30455}, preset="expressive", cooldown=0.8, defaultOn=false,
      defaultSounds={4613005}, defaultDelays={0}, description="Optional Fingers of Frost spender accent." },
    { id="frost_comet_storm_12_1", spec=64, spell="Comet Storm", moment="Cast", event="SUCCEEDED", spellIDs={1247777}, preset="medium", cooldown=1.2, defaultOn=true,
      defaultSounds={4613005,568047}, defaultDelays={0,70}, description="A committed Comet Storm release; individual comets remain silent." },
    { id="frost_blizzard_12_1", spec=64, spell="Blizzard", moment="Cast", event="SUCCEEDED", spellIDs={190356}, preset="expressive", cooldown=1.2, defaultOn=false,
      defaultSounds={4612975}, defaultDelays={0}, description="Optional AoE hard-cast accent." },
}

for _, rule in ipairs(rules) do
    ns.AdditionalSpecRules[#ns.AdditionalSpecRules + 1] = rule
end
