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

    local activeHeroSpecID = C_ClassTalents and SafeCall(C_ClassTalents.GetActiveHeroTalentSpec)
    if self:IsSafeValue(activeHeroSpecID) and type(activeHeroSpecID) == "number" then
        capabilities.activeHeroSpecID = activeHeroSpecID
        local heroInfo = SafeCall(C_ClassTalents.GetHeroTalentSpecInfo, activeHeroSpecID)
        if self:IsSafeTable(heroInfo) and self:IsSafeValue(heroInfo.name) and type(heroInfo.name) == "string" then
            capabilities.activeHeroSpecName = heroInfo.name
        end
    end

    local configID = C_ClassTalents and SafeCall(C_ClassTalents.GetActiveConfigID)
    if self:IsSafeValue(configID) and type(configID) == "number" then
        capabilities.configID = configID
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
                                local activeEntry = nodeInfo.activeEntry
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
                                                if self:IsSafeValue(overriddenSpellID) and type(overriddenSpellID) == "number" then
                                                    MarkSpell(capabilities, overriddenSpellID, rank)
                                                elseif self:IsSafeValue(spellID) and type(spellID) == "number" then
                                                    MarkSpell(capabilities, spellID, rank)
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
    if apex and self:HasCapability(apex.capability) then return apex.label end
    return "Not selected or not detected"
end
