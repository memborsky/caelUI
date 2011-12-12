local _, caelBars = ...

local PixelScale = caelUI.config.PixelScale

local bar3 = CreateFrame("Frame", "bar3", UIParent)

bar3:SetAllPoints(caelPanel_ActionBar3)
MultiBarBottomRight:SetParent(bar3)

local button
local buttonPrev

for index = 1, 12 do

    button = _G["MultiBarBottomRightButton" .. index]
    buttonPrev = _G["MultiBarBottomRightButton" .. index - 1]

    button:ClearAllPoints()
    button:SetScale(0.68625)
    button:SetAlpha(caelBars.settings.buttonAlpha)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar3, PixelScale(5), PixelScale(-5))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarBottomRightButton1"], "BOTTOMLEFT", 0, PixelScale(-6))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", PixelScale(5), 0)
    end
end
