local TradeSkillUIImproved = TradeSkillUIImproved
local L = TradeSkillUIImproved.L

local namePrint = TradeSkillUIImproved.namePrint

local recipeIDButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
recipeIDButton:SetText('recipeID')
recipeIDButton:SetWidth(85)
recipeIDButton:SetHeight(22)
recipeIDButton:ClearAllPoints()
recipeIDButton:SetPoint('BOTTOMRIGHT', TradeSkillFrame.DetailsFrame.CreateButton, 'BOTTOMRIGHT', 85, 0)
recipeIDButton:SetScript('OnClick', function()
    local recipeID = TradeSkillFrame.RecipeList.selectedRecipeID
    if recipeID ~= nil then
        namePrint(L["The selected recipeID is"] .. ' |cffffff00' .. recipeID .. '|r.')
    else
        namePrint(L["No recipe is selected."])
    end
end)
