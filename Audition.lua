local _, ns = ...

local MANAGED_CVARS = {
    "Sound_EnableSFX",
    "Sound_EnableMusic",
    "Sound_EnableAmbience",
    "Sound_EnableDialog",
}

local function ReadCVar(name)
    local getter = C_CVar and C_CVar.GetCVar or GetCVar
    if type(getter) ~= "function" then return nil end
    local ok, value = pcall(getter, name)
    if not ok or ns:IsSecret(value) or value == nil then return nil end
    return tostring(value)
end

local function WriteCVar(name, value)
    local setter = C_CVar and C_CVar.SetCVar or SetCVar
    if type(setter) ~= "function" or value == nil then return false end
    return pcall(setter, name, tostring(value))
end

function ns:GetPlaybackChannel()
    return self.DB.soloMode and "Dialog" or self.DB.channel
end

function ns:EnableSoloMode()
    if self.DB.soloMode then return end

    local restore = {}
    for _, name in ipairs(MANAGED_CVARS) do
        restore[name] = ReadCVar(name)
    end
    self.DB.soloRestore = restore
    self.DB.soloMode = true

    WriteCVar("Sound_EnableSFX", 0)
    WriteCVar("Sound_EnableMusic", 0)
    WriteCVar("Sound_EnableAmbience", 0)
    WriteCVar("Sound_EnableDialog", 1)
    self:Print("solo audition enabled; Resonance is routed to Dialog.")
end

function ns:DisableSoloMode(silent)
    local restore = type(self.DB.soloRestore) == "table" and self.DB.soloRestore or nil
    if restore then
        for _, name in ipairs(MANAGED_CVARS) do
            WriteCVar(name, restore[name])
        end
    end
    self.DB.soloMode = false
    self.DB.soloRestore = nil
    if not silent then
        self:Print("solo audition disabled; previous sound settings restored.")
    end
end

function ns:SetSoloMode(enabled)
    if enabled then
        self:EnableSoloMode()
    else
        self:DisableSoloMode(false)
    end
end

function ns:RecoverSoloMode()
    if self.DB.soloMode or type(self.DB.soloRestore) == "table" then
        self:DisableSoloMode(true)
    end
end
