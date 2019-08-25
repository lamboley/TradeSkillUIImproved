local addonName, addon = ...
local L = addon.L

local TradeSkillUIImproved = addon.frame
TradeSkillUIImproved.name = addonName

local function TradeSkillUIImproved_SetTextColor(c)
    TradeSkillUIImproved_OptionsCheckBoxRecipeBankText:SetText('|cff' .. c .. L["Change the color in the bank."] .. '|r')
    TradeSkillUIImproved_OptionsCheckBoxRecipeBagText:SetText('|cff' .. c .. L["Change the color in the bag."] .. '|r')
end

local function TradeSkillUIImproved_EnableCheckColor(self)
    if self:GetChecked() then
        TradeSkillUIImproved_SetTextColor('ffffff')
    else
        TradeSkillUIImproved_SetTextColor('7a7a7a')
    end
end

function TradeSkillUIImproved_CreateInterfaceOptions()
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

        TradeSkillUIImproved_EnableCheckColor(self)
    end)

    TradeSkillUIImproved_EnableCheckColor(TradeSkillUIImproved_OptionsCheckBoxRecipe)

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

    TradeSkillUIImproved_OptionsSliderSize:SetValue(TradeSkillUIImprovedDB.options.factor)

    InterfaceOptions_AddCategory(TradeSkillUIImproved)
end
