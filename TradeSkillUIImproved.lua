local addonName, addon = ...
local L = addon.L
local _G = _G

local index = 0
local searchText = ''

local runeforgingId = 53428
local cookingId = 2550
local firecampId = 818
local fishingId = 271990
local fishingPoleId = 131474
local archaeologyId = 195127
local digId = 80451

local CreateFrame, InCombatLockdown, GetSpellInfo, GetProfessions, IsCurrentSpell, HideUIPanel
    = CreateFrame, InCombatLockdown, GetSpellInfo, GetProfessions, IsCurrentSpell, HideUIPanel
local GetCategories, GetSubCategories
    = C_TradeSkillUI.GetCategories, C_TradeSkillUI.GetSubCategories
local CloseTradeSkill, SetOnlyShowMakeableRecipes, SetOnlyShowSkillUpRecipes
    = C_TradeSkillUI.CloseTradeSkill, C_TradeSkillUI.SetOnlyShowMakeableRecipes, C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local TradeSkillFrame, DetailsFrame, FilterButton, RankFrame, SearchBox, RecipeList
    = TradeSkillFrame, TradeSkillFrame.DetailsFrame, TradeSkillFrame.FilterButton, TradeSkillFrame.RankFrame, TradeSkillFrame.SearchBox, TradeSkillFrame.RecipeList
local IsAddOnLoaded, GetContainerItemLink, FauxScrollFrame_GetOffset, GetMerchantNumItems
    = IsAddOnLoaded, GetContainerItemLink, FauxScrollFrame_GetOffset, GetMerchantNumItems
local SetItemButtonTextureVertexColor, GetNumAuctionItems, GetAuctionItemLink, MerchantFrame, GetMerchantItemLink
    = SetItemButtonTextureVertexColor, GetNumAuctionItems, GetAuctionItemLink, MerchantFrame, GetMerchantItemLink
local GetNumCollectedInfo
    = C_PetJournal.GetNumCollectedInfo

TradeSkillUIImprovedDB = TradeSkillUIImprovedDB or {
    options = {
        hideAuctionator = true,
        factor = 55,
        colorRecipe = true,
        colorRecipeBag = false,
        colorRecipeBank = false,
    },
    x = 200,
    y = 1050,
    BlackList = {},
}

function TradeSkillUIImproved_Print(...) print('|cff00ff00TSUII:|r', ...) end

local TradeSkillUIImproved_GameTooltipFrame = CreateFrame('GameTooltip', 'TradeSkillUIImproved_GameTooltipFrame', nil, 'GameTooltipTemplate')
TradeSkillUIImproved_GameTooltipFrame:SetOwner(UIParent, 'ANCHOR_NONE')

local function TradeSkillUIImproved_ParseTextGameToolTip(itemLink, changeVertexColor)
	if itemLink:match("|H(.-):") == "battlepet" then
		local _, petID = strsplit(":", itemLink)
		if GetNumCollectedInfo(petID) > 0 then
            changeVertexColor()
			return true
		end
		return false
	end

    TradeSkillUIImproved_GameTooltipFrame:ClearLines()
    TradeSkillUIImproved_GameTooltipFrame:SetHyperlink(itemLink)

    for li = 2, TradeSkillUIImproved_GameTooltipFrame:NumLines() do
        local text = _G['TradeSkillUIImproved_GameTooltipFrameTextLeft' .. li]:GetText()
        if text == ITEM_SPELL_KNOWN then
            changeVertexColor()
            return true
        end
    end
    return false
end



function TradeSkillUIImproved_IsInTable(l, e)
    for i, v in pairs(l) do
        if v.recipeID == e then
            return i
        end
    end
    return false
end

local function IsCurrentTab(self)
    if self.tooltip and IsCurrentSpell(self.tooltip) then
        self:SetChecked(true)
        if self.id == archaeologyId then
            self:RegisterForClicks('AnyDown')
        else
            self:RegisterForClicks(nil)
        end
    else
        self:SetChecked(false)
        self:RegisterForClicks('AnyDown')
    end
end

local function FactoryCheckButton(id)
    index = index + 1

    local name, _, icon, _, _, _, spellID = GetSpellInfo(id)

    local tab = _G['TradeSkillUIImprovedTab' .. index] or CreateFrame('CheckButton', 'TradeSkillUIImprovedTab' .. index, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
    tab:SetScript('OnEvent', IsCurrentTab)
    tab:RegisterEvent('TRADE_SKILL_SHOW')
    tab:RegisterEvent('CURRENT_SPELL_CAST_CHANGED')
    tab.tooltip = name
    tab.id = spellID

    tab:SetNormalTexture(icon)
    if spellID == cookingId or spellID == firecampId or spellID == fishingId or spellID == fishingPoleId or spellID == archaeologyId or spellID == digId or spellID == runeforgingId then
        tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, (-44 * index) + (-40 * 1.5))
    else
        tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, (-44 * index) + (-40 * 1))
    end

    tab:Show()
    tab:SetAttribute('type', 'spell')
    tab:SetAttribute('spell', name)

    IsCurrentTab(tab)
end

local TradeSkillUIImproved = CreateFrame('Frame', addonName)
addon.frame = TradeSkillUIImproved

TradeSkillUIImproved:RegisterEvent('PLAYER_LOGIN')
TradeSkillUIImproved:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
TradeSkillUIImproved:RegisterEvent('TRADE_SKILL_LIST_UPDATE')
TradeSkillUIImproved:RegisterEvent('TRADE_SKILL_DATA_SOURCE_CHANGED')
TradeSkillUIImproved:RegisterEvent('ARCHAEOLOGY_CLOSED')

TradeSkillUIImproved:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_LOGIN' then
        if TradeSkillUIImprovedDB.options == nil then
            TradeSkillUIImprovedDB.options = {
                hideAuctionator = true,
                factor = 55,
                colorRecipe = true,
                colorRecipeBag = false,
                colorRecipeBank = false,
            }
        elseif TradeSkillUIImprovedDB.options.hideAuctionator == nil then
            TradeSkillUIImprovedDB.options.hideAuctionator = true
        elseif TradeSkillUIImprovedDB.options.factor == nil then
            TradeSkillUIImprovedDB.options.factor = 55
        elseif TradeSkillUIImprovedDB.options.colorRecipe == nil then
            TradeSkillUIImprovedDB.options.colorRecipe = true
        elseif TradeSkillUIImprovedDB.options.colorRecipeBag == nil then
            TradeSkillUIImprovedDB.options.colorRecipeBag = false
        elseif TradeSkillUIImprovedDB.options.colorRecipeBank == nil then
            TradeSkillUIImprovedDB.options.colorRecipeBank = false
        end

        TradeSkillUIImproved_CreateInterfaceOptions()

        if TradeSkillUIImprovedDB.options.hideAuctionator and IsAddOnLoaded('Auctionator') then
            Auctionator_Search:Hide()
        end

        if TradeSkillUIImprovedDB.options.colorRecipe then
            if TradeSkillUIImprovedDB.options.colorRecipeBag then
                hooksecurefunc('ContainerFrame_Update', function(self)
                    local id = self:GetID()
                    local name = self:GetName()

                    for i = 1, self.size, 1 do
                        local itemButton = _G[name .. 'Item' .. i]

                        local itemLink = GetContainerItemLink(id, itemButton:GetID())

                        if itemLink then
                            TradeSkillUIImproved_ParseTextGameToolTip(itemLink,  function()
                                SetItemButtonTextureVertexColor(itemButton, 1, 1, 0)
                            end)
                        end
                    end
                end)
            end

            if TradeSkillUIImprovedDB.options.colorRecipeBank then
                hooksecurefunc('BankFrameItemButton_Update', function(button)
                    local container = button:GetParent():GetID()
                    local buttonID = button:GetID()
                    if not button.isBag then
                        local itemLink = GetContainerItemLink(container, buttonID)

                        if itemLink then
                            TradeSkillUIImproved_ParseTextGameToolTip(itemLink,  function()
                                    SetItemButtonTextureVertexColor(button, 1, 1, 0)
                            end)
                        end
                    end
                end)
            end

            hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
                local numMerchantItems = GetMerchantNumItems()

                for i = 1, MERCHANT_ITEMS_PER_PAGE do
                    local indexItem = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)

                    if (indexItem <= numMerchantItems) then
                        local itemLink = GetMerchantItemLink(indexItem)

                        if itemLink then
                            TradeSkillUIImproved_ParseTextGameToolTip(itemLink,  function()
                                SetItemButtonTextureVertexColor(_G['MerchantItem' .. i .. 'ItemButton'], 1, 1, 0)
                            end)
                        end
                    end
                end
            end)

            hooksecurefunc('AuctionFrameBrowse_Update', function()
                local numBatchAuctions = GetNumAuctionItems("list")
                local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
                local buttonTexture

                for i = 1, NUM_BROWSE_TO_DISPLAY do
                    local indexItem = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)

                    if (not (indexItem > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)))) then
                        local itemLink = GetAuctionItemLink('list', offset + i)

                        if itemLink then
                            TradeSkillUIImproved_ParseTextGameToolTip(itemLink,  function()
                                buttonTexture = _G['BrowseButton' .. i .. 'ItemIconTexture']
                                buttonTexture:SetVertexColor(1, 1, 0)
                            end)
                        end
                    end
                end
            end)
        end

        TradeSkillFrame:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 + 96)
        TradeSkillFrame.RecipeInset:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 + 10)
        TradeSkillFrame.DetailsInset:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 - 10)
        DetailsFrame:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 - 15)
        DetailsFrame.Background:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 - 17)
        DetailsFrame.ExitButton:Hide()
        TradeSkillFrame.LinkToButton:SetPoint('BOTTOMRIGHT', TradeSkillFrame, 'TOPRIGHT', -10, -81)
        FilterButton:SetPoint('TOPRIGHT', TradeSkillFrame, 'TOPRIGHT', -12, -31)
        FilterButton:SetHeight(17)
        RankFrame:SetPoint('TOP', TradeSkillFrame, 'TOP', -17, -33)
        RankFrame:SetWidth(500)
        SearchBox:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPLEFT', 163, -60)
        SearchBox:SetWidth(97)

        if RecipeList.FilterBar:IsVisible() then
            RecipeList:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 - 11)
        else
            RecipeList:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 + 5)
        end

        if #RecipeList.buttons < floor(TradeSkillUIImprovedDB.options.factor, 0.5) + 2 then
            local range = RecipeList.scrollBar:GetValue()
            HybridScrollFrame_CreateButtons(RecipeList, 'TradeSkillRowButtonTemplate', 0, 0)
            RecipeList.scrollBar:SetValue(range)
        end
        RecipeList:Refresh()

        UIPanelWindows['TradeSkillFrame'].area = nil
        TradeSkillFrame:ClearAllPoints()
        TradeSkillFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', TradeSkillUIImprovedDB.x, TradeSkillUIImprovedDB.y)
    elseif event == 'PLAYER_MOUNT_DISPLAY_CHANGED' then
        if TradeSkillUIImprovedDB.options.colorRecipe then
            if TradeSkillUIImprovedDB.options.colorRecipeBag then
                ContainerFrame_UpdateAll()
            end
        end
    elseif event == 'TRADE_SKILL_LIST_UPDATE' then
        searchText = SearchBox:GetText()
    elseif event == 'TRADE_SKILL_DATA_SOURCE_CHANGED' then
		if not InCombatLockdown() then
            for i = 1, index do
                local tab = _G['TradeSkillUIImprovedTab' .. i]
                if tab then
                    tab:UnregisterEvent('TRADE_SKILL_SHOW')
                    tab:UnregisterEvent('CURRENT_SPELL_CAST_CHANGED')
                    tab:Hide()
                end
            end

            index = 0

            local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
            for _, id in pairs({prof1, prof2, cooking, archaeology, fishing, (IsSpellKnown(runeforgingId) and runeforgingId or nil)}) do
                if id == runeforgingId then
                    FactoryCheckButton(id, index)
                else
                    local _, _, _, _, numAbilities, spellOffset = GetProfessionInfo(id)

                    for i = 1, numAbilities do
                        FactoryCheckButton(select(2, GetSpellBookItemInfo(spellOffset + i, BOOKTYPE_PROFESSION)), index)
                    end
                end
            end
		end
        SearchBox:SetText(searchText)
    elseif event == 'ARCHAEOLOGY_CLOSED' then -- Fix the highlight of Archaeology when the frame is not closed with the checkbox tab frame.
        for i = 1, index do
            local tab = _G['TradeSkillUIImprovedTab' .. i]
            if tab and tab.id == archaeologyId then
                tab:SetChecked(false)
            end
        end
    end
end)

hooksecurefunc('ToggleGameMenu', function()
	if TradeSkillFrame:IsShown() then
		CloseTradeSkill()
		HideUIPanel(GameMenuFrame)
	end
end)

hooksecurefunc(RecipeList, 'UpdateFilterBar', function(self)
	if self.FilterBar:IsVisible() then
		self:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 - 11)
	else
		self:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 + 5)
	end
end)

hooksecurefunc(RecipeList, 'RebuildDataList', function(self)
    if type(TradeSkillUIImprovedDB.BlackList) == 'table' and #TradeSkillUIImprovedDB.BlackList > 0 then
        for i, listData in ipairs(self.dataList) do
            if listData.type == 'recipe' and TradeSkillUIImproved_IsInTable(TradeSkillUIImprovedDB.BlackList, listData.recipeID) then
                table.remove(self.dataList, i)
            end
            if listData.type == 'subheader' and TradeSkillUIImproved_IsInTable(TradeSkillUIImprovedDB.BlackList, listData.categoryID) then
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

hooksecurefunc(RecipeList, 'OnDataSourceChanging', function()
    TradeSkillUIImproved_CheckButtonHasMaterials:SetChecked(false)
    TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(false)
end)

hooksecurefunc(RecipeList, 'OnHeaderButtonClicked', function(_, _, categoryInfo, mouseButton)
    if mouseButton == 'RightButton' then
        TradeSkillUIImproved_Print(L["The clicked categoryID is"] .. ' |cffffff00' .. categoryInfo.categoryID .. '|r.')
    end
end)

local TradeSkillUIImproved_CollapseButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_CollapseButton:SetText('-')
TradeSkillUIImproved_CollapseButton:SetWidth(20)
TradeSkillUIImproved_CollapseButton:SetHeight(20)
TradeSkillUIImproved_CollapseButton:ClearAllPoints()
TradeSkillUIImproved_CollapseButton:SetPoint('LEFT', SearchBox, 'RIGHT', 3, 0)
TradeSkillUIImproved_CollapseButton:SetScript('OnClick', function()
    local categories = {GetCategories()}
    for _, categoryID in ipairs(categories) do
        local subCategories = {GetSubCategories(categoryID)}
        for _, subId in ipairs(subCategories) do
            RecipeList.collapsedCategories[subId] = true
        end
    end
    RecipeList:Refresh()
end)

local TradeSkillUIImproved_ExpandButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_ExpandButton:SetText('+')
TradeSkillUIImproved_ExpandButton:SetWidth(20)
TradeSkillUIImproved_ExpandButton:SetHeight(20)
TradeSkillUIImproved_ExpandButton:ClearAllPoints()
TradeSkillUIImproved_ExpandButton:SetPoint('LEFT', TradeSkillUIImproved_CollapseButton, 'RIGHT', 3, 0)
TradeSkillUIImproved_ExpandButton:SetScript('OnClick', function()
    local categories = {GetCategories()}
    for _, categoryID in ipairs(categories) do
        local subCategories = {GetSubCategories(categoryID)}
        for _, subId in ipairs(subCategories) do
            RecipeList.collapsedCategories[subId] = nil
        end
    end
    RecipeList:Refresh()
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
    SetOnlyShowMakeableRecipes(TradeSkillUIImproved_CheckButtonHasMaterials:GetChecked())
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
    SetOnlyShowSkillUpRecipes(TradeSkillUIImproved_CheckButtonHasSkillUp:GetChecked())
end)

hooksecurefunc(C_TradeSkillUI, 'SetOnlyShowSkillUpRecipes', function(show)
    TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(show)
end)

local TradeSkillUIImproved_SelectedRecipeIDButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_SelectedRecipeIDButton:SetText('recipeID')
TradeSkillUIImproved_SelectedRecipeIDButton:SetWidth(85)
TradeSkillUIImproved_SelectedRecipeIDButton:SetHeight(22)
TradeSkillUIImproved_SelectedRecipeIDButton:ClearAllPoints()
TradeSkillUIImproved_SelectedRecipeIDButton:SetPoint('BOTTOMRIGHT', DetailsFrame.CreateButton, 'BOTTOMRIGHT', 85, 0)
TradeSkillUIImproved_SelectedRecipeIDButton:SetScript('OnClick', function()
    local recipeID = RecipeList.selectedRecipeID
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
