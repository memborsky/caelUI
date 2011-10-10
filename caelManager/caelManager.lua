--[[    $Id$    ]]

local function debug (message) DEFAULT_CHAT_FRAME:AddMessage(message) end

local caelManager = CreateFrame("Frame", nil, UIParent)

--[[
    Raid Boss Encounters mod to auto enable

    This can be set to one of the following:
        DBM
        RaidWatch
        BigWigs
--]]
local raidBM = "DBM"
local prevInstanceType = ""
local zone = nil

-- Local variables
local playerNameRealm = UnitName("player") .. "-" .. GetRealmName()
local playerClass = select(2, UnitClass("player"))
local MAX_PLAYER_LEVEL = 80

-- Holds a list of the current loaded addons
local loaded = {}

-- Holds what we are currently loading before we load it
local loading = {}

local addons = {
    --[[
    ---------------------------------------------------------------------------
    -=( Base Addons )=-
    ---------------------------------------------------------------------------
    These addons will load for every user, always.
    --]]

    ["base"] = {
        ["caelUI"]              = true,

        ["!recBug"]             = true,
        ["BadBoy"]              = true,
        ["caelManager"]         = true,
        ["caelBags"]            = true,
        ["caelBars"]            = true,
        ["caelBuffet"]          = true,
        ["caelCCBreak"]         = true,
        ["caelChat"]            = true,
        ["caelCombatLog"]       = true,
        ["caelCore"]            = true,
        ["caelEmote"]           = true,
        ["caelFactions"]        = true,
        ["caelInterrupt"]       = true,
        ["caelDataFeeds"]       = true,
        ["caelLib"]             = true,
        ["caelPanels"]          = true,
        ["caelThreat"]          = true,
        ["caelTooltips"]        = true,
        ["caelTimers"]          = true,
        ["caelMap"]             = true,
        ["caelMinimap"]         = true,
        ["caelLoot"]            = true,
        ["caelNameplates"]      = true,
        ["caelCooldowns"]       = true,
        ["caelQuests"]          = true,
        ["gotChat"]             = true,
        ["gotMacros"]           = true,
        ["oUF"]                 = true,
        ["oUF_Caellian"]        = true,
        ["oUF_CombatFeedback"]  = true,
        ["recScrollAreas"]      = true,
        ["Snoopy"]              = true,
    },

    --[[
    ---------------------------------------------------------------------------
    -=( Class-Specific Addons )=-
    ---------------------------------------------------------------------------
    These addons will load for the specified class, always.
    --]]

    ["HUNTER"]  = {
        ["caelMisdirection"]    = true,
    },
    ["ROGUE"]   = {
        ["oUF_WeaponEnchant"]   = true,
        ["fComboBar"]           = true,
    },
    ["SHAMAN"]  = {
        ["oUF_TotemBar"]        = true,
        ["oUF_WeaponEnchant"]   = true,
    },
    ["WARRIOR"] = {
        ["GearSwitcher"]        = false,
    },

    --[[
    ---------------------------------------------------------------------------
    -=( Task-Specific Addons )=-
    ---------------------------------------------------------------------------
    These addons will load if you use their set name after the slash command.
    '/addonset raid' to load raid addons, for example.
    --]]

    ["raid"] = {
        ["caelBossWhisperer"]   = true,
        ["alDamageMeter"]       = true,
        ["recThreatMeter"]      = true,
        ["Omen"]                = true,
        ["RaidMobMarkerHUD"]    = true,
        ["fAnnounce"]           = true,

        ["Snoopy"]              = false,
        ["caelQuests"]          = false,
        ["oUF_Bell"]            = false,
    },

    --
    -- BigWigs Boss encounters
    ["BigWigs-core"] = {
        ["BigWigs"]             = true,
        ["BigWigs_Core"]        = true,
        ["BigWigs_Options"]     = true,
        ["BigWigs_Plugins"]     = true,
        ["BigWigs_Foreign"]     = true,
    },

    ["BigWigs-zone"] = {
        -- Cata
        ["Baradin Hold"]             = "BigWigs_Baradin",
        ["Bastion of Twilight"]      = "BigWigs_Bastion",
        ["Blackwing Descent"]        = "BigWigs_Blackwing",
        ["Throne of the Four Winds"] = "BigWigs_Throne",

        -- WoTLK
        ["Icecrown Citadel"]         = "BigWigs_Citadel",
        --[""] = "BigWigs_Northrend",
    },

    --
    -- DXE Boss Encounters
    ["DXE-core"] = {
        ["DXE"]                 = true,
        ["DXE_Options"]         = true,
        ["DXE_Loader"]          = true,
    },

    ["DXE-zone"] = {
        -- Cata
        ["Baradin Hold"]             = "DXE_Baradin",
        ["Bastion of Twilight"]      = "DXE_Bastion",
        ["Blackwing Descent"]        = "DXE_Descent",
        ["Throne of the Four Winds"] = "DXE_Throne",
        --[""] = "DXE_Kalimdor"
        -- WoTLK
        ["Icecrown Citadel"]         = "DXE_Citadel",
        ["Crusaders' Coliseum"]      = "DXE_Coliseum",
        ["Ulduar"]                   = "DXE_Ulduar",
        ["Naxxramas"]                = "DXE_Naxxramas",
        --[""] = "DXE_Northrend"
    },

    --
    -- RaidWatch2 Boss Encounters
    ["RaidWatch-core"] = {
        ["RaidWatch"]           = true,
        ["RaidWatch_Core"]      = true,
        ["RaidWatch_Options"]   = true,
        ["RaidWatch_Plugins"]   = true,
    },

    ["RaidWatch-zone"] = {
        -- Cata
        ["Baradin Hold"]             = "RaidWatch_BaradinHold",
        ["Bastion of Twilight"]      = "RaidWatch_BoT",
        ["Blackwing Descent"]        = "RaidWatch_BWD",
        ["Throne of the Four Winds"] = "RaidWatch_TotFW",
        -- WoTLK
        ["The Ruby Sanctum"]         = "RaidWatch_RubySanctum",
        ["Ulduar"]                   = "RaidWatch_Ulduar",
        ["Vault of Archavon"]        = "RaidWatch_VoA",
        ["Crusaders' Coliseum"]      = "RaidWatch_Coliseum",
        ["Icecrown Citadel"]         = "RaidWatch_Icecrown",
        -- Classic
        ["Molten Core"]              = "RaidWatch_MC",
        ["Blackwing Lair"]           = "RaidWatch_BWL",

        -- Cata Party instances
        ["Blackrock Caverns"]        = "RaidWatch_PartyCataclysm",
        ["Deadmines"]                = "RaidWatch_PartyCataclysm",
        ["Grim Batol"]               = "RaidWatch_PartyCataclysm",
        ["Halls of Origination"]     = "RaidWatch_PartyCataclysm",
        ["Lost City of the Tol'vir"] = "RaidWatch_PartyCataclysm",
        ["Shadowfang Keep"]          = "RaidWatch_PartyCataclysm",
        ["The Stonecore"]            = "RaidWatch_PartyCataclysm",
        ["The Vortex Pinnacle"]      = "RaidWatch_PartyCataclysm",
        ["Throne of the Tides"]      = "RaidWatch_PartyCataclysm",

        -- WoTLK Party instances
        --[""] = "RaidWatch_PartyWOTLK",
    },

    -- Deadly Boss Mods core addon
    ["DBM-core"] = {
        ["DBM-Core"]            = true,
        ["DBM-GUI"]             = true,
    },

    ["DBM-zone"] = {
        ["Baradin Hold"]                = "DBM-BaradinHold",
        ["Bastion of Twilight"]         = "DBM-BastionTwilight",
        ["Blackwing Descent"]           = "DBM-BlackwingDescent",
        ["Throne of the Four Winds"]    = "DBM-ThroneFourWinds",
    },

    ["party"] = {
        ["alDamageMeter"]       = true,
        ["recThreatMeter"]      = true,
        ["RaidMobMarkerHUD"]    = true,
        ["Omen"]                = true,
        ["fAnnounce"]           = true,

        -- XXX: This needs to move to zone specific
        ["DBM-Core"]            = true,
        ["DBM-GUI"]             = true,
        --["DBM-WorldEvents"]     = true,
        ["DBM-Party-Cataclysm"] = true,
        ["DPM-Core"]            = true,

        ["Snoopy"]              = false,
        ["oUF_Bell"]            = false,
    },

    ["pvp"] = {
        ["alDamageMeter"]       = true,

        -- XXX: This needs to move to zone specific
        ["DBM-Core"]            = true,
        ["DBM-GUI"]             = true,
        ["DBM-WorldEvents"]     = true,
        ["DBM-PvP"]             = true,
        ["RaidMobMarkerHUD"]    = true,
        
        ["Snoopy"]              = false,
        ["oUF_Bell"]            = false,
    },

    ["dev"] = {
        
    },

    ["quest"] = {
        ["alDamageMeter"]       = true,
        ["recThreatMeter"]      = true,

        ["Omen"]                = false,
    },

    ["not-max-level"] = {
        ["DBM-Core"]            = false,
        ["DBM-GUI"]             = false,
        ["DBM-DBM-WorldEvents"] = false,
        ["DBM-PvP"]             = false,
    },

    ------------------------
    -- Character Specific --
    ------------------------
    ["Keltric-Earthen Ring"] = {
        ["oUF_Caellian"]        = true,
        ["oUF_Drk"]             = false,
        ["oUF_Bell"]            = false,
        --["oUF_Caellian_Heal"]   = true,
    }
}


StaticPopupDialogs["RELOAD_UI"] = {
        text                    = "Reload the UI to update |cffD7BEA5cael|rManager",
        button1                 = ACCEPT,
        button2                 = CANCEL,
        OnAccept                = function() ReloadUI() end,
        timeout                 = 0,
        hideOnEscape            = false
}

local function IsIn (needle, haystack)
    if type(haystack) == "table" then
        for key, value in pairs(haystack) do
            if key == needle then
                return true, "needle"
            elseif value == needle then
                return true, "haystack"
            end
        end
    elseif type(haystack) == "string" then
        if type(needle) == "string" and needle == haystack then
            return true, "needle"
        end
    end

    return false, nil
end

local function ChangeSet(set, zone)
    local playerLevel = UnitLevel("player")

    -- Enable a set of addons.
    local function EnableSet(set)
        if not addons[set] then return end

        for key, value in pairs(addons[set]) do
            if IsIn(key, loading) or loading[key] ~= value then
                loading[key] = value
            end
        end
    end

    -- We are going to assume from here on out that only the addons we want enabled will be enabled.
    DisableAllAddOns(index)

    -- Reset our loading list
    loading = {}

    EnableSet("base")

    if set then
        if zone and zone == "" then
            zone = GetRealZoneText()
        end

        if set == "raid" then
            EnableSet(set)

            if addons[raidBM .. "-zone"][zone] and addons[raidBM .. "-core"] then
                EnableSet(raidBM .. "-core")

                -- Enable zone specific raid boss mod.
                loading[addons[raidBM .. "-zone"][zone]] = true
            end
        elseif set == "party" then
            EnableSet(set)

            if addons[raidBM .. "-zone"][zone] and addons[raidBM .. "-core"] then
                EnableSet(raidBM .. "-core")

                -- Enable zone specific raid boss mod.
                loading[addons[raidBM .. "-zone"][zone]] = true
            end
        else
            EnableSet(set)
        end
    end

    -- We assume since we aren't max level, that the questing set needs to be loaded
    if playerLevel < MAX_PLAYER_LEVEL then
        EnableSet("quest")
    end

    -- Enable playerClass specific addons
    EnableSet(playerClass)

    -- Enable player specific addons if they exist
    EnableSet(playerNameRealm)

    -- After all the other sets have been enabled, lets enable the set that is for us not being max level.
    -- This is used to let us unload/load more addons since we aren't max level.
    if playerLevel < MAX_PLAYER_LEVEL then
        EnableSet("not-max-level")
    end

    -- Here we make all the magic happen of loading our loading set.
    for key, value in pairs(loading) do
        if value then
            EnableAddOn(key)
        end
    end

    StaticPopup_Show("RELOAD_UI")
end

local function CheckAddOns(name, enabled)
    local sets = {"base", playerClass}
    local result = false
    local playerLevel = UnitLevel("player")

    if playerLevel < MAX_PLAYER_LEVEL then
        table.insert(sets, 2, "quest")

    end

    if addons[playerNameRealm] then
        table.insert(sets, playerNameRealm)
    end

    if playerLevel < MAX_PLAYER_LEVEL then
        table.insert(sets, "not-max-level")
    end

    for _, set in pairs(sets) do
        if addons[set][name] then
            if addons[set][name] ~= enabled then
                result = true
            else
                result = false
            end
        end
    end

    return result
end

local function AutoSwitch(zone)
    -- Make sure we aren't dead or in combat before we attempt to auto switch.
    if UnitIsDeadOrGhost("player") or InCombatLockdown() then return end

    local _, instanceType = IsInInstance()

    -- Update our listing of currently loaded addons.
    do
        loaded = {}
        local name, enabled

        for index = 1, GetNumAddOns() do
            name, _, _, enabled = GetAddOnInfo(index)

            loaded[name] = enabled and true or false
        end
    end

    -- Change instanceType to pvp if we enter into a world pvp zone that is currently in progress.
    do
        local tbActive = select(3, GetWorldPVPAreaInfo(2)) and true or false
        local wgActive = select(3, GetWorldPVPAreaInfo(1)) and true or false

        if zone == "Tol Barad" and tbActive then
            instanceType = "pvp"
        elseif zone == "Wintergrasp" and wgActive then
            instanceType = "pvp"
        end
    end

    -- We are assuming we want to use the pvp set for arenas.
    if instanceType == "arena" then instanceType = "pvp" end

    -- We check out previous instance type after we have done all our conversions just to be safe.
    --if prevInstanceType == instanceType then return end
    prevInstanceType = instanceType

    -- XXX: Need to check raid type for boss mod addons.
    if instanceType ~= "none" then
        for key, value in pairs(addons[instanceType]) do
            if (value == true and not loaded[key]) or (value == false and loaded[key]) then
                ChangeSet(instanceType, zone)
                return -- This will break all for loops, as we have already changed our set, we no longer need to check more.
            end
        end
    else
        -- Our set list for no instance
        local sets = {"base", playerClass, playerRealmName}

        if UnitLevel("player") < MAX_PLAYER_LEVEL then
            table.insert(sets, 2, "quest")
        end

        -- Make sure the addons that are supposed to be enabled are enabled.
        for name, enabled in pairs(loaded) do
            for _, set in pairs(sets) do
                if not addons[set] then return end

                for key, value in pairs(addons[set]) do
                    if name == key and value ~= enabled then
                        ChangeSet()
                        return -- This will break all for loops, as we have already changed our set, we no longer need to check more.
                    end
                end
            end

            -- Check to make sure we don't have any extra addons loaded
            if CheckAddOns(name, enabled) then
                ChangeSet()
            end

        end
    end
end

caelManager:RegisterEvent("PLAYER_ENTERING_WORLD")
caelManager:RegisterEvent("ZONE_CHANGED_NEW_AREA")
caelManager:SetScript("OnEvent", function(self, event, ...)
    zone = GetRealZoneText()

    if event == "PLAYER_ENTERING_WORLD" then
        local _, instanceType = IsInInstance()

        if instanceType == "raid" or instanceType == "party" then

            if addons[raidBM .. "-zone"][zone] then
                for name, enabled in pairs(addons[raidBM .. "-core"]) do
                    if enabled then
                        LoadAddOn(name)
                    end
                end
                LoadAddOn(addons[raidBM .. "-zone"][zone])
            end
        end
    end

    AutoSwitch(zone)
end)

local handleSlash = function(set)
        ChangeSet(set, GetRealZoneText())
end

SLASH_CAELADDONSMANAGER1 = "/addonset"
SlashCmdList.CAELADDONSMANAGER = handleSlash
