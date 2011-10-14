local _, caelCore = ...

local afkspin = caelCore.createModule("AfkSpin")

if GetCVar("AutoClearAFK") == 0 then
    SetCVar("AutoClearAFK", 1)
end

local dimmer = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
dimmer:SetAllPoints()
RegisterStateDriver(dimmer, "visibility", "[combat] hide")

dimmer.button = CreateFrame("Button", nil, dimmer, "SecureActionButtonTemplate")
dimmer.button:SetHighlightTexture(nil)
dimmer.button:SetPushedTexture(nil)
dimmer.button:SetNormalTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
dimmer.button:SetAttribute("type", "macro")
dimmer.button:SetAttribute("macrotext", "/afk")
dimmer.button:RegisterForClicks("AnyDown")
dimmer.button:SetAllPoints()

-- Hide the frame on load.
dimmer:Hide()

-- Makes all the magic happen
afkspin:RegisterEvent("PLAYER_FLAGS_CHANGED")
afkspin:RegisterEvent("PLAYER_REGEN_DISABLED")
afkspin:RegisterEvent("PLAYER_REGEN_ENABLED")
afkspin:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_REGEN_DISABLED" then
        if UnitIsAFK("player") then
            MoveViewRightStop()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if UnitIsAFK("player") then
            MoveViewRightStart(0.01)
            dimmer:Show()
        end
    end

    if unit ~= "player" then return end

    if event == "PLAYER_FLAGS_CHANGED" then
        if UnitIsAFK(unit) then
            if not InCombatLockdown() then
                dimmer:Show()
                MoveViewRightStart(0.01)
            end
        else
            MoveViewRightStop()

            if dimmer:IsVisible() and not InCombatLockdown() then
                dimmer:Hide()
            end
        end
    end
end)
