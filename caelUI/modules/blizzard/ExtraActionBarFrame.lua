local private = unpack(select(2, ...))

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:SetPoint("BOTTOM", caelPanel_Minimap, "TOP", 0, private.pixel_scale(100))
