TradeSkillUIImproved = {}
TradeSkillUIImproved.L = {}

TradeSkillUIImproved.versionString = GetAddOnMetadata('TradeSkillUIImproved', 'Version')
TradeSkillUIImproved.addonName = GetAddOnMetadata('TradeSkillUIImproved', 'Title')

TradeSkillUIImproved.namePrint = function(msg)
    print('|cff00ff00TSUII:|r' .. msg)
end

TradeSkillUIImproved.isRecipeIDInTable = function(list, id)
    for i, l in pairs(list) do
        if l.recipeID == id then
            return i
        end
    end
    return false
end

function TradeSkillUIImproved.InitializeDB()
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

    -- Ensure new upcoming option do not throw an error. Happen frequently
    -- when a player upgrade the addon and the new release add a new option
    -- var. The default option are not loaded because TradeSkillUIImprovedDB
    -- already exist, so the default value of the new option is not loaded.
    -- When we try to use it in the addon, his value is nil so an error is
    -- thrown. We fix it by cheking if the value of an option is nil, if so we
    -- initialize it.
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
end
