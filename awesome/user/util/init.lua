-----------------------------------------------------------------------------------------------------------------------
--                                                     user/util                                                     --
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable

local wrequire = function(table_, key)
	local module = rawget(table_, key)
	return module or require(table_._NAME .. '.' .. key)
end

local setmetatable = setmetatable

local lib = { _NAME = "user.util", wrequire = wrequire }

return setmetatable(lib, { __index = wrequire })
