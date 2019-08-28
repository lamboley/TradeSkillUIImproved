local CreateFrame, GetCategories, GetSubCategories
    = CreateFrame, C_TradeSkillUI.GetCategories, C_TradeSkillUI.GetSubCategories

local collapseButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
collapseButton:SetText('-')
collapseButton:SetWidth(20)
collapseButton:SetHeight(20)
collapseButton:ClearAllPoints()
collapseButton:SetPoint('LEFT', TradeSkillFrame.SearchBox, 'RIGHT', 3, 0)
collapseButton:SetScript('OnClick', function()
    local categories = {GetCategories()}
    for _, categoryID in ipairs(categories) do
        local subCategories = {GetSubCategories(categoryID)}
        for _, subId in ipairs(subCategories) do
            TradeSkillFrame.RecipeList.collapsedCategories[subId] = true
        end
    end
    TradeSkillFrame.RecipeList:Refresh()
end)

local expandButton = CreateFrame('Button', nil, TradeSkillFrame, 'UIPanelButtonTemplate')
expandButton:SetText('+')
expandButton:SetWidth(20)
expandButton:SetHeight(20)
expandButton:ClearAllPoints()
expandButton:SetPoint('LEFT', collapseButton, 'RIGHT', 3, 0)
expandButton:SetScript('OnClick', function()
    local categories = {GetCategories()}
    for _, categoryID in ipairs(categories) do
        local subCategories = {GetSubCategories(categoryID)}
        for _, subId in ipairs(subCategories) do
            TradeSkillFrame.RecipeList.collapsedCategories[subId] = nil
        end
    end
    TradeSkillFrame.RecipeList:Refresh()
end)
