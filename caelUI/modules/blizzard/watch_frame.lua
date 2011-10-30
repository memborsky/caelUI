local private = unpack(select(2, ...))

do
    local pixel_scale = private.database.get("config").pixel_scale

    -- Initialize the WatchFrame
    WatchFrame:ClearAllPoints()
    WatchFrame:SetHeight(pixel_scale(600))
    WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", pixel_scale(-15), pixel_scale(-15))

    WatchFrame.ClearAllPoints = function () end
    WatchFrame.SetPoint = function () end

    -- Change the font for the watch frame.
    do
        --- This is a carry over from above that needs the usage of the media table.
        local media = private.database.get("media")
        WatchFrameTitle:SetFont(media.fonts.normal, 11)


        local nextline = 1

        hooksecurefunc("WatchFrame_Update", function()
            for index = nextline, 50 do
                line = _G["WatchFrameLine" .. index]

                if line then
                    line.text:SetFont(media.fonts.normal, 9)
                    line.dash:SetFont(media.fonts.normal, 9)
                    line.text:SetSpacing(2)
                else
                    nextline = index
                    break
                end
            end
        end)
    end
end

--- Automatically collapse/expand the WatchFrame when in an arena match or during a boss fight.
for _, event in next, {"WORLD_MAP_UPDATE", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"} do
    private.events:RegisterEvent(event, function()
        local zone = GetRealZoneText()

        if zone and zone ~= "" then
            local _, instanceType = IsInInstance()

            if instanceType == "arena" or UnitExists("boss1") then
                if not WatchFrame.collapsed then
                    WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
                end
            elseif WatchFrame.collapsed then
                WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
            end
        end
    end)
end