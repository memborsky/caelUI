--[[    Some new slash commands    ]]

local playerName = caelUI.config.player.name

SlashCmdList["FRAMENAME"] = function() print(GetMouseFocus():GetName()) end
SlashCmdList["PARENT"] = function() print(GetMouseFocus():GetParent():GetName()) end
SlashCmdList["MASTER"] = function() ToggleHelpFrame() end
SlashCmdList["RELOAD"] = function() ReloadUI() end
SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) end
SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) end
SlashCmdList["CLFIX"] = function() CombatLogClearEntries() end
SlashCmdList["READYCHECK"] = function() DoReadyCheck() end
SlashCmdList["GROUPDISBAND"] = function()
    if UnitInRaid("player") then
        SendChatMessage("Disbanding raid.", "RAID")
        for i = 1, GetNumRaidMembers() do
            local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if online and name ~= playerName then
                UninviteUnit(name)
            end
        end
    else
        SendChatMessage("Disbanding group.", "PARTY")
        for i = MAX_PARTY_MEMBERS, 1, -1 do
            if GetPartyMember(i) then
                UninviteUnit(UnitName("party"..i))
            end
        end
    end
    LeaveParty()
end
SlashCmdList["RAIDASSIST"] = function (message, editbox)
    if UnitInRaid("player") then
        local showOffline = GetGuildRosterShowOffline() -- Used to set this setting back to what it was before we change it.
        local guildRaider = {}

        -- Used so we can limit how many people we need to check against in the guild roster
        if showOffline then
            SetGuildRosterShowOffline(false)
        end

        -- Fire up the guild roster pull just in case
        GuildRoster()

        do
            local _, numOnline = GetNumGuildMembers()

            for index = 1, numOnline do
                name, _, rankID = GetGuildRosterInfo(index)

                if rankID <= 2 then
                    guildRaider[name] = true
                else
                    guildRaider[name] = false
                end
            end
        end

        for index = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(index)

            if name ~= playerName and guildRaider[name] then
                PromoteToAssistant(name, true)
                if (message == "true" or caelLib.isGuildGroup()) then
                    SendChatMessage("Promoted " .. name .. " to Raid Assistant.", "OFFICER", "COMMON")
                end
            end
        end

        -- Reset to what showOffline before we entered into this function.
        if not showOffline then
            SetGuildRosterShowOffline(showOffline)
        end
    end
end

SLASH_FRAMENAME1 = "/frame"
SLASH_PARENT1 = "/parent"
SLASH_MASTER1 = "/gm"
SLASH_RELOAD1 = "/rl"
SLASH_ENABLE_ADDON1 = "/en"
SLASH_DISABLE_ADDON1 = "/dis"
SLASH_CLFIX1 = "/clfix"
SLASH_READYCHECK1 = "/rc"
SLASH_GROUPDISBAND1 = "/radisband"
SLASH_RAIDASSIST1 = "/raassist"
