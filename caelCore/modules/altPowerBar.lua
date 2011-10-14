PlayerPowerBarAlt:SetMovable(true)
PlayerPowerBarAlt:EnableMouse(true)
PlayerPowerBarAlt:SetUserPlaced(true)
PlayerPowerBarAlt:SetClampedToScreen(true)
PlayerPowerBarAlt:RegisterForDrag("LeftButton")

PlayerPowerBarAlt:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

PlayerPowerBarAlt:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
