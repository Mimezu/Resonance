local _, ns = ...

-- Shared character moments. These use confirmed player spell routes only.
-- Hearthstone toys are an explicit, maintained catalogue: Retail has no safe
-- API for asking the Toy Box to return only its teleport toys, and changing
-- the Toy Box filters would interfere with the player's Collections UI.
ns.AdditionalSpecRules = ns.AdditionalSpecRules or {}

local HEARTHSTONE_TOYS = {
    -- The physical Hearthstone and the Innkeeper's Daughter.
    { family = "home", itemID = 6948, spellID = 8690, item = true, name = "Hearthstone" },
    { family = "home", itemID = 64488, spellID = 94719, name = "The Innkeeper's Daughter" },

    -- Portal / engineered variants.
    { family = "arcane", itemID = 54452, spellID = 75136, name = "Ethereal Portal" },
    { family = "arcane", itemID = 93672, spellID = 136508, name = "Dark Portal" },
    { family = "arcane", itemID = 168907, spellID = 298068, name = "Holographic Digitalization Hearthstone" },
    { family = "arcane", itemID = 235016, spellID = 1217281, name = "Redeployment Module" },
    { family = "arcane", itemID = 245970, spellID = 1240219, name = "P.O.S.T. Master's Express Hearthstone" },
    { family = "arcane", itemID = 140192, spellID = 222695, name = "Dalaran Hearthstone" },

    -- Seasonal and holiday variants.
    { family = "festival", itemID = 162973, spellID = 278244, name = "Greatfather Winter's Hearthstone" },
    { family = "festival", itemID = 163045, spellID = 278559, name = "Headless Horseman's Hearthstone" },
    { family = "festival", itemID = 165669, spellID = 285362, name = "Lunar Elder's Hearthstone" },
    { family = "festival", itemID = 165670, spellID = 285424, name = "Peddlefeet's Lovely Hearthstone" },
    { family = "festival", itemID = 165802, spellID = 286031, name = "Noble Gardener's Hearthstone" },
    { family = "festival", itemID = 166746, spellID = 286331, name = "Fire Eater's Hearthstone" },
    { family = "festival", itemID = 166747, spellID = 286353, name = "Brewfest Reveler's Hearthstone" },
    { family = "festival", itemID = 209035, spellID = 422284, name = "Hearthstone of the Flame" },
    { family = "festival", itemID = 236687, spellID = 1220729, name = "Explosive Hearthstone" },

    -- First Ones, Broker, Timewalking, and cosmic travel.
    { family = "cosmic", itemID = 172179, spellID = 308742, name = "Eternal Traveler's Hearthstone" },
    { family = "cosmic", itemID = 190196, spellID = 366945, name = "Enlightened Hearthstone" },
    { family = "cosmic", itemID = 190237, spellID = 367013, name = "Broker Translocation Matrix" },
    { family = "cosmic", itemID = 193588, spellID = 375357, name = "Timewalker's Hearthstone" },
    { family = "cosmic", itemID = 246565, spellID = 1242509, name = "Cosmic Hearthstone" },

    -- Light and Naaru variants, including the Kyrian toy.
    { family = "light", itemID = 184353, spellID = 345393, name = "Kyrian Hearthstone" },
    { family = "light", itemID = 206195, spellID = 412555, name = "Path of the Naaru" },
    { family = "light", itemID = 210455, spellID = 438606, name = "Draenic Hologem" },
    { family = "light", itemID = 257736, spellID = 1261979, name = "Lightcalled Hearthstone" },
    { family = "light", itemID = 263489, spellID = 1270583, name = "Naaru's Enfold" },
    { family = "light", itemID = 276371, spellID = 1299515, name = "Lightveil Recall Beacon" },

    -- Fae, dragonflight, and living-spore travel.
    { family = "nature", itemID = 180290, spellID = 326064, name = "Night Fae Hearthstone" },
    { family = "nature", itemID = 200630, spellID = 391042, name = "Ohn'ir Windsage's Hearthstone" },
    { family = "nature", itemID = 264367, spellID = 1299014, name = "Mycomancer's Hearthspore" },

    -- Venthyr, Necrolord, and void/shadow variants.
    { family = "shadow", itemID = 183716, spellID = 342122, name = "Venthyr Sinstone" },
    { family = "shadow", itemID = 182773, spellID = 340200, name = "Necrolord Hearthstone" },
    { family = "shadow", itemID = 188952, spellID = 363799, name = "Dominated Hearthstone" },
    { family = "shadow", itemID = 228940, spellID = 463481, name = "Notorious Thread's Hearthstone" },
    { family = "shadow", itemID = 263933, spellID = 1270814, name = "Preyseeker's Hearthstone" },

    -- Grounded elemental variants.
    { family = "earth", itemID = 110560, spellID = 171253, name = "Garrison Hearthstone" },
    { family = "earth", itemID = 208704, spellID = 420418, name = "Deepdweller's Earth Hearthstone" },
    { family = "earth", itemID = 212337, spellID = 401802, name = "Stone of the Hearth" },
    { family = "earth", itemID = 265100, spellID = 1273401, name = "Corewarden's Hearthstone" },
}

ns.HearthstoneToyCatalog = HEARTHSTONE_TOYS

local function SafeBoolean(value)
    return ns:IsSafeValue(value) and value == true
end

local function OwnedHearthstone(entry)
    if entry.item then
        local getCount = C_Item and C_Item.GetItemCount or GetItemCount
        if type(getCount) ~= "function" then return false end
        local ok, count = pcall(getCount, entry.itemID, false, true)
        return ok and ns:IsSafeValue(count) and type(count) == "number" and count > 0
    end

    if type(PlayerHasToy) ~= "function" then return false end
    local ok, owned = pcall(PlayerHasToy, entry.itemID)
    if not ok or not SafeBoolean(owned) then return false end
    if C_ToyBox and type(C_ToyBox.IsToyUsable) == "function" then
        local usableOK, usable = pcall(C_ToyBox.IsToyUsable, entry.itemID)
        if usableOK and ns:IsSafeValue(usable) and usable == false then return false end
    end
    return true
end

local function ResolveCurrentItemSpell(entry)
    local getItemSpell = C_Item and C_Item.GetItemSpell or GetItemSpell
    if type(getItemSpell) ~= "function" then return entry.spellID end
    local ok, _, spellID = pcall(getItemSpell, entry.itemID)
    if ok and ns:IsSafeValue(spellID) and type(spellID) == "number" and spellID > 0 then
        return spellID
    end
    return entry.spellID
end

-- Cache each owned toy's resolved item spell. The cards retain stable item-ID
-- rule IDs while a changed item spell can still be routed after a client patch.
function ns:RefreshHearthstoneAvailability()
    local toys, signatureParts = {}, {}
    for _, entry in ipairs(HEARTHSTONE_TOYS) do
        if OwnedHearthstone(entry) then
            local spellID = ResolveCurrentItemSpell(entry)
            if type(spellID) == "number" and spellID > 0 then
                toys[entry.itemID] = { spellID }
                signatureParts[#signatureParts + 1] = entry.itemID .. ":" .. spellID
            end
        end
    end
    table.sort(signatureParts)
    local signature = table.concat(signatureParts, "|")
    local changed = self.Runtime.hearthstoneAvailabilitySignature ~= signature
    self.Runtime.hearthstoneAvailabilitySignature = signature
    self.Runtime.hearthstoneSpellIDsByItemID = toys
    return changed
end

function ns:IsRuleAvailable(rule)
    if not rule or not rule.hearthstoneItemID then return true end
    local toys = self.Runtime.hearthstoneSpellIDsByItemID
    if not toys then
        self:RefreshHearthstoneAvailability()
        toys = self.Runtime.hearthstoneSpellIDsByItemID
    end
    return type(toys) == "table" and type(toys[rule.hearthstoneItemID]) == "table" and #toys[rule.hearthstoneItemID] > 0
end

function ns:GetRuntimeSpellIDs(rule)
    if rule and rule.hearthstoneItemID then
        local toys = self.Runtime.hearthstoneSpellIDsByItemID
        return toys and toys[rule.hearthstoneItemID] or {}
    end
    return rule and rule.spellIDs or {}
end

local LEGACY_FAMILY_RULES = {
    home = "generic_hearthstone", arcane = "generic_hearth_arcane",
    festival = "generic_hearth_festival", cosmic = "generic_hearth_cosmic",
    light = "generic_hearth_light", nature = "generic_hearth_nature",
    shadow = "generic_hearth_shadow", earth = "generic_hearth_earth",
}
ns.HearthstoneGroupRuleExpansions = ns.HearthstoneGroupRuleExpansions or {}

local function HearthstoneRule(entry)
    local id = "generic_hearth_item_" .. entry.itemID
    local description = "Your owned " .. entry.name .. "."
    local cue = entry.family == "light" and "holy" or entry.family == "shadow" and "shadow" or entry.family == "earth" and "earth" or entry.family == "nature" and "nature" or entry.family == "festival" and "fire" or entry.family == "cosmic" and "void" or "arcane"
    return {
        id = id,
        spec = 0,
        spell = entry.name,
        name = entry.name,
        moment = "Cast",
        event = "SUCCEEDED",
        -- Used for the stable card icon. Runtime routing always uses owned,
        -- resolved spell IDs instead of this representative fallback.
        spellIDs = { entry.spellID },
        hearthstoneItemID = entry.itemID,
        cue = cue,
        preset = "subtle",
        cooldown = 2.0,
        defaultOn = true,
        defaultSounds = {},
        noGeneratedCasting = true,
        description = description,
    }
end

-- Every hearthstone toy has a long, visible cast bar.  Keep that moment
-- explicit instead of relying on automatic cast-bar detection: a family's
-- live spell IDs are resolved from its owned toys at runtime, while the
-- representative icon spell is only a stable card icon.
local function HearthstoneCastingRule(entry)
    local id = "generic_hearth_item_" .. entry.itemID
    local cue = entry.family == "light" and "holy" or entry.family == "shadow" and "shadow" or entry.family == "earth" and "earth" or entry.family == "nature" and "nature" or entry.family == "festival" and "fire" or entry.family == "cosmic" and "void" or "arcane"
    return {
        id = id .. "_casting",
        spec = 0,
        spell = entry.name,
        name = entry.name .. " casting",
        moment = "Casting",
        event = "CASTING_START",
        spellIDs = { entry.spellID },
        hearthstoneItemID = entry.itemID,
        cue = cue,
        preset = "subtle",
        cooldown = 1.0,
        defaultOn = true,
        defaultSounds = {},
        noGeneratedCasting = true,
        description = "Plays once when " .. entry.name .. " begins casting.",
    }
end

local rules = {
    -- Skyriding
    { id="generic_surge_forward", spec=0, spell="Surge Forward", name="Surge Forward", moment="Cast", event="SUCCEEDED", spellIDs={372608,376743}, cue="whoosh", preset="medium", cooldown=0.8, defaultOn=true, defaultSounds={5453442}, defaultDelays={0}, description="A short stereo flick under the forward burst." },
    { id="generic_skyward_ascent", spec=0, spell="Skyward Ascent", name="Skyward Ascent", moment="Cast", event="SUCCEEDED", spellIDs={372610,386451,376744}, cue="arcane", preset="subtle", cooldown=0.8, defaultOn=true, defaultSounds={5520041}, defaultDelays={0}, description="A clean arcane lift for the climb." },
    { id="generic_whirling_surge", spec=0, spell="Whirling Surge", name="Whirling Surge", moment="Cast", event="SUCCEEDED", spellIDs={361584}, cue="air", preset="medium", cooldown=0.8, defaultOn=true, defaultSounds={1378203}, defaultDelays={0}, description="A focused Windlord accent for the turn." },
    { id="generic_aerial_halt", spec=0, spell="Aerial Halt", name="Aerial Halt", moment="Cast", event="SUCCEEDED", spellIDs={403092}, cue="bronze", preset="expressive", cooldown=0.8, defaultOn=false, defaultSounds={5013972}, defaultDelays={0}, description="A compact chronal punctuation for an aerial stop." },

    { id="generic_arcantina", spec=0, spell="Key to the Arcantina", name="Key to the Arcantina", moment="Cast", event="SUCCEEDED", spellIDs={1255801}, cue="arcane", preset="subtle", cooldown=2.0, defaultOn=true, defaultSounds={4558583}, defaultDelays={0}, description="Teleport to the Arcantina." },

    -- Rest
    { id="generic_recuperate", spec=0, spell="Recuperate", name="Recuperate", moment="Casting", event="CASTING_START", spellIDs={1231418}, cue="nature", preset="subtle", cooldown=1.0, defaultOn=true, defaultSounds={1661243}, defaultDelays={0}, description="Campfire meal and recovery." },
}

-- One stable card per usable toy/item. Every card contains an explicit
-- Casting moment for its long channel and a Cast moment for its completion.
for _, entry in ipairs(HEARTHSTONE_TOYS) do
    local baseID = "generic_hearth_item_" .. entry.itemID
    local legacyID = LEGACY_FAMILY_RULES[entry.family]
    ns.HearthstoneGroupRuleExpansions[legacyID] = ns.HearthstoneGroupRuleExpansions[legacyID] or {}
    ns.HearthstoneGroupRuleExpansions[legacyID][#ns.HearthstoneGroupRuleExpansions[legacyID] + 1] = baseID
    rules[#rules + 1] = HearthstoneRule(entry)
    rules[#rules + 1] = HearthstoneCastingRule(entry)
end

for _, rule in ipairs(rules) do
    ns.AdditionalSpecRules[#ns.AdditionalSpecRules + 1] = rule
end
