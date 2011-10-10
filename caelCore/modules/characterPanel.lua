--[[    $Id$    ]]

local _, caelCore = ...

local dummy = caelLib.dummy

local characterpanel = caelCore.createModule("CharacterPanel")

local pixelScale = caelUI.pixelScale

local helm = characterpanel.helm
local cloak = characterpanel.cloak
local undress = characterpanel.undress

CharacterModelFrameRotateLeftButton:ClearAllPoints()
CharacterModelFrameRotateLeftButton:SetScale(pixelScale(0.85))
CharacterModelFrameRotateLeftButton:SetPoint("RIGHT", PaperDollFrame, "RIGHT", pixelScale(-140), 0)

CharacterModelFrameRotateRightButton:ClearAllPoints()
CharacterModelFrameRotateRightButton:SetScale(pixelScale(0.85))
CharacterModelFrameRotateRightButton:SetPoint("RIGHT", PaperDollFrame, "RIGHT", pixelScale(-112.5), 0)

local ShowCloak, ShowHelm = ShowCloak, ShowHelm
_G.ShowCloak, _G.ShowHelm = dummy, dummy

for k, v in next, {InterfaceOptionsDisplayPanelShowCloak, InterfaceOptionsDisplayPanelShowHelm} do
    v:SetButtonState("DISABLED", true)
end

helm = CreateFrame("CheckButton", nil, PaperDollFrame, "OptionsCheckButtonTemplate")
helm:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", pixelScale(7), pixelScale(6))
helm:SetChecked(ShowingHelm())
helm:SetToplevel()
helm:RegisterEvent("PLAYER_FLAGS_CHANGED")
helm:SetScript("OnClick", function() ShowHelm(not ShowingHelm()) end)
helm:SetScript("OnEvent", function(self, event, unit)
    if(unit == "player") then
        self:SetChecked(ShowingHelm())
    end
end)
helm:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Toggles helmet model.")
end)
helm:SetScript("OnLeave", function() GameTooltip:Hide() end)

cloak = CreateFrame("CheckButton", nil, PaperDollFrame, "OptionsCheckButtonTemplate")
cloak:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", pixelScale(7), pixelScale(-15))
cloak:SetChecked(ShowingCloak())
cloak:SetToplevel()
cloak:RegisterEvent("PLAYER_FLAGS_CHANGED")
cloak:SetScript("OnClick", function() ShowCloak(not ShowingCloak()) end)
cloak:SetScript("OnEvent", function(self, event, unit)
    if(unit == "player") then
        self:SetChecked(ShowingCloak())
    end
end)
cloak:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Toggles cloak model.")
end)
cloak:SetScript("OnLeave", function() GameTooltip:Hide() end)

undress = CreateFrame("Button", nil, DressUpFrame, "UIPanelButtonTemplate")
undress:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT")
undress:SetHeight(pixelScale(22))
undress:SetWidth(pixelScale(80))
undress:SetText("Undress")
undress:SetScript("OnClick", function() DressUpModel:Undress() end)

local old_PaperDollFrame_SetItemLevel = PaperDollFrame_SetItemLevel
PaperDollFrame_SetItemLevel = function(statFrame, unit, ...)
    old_PaperDollFrame_SetItemLevel(statFrame, unit, ...)

    -- Exit when not the player unit.
    if unit ~= "player" then return end

    _G[statFrame:GetName().."StatText"]:SetText(math.floor(GetAverageItemLevel() * 10) / 10)
end
