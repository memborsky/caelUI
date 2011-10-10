--[[    $Id$    ]]

local _, caelDataFeeds = ...

local social = caelDataFeeds.createModule("Social")

local pixelScale = caelUI.pixelScale

social.text:SetPoint("CENTER", caelPanel_DataFeed, "CENTER", pixelScale(325), 0)

social:RegisterEvent"CHAT_MSG_SYSTEM"
social:RegisterEvent"FRIENDLIST_UPDATE"
social:RegisterEvent"GUILD_ROSTER_UPDATE"
social:RegisterEvent"PLAYER_ENTERING_WORLD"
social:RegisterEvent"BN_SELF_ONLINE"
social:RegisterEvent"BN_FRIEND_ACCOUNT_ONLINE"
social:RegisterEvent"BN_FRIEND_ACCOUNT_OFFLINE"
social:RegisterEvent"BN_CONNECTED"
social:RegisterEvent"BN_DISCONNECTED"

local numGuildMembers = 0
local numOnlineGuildMembers = 0

local numFriends = 0
local numOnlineFriends = 0

local numBN = 0
local numOnlineBN = 0

local delay = 0
social:SetScript("OnUpdate", function(self, elapsed)
    delay = delay - elapsed
    if delay < 0 then
        if IsInGuild("player") then
            GuildRoster()
        end
        delay = 15
    end
end)

local CURRENT_GUILD_SORTING

hooksecurefunc("SortGuildRoster", function(type) CURRENT_GUILD_SORTING = type end)

social:SetScript("OnEnter", function(self)
    numGuildMembers = GetNumGuildMembers()
    numFriends = GetNumFriends() 
    numBNFriends = BNGetNumFriends()

    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, pixelScale(4))

    if numOnlineGuildMembers > 0 then

        if CURRENT_GUILD_SORTING ~= "class" then
            SortGuildRoster("class")
        end

        GameTooltip:AddLine("Online Guild Members", 0.84, 0.75, 0.65)
        GameTooltip:AddLine(" ")

        for i = 1, numGuildMembers do
            local name, _, _, level, _, zone, _, _, isOnline, status, classFileName = GetGuildRosterInfo(i)
            local color = RAID_CLASS_COLORS[classFileName]

            if isOnline and name ~= caelLib.playerName then
                GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..name.." "..status, zone, color.r, color.g, color.b, 0.65, 0.63, 0.35)
            end
        end

        if numOnlineFriends > 0 or (numOnlineBN > 0 and numOnlineFriends == 0) then
            GameTooltip:AddLine(" ")
        end
    end

    if numOnlineFriends > 0 then
        GameTooltip:AddLine("Online Friends", 0.84, 0.75, 0.65)
        GameTooltip:AddLine(" ")
        for i = 1, numFriends do
            local name, level, class, zone, isOnline, status = GetFriendInfo(i)

            if not isOnline then break end

            for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
                if class == v then
                    class = k
                end
            end

            if caelLib.Locale ~= "enUS" then -- female class localization
                for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
                    if class == v then
                        class = k
                    end
                end
            end

            local color = RAID_CLASS_COLORS[class]
            if isOnline then
                GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..name.." "..status, zone, color.r, color.g, color.b, 0.65, 0.63, 0.35)
            end
        end


        if numBNFriends > 0 then
            GameTooltip:AddLine(" ")
        end
    end

    if numOnlineBN > 0 then
        GameTooltip:AddLine("Online BN Friends", 0.84, 0.75, 0.65)
        GameTooltip:AddLine(" ")
        for i = 1, numBNFriends do
            local presenceID = BNGetFriendInfo(i)
            local _, givenName, surName, toonName, toonID, client, isOnline, _, isAFK, isDND, messageText = BNGetFriendInfoByID(presenceID)

            if (client == "WoW") then
                local hasFocus, _, _, realmName, faction, _, race, class, guild, zoneName, level, gameText = BNGetFriendToonInfo(i, 1)

                if not isOnline then break end

                for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
                    if class == v then
                        class = k
                    end
                end

                if caelLib.Locale ~= "enUS" then
                    for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
                        if class == v then
                            class = k
                        end
                    end
                end

                local color = RAID_CLASS_COLORS[class]
                if isOnline then
                    --                    GameTooltip:AddDoubleLine(givenName.." "..surName, client, 0, 1, 1, 0.65, 0.63, 0.35)
                    if color then
                        GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..toonName, zoneName ~= "" and zoneName or "Unknown", color.r, color.g, color.b, 0.65, 0.63, 0.35)
                    else
                        GameTooltip:AddDoubleLine("|cffD7BEA5"..level.." |r"..toonName, zoneName ~= "" and zoneName or "Unknown", 0.55, 0.57, 0.61, 0.65, 0.63, 0.35)
                    end
                end
            elseif (client == "S2") then
                local _, _, _, _, _, _, _, _, _, _, gameText = BNGetFriendToonInfo(i, 1)
                if isOnline then
                    GameTooltip:AddDoubleLine("|cffD7BEA5SC2|r "..toonName, gameText, 0.55, 0.57, 0.61, 0.65, 0.63, 0.35)
                end
                --            else
                --                if isOnline then
                --                    GameTooltip:AddDoubleLine(givenName.." "..surName, client, 0.55, 0.57, 0.61, 0.65, 0.63, 0.35)
                --                end
            end
        end
    end

    GameTooltip:Show()
end)

social:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        ToggleFriendsFrame(1)
    elseif button == "RightButton" then
        if not IsAddOnLoaded("Blizzard_GuildUI") then
            LoadAddOn("Blizzard_GuildUI")
        end

        --        GuildRoster_SetView("playerStatus")
        --        UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, "playerStatus") -- Currently not performed in _SetView
        ToggleFrame(GuildFrame)
    end
end)

social:SetScript("OnEvent", function(self, event, ...)
    local msg = ...
    local text, logInOutMsg

    if event == "CHAT_MSG_SYSTEM" and msg and (msg:match("^(%S+) has come online%.") or msg:match("^(%S+) has gone offline%.")) then
        logInOutMsg = true
    end

    if event == "GUILD_ROSTER_UPDATE" or logInOutMsg then
        if IsInGuild("player") then
            numGuildMembers = GetNumGuildMembers()
            numOnlineGuildMembers = 0
            for i = 1, numGuildMembers do
                local isOnline = select(9, GetGuildRosterInfo(i))
                if isOnline then
                    numOnlineGuildMembers = numOnlineGuildMembers + 1
                end
            end
            numOnlineGuildMembers = numOnlineGuildMembers - 1
        end
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "FRIENDLIST_UPDATE" or logInOutMsg then
        numFriends = GetNumFriends()
        numOnlineFriends = 0

        if numFriends > 0 then
            for i = 1, numFriends do
                local friendIsOnline = select(5, GetFriendInfo(i))
                if friendIsOnline then
                    numOnlineFriends = numOnlineFriends + 1
                end
            end
        end
    end

    if event == "PLAYER_ENTERING_WORLD" or string.find(event, "BN_") then
        numBN = BNGetNumFriends()
        numOnlineBN = 0

        if numBN > 0 then
            for i = 1, numBN do
                local BNFriendIsOnline = select(7, BNGetFriendInfo(i))
                if BNFriendIsOnline then
                    numOnlineBN = numOnlineBN + 1
                end
            end
        end
    end

    if numOnlineGuildMembers > 0 then
        text = string.format("%s %d", (numOnlineFriends > 0 or numOnlineBN > 0) and "|cffD7BEA5g|r" or "|cffD7BEA5guild|r", numOnlineGuildMembers)
    end

    if numOnlineFriends > 0 then
        text = string.format("%s %s %d", (numOnlineGuildMembers > 0) and text or "", (numOnlineGuildMembers > 0 and "- |cffD7BEA5f|r" or numOnlineBN > 0 and "|cffD7BEA5f|r") or (numOnlineFriends > 1 and "|cffD7BEA5friends|r" or "|cffD7BEA5friend|r"), numOnlineFriends)
    end

    if numOnlineBN > 0 then
        text = string.format("%s %s %d", (numOnlineFriends > 0 or numOnlineGuildMembers > 0) and text or "", (numOnlineFriends > 0 or numOnlineGuildMembers > 0) and "- |cffD7BEA5bn|r" or "|cffD7BEA5realid|r", numOnlineBN)
    end

    if numOnlineGuildMembers == 0 and numOnlineFriends == 0 and numOnlineBN == 0 then
        text = ""
    end

    self.text:SetText(text)
end)
