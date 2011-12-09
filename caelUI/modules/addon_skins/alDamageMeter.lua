local alDMS = CreateModule("alDamageMeterSkin")

if not IsAddOnLoaded("alDamageMeter") then return end

local pixel_scale = alDMS.pixel_scale

local function SkinBar (self)

end

alDMS:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    -- Clear the backdrop as we manage that with our own panel creation system.
    alDamageMeterFrame.bg:SetBackdropColor(0, 0, 0, 0)
    alDamageMeterFrame.bg:SetBackdropBorderColor(0, 0, 0, 0)

    -- Reposition and size the frame.
    alDamageMeterFrame:ClearAllPoints()

    -- Position and Size
    alDamageMeterFrame:SetSize(caelPanel_DamageMeter:GetSize())
    alDamageMeterFrame:SetPoint("TOPLEFT", caelPanel_DamageMeter, "TOPLEFT", 0, -pixel_scale(10))
    alDamageMeterFrame:SetPoint("BOTTOMRIGHT", caelPanel_DamageMeter, "BOTTOMRIGHT")
end)