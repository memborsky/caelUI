local Watch = unpack(select(2, ...)).CreateModule("WatchFrame")

do
    local PixelScale = Watch.PixelScale

    -- Initialize the WatchFrame
    WatchFrame:ClearAllPoints()
    WatchFrame:SetHeight(PixelScale(600))
    WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", PixelScale(-15), PixelScale(-15))

    WatchFrame.ClearAllPoints = function () end
    WatchFrame.SetPoint = function () end

    -- Change the font for the watch frame.
    do
        --- This is a carry over from above that needs the usage of the media table.
        local normal_font = Watch:GetMedia()["fonts"]["normal"]
        WatchFrameTitle:SetFont(normal_font, 12)

        local nextline = 1

        hooksecurefunc("WatchFrame_Update", function()
            for index = nextline, 50 do
                line = _G["WatchFrameLine" .. index]

                if line then
                    line.text:SetFont(normal_font, 10)
                    line.dash:SetFont(normal_font, 10)
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
    Watch:RegisterEvent(event, function()
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
