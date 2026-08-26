local _, ns = ...

local UI = ns.UI
local COLORS = UI.COLORS
local TUTORIAL_VERSION = 1

local Tutorial = {
    active = false,
    paused = false,
    step = 1,
    specID = nil,
    ruleID = nil,
    pickerCommitted = false,
}
ns.Tutorial = Tutorial

local function SetTutorialRootShown(shown)
    local root = Tutorial.root
    if not root then return end
    if shown then
        if not root:GetScript("OnUpdate") then root:SetScript("OnUpdate", root._ticker) end
        root:Show()
    else
        root:SetScript("OnUpdate", nil)
        root:Hide()
    end
end

local function TutorialDB()
    ns.DB.tutorial = type(ns.DB.tutorial) == "table" and ns.DB.tutorial or {}
    ns.DB.tutorial.completedVersion = tonumber(ns.DB.tutorial.completedVersion) or 0
    ns.DB.tutorial.lastStep = tonumber(ns.DB.tutorial.lastStep) or 1
    return ns.DB.tutorial
end

local function IsUsableFrame(frame)
    return frame and frame.IsVisible and frame:IsVisible() and frame.GetLeft and frame:GetLeft() ~= nil
end

local function FindDemoRule(specID)
    local section = ns:EnsureOptionsSpec(specID)
    if not section then return nil end
    local fallback
    for _, rule in ipairs(ns.RulesBySpec[specID] or {}) do
        local cell = section.ruleCells and section.ruleCells[rule.id]
        if cell and rule.moment ~= "Casting" then
            fallback = fallback or rule
            local layer = ns:GetLayerConfig(rule, 1)
            if ns:GetRuleEnabled(rule) and layer and layer.soundID then return rule end
        end
    end
    return fallback
end

local function CurrentCell()
    local section = Tutorial.specID and ns.SpecSections and ns.SpecSections[Tutorial.specID]
    return section and section.ruleCells and section.ruleCells[Tutorial.ruleID]
end

local STEPS = {
    {
        title = "Make every cast feel better",
        body = "Resonance adds optional layers around Blizzard's spell audio. It never replaces the original sound.\n\nThe tour never saves or overwrites a set for you.",
    },
    {
        title = "Choose a spell moment",
        body = "Each card is one spell moment.\n\nCast follows a successful spell. Release follows a completed empower. Casting begins with a real cast, channel, or empower bar and fades when it ends.",
        target = CurrentCell,
        scroll = true,
    },
    {
        title = "Choose the first layer",
        body = "Click a sound name to open the library. It starts on the selected sound, so nearby choices are easy to compare.",
        target = function()
            local cell = CurrentCell()
            return cell and cell.swatches and cell.swatches[1]
        end,
        scroll = true,
        action = "Open sound picker",
        run = function()
            local cell = CurrentCell()
            if cell and cell.swatches and cell.swatches[1] then cell.swatches[1]:Click("LeftButton") end
        end,
    },
    {
        title = "Audition before you commit",
        body = "Click a card to preview it. Search by name or source, or browse a category.\n\nNothing changes until you choose Okay. Cancel keeps the current sound.",
        target = function() return ns.SoundPicker end,
    },
    {
        title = "Build a layered accent",
        body = "Each row is one layer. A 0 ms delay plays immediately; 60–180 ms creates an echo or tail.\n\nUse + layer when a spell needs more detail. Extra rows can be removed.",
        target = CurrentCell,
        scroll = true,
    },
    {
        title = "Hear only what you added",
        body = "The play button previews this moment's enabled layers and delays. Blizzard's original spell sound is not included.",
        target = function()
            local cell = CurrentCell()
            return cell and cell.preview
        end,
        scroll = true,
        action = "Preview layers",
        run = function()
            local cell = CurrentCell()
            if cell and cell.preview then cell.preview:Click() end
        end,
    },
    {
        title = "Keep your version",
        body = "Your first edit creates a Personal set for this character and specialization. Open Presets / saved sets to name another version or save changes.",
        target = function()
            local section = Tutorial.specID and ns.SpecSections and ns.SpecSections[Tutorial.specID]
            return section and section.saveSets
        end,
        scroll = true,
        action = "Open saved sets",
        run = function()
            local section = Tutorial.specID and ns.SpecSections and ns.SpecSections[Tutorial.specID]
            if section and section.saveSets then section.saveSets:Click() end
        end,
    },
    {
        title = "Your sound set is ready",
        body = "Save a named set to keep this mix. You can later export it to a friend or import theirs.\n\nBuilt-in presets stay protected.",
        target = function()
            local window = ns.SoundSetWindow
            if not window then return nil end
            if window.namePanel and window.namePanel:IsShown() then return window.namePanel end
            return window.create
        end,
        action = "Finish tutorial",
        finish = true,
    },
}

local function CreateOverlay()
    if Tutorial.root then return end

    local root = CreateFrame("Frame", "ResonanceTutorialOverlay", UIParent)
    root:SetAllPoints(UIParent)
    root:SetFrameStrata("TOOLTIP")
    root:SetFrameLevel(1180)
    root:EnableMouse(false)
    root:Hide()
    Tutorial.root = root

    local function Blocker()
        local frame = CreateFrame("Frame", nil, root, "BackdropTemplate")
        frame:SetFrameLevel(root:GetFrameLevel())
        frame:EnableMouse(true)
        UI.ApplyBackdrop(frame, { 0.005, 0.008, 0.018, 0.76 }, { 0, 0, 0, 0 })
        return frame
    end
    Tutorial.full = Blocker()
    Tutorial.full:SetAllPoints(root)
    Tutorial.blockers = { Blocker(), Blocker(), Blocker(), Blocker() }

    local highlight = CreateFrame("Frame", nil, root, "BackdropTemplate")
    highlight:SetFrameLevel(root:GetFrameLevel() + 2)
    highlight:EnableMouse(false)
    UI.ApplyBackdrop(highlight, { 0, 0, 0, 0 }, COLORS.teal)
    Tutorial.highlight = highlight

    local coach = CreateFrame("Frame", nil, root, "BackdropTemplate")
    coach:SetSize(390, 218)
    coach:SetFrameLevel(root:GetFrameLevel() + 10)
    coach:EnableMouse(true)
    UI.ApplyBackdrop(coach, COLORS.window, COLORS.border)
    UI.AddArcaneTrim(coach, "window")
    UI.SkinPanel(coach, { inset = true })
    Tutorial.coach = coach

    coach.progress = UI.CreateText(coach, "GameFontHighlightSmall", "")
    coach.progress:SetPoint("TOPLEFT", 18, -15)
    coach.progress:SetTextColor(unpack(COLORS.teal))
    coach.title = UI.CreateText(coach, "GameFontNormalLarge", "")
    coach.title:SetPoint("TOPLEFT", coach.progress, "BOTTOMLEFT", 0, -7)
    coach.title:SetPoint("RIGHT", coach, "RIGHT", -42, 0)
    coach.title:SetJustifyH("LEFT")
    coach.body = UI.CreateText(coach, "GameFontHighlightSmall", "")
    coach.body:SetPoint("TOPLEFT", coach.title, "BOTTOMLEFT", 0, -10)
    coach.body:SetPoint("BOTTOMRIGHT", coach, "BOTTOMRIGHT", -18, 49)
    coach.body:SetJustifyH("LEFT")
    coach.body:SetJustifyV("TOP")
    coach.body:SetWordWrap(true)
    coach.body:SetTextColor(unpack(COLORS.muted))

    coach.close = UI.CreateCloseButton(coach, function() ns:StopTutorial(false) end)
    coach.close:SetPoint("TOPRIGHT", -7, -7)
    coach.back = UI.CreateButton(coach, "Back", 70, function()
        if Tutorial.step == 4 and ns.SoundPicker and ns.SoundPicker:IsShown() then
            ns.SoundPicker:Hide() -- The close signal safely returns to step 3.
        elseif Tutorial.step == 5 then
            -- The picker closes after a successful choice, so returning to its
            -- explanatory step would have no live target. Return to the swatch.
            ns:SetTutorialStep(3)
        elseif Tutorial.step == 8 and ns.SoundSetWindow and ns.SoundSetWindow:IsShown() then
            ns.SoundSetWindow:Hide()
            ns:SetTutorialStep(7)
        else
            ns:SetTutorialStep(Tutorial.step - 1)
        end
    end)
    coach.back:SetPoint("BOTTOMLEFT", 16, 14)
    coach.exit = UI.CreateButton(coach, "Exit", 70, function() ns:StopTutorial(false) end)
    coach.exit:SetPoint("LEFT", coach.back, "RIGHT", 7, 0)
    coach.action = UI.CreateButton(coach, "", 132, function()
        local step = STEPS[Tutorial.step]
        if step.finish then ns:StopTutorial(true)
        elseif step.run then step.run() end
    end, true)
    coach.action:SetPoint("BOTTOMRIGHT", -16, 14)
    coach.next = UI.CreateButton(coach, "Next", 72, function()
        if Tutorial.step == 4 and ns.SoundPicker and ns.SoundPicker:IsShown() then
            Tutorial.pickerCommitted = true
            ns.SoundPicker:Hide()
        end
        ns:SetTutorialStep(Tutorial.step + 1)
    end, true)
    coach.next:SetPoint("RIGHT", coach.action, "LEFT", -7, 0)

    root.elapsed = 0
    root._ticker = function(_, elapsed)
        root.elapsed = root.elapsed + elapsed
        if root.elapsed >= 0.05 then
            root.elapsed = 0
            ns:RenderTutorial()
        end
    end

    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" and Tutorial.active then
            Tutorial.paused = true
            Tutorial.pauseReason = "combat"
            SetTutorialRootShown(false)
            ns:Print("Tutorial paused during combat. It will resume when combat ends.")
        elseif event == "PLAYER_REGEN_ENABLED" and Tutorial.active and Tutorial.paused and Tutorial.pauseReason == "combat" then
            if ns.OptionsPanel and ns.OptionsPanel:IsShown() then
                Tutorial.paused = false
                Tutorial.pauseReason = nil
                SetTutorialRootShown(true)
            else
                Tutorial.pauseReason = "options-hidden"
            end
        end
    end)
end

local function ScrollToTarget(target)
    local scroll = ns.OptionsScroll
    if not target or not scroll or not scroll:IsShown() or not target:GetTop() or not scroll:GetTop() then return end
    local desiredTop = scroll:GetTop() - 72
    local delta = desiredTop - target:GetTop()
    if math.abs(delta) < 8 then return end
    local maximum = scroll.GetVerticalScrollRange and scroll:GetVerticalScrollRange() or 0
    scroll:SetVerticalScroll(math.max(0, math.min(maximum, (scroll:GetVerticalScroll() or 0) + delta)))
end

function ns:RenderTutorial()
    if not Tutorial.active or Tutorial.paused or not Tutorial.root or not Tutorial.root:IsShown() then return end
    local step = STEPS[Tutorial.step]
    if not step then return end
    local target = step.target and step.target() or nil

    if step.scroll and target then ScrollToTarget(target) end
    local hasTarget = IsUsableFrame(target)
    Tutorial.full:SetShown(not hasTarget)
    Tutorial.highlight:SetShown(hasTarget)
    for _, blocker in ipairs(Tutorial.blockers) do blocker:SetShown(hasTarget) end

    if hasTarget then
        local screenWidth, screenHeight = UIParent:GetSize()
        local left = math.max(0, (target:GetLeft() or 0) - 7)
        local right = math.min(screenWidth, (target:GetRight() or screenWidth) + 7)
        local bottom = math.max(0, (target:GetBottom() or 0) - 7)
        local top = math.min(screenHeight, (target:GetTop() or screenHeight) + 7)
        local b = Tutorial.blockers
        b[1]:ClearAllPoints(); b[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, top); b[1]:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
        b[2]:ClearAllPoints(); b[2]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0); b[2]:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", 0, bottom)
        b[3]:ClearAllPoints(); b[3]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, bottom); b[3]:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", left, top)
        b[4]:ClearAllPoints(); b[4]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", right, bottom); b[4]:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", 0, top)
        Tutorial.highlight:ClearAllPoints()
        Tutorial.highlight:SetPoint("TOPLEFT", target, "TOPLEFT", -7, 7)
        Tutorial.highlight:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", 7, -7)

        Tutorial.coach:ClearAllPoints()
        if bottom > Tutorial.coach:GetHeight() + 32 then
            Tutorial.coach:SetPoint("BOTTOM", target, "TOP", 0, 18)
        else
            Tutorial.coach:SetPoint("TOP", target, "BOTTOM", 0, -18)
        end
        Tutorial.coach:SetClampedToScreen(true)
    else
        Tutorial.coach:ClearAllPoints()
        Tutorial.coach:SetPoint("CENTER")
    end
end

function ns:SetTutorialStep(stepNumber)
    stepNumber = math.max(1, math.min(#STEPS, tonumber(stepNumber) or 1))
    Tutorial.step = stepNumber
    TutorialDB().lastStep = stepNumber
    local step = STEPS[stepNumber]
    local coach = Tutorial.coach
    coach.progress:SetText(string.format("INTERACTIVE TOUR  •  %d / %d", stepNumber, #STEPS))
    coach.title:SetText(step.title)
    local body = step.body
    if stepNumber == 1 and Tutorial.hadDirtyWork then
        body = body .. "\n\n|cffeda940You already have unsaved changes. The tutorial keeps them and never saves or overwrites them.|r"
    end
    coach.body:SetText(body)
    coach.back:SetEnabled(stepNumber > 1)
    coach.next:SetShown(not step.finish and stepNumber ~= 3 and stepNumber ~= 4 and stepNumber ~= 6 and stepNumber ~= 7)
    coach.next:SetEnabled(stepNumber < #STEPS)
    coach.action:SetShown(step.action ~= nil)
    if step.action then coach.action:SetText(step.action) end
    if stepNumber == 4 then Tutorial.pickerCommitted = false end
    self:RenderTutorial()
end

function ns:StartTutorial(restart)
    if InCombatLockdown and InCombatLockdown() then
        self:Print("The tutorial uses live UI controls. Start it after combat.")
        return
    end
    CreateOverlay()
    -- A resumed tour always reconstructs its own window state. Do not leave a
    -- stale picker or set dialog over the first target.
    Tutorial.active = false
    if self.SoundPicker then self.SoundPicker:Hide() end
    if self.SoundSetWindow then self.SoundSetWindow:Hide() end
    self:OpenOptions()
    Tutorial.specID = self:GetCurrentOptionsSpec()
    self:ShowOptionsSpec(Tutorial.specID)
    local rule = FindDemoRule(Tutorial.specID)
    if not rule then
        self:Print("No editable spell moment is available for this specialization.")
        return
    end
    Tutorial.ruleID = rule.id
    Tutorial.hadDirtyWork = self:HasUnsavedProfileChanges(Tutorial.specID)
    Tutorial.active = true
    Tutorial.paused = false
    Tutorial.pauseReason = nil
    local savedStep = restart and 1 or TutorialDB().lastStep
    if TutorialDB().completedVersion >= TUTORIAL_VERSION and not restart then savedStep = 1 end
    if savedStep == 4 then savedStep = 3 end
    if savedStep == 8 then savedStep = 7 end
    SetTutorialRootShown(true)
    self:SetTutorialStep(savedStep)
end

function ns:PauseTutorial(reason)
    if not Tutorial.active then return end
    Tutorial.paused = true
    Tutorial.pauseReason = reason
    SetTutorialRootShown(false)
end

function ns:ResumeTutorialFromOptions()
    if not Tutorial.active or not Tutorial.paused then return end
    if InCombatLockdown and InCombatLockdown() then return end
    local currentSpecID = self:GetCurrentOptionsSpec()
    if currentSpecID ~= Tutorial.specID then
        Tutorial.specID = currentSpecID
        self:ShowOptionsSpec(currentSpecID)
        local rule = FindDemoRule(currentSpecID)
        if not rule then
            self:StopTutorial(false)
            self:Print("The tutorial stopped because this specialization has no editable spell moment.")
            return
        end
        Tutorial.ruleID = rule.id
        Tutorial.hadDirtyWork = self:HasUnsavedProfileChanges(currentSpecID)
        Tutorial.step = 1
        TutorialDB().lastStep = 1
        self:Print("Tutorial restarted for " .. (self.SUPPORTED_SPECS[currentSpecID] or "the current specialization") .. ".")
    else
        self:ShowOptionsSpec(Tutorial.specID)
    end
    Tutorial.paused = false
    Tutorial.pauseReason = nil
    if Tutorial.root then
        SetTutorialRootShown(true)
        self:RenderTutorial()
    end
end

function ns:StopTutorial(completed)
    if not Tutorial.active and not Tutorial.root then return end
    if completed then
        TutorialDB().completedVersion = TUTORIAL_VERSION
        TutorialDB().lastStep = 1
        self:Print("Tutorial complete. Save your Personal set whenever you are ready.")
    else
        TutorialDB().lastStep = Tutorial.step
    end
    Tutorial.active = false
    Tutorial.paused = false
    Tutorial.pauseReason = nil
    if not completed then
        if self.SoundPicker and self.SoundPicker:IsShown() then self.SoundPicker:Hide() end
        if self.SoundSetWindow and self.SoundSetWindow:IsShown() then self.SoundSetWindow:Hide() end
    end
    SetTutorialRootShown(false)
end

function ns:TutorialCanCommitSound(soundID)
    if Tutorial.active and Tutorial.step == 4 then
        if not soundID or soundID == Tutorial.initialSoundID then
            Tutorial.coach.title:SetText("Choose a different sound")
            Tutorial.coach.body:SetText("Click another sound card to audition it, then press Okay. Your current layer has not changed.")
            return false
        end
    end
    return true
end

function ns:TutorialSignal(event, value)
    if not Tutorial.active then return end
    if event == "sound-picker-opened" and Tutorial.step == 3 then
        Tutorial.initialSoundID = value
        self:SetTutorialStep(4)
    elseif event == "sound-committed" and Tutorial.step == 4 then
        Tutorial.pickerCommitted = true
        C_Timer.After(0, function() if Tutorial.active then ns:SetTutorialStep(5) end end)
    elseif event == "sound-picker-closed" and Tutorial.step == 4 and not Tutorial.pickerCommitted then
        C_Timer.After(0, function() if Tutorial.active and Tutorial.step == 4 then ns:SetTutorialStep(3) end end)
    elseif event == "sound-sets-opened" and Tutorial.step == 7 then
        self:SetTutorialStep(8)
    elseif event == "sound-sets-closed" and Tutorial.step == 8 then
        self:SetTutorialStep(7)
    elseif event == "sound-set-saved" and Tutorial.step == 8 then
        Tutorial.savedSet = true
        Tutorial.coach.title:SetText("Sound set saved")
        Tutorial.coach.body:SetText("Your named set now keeps this mix for the current character and specialization. You can keep editing, export it, or finish the tour.")
    elseif event == "moment-previewed" and Tutorial.step == 6 then
        C_Timer.After(0.25, function() if Tutorial.active and Tutorial.step == 6 then ns:SetTutorialStep(7) end end)
    end
end
