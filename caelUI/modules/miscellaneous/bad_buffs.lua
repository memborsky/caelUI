-- Auto cancel various buffs
local BadBuffs = CreateModule("BadBuffs")

local blacklist = {
    ["Mohawked!"]			= true,
    ["Rabbit Costume"]		= true,
    ["Hand of Proection"]	= true,
    ["Jack-o'-Lanterned!"]	= true,
    ["Skeleton Costume"]    = true,
    ["Bat Costume"]         = true,
    ["Wisp Costume"]        = true,
    ["Ghost Costume"]       = true,
    ["Pirate Costume"]      = true,
    ["Turkey Feathers"]     = true,
    -- ["Hand of Protection"]  = true,
}

BadBuffs:RegisterEvent("UNIT_AURA", function(self, _, unit)
    if unit ~= "player" then
        return
    end

    for buff, enabled in next, blacklist do
        if UnitAura(unit, buff) and enabled and not InCombatLockdown() then
            CancelUnitBuff(unit, buff)
            self:Print("removed " .. buff)
        end
    end
end)
