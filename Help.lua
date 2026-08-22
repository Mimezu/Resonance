local _, ns = ...

local UI = ns.UI
local COLORS = UI.COLORS

local TOPICS = {
    {
        title = "Welcome",
        summary = "What it adds",
        body = "Resonance adds optional layers around confirmed spell moments. Blizzard's original spell audio stays unchanged.\n\n|cff35d1bdFLOW|r\nChoose a preset  →  adjust a moment  →  layer sounds  →  save.",
    },
    {
        title = "Start with a preset",
        summary = "Three starting points",
        body = "|cff9d7cffSubtle|r layers signature moments.\n\n|cff9d7cffMedium|r adds character without covering every global cooldown.\n\n|cff9d7cffExpressive|r uses richer, more frequent layers.\n\nEvery control remains editable.",
    },
    {
        title = "Spell moments",
        summary = "Cast, Release, Casting",
        body = "|cff35d1bdCast|r follows a successful spell.\n\n|cff35d1bdRelease|r follows a completed empower.\n\n|cff35d1bdCasting|r begins with a real cast, channel, or empower bar and fades when it ends. Instant spells have no Casting moment.\n\nThe play button previews Resonance layers only.",
    },
    {
        title = "Generic sounds",
        summary = "Shared across your specs",
        body = "The first tab covers common character actions: skyriding, travel, and Recuperate.\n\nOwned Hearthstone toys appear in themed groups. This sound set belongs to your character, so it follows every specialization.",
    },
    {
        title = "Layers & delay",
        summary = "Build a small sound phrase",
        body = "Each enabled row plays one layer.\n\n|cff35d1bd0 ms|r plays immediately. Try |cff35d1bd60–180 ms|r for an echo, impact, or tail.\n\nUse |cff9d7cff+ layer|r for more texture. Extra rows can be removed.",
    },
    {
        title = "Sound library",
        summary = "Find, hear, and favorite",
        body = "Browse a category or search labels, sources, and categories. Click a card to preview it, then choose Okay.\n\nSearch supports |cff35d1bdAND|r, |cff35d1bdOR|r, the vertical bar, and quoted phrases. Favorites stay easy to find. Right-click a swatch to preview its layer.",
    },
    {
        title = "Save & share",
        summary = "Sets belong to a character and tab",
        body = "Your first edit creates a |cff35d1bdPersonal set|r named for your character and realm.\n\nBuilt-in presets are read-only. Editing one moves the change into your Personal set. Choose |cff9d7cffSave changes|r after editing. Switching sets warns before unsaved changes are lost.\n\nExport creates a share code. Import it on the same specialization or Generic tab. RES1 codes remain supported.",
    },
    {
        title = "Safety & limits",
        summary = "What the addon deliberately avoids",
        body = "Resonance reacts only to confirmed player spell events. It does not automate gameplay or track unavailable combat data such as cooldown-ready, proc, or resource-gain events.\n\nIt uses sounds already installed with WoW. Solo added sounds is for auditioning.",
    },
}

function ns:CreateHelpWindow()
    if self.HelpWindow then return end
    local window = CreateFrame("Frame", "ResonanceHelpWindow", UIParent, "BackdropTemplate")
    window:SetSize(760, 555)
    local function FitToScreen()
        local uiWidth, uiHeight = UIParent:GetSize()
        window:SetScale(math.max(0.50, math.min(1, (uiWidth - 30) / 760, (uiHeight - 30) / 555)))
    end
    FitToScreen()
    window:SetPoint("CENTER")
    window:SetFrameStrata("FULLSCREEN_DIALOG")
    window:SetFrameLevel(850)
    window:SetToplevel(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    UI.ApplyBackdrop(window, { 0.035, 0.04, 0.065, 0.99 }, COLORS.accent)
    UI.AddArcaneTrim(window, "window")
    self.HelpWindow = window

    local close = UI.CreateCloseButton(window)
    close:SetPoint("TOPRIGHT", -8, -8)
    local title = UI.CreateText(window, "GameFontNormalHuge", "Help")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetTextColor(unpack(COLORS.accent))
    local subtitle = UI.CreateText(window, "GameFontHighlightSmall", "Quick answers and a short interactive walkthrough.")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetTextColor(unpack(COLORS.muted))

    local drag = CreateFrame("Frame", nil, window)
    drag:SetPoint("TOPLEFT"); drag:SetPoint("TOPRIGHT"); drag:SetHeight(58)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() window:StartMoving() end)
    drag:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)

    local rail = CreateFrame("Frame", nil, window, "BackdropTemplate")
    rail:SetPoint("TOPLEFT", 18, -76)
    rail:SetPoint("BOTTOMLEFT", 18, 62)
    rail:SetWidth(190)
    UI.ApplyBackdrop(rail, { 0.055, 0.06, 0.09, 0.96 }, COLORS.border)
    UI.AddArcaneTrim(rail, "panel")
    window.topicButtons = {}
    for index, topic in ipairs(TOPICS) do
        local button = UI.CreateButton(rail, topic.title, 174, function() window:ShowTopic(index) end)
        button:SetHeight(42)
        button:SetPoint("TOPLEFT", 8, -8 - (index - 1) * 47)
        button:GetFontString():ClearAllPoints()
        button:GetFontString():SetPoint("LEFT", 10, 0)
        button:GetFontString():SetJustifyH("LEFT")
        button:HookScript("OnLeave", function(self)
            if window.topic == index then
                self:SetBackdropColor(0.08, 0.22, 0.20, 1)
                self:SetBackdropBorderColor(unpack(COLORS.teal))
            end
        end)
        window.topicButtons[index] = button
    end

    local content = CreateFrame("Frame", nil, window, "BackdropTemplate")
    content:SetPoint("TOPLEFT", rail, "TOPRIGHT", 12, 0)
    content:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -18, 62)
    UI.ApplyBackdrop(content, { 0.075, 0.075, 0.115, 0.96 }, COLORS.border)
    UI.AddArcaneTrim(content, "section")
    content.title = UI.CreateText(content, "GameFontNormalHuge", "")
    content.title:SetPoint("TOPLEFT", 22, -22)
    content.title:SetTextColor(unpack(COLORS.teal))
    content.summary = UI.CreateText(content, "GameFontHighlight", "")
    content.summary:SetPoint("TOPLEFT", content.title, "BOTTOMLEFT", 0, -6)
    content.summary:SetTextColor(unpack(COLORS.muted))
    content.rule = content:CreateTexture(nil, "ARTWORK")
    content.rule:SetTexture("Interface\\Buttons\\WHITE8X8")
    content.rule:SetPoint("TOPLEFT", content.summary, "BOTTOMLEFT", 0, -14)
    content.rule:SetPoint("RIGHT", content, "RIGHT", -22, 0)
    content.rule:SetHeight(1)
    content.rule:SetVertexColor(unpack(COLORS.border))
    content.body = UI.CreateText(content, "GameFontHighlight", "")
    content.body:SetPoint("TOPLEFT", content.rule, "BOTTOMLEFT", 0, -20)
    content.body:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -22, 22)
    content.body:SetJustifyH("LEFT")
    content.body:SetJustifyV("TOP")
    content.body:SetWordWrap(true)
    content.body:SetSpacing(3)
    content.body:SetTextColor(0.84, 0.85, 0.91, 1)
    window.content = content

    function window:ShowTopic(index)
        self.topic = index
        local topic = TOPICS[index]
        content.title:SetText(topic.title)
        content.summary:SetText(topic.summary)
        content.body:SetText(topic.body)
        for buttonIndex, button in ipairs(self.topicButtons) do
            if buttonIndex == index then
                button:SetBackdropColor(0.08, 0.22, 0.20, 1)
                button:SetBackdropBorderColor(unpack(COLORS.teal))
            else
                button:SetBackdropColor(0.055, 0.06, 0.09, 0.96)
                button:SetBackdropBorderColor(unpack(COLORS.border))
            end
        end
    end

    window.tutorial = UI.CreateButton(window, "Start interactive tutorial", 190, function()
        window:Hide()
        ns:StartTutorial(false)
    end, true)
    window.tutorial:SetPoint("BOTTOMLEFT", 18, 18)
    local restart = UI.CreateButton(window, "Restart tutorial", 125, function()
        window:Hide()
        ns:StartTutorial(true)
    end)
    restart:SetPoint("LEFT", window.tutorial, "RIGHT", 8, 0)
    local done = UI.CreateButton(window, "Close", 90, function() window:Hide() end)
    done:SetPoint("BOTTOMRIGHT", -18, 18)

    window:SetScript("OnShow", function()
        FitToScreen()
        window:Raise()
        local progress = ns.DB and ns.DB.tutorial
        local resumable = ns.Tutorial and ns.Tutorial.active or (progress and tonumber(progress.lastStep) and progress.lastStep > 1)
        window.tutorial:SetText(resumable and "Resume interactive tutorial" or "Start interactive tutorial")
    end)
    window:SetScript("OnHide", function() window:StopMovingOrSizing() end)
    window:ShowTopic(1)
    window:Hide()
    local displayEvents = CreateFrame("Frame")
    displayEvents:RegisterEvent("DISPLAY_SIZE_CHANGED")
    displayEvents:RegisterEvent("UI_SCALE_CHANGED")
    displayEvents:SetScript("OnEvent", function() if window:IsShown() then FitToScreen() end end)
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = window:GetName() end
end

function ns:OpenHelp(topicIndex)
    self:CreateHelpWindow()
    self.HelpWindow:ShowTopic(math.max(1, math.min(#TOPICS, tonumber(topicIndex) or 1)))
    self.HelpWindow:Show()
    self.HelpWindow:Raise()
end

function ns:ToggleHelp(topicIndex)
    self:CreateHelpWindow()
    if self.HelpWindow:IsShown() then
        self.HelpWindow:Hide()
        return
    end
    self:OpenHelp(topicIndex)
end

function ns:CloseHelp()
    if self.HelpWindow then self.HelpWindow:Hide() end
end
