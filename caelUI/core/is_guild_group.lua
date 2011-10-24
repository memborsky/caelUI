local private = unpack(select(2, ...))

local IS_GUILD_GROUP

local event_frame = CreateFrame("Frame")

event_frame:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
event_frame:SetScript("OnEvent", function(self, event)
    local isGuildGroup = ...
    if (isGuildGroup ~= IS_GUILD_GROUP) then
        IS_GUILD_GROUP = isGuildGroup
    end
)

function private.is_guild_group ()
    return IS_GUILD_GROUP
end