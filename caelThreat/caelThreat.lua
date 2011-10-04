--[[    $Id$    ]]

local _, caelThreat = ...

local abs = math.abs
local playerClass = caelLib.playerClass
local unitClass, lastWarning

caelThreat.eventFrame = CreateFrame"Frame"

-- Dis/En-able warnring sounds
local warningSounds = true

-- Aggro Colors
local aggroColors = {
    [true] = {
        [1] = {1, 0.6, 0, 1},
        [2] = {1, 1, 0.47, 1},
        [3] = {0.33, 0.59, 0.33, 1},
    },
    [false] = {
        [1] = {1, 1, 0.47, 1},
        [2] = {1, 0.6, 0, 1},
        [3] = {0.69, 0.31, 0.31, 1},
    }
}

local isTank = false

specCheck = function(unit, tree)

    -- checks the points of the player/unit for the given tree
    local pointCheck = function(tree, inspect)
        local _, _, _, _, pointsSpent, _, _, _ = GetTalentTabInfo(tree, inspect)

        if pointsSpent >= 11 then -- @ 85 you can only subspec 10 points into another tree.
            return true
        else
            return false
        end
    end

    -- This is used to hold our result from specChecking the player/unit
    isTank = false

    -- Used to inspect the unit for possibly being a tank
    local inspect = CreateFrame"Frame"
    inspect:HookScript("OnEvent", function(self, event, unit)
        if event == "INSPECT_READY" then
            isTank = pointCheck(tree, true)
            --print("Inspecting " .. unit .. " and found is " .. (isTank and "tank" or "not tank"))
            self:UnregisterEvent(event)
        end
    end)

    -- Special casing for unit == "player" on talent checking.
    if unit == "player" then
        isTank = pointCheck(tree, false)
    else
        local name = UnitName(unit)

        if CanInspect(unit) and CheckInteractDistance(unit, 1) then
            NotifyInspect(unit)
            inspect:RegisterEvent("INSPECT_READY")
        end
    end

end

local isTankClassSpec = {
    ["PALADIN"] = function(unit) return specCheck(unit, 2) end,
    --GetSpellInfo(25780), -- Righteous Fury (RF no longer provides any assistance outside of increased threat - 4.0.1)

    ["WARRIOR"] = function(unit) return specCheck(unit, 3) end,
    -- We check for this since Defensive Stance isn't an aura

    ["DEATHKNIGHT"] = function(unit) return specCheck(unit, 1) end,
    --GetSpellInfo(48263), -- Blood Presence
    ["DRUID"] = GetSpellInfo(5487), -- Bear Form
}

local function IsTankCheck(unit)
    local status = false

    local _, unitClass = UnitClass(unit)
    local check = isTankClassSpec[unitClass]

    if type(check) == "table" then
        status = true
        for i = 1, #check do
            if not UnitAura(unit, check[i]) then
                status = false
            end
        end
    elseif type(check) == "function" then
        isTankClassSpec[unitClass](unit)

        --print(isTank)
        if isTank then
            status = true
        end
    elseif check then
        if UnitAura(unit, check) then
            status = true
        end
    end

    return status
end

caelThreat.eventFrame:RegisterEvent("UNIT_AURA")
caelThreat.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
caelThreat.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
caelThreat.eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
caelThreat.eventFrame:HookScript("OnEvent", function(self, event, unit)

    -- Checking for PVP zones.
    local zone = tostring(GetRealZoneText())
    if (zone ~= "Wintergrasp" or zone ~= "Tol Barad") or MiniMapBattlefieldFrame.status == "active" then return end

    -- Check to make sure our unit is not nil'd.
    if not unit then return end

    -- Holds our boolean for unit and player being an actual tank.
    local unitIsTank = IsTankCheck(unit)
    local playerIsTank = IsTankCheck("player")

    if event ~= "UNIT_AURA" then

        -- threat status and percent
        local _, status, threatPercent = UnitDetailedThreatSituation("player", "target")

        -- Used to hold our notice message
        local raidNoticeMessage = ""

        if not playerIsTank then

            if status then
                threatPercent = floor(threatPercent + 0.5)
            end

            if (status and status < 1)    then

                if (abs(threatPercent - 20) <= 5) then

                    if (lastWarning ~= 20) then
                        raidNoticeMessage = "|cff559655".."~20% THREAT|r"
                        lastWarning = 20
                    end

                elseif (abs(threatPercent - 40) <= 5) then

                    if (lastWarning ~= 40) then
                        raidNoticeMessage = "|cff559655".."~40% THREAT|r"
                        lastWarning = 40
                    end

                elseif (abs(threatPercent - 60) <= 5) then

                    if (lastWarning ~= 60) then
                        raidNoticeMessage = "|cffFFFF78".."~60% THREAT|r" -- Yellow |cffA5A05A
                        lastWarning = 60
                    end

                end -- if (threatPercent check of 20/40/60) then

            elseif (status and status > 0 and status < 3 and unit == "player") then

                if (abs(threatPercent - 80) <= 5) then

                    if (lastWarning ~= 85) then

                        if warningSounds then
                            PlaySoundFile(caelMedia.files.soundWarning, "SFX")
                        end

                        raidNoticeMessage = "|cffFF9900".."WARNING THREAT: "..tostring(threatPercent).."%|r" -- Orange |cffB46E46
                        lastWarning = 85

                    end -- if (lastWarnging ~= 85) then

                end -- if (abs(threatPercent - 80) <= 5) then

            elseif (status and status > 2 and unit == "player") then

                if warningSounds then
                    PlaySoundFile(caelMedia.files.soundAggro, "SFX")
                end

                raidNoticeMessage = "|cffAF5050AGGRO|r" -- Red
                UIFrameFlash(caelCoreModuleShadowEdge and caelCoreModuleShadowEdge or LowHealthFrame, 0.2, 0.2, 0.4, caelCoreModuleShadowEdge and true or false, 0, 0.2)

            end -- if (threat status checks) then

        end -- if not playerIsTank then

        -- Notice the player of threat status if not nil
        if raidNoticeMessage ~= "" then
            RaidNotice_AddMessage(RaidWarningFrame, raidNoticeMessage, ChatTypeInfo["RAID_WARNING"])
            raidNoticeMessage = ""
        end

    end -- if event ~= "UNIT_AURA" then


    if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then

        -- caelPanel border coloring
        if IsAddOnLoaded("caelPanels") then
            local editboxPanel = caelPanel4
            for _, panel in pairs(caelPanels) do
                if (panel:GetName() ~= "caelPanel4" or panel ~= editboxPanel) then
                    local status = UnitThreatSituation("player")
                    if (status and status > 0) then
                        local r, g, b = unpack(aggroColors[playerIsTank][status])
                        panel:SetBackdropBorderColor(r, g, b)
                    else
                        panel:SetBackdropBorderColor(0, 0, 0)
                    end
                end
            end
        end

        -- oUF_Caellian frame border coloring.
        if IsAddOnLoaded("oUF_Caellian") then
            --print(unit)
            if not oUF.units[unit] then return end

            local status = UnitThreatSituation(unit)

            if (status and status > 0) then
                if unit == "party1" then
                    --print("Unit " .. unit .. " is " .. (unitIsTank and "tank" or "not tank") .. " with status = " .. status)
                end

                local r, g, b = unpack(aggroColors[unitIsTank][status])
                oUF.units[unit].FrameBackdrop:SetBackdropColor(r, g, b, a)
                if oUF.units[unit].Overlay then
                    oUF.units[unit].Overlay:SetStatusBarColor(r, g, b, a)
                end
            else
                oUF.units[unit].FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
                if oUF.units[unit].Overlay then
                    oUF.units[unit].Overlay:SetStatusBarColor(0.1, 0.1, 0.1, 0.75)
                end
            end
        end
    end
end)
