local _, caelGroupCD = ...

caelGroupCD.eventFrame = CreateFrame("Frame", nil, UIParent)

local pixelScale = caelUI.config.pixel_scale

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
}

local filter = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local floor, format = math.floor, string.format

local bars = {}
local timer = 0

local anchorframe = CreateFrame("Frame", nil, UIParent)
anchorframe:SetSize(145, 12)
anchorframe:SetPoint("RIGHT", pixelScale(-5), 0)
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

local CreateBar = function()
    local bar = CreateFrame("Statusbar", nil, UIParent)
    bar:SetSize(pixelScale(145), pixelScale(12))
    bar:SetStatusBarTexture(caelUI.media.files.statusBarC)
    bar:SetMinMaxValues(0, 100)
    bar.bg = caelUI.media.createBackdrop(bar)
    bar.left = SetFontString(bar, caelUI.media.fonts.NORMAL, 8, "")
    bar.left:SetPoint("LEFT", pixelScale(2), pixelScale(1))
    bar.left:SetJustifyH("LEFT")
    bar.right = SetFontString(bar, caelUI.media.fonts.CUSTOM_NUMBERFONT, 8, "")
    bar.right:SetPoint("RIGHT", pixelScale(-2), pixelScale(1))
    bar.right:SetJustifyH("RIGHT")
    bar.icon = CreateFrame("button", nil, bar)
    bar.icon:SetSize(pixelScale(12), pixelScale(12))
    bar.icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", pixelScale(-5), 0)
    bar.icon.bg = caelUI.media.createBackdrop(bar.icon)

    return bar
end

local UpdateBar = function()
    for i = 1, #bars do
        bars[i]:ClearAllPoints()
        if i == 1 then
            bars[i]:SetPoint("TOPLEFT", anchorframe, 0, 0)
        else
            bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, pixelScale(-5))
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
    bar.left:SetText(unit)
    bar.right:SetText(FormatTime(spells[spellId]))

    if icon then
        bar.icon:SetNormalTexture(icon)
        bar.icon:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    bar.spell = spell
    bar:Show()

    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]

    bar:SetStatusBarColor(color.r, color.g, color.b)

    bar:SetScript("OnUpdate", function(self, elapsed)
        local curTime = GetTime()

        if self.endTime < curTime then
            StopTimer(self)
            return
        end

        self:SetValue(100 - (curTime - self.startTime) / (self.endTime - self.startTime) * 100)
        self.right:SetText(FormatTime(self.endTime - curTime))
    end)

    bar:EnableMouse(true)

    bar:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("RIGHT", self, "LEFT", pixelScale(-23), 0)
        GameTooltip:SetHyperlink(GetSpellLink(spellId))
        GameTooltip:Show()
    end)

    bar:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    bar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            SendChatMessage(format("Cooldown %s %s: %s", self.left:GetText(), self.spell, self.right:GetText()), "RAID")
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
    local _, instanceType = IsInInstance()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if bit.band(sourceFlags, filter) == 0 then return end

        if subEvent == "SPELL_RESURRECT" or subEvent == "SPELL_CAST_SUCCESS" then
            if spells[spellId] then -- and show[instanceType] then
                StartTimer(sourceName, spellId)
            end
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" and instanceType == "arena" then
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