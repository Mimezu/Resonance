local addonName, ns = ...

-- Hand-curated Paladin, Death Knight and Warrior sets.  These deliberately
-- treat intensity as arrangement, not simply "more events": Subtle is sparse,
-- Medium adds rotational punctuation, and Expressive enriches the same fantasy
-- while leaving fatiguing fillers silent.
ns.CuratedRulePresets = ns.CuratedRulePresets or {}

local function Layers(soundIDs, delays, limit, tailSound, tailDelay)
    local layers, seen = {}, {}
    for index, soundID in ipairs(soundIDs or {}) do
        if index > limit then break end
        layers[#layers + 1] = { soundID = soundID, delayMs = (delays and delays[index]) or 0, enabled = true }
        seen[soundID] = true
    end
    if tailSound and #layers < limit and not seen[tailSound] then
        layers[#layers + 1] = { soundID = tailSound, delayMs = tailDelay or 140, enabled = true }
    end
    return layers
end

local function Curate(ruleID, soundIDs, delays, subtleOn, mediumOn, expressiveOn, tailSound, restrained)
    assert(not ns.CuratedRulePresets[ruleID], "Duplicate curated preset: " .. ruleID)
    ns.CuratedRulePresets[ruleID] = {
        subtle = { enabled = subtleOn == true, layers = Layers(soundIDs, delays, 1) },
        medium = { enabled = mediumOn == true, layers = Layers(soundIDs, delays, restrained and 1 or 2) },
        expressive = { enabled = expressiveOn == true, layers = Layers(soundIDs, delays, restrained and 1 or 3, tailSound, 155) },
    }
end

local PALADIN_TAIL = 5207969 -- a short, modern Light onset rather than a UI-like chime
local DEATH_TAIL = 568184    -- a short runic-shadow decay
local WARRIOR_TAIL = 4548280 -- a grounded stone/armor resonance

-- Holy Paladin: warm radiance and measured bells.  Direct-heal spam stays quiet.
Curate("holy_pal_holy_shock",       {1850095},         {0},     false, false, true,  nil,          true)
Curate("holy_pal_light_of_dawn",    {1850095,568262},  {0,80},  false, true,  true,  PALADIN_TAIL)
Curate("holy_pal_divine_toll",      {3190872,5207969}, {0,120}, true,  true,  true,  nil)
Curate("holy_pal_wings",            {1955772,568175},  {0,120}, true,  true,  true,  PALADIN_TAIL)
Curate("holy_pal_word_of_glory",    {1850095,568262},  {0,80},  false, true,  true,  PALADIN_TAIL)
Curate("holy_pal_holy_light",       {1850095},         {0},     false, false, false, nil,          true)
Curate("holy_pal_flash_of_light",   {1850095},         {0},     false, false, false, nil,          true)
Curate("holy_pal_holy_prism",       {3190872,5205686}, {0,90},  false, true,  true,  PALADIN_TAIL)
Curate("holy_pal_beacon_virtue",    {5207969},         {0},     false, true,  true,  PALADIN_TAIL)
Curate("holy_pal_aura_mastery",     {1955772,568175},  {0,120}, true,  true,  true,  PALADIN_TAIL)

-- Protection Paladin: shield weight under a restrained holy resonance.
Curate("prot_pal_avengers_shield",        {1360121},         {0},     false, true,  true,  PALADIN_TAIL)
Curate("prot_pal_eye_of_tyr",             {567985,5205686},  {0,80},  true,  true,  true,  PALADIN_TAIL)
Curate("prot_pal_sentinel",               {1955772,568175},  {0,120}, true,  true,  true,  PALADIN_TAIL)
Curate("prot_pal_divine_toll",            {3190872},         {0},     false, true,  true,  PALADIN_TAIL)
Curate("prot_pal_hammer_of_light",        {1455052,5205686}, {0,100}, true,  true,  true,  PALADIN_TAIL)
Curate("prot_pal_judgment",               {567985},          {0},     false, false, false, nil,          true)
Curate("prot_pal_shield_righteous",       {1455052},         {0},     false, true,  true,  PALADIN_TAIL)
Curate("prot_pal_blessed_hammer",         {1360121},         {0},     false, false, false, nil,          true)
Curate("prot_pal_consecration",           {5205686},         {0},     false, true,  true,  PALADIN_TAIL)
Curate("prot_pal_ardent_defender",        {1955772,568175},  {0,100}, false, true,  true,  PALADIN_TAIL)
Curate("prot_pal_guardian_ancient_kings", {1955772,568175},  {0,120}, true,  true,  true,  PALADIN_TAIL)

-- Retribution Paladin: deliberate verdicts and solar weight, not generator spam.
Curate("ret_pal_wake",               {1455052,567985},  {0,100}, true,  true,  true,  PALADIN_TAIL)
Curate("ret_pal_execution_sentence", {628424,5205686},  {0,100}, false, true,  true,  PALADIN_TAIL)
Curate("ret_pal_final_reckoning",    {567985,5205686},  {0,100}, false, true,  true,  PALADIN_TAIL)
Curate("ret_pal_wings",              {1955772,568175},  {0,120}, true,  true,  true,  PALADIN_TAIL)
Curate("ret_pal_hammer_of_light",    {1455052,1253385}, {0,90},  true,  true,  true,  PALADIN_TAIL)
Curate("ret_pal_final_verdict",      {1455052,5205686}, {0,80},  false, true,  true,  PALADIN_TAIL)
Curate("ret_pal_blade_justice",      {1360121},         {0},     false, false, false, nil,          true)
Curate("ret_pal_hammer_wrath",       {567985},          {0},     false, true,  true,  PALADIN_TAIL)
Curate("ret_pal_judgment",           {567985},          {0},     false, false, false, nil,          true)
Curate("ret_pal_divine_storm",       {1455052},         {0},     false, true,  true,  PALADIN_TAIL)

-- Blood Death Knight: blood magic, bone and runes; routine rune builders stay silent.
Curate("blood_dk_drw",             {1589468,568184},  {0,100}, true,  true,  true,  DEATH_TAIL)
Curate("blood_dk_death_and_decay", {1589468},         {0},     false, true,  true,  DEATH_TAIL)
Curate("blood_dk_abomination_limb",{1589472,1279147}, {0,90},  false, true,  true,  DEATH_TAIL)
Curate("blood_dk_vampiric_blood",  {568406,568184},   {0,100}, true,  true,  true,  nil)
Curate("blood_dk_vampiric_strike", {568406,1279147},  {0,80},  false, true,  true,  DEATH_TAIL)
Curate("blood_dk_death_charge",     {1589472,903900},  {0,80},  true,  true,  true,  DEATH_TAIL)
Curate("blood_dk_death_strike",     {568406},          {0},     false, true,  true,  DEATH_TAIL, true)
Curate("blood_dk_blood_boil",       {1589472},         {0},     false, false, true,  nil,        true)
Curate("blood_dk_marrowrend",       {1279147},         {0},     false, false, false, nil,        true)
Curate("blood_dk_heart_strike",     {1589472},         {0},     false, false, false, nil,        true)
Curate("blood_dk_consumption",      {568406,1279147},  {0,90},  true,  true,  true,  DEATH_TAIL)

-- Frost Death Knight: brittle rune ice, with dragons reserved for the big moments.
Curate("frost_dk_pillar",              {614997,568760},  {0,100}, true,  true,  true,  DEATH_TAIL)
Curate("frost_dk_remorseless_winter",  {614997},         {0},     false, true,  true,  568760)
Curate("frost_dk_breath",              {971536,568177},  {0,100}, true,  true,  true,  614997)
Curate("frost_dk_sindragosa_fury",     {1467221,614997}, {0,120}, false, true,  true,  568760)
Curate("frost_dk_reapers_mark",        {568184,568851},  {0,100}, true,  true,  true,  614997)
Curate("frost_dk_death_charge",        {1589472,903900}, {0,80},  false, true,  true,  DEATH_TAIL)
Curate("frost_dk_obliterate",          {614997},         {0},     false, true,  true,  nil,       true)
Curate("frost_dk_howling_blast",       {614997},         {0},     false, false, true,  nil,       true)
Curate("frost_dk_frost_strike",        {614997},         {0},     false, true,  true,  nil,       true)
Curate("frost_dk_empower_rune_weapon", {568760,614997},  {0,100}, true,  true,  true,  DEATH_TAIL)
Curate("frost_dk_frostwyrm",           {1467221,614997}, {0,120}, false, true,  true,  568760)

-- Unholy Death Knight: necromantic summons and plague, without a cue per coil.
Curate("unholy_dk_apocalypse",          {1472521,3092190},{0,120}, true,  true,  true,  DEATH_TAIL)
Curate("unholy_dk_army",                {3092190,1472521},{0,150}, true,  true,  true,  DEATH_TAIL)
Curate("unholy_dk_dark_transformation", {568406,3092190}, {0,100}, true,  true,  true,  DEATH_TAIL)
Curate("unholy_dk_abomination_limb",    {1589472,1279147},{0,90},  false, true,  true,  DEATH_TAIL)
Curate("unholy_dk_vampiric_strike",     {568406,1279147}, {0,80},  false, true,  true,  DEATH_TAIL)
Curate("unholy_dk_death_charge",        {1589472,903900}, {0,80},  true,  true,  true,  DEATH_TAIL)
Curate("unholy_dk_outbreak",            {1472521},        {0},     false, true,  true,  DEATH_TAIL)
Curate("unholy_dk_soul_reaper",         {1472521,568184}, {0,90},  false, true,  true,  nil)
Curate("unholy_dk_putrefy",             {3092190},        {0},     false, true,  true,  DEATH_TAIL)
Curate("unholy_dk_festering_scythe",    {1472521},        {0},     false, true,  true,  DEATH_TAIL)
Curate("unholy_dk_death_coil",          {568184},         {0},     false, false, false, nil,        true)
Curate("unholy_dk_necrotic_coil",       {568184,1472521}, {0,80},  false, true,  true,  nil,        true)

-- Arms Warrior: mass, stone and decisive steel.  Filler strikes remain untouched.
Curate("arms_avatar",            {620872,4548280},  {0,85},  true,  true,  true,  4556549)
Curate("arms_warbreaker",        {4553587,4555859}, {0,85},  true,  true,  true,  WARRIOR_TAIL)
Curate("arms_demolish",          {4556549,4553587}, {0,115}, true,  true,  true,  WARRIOR_TAIL)
Curate("arms_mortal_strike",     {4553587},         {0},     false, true,  true,  nil,          true)
Curate("arms_execute",           {4555859},         {0},     false, true,  true,  nil,          true)
Curate("arms_overpower",         {4553587},         {0},     false, false, false, nil,          true)
Curate("arms_cleave",            {4553587},         {0},     false, false, false, nil,          true)
Curate("arms_slam",              {4553587},         {0},     false, false, false, nil,          true)
Curate("arms_colossus_smash",    {4553587,4555859}, {0,85},  true,  true,  true,  WARRIOR_TAIL)
Curate("arms_bladestorm",        {4543791,4553587}, {0,90},  true,  true,  true,  WARRIOR_TAIL)

-- Fury Warrior: berserker momentum and storm, never an extra impact on every GCD.
Curate("fury_avatar",              {620872,4548280},  {0,85},  true,  true,  true,  4556549)
Curate("fury_recklessness",        {4556360,4543791}, {0,95},  true,  true,  true,  WARRIOR_TAIL)
Curate("fury_thunderous_roar",     {4543791,1362397}, {0,70},  true,  true,  true,  WARRIOR_TAIL)
Curate("fury_rampage",             {4543791,4556846}, {0,70},  false, true,  true,  nil,          true)
Curate("fury_raging_blow",         {4556846},         {0},     false, false, false, nil,          true)
Curate("fury_bloodthirst",         {4553587},         {0},     false, false, false, nil,          true)
Curate("fury_whirlwind",           {4543791},         {0},     false, false, false, nil,          true)
Curate("fury_execute",             {4555859},         {0},     false, true,  true,  nil,          true)
Curate("fury_bladestorm",          {4543791,4553587}, {0,90},  true,  true,  true,  WARRIOR_TAIL)
Curate("fury_odyns_fury",          {4543791,4553587}, {0,90},  true,  true,  true,  WARRIOR_TAIL)

-- Protection Warrior: grounded defensives and thunder, not rotational noise.
Curate("prot_avatar",              {620872,4548280},  {0,85},  true,  true,  true,  4556549)
Curate("prot_last_stand",          {4556549,4548280}, {0,95},  true,  true,  true,  4553587)
Curate("prot_thunderous_roar",     {4543791,1362397}, {0,70},  true,  true,  true,  WARRIOR_TAIL)
Curate("prot_shield_slam",         {4553587},         {0},     false, true,  true,  nil,          true)
Curate("prot_thunder_clap",        {4543791},         {0},     false, false, false, nil,          true)
Curate("prot_revenge",             {4553587},         {0},     false, false, false, nil,          true)
Curate("prot_ignore_pain",         {4556549},         {0},     false, false, false, nil,          true)
Curate("prot_execute",             {4555859},         {0},     false, true,  true,  nil,          true)
Curate("prot_demoralizing_shout",  {4543791,4556549}, {0,90},  true,  true,  true,  WARRIOR_TAIL)
Curate("prot_shield_charge",       {4553587,4555859}, {0,85},  true,  true,  true,  WARRIOR_TAIL)
