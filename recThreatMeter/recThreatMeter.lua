local round_off = true            -- Should we leave 2 decimal places, or round the threat off?  This is for display only, internally the values will retain their precision.

local raid_threat = {}
local display_frame = CreateFrame("Frame", "recThreatMeter", UIParent)
local table_sort, string_format = table.sort, string.format
local math_floor, tonumber = math.floor, tonumber
local UnitName = UnitName
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local need_reset = true
local in_raid, in_party, warning_played, i_am_tank, target_okay
local top_threat, overtake_threat, my_threat = 0, -1, -1
local HIDDEN, TANKING, BLANK = "* %s", ">>> %s <<<", " "
local PixelScale = caelUI.config.PixelScale
local media = caelUI.media
--local 10   = 10 -- This is set in MakeDisplay() to its true number.

local recycle_bin = {}
local function Recycler(trash_table)
    if trash_table then
        -- Recycle trash_table
        for k,v in pairs(trash_table) do
            if type(v) == "table" then
                Recycler(v)
            end
            trash_table[k] = nil
        end
        recycle_bin[(#recycle_bin or 0) + 1] = trash_table
    else
        -- Return recycled table, or new table if there are no used ones to give.
        if #recycle_bin and #recycle_bin > 0 then
            return table.remove(recycle_bin, 1)
        else
            return {}
        end
    end
end

-- Sorting functions
local function sortfunc(a,b) return (a.threat or 0) > (b.threat or 0) end
local function SortThreat()
    if #raid_threat and #raid_threat > 0 then
        table_sort(raid_threat, sortfunc)
    end
end

local smooth_bars = Recycler()
local smooth_update = CreateFrame("Frame")
local function SmoothUpdate()
    local rate = GetFramerate()
    local limit = 30/rate
    for index, data in pairs(smooth_bars) do
        local cur = display_frame.bars[index]:GetValue()
        local new = cur + min((data.value-cur)/3, max(data.value-cur, limit))
        if new ~= new then
            -- Mad hax to prevent QNAN.
            new = data.value
        end
        display_frame.bars[index]:SetValue(new)
        display_frame.bars[index].lefttext:SetText(data.left or " ")
        display_frame.bars[index].righttext:SetText(data.right or " ")
        if cur == data.value or abs(new - data.value) < 2 then
            display_frame.bars[index]:SetValue(data.value)
            display_frame.bars[index].lefttext:SetText(data.left or " ")
            display_frame.bars[index].righttext:SetText(data.right or " ")
            local temp = smooth_bars[index]
            smooth_bars[index] = nil
            Recycler(temp)
        end
    end
    if not smooth_bars or #smooth_bars == 0 then
        smooth_update:SetScript('OnUpdate', nil)
    end
end
local function SetBarValues(index, value, left, right)
    if value ~= display_frame.bars[index]:GetValue() or value == 0 then
        smooth_bars[index] = smooth_bars[index] or Recycler()
        smooth_bars[index].value = value or 0
        smooth_bars[index].left = left or " "
        smooth_bars[index].right = right or " "
        smooth_update:SetScript('OnUpdate', SmoothUpdate)
    else
        local temp = smooth_bars[index]
        smooth_bars[index] = nil
        Recycler(temp)
    end

    -- Simply leave out value, left and/or right to reset the value(s) to a zeroed state.
    --display_frame.bars[index]:SetValue(value or 0)
    --display_frame.bars[index].lefttext:SetText(left or " ")
    --display_frame.bars[index].righttext:SetText(right or " ")
end

-- Determines unit's position in our threat table, or adds them if they are not present
-- Then updates their threat data.
local function UpdateUnitThreat(unit_id)
    local unit_name = UnitName(unit_id)
    local updated = false
    if unit_name then
        for i, data in pairs(raid_threat) do
            if data.name == unit_name then

                -- Sometimes names get set as 'Unknown'.  This should resolve that issue.
                if raid_threat[i].name == "Unknown" then raid_threat[i].name = unit_name end

                -- We use this as a flag to determine that we had this unit in our threat table.
                updated = true

                -- Obtain threat info about this unit.
                local tanking, state, scaled_percent, raw_percent, threat = UnitDetailedThreatSituation(unit_id, "target")

                if threat then

                    -- Compensate for Mirror Images, Fade
                    if threat < 0 then
                        threat = threat + 410065408
                        raid_threat[i].threat_hidden = true
                    else
                        raid_threat[i].threat_hidden = false
                    end

                    -- If threat level is zero at this point, then we're just going to hide the user's threat by setting it to -1
                    if threat == 0 then threat = -1 end

                    -- Save the highest threat value for later (TODO: Use this instead of 1.3 below to provide overtake bar)
                    if threat > top_threat then top_threat = threat end

                    if tanking then

                        -- Save the threat needed to overtake this unit if they are tanking.
                        overtake_threat = threat * 1.1
                        if not(raid_threat[i].tanking) and warning_played then

                            -- If we were not tanking before, and we were warned, then play aggro sound.
                            PlaySoundFile(media.files.sound_aggro, "SFX")
                        end

                        -- Flag this unit as tanking, for special formatting on the bars.
                        raid_threat[i].tanking = true
                    else

                        -- Flag this unit as not tanking.
                        raid_threat[i].tanking = false
                    end

                    -- Deposit this unit's threat into our table
                    raid_threat[i].threat = threat

                    -- If this is the player, then we save some special flags
                    if data.name == UnitName("player") then
                        my_threat = threat
                        i_am_tank = raid_threat[i].tanking
                    end
                else
                    -- unit is not on target's threat table.
                    raid_threat[i].threat = -1
                    raid_threat[i].tanking = false
                    raid_threat[i].threat_hidden = false
                end
            end
        end

        -- If we haven't updated, then we don't have this unit in our threat table, so we'll add them, and then check them again.
        if not updated then
            raid_threat[(#raid_threat or 0)+1] = { name = unit_name, threat = -1, threat_hidden = false, tanking = false }
            UpdateUnitThreat(unit_id)
        end
    end
end

local function UpdateDisplay()
    -- If we have no data, then, zero out everything.
    if not(#raid_threat) or #raid_threat < 1 or not(UnitName("target")) then
        for i = 1, 10 do
            display_frame.bars[i]:SetMinMaxValues(0, 1)
            SetBarValues(i)
        end
        return
    end

    -- Whether to sound a warning for the user or not, and resets our warning played
    -- flag if the user slips back under 80% threat.
    if not(i_am_tank) and my_threat >= (top_threat * 0.8) and not(warning_played) then
        PlaySoundFile(media.files.sound_warning, "SFX")
        warning_played = true
    elseif my_threat < (top_threat * 0.8) then
        warning_played = false
    end

    for i = 1, 10 do

        -- Set the bar's max value to the take aggro level, if present.
        display_frame.bars[i]:SetMinMaxValues(0, raid_threat[1] and raid_threat[1].threat > -1 and (tonumber(raid_threat[1].threat)/100) or 1)
        if i == 1 then
            display_frame.bars[i]:SetValue(tonumber(raid_threat[i].threat)/100 or 0,
            string_format(raid_threat[i].threat_hidden and HIDDEN or raid_threat[i].tanking and TANKING or "%s", raid_threat[i].name),
            round_off and math_floor(tonumber(raid_threat[i].threat)/100) or (tonumber(raid_threat[i].threat)/100) or 0
            )
        end

        if raid_threat[i] and raid_threat[i].threat > -1 then
            SetBarValues(i,
            tonumber(raid_threat[i].threat)/100 or 0,
            string_format(raid_threat[i].threat_hidden and HIDDEN or raid_threat[i].tanking and TANKING or "%s", raid_threat[i].name),
            round_off and math_floor(tonumber(raid_threat[i].threat)/100) or (tonumber(raid_threat[i].threat)/100) or 0
            )


            -- Color bar by class if we can obtain the info.
            local _, class = UnitClass(raid_threat[i].name)
            if class then
                -- By class
                display_frame.bars[i]:SetStatusBarColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 0.8)
            elseif raid_threat[i].name == "Aggro" then
                display_frame.bars[i]:SetStatusBarColor(1, 0, 0, 0.8)
            else
                display_frame.bars[i]:SetStatusBarColor(1, 1, 1, 0.8)
            end
        else
            SetBarValues(i)
        end
    end
end

local function UpdateThreat()
    if not target_okay then
        UpdateDisplay()
    end
    in_party = GetNumPartyMembers() > 0
    in_raid = GetNumRaidMembers() > 0

    if in_raid or in_party then
        if in_raid then
            for i = 1, GetNumRaidMembers() do
                UpdateUnitThreat(string_format("raid%d", i))
                UpdateUnitThreat(string_format("raidpet%d", i))
            end
        else
            for i = 1, GetNumPartyMembers() do
                UpdateUnitThreat(string_format("party%d", i))
                UpdateUnitThreat(string_format("partypet%d", i))
            end
        end
    end

    if not in_raid then
        UpdateUnitThreat("player")
        UpdateUnitThreat("pet")
    end

    UpdateUnitThreat("targettarget")

    -- Add in our overtake threat line
    local overtake_set
    for k,v in pairs(raid_threat) do
        if v.name == "Aggro" then
            v.threat = overtake_threat or -1
            overtake_set = true
        end
    end
    if not overtake_set then
        raid_threat[(#raid_threat or 0)+1] = { name = "Aggro", threat = overtake_threat or -1, threat_hidden = false, tanking = false }
    end

    SortThreat()
    UpdateDisplay()
end

local function MakeDisplay()
    local f = display_frame
    f:SetWidth(PixelScale(200))
    f:SetHeight(PixelScale(170))

    caelPanels.SetupAddonPanel(caelPanel_ThreatMeter, f)
    --f:SetPoint("BOTTOM", UIParent, "BOTTOM", PixelScale(647), PixelScale(23))

    f.texture = f:CreateTexture()
    f.texture:SetAllPoints()
    f.texture:SetTexture(0,0,0,0)
    f.texture:SetDrawLayer("BACKGROUND")

    f.titletext = f:CreateFontString(nil, "ARTWORK")
    f.titletext:SetFont(media.fonts.normal, 9)
    f.titletext:SetText("Threat")
    f.titletext:SetPoint("TOP", f, "TOP", 0, 0)

    -- Add some bars!
    f.bars = Recycler()
    local bar_nums = PixelScale(floor((f:GetHeight()-40)/10))
    for i = 1, bar_nums do
        f.bars[i] = CreateFrame("StatusBar", nil, f)
        f.bars[i]:SetWidth(PixelScale(159))
        f.bars[i]:SetHeight(12.35)
        f.bars[i]:SetMinMaxValues(0, 1)
        f.bars[i]:SetOrientation("HORIZONTAL")
        f.bars[i]:SetStatusBarColor(1, 1, 1, 0.8)
        f.bars[i]:SetStatusBarTexture(media.files.statusbar_c)
        f.bars[i]:SetPoint("TOPLEFT", i == 1 and f or f.bars[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", PixelScale(i == 1 and 2 or 0), PixelScale(i == 1 and -10 or -1))
        f.bars[i]:SetPoint("TOPRIGHT", i == 1 and f or f.bars[i-1], i == 1 and "TOPRIGHT" or "BOTTOMRIGHT", PixelScale(i == 1 and -2 or 0), PixelScale(i == 1 and -10 or -1))
        f.bars[i].lefttext = f.bars[i]:CreateFontString(nil, "ARTWORK")
        f.bars[i].lefttext:SetFont(media.fonts.normal, 9)
        f.bars[i].lefttext:SetPoint("LEFT", f.bars[i], "LEFT", 0, PixelScale(2))
        f.bars[i].lefttext:Show()
        f.bars[i].righttext = f.bars[i]:CreateFontString(nil, "ARTWORK")
        f.bars[i].righttext:SetFont(media.fonts.normal, 9)
        f.bars[i].righttext:SetPoint("RIGHT", f.bars[i], "RIGHT", 0, PixelScale(2))
        SetBarValues(i)
    end

    display_frame:HookScript("OnSizeChanged", function(frame, ...)
        for i = 1, 10 do
            frame.bars[i]:Hide()
        end

        if bar_nums and bar_nums > 0 then
            for i = 1, bar_nums do
                frame.bars[i]:Show()
            end
        end
    end)

    -- XXX: hack_threat_01, Display the panel. We need a better method of handling the showing/hiding of the panel/threat bar system.
    caelPanel_ThreatMeter:Show()
end

local update_delay = 0.5
local function OnUpdate(self, elapsed)
    update_delay = update_delay - elapsed
    if update_delay <= 0 then
        UpdateThreat()
        update_delay = 0.5
    end
end

local function OnEvent(self, event,...)
    if event == "PLAYER_TARGET_CHANGED" then
        display_frame.titletext:SetText(UnitName("target") or "Threat")
        overtake_threat = -1
        for i = 1, 10 do
            display_frame.bars[i]:SetMinMaxValues(0, 1)
            SetBarValues(i)
        end
        if not UnitIsPlayer("target") and UnitCanAttack("player", "target") and UnitHealth("target") > 0 then
            target_okay = true
        else
            target_okay = false
        end
        UpdateThreat()
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        display_frame:SetScript("OnUpdate", nil)
        Recycler(raid_threat)
        raid_threat = Recycler()
        collectgarbage("collect")
        overtake_threat = -1
        top_threat = -1
        warning_played = false
        my_threat = -1
        i_am_tank = false
        for i = 1, 10 do
            display_frame.bars[i]:SetMinMaxValues(0, 1)
            SetBarValues(i)
        end
        return
    elseif event == "PLAYER_REGEN_DISABLED" then
        display_frame:SetScript("OnUpdate", OnUpdate)
        return
    end
end

MakeDisplay()

display_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
display_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
display_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
display_frame:SetScript("OnEvent", OnEvent)
