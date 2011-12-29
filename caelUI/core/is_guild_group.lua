local private = unpack(select(2, ...))

local IS_GUILD_GROUP = false

-- This will manage setting our boolean flag above to be true when the group changes to a guild group.
do
    local frame = CreateFrame("Frame")

    frame:RegisterEvent("GUILD_PARY_STATE_UPDATED")

    frame:SetScript("OnEvent", function(_, _, isGuildGroup)
        if (isGuildGroup ~= IS_GUILD_GROUP) then
            IS_GUILD_GROUP = isGuildGroup
        end
    end)
end


-- This will return our guild group boolean flag check.
function private.IsGuildGroup ()
    return IS_GUILD_GROUP
end
