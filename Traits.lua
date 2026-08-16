local _, ns = ...

local function SafeCall(func, ...)
    if type(func) ~= "function" then
        return nil
    end
    local ok, result = pcall(func, ...)
    if not ok then
        return nil
    end
    return result
end

local function MarkSpell(capabilities, spellID, rank)
    if not ns:IsSafeValue(spellID) or type(spellID) ~= "number" then
        return
    end
    capabilities.hasSpellID[spellID] = true
    if ns:IsSafeValue(rank) and type(rank) == "number" then
        capabilities.rankBySpellID[spellID] = math.max(capabilities.rankBySpellID[spellID] or 0, rank)
    end
end

function ns:ScanCapabilities()
    local capabilities = {
        hasSpellID = {},
        rankBySpellID = {},
        groups = {},
        configID = nil,
        activeHeroSpecID = nil,
        activeHeroSpecName = nil,
    }

    local configID = C_ClassTalents and SafeCall(C_ClassTalents.GetActiveConfigID)
    if self:IsSafeValue(configID) and type(configID) == "number" then
        capabilities.configID = configID

        -- GetActiveHeroTalentSpec returns a TraitSubTreeID, not a hero
        -- specialization ID. GetHeroTalentSpecInfo accepts a different ID
        -- namespace and can therefore return the wrong tree (for example,
        -- Chronowarden while Flameshaper is active). Resolve the active
        -- subtree through C_Traits, which is also what Blizzard's talent UI
        -- and maintained talent addons use.
        local activeSubTreeID = C_ClassTalents and SafeCall(C_ClassTalents.GetActiveHeroTalentSpec)
        if not self:IsSafeValue(activeSubTreeID) or type(activeSubTreeID) ~= "number" then
            activeSubTreeID = nil
        end

        -- Defensive fallback for clients where the convenience API has not
        -- populated yet: inspect only the current specialization's subtrees
        -- and use the one explicitly marked active.
        if not activeSubTreeID and C_ClassTalents and C_ClassTalents.GetHeroTalentSpecsForClassSpec then
            local specializationIndex = GetSpecialization and GetSpecialization()
            local specID
            if self:IsSafeValue(specializationIndex) and type(specializationIndex) == "number" then
                specID = GetSpecializationInfo and SafeCall(GetSpecializationInfo, specializationIndex)
            end
            if self:IsSafeValue(specID) and type(specID) == "number" then
                local subTreeIDs = SafeCall(C_ClassTalents.GetHeroTalentSpecsForClassSpec, configID, specID)
                if self:IsSafeTable(subTreeIDs) then
                    for _, subTreeID in ipairs(subTreeIDs) do
                        if self:IsSafeValue(subTreeID) and type(subTreeID) == "number" then
                            local subTreeInfo = C_Traits and SafeCall(C_Traits.GetSubTreeInfo, configID, subTreeID)
                            if self:IsSafeTable(subTreeInfo) and subTreeInfo.isActive == true then
                                activeSubTreeID = subTreeID
                                break
                            end
                        end
                    end
                end
            end
        end

        if activeSubTreeID then
            capabilities.activeHeroSpecID = activeSubTreeID
            capabilities.activeHeroSubTreeID = activeSubTreeID
            local subTreeInfo = C_Traits and SafeCall(C_Traits.GetSubTreeInfo, configID, activeSubTreeID)
            if self:IsSafeTable(subTreeInfo) and self:IsSafeValue(subTreeInfo.name)
                and type(subTreeInfo.name) == "string" then
                capabilities.activeHeroSpecName = subTreeInfo.name
            end
        end

        local configInfo = C_Traits and SafeCall(C_Traits.GetConfigInfo, configID)
        local treeIDs
        if self:IsSafeTable(configInfo) then
            treeIDs = configInfo.treeIDs
        end
        if self:IsSafeTable(treeIDs) then
            for _, treeID in ipairs(treeIDs) do
                if self:IsSafeValue(treeID) then
                    local nodeIDs = SafeCall(C_Traits.GetTreeNodes, treeID)
                    if self:IsSafeTable(nodeIDs) then
                        for _, nodeID in ipairs(nodeIDs) do
                            local nodeInfo = SafeCall(C_Traits.GetNodeInfo, configID, nodeID)
                            if self:IsSafeTable(nodeInfo) then
                                -- Talent configurations can retain purchased
                                -- ranks for both hero subtrees. Only scan nodes
                                -- from the currently selected subtree; otherwise
                                -- capability gates from both hero trees become
                                -- true at the same time.
                                local nodeSubTreeID = nodeInfo.subTreeID
                                local inActiveSubTree = not (self:IsSafeValue(nodeSubTreeID)
                                    and type(nodeSubTreeID) == "number")
                                    or nodeSubTreeID == activeSubTreeID
                                local activeEntry = inActiveSubTree and nodeInfo.activeEntry or nil
                                if self:IsSafeTable(activeEntry) then
                                    local entryID = activeEntry.entryID
                                    local rank = activeEntry.rank
                                    if not self:IsSafeValue(rank) or type(rank) ~= "number" then
                                        rank = nodeInfo.activeRank
                                    end
                                    if self:IsSafeValue(entryID) and type(entryID) == "number"
                                        and self:IsSafeValue(rank) and type(rank) == "number" and rank > 0 then
                                        local entryInfo = SafeCall(C_Traits.GetEntryInfo, configID, entryID)
                                        local definitionID
                                        if self:IsSafeTable(entryInfo) then
                                            definitionID = entryInfo.definitionID
                                        end
                                        if self:IsSafeValue(definitionID) and type(definitionID) == "number" then
                                            local definitionInfo = SafeCall(C_Traits.GetDefinitionInfo, definitionID)
                                            if self:IsSafeTable(definitionInfo) then
                                                local overriddenSpellID = definitionInfo.overriddenSpellID
                                                local spellID = definitionInfo.spellID
                                                -- Replacement talents can expose a passive/base
                                                -- spell on the selected node and a separate active
                                                -- override in the spellbook. Both identities belong
                                                -- to the purchased talent and must be retained for
                                                -- capability gates such as Apex detection.
                                                if self:IsSafeValue(spellID) and type(spellID) == "number" then
                                                    MarkSpell(capabilities, spellID, rank)
                                                end
                                                if self:IsSafeValue(overriddenSpellID) and type(overriddenSpellID) == "number" then
                                                    MarkSpell(capabilities, overriddenSpellID, rank)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for groupName, spellIDs in pairs(self.CapabilityGroups) do
        for _, spellID in ipairs(spellIDs) do
            if capabilities.hasSpellID[spellID] then
                capabilities.groups[groupName] = true
                break
            end
        end
    end

    self.Runtime.capabilities = capabilities
    return capabilities
end

function ns:HasCapability(groupName)
    return self.Runtime.capabilities.groups[groupName] == true
end

function ns:GetHeroTreeLabel(specID)
    local detectedName = self.Runtime.capabilities.activeHeroSpecName
    if type(detectedName) == "string" and detectedName ~= "" then
        return detectedName
    end
    for _, hero in ipairs((self.HeroTreesBySpec and self.HeroTreesBySpec[specID]) or {}) do
        if self:HasCapability(hero.capability) then return hero.label end
    end
    return "Not detected"
end

function ns:GetApexLabel(specID)
    local apex = self.ApexBySpec and self.ApexBySpec[specID]
    if not apex then return "Not catalogued" end
    if apex and self:HasCapability(apex.capability) then return apex.label end
    return "Not detected"
end
