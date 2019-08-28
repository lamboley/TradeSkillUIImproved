TradeSkillUIImproved.L = setmetatable({}, { __index = function(self, key)
	local str = tostring(key)
	rawset(self, key, str)
	return str
end})
