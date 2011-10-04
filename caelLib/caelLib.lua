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

caelLib.screenWidth, caelLib.screenHeight = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")

-- 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1, 1.05, 1.1, 1.15
caelLib.scales = {
    ["720"] = { ["576"] = 0.65},
    ["800"] = { ["600"] = 0.7},
    ["960"] = { ["600"] = 0.84},
    ["1024"] = { ["600"] = 0.89, ["768"] = 0.7},
    ["1152"] = { ["864"] = 0.7},
    ["1176"] = { ["664"] = 0.93},
    ["1280"] = { ["800"] = 0.84, ["720"] = 0.93, ["768"] = 0.87, ["960"] = 0.7, ["1024"] = 0.65},
    ["1360"] = { ["768"] = 0.93},
    ["1366"] = { ["768"] = 0.93},
    ["1440"] = { ["900"] = 0.84},
    ["1600"] = { ["1200"] = 0.7, ["1024"] = 0.82, ["900"] = 0.93},
    ["1680"] = { ["1050"] = 0.84},
    ["1768"] = { ["992"] = 0.93},
    ["1920"] = { ["1440"] = 0.7, ["1200"] = 0.84, ["1080"] = 0.93},
    ["2048"] = { ["1536"] = 0.7},
    ["2560"] = { ["1440"] = 0.93, ["1600"] = caelLib.myChars and 0.64 or 0.84},
}

local ScaleFix

caelLib.scale = function(value)
    return ScaleFix * math.floor(value / ScaleFix + 0.5)
end

EventFrame.ADDON_LOADED = function(self, event, addon)
    if addon ~= "caelLib" then
        return
    end

    if not caelDB then
        caelDB  = {}
    end

    local UIScale = caelDB.scale or caelLib.scales[screenWidth] and caelLib.scales[screenWidth][screenHeight] or 1
    ScaleFix = (768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)")))/UIScale

    self:UnregisterEvent(event)
end
EventFrame:RegisterEvent("ADDON_LOADED")

EventFrame.UPDATE_FLOATING_CHAT_WINDOWS = function(self, event)
    caelDB.scale = math.floor(GetCVar("uiScale") * 100 + 0.5)/100
end
EventFrame:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS")

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
