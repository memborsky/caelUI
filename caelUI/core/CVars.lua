local private = unpack(select(2, ...))

local events = private.events

local function initialize (_, event)
    local CVars = private.GetDatabase("cvars")

    if not CVars then
        local defaultCVarValues = {
            ["chatBubbles"] = 1
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
            ["chatBubblesParty"] = 1,
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
            ["autointeract"] = 0,
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

            ["M2Faster"] = 3, -- Adds additional threads used in rendering models on screen (0 = no additional threads, 1 - 3 = adds additional threads to the WoW Client)
            --[[
            ["gxTextureCacheSize"] = 1024,
            ["gxMultisample"] = 8,
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
            ["textureFilteringMode"] = 5,
            ["baseMip"] = 0, -- 0 for max
            ["ffxDeath"] = 0,
            ["ffxGlow"] = 0,
            --]]

            ["farclip"] = 1600,
            --["shadowMode"] = 0,
            ["componentCompress"] = 1,
            ["componentThread"] = 3,
            ["componentTextureLevel"] = 9, -- min 8
            ["sunshafts"] = 2,
            ["waterdetail"] = 3,
            ["rippleDetail"] = 2,
            ["reflectionmode"] = 3,
            ["violencelevel"] = 5, -- 0-5 Level of violence, 0 == none, 1 == green blood 2-5 == red blood

            --[[
            ["Sound_EnableHardware"] = 1,
            ["Sound_NumChannels"] = 128, -- 12, 32, 64, 128
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
            ["bloatthreat"] = 0, -- 1 makes nameplates resize depending on threat gain/loss. Only active when a mob has multiple units on its threat CVars.
        }

        setmetatable(CVars, {__index = defaultCVarValues})

        for cvar, value in next, CVars do
            SetCVar(cvar, value)
        end
    end

    -- 89, 449. 449 allows doing flips, 89 will not
    ConsoleExec("pitchlimit 89")

    -- -0.1-1 use ambient lighting for character. <0 == off
    ConsoleExec("characterAmbient 1")

    if (tonumber(GetCVar("ScreenshotQuality")) < 10) then
        SetCVar("ScreenshotQuality", 10)
    end

    hooksecurefunc("SetCVar", function(cvar, value, event)
        if event then
            CVars[cvar] = value
        end
    end)

    -- Save the CVars database for next time.
    CVars:Save()

    -- Unregister this function
    -- events:UnregisterEvent(event, self)
end

events:RegisterEvent("PLAYER_ENTERING_WORLD", initialize())

-- XXX: Hack to get the profanity filter working like we want it correctly.
events:RegisterEvent("CVAR_UPDATE", function()
    SetCVar("profanityFilter", 0)
end)
