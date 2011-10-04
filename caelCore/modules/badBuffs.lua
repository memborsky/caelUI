--[[    $Id$    ]]

if not caelLib.isCharListA then return end

local _, caelCore = ...

--[[    Auto cancel various buffs    ]]

local badbuffs = caelCore.createModule("BadBuffs")

local badBuffsList = {
    ["Mohawked!"]			= true,
    ["Rabbit Costume"]		= true,
    ["Hand of Proection"]	= true,
}

badbuffs:RegisterEvent("UNIT_AURA")
badbuffs:SetScript("OnEvent", function(self, event)
    for k, v in pairs(badBuffsList) do
        if UnitAura("player", k) then
            CancelUnitBuff("player", k)
            print("|cffD7BEA5cael|rCore: removed "..k)
        end
    end
end)
