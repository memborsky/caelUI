local alDamageMeterSkin = unpack(select(2, ...)).CreateModule("alDamageMeterSkin")

if not IsAddOnLoaded("alDamageMeter") then return end

local PixelScale = alDamageMeterSkin.PixelScale

local function SkinBar (self)

end

alDamageMeterSkin:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    -- Clear the backdrop as we manage that with our own panel creation system.
    alDamageMeterFrame.bg:SetBackdropColor(0, 0, 0, 0)
    alDamageMeterFrame.bg:SetBackdropBorderColor(0, 0, 0, 0)

    -- Reposition and size the frame.
    alDamageMeterFrame:ClearAllPoints()

    -- Position and Size
    alDamageMeterFrame:SetSize(caelPanel_DamageMeter:GetSize())
    alDamageMeterFrame:SetPoint("TOPLEFT", caelPanel_DamageMeter, "TOPLEFT", 0, -PixelScale(10))
    alDamageMeterFrame:SetPoint("BOTTOMRIGHT", caelPanel_DamageMeter, "BOTTOMRIGHT")
end)