local _, caelBars = ...

local PixelScale = caelUI.config.PixelScale

local bar4 = CreateFrame("Frame", "bar4", UIParent)

bar4:SetAllPoints(caelPanel_ActionBar4)
MultiBarRight:SetParent(bar4)

local button
local buttonPrev

for index = 1, 12 do

    button = _G["MultiBarRightButton" .. index]
    buttonPrev = _G["MultiBarRightButton" .. index - 1]

    button:ClearAllPoints()
    button:SetScale(0.68625)
    button:SetAlpha(caelBars.settings.buttonAlpha)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar4, PixelScale(5), PixelScale(-5))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarRightButton1"], "BOTTOMLEFT", 0, PixelScale(-6))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", PixelScale(5), 0)
    end
end
