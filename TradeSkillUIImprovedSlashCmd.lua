local addonName, addon = ...
local L = addon.L

local addonVersion = GetAddOnMetadata(addonName, 'Version')
local TradeSkillUIImproved = addon.frame

local GetRecipeInfo, GetCategoryInfo = C_TradeSkillUI.GetRecipeInfo, C_TradeSkillUI.GetCategoryInfo

SLASH_TSUII1, SLASH_TSUII2 = '/TSUII', '/TradeSkillUIImproved'
SlashCmdList.TSUII = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == 'addBL' and args ~= '' then
        local tonumberArgs = tonumber(args)
        local recipeInfo = {}
        GetRecipeInfo(tonumberArgs, recipeInfo)

        if recipeInfo.name == nil then
            GetCategoryInfo(tonumberArgs, recipeInfo)
        end

        if TradeSkillUIImproved_IsInTable(TradeSkillUIImprovedDB.BlackList, tonumberArgs) then
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["is already in the blacklist."])
        else
            table.insert(TradeSkillUIImprovedDB.BlackList, { recipeID = (recipeInfo.recipeID or recipeInfo.categoryID), name = recipeInfo.name })
            TradeSkillUIImproved_Print(L["The recipeID"] .. ' |cffffff00' .. args .. '|r ' .. L["has been added in the blacklist."])
        end
    elseif cmd == 'delBL' and args ~= '' then
        local idElement = TradeSkillUIImproved_IsInTable(TradeSkillUIImprovedDB.BlackList, tonumber(args))

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
        if TradeSkillUIImproved_IsInTable(TradeSkillUIImprovedDB.BlackList, tonumber(args)) then
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
