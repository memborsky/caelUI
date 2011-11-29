local _, caelBars = ...

local pixel_scale = caelUI.config.pixel_scale

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
    button:SetAlpha(0.45)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar4, pixel_scale(5), pixel_scale(-2))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarRightButton1"], "BOTTOMLEFT", 0, pixel_scale(-2))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", pixel_scale(2), 0)
    end
end
