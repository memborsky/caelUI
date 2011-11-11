local private = unpack(select(2, ...))

-- Make sure we are auto clearing our AFK status when we return from being away.
if GetCVar("AutoClearAFK") == 0 then
    SetCVar("AutoClearAFK", 1)
end

-- Internal: The frame that dims the screen when we go Away.
local dimmer = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
dimmer:SetHighlightTexture(nil)
dimmer:SetPushedTexture(nil)
dimmer:SetNormalTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
dimmer:RegisterForClicks("AnyUp")
dimmer:SetAllPoints()
RegisterStateDriver(dimmer, "visibility", "[combat] hide")

-- Internal: Starts the dimmer and camera move when the player goes Away.
--
-- frame - This is the dimmer frame we want to show.
--
-- Examples
--
--   GoAFK(dimmer)
--
-- Returns nothing.
function dimmer.GoAFK (self)
    MoveViewRightStart(0.01)
    self:Show()
end

-- Internal: Stops the dimmer and camera moving when the player returns from Away.
--
-- frame - This is the dimmer frame we want to hide.
--
-- Examples
--
--   ReturnFromBeingAFK(dimmer)
--
-- Returns nothing.
function dimmer.ReturnFromBeingAFK (self)
    MoveViewRightStop()
    self:Hide()
end

-- Internal: Make sure that when we click the dimmer frame it hides and clears
-- our afk state immediately instead of the delayed time waiting for the
-- PLAYER_FLAGS_EVENT to trigger.
--
-- Fixes Issue #<personal no number>: The frame would not :Hide() fast enough
-- and would be left with a constant spam of Away, Return, Away, Return actions.
dimmer:SetScript("OnClick", function(self)
    if UnitIsAFK("player") then
        -- Make sure we clear the player's Away status when the frame is clicked.
        SendChatMessage("", "AFK")

        -- Stop our AFK state.
        self:ReturnFromBeingAFK()
    end
end)

-- Internal: This function will toggle our AFK state for us.
--
-- override - Overrides our check for being in combat.
--
-- Examples
--
--  ToggleAFKState()
--
-- Returns nothing.
local function ToggleAFKState (override)
    -- We want to make sure that we are not in combat before we attempt to
    -- start/stop our AFK spinning state. This is due to frame tainting while
    -- in combat.
    -- If the override flag is true, we skip checking for not being in combat.
    if override or not InCombatLockdown() then

        -- Start and stop the player's AFK state.
        if UnitIsAFK("player") then
            dimmer:GoAFK()
        else
            dimmer:ReturnFromBeingAFK()
        end

    end
end

-- Internal: The following section of code will register all the events we need
-- to for managing our changes in AFK state.
--
-- event - This is the event we are currently on in the list of events.
--
-- event = "PLAYER_ENTERING_WORLD"
--   When entering the game world, return our player to the AFK state that they
--   are currently in. This will reactive the camera move and dimmer frame if
--   they happen to ReloadUI() while being Away.
-- event = "PLAYER_FLAGS_CHANGED"
--   When our flags change, check to see if the event was fired by the player.
--   If it was, then check to see if the player has changed flags because they
--   have gone Away. If they have, start the AFK state, else make sure we are in
--   a stopped AFK state.
-- event = "PLAYER_REGEN_ENABLED"
--   This means the player has left combat and we can move the camera and show
--   the dimmer frame again.
-- event = "PLAYER_REGEN_DISABLED"
--   This means the player has entered combat and we need to stop our player's
--   camera and dimmer frame from being shown.
for _, event in next, {"PLAYER_ENTERING_WORLD", "PLAYER_FLAGS_CHANGED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED"} do
    private.events:RegisterEvent(event, function(_, event, ...)
        if event == "PLAYER_FLAGS_CHANGED" then
            local unit = ...
            if unit ~= "player" then
                return
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            ToggleAFKState(true)
            return
        end

        ToggleAFKState()
    end)
end

