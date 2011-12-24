local PixelScale = unpack(select(2, ...)).PixelScale

---
--- Add a checkbox to the character model frame (Default Hotkey "c") to show/hide the helm.
---
local helm = CreateFrame("CheckButton", nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
helm:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", PixelScale(7), PixelScale(6))
helm:SetChecked(ShowingHelm())
helm:SetToplevel()
helm:RegisterEvent("PLAYER_FLAGS_CHANGED")
helm:SetScript("OnClick", function() ShowHelm(not ShowingHelm()) end)
helm:SetScript("OnEvent", function(self, _, unit)
    if(unit == "player") then
        self:SetChecked(ShowingHelm())
    end
end)
helm:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Toggles helmet model.")
end)
helm:SetScript("OnLeave", function() GameTooltip:Hide() end)

---
--- Add a checkbox to the character model frame (Default Hotkey "c") to show/hide the cloak.
---
local cloak = CreateFrame("CheckButton", nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
cloak:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", PixelScale(7), PixelScale(-15))
cloak:SetChecked(ShowingCloak())
cloak:SetToplevel()
cloak:RegisterEvent("PLAYER_FLAGS_CHANGED")
cloak:SetScript("OnClick", function() ShowCloak(not ShowingCloak()) end)
cloak:SetScript("OnEvent", function(self, _, unit)
    if(unit == "player") then
        self:SetChecked(ShowingCloak())
    end
end)
cloak:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Toggles cloak model.")
end)
cloak:SetScript("OnLeave", function() GameTooltip:Hide() end)

---
--- Add an undress button to the dress up frame.
---
local undress = CreateFrame("Button", nil, DressUpFrame, "UIPanelButtonTemplate")
undress:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT")
undress:SetHeight(PixelScale(22))
undress:SetWidth(PixelScale(80))
undress:SetText("Undress")
undress:SetScript("OnClick", function() DressUpModel:Undress() end)

---
--- This will replace the item level value in our character panel with a more precise number at 1 decimal place.
---
local old_PaperDollFrame_SetItemLevel = PaperDollFrame_SetItemLevel
PaperDollFrame_SetItemLevel = function(statFrame, unit, ...)
    old_PaperDollFrame_SetItemLevel(statFrame, unit, ...)

    -- Exit when not the player unit.
    if unit ~= "player" then return end

    _G[statFrame:GetName().."StatText"]:SetText(math.floor(GetAverageItemLevel() * 10) / 10)
end
