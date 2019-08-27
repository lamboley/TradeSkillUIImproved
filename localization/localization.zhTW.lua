local _, addon = ...

local L = addon.L

if GetLocale() == "zhTW" then
    L["A reload is |cffffff00necessary|r."] = "|cffffff00需要|r介面重載。"
    L["Add a recipeID in the blacklist."] = "新增配方ID到黑名單。"
    L["Allow to change the factor of the size of the tradeskill UI.\\n\\nDefault is 55 and Blizzard's default is 27.\\n\\nA reload is necessary."] = "允許更改專業技能介面的大小係數。\\n\\n預設值為55，暴雪的預設值為27. \\n\\n需要重載。"
    L["Arguments :"] = "參數："
    L["Change the color in the bag."] = "更改背包中的顏色。"
    L["Change the color in the bank."] = "更改銀行中的顏色。"
    L["Change the color of an icon if an item in the bag is already learned.\\n\\nA reload is necessary."] = "如果背包中的物品已經學習，更改圖示的顏色。\\n\\n需要重載。"
    L["Change the color of an icon if an item in the bank is already learned.\\n\\nA reload is necessary."] = "如果銀行中的物品已經學習，更改圖示的顏色。\\n\\n需要重載。"
    L["Change the color of an icon if the item (merchant, auction, bag, bank) is already learned.\\n\\nA reload is necessary."] = "已經學習的物品改變圖示的顏色(商店、拍賣場、背包、銀行)。\\n\\n需要重載。"
    L["Change the color of an icon if the item is already learned."] = "已經學習的物品改變圖示的顏色。"
    L["Content of the blacklist :"] = "黑名單的內容："
    L["Content of the blacklist with the pattern"] = "包含圖樣的黑名單內容"
    L["Delete the recipeID from the blacklist."] = "從黑名單中刪除此配方ID。"
    L["has been added in the blacklist."] = "已經加入黑名單。"
    L["has been removed from the blacklist."] = "已經從黑名單移除。"
    L["Hide the AH button if the addon Auctionator is loaded."] = "當插件Auctionator載入時隱藏AH按鈕。"
    L["is already in the blacklist."] = "已經在黑名單中。"
    L["is in the blacklist."] = "在黑名單中。"
    L["is not in the blacklist, there is nothing to remove."] = "不在黑名單中，沒什麼要移除的。"
    L["isn't in the blacklist."] = "不在黑名單中。"
    L["No recipe is selected."] = "沒有已選的配方。"
    L["Show if the recipeID is in the blacklist."] = "顯示配方ID是否在黑名單中。"
    L["Show the data of the blacklist. If an argument is passed, a pattern case-sensitive while be executed on the recipeID and the name."] = "顯示黑名單的數據。 如果略過參數，圖紙將同時在配方ID和名稱上區分大小寫。"
    L["Show the option window."] = "顯示選項視窗。"
    L["Show the version of the addon."] = "顯示此插件的版本。"
    L["Size factor"] = "尺寸係數"
    L["substring"] = "次層字串"
    L["The addon Auctionator had a button in the tradeskill UI. This options allow you to hide that button.\\n\\nA reload is necessary."] = "插件Auctionator在專業技能介面中有一個按鈕。 此選項允許您隱藏該按鈕。\\n\\n需要重載。"
    L["The blacklist is empty."] = "黑名單已滿。"
    L["The clicked categoryID is"] = "點擊的類別ID是"
    L["The recipeID"] = "配方ID"
    L["The selected recipeID is"] = "選擇的配方ID是"
    L["The version of the addon is"] = "此插件的版本為"
end

addon.L = L
