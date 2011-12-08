local private = unpack(select(2, ...))

local module_metatable = {
    __index = function(_, name) CreateFrame("Frame", "caelUI_" .. name, UIParent),
}

function module_metatable.__index:CreatePanel ()

end

private.CreateModule = setmetatable({}, module_metatable)