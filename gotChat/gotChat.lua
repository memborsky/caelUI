-- At some point in the past, this was idChat.

local kill = caelLib.kill

-- Stuff you can change without things blowing up.
local SCROLLDOWNDELAY = 20    -- Time in seconds before the chatframe auto-scrolls down.

-- That is all.

local hooks = {}

local frame = CreateFrame("Frame")

local function GetPlayerAndRealm(unit)
    local name, realm = UnitName(unit)
    if realm and realm ~= "" then
        name = name.."-"..realm
    end
    return name
end

-- Change the format strings where possible. 
CHAT_WHISPER_GET = "From %s:\32"
CHAT_WHISPER_INFORM_GET = "To %s:\32"
CHAT_BN_WHISPER_GET = "From %s:\32"
CHAT_BN_WHISPER_INFORM_GET = "To %s:\32"
CHAT_BN_WHISPER_SEND = "Tell %s:\32"
CHAT_PARTY_GET = "|Hchannel:Party|hP.|h %s:\32"
CHAT_MONSTER_PARTY_GET = "|Hchannel:Party|hP.|h %s: "
CHAT_PARTY_GUIDE_GET = "|Hchannel:Party|hPL.|h %s: "
CHAT_PARTY_LEADER_GET = "|Hchannel:Party|hPL.|h %s: "
CHAT_CHANNEL_LEAVE_GET = "%s left channel."
CHAT_MONSTER_SAY_GET = "%s: "
CHAT_CHANNEL_JOIN_GET = "%s joined channel."
CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|hBL.|h %s: "
CHAT_RAID_GET = "|Hchannel:raid|hR.|h %s: "
CHAT_YELL_GET = "%s: "
CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|hBG.|h %s: "
CHAT_GUILD_GET = "|Hchannel:Guild|hG.|h %s: "
CHAT_SAY_GET = "%s: "
CHAT_RAID_WARNING_GET = "RW. %s: "
CHAT_RAID_LEADER_GET = "|Hchannel:raid|hRL.|h %s: "
CHAT_OFFICER_GET = "|Hchannel:o|hO.|h %s: "
CHAT_MONSTER_YELL_GET = "%s: "
CHAT_MONSTER_WHISPER_GET = "From %s: "
CHAT_CHANNEL_LIST_GET = "|Hchannel:%d|h%s|h:\32"
CHAT_YOU_CHANGED_NOTICE = "Changed Channel: |Hchannel:%d|h%s|h"
CHAT_YOU_JOINED_NOTICE = "Joined Channel: |Hchannel:%d|h%s|h"
CHAT_YOU_LEFT_NOTICE = "Left Channel: |Hchannel:%d|h%s|h"
CHAT_SUSPENDED_NOTICE = "Left Channel: |Hchannel:%d|h%s|h ";

local function AlwaysFilter()
    return true
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", AlwaysFilter)

ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", AlwaysFilter)

-- Things we can't do with the filters.

-- Custom channel replacements.
-- Format: ["pattern"] = "Replacement"
local CustomChannelNames = {
    ["Trade"] = "Tr.",
    ["[wW]e[dD]id[hH]eal"] = "heal.",
    ["[wW]e[dD]id[tT]ank"] = "tank.",
    ["[wW]e[dD]id[cC]a[cC]"] = "cac.",
    ["[wW]e[dD]id[hH]unter"] = "hunt."
}

local function FormatChannel(t, channelstring)
    local channelname = channelstring:match("|h%[(.-)%]|h")
    if channelname:find("^%d") then
        channelname = channelname:sub(4)
    end
    local dashpos = channelname:find(" %-")
    if dashpos then
        channelname = channelname:sub(1, dashpos-1)
    end

    local newname
    if type(CustomChannelNames) == "table" then
        for pattern, replace in pairs(CustomChannelNames) do
            if channelname:find(pattern) then
                newname = replace
                break
            end
        end
    end
    if not newname then
        newname = channelname:gsub("%U", "")
        if newname and #newname > 1 then
            newname = newname
        else
            newname = channelname:sub(1,3)
        end
        newname = newname:lower():gsub(".", string.upper, 1).."."
    end

    local newstring = channelstring:gsub("|h%[.-%]|h", "|h"..newname.."|h")
    t[channelstring] = newstring
    return newstring
end

ChannelNameCache = setmetatable({}, {__index = FormatChannel})

local function AddMessage(frame, text, red, green, blue, id)
    if text then
        text = text:gsub("|Hplayer(.-)|h%[(.-)%]|h", "|Hplayer%1|h%2|h")
        text = text:gsub("^(|Hchannel:[^|]-|h%[.-%]|h)", ChannelNameCache)
        text = text:gsub("(|Hplayer.-|h) has earned the achievement (.-)!", "%1 has earned %2")
        text = string.format("|HChatCopy|h%s%s|r|h %s", "|cff999999", date("%H:%M"), text)
    end
    return hooks[frame](frame, text, red, green, blue, id)
end

-- Auto scroll to bottom after SCROLLDOWNDELAY seconds of no activity.
local AutoScrollQueue = {}
local function AutoScrollOnUpdate(self, elapsed)
    if next(AutoScrollQueue) then
        for cf, _ in pairs(AutoScrollQueue) do
            if cf.delay then
                cf.delay = cf.delay - elapsed
                if cf.delay <= 0 then
                    cf:ScrollToBottom()
                    AutoScrollQueue[cf] = nil
                    cf.delay = nil
                end
            else
                AutoScrollQueue[cf] = nil
            end
        end
    else
        self:SetScript("OnUpdate", nil)
    end
end

function FloatingChatFrame_OnMouseScroll(self, delta)
    if delta > 0 then
        if IsShiftKeyDown() then
            self:ScrollToTop()
        else
            self:ScrollUp()
        end
        AutoScrollQueue[self] = true
        self.delay = SCROLLDOWNDELAY
        frame:SetScript("OnUpdate", AutoScrollOnUpdate)
    elseif delta < 0 then
        if IsShiftKeyDown() then
            self:ScrollToBottom()
        else
            self:ScrollDown()
            AutoScrollQueue[self] = true
            self.delay = SCROLLDOWNDELAY
            frame:SetScript("OnUpdate", AutoScrollOnUpdate)
        end
    end
end

-- Hide the last remaining button.
kill(ChatFrameMenuButton)

-- Stickies! You know, those things we haven't got on the EU Interface forums.
do
    local stickys = {"SAY", "EMOTE", "YELL", "PARTY", "GUILD", "OFFICER", "RAID", "RAID_WARNING", 'BATTLEGROUND', "WHISPER", "CHANNEL"}
    for _, chanType in ipairs(stickys) do
        ChatTypeInfo[chanType].sticky = 1
    end
end

--[[
ChatTypeInfo.SAY.sticky = 1
ChatTypeInfo.EMOTE.sticky = 0
ChatTypeInfo.YELL.sticky = 0
ChatTypeInfo.PARTY.sticky = 1
ChatTypeInfo.GUILD.sticky = 1
ChatTypeInfo.OFFICER.sticky = 1
ChatTypeInfo.RAID.sticky = 1
ChatTypeInfo.RAID_WARNING.sticky = 0
ChatTypeInfo.BATTLEGROUND.sticky = 1
ChatTypeInfo.WHISPER.sticky = 1
ChatTypeInfo.CHANNEL.sticky = 1
--]]

-- Chat Copy and AltClickInvite.
local function AltClickInvite(link)
    if IsAltKeyDown() then
        local type, player = (":"):split(link)
        if type == "player" and player then
            InviteUnit(player)
            return true
        end
    end
end

-- Credits to haste for his oChat chatcopy code: github.com/haste
local MouseIsOver = function(frame)
    local s = frame:GetParent():GetEffectiveScale()
    local x, y = GetCursorPosition()
    x = x / s
    y = y / s

    local left = frame:GetLeft()
    local right = frame:GetRight()
    local top = frame:GetTop()
    local bottom = frame:GetBottom()

    -- Hack to fix a symptom not the real issue
    if(not left) then
        return
    end

    if((x > left and x < right) and (y > bottom and y < top)) then
        return 1
    else
        return
    end
end

local function GetCFRegionUnderMouse(cf)
    local regions = {cf:GetRegions()}
    local output, region
    for i=1, #regions do
        region = regions[i]
        if region:IsObjectType("FontString") and MouseIsOver(region) then    
            output = region:GetText()
            break
        end
    end

    regions = nil
    return output
end

local CustomSetItemRef = function(link, text, button, ...)
    SetItemRefCount = SetItemRefCount + 1

end

local function OnHyperlinkClickHook(self, link, text, button)
    if link:sub(1,8) == "ChatCopy" then
        local text = GetCFRegionUnderMouse(self)
        if text then
            text = text:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
            text = text:gsub("|H.-|h(.-)|h", "%1")

            caelChat.GetChatFrameEditBox():Insert(text)
            caelChat.GetChatFrameEditBox():Show()
            caelChat.GetChatFrameEditBox():HighlightText()
            caelChat.GetChatFrameEditBox():SetFocus()
        end
        return
    elseif link:sub(1,6) == "player" and button == "LeftButton" and AltClickInvite(link) then
        return
    end

    SetItemRef(link, text, button)
end

-- Skip the combat log!
local blacklist = {
    [ChatFrame2] = true,
}

for i=1,7 do
    local frame = _G[format("ChatFrame%s", i)]
    frame:EnableMouseWheel(true)

    kill(_G[format("ChatFrame%sUpButton", i)])
    kill(_G[format("ChatFrame%sDownButton", i)])
    kill(_G[format("ChatFrame%sBottomButton", i)])

    if not blacklist[frame] then
        frame:SetScript("OnHyperlinkClick", OnHyperlinkClickHook)
        hooks[frame] = frame.AddMessage
        frame.AddMessage = AddMessage
    end
end
