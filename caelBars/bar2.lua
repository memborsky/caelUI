local _, caelBars = ...

local PixelScale = caelUI.config.PixelScale
local kill = caelUI.kill

local bar2 = CreateFrame("Frame", "bar2", UIParent)

bar2:SetAllPoints(caelPanel_ActionBar2)
MultiBarBottomLeft:SetParent(bar2)

local button
local buttonPrev
local floatBG

for index = 1, 12 do

    button = _G["MultiBarBottomLeftButton" .. index]
    buttonPrev = _G["MultiBarBottomLeftButton" .. index - 1]
    floatBG = _G[button:GetName() .. "FloatingBG"]

    if floatBG then
        kill(floatBG)
    end

    button:ClearAllPoints()
    button:SetScale(0.68625)
    button:SetAlpha(caelBars.settings.buttonAlpha)

    if index == 1 then
        button:SetPoint("TOPLEFT", caelPanel_ActionBar2, PixelScale(5), PixelScale(-5))
    elseif index == 7 then
        button:SetPoint("TOPLEFT", _G["MultiBarBottomLeftButton1"], "BOTTOMLEFT", 0, PixelScale(-6))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", PixelScale(5), 0)
    end
end
