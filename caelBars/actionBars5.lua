--[[    $Id$   ]]

local _, caelBars = ...

local pixelScale = caelUI.pixelScale

local playerClass = caelLib.playerClass

local bar5 = CreateFrame("Frame", "bar5", UIParent)

bar5:SetAllPoints(caelPanel_ActionBar5)
MultiBarLeft:SetParent(bar5)

for index = 1, 12 do

    local button = _G["MultiBarLeftButton" .. index]
    local buttonPrev = _G["MultiBarLeftButton" .. index - 1]

    button:ClearAllPoints()
    button:SetScale(0.68625)
    button:SetAlpha(0.45)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar5, pixelScale(2), pixelScale(-2))
    else
        button:SetPoint("TOP", buttonPrev, "BOTTOM", 0, pixelScale(-2))
    end

    -- mouse over enable
    if (caelBars.actionBar["settings"]["showBar5"] == true and caelBars.actionBar["settings"]["mouseOverBar5"] == true) then
        button:SetScript("OnEnter", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 1) end)
        button:SetScript("OnLeave", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0) end)
        caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0)
    end
end

if not caelBars.actionBar["settings"]["showBar5"] == true then
    -- Move the 4th bar to the right if we hide this bar
    if caelBars.actionBar["settings"]["showBar4"] == true then
        for index = 1, caelPanel_ActionBar5:GetNumRegions() do
            caelPanel_ActionBar4:SetPoint(caelPanel_ActionBar5:GetPoint(index))
        end
    end

    caelPanel_ActionBar5:Hide()
    MultiBarLeft:Hide()
    bar5:Hide()
elseif caelBars.actionBar["settings"]["mouseOverBar5"] == true then
    caelPanel_ActionBar5:EnableMouse(true)
    caelPanel_ActionBar5:SetScript("OnEnter", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 1) end)
    caelPanel_ActionBar5:SetScript("OnLeave", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0) end)
    caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0)
end
