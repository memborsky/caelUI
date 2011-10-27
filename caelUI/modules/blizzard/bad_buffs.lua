-- Auto cancel various buffs
local private = unpack(select(2, ...))

local badBuffsList = {
    ["Mohawked!"]			= true,
    ["Rabbit Costume"]		= true,
    ["Hand of Proection"]	= true,
    ["Jack-o'-Lanterned!"]	= true,
    ["Skeleton Costume"]    = true,
    ["Bat Costume"]         = true,
    ["Wisp Costume"]        = true,
    ["Ghost Costume"]       = true,
    ["Pirate Costume"]      = true,
}

private.events:RegisterEvent("UNIT_AURA", function(self, event)
    for k, v in pairs(badBuffsList) do
        if UnitAura("player", k) then
            CancelUnitBuff("player", k)
            print("|cffD7BEA5cael|rCore: removed "..k)
        end
    end
end)
