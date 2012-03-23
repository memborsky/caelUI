local PixelScale = unpack(select(2, ...)).PixelScale

PlayerPowerBarAlt:SetMovable(true)
PlayerPowerBarAlt:EnableMouse(true)
PlayerPowerBarAlt:SetClampedToScreen(true)
PlayerPowerBarAlt:RegisterForDrag("LeftButton")

PlayerPowerBarAlt:ClearAllPoints()
PlayerPowerBarAlt:SetParent(UIParent)
PlayerPowerBarAlt:SetPoint("BOTTOM", caelPanel_Minimap, "TOP", 0, PixelScale(100))

PlayerPowerBarAlt:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

PlayerPowerBarAlt:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
