local _, caelLib = ...
_G["caelLib"] = caelLib

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
    if type(self[event]) == "function" then
        return self[event](self, event, ...)
    end
end)

caelLib.zoneName = GetRealZoneText()

-------------------------------------
-- Check if we are in a guild group
-------------------------------------
local IS_GUILD_GROUP = false

caelLib.isGuildGroup = function()
    return IS_GUILD_GROUP
end

EventFrame.GUILD_PARTY_STATE_UPDATED = function(self, event, ...)
    local isGuildGroup = ...
    if (isGuildGroup ~= IS_GUILD_GROUP) then
        IS_GUILD_GROUP = isGuildGroup
    end
end
EventFrame:RegisterEvent("GUILD_PARTY_STATE_UPDATED")

------------------------------
-- Update our zone variable --
------------------------------
EventFrame.ZONE_CHANGED_NEW_AREA = function(self, event, ...)
    if (caelLib.zoneName ~= GetRealZoneText()) then
        caelLib.zoneName = GetRealZoneText()
    end
end
EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

EventFrame.PLAYER_ENTERING_WORLD = function(self, event, ...)
    if (caelLib.zoneName ~= GetRealZoneText()) then
        caelLib.zoneName = GetRealZoneText()
    end
end
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

caelLib.kill = function(object)
    local objectReference = object
    if type(object) == "string" then
        objectReference = _G[object]
    else
        objectReference = object
    end
    if not objectReference then return end
    if type(objectReference) == "frame" then
        objectReference:UnregisterAllEvents()
    end
    objectReference:Hide()
    objectReference.Show = objectReference.Hide
end
