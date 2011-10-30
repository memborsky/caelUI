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

private.events:RegisterEvent("UNIT_AURA", function(_, _, unit)
    if unit ~= "player" then
        return
    end

    for buff, enabled in next, badBuffsList do
        if UnitAura(unit, buff) and enabled then
            CancelUnitBuff(unit, buff)
            private.print("BadBuff", " removed " .. buff)
        end
    end
end)