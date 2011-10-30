local private = unpack(select(2, ...))

local pixel_scale = private.database.get("config")["pixel_scale"]
local ShowCloak = ShowCloak
local ShowHelm = ShowHelm

--- XXX: This is killed in 4.3
--- These are removed on the PTR and are replaced with a built in UI element on the
--- character model frame that does the same thing plus (un)zoom the character model.
--- This will display a rotate left and right button for the character model frame. 
if not private.ptr_check() then
    CharacterModelFrameRotateLeftButton:ClearAllPoints()
    CharacterModelFrameRotateLeftButton:SetScale(pixel_scale(0.85))
    CharacterModelFrameRotateLeftButton:SetPoint("BOTTOMRIGHT", CharacterModelFrame, "BOTTOM", pixel_scale(1), pixel_scale(20))

    CharacterModelFrameRotateRightButton:ClearAllPoints()
    CharacterModelFrameRotateRightButton:SetScale(pixel_scale(0.85))
    CharacterModelFrameRotateRightButton:SetPoint("BOTTOMLEFT", CharacterModelFrame, "BOTTOM", pixel_scale(-1), pixel_scale(20))
end

---
--- Add a checkbox to the character model frame (Default Hotkey "c") to show/hide the helm.
---
local helm = CreateFrame("CheckButton", nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
helm:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", pixel_scale(7), pixel_scale(6))
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
cloak:SetPoint("LEFT", CharacterHeadSlot, "RIGHT", pixel_scale(7), pixel_scale(-15))
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
undress:SetHeight(pixel_scale(22))
undress:SetWidth(pixel_scale(80))
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
