local private = unpack(select(2, ...))

local IS_GUILD_GROUP = false

-- This will manage setting our boolean flag above to be true when the group changes to a guild group.
private.events:RegisterEvent("GUILD_PARTY_STATE_UPDATED", function(self, event, isGuildGroup)
    if (isGuildGroup ~= IS_GUILD_GROUP) then
        IS_GUILD_GROUP = isGuildGroup
    end
end)


-- This will return our guild group boolean flag check.
function private.is_guild_group ()
    return IS_GUILD_GROUP
end
