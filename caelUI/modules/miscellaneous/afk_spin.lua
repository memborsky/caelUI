local private = unpack(select(2, ...))

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
dimmer.button:RegisterForClicks("AnyUp")
dimmer.button:SetAllPoints()

-- Hide the frame if it is visible on entering the world load.
private.events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if dimmer:IsVisible() then
        dimmer:Hide()
    end
end)

-- Everything below here makes the magic happen for the afk spinner.


-- This works to start and stop the screen spinning and dimmer showing when we go afk and come back.
private.events:RegisterEvent("PLAYER_FLAGS_CHANGED", function(_, _, unit)
    -- Quit if the unit the event fired from is not ourselves.
    if unit ~= "player" then
        return
    end

    -- Quit if we are in combat when we go afk. This solves so many possible taint issues with the dimmer frame.
    if UnitIsAFK(unit) and InCombatLockdown() then
        return
    end

    if UnitIsAFK(unit) then
        MoveViewRightStart(0.01)
        dimmer:Show()
    else
        MoveViewRightStop()

        if dimmer:IsVisible() then
            dimmer:Hide()
        end
    end
end)

private.events:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    if UnitIsAFK("player") then
        MoveViewRightStart(0.01)
        dimmer:Show()
    end
end)

private.events:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    if UnitIsAFK("player") and dimmer:IsVisible() then
        MoveViewRightStop()
        dimmer:Hide()
    end
end)
