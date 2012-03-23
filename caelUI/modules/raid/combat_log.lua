local RaidLogger = unpack(select(2, ...)).GetModule("RaidLogger")

RaidLogger:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
    local _, instance = IsInInstance();

    if instance == "raid" then
        local name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo();

        -- if maxPlayers == 10 then
            LoggingCombat(1);
            RaidLogger.active = true;
            DEFAULT_CHAT_FRAME:AddMessage("Starting to log combat.");
        -- end
    else
        if RaidLogger.active then
            LoggingCombat(0);
            DEFAULT_CHAT_FRAME:AddMessage("No longer logging combat.");
            RaidLogger.active = nil;
        end
    end
end)