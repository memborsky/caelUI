local _, caelBars = ...

local pixel_scale = caelUI.config.pixel_scale

local bar2 = CreateFrame("Frame", "bar2", UIParent)

bar2:SetAllPoints(caelPanel_ActionBar2)
MultiBarBottomLeft:SetParent(bar2)

local button
local buttonPrev

for index = 1, 12 do

    button = _G["MultiBarBottomLeftButton" .. index]
    buttonPrev = _G["MultiBarBottomLeftButton" .. index - 1]

    button:ClearAllPoints()
    button:SetScale(0.68625)
    button:SetAlpha(0.45)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar2, pixel_scale(2), pixel_scale(-2))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarBottomLeftButton1"], "BOTTOMLEFT", 0, pixel_scale(-2))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", pixel_scale(2), 0)
    end
end
