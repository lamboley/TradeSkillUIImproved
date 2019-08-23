local addonName, L = ...
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
local GetCategories, GetSubCategories, GetRecipeInfo, GetCategoryInfo
    = C_TradeSkillUI.GetCategories, C_TradeSkillUI.GetSubCategories, C_TradeSkillUI.GetRecipeInfo, C_TradeSkillUI.GetCategoryInfo
local CloseTradeSkill, SetOnlyShowMakeableRecipes, SetOnlyShowSkillUpRecipes
    = C_TradeSkillUI.CloseTradeSkill, C_TradeSkillUI.SetOnlyShowMakeableRecipes, C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local TradeSkillFrame, DetailsFrame, FilterButton, RankFrame, SearchBox, RecipeList
    = TradeSkillFrame, TradeSkillFrame.DetailsFrame, TradeSkillFrame.FilterButton, TradeSkillFrame.RankFrame, TradeSkillFrame.SearchBox, TradeSkillFrame.RecipeList
local IsAddOnLoaded, GetContainerItemLink, FauxScrollFrame_GetOffset, GetMerchantNumItems
    = IsAddOnLoaded, GetContainerItemLink, FauxScrollFrame_GetOffset, GetMerchantNumItems
local SetItemButtonTextureVertexColor, GetNumAuctionItems, GetAuctionItemLink, MerchantFrame, GetMerchantItemLink
    = SetItemButtonTextureVertexColor, GetNumAuctionItems, GetAuctionItemLink, MerchantFrame, GetMerchantItemLink

local addonVersion = GetAddOnMetadata(addonName, 'Version')

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

local TradeSkillUIImproved_GameTooltipFrame = CreateFrame('GameTooltip', 'TradeSkillUIImproved_GameTooltipFrame', nil, 'GameTooltipTemplate')
TradeSkillUIImproved_GameTooltipFrame:SetOwner(UIParent, 'ANCHOR_NONE')

local function TradeSkillUIImproved_ParseTextGameToolTip(itemLink, changeVertexColor)
    TradeSkillUIImproved_GameTooltipFrame:ClearLines()
    TradeSkillUIImproved_GameTooltipFrame:SetHyperlink(itemLink)

    for li = 2, TradeSkillUIImproved_GameTooltipFrame:NumLines() do
        local text = _G['TradeSkillUIImproved_GameTooltipFrameTextLeft' .. li]:GetText()
        if text == ITEM_SPELL_KNOWN then
            changeVertexColor()
        end
    end
end

local function TradeSkillUIImproved_Print(msg)
    print('|cff00ff00TSUII|r: ' .. msg)
end

local function IsInTable(l, e)
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

TradeSkillUIImproved:RegisterEvent('PLAYER_LOGIN')
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

        TradeSkillUIImproved.name = addonName

        local TradeSkillUIImproved_OptionsTitle = TradeSkillUIImproved:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        TradeSkillUIImproved_OptionsTitle:SetPoint('TOPLEFT', 16, -16)
        TradeSkillUIImproved_OptionsTitle:SetText(addonName)

        local TradeSkillUIImproved_OptionsCheckBoxAuctionator = CreateFrame('CheckButton', 'TradeSkillUIImproved_OptionsCheckBoxAuctionator', TradeSkillUIImproved, 'InterfaceOptionsCheckButtonTemplate')
        TradeSkillUIImproved_OptionsCheckBoxAuctionator:SetPoint('TOPLEFT', TradeSkillUIImproved_OptionsTitle, 'BOTTOMLEFT', 0, -5)
        TradeSkillUIImproved_OptionsCheckBoxAuctionator.tooltipText = L["The addon Auctionator had a button in the tradeskill UI. This options allow you to hide that button.\n\nA reload is necessary."]
        TradeSkillUIImproved_OptionsCheckBoxAuctionatorText:SetText(L["Hide the AH button if the addon Auctionator is loaded."])
        TradeSkillUIImproved_OptionsCheckBoxAuctionator:SetChecked(TradeSkillUIImprovedDB.options.hideAuctionator)
        TradeSkillUIImproved_OptionsCheckBoxAuctionator:SetScript('OnClick', function(self)
            TradeSkillUIImprovedDB.options.hideAuctionator = self:GetChecked()
        end)

        local TradeSkillUIImproved_OptionsCheckBoxRecipeBag = CreateFrame('CheckButton', 'TradeSkillUIImproved_OptionsCheckBoxRecipeBag', TradeSkillUIImproved, 'InterfaceOptionsCheckButtonTemplate')
        TradeSkillUIImproved_OptionsCheckBoxRecipeBag.tooltipText = L["Change the color of an icon if an item in the bag is already learned.\n\nA reload is necessary."]
        TradeSkillUIImproved_OptionsCheckBoxRecipeBagText:SetText(L["Change the color in the bag."])
        TradeSkillUIImproved_OptionsCheckBoxRecipeBag:SetChecked(TradeSkillUIImprovedDB.options.colorRecipeBag)
        TradeSkillUIImproved_OptionsCheckBoxRecipeBag:SetEnabled(TradeSkillUIImprovedDB.options.colorRecipe)
        TradeSkillUIImproved_OptionsCheckBoxRecipeBag:SetScript('OnClick', function(self)
            TradeSkillUIImprovedDB.options.colorRecipeBag = self:GetChecked()
        end)

        local TradeSkillUIImproved_OptionsCheckBoxRecipeBank = CreateFrame('CheckButton', 'TradeSkillUIImproved_OptionsCheckBoxRecipeBank', TradeSkillUIImproved, 'InterfaceOptionsCheckButtonTemplate')
        TradeSkillUIImproved_OptionsCheckBoxRecipeBank.tooltipText = L["Change the color of an icon if an item in the bank is already learned.\n\nA reload is necessary."]
        TradeSkillUIImproved_OptionsCheckBoxRecipeBankText:SetText(L["Change the color in the bank."])
        TradeSkillUIImproved_OptionsCheckBoxRecipeBank:SetChecked(TradeSkillUIImprovedDB.options.colorRecipeBank)
        TradeSkillUIImproved_OptionsCheckBoxRecipeBank:SetEnabled(TradeSkillUIImprovedDB.options.colorRecipe)
        TradeSkillUIImproved_OptionsCheckBoxRecipeBank:SetScript('OnClick', function(self)
            TradeSkillUIImprovedDB.options.colorRecipeBank = self:GetChecked()
        end)

        local TradeSkillUIImproved_OptionsCheckBoxRecipe = CreateFrame('CheckButton', 'TradeSkillUIImproved_OptionsCheckBoxRecipe', TradeSkillUIImproved, 'InterfaceOptionsCheckButtonTemplate')
        TradeSkillUIImproved_OptionsCheckBoxRecipe:SetPoint('TOPLEFT', TradeSkillUIImproved_OptionsCheckBoxAuctionator, 'BOTTOMLEFT', 0, -3)
        TradeSkillUIImproved_OptionsCheckBoxRecipe.tooltipText = L["Change the color of an icon if the item (merchant, auction, bag, bank) is already learned.\n\nA reload is necessary."]
        TradeSkillUIImproved_OptionsCheckBoxRecipeText:SetText(L["Change the color of an icon if the item is already learned."])
        TradeSkillUIImproved_OptionsCheckBoxRecipe:SetChecked(TradeSkillUIImprovedDB.options.colorRecipe)
        TradeSkillUIImproved_OptionsCheckBoxRecipe:SetScript('OnClick', function(self)
            TradeSkillUIImprovedDB.options.colorRecipe = self:GetChecked()
            TradeSkillUIImproved_OptionsCheckBoxRecipeBag:SetEnabled(self:GetChecked())
            TradeSkillUIImproved_OptionsCheckBoxRecipeBank:SetEnabled(self:GetChecked())
        end)

        TradeSkillUIImproved_OptionsCheckBoxRecipeBag:SetPoint('TOPLEFT', TradeSkillUIImproved_OptionsCheckBoxRecipe, 'BOTTOMLEFT', 10, -3)
        TradeSkillUIImproved_OptionsCheckBoxRecipeBank:SetPoint('TOPLEFT', TradeSkillUIImproved_OptionsCheckBoxRecipeBag, 'BOTTOMLEFT', 0, -3)

        local TradeSkillUIImproved_OptionsSliderSize = CreateFrame('Slider', 'TradeSkillUIImproved_OptionsSliderSize', TradeSkillUIImproved, 'OptionsSliderTemplate')
        TradeSkillUIImproved_OptionsSliderSize:SetWidth(585)
        TradeSkillUIImproved_OptionsSliderSize:SetHeight(13)
        TradeSkillUIImproved_OptionsSliderSize:SetPoint('TOPLEFT', TradeSkillUIImproved_OptionsCheckBoxRecipeBank, 'BOTTOMLEFT', 0, -15)
        TradeSkillUIImproved_OptionsSliderSize.tooltipText = L["Allow to change the factor of the size of the tradeskill UI.\n\nDefault is 55 and Blizzard\"s default is 27.\n\nA reload is necessary."]
        TradeSkillUIImproved_OptionsSliderSize:SetValueStep(1)
        TradeSkillUIImproved_OptionsSliderSize:SetMinMaxValues(27, 65)
        TradeSkillUIImproved_OptionsSliderSizeText:SetText(L["Size factor"])
        TradeSkillUIImproved_OptionsSliderSizeLow:SetText('27')
        TradeSkillUIImproved_OptionsSliderSizeHigh:SetText('65')

        local TradeSkillUIImproved_OptionsSliderSizeValueBox = CreateFrame('editbox', nil, TradeSkillUIImproved_OptionsSliderSize)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetPoint('TOP', TradeSkillUIImproved_OptionsSliderSize, 'BOTTOM', 0, 0)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetSize(60, 14)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetFontObject(GameFontHighlightSmall)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetMaxLetters(2)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetAutoFocus(false)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetJustifyH('CENTER')
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetScript('OnEscapePressed', function(self)
            self:SetText(TradeSkillUIImprovedDB.options.factor)
            self:ClearFocus()
        end)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetScript('OnEnterPressed', function(self)
            local value = tonumber(self:GetText()) or TradeSkillUIImprovedDB.options.factor or 27
            TradeSkillUIImproved_OptionsSliderSize:SetValue(value)
            TradeSkillUIImprovedDB.options.factor = value
            self:SetText(value)
            self:ClearFocus()
        end)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetBackdrop({
            bgFile = 'Interface/ChatFrame/ChatFrameBackground',
            edgeFile = 'Interface/ChatFrame/ChatFrameBackground',
            tile = true, edgeSize = 1, tileSize = 5,
        })
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetBackdropColor(0, 0, 0, 0.5)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

        TradeSkillUIImproved_OptionsSliderSize:HookScript('OnValueChanged', function(_, value)
            TradeSkillUIImprovedDB.options.factor = value
            TradeSkillUIImproved_OptionsSliderSizeValueBox:SetText(floor(value))
            TradeSkillUIImproved_OptionsSliderSizeValueBox:SetCursorPosition(0) -- Fix value not showing up
        end)
        TradeSkillUIImproved_OptionsSliderSizeValueBox:SetScript('OnChar', function(self)
            self:SetText(self:GetText():gsub('[^%.0-9]+', ''):gsub('(%..*)%.', '%1'))
        end)

        InterfaceOptions_AddCategory(TradeSkillUIImproved)

        if TradeSkillUIImprovedDB.options.hideAuctionator and IsAddOnLoaded('Auctionator') then
            Auctionator_Search:Hide()
        end

        TradeSkillUIImproved_OptionsSliderSize:SetValue(TradeSkillUIImprovedDB.options.factor)

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

SLASH_TSUII1, SLASH_TSUII2 = '/TSUII', '/TradeSkillUIImproved'
SlashCmdList["TSUII"] = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == 'addBL' and args ~= '' then
        local tonumberArgs = tonumber(args)
        local recipeInfo = {}
        GetRecipeInfo(tonumberArgs, recipeInfo)

        if recipeInfo.name == nil then
            GetCategoryInfo(tonumberArgs, recipeInfo)
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
    elseif cmd == 'version' then
        TradeSkillUIImproved_Print(L["The version of the addon is"] .. ' |cffffff00' .. addonVersion .. '|r.')
    elseif cmd == 'options' then
        -- We call it twice because of a bug of blizzard
        InterfaceOptionsFrame_OpenToCategory(TradeSkillUIImproved)
        InterfaceOptionsFrame_OpenToCategory(TradeSkillUIImproved)
    else
        TradeSkillUIImproved_Print(L["Arguments :"])
        print('  |cfffff194addBL|r - ' .. L["Add a recipeID in the blacklist."])
        print('  |cfffff194delBL|r - ' .. L["Delete the recipeID from the blacklist."])
        print('  |cfffff194showBL [' .. L["substring"] .. ']|r - ' .. L["Show the data of the blacklist. If an argument is passed, a pattern case-sensitive while be executed on the recipeID and the name."])
        print('  |cfffff194isBL|r - ' .. L["Show if the recipeID is in the blacklist."])
        print('  |cfffff194version|r - ' .. L["Show the version of the addon."])
        print('  |cfffff194options|r - ' .. L["Show the option window."])
    end
end

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
