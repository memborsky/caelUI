--[[    $Id$    ]]

local _, caelCore = ...

local cvardata = caelCore.createModule("cvarData")

cvardata.initOn = "PLAYER_ENTERING_WORLD"

local myChars = caelLib.myChars
local ZoneChange = function(zone)
        local _, instanceType = IsInInstance()
        if zone == "Orgrimmar" or zone == "Stormwind" then
            if caelLib.playerClass == "HUNTER" then SetTracking(nil) end
            SetCVar("chatBubbles", 0)
        elseif instanceType == "raid" then
            SetCVar("chatBubbles", 1)
        else
            SetCVar("chatBubbles", 0)
        end
end


cvardata:RegisterEvent("WORLD_MAP_UPDATE")
cvardata:RegisterEvent("ZONE_CHANGED_NEW_AREA")
cvardata:RegisterEvent("PLAYER_ENTERING_WORLD")
cvardata:SetScript("OnEvent", function(self, event)
        local zone = GetRealZoneText()

        if zone and zone ~= "" then
                return ZoneChange(zone)
        end
end)


--[[
Scales = {
    ["800"] = { ["600"] = 0.69999998807907},
    ["1024"] = { ["768"] = 0.69999998807907},
    ["1152"] = { ["864"] = 0.69999998807907},
    ["1280"] = { ["720"] = 0.93000000715256, ["768"] = 0.87000000476837, ["960"] = 0.69999998807907, ["1024"] = 0.64999997615814},
    ["1366"] = { ["768"] = 0.93000000715256},
    ["1600"] = { ["900"] = 0.93000000715256, ["1200"] = 0.69999998807907},
    ["1680"] = { ["1050"] = 0.83999997377396},
    ["1768"] = { ["992"] = 0.93000000715256},
    ["1920"] = { ["1200"] = 0.83999997377396, ["1080"] = 0.93000000715256},
}
--]]

local defaultCVarValues = {
    ["reducedLagTolerance"] = 1,
    ["scriptProfile"] = 0, -- Disables CPU profiling
    ["showToolsUI"] = 0, -- Disables the Launcher
    ["synchronizeSettings"] = 0, -- Don't synchronize settings with the server
    ["synchronizeConfig"] = 0,
    ["synchronizeBindings"] = 0,
    ["synchronizeMacros"] = 0,
    ["alwaysCompareItems"] = 1,
    ["deselectOnClick"] = 1,
    ["autoDismountFlying"] = 1,
    ["autoClearAFK"] = 1,
    ["lootUnderMouse"] = 0,
    ["autoLootDefault"] = 1,
    ["stopAutoAttackOnTargetChange"] = 1,
    ["autoSelfCast"] = 1,
    ["rotateMinimap"] = 0,
    ["showLootSpam"] = 1,
    ["threatShowNumeric"] = 0,
    ["threatPlaySounds"] = 0,
    ["autoQuestWatch"] = 1,
    ["autoQuestProgress"] = 1,
    ["mapQuestDifficulty"] = 1,
    ["profanityFilter"] = 0,
    ["chatBubblesParty"] = 0,
    ["spamFilter"] = 0,
    ["guildMemberNotify"] = 1,
    ["chatMouseScroll"] = 1,
    ["chatStyle"] = "classic",
    ["conversationMode"] = "inline",
    ["lockActionBars"] = 1,
    ["alwaysShowActionBars"] = 1,
    ["secureAbilityToggle"] = 1,
    ["UnitNameOwn"] = 0,
    ["UnitNameNPC"] = 1,
    ["UnitNameNonCombatCreatureName"] = 0,
    ["UnitNamePlayerGuild"] = 1,
    ["UnitNamePlayerPVPTitle"] = 1,
    ["UnitNameFriendlyPlayerName"] = 1,
    ["UnitNameFriendlyPetName"] = 1,
    ["UnitNameFriendlyGuardianName"] = 1,
    ["UnitNameFriendlyTotemName"] = 0,
    ["UnitNameEnemyPlayerName"] = 1,
    ["UnitNameEnemyPetName"] = 1,
    ["UnitNameEnemyGuardianName"] = 1,
    ["UnitNameEnemyTotemName"] = 1,
    ["CombatDamage"] = 1,
    ["CombatHealing"] = 1,
    ["fctSpellMechanics"] = 1,
    ["enableCombatText"] = 0,
    ["showArenaEnemyFrames"] = 0,
    ["autointeract"] = caelLib.isCharListA and 1 or 0,
    ["showTutorials"] = 0,
    ["UberTooltips"] = 1,
    ["showNewbieTips"] = 0,
    ["scriptErrors"] = 1,
    ["consolidateBuffs"] = 0,
    ["alternateResourceText"] = 0, -- Display percentages on AltPowerBar

    ["showToastOnline"] = 0,
    ["showToastOffline"] = 0,
    ["showToastBroadcast"] = 0,
    ["showToastFriendRequest"] = 0,
    ["showToastConversation"] = 0,
    ["showToastWindow"] = 0,
    ["toastDuration"] = 0,

    ["M2Faster"] = myChars and 3 or 2, -- Adds additional threads used in rendering models on screen (0 = no additional threads, 1 - 3 = adds additional threads to the WoW Client)
    --[[
    ["gxTextureCacheSize"] = myChars and 1024 or 512,
    ["gxMultisample"] = myChars and 8 or 4,
    ["gxMultisampleQuality"] = 0.000000,
    ["gxVSync"] = 0,
    ["gxTripleBuffer"] = 0,
    ["gxFixLag"] = 1,
    ["gxCursor"] = 1,
    --]]
    ["Maxfps"] = 100,
    ["maxfpsbk"] = 100,
    --[[
    ["ffx"] = 0,
    ["textureFilteringMode"] = myChars and 5 or 1,
    ["baseMip"] = 0, -- 0 for max
    ["ffxDeath"] = 0,
    ["ffxGlow"] = 0,
    --]]

    ["farclip"] = 1600,
    --["shadowMode"] = 0,
    ["componentCompress"] = 1,
    ["componentThread"] = myChars and 3 or 1,
    ["componentTextureLevel"] = 9, -- min 8
    ["sunshafts"] = myChars and 2 or 1,
    ["waterdetail"] = myChars and 3 or 2,
    ["rippleDetail"] = myChars and 2 or 1,
    ["reflectionmode"] = myChars and 3 or 0,
    ["violencelevel"] = 5, -- 0-5 Level of violence, 0 == none, 1 == green blood 2-5 == red blood

    --[[
    ["Sound_EnableHardware"] = 1,
    ["Sound_NumChannels"] = myChars and 128 or 64, -- 12, 32, 64, 128
    ["Sound_OutputQuality"] = 2, -- 0-2
    ["Sound_EnableSoftwareHRTF"] = 1, -- Enables headphone designed sound subsystem
    ["Sound_AmbienceVolume"] = 0.10000000149012,
    ["Sound_EnableErrorSpeech"] = 0,
    ["Sound_EnableMusic"] = 0,
    ["Sound_EnableSoundWhenGameIsInBG"] = 1,
    ["Sound_MasterVolume"] = 0.10000000149012,
    ["Sound_MusicVolume"] = 0,
    ["Sound_SFXVolume"] = 0.20000000298023,
    --]]

    ["cameraDistanceMax"] = 50,
    ["cameraDistanceMaxFactor"] = 3.4,
    ["cameraDistanceMoveSpeed"] = 50,
    ["cameraViewBlendStyle"] = 2,

    ["nameplateShowFriends"] = 0,
    ["nameplateShowFriendlyPets"] = 0,
    ["nameplateShowFriendlyGuardians"] = 0,
    ["nameplateShowFriendlyTotems"] = 0,

    ["nameplateShowEnemies"] = 1,
    ["nameplateShowEnemyPets"] = 1,
    ["nameplateShowEnemyGuardians"] = 1,
    ["nameplateShowEnemyTotems"] = 1,

    --["spreadnameplates"] = 1, -- 0 makes nameplates overlap.
    ["bloattest"] = 0, -- 1 might make nameplates larger but it fixes the disappearing ones.
    ["bloatnameplates"] = 0, -- 1 makes nameplates larger depending on threat percentage.
    ["bloatthreat"] = 0, -- 1 makes nameplates resize depending on threat gain/loss. Only active when a mob has multiple units on its threat table.
}

function cvardata:init()
    if not self.db.cvarValues then
        self.db.cvarValues = {}
    end
    
    setmetatable(self.db.cvarValues, {__index = defaultCVarValues})
    
    local screenWidth, screenHeight = caelLib.screenWidth, caelLib.screenHeight
    if caelLib.scales[screenWidth] and caelLib.scales[screenWidth][screenHeight] then
        SetCVar("useUiScale", 1)
        SetCVar("uiScale", caelLib.scales[screenWidth][screenHeight])

        WorldFrame:SetUserPlaced(false)
        WorldFrame:ClearAllPoints()
        WorldFrame:SetHeight(GetScreenHeight() * caelLib.scales[screenWidth][screenHeight])
        WorldFrame:SetWidth(GetScreenWidth() * caelLib.scales[screenWidth][screenHeight])
        WorldFrame:SetPoint("BOTTOM", UIParent)
    else
        SetCVar("useUiScale", 0)
        print("Your resolution is not supported, UI Scale has been disabled.")
    end
    
    for cvar in next, defaultCVarValues do
        SetCVar(cvar, self.db.cvarValues[cvar])
    end
    
    ConsoleExec("pitchlimit 89") -- 89, 449. 449 allows doing flips, 89 will not
    ConsoleExec("characterAmbient -0.1") -- -0.1-1 use ambient lighting for character. <0 == off
    if (tonumber(GetCVar("ScreenshotQuality")) < 10) then SetCVar("ScreenshotQuality", 10) end
    
    hooksecurefunc("SetCVar", function(cvar, value, event)
        if event then
            cvardata.db.cvarValues[cvar] = value
        end
    end)
end