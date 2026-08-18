local _, ns = ...

local Atan2 = math.atan2 or function(y, x)
    if x > 0 then return math.atan(y / x) end
    if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
    if x < 0 and y < 0 then return math.atan(y / x) - math.pi end
    if x == 0 and y > 0 then return math.pi / 2 end
    if x == 0 and y < 0 then return -math.pi / 2 end
    return 0
end

-- Match the shape-aware positioning used by LibDBIcon while keeping Resonance
-- dependency-free. Edit Mode can resize and scale the minimap, so a fixed
-- 80-pixel orbit is not reliable even on Blizzard's circular minimap.
local MINIMAP_SHAPES = {
    ["ROUND"] = { true, true, true, true },
    ["SQUARE"] = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
    ["SIDE-LEFT"] = { false, true, false, true },
    ["SIDE-RIGHT"] = { true, false, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, true, true },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function SetPosition(button)
    local angle = math.rad(ns.DB.minimap.angle or 225)
    local x, y = math.cos(angle), math.sin(angle)
    local quadrant = 1
    if x < 0 then quadrant = quadrant + 1 end
    if y > 0 then quadrant = quadrant + 2 end

    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadrants = MINIMAP_SHAPES[shape] or MINIMAP_SHAPES.ROUND
    local widthRadius = (Minimap:GetWidth() / 2) + 5
    local heightRadius = (Minimap:GetHeight() / 2) + 5
    if quadrants[quadrant] then
        x, y = x * widthRadius, y * heightRadius
    else
        local diagonalWidth = math.sqrt(2 * widthRadius * widthRadius) - 10
        local diagonalHeight = math.sqrt(2 * heightRadius * heightRadius) - 10
        x = math.max(-widthRadius, math.min(x * diagonalWidth, widthRadius))
        y = math.max(-heightRadius, math.min(y * diagonalHeight, heightRadius))
    end

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function UpdateAngle(button)
    local minimapX, minimapY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    ns.DB.minimap.angle = math.deg(Atan2(cursorY - minimapY, cursorX - minimapX)) % 360
    SetPosition(button)
end

function ns:CreateMinimapButton()
    if self.MinimapButton then return end
    local button = CreateFrame("Button", "ResonanceMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetMovable(true)
    button.minimapButton = true

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\Icons\\Spell_Mage_ArcaneOrb")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            local rule = ns.Runtime.activeRules and ns.Runtime.activeRules[1]
            if rule then ns:PlayRule(rule, true) else ns:OpenSoundPicker(nil, function() end, "arcane") end
        else
            ns:OpenOptions()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", UpdateAngle)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Resonance", 1, 1, 1)
        GameTooltip:AddLine("Left-click: Open settings", nil, nil, nil, true)
        GameTooltip:AddLine("Right-click: Preview an active sound", nil, nil, nil, true)
        GameTooltip:AddLine("Drag: Move around the minimap", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)

    self.MinimapButton = button
    Minimap:HookScript("OnSizeChanged", function()
        if ns.MinimapButton and ns.DB then SetPosition(ns.MinimapButton) end
    end)
    self:UpdateMinimapButton()
end

function ns:UpdateMinimapButton()
    if not self.MinimapButton or not self.DB then return end
    SetPosition(self.MinimapButton)
    self.MinimapButton:SetShown(not self.DB.minimap.hide)
end

function Resonance_AddonCompartmentFunction()
    ns:OpenOptions()
end
