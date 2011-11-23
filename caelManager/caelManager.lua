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

-- Local variables
local playerClass = select(2, UnitClass("player"))
local MAX_PLAYER_LEVEL = 85

local addons = {
    ----------
    -- Base --
    ----------
    ["base"] = {
        ["caelUI"]              = true,

        ["!recBug"]             = true,
        ["BadBoy"]              = true,
        ["caelManager"]         = true,
        ["caelBags"]            = true,
        ["caelBars"]            = true,
        ["caelBuffet"]          = true,
        ["caelBuffs"]           = true,
        ["caelCCBreak"]         = true,
        ["caelChat"]            = true,
        ["caelCombatLog"]       = true,
        ["caelCore"]            = true,
        ["caelEmote"]           = true,
        ["caelFactions"]        = true,
        ["caelInterrupt"]       = true,
        ["caelDataFeeds"]       = true,
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
        ["caelGroupCD"]         = true,
    },

    --------------------
    -- Class Specific --
    --------------------
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


    -------------------
    -- Task Specific --
    -------------------
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

    ["party"] = {
        ["alDamageMeter"]       = true,
        ["recThreatMeter"]      = true,
        ["RaidMobMarkerHUD"]    = true,
        ["Omen"]                = true,
        ["fAnnounce"]           = true,
        ["Snoopy"]              = false,
    },

    ["pvp"] = {
        ["alDamageMeter"]       = true,
        ["Snoopy"]              = false,
        ["RaidMobMarkerHUD"]    = true,
    },

    ["dev"] = {
    },

    ["quest"] = {
        ["alDamageMeter"]       = true,
        ["recThreatMeter"]      = true,

        ["Omen"]                = false,
    },

    -----------------------------
    -- Boss Encounter Specific --
    -----------------------------

    -------------
    -- BigWigs --
    -------------
        ["BigWigs-core"] = {
            ["BigWigs"]             = true,
            ["BigWigs_Core"]        = true,
            ["BigWigs_Options"]     = true,
            ["BigWigs_Plugins"]     = true,
            ["BigWigs_Foreign"]     = true,
        },

        ["BigWigs-raid"] = {
            -- Cata
            ["BigWigs_Baradin"]     = true,
            ["BigWigs_Bastion"]     = true,
            ["BigWigs_Blackwing"]   = true,
            ["BigWigs_Throne"]      = true,
        },

    ---------
    -- DXE --
    ---------
        ["DXE-core"] = {
            ["DXE"]                 = true,
            ["DXE_Options"]         = true,
            ["DXE_Loader"]          = true,
        },

        ["DXE-raid"] = {
            ["DXE_Baradin"] = true,
            ["DXE_Bastion"] = true,
            ["DXE_Descent"] = true,
            ["DXE_Throne"]  = true,
        },

    ----------------
    -- RaidWatch2 --
    ----------------
        ["RaidWatch-core"] = {
            ["RaidWatch"]           = true,
            ["RaidWatch_Core"]      = true,
            ["RaidWatch_Options"]   = true,
            ["RaidWatch_Plugins"]   = true,
        },

        ["RaidWatch-raid"] = {
            ["RaidWatch_BaradinHold"]   = true,
            ["RaidWatch_BoT"]           = true,
            ["RaidWatch_BWD"]           = true,
            ["RaidWatch_TotFW"]         = true,
        },

        ["RaidWatch-party"] = {
            ["RaidWatch_PartyCataclysm"] = true,
        },

    ---------
    -- DBM --
    ---------
        ["DBM-core"] = {
            ["DBM-Core"]            = true,
            ["DBM-GUI"]             = true,
        },

        ["DBM-raid"] = {
            ["DBM-BaradinHold"]         = true,
            ["DBM-BastionTwilight"]     = true,
            ["DBM-BlackwingDescent"]    = true,
            ["DBM-ThroneFourWinds"]     = true,
            ["DBM-Firelands"]           = true,
            ["DBM-DragonSoul"]          = true
        },

        ["DBM-party"] = {
            ["DBM-Party-Cataclysm"] = true,
        },

        ["DBM-pvp"] = {
            ["DBM-PvP"]             = true,
            ["DBM-WorldEvents"]     = true,
            ["DBM-BaradinHold"]         = true,
        },
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

local function ChangeSet(set)
    -- Holds what addons we are going to be loading.
    local loading = {}

    -- The player's level.
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

    EnableSet("base")

    if set then
        EnableSet(set)

        -- Enable boss mod sets
        if addons[raidBM .. "-" .. set] then
            EnableSet(raidBM .. "-core")
            EnableSet(raidBM .. "-" .. set)
        end
    end

    -- We assume since we aren't max level, that the questing set needs to be enabled.
    if playerLevel < MAX_PLAYER_LEVEL then
        EnableSet("quest")
    end

    -- Enable playerClass specific addons
    EnableSet(playerClass)

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
    -- Our loaded addon list.
    local loaded = {}

    -- Make sure we aren't dead or in combat before we attempt to auto switch.
    if UnitIsDeadOrGhost("player") or InCombatLockdown() then return end

    local _, instanceType = IsInInstance()

    -- Update our listing of currently loaded addons.
    do
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

    if instanceType ~= "none" then
        -- We are in some type of instance.

        for key, value in pairs(addons[instanceType]) do
            if (value == true and not loaded[key]) or (value == false and loaded[key]) then
                ChangeSet(instanceType)
                return
            end
        end

    else
        -- We aren't in any type of instance.

        local sets = {"base", playerClass}

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
caelManager:SetScript("OnEvent", function()
    AutoSwitch(GetRealZoneText())
end)

local handleSlash = function(set)
        ChangeSet(set, GetRealZoneText())
end

SLASH_CAELADDONSMANAGER1 = "/addonset"
SlashCmdList.CAELADDONSMANAGER = handleSlash
