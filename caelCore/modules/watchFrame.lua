--[[    $Id$    ]]

local dummy = caelLib.dummy

local nextline = 1

WatchFrame:ClearAllPoints()
WatchFrame:SetHeight(caelLib.scale(600))
WatchFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", caelLib.scale(-15), caelLib.scale(-15))
--WatchFrameCollapseExpandButton:Hide()

WatchFrame.ClearAllPoints = dummy
WatchFrame.SetPoint = dummy
--WatchFrameCollapseExpandButton.Show = dummy

WatchFrameTitle:SetFont(caelMedia.fonts.NORMAL, 11)

hooksecurefunc("WatchFrame_Update", function()
    for i = nextline, 50 do
        line = _G["WatchFrameLine"..i]
        if line then
            line.text:SetFont(caelMedia.fonts.NORMAL, 9)
            line.dash:SetFont(caelMedia.fonts.NORMAL, 9)
            line.text:SetSpacing(2)
        else
            nextline = i
            break
        end
    end
end)

local ZoneChange = function(zone)
    local _, instanceType = IsInInstance()
    if instanceType == "arena" or UnitExists("boss1") then
        if not WatchFrame.collapsed then
            WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
        end
    elseif WatchFrame.collapsed then
        WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
    end
end

WatchFrame:RegisterEvent("WORLD_MAP_UPDATE")
WatchFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
WatchFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
WatchFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
WatchFrame:HookScript("OnEvent", function(self, event)
    local zone = GetRealZoneText()
    if zone and zone ~= "" then
        return ZoneChange(zone)
    end
end)
