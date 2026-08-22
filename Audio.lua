local _, ns = ...

local function Now()
    local value = GetTimePreciseSec and GetTimePreciseSec() or GetTime()
    if ns:IsSafeValue(value) and type(value) == "number" then
        return value
    end
    return 0
end

-- Rule labels are informational only, but diagnostics must never make a
-- sound path fail. Some generated/legacy rules intentionally omit `name`.
local function RuleLabel(rule)
    if type(rule) ~= "table" then
        return "Unknown rule"
    end
    if type(rule.name) == "string" and rule.name ~= "" then
        return rule.name
    end
    if type(rule.spell) == "string" and rule.spell ~= "" then
        if type(rule.moment) == "string" and rule.moment ~= "" then
            return rule.spell .. " · " .. rule.moment
        end
        return rule.spell
    end
    if type(rule.id) == "string" and rule.id ~= "" then
        return rule.id
    end
    return "Unknown rule"
end

local function SoundDebugLabel(sound)
    if type(sound) ~= "table" then
        return "unknown sound"
    end
    if type(sound.key) == "string" and sound.key ~= "" then
        return sound.key
    end
    if type(sound.label) == "string" and sound.label ~= "" then
        return sound.label
    end
    if type(sound.id) == "number" then
        return tostring(sound.id)
    end
    return "unknown sound"
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

function ns:ResolveRuleSounds(rule)
    local cache = self.Runtime and self.Runtime.resolvedSoundCache
    local cached = cache and cache[rule]
    if cached then return cached end

    local sounds, labels = {}, {}
    for index = 1, self:GetRuleLayerCount(rule) do
        local layer = self:GetLayerConfig(rule, index)
        local sound = type(layer.soundID) == "number" and self.SoundByID[layer.soundID]
        if layer.enabled and sound then
            sounds[#sounds + 1] = {
                id = layer.soundID,
                key = self:GetSoundLabel(layer.soundID),
                delay = (layer.delayMs or 0) / 1000,
                kind = sound.kind or "file",
            }
            labels[#labels + 1] = sounds[#sounds].key
        end
    end
    sounds.label = table.concat(labels, " + ")
    if cache then cache[rule] = sounds end
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

local CASTING_FADE_OUT_SECONDS = 0.08

local function TrackTimer(registry, timer)
    if registry and timer then registry[timer] = true end
end

local function UntrackTimer(registry, timer)
    if registry and timer then registry[timer] = nil end
end

function ns:CancelDelayedSoundTimers()
    local runtime = self.Runtime
    runtime.delayedSoundGeneration = (runtime.delayedSoundGeneration or 0) + 1
    for timer in pairs(runtime.delayedSoundTimers or {}) do
        if timer and timer.Cancel then pcall(timer.Cancel, timer) end
    end
    wipe(runtime.delayedSoundTimers)
end

function ns:StopCastingSounds(fadeSeconds)
    local runtime = self.Runtime
    runtime.castingSoundGeneration = (runtime.castingSoundGeneration or 0) + 1
    runtime.castingCastGUID = nil
    runtime.castingSpellID = nil

    for _, timer in ipairs(runtime.castingSoundTimers or {}) do
        if timer and timer.Cancel then
            pcall(timer.Cancel, timer)
        end
    end
    wipe(runtime.castingSoundTimers)

    for _, handle in ipairs(runtime.castingSoundHandles or {}) do
        if handle and StopSound then
            pcall(StopSound, handle, fadeSeconds or CASTING_FADE_OUT_SECONDS)
        end
    end
    wipe(runtime.castingSoundHandles)
end

local function TrackCastingHandle(handle)
    if not handle then return end
    ns.Runtime.castingSoundHandles = ns.Runtime.castingSoundHandles or {}
    ns.Runtime.castingSoundHandles[#ns.Runtime.castingSoundHandles + 1] = handle
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

    local ruleLabel = RuleLabel(rule)
    local sounds = self:ResolveRuleSounds(rule)
    if #sounds == 0 then
        return false, "unresolved sound"
    end

    local channel = self:GetPlaybackChannel()
    local trackCasting = not preview and rule.event == "CASTING_START"
    local castingGeneration
    local previewTimers = preview and (self.Runtime.previewTimers or {}) or nil
    local previewGeneration
    if preview then
        self.Runtime.previewTimers = previewTimers
        self.Runtime.previewGeneration = self.Runtime.previewGeneration or 0
        previewGeneration = self.Runtime.previewGeneration
    end
    if trackCasting then
        self:StopCastingSounds(CASTING_FADE_OUT_SECONDS)
        castingGeneration = self.Runtime.castingSoundGeneration
    end
    local soundLabel = type(sounds.label) == "string" and sounds.label or ""
    local played = false
    for _, sound in ipairs(sounds) do
        local delay = math.max(0, sound.delay or 0)
        if delay > 0 then
            played = true
            local queuedSound = sound
            if trackCasting then
                local timer = C_Timer.NewTimer(delay, function()
                    if ns.Runtime.castingSoundGeneration ~= castingGeneration then return end
                    local accepted, handle = PlayResolvedSound(queuedSound, channel)
                    if accepted then TrackCastingHandle(handle) end
                    if ns.DB and ns.DB.debug then
                        ns:Print((accepted and "Played " or "Skipped ") .. ruleLabel
                            .. " delayed layer [" .. SoundDebugLabel(queuedSound) .. "]")
                    end
                end)
                self.Runtime.castingSoundTimers[#self.Runtime.castingSoundTimers + 1] = timer
            elseif preview then
                local timer
                timer = C_Timer.NewTimer(delay, function()
                    UntrackTimer(previewTimers, timer)
                    if self.Runtime.previewGeneration ~= previewGeneration then return end
                    local accepted, handle = PlayResolvedSound(queuedSound, channel)
                    if accepted and handle then
                        self.Runtime.previewHandles = self.Runtime.previewHandles or {}
                        self.Runtime.previewHandles[#self.Runtime.previewHandles + 1] = handle
                    end
                end)
                TrackTimer(previewTimers, timer)
            else
                local generation = self.Runtime.delayedSoundGeneration or 0
                local timer
                timer = C_Timer.NewTimer(delay, function()
                    UntrackTimer(self.Runtime.delayedSoundTimers, timer)
                    if self.Runtime.delayedSoundGeneration ~= generation then return end
                    local accepted = PlayResolvedSound(queuedSound, channel)
                    if ns.DB and ns.DB.debug then
                        ns:Print((accepted and "Played " or "Skipped ") .. ruleLabel
                            .. " delayed layer [" .. SoundDebugLabel(queuedSound) .. "]")
                    end
                end)
                TrackTimer(self.Runtime.delayedSoundTimers, timer)
            end
        else
            local accepted, handle = PlayResolvedSound(sound, channel)
            if trackCasting and accepted then TrackCastingHandle(handle) end
            if preview and accepted and handle then
                self.Runtime.previewHandles = self.Runtime.previewHandles or {}
                self.Runtime.previewHandles[#self.Runtime.previewHandles + 1] = handle
            end
            played = accepted or played
        end
    end
    if played and not preview then
        self.Runtime.lastRulePlay[rule.id] = now
    end

    if self.DB.debug then
        self:Print((played and "Played " or "Skipped ") .. ruleLabel .. " [" .. soundLabel .. "]")
    end
    return played == true, soundLabel, trackCasting
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
