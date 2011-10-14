local gsub, find, match, lower = string.gsub, string.find, string.match, string.lower

--[[    Filter npc spam    ]]

local npcChannels = {
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_EMOTE",
}

local isNpcChat = function(self, event, ...)
    local msg = ...
    local isResting = IsResting()
    if isResting and not msg:find(caelUI.config.player.name) then
        return true, ...
    end
    return false, ...
end

for i,v in ipairs(npcChannels) do
    ChatFrame_AddMessageEventFilter(v, isNpcChat)
end

--[[    Filter bossmods    ]]

local filteredchannels = {
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_WHISPER",
}

local IsSpam = function(self, event, ...)
    local msg = ...
    if msg:find("%*%*%*") or msg:find("%<%D%B%M%>") or msg:find("%<%B%W%>") then
        return true, ...
    end
    return false, ...
end

for i, v in ipairs(filteredchannels) do
    ChatFrame_AddMessageEventFilter(v, IsSpam)
end

RaidWarningFrame:SetScript("OnEvent", function(self, event, msg)
    if event == "CHAT_MSG_RAID_WARNING" then
        if not msg:find("%*%*%*", 1, false) then
            RaidWarningFrame_OnEvent(self, event, msg)
        end 
    end
end)

--[    Filter channels join/leave    ]

local eventsNotice = {
    "CHAT_MSG_CHANNEL_JOIN",
    "CHAT_MSG_CHANNEL_LEAVE",
    "CHAT_MSG_CHANNEL_NOTICE",
    "CHAT_MSG_CHANNEL_NOTICE_USER",
}

local SuppressNotices = function()
    return true
end

for i,v in ipairs(eventsNotice) do
    ChatFrame_AddMessageEventFilter(v, SuppressNotices)
end

--[[  Filter various spam    ]]

--[=[
local Spam = {
    [1] = "Le Cataclysme est sur nous!",
    [2] = "Si vous cherchez des informations relatives aux questions et problèmes",
    [3] = "les plus répandus, veuillez consulter la base de connaissance en ligne.",
    [4] = "Pour y accéder, il vous suffit d'appuyer en jeu sur le point d'interrogation ",
    [5] = "rouge .+ situé à gauche de vos sacs dans la barre de menu.",
    [6] = "You have .+ the title '.atron Caellian'%.",
    [7] = "^(%S+) has come online%.",
    [8] = "^(%S+) has gone offline%.",
    [9] = "You have unlearned",
    [10] = "You have learned a new spell:",
    [11] = "You have learned a new ability:",
    [12] = "Your pet has unlearned",
    [13] = "You have gained the maximum amount of guild reputation allowed this week.",
}

local SystemMessageFilter = function(self, event, ...)
    local msg = ...
    for _, pattern in pairs(Spam) do
        if msg:find(pattern) then
            return true, ...
        end
    end

    return false, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemMessageFilter)
--]=]
--[[    RaidNotice to Scrolling frame    ]]

local hooks = {}
hooks["RaidNotice_AddMessage"] = RaidNotice_AddMessage

RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo, ...)
    if noticeFrame then
        if MikScrollingBattleText then
            MikSBT.DisplayMessage(textString, MikSBT.DISPLAYTYPE_NOTIFICATION, true, 140, 145, 155, 16, "neuropol x cd bd", 2)
        elseif recScrollAreas then
            recScrollAreas:AddText("|cffD7BEA5"..textString.."|r", true, "Notification")
        else
            hooks.RaidNotice_AddMessage(noticeFrame, textString, colorInfo, ...)
        end
        PlaySoundFile(caelUI.media.files.soundAlarm)
    end
end

--[=[
--[[    Bosses & monsters emotes to RWF    ]]

chatFrames:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
chatFrames.CHAT_MSG_RAID_BOSS_EMOTE = function(self, event, arg1, arg2)
    local string = format(arg1, arg2)
    RaidNotice_AddMessage(RaidWarningFrame, string, ChatTypeInfo["RAID_WARNING"])
end

--[[    Filter various crap         ]]

local craps = {
    "%[.*%].*anal",
    "anal.*%[.*%]",
}

local FilterFunc = function(_, _, msg, userID, _, _, _, _, chanID)
    if userID == UnitName("Player") then return false end

    if chanID == 1 or chanID == 2 then
        msg = lower(msg) --lower all text
        msg = gsub(msg, " ", "") --Remove spaces

        for i, v in ipairs(craps) do
            if find(msg, v) then
                return true
            end
        end
    end

    return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FilterFunc)
--]=]

--[[    Reformat money messages     ]]

do
    local gold      = " " .. select(2, strsplit(" ", GOLD_AMOUNT))
    local silver    = " " .. select(2, strsplit(" ", SILVER_AMOUNT))
    local copper    = " " .. select(2, strsplit(" ", COPPER_AMOUNT))

    local function moneyFilter(self, event, msg, ...)
        local newMsg = msg
        newMsg = gsub(newMsg, " deposited to guild bank", "")
        newMsg = gsub(newMsg, " of the loot", "")
        newMsg = gsub(newMsg, gold, "|cffffd700g|r")
        newMsg = gsub(newMsg, silver, "|cffc7c7cfs|r")
        newMsg = gsub(newMsg, copper, "|cffeda55fc|r")
        return false, newMsg, ...
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", moneyFilter)
end
