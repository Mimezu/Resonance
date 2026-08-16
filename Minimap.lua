local _, ns = ...

local Atan2 = math.atan2 or function(y, x)
    if x > 0 then return math.atan(y / x) end
    if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
    if x < 0 and y < 0 then return math.atan(y / x) - math.pi end
    if x == 0 and y > 0 then return math.pi / 2 end
    if x == 0 and y < 0 then return -math.pi / 2 end
    return 0
end

local function SetPosition(button)
    local angle = math.rad(ns.DB.minimap.angle or 225)
    local radius = 80
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function UpdateAngle(button)
    local minimapX, minimapY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    ns.DB.minimap.angle = math.deg(Atan2(cursorY - minimapY, cursorX - minimapX))
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
