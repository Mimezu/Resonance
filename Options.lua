local _, ns = ...

local COLORS = {
    panel = { 0.035, 0.04, 0.065, 0.98 },
    card = { 0.075, 0.075, 0.115, 0.96 },
    cardAlt = { 0.055, 0.06, 0.09, 0.96 },
    border = { 0.30, 0.22, 0.48, 0.85 },
    accent = { 0.61, 0.46, 1.0, 1 },
    teal = { 0.15, 0.82, 0.74, 1 },
    muted = { 0.62, 0.64, 0.72, 1 },
}

local WHITE = "Interface\\Buttons\\WHITE8X8"

-- The catalog editor is deliberately tucked away for the 1.14 release.
-- Keep both the SavedVariables and implementation intact: switching this
-- flag back on restores a tester's existing draft instead of losing it.
local DEBUG_SOUND_TOOLS_VISIBLE = false

local function IsSoundSortingDebugActive()
    return DEBUG_SOUND_TOOLS_VISIBLE and ns.DB and ns.DB.soundSortDebug == true
end

local PurpleButtonFont = CreateFont("ResonancePurpleButtonFont")
PurpleButtonFont:CopyFontObject(GameFontNormal)
PurpleButtonFont:SetTextColor(0.61, 0.46, 1.0, 1)
local WhiteButtonFont = CreateFont("ResonanceWhiteButtonFont")
WhiteButtonFont:CopyFontObject(GameFontNormal)
WhiteButtonFont:SetTextColor(1, 1, 1, 1)
local MutedButtonFont = CreateFont("ResonanceMutedButtonFont")
MutedButtonFont:CopyFontObject(GameFontNormal)
MutedButtonFont:SetTextColor(0.62, 0.64, 0.72, 1)

local function ApplyBackdrop(frame, color, border)
    frame:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(color))
    frame:SetBackdropBorderColor(unpack(border or COLORS.border))
end

-- Borders have one owner: the frame's Backdrop. Earlier decorative strips
-- overlapped the ScrollFrame and left visually open corners at large scales.
-- Keep this shared hook intentionally quiet so existing callers retain a
-- single, clean perimeter without stacked artwork.
local function AddArcaneTrim(frame, style)
    if not frame or frame._resonanceArcaneTrim then return end
    frame._resonanceArcaneTrim = true
end

-- Replace UIPanelScrollFrameTemplate's large arrows and Blizzard artwork with
-- a compact Resonance track. The wider transparent hit target keeps the slim
-- visual easy to grab, while wheel, track-click and thumb dragging all remain
-- available.
local function SkinScrollFrame(scroll)
    if not scroll or scroll._resonanceScrollBar then return end

    local blizzardBar = scroll.ScrollBar or scroll.scrollBar
    if not blizzardBar and scroll.GetName and scroll:GetName() then
        blizzardBar = _G[scroll:GetName() .. "ScrollBar"]
    end
    if blizzardBar then
        blizzardBar:SetAlpha(0)
        blizzardBar:EnableMouse(false)
        blizzardBar:Hide()
    end

    scroll:EnableMouseWheel(true)
    if scroll.SetClipsChildren then scroll:SetClipsChildren(true) end

    local track = CreateFrame("Button", nil, scroll:GetParent(), "BackdropTemplate")
    track:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 5, 0)
    track:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 5, 0)
    track:SetWidth(10)
    track:SetFrameLevel(scroll:GetFrameLevel() + 8)
    track:EnableMouse(true)
    ApplyBackdrop(track, { 0.025, 0.03, 0.05, 0.28 }, { 0, 0, 0, 0 })

    local rail = track:CreateTexture(nil, "BACKGROUND")
    rail:SetTexture("Interface\\Buttons\\WHITE8X8")
    rail:SetVertexColor(0.30, 0.22, 0.48, 0.42)
    rail:SetPoint("TOP", 0, -3)
    rail:SetPoint("BOTTOM", 0, 3)
    rail:SetWidth(2)

    local thumb = CreateFrame("Button", nil, track, "BackdropTemplate")
    thumb:SetWidth(6)
    thumb:SetHeight(34)
    thumb:SetPoint("TOP", track, "TOP", 0, -2)
    thumb:SetFrameLevel(track:GetFrameLevel() + 1)
    thumb:EnableMouse(true)
    thumb:RegisterForDrag("LeftButton")
    ApplyBackdrop(thumb, { 0.61, 0.46, 1.0, 0.88 }, { 0.72, 0.60, 1.0, 1 })

    local dragging = false
    local dragStartY, dragStartScroll

    local function GetRange()
        local range = scroll.GetVerticalScrollRange and scroll:GetVerticalScrollRange() or 0
        return math.max(0, tonumber(range) or 0)
    end

    local function UpdateThumb()
        local maxScroll = GetRange()
        local trackHeight = math.max(1, track:GetHeight() - 4)
        if maxScroll <= 0 or trackHeight <= 1 then
            track:Hide()
            return
        end
        track:Show()
        local visibleHeight = math.max(1, scroll:GetHeight())
        local thumbHeight = math.max(28, trackHeight * visibleHeight / (visibleHeight + maxScroll))
        thumbHeight = math.min(trackHeight, thumbHeight)
        thumb:SetHeight(thumbHeight)
        local travel = math.max(0, trackHeight - thumbHeight)
        local ratio = math.max(0, math.min(1, (tonumber(scroll:GetVerticalScroll()) or 0) / maxScroll))
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -2 - ratio * travel)
    end

    local function StopDrag()
        if not dragging then return end
        dragging = false
        thumb:SetScript("OnUpdate", nil)
        thumb:SetBackdropColor(0.61, 0.46, 1.0, 0.88)
        thumb:SetBackdropBorderColor(0.72, 0.60, 1.0, 1)
    end

    local function BeginDrag()
        local _, cursorY = GetCursorPosition()
        local scale = math.max(0.001, scroll:GetEffectiveScale())
        dragging = true
        dragStartY = cursorY / scale
        dragStartScroll = tonumber(scroll:GetVerticalScroll()) or 0
        thumb:SetBackdropColor(unpack(COLORS.teal))
        thumb:SetBackdropBorderColor(unpack(COLORS.teal))
        thumb:SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then
                StopDrag()
                return
            end
            local maxScroll = GetRange()
            local travel = math.max(1, track:GetHeight() - 4 - thumb:GetHeight())
            local _, currentY = GetCursorPosition()
            local delta = dragStartY - currentY / math.max(0.001, scroll:GetEffectiveScale())
            scroll:SetVerticalScroll(math.max(0, math.min(maxScroll, dragStartScroll + delta / travel * maxScroll)))
            UpdateThumb()
        end)
    end

    thumb:SetScript("OnEnter", function(self)
        if not dragging then
            self:SetBackdropColor(0.15, 0.82, 0.74, 0.88)
            self:SetBackdropBorderColor(unpack(COLORS.teal))
        end
    end)
    thumb:SetScript("OnLeave", function(self)
        if not dragging then
            self:SetBackdropColor(0.61, 0.46, 1.0, 0.88)
            self:SetBackdropBorderColor(0.72, 0.60, 1.0, 1)
        end
    end)
    thumb:SetScript("OnDragStart", BeginDrag)
    thumb:SetScript("OnDragStop", StopDrag)
    thumb:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then BeginDrag() end end)
    thumb:SetScript("OnMouseUp", StopDrag)

    track:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        local maxScroll = GetRange()
        local scale = math.max(0.001, track:GetEffectiveScale())
        local _, cursorY = GetCursorPosition()
        local offset = (track:GetTop() or 0) - cursorY / scale - thumb:GetHeight() * 0.5
        local travel = math.max(1, track:GetHeight() - 4 - thumb:GetHeight())
        scroll:SetVerticalScroll(math.max(0, math.min(maxScroll, offset / travel * maxScroll)))
        UpdateThumb()
        BeginDrag()
    end)
    track:SetScript("OnMouseUp", StopDrag)

    scroll:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = GetRange()
        local nextScroll = (tonumber(self:GetVerticalScroll()) or 0) - delta * 54
        self:SetVerticalScroll(math.max(0, math.min(maxScroll, nextScroll)))
        UpdateThumb()
    end)
    scroll:HookScript("OnVerticalScroll", UpdateThumb)
    scroll:HookScript("OnScrollRangeChanged", UpdateThumb)
    scroll:HookScript("OnSizeChanged", UpdateThumb)
    scroll:HookScript("OnShow", function() C_Timer.After(0, UpdateThumb) end)

    scroll._resonanceScrollBar = track
    scroll._resonanceUpdateScrollBar = UpdateThumb
    C_Timer.After(0, UpdateThumb)
end

local function CreateText(parent, template, text)
    local label = parent:CreateFontString(nil, "ARTWORK", template)
    label:SetText(text)
    if template and template:find("GameFontNormal", 1, true) then
        label:SetTextColor(unpack(COLORS.accent))
    end
    return label
end

local function CreateDrawnStar(parent)
    local star = CreateFrame("Frame", nil, parent)
    star:SetSize(12, 12)
    local points = {}
    for index = 1, 10 do
        local angle = math.rad(-90 + (index - 1) * 36)
        local radius = index % 2 == 1 and 5 or 2.25
        points[index] = { math.cos(angle) * radius, math.sin(angle) * radius }
    end
    for index = 1, 10 do
        local nextIndex = index == 10 and 1 or index + 1
        local line = star:CreateLine(nil, "ARTWORK")
        line:SetThickness(1.25)
        line:SetColorTexture(unpack(COLORS.accent))
        line:SetStartPoint("CENTER", star, points[index][1], points[index][2])
        line:SetEndPoint("CENTER", star, points[nextIndex][1], points[nextIndex][2])
    end
    return star
end

local function RegisterOptionWidget(widget)
    widget._resSpecID = ns._BuildingSpecID
    ns.OptionWidgets[#ns.OptionWidgets + 1] = widget
    return widget
end

local function ParseSearchExpression(query)
    query = string.lower(query or "")
    local tokens, index, length = {}, 1, #query
    while index <= length do
        while index <= length and string.match(string.sub(query, index, index), "%s") do index = index + 1 end
        if index > length then break end
        if string.sub(query, index, index) == '"' then
            local closing = string.find(query, '"', index + 1, true)
            local value
            if closing then
                value = string.sub(query, index + 1, closing - 1)
                index = closing + 1
            else
                value = string.sub(query, index + 1)
                index = length + 1
            end
            if value ~= "" then tokens[#tokens + 1] = { value = value, quoted = true } end
        else
            local ending = string.find(query, "%s", index)
            local value = ending and string.sub(query, index, ending - 1) or string.sub(query, index)
            index = ending and ending + 1 or length + 1
            if value ~= "" then tokens[#tokens + 1] = { value = value } end
        end
    end

    local groups, group = {}, {}
    for _, token in ipairs(tokens) do
        local value = token.value
        if not token.quoted and (value == "or" or value == "|" or value == "||") then
            if #group > 0 then groups[#groups + 1] = group end
            group = {}
        elseif token.quoted or (value ~= "and" and value ~= "&" and value ~= "&&") then
            group[#group + 1] = value
        end
    end
    if #group > 0 then groups[#groups + 1] = group end
    return groups
end

local function MatchesSearchExpression(haystack, groups)
    for _, group in ipairs(groups) do
        local matches = true
        for _, term in ipairs(group) do
            if not string.find(haystack, term, 1, true) then
                matches = false
                break
            end
        end
        if matches then return true end
    end
    return false
end

local function GetCategoryDisplayName(categoryID)
    for _, category in ipairs(ns.SoundCategories or {}) do
        if category.id == categoryID then return category.label end
    end
    return categoryID or "Uncategorized"
end

local function AddTooltip(frame, title, body)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, unpack(COLORS.accent))
        GameTooltip:AddLine(body, COLORS.accent[1], COLORS.accent[2], COLORS.accent[3], true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", GameTooltip_Hide)
end

-- Shared with PriorityFader/Frame Gambit: a compact, texture-free close
-- control that keeps our addon windows visually consistent.
local function CreateCloseButton(parent, callback)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(24, 24)
    button:SetFrameLevel(parent:GetFrameLevel() + 20)
    ApplyBackdrop(button, COLORS.cardAlt, COLORS.border)

    local strokes = {}
    for index, angle in ipairs({ math.pi / 4, -math.pi / 4 }) do
        local stroke = button:CreateTexture(nil, "ARTWORK")
        stroke:SetTexture("Interface\\Buttons\\WHITE8X8")
        stroke:SetSize(2, 13)
        stroke:SetPoint("CENTER")
        stroke:SetRotation(angle)
        stroke:SetVertexColor(unpack(COLORS.accent))
        strokes[index] = stroke
    end

    local function Tint(color)
        for _, stroke in ipairs(strokes) do
            stroke:SetVertexColor(unpack(color))
        end
    end

    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.05, 0.18, 0.17, 1)
        self:SetBackdropBorderColor(unpack(COLORS.teal))
        Tint(COLORS.teal)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Close", unpack(COLORS.accent))
        GameTooltip:AddLine("Close this window.", COLORS.accent[1], COLORS.accent[2], COLORS.accent[3], true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(COLORS.cardAlt))
        self:SetBackdropBorderColor(unpack(COLORS.border))
        Tint(COLORS.accent)
        GameTooltip_Hide()
    end)
    button:SetScript("OnClick", callback or function() parent:Hide() end)
    return button
end

local function StyleButton(button, accent)
    local font = accent and WhiteButtonFont or PurpleButtonFont
    button:SetNormalFontObject(font)
    button:SetHighlightFontObject(font)
    button:SetDisabledFontObject(MutedButtonFont)
    local color = accent and COLORS.accent or COLORS.cardAlt
    ApplyBackdrop(button, color, COLORS.border)
    if button:GetFontString() then
        button:GetFontString():SetTextColor(unpack(accent and {1, 1, 1, 1} or COLORS.accent))
    end
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(accent and 0.72 or 0.12, accent and 0.57 or 0.12, accent and 1.0 or 0.18, 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(color))
    end)
end

local function CreateModernCheck(parent, size)
    local check = CreateFrame("Button", nil, parent, "BackdropTemplate")
    size = size or 20
    check:SetSize(size, size)
    check.checked = false
    ApplyBackdrop(check, {0.035, 0.05, 0.07, 1}, {0.10, 0.48, 0.45, 1})
    -- Draw a crisp X from two teal strokes. WoW's bundled fonts do not reliably
    -- contain checkmark glyphs and can render them as hollow rectangles.
    check.markA = check:CreateTexture(nil, "OVERLAY")
    check.markA:SetTexture("Interface\\Buttons\\WHITE8X8")
    check.markA:SetVertexColor(unpack(COLORS.teal))
    check.markA:SetSize(2, math.max(9, size * 0.58))
    check.markA:SetPoint("CENTER", 0, 0)
    check.markA:SetRotation(-math.pi / 4)
    check.markB = check:CreateTexture(nil, "OVERLAY")
    check.markB:SetTexture("Interface\\Buttons\\WHITE8X8")
    check.markB:SetVertexColor(unpack(COLORS.teal))
    check.markB:SetSize(2, math.max(9, size * 0.58))
    check.markB:SetPoint("CENTER", 0, 0)
    check.markB:SetRotation(math.pi / 4)
    function check:SetChecked(value)
        self.checked = value == true
        self.markA:SetShown(self.checked)
        self.markB:SetShown(self.checked)
        self:SetBackdropColor(self.checked and 0.04 or 0.035, self.checked and 0.20 or 0.05, self.checked and 0.18 or 0.07, 1)
        self:SetBackdropBorderColor(self.checked and COLORS.teal[1] or 0.10, self.checked and COLORS.teal[2] or 0.48, self.checked and COLORS.teal[3] or 0.45, 1)
    end
    function check:GetChecked() return self.checked end
    check:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then self:SetChecked(not self:GetChecked()) end
    end)
    check:SetChecked(false)
    return check
end

local function CreateButton(parent, text, width, callback, accent)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 110, 22)
    local label = button:CreateFontString(nil, "ARTWORK")
    label:SetPoint("CENTER")
    button:SetFontString(label)
    button:SetText(text)
    button:SetScript("OnClick", callback)
    StyleButton(button, accent)
    return button
end

local function CreateSection(parent, title, subtitle, height)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetHeight(height)
    ApplyBackdrop(frame, COLORS.card)
    AddArcaneTrim(frame, "section")

    local titleText
    if title and title ~= "" then
        titleText = CreateText(frame, "GameFontNormalLarge", title)
        titleText:SetPoint("TOPLEFT", 14, -11)
        titleText:SetTextColor(unpack(COLORS.teal))
    end

    if subtitle and subtitle ~= "" and titleText then
        local subtitleText = CreateText(frame, "GameFontHighlightSmall", subtitle)
        subtitleText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -3)
        subtitleText:SetPoint("RIGHT", frame, -18, 0)
        subtitleText:SetJustifyH("LEFT")
        subtitleText:SetTextColor(unpack(COLORS.muted))
    end
    return frame
end

-- Small UI toolkit shared by the standalone Help Center and tutorial. Keeping
-- these primitives here guarantees every Resonance window uses one visual
-- language without copying styling code between modules.
ns.UI = {
    COLORS = COLORS,
    ApplyBackdrop = ApplyBackdrop,
    SkinScrollFrame = SkinScrollFrame,
    CreateText = CreateText,
    CreateButton = CreateButton,
    CreateCloseButton = CreateCloseButton,
    CreateSection = CreateSection,
    AddArcaneTrim = AddArcaneTrim,
}

local function CreateCheckRow(parent, label, description, getter, setter)
    local row = CreateFrame("Frame", nil, parent)
    local hasDescription = description and description ~= ""
    row:SetSize(350, hasDescription and 40 or 26)
    local check = CreateModernCheck(row, 19)
    check:SetPoint("LEFT", 0, 0)
    row.label = CreateText(row, "GameFontNormal", label)
    row.label:SetPoint("LEFT", check, "RIGHT", 10, hasDescription and 7 or 0)
    row.description = CreateText(row, "GameFontHighlightSmall", description or "")
    row.description:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -2)
    row.description:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.description:SetJustifyH("LEFT")
    row.description:SetWordWrap(true)
    if row.description.SetMaxLines then row.description:SetMaxLines(2) end
    row.description:SetTextColor(unpack(COLORS.muted)); row.description:SetShown(hasDescription)
    check.getter = getter
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() == true)
    end)
    AddTooltip(check, label, description or "")
    RegisterOptionWidget(check)
    return row
end

-- Release controls use a compact horizontal settings band rather than the
-- vertical form rhythm used elsewhere. This keeps their top baselines aligned
-- and avoids scattering one-off positioning rules through BuildGeneral.
local function CreateSettingsBandToggle(parent, label, description, getter, setter)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(300, 42)

    local check = CreateModernCheck(row, 19)
    check:SetPoint("TOPLEFT", 0, 0)

    local title = CreateText(row, "GameFontNormal", label)
    title:SetPoint("TOPLEFT", check, "TOPRIGHT", 10, 2)

    if description and description ~= "" then
        local detail = CreateText(row, "GameFontHighlightSmall", description)
        detail:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
        detail:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        detail:SetJustifyH("LEFT")
        detail:SetWordWrap(true)
        if detail.SetMaxLines then detail:SetMaxLines(2) end
        detail:SetTextColor(unpack(COLORS.muted))
    end

    check.getter = getter
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() == true)
    end)
    AddTooltip(check, label, description or "")
    RegisterOptionWidget(check)
    return row
end

local function CreateCycle(parent, label, values, getter, setter, width)
    width = width or 230
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, 50)
    local title = CreateText(frame, "GameFontNormal", label)
    title:SetPoint("TOPLEFT", 0, 0)
    local button = CreateButton(frame, "", width, function(self)
        local current = getter()
        local index = 1
        for i, entry in ipairs(values) do
            if entry.value == current then index = i break end
        end
        index = index % #values + 1
        setter(values[index].value)
        self:SetText(values[index].label .. "  |cff9d7cff›|r")
    end)
    button:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    button.refresh = function(self)
        local current = getter()
        for _, entry in ipairs(values) do
            if entry.value == current then
                self:SetText(entry.label .. "  |cff9d7cff›|r")
                return
            end
        end
    end
    RegisterOptionWidget(button)
    return frame
end

-- The public settings band uses the same behavior as a regular cycle, but
-- presents it as one compact action instead of a label-and-field stack.
local function CreateCompactCycle(parent, values, getter, setter, width)
    local button = CreateButton(parent, "", width, function(self)
        local current = getter()
        local index = 1
        for i, entry in ipairs(values) do
            if entry.value == current then index = i break end
        end
        index = index % #values + 1
        setter(values[index].value)
        self:refresh()
    end)
    button.refresh = function(self)
        local current = getter()
        for _, entry in ipairs(values) do
            if entry.value == current then
                self:SetText(entry.label .. "  |cff9d7cff›|r")
                return
            end
        end
    end
    RegisterOptionWidget(button)
    return button
end

local function CreateEditBox(parent, width)
    local box = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    box:SetSize(width or 48, 20)
    box:SetAutoFocus(false)
    box:SetNumeric(true)
    box:SetMaxLetters(4)
    box:SetFontObject("GameFontHighlightSmall")
    box:SetJustifyH("LEFT")
    box:SetTextInsets(7, 5, 0, 0)
    ApplyBackdrop(box, COLORS.panel, COLORS.border)
    box:SetScript("OnTextChanged", function(self, userInput)
        if not userInput or self._normalizingNumericText then return end
        local raw = self:GetText() or ""
        local normalized = raw:gsub("%D", ""):sub(1, 4)
        if normalized ~= raw then
            self._normalizingNumericText = true
            self:SetText(normalized)
            self:SetCursorPosition(#normalized)
            self._normalizingNumericText = nil
        end
    end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return box
end

local function ShortSoundLabel(fileID, preservedLabel)
    return ns:GetSoundLabel(fileID, preservedLabel)
end

function ns:CreateSoundPicker()
    if self.SoundPicker then return end
    local picker = CreateFrame("Frame", "ResonanceSoundPicker", UIParent, "BackdropTemplate")
    picker:SetSize(760, 580)
    picker:SetPoint("CENTER")
    picker:SetFrameStrata("TOOLTIP")
    picker:SetFrameLevel(900)
    picker:SetToplevel(true)
    picker:SetMovable(true)
    picker:SetClampedToScreen(true)
    picker:EnableMouse(true)
    ApplyBackdrop(picker, COLORS.panel, COLORS.accent)
    AddArcaneTrim(picker, "window")
    self.SoundPicker = picker
    picker.selectedIDs = {}
    picker:SetScript("OnHide", function()
        picker:StopMovingOrSizing()
        picker.dragging = false
        picker.dropCategory = nil
        if picker.dragBadge then picker.dragBadge:Hide() end
        ns:StopPreviewSound()
        if ns.TutorialSignal then ns:TutorialSignal("sound-picker-closed") end
    end)

    local dragBadge = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    dragBadge:SetSize(190, 34)
    dragBadge:SetFrameStrata("TOOLTIP")
    dragBadge:SetFrameLevel(1100)
    dragBadge:EnableMouse(false)
    ApplyBackdrop(dragBadge, {0.04, 0.12, 0.11, 0.96}, COLORS.teal)
    dragBadge.label = CreateText(dragBadge, "GameFontNormalSmall", "")
    dragBadge.label:SetPoint("LEFT", 10, 0)
    dragBadge.label:SetPoint("RIGHT", -10, 0)
    dragBadge.label:SetJustifyH("LEFT")
    dragBadge:SetScript("OnUpdate", function(self)
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / scale + 14, y / scale + 12)
    end)
    dragBadge:Hide()
    picker.dragBadge = dragBadge

    local close = CreateCloseButton(picker)
    close:SetPoint("TOPRIGHT", -4, -4)
    local title = CreateText(picker, "GameFontNormalHuge", "Sound picker")
    title:SetPoint("TOPLEFT", 18, -14)
    title:SetTextColor(unpack(COLORS.accent))
    local help = CreateText(picker, "GameFontHighlightSmall", "Choose a sound family or search every source, then click a swatch to hear it. Nothing is committed until OK.")
    help:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7)
    help:SetPoint("RIGHT", picker, "RIGHT", -20, 0)
    help:SetJustifyH("LEFT")
    help:SetWordWrap(false)
    help:SetTextColor(unpack(COLORS.muted))
    picker.help = help
    local drag = CreateFrame("Frame", nil, picker)
    drag:SetPoint("TOPLEFT"); drag:SetPoint("TOPRIGHT"); drag:SetHeight(54)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() picker:StartMoving() end)
    drag:SetScript("OnDragStop", function() picker:StopMovingOrSizing() end)

    local categoryPane = CreateFrame("Frame", nil, picker, "BackdropTemplate")
    categoryPane:SetPoint("TOPLEFT", 14, -66); categoryPane:SetPoint("BOTTOMLEFT", 14, 54); categoryPane:SetWidth(148)
    ApplyBackdrop(categoryPane, COLORS.cardAlt)
    AddArcaneTrim(categoryPane, "panel")
    picker.categoryPane = categoryPane
    local categoryScroll = CreateFrame("ScrollFrame", nil, categoryPane, "UIPanelScrollFrameTemplate")
    categoryScroll:SetPoint("TOPLEFT", 5, -5)
    categoryScroll:SetPoint("BOTTOMRIGHT", -24, 5)
    local categoryContent = CreateFrame("Frame", nil, categoryScroll)
    categoryContent:SetSize(114, math.max(1, #self.SoundCategories * 25 + 8))
    categoryScroll:SetScrollChild(categoryContent)
    SkinScrollFrame(categoryScroll)
    picker.categoryScroll = categoryScroll
    picker.categoryButtons = {}
    for index, category in ipairs(self.SoundCategories) do
        local button = CreateButton(categoryContent, category.label, 112, function()
            picker.category = category.id
            if picker.soundScroll then picker.soundScroll:SetVerticalScroll(0) end
            if picker.search and picker.search:GetText() ~= "" then
                picker.search:SetText("")
                picker.search:ClearFocus()
            else
                picker:RefreshSounds()
            end
        end)
        button:SetHeight(22)
        button:SetPoint("TOPLEFT", 1, -2 - (index - 1) * 25)
        button.categoryID = category.id
        button.categoryColor = category.color
        button:HookScript("OnEnter", function(self)
            if picker.dragging and self.categoryID ~= "favorites" then
                picker.dropCategory = self.categoryID
                if picker.RefreshCategoryButtons then picker:RefreshCategoryButtons() end
            end
        end)
        button:HookScript("OnLeave", function(self)
            if picker.dragging and picker.dropCategory == self.categoryID then
                picker.dropCategory = nil
                if picker.RefreshCategoryButtons then picker:RefreshCategoryButtons() end
            end
        end)
        button:SetScript("OnReceiveDrag", function(self)
            if picker.dragging and self.categoryID ~= "favorites" then
                picker:FinishSoundDrag(self.categoryID)
            end
        end)
        picker.categoryButtons[#picker.categoryButtons + 1] = button
    end


    function picker:RefreshCategoryButtons()
        for _, button in ipairs(self.categoryButtons) do
            local isDropTarget = self.dragging and self.dropCategory == button.categoryID
            if isDropTarget then
                button:SetBackdropColor(0.06, 0.28, 0.24, 1)
                button:SetBackdropBorderColor(unpack(COLORS.teal))
            elseif button.categoryID == self.category then
                button:SetBackdropColor(button.categoryColor[1]*0.35, button.categoryColor[2]*0.35, button.categoryColor[3]*0.35, 1)
                button:SetBackdropBorderColor(unpack(COLORS.border))
            else
                button:SetBackdropColor(unpack(COLORS.cardAlt))
                button:SetBackdropBorderColor(unpack(COLORS.border))
            end
        end
    end

    local search = CreateFrame("EditBox", nil, picker, "BackdropTemplate")
    search:SetPoint("TOPLEFT", categoryPane, "TOPRIGHT", 10, 0)
    search:SetPoint("RIGHT", picker, "RIGHT", -28, 0)
    search:SetHeight(24)
    search:SetAutoFocus(false)
    search:SetFontObject("GameFontHighlightSmall")
    search:SetTextInsets(9, 9, 0, 0)
    ApplyBackdrop(search, COLORS.cardAlt, COLORS.border)
    local searchHint = CreateText(search, "GameFontHighlightSmall", "Search sounds · use AND, OR, |, or quoted phrases")
    searchHint:SetPoint("LEFT", 9, 0)
    searchHint:SetTextColor(unpack(COLORS.muted))
    search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
    search:SetScript("OnTextChanged", function(self)
        searchHint:SetShown(self:GetText() == "")
        if picker.RefreshSounds and picker:IsShown() then picker:RefreshSounds() end
    end)
    AddTooltip(search, "Boolean sound search", "Spaces and AND require every term. OR or | accepts either term. Put exact phrases in quotes, for example: dawn AND spark, or \"Dawn of the Infinite\" OR bronze.")
    picker.search = search

    local scroll = CreateFrame("ScrollFrame", nil, picker, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -8)
    scroll:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -28, 54)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(552, 430)
    scroll:SetScrollChild(content)
    SkinScrollFrame(scroll)
    picker.soundScroll = scroll
    picker.soundContent = content
    picker.soundButtons = {}

    function picker:GetSelectedSoundIDs(includePending)
        local result = {}
        for soundID, selected in pairs(self.selectedIDs or {}) do
            if selected and ns.SoundByID[soundID] then result[#result + 1] = soundID end
        end
        if #result == 0 and includePending and self.pendingID and ns.SoundByID[self.pendingID] then
            result[1] = self.pendingID
        end
        table.sort(result)
        return result
    end

    function picker:SelectOnly(soundID)
        wipe(self.selectedIDs)
        if soundID then self.selectedIDs[soundID] = true end
        self.pendingID = soundID
    end

    function picker:BeginSoundDrag(button)
        if not IsSoundSortingDebugActive() or not button.sound then return end
        if not self.selectedIDs[button.sound.id] then self:SelectOnly(button.sound.id) end
        self.dragIDs = self:GetSelectedSoundIDs(true)
        if #self.dragIDs == 0 then return end
        self.dragging = true
        self.dropCategory = nil
        self.dragBadge.label:SetText(#self.dragIDs == 1 and button.sound.label or (#self.dragIDs .. " sounds selected"))
        self.dragBadge:Show()
        self:RefreshCategoryButtons()
        self:RefreshSounds()
    end

    function picker:FinishSoundDrag(categoryID)
        if not self.dragging then return end
        local dragged = self.dragIDs or {}
        self.dragging = false
        self.dropCategory = nil
        self.dragBadge:Hide()
        if categoryID and categoryID ~= "favorites" then
            for _, soundID in ipairs(dragged) do ns:MoveSoundToCategory(soundID, categoryID) end
        end
        self.dragIDs = nil
        self:RefreshSounds()
        ns:RefreshOptions()
    end

    function picker:AcquireSoundButton(index)
        if self.soundButtons[index] then return self.soundButtons[index] end
        local button = CreateFrame("Button", nil, content, "BackdropTemplate")
        button:SetSize(174, 58)
        local col = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        button:SetPoint("TOPLEFT", col * 182, -row * 64)
        ApplyBackdrop(button, COLORS.cardAlt, {0.16,0.17,0.24,1})
        button.label = CreateText(button, "GameFontNormal", "")
        button.label:SetPoint("TOPLEFT", 9, -8); button.label:SetPoint("RIGHT", -8, 0); button.label:SetJustifyH("LEFT")
        button.label:SetWordWrap(false)
        if button.label.SetMaxLines then button.label:SetMaxLines(1) end
        button.detail = CreateText(button, "GameFontHighlightSmall", "")
        button.detail:SetPoint("TOPLEFT", button.label, "BOTTOMLEFT", 0, -3); button.detail:SetPoint("RIGHT", -23, 0); button.detail:SetJustifyH("LEFT")
        button.detail:SetWordWrap(true)
        if button.detail.SetMaxLines then button.detail:SetMaxLines(2) end
        button.detail:SetTextColor(unpack(COLORS.muted))
        button.category = CreateText(button, "GameFontDisableSmall", "")
        button.category:SetPoint("BOTTOMLEFT", 9, 4)
        button.category:SetPoint("RIGHT", -23, 0)
        button.category:SetJustifyH("LEFT")
        button.category:SetTextColor(unpack(COLORS.teal))
        button.category:Hide()
        button.favoriteStar = CreateDrawnStar(button)
        button.favoriteStar:SetPoint("BOTTOMRIGHT", -6, 4)
        button.favoriteStar:Hide()
        button.deleteOverlay = button:CreateTexture(nil, "BACKGROUND", nil, 1)
        button.deleteOverlay:SetAllPoints()
        button.deleteOverlay:SetColorTexture(0.72, 0.04, 0.08, 0.34)
        button.deleteOverlay:Hide()
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnDragStart", function(self) picker:BeginSoundDrag(self) end)
        button:SetScript("OnDragStop", function()
            if picker.dragging then picker:FinishSoundDrag(picker.dropCategory) end
        end)
        button:SetScript("OnClick", function(self)
            if not self.sound then return end
            if IsSoundSortingDebugActive() then
                if IsControlKeyDown and IsControlKeyDown() then
                    picker.selectedIDs[self.sound.id] = not picker.selectedIDs[self.sound.id] or nil
                    if picker.selectedIDs[self.sound.id] then
                        picker.pendingID = self.sound.id
                    elseif picker.pendingID == self.sound.id then
                        local remaining = picker:GetSelectedSoundIDs(false)
                        picker.pendingID = remaining[1]
                    end
                else
                    picker:SelectOnly(self.sound.id)
                end
            else
                picker.pendingID = self.sound.id
            end
            ns:PreviewSoundFile(self.sound.id)
            if ns.TutorialSignal then ns:TutorialSignal("sound-auditioned", self.sound.id) end
            picker:RefreshSounds()
        end)
        self.soundButtons[index] = button
        return button
    end

    function picker:RefreshSounds()
        local source = {}
        local query = string.lower((self.search and self.search:GetText()) or "")
        if query ~= "" then
            local searchGroups = ParseSearchExpression(query)
            local seen = {}
            for _, sound in ipairs(ns.SoundCatalog) do
                local haystack = sound.searchText or string.lower((sound.label or "") .. " " .. (sound.detail or ""))
                if not seen[sound.id] and MatchesSearchExpression(haystack, searchGroups) then
                    seen[sound.id] = true
                    source[#source+1] = sound
                end
            end
            table.sort(source, function(a,b) return a.label < b.label end)
        elseif self.category == "favorites" then
            for fileID, favorite in pairs(ns.DB.favorites) do
                if favorite and ns.SoundByID[fileID] then source[#source+1] = ns.SoundByID[fileID] end
            end
            table.sort(source, function(a,b) return a.label < b.label end)
        else
            source = ns:GetSoundsForCategory(self.category)
        end
        for i = 1, math.max(#source, #self.soundButtons) do
            local button = self:AcquireSoundButton(i)
            local sound = source[i]
            button.sound = sound
            if sound then
                local marked = ns:IsSoundMarkedForDelete(sound.id)
                local selected = IsSoundSortingDebugActive() and self.selectedIDs[sound.id] == true
                local moved = ns.DB.categoryDraft[sound.id] ~= nil
                local color = marked and "|cffffa0aa" or (selected and "|cff35d1bd" or "|cff9d7cff")
                button.label:SetText(color .. sound.label .. "|r")
                button.detail:SetText(sound.detail or "WoW spell sound")
                if button.detail.SetMaxLines then button.detail:SetMaxLines(query ~= "" and 1 or 2) end
                button.category:SetText(GetCategoryDisplayName(ns:GetEffectiveSoundCategory(sound)))
                button.category:SetShown(query ~= "")
                button.favoriteStar:SetShown(ns.DB.favorites[sound.id] == true)
                button.deleteOverlay:SetShown(marked)
                if selected then
                    button:SetBackdropBorderColor(unpack(COLORS.teal))
                elseif moved then
                    button:SetBackdropBorderColor(0.96, 0.66, 0.16, 1)
                elseif not IsSoundSortingDebugActive() and self.pendingID == sound.id then
                    button:SetBackdropBorderColor(unpack(COLORS.teal))
                else
                    button:SetBackdropBorderColor(0.16, 0.17, 0.24, 1)
                end
                button:Show()
            else
                button.category:Hide()
                button.favoriteStar:Hide()
                button.deleteOverlay:Hide()
                button:Hide()
            end
        end
        self.soundContent:SetHeight(math.max(430, math.ceil(#source / 3) * 64))
        self:RefreshCategoryButtons()
        self.selection:SetText(self.pendingID and ns:GetSoundLabel(self.pendingID) or "No sound selected")
        self.favorite:SetText(self.pendingID and ns.DB.favorites[self.pendingID] and "Unfavorite" or "Favorite")
        local selectedIDs = self:GetSelectedSoundIDs(not IsSoundSortingDebugActive())
        local allMarked = #selectedIDs > 0
        for _, soundID in ipairs(selectedIDs) do
            if not ns:IsSoundMarkedForDelete(soundID) then allMarked = false break end
        end
        self.deleteMark:SetText(allMarked and ("Undelete selected (" .. #selectedIDs .. ")") or ("Mark selected for delete (" .. #selectedIDs .. ")"))
        self.deleteMark:SetShown(IsSoundSortingDebugActive() and #selectedIDs > 0)
        self.selection:SetShown(not IsSoundSortingDebugActive())
        self.help:SetText(IsSoundSortingDebugActive()
            and "Sorting: click • Ctrl-click multi • drag to category • green selected • gold moved • red delete • save in main footer."
            or "Choose a sound family or search every source, then click a swatch to hear it. Nothing is committed until OK.")
    end

    function picker:ScrollCategoryIntoView(categoryID)
        if not categoryID or not self.categoryScroll then return end
        local categoryIndex
        for index, button in ipairs(self.categoryButtons or {}) do
            if button.categoryID == categoryID then
                categoryIndex = index
                break
            end
        end
        if not categoryIndex then return end
        local viewport = math.max(1, self.categoryScroll:GetHeight())
        local itemCenter = (categoryIndex - 1) * 25 + 13
        local maxScroll = math.max(0, tonumber(self.categoryScroll:GetVerticalScrollRange()) or 0)
        self.categoryScroll:SetVerticalScroll(math.max(0, math.min(maxScroll, itemCenter - viewport * 0.5)))
        if self.categoryScroll._resonanceUpdateScrollBar then
            self.categoryScroll._resonanceUpdateScrollBar()
        end
    end

    function picker:ScrollToSound(soundID)
        if not soundID or not self.soundScroll then
            if self.soundScroll then self.soundScroll:SetVerticalScroll(0) end
            return
        end
        local soundIndex
        for index, button in ipairs(self.soundButtons or {}) do
            if button:IsShown() and button.sound and button.sound.id == soundID then
                soundIndex = index
                break
            end
        end
        if not soundIndex then return end
        local row = math.floor((soundIndex - 1) / 3)
        local cardCenter = row * 64 + 29
        local viewport = math.max(1, self.soundScroll:GetHeight())
        local maxScroll = math.max(0, tonumber(self.soundScroll:GetVerticalScrollRange()) or 0)
        self.soundScroll:SetVerticalScroll(math.max(0, math.min(maxScroll, cardCenter - viewport * 0.5)))
        if self.soundScroll._resonanceUpdateScrollBar then
            self.soundScroll._resonanceUpdateScrollBar()
        end
    end

    picker.selection = CreateText(picker, "GameFontHighlight", "")
    picker.selection:SetPoint("BOTTOMLEFT", picker, "BOTTOMLEFT", 286, 21)
    picker.favorite = CreateButton(picker, "Favorite", 92, function()
        if picker.pendingID then
            ns.DB.favorites[picker.pendingID] = not ns.DB.favorites[picker.pendingID] or nil
            picker:RefreshSounds()
        end
    end)
    picker.favorite:SetPoint("BOTTOMRIGHT", -197, 16)
    picker.deleteMark = CreateButton(picker, "Mark for delete", 126, function()
        local selectedIDs = picker:GetSelectedSoundIDs(false)
        local allMarked = #selectedIDs > 0
        for _, soundID in ipairs(selectedIDs) do
            if not ns:IsSoundMarkedForDelete(soundID) then allMarked = false break end
        end
        for _, soundID in ipairs(selectedIDs) do ns:SetSoundMarkedForDelete(soundID, not allMarked) end
        picker:RefreshSounds()
        ns:RefreshOptions()
    end)
    picker.deleteMark:SetWidth(176)
    picker.deleteMark:SetPoint("BOTTOMLEFT", 14, 16)
    local cancel = CreateButton(picker, CANCEL, 86, function() picker:Hide() end)
    cancel:SetPoint("BOTTOMRIGHT", -105, 16)
    local okay = CreateButton(picker, OKAY, 86, function()
        if ns.TutorialCanCommitSound and not ns:TutorialCanCommitSound(picker.pendingID) then return end
        if picker.callback then picker.callback(picker.pendingID) end
        if ns.TutorialSignal then ns:TutorialSignal("sound-committed", picker.pendingID) end
        picker:Hide()
    end, true)
    okay:SetPoint("BOTTOMRIGHT", -14, 16)
    picker.cancel = cancel
    picker.okay = okay
    picker:Hide()
end

local MOMENT_CELL_WIDTH = 344
local MOMENT_CELL_GAP = 8
-- Keep the spell editor as two visual levels: one list frame, then the
-- identity rail and moment panels. These values deliberately do not reuse
-- the horizontal moment gap.
local SPELL_ROW_GAP = 4
-- The list starts just below the specialization controls: close enough to
-- read as one section, with a fixed 4px clearance after the toggle.
local SPELL_LIST_TOP = 62
local SPELL_LIST_INSET = 4
-- Keep the spell identity rail deliberately narrow: its job is to identify
-- the spell, while the editor needs the horizontal space for sound layers.
local MOMENT_CONTENT_LEFT = 114
local SOUND_SWATCH_WIDTH = 218
local DELAY_FIELD_WIDTH = 50
local MOMENT_LAYER_HEIGHT = 26

local function GetMomentCellHeight(rule)
    return 102 + math.max(0, ns:GetRuleLayerCount(rule) - 2) * MOMENT_LAYER_HEIGHT
end

local function GetMomentColumns(cardWidth, momentCount)
    local available = math.max(MOMENT_CELL_WIDTH, (tonumber(cardWidth) or 0) - MOMENT_CONTENT_LEFT - 12)
    -- Keep moment cards at a consistent readable width. A third moment wraps
    -- beneath the first pair instead of squeezing all three into narrow cards.
    return math.max(1, math.min(2, momentCount, math.floor((available + MOMENT_CELL_GAP) / (MOMENT_CELL_WIDTH + MOMENT_CELL_GAP))))
end

local function GetSpellCardLayout(spellRules, columns)
    columns = math.max(1, tonumber(columns) or 1)
    local rowHeights = {}
    for index, rule in ipairs(spellRules) do
        local row = math.floor((index - 1) / columns) + 1
        rowHeights[row] = math.max(rowHeights[row] or 0, GetMomentCellHeight(rule))
    end
    local height = 0
    for row, rowHeight in ipairs(rowHeights) do
        height = height + rowHeight
        if row < #rowHeights then height = height + SPELL_ROW_GAP end
    end
    return math.max(80, height), rowHeights
end

local function CreateMomentCell(parent, rule, cellHeight)
    local cell = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    cell:SetSize(MOMENT_CELL_WIDTH, cellHeight)
    if cell.SetClipsChildren then cell:SetClipsChildren(true) end
    ApplyBackdrop(cell, COLORS.panel, { 0.12, 0.13, 0.19, 1 })
    AddArcaneTrim(cell, "moment")
    cell.rule = rule
    cell.layerChecks = {}
    cell.swatches = {}
    cell.delays = {}
    cell.removeButtons = {}

    local enabled = CreateModernCheck(cell, 16)
    enabled:SetSize(19, 19); enabled:SetPoint("TOPLEFT", 4, -3)
    local function RefreshMomentAppearance(value)
        cell:SetAlpha(value and 1 or 0.38)
    end
    enabled:SetScript("OnClick", function(self)
        RefreshMomentAppearance(self:GetChecked() == true)
        ns:SetRuleEnabled(rule.id, self:GetChecked() == true)
    end)
    enabled.getter = function() return ns:GetRuleEnabled(rule) end
    RegisterOptionWidget(enabled)
    RegisterOptionWidget({refresh=function()
        RefreshMomentAppearance(ns:GetRuleEnabled(rule))
    end})
    cell.enabled = enabled

    local title = CreateText(cell, "GameFontNormalSmall", rule.moment)
    title:SetPoint("TOPLEFT", enabled, "TOPRIGHT", 5, -1)
    title:SetPoint("RIGHT", cell, "RIGHT", -34, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    title:SetTextColor(unpack(COLORS.teal))

    local hearAdded = CreateButton(cell, "", 23, function()
        ns:PlayRule(rule, true)
        if ns.TutorialSignal then ns:TutorialSignal("moment-previewed", rule.id) end
    end, true)
    hearAdded:SetPoint("TOPRIGHT", -4, -3)
    hearAdded:SetBackdropColor(0.42, 0.27, 0.04, 1)
    hearAdded:SetBackdropBorderColor(0.96, 0.66, 0.16, 0.95)
    local playIcon = hearAdded:CreateTexture(nil, "ARTWORK")
    playIcon:SetSize(12, 12)
    playIcon:SetPoint("CENTER", 1, 0)
    playIcon:SetAtlas("common-icon-forwardarrow", false)
    playIcon:SetVertexColor(1, 1, 1, 1)
    hearAdded:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Preview added sounds", unpack(COLORS.accent))
        local configured = 0
        for layerIndex = 1, ns:GetRuleLayerCount(rule) do
            local layer = ns:GetLayerConfig(rule, layerIndex)
            if layer.enabled and layer.soundID then
                configured = configured + 1
                GameTooltip:AddDoubleLine(
                    "Layer " .. layerIndex,
                    string.format("%s  •  %d ms", ns:GetSoundLabel(layer.soundID, layer.soundLabel), layer.delayMs or 0),
                    COLORS.teal[1], COLORS.teal[2], COLORS.teal[3],
                    1, 1, 1
                )
            end
        end
        if configured == 0 then
            GameTooltip:AddLine("No enabled sound layers are configured.", COLORS.muted[1], COLORS.muted[2], COLORS.muted[3], true)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Plays only the sounds Resonance adds, not the spell's original game audio.", COLORS.muted[1], COLORS.muted[2], COLORS.muted[3], true)
        GameTooltip:Show()
    end)
    hearAdded:SetScript("OnLeave", GameTooltip_Hide)
    cell.preview = hearAdded

    AddTooltip(hearAdded, "Preview added sounds", "Plays this moment's enabled Resonance layers and their delays. It does not play Blizzard's original spell sound.")

    local function LayerLine(layerIndex, y)
        local layerCheck = CreateModernCheck(cell, 15)
        layerCheck:SetSize(18,18); layerCheck:SetPoint("TOPLEFT", 4, y)
        local swatch = CreateButton(cell, "", SOUND_SWATCH_WIDTH, function()
            local current = ns:GetLayerConfig(rule, layerIndex)
            ns:OpenSoundPicker(current.soundID, function(soundID)
                ns:SetLayerConfig(rule, layerIndex, { soundID=soundID, enabled=true })
                ns:RefreshOptions()
            end, ns:GetSuggestedSoundCategory(rule))
        end)
        swatch:SetHeight(20); swatch:SetPoint("LEFT", layerCheck, "RIGHT", 4, 0)
        local swatchText = swatch:GetFontString()
        swatchText:ClearAllPoints()
        swatchText:SetPoint("LEFT", swatch, "LEFT", 7, 0)
        swatchText:SetPoint("RIGHT", swatch, "RIGHT", -5, 0)
        swatchText:SetJustifyH("LEFT")
        swatchText:SetWordWrap(false)
        if swatchText.SetMaxLines then swatchText:SetMaxLines(1) end
        local delay = CreateEditBox(cell, DELAY_FIELD_WIDTH)
        delay:SetPoint("LEFT", swatch, "RIGHT", 4, 0)
        cell.layerChecks[layerIndex] = layerCheck
        cell.swatches[layerIndex] = swatch
        cell.delays[layerIndex] = delay
        local remove
        local function RefreshLayerAppearance(value)
            local alpha = value and 1 or 0.46
            layerCheck:SetAlpha(alpha)
            swatch:SetAlpha(alpha)
            delay:SetAlpha(alpha)
            if remove then remove:SetAlpha(alpha) end
        end
        layerCheck:SetScript("OnClick", function(self)
            RefreshLayerAppearance(self:GetChecked() == true)
            ns:SetLayerConfig(rule, layerIndex, {enabled=self:GetChecked()==true})
            ns:QueueRefresh("layer")
        end)
        delay:SetScript("OnEditFocusLost", function(self)
            ns:SetLayerConfig(rule, layerIndex, {delayMs=tonumber(self:GetText()) or 0})
            self:SetText(ns:GetLayerConfig(rule,layerIndex).delayMs)
        end)
        AddTooltip(delay, "Delay in milliseconds", "0 plays immediately. Small values such as 60–180 ms create an echo or trailing layer.")
        AddTooltip(swatch, "Layer " .. layerIndex .. " sound", "Click to choose. Right-click previews this layer.")
        swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        swatch:SetScript("OnClick", function(_, mouseButton)
            local current = ns:GetLayerConfig(rule,layerIndex)
            if mouseButton == "RightButton" then
                if current.soundID then ns:PreviewSoundFile(current.soundID) end
            else
                ns:OpenSoundPicker(current.soundID, function(soundID)
                    ns:SetLayerConfig(rule, layerIndex, {soundID=soundID, enabled=true})
                    ns:RefreshOptions()
                end, ns:GetSuggestedSoundCategory(rule))
            end
        end)
        if layerIndex >= 3 then
            remove = CreateButton(cell, "×", 18, function()
                if ns:RemoveRuleLayer(rule, layerIndex) then ns:RebuildOptionsSpec(rule.spec) end
            end)
            remove:SetHeight(20)
            remove:SetPoint("LEFT", delay, "RIGHT", 3, 0)
            AddTooltip(remove, "Remove layer", "Removes this added sound layer and shifts later layers upward.")
            cell.removeButtons[layerIndex] = remove
        end
        RegisterOptionWidget({refresh=function()
            local layer=ns:GetLayerConfig(rule,layerIndex)
            layerCheck:SetChecked(layer.enabled)
            RefreshLayerAppearance(layer.enabled)
            swatch:SetText(ShortSoundLabel(layer.soundID, layer.soundLabel))
            delay:SetText(layer.delayMs or 0)
        end})
    end
    for layerIndex = 1, ns:GetRuleLayerCount(rule) do
        LayerLine(layerIndex, -33 - (layerIndex - 1) * MOMENT_LAYER_HEIGHT)
    end
    local addLayer = CreateButton(cell, "+ layer", 54, function()
        if ns:AddRuleLayer(rule) then
            ns:RebuildOptionsSpec(rule.spec)
            if ns.TutorialSignal then ns:TutorialSignal("layer-added", rule.id) end
        end
    end)
    addLayer:SetHeight(20)
    addLayer:SetPoint("BOTTOMLEFT", 4, 4)
    addLayer:SetEnabled(ns:GetRuleLayerCount(rule) < ns.MAX_RULE_LAYERS)
    AddTooltip(addLayer, "Add sound layer", "Adds another independently selectable sound and delay. Up to " .. ns.MAX_RULE_LAYERS .. " layers per moment.")
    cell.addLayer = addLayer
    function cell:ResizeForCard(width, height)
        self:SetSize(width, height)
        for layerIndex, swatch in ipairs(self.swatches) do
            -- Always reserve the trailing remove-button column. The × only
            -- appears on added layers, but every delay stays in the same
            -- vertical column instead of shifting when a layer is added.
            swatch:SetWidth(math.max(SOUND_SWATCH_WIDTH, width - 105))
        end
    end
    return cell
end

local function ResolveSpellIcon(spellRules)
    for _, rule in ipairs(spellRules or {}) do
        for _, spellID in ipairs(rule.spellIDs or {}) do
            if C_Spell and C_Spell.GetSpellTexture then
                local ok, texture = pcall(C_Spell.GetSpellTexture, spellID)
                if ok and texture then return texture end
            end
            if C_Spell and C_Spell.GetSpellInfo then
                local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
                if ok and info and info.iconID then return info.iconID end
            end
            if GetSpellTexture then
                local ok, texture = pcall(GetSpellTexture, spellID)
                if ok and texture then return texture end
            end
        end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function CreateSpellCard(parent, spellName, spellRules, y)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", SPELL_LIST_INSET, y); card:SetPoint("TOPRIGHT", -SPELL_LIST_INSET, y); card:SetHeight(80)
    if card.SetClipsChildren then card:SetClipsChildren(true) end
    -- The spell-list frame is the one enclosing frame. Each row needs only
    -- its identity rail and editable moment cards.

    local rail = CreateFrame("Frame", nil, card, "BackdropTemplate")
    rail:SetPoint("TOPLEFT", 0, 0)
    rail:SetPoint("BOTTOMLEFT", 0, 0)
    -- Keep the identity rail close to its moment panels so both read as one
    -- spell record, while preserving enough width for a wrapped spell name.
    rail:SetWidth(MOMENT_CONTENT_LEFT - 8)
    ApplyBackdrop(rail, { 0.035, 0.04, 0.065, 0.88 }, { 0.18, 0.13, 0.30, 0.90 })

    local identity = CreateFrame("Frame", nil, rail)
    identity:SetSize(math.max(84, MOMENT_CONTENT_LEFT - 30), 100)
    identity:SetPoint("TOP", rail, "TOP", 0, -10)

    local iconFrame = CreateFrame("Frame", nil, identity, "BackdropTemplate")
    iconFrame:SetSize(40, 40)
    iconFrame:SetPoint("TOPLEFT", 0, 0)
    ApplyBackdrop(iconFrame, { 0.015, 0.02, 0.035, 1 }, COLORS.accent)
    local spellIcon = iconFrame:CreateTexture(nil, "ARTWORK")
    spellIcon:SetPoint("TOPLEFT", 3, -3)
    spellIcon:SetPoint("BOTTOMRIGHT", -3, 3)
    spellIcon:SetTexture(ResolveSpellIcon(spellRules))
    spellIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    card.spellIcon = spellIcon

    local name = CreateText(identity, "GameFontNormal", spellName)
    name:SetPoint("TOPLEFT", iconFrame, "BOTTOMLEFT", 0, -7)
    name:SetPoint("RIGHT", identity, "RIGHT", 0, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(true)
    local count = CreateText(identity, "GameFontHighlightSmall", #spellRules .. (#spellRules == 1 and " moment" or " moments"))
    count:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    count:SetTextColor(unpack(COLORS.muted))
    count:SetJustifyH("LEFT")
    card.momentCells = {}
    card.ruleCells = {}
    for index, rule in ipairs(spellRules) do
        card.momentCells[index] = CreateMomentCell(card, rule, GetMomentCellHeight(rule))
        card.ruleCells[rule.id] = card.momentCells[index]
    end
    function card:Reflow()
        local columns = GetMomentColumns(self:GetWidth(), #spellRules)
        local height, rowHeights = GetSpellCardLayout(spellRules, columns)
        local rowOffsets = { 0 }
        for row = 2, #rowHeights do rowOffsets[row] = rowOffsets[row - 1] + rowHeights[row - 1] + SPELL_ROW_GAP end
        for index, cell in ipairs(self.momentCells) do
            local column = (index - 1) % columns
            local row = math.floor((index - 1) / columns) + 1
            local firstInRow = (row - 1) * columns + 1
            local momentsInRow = math.min(columns, #spellRules - firstInRow + 1)
            local availableWidth = math.max(MOMENT_CELL_WIDTH, self:GetWidth() - MOMENT_CONTENT_LEFT - 12)
            -- A single moment should not become a very long, hard-to-scan
            -- control strip. When two normal cards fit, reserve its absent
            -- neighbour and keep the same readable card width. On narrow
            -- windows it still expands naturally to the available space.
            local displayColumns = momentsInRow
            if momentsInRow == 1 and availableWidth >= MOMENT_CELL_WIDTH * 2 + MOMENT_CELL_GAP then
                displayColumns = 2
            end
            local cellWidth = (availableWidth - (displayColumns - 1) * MOMENT_CELL_GAP) / displayColumns
            cell:ClearAllPoints()
            cell:SetPoint("TOPLEFT", MOMENT_CONTENT_LEFT + column * (cellWidth + MOMENT_CELL_GAP), -rowOffsets[row])
            cell:ResizeForCard(cellWidth, rowHeights[row])
        end
        self:SetHeight(height)
        return height
    end
    return card, card:Reflow()
end

function ns:OpenSoundPicker(initialID, callback, suggestedCategory)
    self:CreateSoundPicker()
    local sound = initialID and self.SoundByID[initialID]
    self.SoundPicker.pendingID = initialID
    wipe(self.SoundPicker.selectedIDs)
    if IsSoundSortingDebugActive() and initialID then self.SoundPicker.selectedIDs[initialID] = true end
    self.SoundPicker.callback = callback
    self.SoundPicker.category = (sound and self:GetEffectiveSoundCategory(sound)) or suggestedCategory or "arcane"
    self.SoundPicker.search:SetText("")
    self.SoundPicker.search:ClearFocus()
    self.SoundPicker:RefreshSounds()
    self.SoundPicker:Show()
    self.SoundPicker:Raise()
    if self.TutorialSignal then self:TutorialSignal("sound-picker-opened", initialID) end
    local picker = self.SoundPicker
    local targetID = initialID
    local targetCategory = picker.category
    C_Timer.After(0, function()
        if not picker:IsShown() or picker.pendingID ~= targetID then return end
        picker:ScrollCategoryIntoView(targetCategory)
        picker:ScrollToSound(targetID)
    end)
end

function ns:RefreshOptions()
    if not self.OptionWidgets then return end
    for _, widget in ipairs(self.OptionWidgets) do
        if widget.getter and widget.SetChecked then
            widget:SetChecked(widget.getter() == true)
        elseif widget.refresh then
            widget:refresh()
        end
    end

end

local function BuildGeneral(content, y)
    -- This is a compact utility band. Public controls share one baseline;
    -- debug-only controls retain their taller diagnostic layout.
    local publicLayout = not DEBUG_SOUND_TOOLS_VISIBLE
    local generalHeight = publicLayout and 56 or 140
    local section = CreateSection(content, nil, nil, generalHeight)
    section:SetPoint("TOPLEFT", 0, y)
    section:SetPoint("TOPRIGHT", 0, y)

    local enabled
    local minimap
    local solo
    if publicLayout then
        enabled = CreateSettingsBandToggle(section, "Enable Resonance", nil,
            function() return ns.DB.enabled end,
            function(value) ns.DB.enabled = value ns:QueueRefresh("master") end)
        solo = CreateSettingsBandToggle(section, "Solo added sounds", "Route Resonance to Dialog and mute the game mix.",
            function() return ns.DB.soloMode end,
            function(value) ns:SetSoloMode(value) end)
        minimap = CreateSettingsBandToggle(section, "Show minimap button", nil,
            function() return not ns.DB.minimap.hide end,
            function(value) ns.DB.minimap.hide = not value ns:UpdateMinimapButton() end)
    else
        enabled = CreateCheckRow(section, "Enable Resonance", nil,
            function() return ns.DB.enabled end,
            function(value) ns.DB.enabled = value ns:QueueRefresh("master") end)
        minimap = CreateCheckRow(section, "Show minimap button", nil,
            function() return not ns.DB.minimap.hide end,
            function(value) ns.DB.minimap.hide = not value ns:UpdateMinimapButton() end)
        solo = CreateCheckRow(section, "Solo added sounds", "Routes Resonance to Dialog and temporarily mutes SFX, music and ambience.",
            function() return ns.DB.soloMode end,
            function(value) ns:SetSoloMode(value) end)
    end

    if DEBUG_SOUND_TOOLS_VISIBLE then
        local debug = CreateCheckRow(section, "Diagnostic messages", "Print cue and refresh information to chat while testing.",
            function() return ns.DB.debug end,
            function(value) ns.DB.debug = value end)
        debug:SetPoint("TOPLEFT", 300, -82)
        debug:SetWidth(300)

        local sorting = CreateCheckRow(section, "Debug: Sound sorting mode", "Move sounds, stage deletions, then save from the footer.",
            function() return ns.DB.soundSortDebug end,
            function(value)
                ns.DB.soundSortDebug=value
                if ns.SoundPicker and ns.SoundPicker:IsShown() then ns.SoundPicker:RefreshSounds() end
                ns:RefreshOptions()
            end)
        sorting:SetPoint("TOPLEFT", 14, -98)
        sorting:SetWidth(270)
    end

    local channelValues = {
        { value = "SFX", label = "SFX (recommended)" },
        { value = "Dialog", label = "Dialog" },
        { value = "Master", label = "Master" },
    }
    local getChannel = function() return ns.DB.channel end
    local setChannel = function(value) ns.DB.channel = value end
    local channel
    if publicLayout then
        channel = CreateCompactCycle(section, channelValues, getChannel, setChannel, 132)
    else
        channel = CreateCycle(section, "Audio channel", channelValues, getChannel, setChannel, 206)
    end
    local library = CreateButton(section, "Open sound library", publicLayout and 160 or 206, function()
        ns:OpenSoundPicker(nil, function() end, "bronze")
    end, true)
    AddTooltip(library, "Sound library", "Audition the curated WoW spell assets. Pickers opened from a spell moment also save your choice.")
    AddTooltip(channel, "Sound channel", "Choose which WoW sound channel plays Resonance layers.")

    if publicLayout then
        -- A compact, named four-column grid: related settings on the left,
        -- one separated visibility control, then the paired audio actions.
        local divider = section:CreateTexture(nil, "ARTWORK")
        divider:SetTexture("Interface\\Buttons\\WHITE8X8")
        divider:SetVertexColor(COLORS.accent[1], COLORS.accent[2], COLORS.accent[3], 0.42)
        divider:SetSize(1, 32)

        local function LayoutPublicBand()
            local width = section:GetWidth()
            if width <= 0 then return end

            local inset = 22
            local utilityRight = width - inset
            local libraryWidth, utilityGap = library:GetWidth(), 8
            local utilityLeft = utilityRight - libraryWidth - utilityGap - channel:GetWidth()
            -- Do not spread settings across the whole window on ultrawide
            -- layouts. The reference uses a compact control cluster first,
            -- then leaves breathing room before the right-side actions.
            local settingsWidth = math.min(520, math.max(450, utilityLeft - inset - 230))
            local enabledWidth = math.floor(settingsWidth * 0.50)
            local soloX = inset + enabledWidth + 12
            local dividerX = inset + settingsWidth + 12
            local minimapX = dividerX + 28

            enabled:SetWidth(enabledWidth)
            solo:SetWidth(math.max(250, dividerX - soloX - 22))
            minimap:SetWidth(math.max(180, utilityLeft - minimapX - 18))

            enabled:ClearAllPoints(); enabled:SetPoint("TOPLEFT", inset, -11)
            solo:ClearAllPoints(); solo:SetPoint("TOPLEFT", soloX, -11)
            divider:ClearAllPoints(); divider:SetPoint("TOPLEFT", dividerX, -12)
            minimap:ClearAllPoints(); minimap:SetPoint("TOPLEFT", minimapX, -11)
            library:ClearAllPoints(); library:SetPoint("TOPRIGHT", -inset, -17)
            channel:ClearAllPoints(); channel:SetPoint("RIGHT", library, "LEFT", -utilityGap, 0)
        end
        section:SetScript("OnSizeChanged", LayoutPublicBand)
        LayoutPublicBand()
    else
        enabled:SetPoint("TOPLEFT", 14, -36)
        minimap:SetPoint("TOPLEFT", 14, -64)
        solo:SetPoint("TOPLEFT", 300, -36)
        channel:SetPoint("TOPRIGHT", -14, -31)
        library:SetPoint("TOPRIGHT", -14, -68)
    end

    return y - generalHeight - 10
end

function ns:CreateSoundSetWindow()
    if self.SoundSetWindow then return end
    local window = CreateFrame("Frame", "ResonanceSoundSetWindow", UIParent, "BackdropTemplate")
    window:SetSize(610, 510); window:SetPoint("CENTER"); window:SetFrameStrata("TOOLTIP"); window:SetFrameLevel(920)
    window:SetToplevel(true); window:SetMovable(true); window:SetClampedToScreen(true); window:EnableMouse(true)
    ApplyBackdrop(window, COLORS.panel, COLORS.accent)
    AddArcaneTrim(window, "window")
    local close = CreateCloseButton(window)
    close:SetPoint("TOPRIGHT", -8, -8)
    local title = CreateText(window, "GameFontNormalLarge", "Sound sets"); title:SetPoint("TOPLEFT", 18, -16)
    local subtitle = CreateText(window, "GameFontHighlightSmall", "Editing a preset switches you to your personal set. Save changes updates that set.")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4); subtitle:SetTextColor(unpack(COLORS.muted))
    window.subtitle = subtitle
    local drag = CreateFrame("Frame", nil, window); drag:SetPoint("TOPLEFT"); drag:SetPoint("TOPRIGHT"); drag:SetHeight(50)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() window:StartMoving() end); drag:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    window.empty = CreateText(window, "GameFontHighlight", "Your personal set appears here after your first edit.")
    window.empty:SetPoint("CENTER", 0, 20); window.empty:SetTextColor(unpack(COLORS.muted))
    local setScroll=CreateFrame("ScrollFrame",nil,window)
    setScroll:SetPoint("TOPLEFT",18,-66); setScroll:SetPoint("BOTTOMRIGHT",-34,58)
    local setContent=CreateFrame("Frame",nil,setScroll)
    setContent:SetWidth(558); setContent:SetHeight(386); setScroll:SetScrollChild(setContent)
    SkinScrollFrame(setScroll)
    window.rows = {}
    local loadConfirmPanel, namePanel, nameBox, OpenNamePanel
    local function FinishSoundSetLoad(specID, setName)
        if not ns:LoadSoundSet(specID, setName) then return end
        if loadConfirmPanel then loadConfirmPanel:Hide() end
        ns:RefreshOptions()
        if ns.SoundSetWindow then ns.SoundSetWindow:Refresh() end
    end
    local function RequestSoundSetLoad(specID, setName)
        if not ns:HasUnsavedProfileChanges(specID) then
            FinishSoundSetLoad(specID, setName)
            return
        end
        local store = ns:GetSpecProfileStore(specID)
        local sourceName = store and store.loadedName or ns.SUPPORTED_SPECS[specID] or "working set"
        loadConfirmPanel.specID = specID
        loadConfirmPanel.setName = setName
        loadConfirmPanel.message:SetText("Using |cff9d7cff"..setName.."|r will replace the unsaved edits to |cffffffff"..sourceName.."|r. Save changes first if you want to keep them.")
        loadConfirmPanel:Show()
        loadConfirmPanel:Raise()
    end
    function window:AcquireSetRow(index)
        if self.rows[index] then return self.rows[index] end
        local row=CreateFrame("Frame",nil,setContent,"BackdropTemplate")
        row:SetHeight(44); row:SetPoint("TOPLEFT",0,-(index-1)*49); row:SetPoint("TOPRIGHT",0,-(index-1)*49)
        ApplyBackdrop(row,COLORS.cardAlt,{0.16,0.17,0.24,1})
        row.name=CreateText(row,"GameFontNormal",""); row.name:SetPoint("TOPLEFT",10,-7)
        row.status=CreateText(row,"GameFontHighlightSmall",""); row.status:SetPoint("BOTTOMLEFT",10,6)
        row.status:SetTextColor(unpack(COLORS.muted)); row.status:SetJustifyH("LEFT"); row.status:SetWordWrap(false)
        row.rename=CreateFrame("Button",nil,row)
        row.rename:EnableMouse(true)
        row.rename:SetScript("OnClick",function()
            if row.isBuiltin ~= true and OpenNamePanel then OpenNamePanel("rename", row.setName) end
        end)
        row.export=CreateButton(row,"Export",54,function()
            local exportText, reason = ns:ExportSoundSet(window.specID, row.setName)
            if exportText then window.transfer:OpenExport(row.setName, exportText)
            else ns:Print("Could not export this sound set (" .. tostring(reason or "unknown error") .. ").") end
        end)
        row.export:SetPoint("RIGHT",-8,0)
        row.delete=CreateButton(row,"×",28,function() ns:DeleteSoundSet(window.specID,row.setName); window:Refresh(); ns:RefreshOptions() end)
        row.delete:SetPoint("RIGHT",row.export,"LEFT",-6,0)
        row.overwrite=CreateButton(row,"Save changes",96,function() ns:SaveActiveSoundSet(window.specID); window:Refresh(); ns:RefreshOptions() end)
        row.overwrite:SetPoint("RIGHT",row.delete,"LEFT",-6,0)
        row.load=CreateButton(row,"Use",62,function() RequestSoundSetLoad(window.specID,row.setName) end,true)
        row.load:SetPoint("RIGHT",row.overwrite,"LEFT",-6,0)
        row.rename:SetPoint("TOPLEFT",8,-3); row.rename:SetPoint("BOTTOMRIGHT",row.load,"LEFT",-6,3)
        row.name:SetPoint("RIGHT", row.load, "LEFT", -8, 0)
        row.status:SetPoint("RIGHT", row.load, "LEFT", -8, 0)
        row.name:SetJustifyH("LEFT"); row.name:SetWordWrap(false)
        AddTooltip(row.rename, "Rename set", "Click the set name to rename this personal or saved set. Built-in presets cannot be renamed.")
        AddTooltip(row.load, "Use this set", "Replaces the current working sounds with this saved set. Save changes first if the active set is marked Changed.")
        AddTooltip(row.overwrite, "Save changes", "Updates the active set with the changes you have made.")
        AddTooltip(row.delete, "Delete set", "Deletes this named set. Your first personal set and built-in presets are protected.")
        self.rows[index]=row
        return row
    end
    loadConfirmPanel=CreateFrame("Frame",nil,window,"BackdropTemplate")
    loadConfirmPanel:SetSize(390,146); loadConfirmPanel:SetPoint("CENTER"); loadConfirmPanel:SetFrameLevel(window:GetFrameLevel()+25)
    loadConfirmPanel:EnableMouse(true); ApplyBackdrop(loadConfirmPanel,COLORS.card,COLORS.accent)
    local loadConfirmTitle=CreateText(loadConfirmPanel,"GameFontNormalLarge","Switch sound set?")
    loadConfirmTitle:SetPoint("TOPLEFT",16,-15)
    loadConfirmPanel.message=CreateText(loadConfirmPanel,"GameFontHighlightSmall","")
    loadConfirmPanel.message:SetPoint("TOPLEFT",16,-48); loadConfirmPanel.message:SetPoint("RIGHT",loadConfirmPanel,"RIGHT",-16,0)
    loadConfirmPanel.message:SetJustifyH("LEFT"); loadConfirmPanel.message:SetWordWrap(true); loadConfirmPanel.message:SetTextColor(unpack(COLORS.muted))
    local confirmLoad=CreateButton(loadConfirmPanel,"Use this set",108,function()
        FinishSoundSetLoad(loadConfirmPanel.specID,loadConfirmPanel.setName)
    end,true)
    confirmLoad:SetPoint("BOTTOMRIGHT",-16,13)
    local cancelLoad=CreateButton(loadConfirmPanel,"Keep editing",100,function() loadConfirmPanel:Hide() end)
    cancelLoad:SetPoint("RIGHT",confirmLoad,"LEFT",-8,0)
    loadConfirmPanel:Hide(); window.loadConfirmPanel=loadConfirmPanel
    namePanel=CreateFrame("Frame",nil,window,"BackdropTemplate")
    namePanel:SetSize(360,132); namePanel:SetPoint("CENTER"); namePanel:SetFrameLevel(window:GetFrameLevel()+20)
    namePanel:EnableMouse(true); ApplyBackdrop(namePanel,COLORS.card,COLORS.accent)
    local nameTitle=CreateText(namePanel,"GameFontNormalLarge","Name this sound set")
    nameTitle:SetPoint("TOPLEFT",16,-14)
    local nameHelp=CreateText(namePanel,"GameFontHighlightSmall","Create another named copy of your current sounds. Your first personal set stays protected.")
    nameHelp:SetPoint("TOPLEFT",nameTitle,"BOTTOMLEFT",0,-3); nameHelp:SetTextColor(unpack(COLORS.muted))
    nameBox=CreateFrame("EditBox",nil,namePanel,"BackdropTemplate")
    nameBox:SetSize(328,24); nameBox:SetPoint("TOPLEFT",16,-58); nameBox:SetAutoFocus(false); nameBox:SetMaxLetters(32)
    nameBox:SetFontObject("GameFontHighlight"); nameBox:SetTextInsets(8,8,0,0); ApplyBackdrop(nameBox,COLORS.panel,COLORS.border)
    local function CommitNewSoundSet()
        local saved, reason
        if namePanel.mode == "rename" then
            saved, reason = ns:RenameSoundSet(window.specID, namePanel.sourceName, nameBox:GetText())
        else
            saved, reason = ns:SaveSoundSet(window.specID,nameBox:GetText())
        end
        if saved then
            namePanel:Hide(); window:Refresh(); ns:RefreshOptions()
            if ns.TutorialSignal then ns:TutorialSignal("sound-set-saved", window.specID) end
        elseif reason == "builtin" then
            ns:Print("Built-in presets are protected. Choose a different name for your version."); nameBox:SetFocus()
        elseif reason == "exists" then
            ns:Print("A sound set already uses that name."); nameBox:SetFocus()
        else
            ns:Print("Please enter a unique sound set name."); nameBox:SetFocus()
        end
    end
    local createNamed=CreateButton(namePanel,"Create",92,CommitNewSoundSet,true)
    createNamed:SetPoint("BOTTOMRIGHT",-16,12)
    local cancelNamed=CreateButton(namePanel,"Cancel",82,function() namePanel:Hide() end)
    cancelNamed:SetPoint("RIGHT",createNamed,"LEFT",-7,0)
    nameBox:SetScript("OnEnterPressed",CommitNewSoundSet)
    nameBox:SetScript("OnEscapePressed",function(self) self:ClearFocus(); namePanel:Hide() end)
    OpenNamePanel = function(mode, sourceName)
        namePanel.mode = mode
        namePanel.sourceName = sourceName
        if mode == "rename" then
            nameTitle:SetText("Rename sound set")
            nameHelp:SetText("This changes the set name only. Its sounds and settings stay exactly the same.")
            createNamed:SetText("Rename")
            nameBox:SetText(sourceName or "")
            nameBox:HighlightText()
        else
            nameTitle:SetText("Name this sound set")
            nameHelp:SetText("Create another named copy of your current sounds. Your first personal set stays protected.")
            createNamed:SetText("Create")
            nameBox:SetText("")
        end
        namePanel:Show(); namePanel:Raise(); nameBox:SetFocus()
    end
    namePanel:Hide(); window.namePanel=namePanel
    window.nameBox=nameBox; window.createNamed=createNamed; window.cancelNamed=cancelNamed

    local transfer=CreateFrame("Frame",nil,window,"BackdropTemplate")
    transfer:SetSize(450,310); transfer:SetPoint("CENTER"); transfer:SetFrameLevel(window:GetFrameLevel()+30)
    transfer:EnableMouse(true); ApplyBackdrop(transfer,COLORS.panel,COLORS.accent)
    local transferClose=CreateCloseButton(transfer)
    transferClose:SetPoint("TOPRIGHT",-8,-8)
    transfer.title=CreateText(transfer,"GameFontNormalLarge","")
    transfer.title:SetPoint("TOPLEFT",16,-14)
    transfer.help=CreateText(transfer,"GameFontHighlightSmall","")
    transfer.help:SetPoint("TOPLEFT",transfer.title,"BOTTOMLEFT",0,-4)
    transfer.help:SetPoint("RIGHT",transfer,"RIGHT",-42,0)
    transfer.help:SetJustifyH("LEFT"); transfer.help:SetTextColor(unpack(COLORS.muted))

    local textScroll=CreateFrame("ScrollFrame",nil,transfer,"BackdropTemplate")
    textScroll:SetPoint("TOPLEFT",16,-72); textScroll:SetPoint("BOTTOMRIGHT",-16,60)
    textScroll:EnableMouseWheel(true); ApplyBackdrop(textScroll,COLORS.cardAlt,COLORS.border)
    local textBox=CreateFrame("EditBox",nil,textScroll)
    textBox:SetMultiLine(true); textBox:SetAutoFocus(false); textBox:SetFontObject("GameFontHighlightSmall")
    textBox:SetWidth(400); textBox:SetHeight(170); textBox:SetTextInsets(8,8,8,8)
    textBox:SetMaxLetters(100000); textScroll:SetScrollChild(textBox)
    textBox:SetScript("OnTextChanged",function(self)
        local textHeight = tonumber(self.GetStringHeight and self:GetStringHeight()) or 150
        self:SetHeight(math.max(170, textHeight + 20))
        textScroll:UpdateScrollChildRect()
    end)
    textBox:SetScript("OnEscapePressed",function(self) self:ClearFocus(); transfer:Hide() end)
    textScroll:SetScript("OnMouseWheel",function(self,delta)
        local maximum = self.GetVerticalScrollRange and self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(math.max(0,math.min(maximum,(self:GetVerticalScroll() or 0)-delta*36)))
    end)

    transfer.status=CreateText(transfer,"GameFontHighlightSmall","")
    transfer.status:SetPoint("BOTTOMLEFT",16,18); transfer.status:SetPoint("RIGHT",transfer,"RIGHT",-210,0)
    transfer.status:SetJustifyH("LEFT"); transfer.status:SetTextColor(unpack(COLORS.muted))
    transfer.cancel=CreateButton(transfer,"Cancel",80,function() transfer:Hide() end)
    transfer.cancel:SetPoint("BOTTOMRIGHT",-16,14)
    transfer.action=CreateButton(transfer,"",110,function() end,true)
    transfer.action:SetPoint("RIGHT",transfer.cancel,"LEFT",-8,0)

    function transfer:OpenExport(setName,exportText)
        self.mode="export"; self.title:SetText("Export “"..setName.."”")
        self.help:SetText("Copy this complete Resonance code and send it to a friend. It contains this specialization’s sounds, layers, delays, and toggles.")
        self.status:SetText("Ctrl+C copies the selected code.")
        self.status:SetTextColor(unpack(COLORS.muted))
        self.action:SetText("Select all")
        self.action:SetScript("OnClick",function() textBox:SetFocus(); textBox:HighlightText() end)
        self:Show(); self:Raise()
        textBox:SetText(exportText); textScroll:SetVerticalScroll(0); textBox:SetFocus(); textBox:HighlightText()
    end

    function transfer:OpenImport()
        self.mode="import"; self.title:SetText("Import new sound set")
        self.help:SetText("Paste a complete Resonance export code. It must belong to the specialization currently shown in this window.")
        self.status:SetText("")
        self.status:SetTextColor(unpack(COLORS.muted))
        self.action:SetText("Import")
        self.action:SetScript("OnClick",function()
            local importedName, reason, sourceSpecID = ns:ImportSoundSet(window.specID,textBox:GetText())
            if importedName then
                ns:Print("Imported sound set: "..importedName)
                transfer:Hide(); window:Refresh(); ns:RefreshOptions()
            elseif reason == "wrong-spec" then
                local sourceName = ns.SUPPORTED_SPECS[sourceSpecID] or ("specialization "..tostring(sourceSpecID or "?"))
                transfer.status:SetText("This code belongs to "..sourceName..". Select that spec first.")
                transfer.status:SetTextColor(1,0.35,0.35,1)
            elseif reason == "checksum" then
                transfer.status:SetText("Invalid or incomplete code. Copy the entire export again.")
                transfer.status:SetTextColor(1,0.35,0.35,1)
            else
                transfer.status:SetText("This is not a valid Resonance sound-set code.")
                transfer.status:SetTextColor(1,0.35,0.35,1)
            end
        end)
        self:Show(); self:Raise()
        textBox:SetText(""); textScroll:SetVerticalScroll(0); textBox:SetFocus()
    end
    transfer:SetScript("OnHide",function() textBox:ClearFocus() end)
    transfer:Hide(); window.transfer=transfer

    window.create=CreateButton(window,"Save as new set",138,function() OpenNamePanel("create") end,true)
    window.create:SetPoint("BOTTOMLEFT",18,16)
    window.import=CreateButton(window,"Import new set",138,function() transfer:OpenImport() end)
    window.import:SetPoint("LEFT",window.create,"RIGHT",8,0)
    function window:Refresh()
        local names=ns:GetSoundSetNames(self.specID); self.empty:SetShown(#names==0)
        local store=ns:GetSpecProfileStore(self.specID)
        for index,name in ipairs(names) do
            local row=self:AcquireSetRow(index); row.setName=name
            local savedSet = store.savedSets[name]
            local builtin = savedSet and savedSet.builtin == true
            local automatic = savedSet and savedSet.automatic == true
            local isLoaded = store.loadedName == name
            local status, statusColor
            if isLoaded and store.dirty == true then
                status, statusColor = "Changed · click Save changes to update this set", {0.96,0.66,0.16,1}
            elseif automatic then
                status, statusColor = isLoaded and "Personal set · active" or "Personal set · created on your first edit", COLORS.teal
            elseif builtin then
                status, statusColor = "Built-in preset", COLORS.muted
            elseif isLoaded then
                status, statusColor = "Active named set", COLORS.teal
            else
                status, statusColor = "Saved named set", COLORS.muted
            end
            row.name:SetText((isLoaded and "|cff35d1bd" or "|cff9d7cff")..name)
            row.status:SetText(status); row.status:SetTextColor(unpack(statusColor))
            row.isBuiltin = builtin
            row.rename:SetShown(not builtin)
            row.load:SetText(isLoaded and "Active" or "Use")
            row.load:SetEnabled(not isLoaded)
            row.overwrite:SetShown(isLoaded and store.dirty == true)
            row.delete:SetShown(not builtin and not automatic and not isLoaded)
            if isLoaded then
                local border = store.dirty == true and {0.96,0.66,0.16,1} or COLORS.teal
                ApplyBackdrop(row, COLORS.cardAlt, border)
            else
                ApplyBackdrop(row, COLORS.cardAlt, {0.16,0.17,0.24,1})
            end
            row:Show()
        end
        for index=#names+1,#self.rows do self.rows[index]:Hide() end
        setContent:SetHeight(math.max(setScroll:GetHeight(),#names*49))
        setScroll:UpdateScrollChildRect()
        if setScroll._resonanceUpdateScrollBar then setScroll._resonanceUpdateScrollBar() end
    end
    function window:SetSpec(specID)
        if not ns.SUPPORTED_SPECS[specID] then return end
        local changed = self.specID ~= specID
        self.specID = specID
        self.subtitle:SetText((ns.SUPPORTED_SPECS[specID] or "This specialization") .. " \226\128\162 presets and saved sets")
        if changed then
            -- A pending confirmation or name/import dialog belongs to the
            -- previous specialization. Close it rather than letting it act
            -- on a different profile after the selector changes.
            namePanel:Hide()
            transfer:Hide()
            loadConfirmPanel:Hide()
            nameBox:ClearFocus()
        end
        self:Refresh()
    end
    window:SetScript("OnHide",function()
        namePanel:Hide(); transfer:Hide(); loadConfirmPanel:Hide(); nameBox:ClearFocus()
        if ns.TutorialSignal then ns:TutorialSignal("sound-sets-closed") end
    end)
    window:Hide(); self.SoundSetWindow=window
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames+1]=window:GetName() end
end

function ns:OpenSoundSetWindow(specID)
    self:CreateSoundSetWindow(); self.SoundSetWindow:SetSpec(specID); self.SoundSetWindow:Show(); self.SoundSetWindow:Raise()
    if self.TutorialSignal then self:TutorialSignal("sound-sets-opened", specID) end
end

local function BuildSpecSection(content, specID, y)
    local specRules = ns.RulesBySpec[specID] or {}
    local groups, order = {}, {}
    for _, rule in ipairs(specRules) do
        if not groups[rule.spell] then groups[rule.spell]={}; order[#order+1]=rule.spell end
        groups[rule.spell][#groups[rule.spell]+1]=rule
    end
    local section = CreateSection(content, ns.SUPPORTED_SPECS[specID], nil, 84)
    section:SetPoint("TOPLEFT", 0, y)
    section:SetPoint("TOPRIGHT", 0, y)
    section.spellCards = {}
    section.ruleCells = {}

    local function RefreshSpecCardAppearance()
        local active = ns.DB.specEnabled[specID] ~= false
        for _, card in ipairs(section.spellCards) do
            card:SetAlpha(active and 1 or 0.38)
        end
    end

    local specToggle = CreateCheckRow(section, "Enable this specialization", nil,
        function() return ns.DB.specEnabled[specID] end,
        function(value)
            ns.DB.specEnabled[specID] = value
            RefreshSpecCardAppearance()
            ns:QueueRefresh("spec toggle")
        end)
    specToggle:SetPoint("TOPLEFT", 10, -32)
    RegisterOptionWidget({refresh=RefreshSpecCardAppearance})

    local saveSets = CreateButton(section, "Presets / saved sets", 180, function() ns:OpenSoundSetWindow(specID) end, true)
    saveSets:SetPoint("TOPRIGHT", -14, -28)
    local currentSet = CreateText(section, "GameFontHighlightSmall", "")
    currentSet:SetPoint("BOTTOMRIGHT", saveSets, "TOPRIGHT", 0, 3); currentSet:SetTextColor(unpack(COLORS.muted))
    RegisterOptionWidget({refresh=function()
        local store=ns:GetSpecProfileStore(specID)
        if store and store.loadedName then
            local activeSet = store.savedSets and store.savedSets[store.loadedName]
            if store.dirty == true then
                currentSet:SetText("Editing: "..store.loadedName.."  |cffffb84d• Save changes|r")
            elseif activeSet and activeSet.automatic == true then
                currentSet:SetText("|cff35d1bdPersonal set: "..store.loadedName.."|r")
            elseif activeSet and activeSet.builtin == true then
                currentSet:SetText("Built-in preset: "..store.loadedName)
            else
                currentSet:SetText("Active set: "..store.loadedName)
            end
        elseif store and store.dirty == true then
            currentSet:SetText("|cffffb84dChanged · Save changes|r")
        else
            currentSet:SetText("Working set")
        end
    end})

    section.saveSets = saveSets
    -- One quiet inset frame groups the whole spell list. Individual spells
    -- keep their rail and moment panels without acquiring another wrapper.
    local spellList = CreateFrame("Frame", nil, section, "BackdropTemplate")
    spellList:SetPoint("TOPLEFT", section, "TOPLEFT", SPELL_LIST_INSET, -SPELL_LIST_TOP)
    spellList:SetPoint("TOPRIGHT", section, "TOPRIGHT", -SPELL_LIST_INSET, -SPELL_LIST_TOP)
    spellList:SetHeight(1)
    -- The list frame defines the boundary only. Darkness belongs to the
    -- editable identity and moment cards inside it.
    ApplyBackdrop(spellList, { 0.02, 0.025, 0.04, 0 }, { 0.19, 0.20, 0.27, 0.95 })
    section.spellList = spellList

    local rowY = -SPELL_LIST_INSET
    for _, spellName in ipairs(order) do
        local card, cardHeight = CreateSpellCard(spellList, spellName, groups[spellName], rowY)
        section.spellCards[#section.spellCards + 1] = card
        for ruleID, cell in pairs(card.ruleCells or {}) do section.ruleCells[ruleID] = cell end
        rowY = rowY - cardHeight - SPELL_ROW_GAP
    end
    function section:Reflow()
        local nextY = -SPELL_LIST_INSET
        for index, card in ipairs(self.spellCards) do
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", SPELL_LIST_INSET, nextY)
            card:SetPoint("TOPRIGHT", -SPELL_LIST_INSET, nextY)
            local cardHeight = card:Reflow()
            nextY = nextY - cardHeight
            if index < #self.spellCards then nextY = nextY - SPELL_ROW_GAP end
        end
        local spellListHeight = math.max(1, -nextY + SPELL_LIST_INSET)
        self.spellList:SetHeight(spellListHeight)
        local sectionHeight = math.max(84, SPELL_LIST_TOP + spellListHeight + SPELL_LIST_INSET)
        self:SetHeight(sectionHeight)
        if ns.SpecSectionBottom then ns.SpecSectionBottom[specID] = ns.SpecSectionY - sectionHeight - 10 end
        if ns.SelectedOptionsSpec == specID and ns.OptionsContent then
            ns.OptionsContent:SetHeight(-ns.SpecSectionBottom[specID] + 10)
        end
        return sectionHeight
    end
    local height = section:Reflow()
    return y - height - 10, section
end

local SPEC_CLASS_ID = {
    [71]=1, [72]=1, [73]=1,
    [65]=2, [66]=2, [70]=2,
    [253]=3, [254]=3, [255]=3,
    [259]=4, [260]=4, [261]=4,
    [256]=5, [257]=5, [258]=5,
    [250]=6, [251]=6, [252]=6,
    [262]=7, [263]=7, [264]=7,
    [62]=8, [63]=8, [64]=8,
    [265]=9, [266]=9, [267]=9,
    [268]=10, [269]=10, [270]=10,
    [102]=11, [103]=11, [104]=11, [105]=11,
    [577]=12, [581]=12, [1480]=12,
    [1467]=13, [1468]=13, [1473]=13,
}

local function BuildSpecTabs(content, y)
    local tabs = CreateFrame("Frame", nil, content, "BackdropTemplate")
    local specs = ns.SPEC_ORDER
    local buttons = {}
    local _, _, playerClassID = UnitClass("player")
    tabs._expanded = false
    tabs._topY = y
    tabs:SetPoint("TOPLEFT",0,y); tabs:SetPoint("TOPRIGHT",0,y)
    ApplyBackdrop(tabs,COLORS.card)
    AddArcaneTrim(tabs, "panel")
    for index,specID in ipairs(specs) do
        local button=CreateFrame("Button",nil,tabs,"BackdropTemplate"); button:SetSize(30,30)
        buttons[index] = button
        ApplyBackdrop(button,COLORS.cardAlt,COLORS.border)
        local icon=button:CreateTexture(nil,"ARTWORK"); icon:SetPoint("TOPLEFT",3,-3); icon:SetPoint("BOTTOMRIGHT",-3,3)
        local specIcon
        if GetSpecializationInfoByID then
            local ok, _, _, _, result = pcall(GetSpecializationInfoByID, specID)
            if ok then specIcon = result end
        end
        if not specIcon and C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfoByID then
            local info = C_SpecializationInfo.GetSpecializationInfoByID(specID)
            specIcon = info and info.icon
        end
        icon:SetTexture(specIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        icon:SetTexCoord(0.07,0.93,0.07,0.93)
        button:SetScript("OnClick",function() ns:ShowOptionsSpec(specID) end)
        AddTooltip(button,ns.SUPPORTED_SPECS[specID],"Show this specialization's sound moments and saved sets.")
        button.refresh=function(self)
            if ns.SelectedOptionsSpec==specID then self:SetBackdropBorderColor(unpack(COLORS.teal)); self:SetBackdropColor(0.10,0.20,0.20,1)
            else self:SetBackdropBorderColor(unpack(COLORS.border)); self:SetBackdropColor(unpack(COLORS.cardAlt)) end
        end
        RegisterOptionWidget(button)
    end

    local expand = CreateFrame("Button", nil, tabs, "BackdropTemplate")
    expand:SetSize(30, 30)
    ApplyBackdrop(expand, COLORS.cardAlt, COLORS.border)
    local gridOffsets = { {-5, 5}, {5, 5}, {-5, -5}, {5, -5} }
    for _, offset in ipairs(gridOffsets) do
        local square = expand:CreateTexture(nil, "ARTWORK")
        square:SetTexture("Interface\\Buttons\\WHITE8X8")
        square:SetSize(7, 7)
        square:SetPoint("CENTER", offset[1], offset[2])
        square:SetVertexColor(unpack(COLORS.accent))
    end
    AddTooltip(expand, "All specializations", "Expand or collapse specializations from other classes.")
    expand:SetScript("OnClick", function()
        tabs._expanded = not tabs._expanded
        tabs:Reflow(content:GetWidth())
    end)

    function tabs:Reflow(availableWidth)
        availableWidth = math.max(40, tonumber(availableWidth) or self:GetWidth() or 0)
        local visible = {}
        for index, specID in ipairs(specs) do
            local button = buttons[index]
            local show = self._expanded or not playerClassID or SPEC_CLASS_ID[specID] == playerClassID
            button:SetShown(show)
            if show then visible[#visible + 1] = button end
        end
        visible[#visible + 1] = expand

        local columns = math.max(1, math.min(#visible, math.floor((availableWidth - 20) / 36)))
        local rows = math.ceil(#visible / columns)
        local height = rows * 34 + 8
        self:SetHeight(height)
        for index, button in ipairs(visible) do
            local column = (index - 1) % columns
            local row = math.floor((index - 1) / columns)
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", 10 + column * 36, -4 - row * 34)
        end
        expand:SetBackdropBorderColor(unpack(self._expanded and COLORS.teal or COLORS.border))
        expand:SetBackdropColor(unpack(self._expanded and {0.10, 0.20, 0.20, 1} or COLORS.cardAlt))

        local sectionY = self._topY - height - 6
        ns.SpecSectionY = sectionY
        for specID, section in pairs(ns.SpecSections or {}) do
            section:ClearAllPoints()
            section:SetPoint("TOPLEFT", 0, sectionY)
            section:SetPoint("TOPRIGHT", 0, sectionY)
            ns.SpecSectionBottom[specID] = sectionY - section:GetHeight() - 10
        end
        local selected = ns.SelectedOptionsSpec
        if selected and ns.SpecSectionBottom and ns.SpecSectionBottom[selected] then
            content:SetHeight(-ns.SpecSectionBottom[selected] + 10)
        end
    end

    ns.SpecTabs = tabs
    tabs.buttonsBySpec = {}
    for index, specID in ipairs(specs) do tabs.buttonsBySpec[specID] = buttons[index] end
    tabs:Reflow(content:GetWidth())
    return ns.SpecSectionY
end

function ns:EnsureOptionsSpec(specID)
    if not self.SUPPORTED_SPECS[specID] or not self.OptionsContent then return nil end
    if not self.SpecSections[specID] then
        self._BuildingSpecID = specID
        local bottom, section = BuildSpecSection(self.OptionsContent, specID, self.SpecSectionY)
        self._BuildingSpecID = nil
        self.SpecSections[specID] = section
        self.SpecSectionBottom[specID] = bottom
        section:Hide()
    end
    return self.SpecSections[specID]
end

function ns:GetCurrentOptionsSpec()
    if GetSpecialization and GetSpecializationInfo then
        local specializationIndex = GetSpecialization()
        if specializationIndex then
            local ok, specID = pcall(GetSpecializationInfo, specializationIndex)
            if ok and self.SUPPORTED_SPECS[specID] then
                return specID
            end
        end
    end
    if self.Runtime.specID and self.SUPPORTED_SPECS[self.Runtime.specID] then
        return self.Runtime.specID
    end
    return self.SPEC_ORDER[1]
end

function ns:RebuildOptionsSpec(specID)
    local scrollPosition = self.OptionsScroll and self.OptionsScroll:GetVerticalScroll() or 0
    local old = self.SpecSections and self.SpecSections[specID]
    if old then old:Hide() end
    local kept = {}
    for _, widget in ipairs(self.OptionWidgets or {}) do
        if widget._resSpecID ~= specID then kept[#kept + 1] = widget end
    end
    self.OptionWidgets = kept
    self.SpecSections[specID] = nil
    self.SpecSectionBottom[specID] = nil
    self:ShowOptionsSpec(specID, scrollPosition)
end

function ns:ShowOptionsSpec(specID, preservedScrollPosition)
    if not self.SUPPORTED_SPECS[specID] then return end
    self.SelectedOptionsSpec=specID
    self:EnsureOptionsSpec(specID)
    local soundSets = self.SoundSetWindow
    if soundSets and soundSets:IsShown() and soundSets.SetSpec then
        soundSets:SetSpec(specID)
    end
    for id,section in pairs(self.SpecSections or {}) do section:SetShown(id==specID) end
    if self.OptionsContent and self.SpecSectionBottom and self.SpecSectionBottom[specID] then
        self.OptionsContent:SetHeight(-self.SpecSectionBottom[specID]+10)
    end
    if self.OptionsScroll then
        local scrollPosition = preservedScrollPosition or 0
        self.OptionsScroll:SetVerticalScroll(scrollPosition)
        -- The scroll range is recalculated after the rebuilt section receives
        -- its new height. Restore once more on the next frame so adding or
        -- removing a layer never jumps the editor back to the top.
        if preservedScrollPosition ~= nil and C_Timer and C_Timer.After then
            local scroll = self.OptionsScroll
            C_Timer.After(0, function()
                if ns.SelectedOptionsSpec == specID and scroll then
                    scroll:SetVerticalScroll(scrollPosition)
                end
            end)
        end
    end
    self:RefreshOptions()
end

function ns:CreateOptions()
    if self.OptionsPanel then return end
    self.OptionWidgets = {}

    local panel = CreateFrame("Frame", "ResonanceOptionsPanel", UIParent, "BackdropTemplate")
    local uiWidth, uiHeight = UIParent:GetSize()
    panel:SetSize(math.min(1260, uiWidth - 40), math.min(760, uiHeight - 40))
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("FULLSCREEN_DIALOG")
    panel:SetFrameLevel(500)
    panel:SetToplevel(true)
    panel:SetMovable(true)
    panel:SetResizable(true)
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    if panel.SetResizeBounds then
        local minimumWidth = math.min(900, uiWidth - 20)
        panel:SetResizeBounds(minimumWidth, 540, math.max(minimumWidth, uiWidth - 20), math.max(540, uiHeight - 20))
    end
    ApplyBackdrop(panel, COLORS.panel, COLORS.border)
    AddArcaneTrim(panel, "window")
    self.OptionsPanel = panel
    -- Keep a partially constructed panel invisible if a future widget errors.
    panel:Hide()

    local close = CreateCloseButton(panel)
    close:SetPoint("TOPRIGHT", -4, -4)

    local resizer = CreateFrame("Button", nil, panel)
    resizer:SetSize(22, 22)
    resizer:SetPoint("BOTTOMRIGHT", -3, 3)
    local resizeTexture = resizer:CreateTexture(nil, "ARTWORK")
    resizeTexture:SetAllPoints()
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizer:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then panel:StartSizing("BOTTOMRIGHT") end
    end)
    resizer:SetScript("OnMouseUp", function() panel:StopMovingOrSizing() end)

    local header = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 12, -12)
    header:SetPoint("TOPRIGHT", -12, -12)
    header:SetHeight(76)
    ApplyBackdrop(header, { 0.085, 0.055, 0.14, 1 }, COLORS.accent)
    AddArcaneTrim(header, "header")
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() panel:StartMoving() end)
    header:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(42, 42)
    icon:SetPoint("LEFT", 14, 0)
    icon:SetTexture("Interface\\Icons\\Spell_Mage_ArcaneOrb")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local title = CreateText(header, "GameFontNormalLarge", "Resonance")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -1)
    title:SetTextColor(unpack(COLORS.accent))
    local subtitle = CreateText(header, "GameFontHighlightSmall", "Native spell layers • precise moments • character/spec sound sets")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -4)
    subtitle:SetTextColor(unpack(COLORS.muted))

    local version = CreateText(header, "GameFontHighlightSmall", "v" .. self.VERSION .. "  •  Retail 12.1")
    version:SetPoint("TOPRIGHT", -18, -16)
    version:SetTextColor(unpack(COLORS.teal))
    local creator = CreateText(header, "GameFontHighlightSmall", "by Mimezu")
    creator:SetPoint("TOPRIGHT", version, "BOTTOMRIGHT", 0, -4)
    creator:SetTextColor(unpack(COLORS.muted))

    local helpButton = CreateButton(header, "?  Help", 72, function() ns:ToggleHelp() end)
    helpButton:SetPoint("RIGHT", header, "RIGHT", -142, 0)
    self.HelpButton = helpButton

    -- Normal releases have no footer controls. Keep only enough clearance for
    -- the resize grip; the wider debug footer is reserved dynamically when
    -- the internal catalog tools are brought back.
    local footerInset = DEBUG_SOUND_TOOLS_VISIBLE and 52 or 12
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, footerInset)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(math.max(760, panel:GetWidth() - 50))
    scroll:SetScrollChild(content)
    SkinScrollFrame(scroll)
    self.OptionsContent=content
    self.OptionsScroll=scroll

    local y = 0
    y = BuildGeneral(content, y)
    y = BuildSpecTabs(content,y)
    self.SpecSections={}; self.SpecSectionBottom={}
    self.SpecSectionY=y
    self.SelectedOptionsSpec=self:GetCurrentOptionsSpec()
    self:EnsureOptionsSpec(self.SelectedOptionsSpec)
    self.SpecSections[self.SelectedOptionsSpec]:Show()
    content:SetHeight(-self.SpecSectionBottom[self.SelectedOptionsSpec]+10)
    local function ReflowContentWidth(width)
        if not width or width <= 0 then width = panel:GetWidth() - 50 end
        local contentWidth = math.max(760, width - 8)
        content:SetWidth(contentWidth)
        if ns.SpecTabs and ns.SpecTabs.Reflow then
            ns.SpecTabs:Reflow(contentWidth)
        end
        for _, section in pairs(ns.SpecSections or {}) do
            if section.Reflow then section:Reflow() end
        end
    end
    -- A UIPanelScrollFrame can report its previous (or zero) viewport width
    -- while this standalone window is still hidden.  Keep the reflow on the
    -- panel itself too, so opening a resized window never leaves a narrow
    -- content column and a large unused strip at the right.
    panel._resonanceReflowContent = ReflowContentWidth
    panel:SetScript("OnSizeChanged", function()
        ReflowContentWidth(scroll:GetWidth())
    end)
    scroll:SetScript("OnSizeChanged", function(_, width) ReflowContentWidth(width) end)
    -- Anchored ScrollFrames do not always emit OnSizeChanged before their
    -- first show. Reflow once now and once on the next frame so a persisted
    -- large editor width is never left with a narrow, empty content column.
    ReflowContentWidth(scroll:GetWidth())
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if ns.OptionsPanel == panel then ReflowContentWidth(scroll:GetWidth()) end
        end)
    end

    if DEBUG_SOUND_TOOLS_VISIBLE then
        local saveSorting = CreateButton(panel, "SAVE sorting changes", 190, function()
            local moveCount, deletionCount = ns:GetSortingDraftCounts()
            ns:SaveCategoryDraft()
            ns:RefreshOptions()
            if ns.SoundPicker and ns.SoundPicker:IsShown() then ns.SoundPicker:RefreshSounds() end
            ns:Print(string.format("Saved %d category moves and %d deletion marks. Log out normally before asking Codex to apply them.", moveCount, deletionCount))
        end, true)
        saveSorting:SetPoint("BOTTOMLEFT", 18, 14)

        local sortingStatus = CreateText(panel, "GameFontHighlightSmall", "")
        sortingStatus:SetPoint("LEFT", saveSorting, "RIGHT", 12, 0)
        sortingStatus:SetPoint("RIGHT", panel, "RIGHT", -18, 0)
        sortingStatus:SetJustifyH("LEFT")
        sortingStatus:SetWordWrap(false)
        saveSorting.refresh = function(self)
            local visible = IsSoundSortingDebugActive()
            local dirty = visible and ns:HasUnsavedSortingChanges()
            local moveCount, deletionCount = ns:GetSortingDraftCounts()
            self:SetShown(visible)
            self:SetEnabled(dirty == true)
            self:SetText(dirty and "SAVE sorting changes" or "Sorting changes saved")
            sortingStatus:SetShown(visible)
            sortingStatus:SetText(dirty
                and string.format("Unsaved • %d moved • %d delete", moveCount, deletionCount)
                or string.format("Saved • %d moved • %d delete", moveCount, deletionCount))
            sortingStatus:SetTextColor(unpack(dirty and {0.96, 0.66, 0.16, 1} or COLORS.teal))
        end
        RegisterOptionWidget(saveSorting)
    end

    panel:SetScript("OnShow", function()
        panel:Raise()
        ReflowContentWidth(scroll:GetWidth())
        ns:ShowOptionsSpec(ns:GetCurrentOptionsSpec())
        -- The anchored scroll viewport reaches its final dimensions after
        -- the first visible frame. Reflow once more so a persisted wide
        -- editor always fills its frame immediately.
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if ns.OptionsPanel == panel and panel:IsShown() then
                    ReflowContentWidth(scroll:GetWidth())
                end
            end)
        end
        if ns.ResumeTutorialFromOptions then ns:ResumeTutorialFromOptions() end
    end)
    panel:SetScript("OnHide", function()
        panel:StopMovingOrSizing()
        if ns.CloseHelp then ns:CloseHelp() end
        if ns.PauseTutorial then ns:PauseTutorial("options-hidden") end
    end)
    panel:Hide()
    if UISpecialFrames then
        UISpecialFrames[#UISpecialFrames + 1] = panel:GetName()
    end

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local launcher = CreateFrame("Frame", "ResonanceSettingsLauncher", UIParent)
        launcher.name = "Resonance"
        local launcherTitle = CreateText(launcher, "GameFontNormalHuge", "Resonance")
        launcherTitle:SetPoint("TOPLEFT", 24, -24)
        launcherTitle:SetTextColor(unpack(COLORS.accent))
        local launcherText = CreateText(launcher, "GameFontHighlight", "Resonance uses a standalone window so every per-spell control remains visible.")
        launcherText:SetPoint("TOPLEFT", launcherTitle, "BOTTOMLEFT", 0, -12)
        local openButton = CreateButton(launcher, "Open Resonance", 180, function() ns:OpenOptions() end, true)
        openButton:SetPoint("TOPLEFT", launcherText, "BOTTOMLEFT", 0, -20)
        local category = Settings.RegisterCanvasLayoutCategory(launcher, "Resonance", "Resonance")
        Settings.RegisterAddOnCategory(category)
        self.SettingsCategoryID = (category.GetID and category:GetID()) or category.ID or "Resonance"
    elseif InterfaceOptions_AddCategory then
        -- The standalone window remains available through /res and the minimap button.
    end
end

function ns:OpenOptions()
    if self.OptionsBuildError then
        self:Print("The options window could not be built. Reload after updating Resonance.")
        return
    end
    if not self.OptionsPanel then self:CreateOptions() end
    self.SelectedOptionsSpec = self:GetCurrentOptionsSpec()
    self.OptionsPanel:Show()
    -- Select the played specialization on every open.  This also refreshes
    -- the just-created panel before its first visible frame.
    self:ShowOptionsSpec(self.SelectedOptionsSpec)
    self.OptionsPanel:Raise()
end

StaticPopupDialogs.RESONANCE_RESET_CONFIRM = {
    text = "Reset all Resonance options to their defaults?",
    button1 = YES,
    button2 = NO,
    OnAccept = function() ns:ResetDatabase() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
