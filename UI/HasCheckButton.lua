local GetOnlyShowSkillUpRecipes, GetOnlyShowMakeableRecipes
    = C_TradeSkillUI.GetOnlyShowSkillUpRecipes, C_TradeSkillUI.GetOnlyShowMakeableRecipes
local SetOnlyShowSkillUpRecipes, SetOnlyShowMakeableRecipes
    = C_TradeSkillUI.SetOnlyShowSkillUpRecipes, C_TradeSkillUI.SetOnlyShowMakeableRecipes

local TradeSkillUIImproved_CheckButtonHasMaterials = CreateFrame('CheckButton', 'TradeSkillUIImproved_CheckButtonHasMaterials', TradeSkillFrame, 'UICheckButtonTemplate')
TradeSkillUIImproved_CheckButtonHasMaterials:SetPoint('LEFT', TradeSkillFrame.SearchBox, 'RIGHT', 90, 0)
TradeSkillUIImproved_CheckButtonHasMaterials:SetWidth(24)
TradeSkillUIImproved_CheckButtonHasMaterials:SetHeight(24)
TradeSkillUIImproved_CheckButtonHasMaterialsText:SetText(CRAFT_IS_MAKEABLE)
TradeSkillUIImproved_CheckButtonHasMaterialsText:SetWidth(110)
TradeSkillUIImproved_CheckButtonHasMaterialsText:SetJustifyH('LEFT')
TradeSkillUIImproved_CheckButtonHasMaterials:SetChecked(GetOnlyShowMakeableRecipes())
TradeSkillUIImproved_CheckButtonHasMaterials:SetScript('OnClick', function()
    SetOnlyShowMakeableRecipes(TradeSkillUIImproved_CheckButtonHasMaterials:GetChecked())
end)

local TradeSkillUIImproved_CheckButtonHasSkillUp = CreateFrame('CheckButton', 'TradeSkillUIImproved_CheckButtonHasSkillUp', TradeSkillFrame, 'UICheckButtonTemplate')
TradeSkillUIImproved_CheckButtonHasSkillUp:SetPoint('LEFT', TradeSkillUIImproved_CheckButtonHasMaterials, 'RIGHT', 130, 0)
TradeSkillUIImproved_CheckButtonHasSkillUp:SetWidth(24)
TradeSkillUIImproved_CheckButtonHasSkillUp:SetHeight(24)
TradeSkillUIImproved_CheckButtonHasSkillUpText:SetText(TRADESKILL_FILTER_HAS_SKILL_UP)
TradeSkillUIImproved_CheckButtonHasSkillUpText:SetWidth(110)
TradeSkillUIImproved_CheckButtonHasSkillUpText:SetJustifyH('LEFT')
TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(GetOnlyShowSkillUpRecipes())
TradeSkillUIImproved_CheckButtonHasSkillUp:SetScript('OnClick', function()
    SetOnlyShowSkillUpRecipes(TradeSkillUIImproved_CheckButtonHasSkillUp:GetChecked())
end)

hooksecurefunc(C_TradeSkillUI, 'SetOnlyShowMakeableRecipes', function(show)
    TradeSkillUIImproved_CheckButtonHasMaterials:SetChecked(show)
end)

hooksecurefunc(C_TradeSkillUI, 'SetOnlyShowSkillUpRecipes', function(show)
    TradeSkillUIImproved_CheckButtonHasSkillUp:SetChecked(show)
end)
