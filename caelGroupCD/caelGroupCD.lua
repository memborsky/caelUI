--[[    $Id:$   ]]

local _, caelGroupCD = ...

caelGroupCD.eventFrame = CreateFrame("Frame", nil, UIParent)

local pixel_scale = caelUI.config.pixel_scale
local media = caelUI.media

local show = {
    raid = true,
    party = true,
    arena = true,
}

local spells = {
    [740]   = 480,  -- Tranquility
    [2825]  = 300,  -- Bloodlust
    [6203]  = 900,  -- Soulstone
    [6346]  = 180,  -- Fear Ward
    [20484] = 600,  -- Rebirth
    [29166] = 180,  -- Innervate
    [32182] = 300,  -- Heroism
    [61999] = 600,  -- Raise Ally
    [64843] = 480,  -- Divine Hymn
    [80353] = 300,  -- Time Warp
    [90355] = 300,  -- Ancient Hysteria
    [95750] = 900,  -- Soulstone res
    [27740] = 1800, -- Reincarnation
}

local filter = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local floor, format, gsub = math.floor, string.format, string.gsub

bars = {}
local timer = 0

local anchorframe = CreateFrame("Frame", nil, UIParent)
anchorframe:SetSize(160, 25)
anchorframe:SetPoint("RIGHT", UIParent, "RIGHT", pixel_scale(-5), 0)
if UIMovableFrames then tinsert(UIMovableFrames, anchorframe) end

local FormatTime = function(t)
    local day, hour, minute = 86400, 3600, 60
    if t >= day then
        return format("%dd", floor(t/day + 0.5)), t % day
    elseif t >= hour then
        return format("%dh", floor(t/hour + 0.5)), t % hour
    elseif t >= minute then
        if t <= minute * 5 then
            return format("%d:%02d", floor(t/60), t % minute), t - floor(t)
        end
        return format("%dm", floor(t/minute + 0.5)), t % minute
    elseif t >= minute / 12 then
        return floor(t + 0.5), (t * 100 - floor(t * 100))/100
    end
    return format("%.1f", t), (t * 100 - floor(t * 100))/100
end

local SetFontString = function(parent, fontName, fontHeight, fontStyle)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(fontName, fontHeight, fontStyle)
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(0.75, -0.75)

    return fs
end

local CreateBar = function(id)
    local bar = CreateFrame("Frame", nil, UIParent)
    bar:SetSize(pixel_scale(150), pixel_scale(25))

    bar.icon = media.create_blank_backdrop(bar)
    bar.icon:SetSize(pixel_scale(30), pixel_scale(30))
    bar.icon:ClearAllPoints()
    bar.icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -pixel_scale(7.5), -pixel_scale(2))
    bar.icon:SetFrameLevel(1)
    bar.icon:SetBackdropColor(0.1, 0.1, 0.1, 1)
    bar.icon:SetBackdropBorderColor(0.6, 0.6, 0.6)

    -- Shadow for the icon
    bar.icon.shadow = media.create_shadow(bar.icon)

    -- The actual spell icon texture.
    bar.icon.texture = bar.icon:CreateTexture(nil, "BORDER")
    bar.icon.texture:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
    bar.icon.texture:SetPoint("TOPLEFT", bar.icon, "TOPLEFT", pixel_scale(2), -pixel_scale(2))
    bar.icon.texture:SetPoint("BOTTOMRIGHT", bar.icon, "BOTTOMRIGHT", -pixel_scale(2), pixel_scale(2))
    bar.icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    bar.statusbar = media.create_blank_backdrop(bar)
    bar.statusbar:SetHeight(pixel_scale(15))
    bar.statusbar:SetWidth(pixel_scale(150))
    bar.statusbar:ClearAllPoints()
    bar.statusbar:SetPoint("BOTTOMLEFT", bar.icon, "BOTTOMRIGHT", pixel_scale(5), 0)
    bar.statusbar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    bar.statusbar:SetBackdropBorderColor(0.6, 0.6, 0.6)

    bar.statusbar.bar = CreateFrame("Statusbar", nil, bar.statusbar)
    bar.statusbar.bar:SetStatusBarTexture(media.files.statusbar_c)
    bar.statusbar.bar:SetMinMaxValues(0, 100)
    bar.statusbar.bar:SetPoint("TOPLEFT", bar.statusbar, "TOPLEFT", pixel_scale(2), -pixel_scale(2))
    bar.statusbar.bar:SetPoint("BOTTOMRIGHT", bar.statusbar, "BOTTOMRIGHT", -pixel_scale(2), pixel_scale(2))

    -- Shadow it up.
    bar.statusbar.shadow = media.create_shadow(bar.statusbar)

    bar.name = SetFontString(bar, media.fonts.normal, 11, "")
    bar.name:ClearAllPoints()
    bar.name:SetPoint("BOTTOMLEFT", bar.statusbar, "TOPLEFT", pixel_scale(1), pixel_scale(3))
    bar.name:SetJustifyH("LEFT")
    bar.name:SetWidth(pixel_scale(165))
    bar.name:SetHeight(pixel_scale(10))

    bar.duration = SetFontString(bar, media.fonts.custom_number, 11, "")
    bar.duration:ClearAllPoints()
    bar.duration:SetPoint("BOTTOMRIGHT", bar.statusbar, "TOPRIGHT", -pixel_scale(1), pixel_scale(3))
    bar.duration:SetJustifyH("RIGHT")
    bar.duration:SetWidth(pixel_scale(165))
    bar.duration:SetHeight(pixel_scale(10))

    return bar
end

local UpdateBar = function()
    for i = 1, #bars do
        bars[i]:ClearAllPoints()
        if i == 1 then
            bars[i]:SetPoint("TOPLEFT", anchorframe, 0, 0)
        else
            bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -pixel_scale(10))
        end
        bars[i].id = i
    end
end

local StopTimer = function(bar)
    bar:SetScript("OnUpdate", nil)
    bar:Hide()

    tremove(bars, bar.id)
    UpdateBar()
end

local StartTimer = function(unit, spellId)
    local bar = CreateBar()
    local spell, rank, icon = GetSpellInfo(spellId)

    bar.endTime = GetTime() + spells[spellId]
    bar.startTime = GetTime()

    bar.name:SetText(gsub(unit, "%s*%-.*", " (*)"))
    bar.duration:SetText(FormatTime(spells[spellId]))

    if icon then
        bar.icon.texture:SetTexture(icon)
        bar.icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    bar.spell = spell
    bar:Show()

    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]

    if color then
        bar.statusbar.bar:SetStatusBarColor(color.r, color.g, color.b)
    else
        bar.statusbar.bar:SetStatusBarColor(0, 0, 0)
    end

    bar:SetScript("OnUpdate", function(self, elapsed)
        local curTime = GetTime()

        if self.endTime < curTime then
            StopTimer(self)
            return
        end

        self.statusbar.bar:SetValue(100 - (curTime - self.startTime) / (self.endTime - self.startTime) * 100)
        self.duration:SetText(FormatTime(self.endTime - curTime))
    end)

    bar:EnableMouse(true)

    bar:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("RIGHT", self, "LEFT", pixel_scale(-23), 0)
        GameTooltip:SetHyperlink(GetSpellLink(spellId))
        GameTooltip:Show()
    end)

    bar:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    bar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            SendChatMessage(format("Cooldown %s %s: %s", self.name:GetText(), self.spell, self.duration:GetText()), "RAID")
        elseif button == "RightButton" then
            StopTimer(self)
        end
    end)

    tinsert(bars, bar)
    UpdateBar()
end

caelGroupCD.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
caelGroupCD.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
caelGroupCD.eventFrame:SetScript("OnEvent", function(_, event, _, subEvent, _, _, sourceName, sourceFlags, _, _, _, _, _, spellId)
    local inInstance, instanceType = IsInInstance()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if bit.band(sourceFlags, filter) == 0 then return end

        if subEvent == "SPELL_RESURRECT" or subEvent == "SPELL_CAST_SUCCESS" then
            if spells[spellId] then -- and show[instanceType] then
                StartTimer(sourceName, spellId)
            end
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" and (not inInstance or instanceType == "arena") then
        for k, v in pairs(bars) do
            StopTimer(v)
        end
    end
end)

SlashCmdList["GroupCD"] = function(msg) 
    StartTimer(UnitName("player"), 20484)
    StartTimer(UnitName("player"), 6203)
    StartTimer(UnitName("player"), 6346)
end
SLASH_GroupCD1 = "/groupcd"