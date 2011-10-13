--[[    $Id$    ]]

local _, caelLib = ...
_G["caelLib"] = caelLib

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
    if type(self[event]) == "function" then
        return self[event](self, event, ...)
    end
end)

caelLib.playerClass = select(2, UnitClass("player"))
caelLib.playerName = UnitName("player")
caelLib.playerRealm = GetRealmName()
caelLib.zoneName = GetRealZoneText()
caelLib.iLvl = math.floor(GetAverageItemLevel("player"))

-- Setup myChars and charListA list
do
    local myChars = {
        ["Earthen Ring"] = {
            ["WARRIOR"] = {
                ["Belliofria"]  = true,
            },
            ["PALADIN"] = {
                ["Keltric"]     = true,
            },
            ["DRUID"] = {
                ["Yeebuddy"]    = true,
            },
            ["PRIEST"] = {
                ["Jankly"]      = true,
            },
            ["HUNTER"] = {
                ["Meybe"]       = true,
            },
            ["WARLOCK"] = {
                ["Jeprscreprs"] = true,
            },
            ["SHAMAN"] = {
                ["Illexia"]     = true,
            },
            ["ROGUE"] = {
                ["Burlesque"]   = true,
            },
            ["DEATHKNIGHT"] = {
                ["Sey"]         = true,
            }
        },
        ["Korgath"] = {
            ["MAGE"] = {
                ["Regretfully"] = true,
            },
        },
        ["Broxigar (US)"] = {
            ["WARRIOR"] = {
                ["Bellio"]      = true,
                ["Belliofria"]  = true,
            },
        }
    }

    local charListA = {
        ["Illidan"] = { 
            ["HUNTER"] = {
                ["Ragnuk"]      = true,
                ["Callysto"]    = true
            },
            ["DRUID"] = {
                ["Cowdiak"]     = true,
                ["Kallysto"]    = true
            },
            ["PALADIN"] = {
                ["Calyr"]       = true
            },
            ["PRIEST"] = {
                ["Baelnorn"]    = true,
                ["Nïmue"]       = true
            },
            ["SHAMAN"] = {
                ["Pimiko"]      = true
            },
            ["WARRIOR"] = {
                ["Ragnøk"]      = true
            }
        }
    }

    if myChars[caelLib.playerRealm] and myChars[caelLib.playerRealm][caelLib.playerClass] and myChars[caelLib.playerRealm][caelLib.playerClass][UnitName("player")] then
        caelLib.myChars = true
    end

    if charListA[caelLib.playerRealm] and charListA[caelLib.playerRealm][caelLib.playerClass] and charListA[caelLib.playerRealm][caelLib.playerClass][UnitName("player")] then
        caelLib.isCharListA = true
    end
end

-- Returns the name of the spell ID.
caelLib.GetSpellName = function(spellId) return GetSpellInfo(spellId) end

function caelLib.IsIn (needle, haystack)
    if type(haystack) == "table" then
        for key, value in pairs(haystack) do
            if key == needle then
                return true, "key"
            elseif value == needle then
                return true, "value"
            end
        end
    end

    return false, nil
end

caelLib.utf8sub = function(string, index, dots)
    local bytes = string:len()
    if bytes <= index then
        return string
    else
        local length, currentIndex = 0, 1

        while currentIndex <= bytes do
            length = length + 1
            local char = string:byte(currentIndex)
            if char > 240 then
                currentIndex = currentIndex + 4
            elseif char > 225 then
                currentIndex = currentIndex + 3
            elseif char > 192 then
                currentIndex = currentIndex + 2
            else
                currentIndex = currentIndex + 1
            end

            if length == index then
                break
            end
        end

        if length == index and currentIndex <= bytes then
            return string:sub(1, currentIndex - 1)..(dots and "..." or "")
        else
            return string
        end
    end
end

-------------------------------------
-- Check if we are in a guild group
-------------------------------------
local IS_GUILD_GROUP = false

caelLib.isGuildGroup = function()
    return IS_GUILD_GROUP
end

EventFrame.GUILD_PARTY_STATE_UPDATED = function(self, event, ...)
    local isGuildGroup = ...
    if (isGuildGroup ~= IS_GUILD_GROUP) then
        IS_GUILD_GROUP = isGuildGroup
    end
end
EventFrame:RegisterEvent("GUILD_PARTY_STATE_UPDATED")

------------------------------
-- Update our zone variable --
------------------------------
EventFrame.ZONE_CHANGED_NEW_AREA = function(self, event, ...)
    if (caelLib.zoneName ~= GetRealZoneText()) then
        caelLib.zoneName = GetRealZoneText()
    end
end
EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

EventFrame.PLAYER_ENTERING_WORLD = function(self, event, ...)
    if (caelLib.zoneName ~= GetRealZoneText()) then
        caelLib.zoneName = GetRealZoneText()
    end
end
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Dummy function
caelLib.dummy = function() end

caelLib.kill = function(object)
    local objectReference = object
    if type(object) == "string" then
        objectReference = _G[object]
    else
        objectReference = object
    end
    if not objectReference then return end
    if type(objectReference) == "frame" then
        objectReference:UnregisterAllEvents()
    end
    objectReference.Show = caelLib.dummy
    objectReference:Hide()
end

caelLib.locale = caelLib.isCharListA and "frFR" or GetLocale()
