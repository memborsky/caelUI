--[[    $Id$   ]]

local _, caelBars = ...

local pixelScale = caelLib.scale

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
        button:SetPoint("TOPLEFT", caelPanel_ActionBar2, pixelScale(2), pixelScale(-2))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarBottomLeftButton1"], "BOTTOMLEFT", 0, pixelScale(-2))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", pixelScale(2), 0)
    end
end