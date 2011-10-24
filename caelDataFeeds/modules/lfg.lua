local _, caelDataFeeds = ...

local lfg = caelDataFeeds.createModule("LFG")

local pixel_scale = caelUI.config.pixel_scale

lfg.text:SetPoint("CENTER", caelPanel_DataFeed, "CENTER", pixel_scale(-150), 0)

lfg:RegisterEvent"LFG_UPDATE"
lfg:RegisterEvent"UPDATE_LFG_LIST"
--lfg:RegisterEvent"LFG_PROPOSAL_SHOW"
lfg:RegisterEvent"LFG_PROPOSAL_UPDATE"
lfg:RegisterEvent"PARTY_MEMBERS_CHANGED"
lfg:RegisterEvent"LFG_ROLE_CHECK_UPDATE"
lfg:RegisterEvent"PLAYER_ENTERING_WORLD"
--lfg:RegisterEvent"LFG_COMPLETION_REWARD"
lfg:RegisterEvent"LFG_QUEUE_STATUS_UPDATE"

local format = string.format

local red, green = "AF5050", "559655"

local leaveMsg = caelUI.config.locale == "frFR" and "Merci pour le gruope, bye." or "Thank you for the group, goodbye."

AlertFrame:UnregisterEvent"LFG_COMPLETION_REWARD" -- Dont Show the Dungeon Complete Frame

local delay = 0
local expiryTime, deserterExpiration
local lfg_OnUpdate = function(self, elapsed)
    delay = delay - elapsed

    if delay < 0 then
        expiryTime = GetLFGRandomCooldownExpiration()
        deserterExpiration = GetLFGDeserterExpiration()

        if deserterExpiration then
            self.text:SetFormattedText("%s|cff%s%s|r", "|cffD7BEA5lfg|r ", red, SecondsToTime(deserterExpiration - GetTime()))
        elseif expiryTime then
            self.text:SetFormattedText("%s|cff%s%s|r", "|cffD7BEA5lfg|r ", red, SecondsToTime(expiryTime - GetTime()))
        else
            self:SetScript("OnUpdate", nil)
            self.text:SetText("|cffD7BEA5lfg|r Standby")
        end

        delay = 1
    end
end

lfg:SetScript("OnEvent", function(self, event)
    MiniMapLFGFrame:UnregisterAllEvents()
    MiniMapLFGFrame:Hide()
    MiniMapLFGFrame.Show = function() end

    local hasData, _, tankNeeds, healerNeeds, dpsNeeds, _, _, _, _, _, _, myWait = GetLFGQueueStats()

    local mode = GetLFGMode()

    if mode == "listed" then
        self.text:SetText("|cffD7BEA5LFR|r")
        return
    elseif mode == "queued" and not hasData then
        self.text:SetText("|cffD7BEA5lfg|r Searching")
        return
    elseif not hasData then
        self:SetScript("OnUpdate", lfg_OnUpdate)
        return
    end

    self.text:SetText(
        format("|cffD7BEA5lfg |r %s%s%s%s%s %s",
            format("|cff%s%s|r", tankNeeds == 0 and green or red, "T"),
            format("|cff%s%s|r", healerNeeds == 0 and green or red, "H"),
            format("|cff%s%s|r", dpsNeeds == 3 and red or green, "D"),
            format("|cff%s%s|r", dpsNeeds >= 2 and red or green, "D"),
            format("|cff%s%s|r", dpsNeeds >= 1 and red or green, "D"),
            (myWait ~= -1 and SecondsToTime(myWait, false, false, 1) or "|cffD7BEA5Unknown|r")
        )
    )
end)

lfg:SetScript("OnMouseDown", function(self, button)
    local mode = GetLFGMode()
    if button == "LeftButton" then
        if mode == "listed" then
            ToggleLFRParentFrame()
        else
            ToggleLFDParentFrame()
        end
    elseif button == "RightButton" then
        if mode == "proposal" then
            if not LFDDungeonReadyPopup:IsShown() then
                StaticPopupSpecial_Show(LFDDungeonReadyPopup)
                return
            end
        end

        MiniMapLFGFrameDropDown.point = "BOTTOM"
        MiniMapLFGFrameDropDown.relativePoint = "TOP"
        ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, lfg, 0, 0)
    end
end)
