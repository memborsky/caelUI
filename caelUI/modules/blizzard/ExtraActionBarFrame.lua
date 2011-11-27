ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:SetMovable(true)
ExtraActionBarFrame:EnableMouse(true)
ExtraActionBarFrame:SetUserPlaced(true)
ExtraActionBarFrame:SetClampedToScreen(true)
ExtraActionBarFrame:RegisterForDrag("LeftButton")

ExtraActionBarFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

ExtraActionBarFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- ExtraActionBarFrame:SetPoint("CENTER", UIParent, "CENTER")
