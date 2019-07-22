local _, L = ...
--print(L["Hello World!"]);

if IsAddOnLoaded('Auctionator') then Auctionator_Search:Hide() end

TradeSkillFrame.DetailsFrame.ExitButton:Hide()
TradeSkillFrame.SearchBox:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPLEFT', 163, -60)
TradeSkillFrame.SearchBox:SetWidth(97)

TradeSkillUIImprovedDB = TradeSkillUIImprovedDB or { size = 55, x = 1032, y = 151, BlackList = {} }

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

local TradeSkillUIImproved = CreateFrame('Frame', 'TradeSkillUIImproved')
TradeSkillUIImproved:RegisterEvent('PLAYER_LOGIN')

TradeSkillUIImproved.version = GetAddOnMetadata('TradeSkillUIImproved', 'Version')

TradeSkillUIImproved:SetScript('OnEvent', function(_, event, ...)
    if event == 'PLAYER_LOGIN' then
        TradeSkillFrame:SetHeight(TradeSkillUIImprovedDB.size * 16 + 96)
        TradeSkillFrame.RecipeInset:SetHeight(TradeSkillUIImprovedDB.size * 16 + 10)
        TradeSkillFrame.DetailsInset:SetHeight(TradeSkillUIImprovedDB.size * 16 - 10)
        TradeSkillFrame.DetailsFrame:SetHeight(TradeSkillUIImprovedDB.size * 16 - 15)
        TradeSkillFrame.DetailsFrame.Background:SetHeight(TradeSkillUIImprovedDB.size * 16 - 17)

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
    end
end)

local function TradeSkillUIImproved_SlashCmd(msg, editbox)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == 'addBL' and args ~= '' then
        local tonumberArgs = tonumber(args)
        local recipeInfo = {}
        C_TradeSkillUI.GetRecipeInfo(tonumberArgs, recipeInfo)

        if IsInTable(TradeSkillUIImprovedDB.BlackList, tonumberArgs) then
            TradeSkillUIImproved_Print('Le recipeID |cffffff00' .. args .. '|r est déjà dans la blacklist.')
        else
            table.insert(TradeSkillUIImprovedDB.BlackList, { recipeID = recipeInfo.recipeID, name = recipeInfo.name })
            TradeSkillUIImproved_Print('Le recipeID |cffffff00' .. args .. '|r a été ajouté dans la blacklist.')
        end
    elseif cmd == 'delBL' and args ~= '' then
        local idElement = IsInTable(TradeSkillUIImprovedDB.BlackList, tonumber(args))

        if idElement then
            table.remove(TradeSkillUIImprovedDB.BlackList, idElement)
            TradeSkillUIImproved_Print('Le recipeID |cffffff00' .. args .. "|r a été supprimé de la blacklist.")
        else
            TradeSkillUIImproved_Print('Le recipeID |cffffff00' .. args .. "|r n'est pas dans la blacklist, il n'y a donc rien à enlever.")
        end
    elseif cmd == 'showBL' then
        if #TradeSkillUIImprovedDB.BlackList == 0 then
            TradeSkillUIImproved_Print('La blacklist est vide.')
        elseif args == '' then
            TradeSkillUIImproved_Print('Contenu de la blacklist :')
                print('  index,recipeID,name')
            for i, recipeIDTable in ipairs(TradeSkillUIImprovedDB.BlackList) do
                print('  ' .. i .. ',' .. recipeIDTable.recipeID .. ',' .. recipeIDTable.name)
            end
        else
            TradeSkillUIImproved_Print("Contenu de la blacklist avec le pattern '" .. args .. "' :")
            print('  index,recipeID,name')
            for i, recipeIDTable in ipairs(TradeSkillUIImprovedDB.BlackList) do
                if string.match(recipeIDTable.recipeID, args) or string.match(recipeIDTable.name, args) then
                    print('  ' .. i .. ',' .. recipeIDTable.recipeID .. ',' .. recipeIDTable.name)
                end
            end
        end
    elseif cmd == 'isBL' and args ~= '' then
        if IsInTable(TradeSkillUIImprovedDB.BlackList, tonumber(args)) then
            TradeSkillUIImproved_Print('Le recipeID |cffffff00' .. args .. '|r est dans la blacklist.')
        else
            TradeSkillUIImproved_Print('Le recipeID |cffffff00' .. args .. "|r n'est pas dans la blacklist.")
        end
    elseif cmd == 'getSize'then
        TradeSkillUIImproved_Print("Le multiplicateur de taille est à |cffffff00" .. TradeSkillUIImprovedDB.size .. "|r.")
    elseif cmd == 'setSize' and args ~= '' then
        TradeSkillUIImprovedDB.size = args
        TradeSkillUIImproved_Print("Le multiplicateur de taille a été placé à |cffffff00" .. TradeSkillUIImprovedDB.size .. "|r. Un rechargement de l'interface est |cffffff00nécéssaire|r pour éviter tout bug d'affichage.")
    elseif cmd == 'version' then
        TradeSkillUIImproved_Print("La version de l'addon est |cffffff00" .. TradeSkillUIImproved.version .. '|r.')
    else
        TradeSkillUIImproved_Print('Arguments :')
        print("  |cfffff194addBL|r - Ajoute un recipeID dans la blacklist.")
        print("  |cfffff194delBL|r - Supprime le recipeID de la blacklist.")
        print("  |cfffff194showBL [sous-chaîne]|r - Affiche le contenu de la blacklist. Si un argument est passé, un pattern sensible à la casse sera fait sur le recipeID et le nom.")
        print("  |cfffff194isBL|r - Affiche si le recipeID est dans la blacklist.")
        print("  |cfffff194getSize|r - Affiche la valeur du multiplicateur de taille.")
        print("  |cfffff194setSize|r - Modifie la valeur du multiplicateur de taille. Un rechargement de l'interface est nécessaire.")
        print("  |cfffff194version|r - Affiche la version de l'addon")
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
    for i, listData in ipairs(self.dataList) do
        if IsInTable(TradeSkillUIImprovedDB.BlackList, listData.recipeID) then
            table.remove(self.dataList, i)
        end
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

local TradeSkillUIImproved_ExpandButton  = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
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

local TradeSkillUIImproved_SelectedRecipeIDButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
TradeSkillUIImproved_SelectedRecipeIDButton:SetText('recipeID')
TradeSkillUIImproved_SelectedRecipeIDButton:SetWidth(85)
TradeSkillUIImproved_SelectedRecipeIDButton:SetHeight(22)
TradeSkillUIImproved_SelectedRecipeIDButton:ClearAllPoints()
TradeSkillUIImproved_SelectedRecipeIDButton:SetPoint('BOTTOMRIGHT', TradeSkillFrame.DetailsFrame.CreateButton, 'BOTTOMRIGHT', 85, 0)
TradeSkillUIImproved_SelectedRecipeIDButton:SetScript('OnClick', function()
    TradeSkillUIImproved_Print('Le recipeID selectionné est |cffffff00' .. TradeSkillFrame.RecipeList.selectedRecipeID .. '|r.')
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
