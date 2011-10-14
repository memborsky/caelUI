local _, caelCore = ...

--[[    Auto accept some invites    ]]

local autoinvite = caelCore.createModule("AutoInvite")

local media = caelUI.get_database("media")

local AcceptFriends = false
local AcceptGuild = true

local INVITE_WORD = "invite"

local Blacklisted = {
    ["Kreinium"]    = true,
    ["Nikoh"]       = true,
}

local Whitelisted = {
    ["Scyanne"]     = true, -- Sephi

    ["Sayori"]      = true, -- Say
    ["Sariyah"]     = true, -- Say

    ["Maikar"]      = true,

    ["Elthor"]      = true,
}

local function IsFriend(name)
    if Blacklisted[name] then
        return false
    end

    if Whitelisted[name] then
        return true
    end

    if isChatListB then
        return true
    end

    if AcceptFriends then
        for i = 1, GetNumFriends() do
            if GetFriendInfo(i) == name then
                return true
            end
        end
    end

    if IsInGuild() and AcceptGuild then
        for i = 1, GetNumGuildMembers() do
            if GetGuildRosterInfo(i) == name then
                return true
            end
        end
    end

    return false
end

local function CanInvite()
    if IsRaidLeader() or IsRaidOfficer() or IsPartyLeader() or not UnitExists("party1") then
        return true
    end

    return false
end

autoinvite:RegisterEvent("PARTY_INVITE_REQUEST")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:SetScript("OnEvent", function(self, event, ...)
    if event == "PARTY_INVITE_REQUEST" then
        name = ...
        if IsFriend(name) then
            for i = 1, STATICPOPUP_NUMDIALOGS do
                local frame = _G["StaticPopup"..i]
                if frame:IsVisible() and frame.which == "PARTY_INVITE" then
                    StaticPopup_OnClick(frame, 1)
                end
            end
        else
            SendWho(string.join("", "n-\"", name, "\""))
        end
    elseif event == "CHAT_MSG_WHISPER" then
        PlaySoundFile(media.files.soundWhisper)

        arg1, arg2 = ...

        if IsFriend(arg2) then
            if CanInvite() then
                if arg1:len() == INVITE_WORD:len() and arg1:lower() == INVITE_WORD:lower() then
                    InviteUnit(arg2)
                end
            end

            if arg1:lower() == "promote" then
                if IsPartyLeader() then
                    PromoteToLeader(arg2)
                elseif IsRaidLeader() then
                    PromoteToAssistant(arg2)
                end
            elseif (arg1:lower() == "assistant" or arg1:lower() == "assist") and IsRaidLeader() then
                PromoteToAssistant(arg2)
            end
        end
    end
end)

StaticPopupDialogs["LOOT_BIND"].OnCancel = function(self, slot)
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        ConfirmLootSlot(slot)
    end
end
