local _, L = ...

if IsAddOnLoaded('Auctionator') then Auctionator_Search:Hide() end

TradeSkillUIImprovedDB = TradeSkillUIImprovedDB or { size = 55, x = 200, y = 1050, countTab = 0, BlackList = {} }

local function TradeSkillUIImproved_Print(msg)
    print('|cff00ff00TSUII|r: ' .. msg)
end

local function IsInTable(l, e)
    for i,v in pairs(l) do
        if v.recipeID == e then
            return i
        end
    end
    return false
end

local function updatePosition()
    UIPanelWindows['TradeSkillFrame'].area = nil
    TradeSkillFrame:ClearAllPoints()
    TradeSkillFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', TradeSkillUIImprovedDB.x, TradeSkillUIImprovedDB.y)
end

local function isCurrentTab(self)
    if self.tooltip and IsCurrentSpell(self.tooltip) then
        self:SetChecked(true)
        self:RegisterForClicks(nil)
    else
        self:SetChecked(false)
        self:RegisterForClicks('AnyDown')
    end
end

local function updateTabs(init)
    local mainTabs = {}

    if init then
        for i = 1, TradeSkillUIImprovedDB.countTab do
            local tab = _G['TradeSkillUIImprovedTab' .. i]
            if tab and tab:IsShown() then
                tab:Hide()
                tab:UnregisterEvent('TRADE_SKILL_SHOW')
                tab:UnregisterEvent('CURRENT_SPELL_CAST_CHANGED')
            end
        end
    end

    for _, professionID in pairs({GetProfessions()}) do
        local _, _, _, _, _, offset, _, _, _, _ =  GetProfessionInfo(professionID)
        local _, id = GetSpellBookItemInfo(offset + 1, BOOKTYPE_PROFESSION)
        tinsert(mainTabs, id)
    end

    TradeSkillUIImprovedDB.countTab = #mainTabs

    for i, id in pairs(mainTabs) do
        local name, _, icon = GetSpellInfo(id)
        local tab = _G['TradeSkillUIImprovedTab' .. i] or CreateFrame('CheckButton', 'TradeSkillUIImprovedTab' .. i, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
        tab:SetScript('OnEvent', isCurrentTab)
        tab:RegisterEvent('TRADE_SKILL_SHOW')
        tab:RegisterEvent('CURRENT_SPELL_CAST_CHANGED')

        tab.id = id
        tab.tooltip = name
        tab:SetNormalTexture(icon)
        tab:SetAttribute('type', 'spell')
        tab:SetAttribute('spell', name)
        tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, (-44 * i) + -40)
        isCurrentTab(tab)
        tab:Show()
    end
end

local TradeSkillUIImproved = CreateFrame('Frame', 'TradeSkillUIImproved')
TradeSkillUIImproved:RegisterEvent('PLAYER_LOGIN')
TradeSkillUIImproved:RegisterEvent('TRADE_SKILL_DATA_SOURCE_CHANGED')

TradeSkillUIImproved.version = GetAddOnMetadata('TradeSkillUIImproved', 'Version')

TradeSkillUIImproved:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_LOGIN' then
        TradeSkillFrame:SetHeight(TradeSkillUIImprovedDB.size * 16 + 96)
        TradeSkillFrame.RecipeInset:SetHeight(TradeSkillUIImprovedDB.size * 16 + 10)
        TradeSkillFrame.DetailsInset:SetHeight(TradeSkillUIImprovedDB.size * 16 - 10)
        TradeSkillFrame.DetailsFrame:SetHeight(TradeSkillUIImprovedDB.size * 16 - 15)
        TradeSkillFrame.DetailsFrame.Background:SetHeight(TradeSkillUIImprovedDB.size * 16 - 17)
        TradeSkillFrame.DetailsFrame.ExitButton:Hide()
        TradeSkillFrame.LinkToButton:SetPoint('BOTTOMRIGHT', TradeSkillFrame, 'TOPRIGHT', -10, -81)
        TradeSkillFrame.FilterButton:SetPoint('TOPRIGHT', TradeSkillFrame, 'TOPRIGHT', -12, -31)
        TradeSkillFrame.FilterButton:SetHeight(17)
        TradeSkillFrame.RankFrame:SetPoint('TOP', TradeSkillFrame, 'TOP', -17, -33)
        TradeSkillFrame.RankFrame:SetWidth(500)
        TradeSkillFrame.SearchBox:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPLEFT', 163, -60)
        TradeSkillFrame.SearchBox:SetWidth(97)

        if TradeSkillFrame.RecipeList.FilterBar:IsVisible() then
            TradeSkillFrame.RecipeList:SetHeight(TradeSkillUIImprovedDB.size * 16 - 11)
        else
            TradeSkillFrame.RecipeList:SetHeight(TradeSkillUIImprovedDB.size * 16 + 5)
        end

        if #TradeSkillFrame.RecipeList.buttons < floor(TradeSkillUIImprovedDB.size, 0.5) + 2 then
            local range = TradeSkillFrame.RecipeList.scrollBar:GetValue()
            HybridScrollFrame_CreateButtons(TradeSkillFrame.RecipeList, 'TradeSkillRowButtonTemplate', 0, 0)
            TradeSkillFrame.RecipeList.scrollBar:SetValue(range)
        end
        TradeSkillFrame.RecipeList:Refresh()

        updatePosition()
        updateTabs()
    elseif event == 'TRADE_SKILL_DATA_SOURCE_CHANGED' then
		if not InCombatLockdown() then
			updateTabs(true)
		end
    end
end)

local function TradeSkillUIImproved_SlashCmd(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == 'addBL' and args ~= '' then
        local tonumberArgs = tonumber(args)
        local recipeInfo = {}
        C_TradeSkillUI.GetRecipeInfo(tonumberArgs, recipeInfo)

        if recipeInfo.name == nil then
            C_TradeSkillUI.GetCategoryInfo(tonumberArgs, recipeInfo)
        end

        if IsInTable(TradeSkillUIImprovedDB.BlackList, tonumberArgs) then
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["is already in the blacklist."])
        else
            table.insert(TradeSkillUIImprovedDB.BlackList, { recipeID = (recipeInfo.recipeID or recipeInfo.categoryID), name = recipeInfo.name })
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["has been added in the blacklist."])
        end
    elseif cmd == 'delBL' and args ~= '' then
        local idElement = IsInTable(TradeSkillUIImprovedDB.BlackList, tonumber(args))

        if idElement then
            table.remove(TradeSkillUIImprovedDB.BlackList, idElement)
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["has been removed from the blacklist."])
        else
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["is not in the blacklist, there is nothing to remove."])
        end
    elseif cmd == 'showBL' then
        if type(TradeSkillUIImprovedDB.BlackList) == 'table' then
            if #TradeSkillUIImprovedDB.BlackList == 0 then
                TradeSkillUIImproved_Print(L["The blacklist is empty."])
            elseif args == '' then
                TradeSkillUIImproved_Print(L["Content of the blacklist :"])
                    print('  index,recipeID,recipeName')
                for i, recipeIDTable in ipairs(TradeSkillUIImprovedDB.BlackList) do
                    print('  ' .. i .. ',' .. recipeIDTable.recipeID .. ',' .. recipeIDTable.name)
                end
            else
                TradeSkillUIImproved_Print(L["Content of the blacklist with the pattern"] .. " '" .. args .. "' :")
                print('  index,recipeID,recipeName')
                for i, recipeIDTable in ipairs(TradeSkillUIImprovedDB.BlackList) do
                    if string.match(recipeIDTable.recipeID, args) or string.match(recipeIDTable.name, args) then
                        print('  ' .. i .. ',' .. recipeIDTable.recipeID .. ',' .. recipeIDTable.name)
                    end
                end
            end
        else
            TradeSkillUIImproved_Print(L["The blacklist is empty."])
        end
    elseif cmd == 'isBL' and args ~= '' then
        if IsInTable(TradeSkillUIImprovedDB.BlackList, tonumber(args)) then
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["is in the blacklist."])
        else
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["isn't in the blacklist."])
        end
    elseif cmd == 'getSize'then
        TradeSkillUIImproved_Print(L["The coefficient of the size is"] .. ' |cffffff00' .. TradeSkillUIImprovedDB.size .. "|r.")
    elseif cmd == 'setSize' and args ~= '' then
        TradeSkillUIImprovedDB.size = args
        TradeSkillUIImproved_Print(L["The coefficient of the size has been set to"] .. ' |cffffff00' .. TradeSkillUIImprovedDB.size .. '|r. ' .. L["A reload is |cffffff00necessary|r."])
    elseif cmd == 'version' then
        TradeSkillUIImproved_Print(L["The version of the addon is"] .. ' |cffffff00' .. TradeSkillUIImproved.version .. '|r.')
    else
        TradeSkillUIImproved_Print(L["Arguments :"])
        print('  |cfffff194addBL|r - ' .. L["Add a recipeID in the blacklist."])
        print('  |cfffff194delBL|r - ' .. L["Delete the recipeID from the blacklist."])
        print('  |cfffff194showBL [' .. L["substring"] .. ']|r - ' .. L["Show the data of the blacklist. If an argument is passed, a pattern case-sensitive while be executed on the recipeID and the name."])
        print('  |cfffff194isBL|r - ' .. L["Show if the recipeID is in the blacklist."])
        print('  |cfffff194getSize|r - ' .. L["Show the coefficient of the size."])
        print('  |cfffff194setSize|r - ' .. L["Change the coefficient of the size. A reload will be necessary."])
        print('  |cfffff194version|r - ' .. L["Show the version fo the addon."])
    end
end

SLASH_TSUII1, SLASH_TSUII2 = '/TSUII', '/TradeSkillUIImproved'
SlashCmdList["TSUII"] = TradeSkillUIImproved_SlashCmd

hooksecurefunc('ToggleGameMenu', function()
	if TradeSkillFrame:IsShown() then
		C_TradeSkillUI.CloseTradeSkill()
		HideUIPanel(GameMenuFrame)
	end
end)

hooksecurefunc(TradeSkillFrame.RecipeList, 'UpdateFilterBar', function(self)
	if self.FilterBar:IsVisible() then
		self:SetHeight(TradeSkillUIImprovedDB.size * 16 - 11)
	else
		self:SetHeight(TradeSkillUIImprovedDB.size * 16 + 5)
	end
end)

hooksecurefunc(TradeSkillFrame.RecipeList, 'RebuildDataList', function(self)
    if type(TradeSkillUIImprovedDB.BlackList) == 'table' and #TradeSkillUIImprovedDB.BlackList > 0 then
        for i, listData in ipairs(self.dataList) do
            if listData.type == 'recipe' and IsInTable(TradeSkillUIImprovedDB.BlackList, listData.recipeID) then
                table.remove(self.dataList, i)
            end
            if listData.type == 'subheader' and IsInTable(TradeSkillUIImprovedDB.BlackList, listData.categoryID) then
                for subI, subListData in ipairs(self.dataList) do
                    if subListData.type == 'subheader' and subListData.parentCategoryID == listData.categoryID then
                        table.remove(self.dataList, subI)
                    end
                    if subListData.type == 'recipe' and subListData.categoryID == listData.categoryID then
                        table.remove(self.dataList, subI)
                    end
                end
                table.remove(self.dataList, i)
            end

        end
    end
end)

hooksecurefunc(TradeSkillFrame.RecipeList, 'OnDataSourceChanging', function()
    TradeSkillUIImproved_CheckButtonHasMaterials:SetChecked(false)
    TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(false)
end)

hooksecurefunc(TradeSkillFrame.RecipeList, 'OnHeaderButtonClicked', function(_, _, categoryInfo, mouseButton)
    if mouseButton == 'RightButton' then
        TradeSkillUIImproved_Print(L["The clicked categoryID is"] .. ' |cffffff00' .. categoryInfo.categoryID .. '|r.')
    end
end)

local TradeSkillUIImproved_CollapseButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_CollapseButton:SetText('-')
TradeSkillUIImproved_CollapseButton:SetWidth(20)
TradeSkillUIImproved_CollapseButton:SetHeight(20)
TradeSkillUIImproved_CollapseButton:ClearAllPoints()
TradeSkillUIImproved_CollapseButton:SetPoint('LEFT', TradeSkillFrame.SearchBox, 'RIGHT', 3, 0)
TradeSkillUIImproved_CollapseButton:SetScript('OnClick', function()
    local categories = {C_TradeSkillUI.GetCategories()}
    for _, categoryID in ipairs(categories) do
        local subCategories = {C_TradeSkillUI.GetSubCategories(categoryID)}
        for _, subId in ipairs(subCategories) do
            TradeSkillFrame.RecipeList.collapsedCategories[subId] = true
        end
    end
    TradeSkillFrame.RecipeList:Refresh()
end)

local TradeSkillUIImproved_ExpandButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_ExpandButton:SetText('+')
TradeSkillUIImproved_ExpandButton:SetWidth(20)
TradeSkillUIImproved_ExpandButton:SetHeight(20)
TradeSkillUIImproved_ExpandButton:ClearAllPoints()
TradeSkillUIImproved_ExpandButton:SetPoint('LEFT', TradeSkillUIImproved_CollapseButton, 'RIGHT', 3, 0)
TradeSkillUIImproved_ExpandButton:SetScript('OnClick', function()
    local categories = {C_TradeSkillUI.GetCategories()}
    for _, categoryID in ipairs(categories) do
        local subCategories = {C_TradeSkillUI.GetSubCategories(categoryID)}
        for _, subId in ipairs(subCategories) do
            TradeSkillFrame.RecipeList.collapsedCategories[subId] = nil
        end
    end
    TradeSkillFrame.RecipeList:Refresh()
end)

local TradeSkillUIImproved_CheckButtonHasMaterials = CreateFrame('CheckButton', 'TradeSkillUIImproved_CheckButtonHasMaterials', TradeSkillFrame, 'UICheckButtonTemplate')
TradeSkillUIImproved_CheckButtonHasMaterials:SetPoint('LEFT', TradeSkillUIImproved_ExpandButton, 'RIGHT', 35, 0)
TradeSkillUIImproved_CheckButtonHasMaterials:SetWidth(24)
TradeSkillUIImproved_CheckButtonHasMaterials:SetHeight(24)
TradeSkillUIImproved_CheckButtonHasMaterialsText:SetText(CRAFT_IS_MAKEABLE)
TradeSkillUIImproved_CheckButtonHasMaterialsText:SetWidth(110)
TradeSkillUIImproved_CheckButtonHasMaterialsText:SetJustifyH('LEFT')
TradeSkillUIImproved_CheckButtonHasMaterials:SetChecked(C_TradeSkillUI.GetOnlyShowMakeableRecipes())
TradeSkillUIImproved_CheckButtonHasMaterials:SetScript('OnClick', function()
    C_TradeSkillUI.SetOnlyShowMakeableRecipes(TradeSkillUIImproved_CheckButtonHasMaterials:GetChecked())
end)

hooksecurefunc(C_TradeSkillUI, 'SetOnlyShowMakeableRecipes', function(show)
    TradeSkillUIImproved_CheckButtonHasMaterials:SetChecked(show)
end)

local TradeSkillUIImproved_CheckButtonHasSkillUp = CreateFrame('CheckButton', 'TradeSkillUIImproved_CheckButtonHasSkillUp', TradeSkillFrame, 'UICheckButtonTemplate')
TradeSkillUIImproved_CheckButtonHasSkillUp:SetPoint('LEFT', TradeSkillUIImproved_CheckButtonHasMaterials, 'RIGHT', 130, 0)
TradeSkillUIImproved_CheckButtonHasSkillUp:SetWidth(24)
TradeSkillUIImproved_CheckButtonHasSkillUp:SetHeight(24)
TradeSkillUIImproved_CheckButtonHasSkillUpText:SetText(TRADESKILL_FILTER_HAS_SKILL_UP)
TradeSkillUIImproved_CheckButtonHasSkillUpText:SetWidth(110)
TradeSkillUIImproved_CheckButtonHasSkillUpText:SetJustifyH('LEFT')
TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(C_TradeSkillUI.GetOnlyShowSkillUpRecipes())
TradeSkillUIImproved_CheckButtonHasSkillUp:SetScript('OnClick', function()
    C_TradeSkillUI.SetOnlyShowSkillUpRecipes(TradeSkillUIImproved_CheckButtonHasSkillUp:GetChecked())
end)

hooksecurefunc(C_TradeSkillUI, 'SetOnlyShowSkillUpRecipes', function(show)
    TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(show)
end)

local TradeSkillUIImproved_SelectedRecipeIDButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_SelectedRecipeIDButton:SetText('recipeID')
TradeSkillUIImproved_SelectedRecipeIDButton:SetWidth(85)
TradeSkillUIImproved_SelectedRecipeIDButton:SetHeight(22)
TradeSkillUIImproved_SelectedRecipeIDButton:ClearAllPoints()
TradeSkillUIImproved_SelectedRecipeIDButton:SetPoint('BOTTOMRIGHT', TradeSkillFrame.DetailsFrame.CreateButton, 'BOTTOMRIGHT', 85, 0)
TradeSkillUIImproved_SelectedRecipeIDButton:SetScript('OnClick', function()
    local recipeID = TradeSkillFrame.RecipeList.selectedRecipeID
    if recipeID ~= nil then
        TradeSkillUIImproved_Print(L["The selected recipeID is"] .. ' |cffffff00' .. recipeID .. '|r.')
    else
        TradeSkillUIImproved_Print(L["No recipe is selected."])
    end
end)

local TradeSkillUIImproved_MoveFrame = CreateFrame('Button', nil, TradeSkillFrame)
TradeSkillUIImproved_MoveFrame:SetPoint('TOPRIGHT', TradeSkillFrame)
TradeSkillUIImproved_MoveFrame:SetSize(610, 24)
TradeSkillUIImproved_MoveFrame:SetScript('OnMouseDown', function()
    TradeSkillFrame:SetMovable(true)
    TradeSkillFrame:StartMoving()
end)
TradeSkillUIImproved_MoveFrame:SetScript('OnMouseUp', function()
    TradeSkillFrame:StopMovingOrSizing()
    TradeSkillFrame:SetMovable(false)

    TradeSkillUIImprovedDB.x = TradeSkillFrame:GetLeft()
    TradeSkillUIImprovedDB.y = TradeSkillFrame:GetTop()
end)
