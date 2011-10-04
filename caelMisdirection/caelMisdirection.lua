--[[    $Id$    ]]

if caelLib.playerClass ~= "HUNTER" then
    print("|cffD7BEA5cael|rMisdirection: You are not a Hunter, caelMisdirection will be disabled on next UI reload.")
    return DisableAddOn("caelMisdirection")
end

local _, caelMisdirection = ...

caelMisdirection.eventFrame = CreateFrame("Frame", nil, UIParent)

local locale = caelLib.locale

local msgInfo = locale == "frFR" and " d'aggro transférée à " or " threat transferred to "
local msgChat = locale == "frFR" and "détourné " or "misdirected "
local msgWhisper =  locale == "frFR" and "Détourné" or "Misdirected"
local msgChannel = locale == "frFR" and "Détournement sur " or "Misdirection on "

local textColor = {r = 0.84, g = 0.75, b = 0.65}

local MisdThreat = 0
local MisdIsUp = false
local find = string.find
local amount, MDTarget

local index = GetChannelName("WeDidHunter")

caelMisdirection.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
caelMisdirection.eventFrame:SetScript("OnEvent", function(_, _, _, subEvent, _, _, sourceName, _, _, _, destName, _, _, spellId, _, _, amount, ...)

    if sourceName and sourceName == caelLib.playerName then
        if UnitIsPlayer(destName) and not UnitIsUnit(destName, "pet") then
            if subEvent == "SPELL_CAST_SUCCESS" then
                if  spellId == 34477 then
                    SendChatMessage((msgWhisper), "WHISPER", GetDefaultLanguage("player"), destName)
                    RaidNotice_AddMessage(RaidWarningFrame, msgChannel..destName, textColor)

                    if index ~= nil then 
                        SendChatMessage((msgChat..destName) , "CHANNEL", nil, index)
                    end

                    MDTarget = destName
                    MisdIsUp = true
                end
            end
        end

        if ((find(subEvent, "DAMAGE") and not (find(subEvent, "MISS")) or find(subEvent, "HEAL")) and MisdIsUp == true) then
            MisdThreat = MisdThreat + (amount and amount or 0)
        end

        if index ~= nil and MDTarget then
            if subEvent == "SPELL_AURA_REMOVED" then
                if spellId == 35079 then
                    SendChatMessage((MisdThreat..msgInfo..MDTarget) , "CHANNEL", nil, index)

                    MisdIsUp = false
                    MisdThreat = 0
                end
            end
        end
    end
end)
