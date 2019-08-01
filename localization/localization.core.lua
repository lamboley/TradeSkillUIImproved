local _, L = ...

local function defaultFunc(_, key)
    return key
end

setmetatable(L, {__index=defaultFunc})
