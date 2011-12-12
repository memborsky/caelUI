local _, caelBars = ...

local PixelScale = caelUI.config.PixelScale

local bar5 = CreateFrame("Frame", "bar5", UIParent)

bar5:SetAllPoints(caelPanel_ActionBar5)
MultiBarLeft:SetParent(bar5)

for index = 1, 12 do

    local button = _G["MultiBarLeftButton" .. index]
    local buttonPrev = _G["MultiBarLeftButton" .. index - 1]

    button:ClearAllPoints()
    button:SetScale(0.68625)
    button:SetAlpha(caelBars.settings.buttonAlpha)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar5, PixelScale(5), PixelScale(-5))
    else
        button:SetPoint("TOP", buttonPrev, "BOTTOM", 0, PixelScale(-5))
    end

    -- mouse over enable
    if (caelBars.settings["showBar5"] == true and caelBars.settings.mouseOverBar5 == true) then
        button:SetScript("OnEnter", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 1) end)
        button:SetScript("OnLeave", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0) end)
        caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0)
    end
end

if not caelBars.settings["showBar5"] == true then
    -- Move the 4th bar to the right if we hide this bar
    if caelBars.settings["showBar4"] == true then
        for index = 1, caelPanel_ActionBar5:GetNumRegions() do
            caelPanel_ActionBar4:SetPoint(caelPanel_ActionBar5:GetPoint(index))
        end
    end

    caelPanel_ActionBar5:Hide()
    MultiBarLeft:Hide()
    bar5:Hide()
elseif caelBars.settings.mouseOverBar5 == true then
    caelPanel_ActionBar5:EnableMouse(true)
    caelPanel_ActionBar5:SetScript("OnEnter", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 1) end)
    caelPanel_ActionBar5:SetScript("OnLeave", function() caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0) end)
    caelBars.MouseOverBar(caelPanel_ActionBar5, MultiBarLeft, MultiBarLeftButton, 0)
end
