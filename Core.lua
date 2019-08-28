local CreateFrame, HideUIPanel, C_TradeSkillUI, SetItemButtonTextureVertexColor
    = CreateFrame, HideUIPanel, C_TradeSkillUI, SetItemButtonTextureVertexColor
local GetNumCollectedInfo, GetContainerItemLink, GetMerchantNumItems, GetAuctionItemLink, GetMerchantItemLink, GetNumAuctionItems
    = GetNumCollectedInfo, GetContainerItemLink, GetMerchantNumItems, GetAuctionItemLink, GetMerchantItemLink, GetNumAuctionItems
local FauxScrollFrame_GetOffset, HybridScrollFrame_CreateButtons, ContainerFrame_UpdateAll
    = FauxScrollFrame_GetOffset, HybridScrollFrame_CreateButtons, ContainerFrame_UpdateAll
local GetSpellInfo, GetSpellBookItemInfo, GetProfessions, GetProfessionInfo
    = GetSpellInfo, GetSpellBookItemInfo, GetProfessions, GetProfessionInfo
local IsSpellKnown, IsAddOnLoaded, InCombatLockdown, IsCurrentSpell
    = IsSpellKnown, IsAddOnLoaded, InCombatLockdown, IsCurrentSpell
local CloseTradeSkill, GetRecipeInfo, GetCategoryInfo
    = C_TradeSkillUI.CloseTradeSkill, C_TradeSkillUI.GetRecipeInfo, C_TradeSkillUI.GetCategoryInfo

local _G = _G

local index = 0
local searchText = ''

local TradeSkillUIImproved = TradeSkillUIImproved
local L = TradeSkillUIImproved.L

local versionString = TradeSkillUIImproved.versionString

local namePrint = TradeSkillUIImproved.namePrint

local ARCHAEOLOGY_ID = TradeSkillUIImproved.secondaryProfessionID.archaeology
local RUNEFORGING_ID = TradeSkillUIImproved.secondaryProfessionID.runeForging

function TradeSkillUIImproved.isRecipeIDInTable(list, id)
    for i, l in pairs(list) do
        if l.recipeID == id then
            return i
        end
    end
    return false
end

function TradeSkillUIImproved:AddBlacklist(id)
    local recipeInfo = {}
    GetRecipeInfo(id, recipeInfo)

    if recipeInfo.name == nil then
        GetCategoryInfo(id, recipeInfo)
    end

    if self.isRecipeIDInTable(TradeSkillUIImprovedDB.BlackList, id) then
        namePrint(L["The recipeID"] .. ' |cffffff00' .. id .. '|r ' .. L["is already in the blacklist."])
    else
        table.insert(TradeSkillUIImprovedDB.BlackList, { recipeID = (recipeInfo.recipeID or recipeInfo.categoryID), name = recipeInfo.name })
        namePrint(L["The recipeID"] .. ' |cffffff00' .. id .. '|r ' .. L["has been added in the blacklist."])
    end
end

function TradeSkillUIImproved:DellBlacklist(id)
    local idElement = self.isRecipeIDInTable(TradeSkillUIImprovedDB.BlackList, id)

    if idElement then
        table.remove(TradeSkillUIImprovedDB.BlackList, idElement)
        namePrint(L["The recipeID"] .. ' |cffffff00' .. id .. '|r ' .. L["has been removed from the blacklist."])
    else
        namePrint(L["The recipeID"] .. ' |cffffff00' .. id .. '|r ' .. L["is not in the blacklist, there is nothing to remove."])
    end
end

function TradeSkillUIImproved.ShowBlacklist(pattern)
    if type(TradeSkillUIImprovedDB.BlackList) == 'table' then
        if #TradeSkillUIImprovedDB.BlackList == 0 then
            namePrint(L["The blacklist is empty."])
        elseif pattern == '' then
            namePrint(L["Content of the blacklist :"])
                print('  index,recipeID,recipeName')
            for i, recipeIDTable in ipairs(TradeSkillUIImprovedDB.BlackList) do
                print('  ' .. i .. ',' .. recipeIDTable.recipeID .. ',' .. recipeIDTable.name)
            end
        else
            namePrint(L["Content of the blacklist with the pattern"] .. " '" .. pattern .. "' :")
            print('  index,recipeID,recipeName')
            for i, recipeIDTable in ipairs(TradeSkillUIImprovedDB.BlackList) do
                if string.match(recipeIDTable.recipeID, pattern) or string.match(recipeIDTable.name, pattern) then
                    print('  ' .. i .. ',' .. recipeIDTable.recipeID .. ',' .. recipeIDTable.name)
                end
            end
        end
    else
        namePrint(L["The blacklist is empty."])
    end
end

function TradeSkillUIImproved:IsBlacklisted(id)
    if self.isRecipeIDInTable(TradeSkillUIImprovedDB.BlackList, tonumber(id)) then
        namePrint(L["The recipeID"] .. ' |cffffff00' .. id .. '|r ' .. L["is in the blacklist."])
    else
        namePrint(L["The recipeID"] .. ' |cffffff00' .. id .. '|r ' .. L["isn't in the blacklist."])
    end
end

function TradeSkillUIImproved.ShowVersion()
    namePrint(L["The version of the addon is"] .. ' |cffffff00' .. versionString .. '|r.')
end

function TradeSkillUIImproved.ShowHelp()
    namePrint(L["Arguments :"])
    print('  |cfffff194add|r - ' .. L["Add a recipeID in the blacklist."])
    print('  |cfffff194del|r - ' .. L["Delete the recipeID from the blacklist."])
    print('  |cfffff194show [' .. L["substring"] .. ']|r - ' .. L["Show the data of the blacklist. If an argument is passed, a pattern case-sensitive while be executed on the recipeID and the name."])
    print('  |cfffff194is|r - ' .. L["Show if the recipeID is in the blacklist."])
    print('  |cfffff194version|r - ' .. L["Show the version of the addon."])
    print('  |cfffff194options|r - ' .. L["Show the option window."])
end

SLASH_TSUII1, SLASH_TSUII2 = '/TSUII', '/TradeSkillUIImproved'
function SlashCmdList.TSUII(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == 'add' and args ~= '' then
        TradeSkillUIImproved:AddBlacklist(tonumber(args))
    elseif cmd == 'del' and args ~= '' then
        TradeSkillUIImproved:DellBlacklist(tonumber(args))
    elseif cmd == 'show' then
        TradeSkillUIImproved.ShowBlacklist(args)
    elseif cmd == 'is' and args ~= '' then
        TradeSkillUIImproved:IsBlacklisted(args)
    elseif cmd == 'version' then
        TradeSkillUIImproved.ShowVersion()
    elseif cmd == 'options' then
        TradeSkillUIImproved:OpenOptions()
    else
        TradeSkillUIImproved.ShowHelp()
    end
end

function TradeSkillUIImproved:isSecondaryProfession(id)
    for _, l in pairs(self.secondaryProfessionID) do
        if l == id then
            return true
        end
    end
    return false
end

local function ParseTextGameToolTip(itemLink, changeVertexColor)
    local parseGameTooltip = _G['TradeSkillUIImproved_GameTooltipFrame'] or CreateFrame('GameTooltip', 'TradeSkillUIImproved_GameTooltipFrame', nil, 'GameTooltipTemplate')
    parseGameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')

	if itemLink:match("|H(.-):") == "battlepet" then
		local _, petID = strsplit(":", itemLink)
		if GetNumCollectedInfo(petID) > 0 then
            changeVertexColor()
			return true
		end
		return false
	end

    parseGameTooltip:ClearLines()
    parseGameTooltip:SetHyperlink(itemLink)

    for li = 2, parseGameTooltip:NumLines() do
        local text = _G['TradeSkillUIImproved_GameTooltipFrameTextLeft' .. li]:GetText()
        if text == ITEM_SPELL_KNOWN then
            changeVertexColor()
            return true
        end
    end
    return false
end

local function IsCurrentTab(self)
    if self.tooltip and IsCurrentSpell(self.tooltip) then
        self:SetChecked(true)
        if self.id == ARCHAEOLOGY_ID then
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
    if TradeSkillUIImproved:isSecondaryProfession(spellID) then
        tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, (-44 * index) + (-40 * 1.5))
    else
        tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, (-44 * index) + (-40 * 1))
    end

    tab:Show()
    tab:SetAttribute('type', 'spell')
    tab:SetAttribute('spell', name)

    IsCurrentTab(tab)
end

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_LOGIN')
eventFrame:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
eventFrame:RegisterEvent('TRADE_SKILL_LIST_UPDATE')
eventFrame:RegisterEvent('TRADE_SKILL_DATA_SOURCE_CHANGED')
eventFrame:RegisterEvent('ARCHAEOLOGY_CLOSED')
eventFrame:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_LOGIN' then
        TradeSkillUIImproved.InitializeDB()
        TradeSkillUIImproved:CreateInterfaceOptions()

        if IsAddOnLoaded('Auctionator') and TradeSkillUIImprovedDB.options.hideAuctionator then
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
                            ParseTextGameToolTip(itemLink,  function()
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
                            ParseTextGameToolTip(itemLink,  function()
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
                            ParseTextGameToolTip(itemLink,  function()
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
                            ParseTextGameToolTip(itemLink,  function()
                                buttonTexture = _G['BrowseButton' .. i .. 'ItemIconTexture']
                                buttonTexture:SetVertexColor(1, 1, 0)
                            end)
                        end
                    end
                end
            end)
        end

        local size = TradeSkillUIImprovedDB.options.factor

        TradeSkillFrame:SetHeight(size * 16 + 96)
        TradeSkillFrame.RecipeInset:SetHeight(size * 16 + 10)
        TradeSkillFrame.DetailsInset:SetHeight(size * 16 - 10)
        TradeSkillFrame.DetailsFrame:SetHeight(size * 16 - 15)
        TradeSkillFrame.DetailsFrame.Background:SetHeight(size * 16 - 17)
        TradeSkillFrame.DetailsFrame.ExitButton:Hide()
        TradeSkillFrame.LinkToButton:SetPoint('BOTTOMRIGHT', TradeSkillFrame, 'TOPRIGHT', -10, -81)
        TradeSkillFrame.FilterButton:SetPoint('TOPRIGHT', TradeSkillFrame, 'TOPRIGHT', -12, -31)
        TradeSkillFrame.FilterButton:SetHeight(17)
        TradeSkillFrame.RankFrame:SetPoint('TOP', TradeSkillFrame, 'TOP', -17, -33)
        TradeSkillFrame.RankFrame:SetWidth(500)
        TradeSkillFrame.SearchBox:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPLEFT', 163, -60)
        TradeSkillFrame.SearchBox:SetWidth(97)

        if TradeSkillFrame.RecipeList.FilterBar:IsVisible() then
            TradeSkillFrame.RecipeList:SetHeight(size * 16 - 11)
        else
            TradeSkillFrame.RecipeList:SetHeight(size * 16 + 5)
        end

        if #TradeSkillFrame.RecipeList.buttons < floor(size, 0.5) + 2 then
            local range = TradeSkillFrame.RecipeList.scrollBar:GetValue()
            HybridScrollFrame_CreateButtons(TradeSkillFrame.RecipeList, 'TradeSkillRowButtonTemplate', 0, 0)
            TradeSkillFrame.RecipeList.scrollBar:SetValue(range)
        end
        TradeSkillFrame.RecipeList:Refresh()

        UIPanelWindows['TradeSkillFrame'].area = nil
        TradeSkillFrame:ClearAllPoints()
        TradeSkillFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', TradeSkillUIImprovedDB.x, TradeSkillUIImprovedDB.y)
    elseif event == 'TRADE_SKILL_LIST_UPDATE' then
        searchText = TradeSkillFrame.SearchBox:GetText()
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
            for _, id in pairs({prof1, prof2, cooking, archaeology, fishing, (IsSpellKnown(RUNEFORGING_ID) and RUNEFORGING_ID or nil)}) do
                if id == RUNEFORGING_ID then
                    FactoryCheckButton(id, index)
                else
                    local _, _, _, _, numAbilities, spellOffset = GetProfessionInfo(id)

                    for i = 1, numAbilities do
                        FactoryCheckButton(select(2, GetSpellBookItemInfo(spellOffset + i, BOOKTYPE_PROFESSION)), index)
                    end
                end
            end
		end
        TradeSkillFrame.SearchBox:SetText(searchText)
    elseif event == 'PLAYER_MOUNT_DISPLAY_CHANGED' then
        if TradeSkillUIImprovedDB.options.colorRecipe then
            if TradeSkillUIImprovedDB.options.colorRecipeBag then
                ContainerFrame_UpdateAll()
            end
        end
    elseif event == 'ARCHAEOLOGY_CLOSED' then -- Fix the highlight of Archaeology when the frame is not closed with the checkbox tab frame.
        for i = 1, index do
            local tab = _G['TradeSkillUIImprovedTab' .. i]
            if tab and tab.id == ARCHAEOLOGY_ID then
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

hooksecurefunc(TradeSkillFrame.RecipeList, 'UpdateFilterBar', function(self)
	if self.FilterBar:IsVisible() then
		self:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 - 11)
	else
		self:SetHeight(TradeSkillUIImprovedDB.options.factor * 16 + 5)
	end
end)

hooksecurefunc(TradeSkillFrame.RecipeList, 'RebuildDataList', function(self)
    if type(TradeSkillUIImprovedDB.BlackList) == 'table' and #TradeSkillUIImprovedDB.BlackList > 0 then
        for i, listData in ipairs(self.dataList) do
            if listData.type == 'recipe' and TradeSkillUIImproved.isRecipeIDInTable(TradeSkillUIImprovedDB.BlackList, listData.recipeID) then
                table.remove(self.dataList, i)
            end
            if listData.type == 'subheader' and TradeSkillUIImproved.isRecipeIDInTable(TradeSkillUIImprovedDB.BlackList, listData.categoryID) then
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
        namePrint(L["The clicked categoryID is"] .. ' |cffffff00' .. categoryInfo.categoryID .. '|r.')
    end
end)
