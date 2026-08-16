local _, ns = ...

local function Now()
    local value = GetTimePreciseSec and GetTimePreciseSec() or GetTime()
    if ns:IsSafeValue(value) and type(value) == "number" then
        return value
    end
    return 0
end

function ns:GetRuleCue(rule)
    local cue = rule.cue
    local specID = self.Runtime.specID

    -- Hero trees color the same important gameplay moment instead of adding spammy extra events.
    if specID == 62 and rule.id == "arcane_surge" and self:HasCapability("spellslinger") then
        cue = "frost"
    elseif specID == 62 and rule.id == "arcane_surge" and self:HasCapability("sunfury") then
        cue = "apex"
    elseif specID == 64 and rule.id == "frost_ray" and self:HasCapability("handOfFrost") then
        cue = "apex"
    elseif specID == 64 and rule.id == "frost_ray" and self:HasCapability("frostfire") then
        cue = "release"
    elseif specID == 1467 and rule.id == "dev_fire_breath" and self:HasCapability("flameshaper") then
        cue = "draconic"
    elseif specID == 1467 and rule.id == "dev_disintegrate" and self:HasCapability("scalecommander") then
        cue = "major"
    elseif specID == 1468 and rule.id == "pres_temporal_anomaly" and self:HasCapability("chronowarden") then
        cue = "bronze"
    elseif specID == 1468 and rule.id == "pres_dream_breath" and self:HasCapability("flameshaper") then
        cue = "draconic"
    end

    return cue
end

function ns:ResolveSound(cue, paletteName)
    local palette = self.SoundPalettes[paletteName or self.DB.palette] or self.SoundPalettes.subtle
    local candidates = palette[cue] or palette.proc
    for _, key in ipairs(candidates or {}) do
        local soundKitID = SOUNDKIT and SOUNDKIT[key]
        if type(soundKitID) == "number" then
            return soundKitID, key
        end
    end
    local fallback = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    if type(fallback) == "number" then
        return fallback, "IG_MAINMENU_OPTION_CHECKBOX_ON"
    end
    return nil, nil
end

local TONE_CUES = {
    soft = "proc",
    bright = "ready",
    impact = "major",
    apex = "apex",
}

function ns:ResolveRuleSounds(rule)
    local sounds = {}
    for index = 1, self:GetRuleLayerCount(rule) do
        local layer = self:GetLayerConfig(rule, index)
        if layer.enabled and type(layer.soundID) == "number" then
            sounds[#sounds + 1] = {
                id = layer.soundID,
                key = self:GetSoundLabel(layer.soundID),
                delay = (layer.delayMs or 0) / 1000,
                kind = self.SoundByID[layer.soundID] and self.SoundByID[layer.soundID].kind or "file",
            }
        end
    end
    return sounds
end

local function PlayResolvedSound(sound, channel)
    local accepted, handle
    if sound.kind == "kit" then
        accepted, handle = PlaySound(sound.id, channel, true)
    else
        accepted, handle = PlaySoundFile(sound.id, channel)
    end
    if accepted == nil then accepted = true end
    return accepted == true, handle
end

function ns:PlayRule(rule, preview)
    if not self.DB.enabled and not preview then
        return false, "disabled"
    end

    local now = Now()
    if not preview then
        local lastRule = self.Runtime.lastRulePlay[rule.id] or 0
        if now - lastRule < rule.cooldown then
            return false, "rule throttle"
        end
    end

    local sounds = self:ResolveRuleSounds(rule)
    if #sounds == 0 then
        return false, "unresolved sound"
    end

    local soundKeys = {}
    local channel = self:GetPlaybackChannel()
    for _, sound in ipairs(sounds) do
        soundKeys[#soundKeys + 1] = sound.key
    end
    local played = false
    for _, sound in ipairs(sounds) do
        local delay = math.max(0, sound.delay or 0)
        if delay > 0 then
            played = true
            local queuedSound = sound
            C_Timer.After(delay, function()
                local accepted = PlayResolvedSound(queuedSound, channel)
                if ns.DB and ns.DB.debug then
                    ns:Print((accepted and "Played " or "Skipped ") .. rule.name .. " delayed layer [" .. queuedSound.key .. "]")
                end
            end)
        else
            played = PlayResolvedSound(sound, channel) or played
        end
    end
    if played and not preview then
        self.Runtime.lastRulePlay[rule.id] = now
    end

    if self.DB.debug then
        self:Print((played and "Played " or "Skipped ") .. rule.name .. " [" .. table.concat(soundKeys, " + ") .. "]")
    end
    return played == true, table.concat(soundKeys, " + ")
end

function ns:PreviewCue(cue)
    local soundKitID, soundKey = self:ResolveSound(cue)
    if not soundKitID then
        self:Print("No built-in sound is available for that cue.")
        return false
    end
    local played = PlaySound(soundKitID, self:GetPlaybackChannel(), true)
    if played == nil then
        played = true
    end
    if not played then
        self:Print("WoW did not play the preview. Check the game SFX setting.")
    end
    return played, soundKey
end
