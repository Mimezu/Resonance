local _, ns = ...

local function TrimAndLower(message)
    return strtrim(string.lower(message or ""))
end

function ns:PrintAudit()
    local specID = self.Runtime.specID
    self:Print("v" .. self.VERSION .. " • " .. self:GetCharacterLabel())
    self:Print("Spec: " .. (self.SUPPORTED_SPECS[specID] or "Unsupported"))
    self:Print("Hero tree: " .. (specID and self:GetHeroTreeLabel(specID) or "Not detected"))
    self:Print("Apex: " .. (specID and self:GetApexLabel(specID) or "Not detected"))
    local _, soundSet = self:GetActiveProfile(specID)
    self:Print("Active moments: " .. tostring(#(self.Runtime.activeRules or {})) .. " • Sound set: " .. (soundSet or "Unsaved changes"))
    if specID then
        local compatibility = self:GetProfileCompatibility(specID)
        self:Print(string.format("Compatibility: %d missing sounds • %d retired rules • %d new rules disabled",
            compatibility.missingSounds, compatibility.retiredRules, compatibility.newRules))
        local saved = self:GetSavedSetsCompatibility(specID)
        if saved.affectedSets > 0 then
            self:Print(string.format("Saved sets: %d affected • %d missing sounds • %d retired rules • %d new rules disabled",
                saved.affectedSets, saved.missingSounds, saved.retiredRules, saved.newRules))
        end
    end
end

function ns:HandleCommand(message)
    local command = TrimAndLower(message)
    if command == "" or command == "options" or command == "config" or command == "settings" then
        self:OpenOptions()
    elseif command == "on" then
        self.DB.enabled = true
        self:QueueRefresh("slash on")
        self:Print("Resonance enabled.")
    elseif command == "off" then
        self.DB.enabled = false
        self:QueueRefresh("slash off")
        self:Print("Resonance disabled. Blizzard sounds are unchanged.")
    elseif command == "toggle" then
        self.DB.enabled = not self.DB.enabled
        self:QueueRefresh("slash toggle")
        self:Print(self.DB.enabled and "Resonance enabled." or "Resonance disabled.")
    elseif command == "test" or command == "preview" then
        local rule = self.Runtime.activeRules and self.Runtime.activeRules[1]
        if rule then self:PlayRule(rule, true) else self:OpenSoundPicker(nil, function() end, "arcane") end
    elseif command == "status" or command == "audit" then
        self:PrintAudit()
    elseif command == "minimap" then
        self.DB.minimap.hide = not self.DB.minimap.hide
        self:UpdateMinimapButton()
        self:Print(self.DB.minimap.hide and "Minimap button hidden." or "Minimap button shown.")
    elseif command == "solo" then
        self:SetSoloMode(not self.DB.soloMode)
        if self.RefreshOptions then self:RefreshOptions() end
    elseif command == "refresh" then
        self:QueueRefresh("slash refresh")
        self:Print("Refresh queued.")
    elseif command == "reset" then
        StaticPopup_Show("RESONANCE_RESET_CONFIRM")
    elseif command == "help" then
        self:OpenHelp()
    elseif command == "tutorial" or command == "tour" then
        self:StartTutorial()
    else
        self:Print("/res options • help • tutorial • on • off • toggle • preview • status • solo • minimap • refresh • reset")
    end
end

function ns:RegisterCommands()
    if self.CommandsRegistered then return end
    SLASH_RESONANCE1 = "/resonance"
    SLASH_RESONANCE2 = "/res"
    SlashCmdList.RESONANCE = function(message) ns:HandleCommand(message) end
    self.CommandsRegistered = true
end
