--[[    $Id$   ]]

local _, caelBars = ...

local pixelScale = caelUI.pixelScale

local playerClass = caelLib.playerClass

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
    button:SetAlpha(0.45)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar3, pixelScale(2), pixelScale(-2))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarBottomRightButton1"], "BOTTOMLEFT", 0, pixelScale(-2))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", pixelScale(2), 0)
    end
end
