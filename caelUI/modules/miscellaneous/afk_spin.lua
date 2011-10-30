local private = unpack(select(2, ...))

if GetCVar("AutoClearAFK") == 0 then
    SetCVar("AutoClearAFK", 1)
end

local dimmer = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
dimmer:SetHighlightTexture(nil)
dimmer:SetPushedTexture(nil)
dimmer:SetNormalTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
dimmer:RegisterForClicks("AnyUp")
dimmer:SetAllPoints()
RegisterStateDriver(dimmer, "visibility", "[combat] hide")

-- This is to prevent the frame from resetting the AFK status if we double click the giant button.
dimmer:SetScript("OnClick", function(self)
    if UnitIsAFK("player") then
        -- Unsets the AFK status.
        SendChatMessage("", "AFK")

        -- Hide the button so we can NOT double click the button and reset ourselves as away.
        self:Hide()
    end
end)

-- Hide the frame if it is visible on entering the world load.
private.events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if dimmer:IsVisible() then
        dimmer:Hide()
    end
end)

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
