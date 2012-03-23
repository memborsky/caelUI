local _, oUF_Caellian = ...

oUF_Caellian.main = CreateFrame("Frame", nil, UIParent)

local main = oUF_Caellian.main
local config = oUF_Caellian.config

-- Define variables from caelUI or the old system.
local media = caelUI.media
local media_path = media.directory
local PixelScale = caelUI.config.PixelScale

local floor, format, insert, sort = math.floor, string.format, table.insert, table.sort

local normtex = media.files.statusbar_e
local buttonTex = media.files.button_normal
local raidIcons = media.files.raid_icons
local bubbleTex = media_path..[=[miscellaneous\bubbletex]=]
local shaderTex = media_path..[=[miscellaneous\smallshadertex]=]
local highlightTex = media_path..[=[miscellaneous\highlighttex]=]

local font = media.fonts.normal
local fontn = media.fonts.custom_number

local playerClass = caelUI.config.player.class
local playerSpec = GetPrimaryTalentTree()

local manaThreshold = config.manaThreshold

local execThreshold = {
    ["HUNTER"] = 20,
    ["PALADIN"] = 20,
    ["PRIEST"] = {[3] = 25},
    ["ROGUE"] = {[1] = 35},
    ["WARLOCK"] = 25,
    ["WARRIOR"] = 20
}

local healingSpecs = {
    ["PALADIN"] = 1,
    ["PRIEST"]  = 3, -- We check priest against the opposite due to shadow being the only dps spec for priest.
    ["SHAMAN"]  = 3,
    ["DRUID"]   = 3,
}

local auraSize = PixelScale(((230 - (9 * 6)) / 10))

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = PixelScale(-1), left = PixelScale(-1), bottom = PixelScale(-1), right = PixelScale(-1)},
}

local runeloadcolors = {
    [1] = {0.69, 0.31, 0.31},
    [2] = {0.69, 0.31, 0.31},
    [3] = {0.33, 0.59, 0.33},
    [4] = {0.33, 0.59, 0.33},
    [5] = {0.31, 0.45, 0.63},
    [6] = {0.31, 0.45, 0.63},
}

local colors = setmetatable({
    power = setmetatable({
        ["MANA"] = {0.31, 0.45, 0.63},
        ["RAGE"] = {0.69, 0.31, 0.31},
        ["FOCUS"] = {0.71, 0.43, 0.27},
        ["ENERGY"] = {0.65, 0.63, 0.35},
        ["RUNES"] = {0.55, 0.57, 0.61},
        ["RUNIC_POWER"] = {0, 0.82, 1},
        ["AMMOSLOT"] = {0.8, 0.6, 0},
        ["FUEL"] = {0, 0.55, 0.5},
        ["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
        ["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
        ["HOLY_POWER"] = {0.95, 0.93, 0.15},    
        ["SOUL_SHARDS"] = {0.5, 0.0, 0.56},
    }, {__index = oUF.colors.power}),
    runes = setmetatable({
        [1] = {0.69, 0.31, 0.31},
        [2] = {0.33, 0.59, 0.33},
        [3] = {0.31, 0.45, 0.63},
        [4] = {0.84, 0.75, 0.65},
    }, {__index = oUF.colors.runes}),
}, {__index = oUF.colors})

oUF.colors.tapped = {0.55, 0.57, 0.61}

local Dropdown = CreateFrame("Frame", "oUF_CaellianUnitDropDownMenu", UIParent, "UIDropDownMenuTemplate")

UIDropDownMenu_Initialize(Dropdown, function(self)
    local unit = self:GetParent().unit

    if not unit then return end

    local menu, name, id

    if UnitIsUnit(unit, "player") then
        menu = "SELF"
    elseif UnitIsUnit(unit, "vehicle") then
        menu = "VEHICLE"
    elseif UnitIsUnit(unit, "pet") then
        menu = "PET"
    elseif UnitIsPlayer(unit) then
        id = UnitInRaid(unit)
        if id then
            menu = "RAID_PLAYER"
            name = GetRaidRosterInfo(id)
        elseif UnitInParty(unit) then
            menu = "PARTY"
        else
            menu = "PLAYER"
        end
    else
        menu = "TARGET"
        name = RAID_TARGET_ICON
    end

    if menu then
        UnitPopup_ShowMenu(self, menu, unit, name, id)
    end
end, "MENU")

-- Remove "Set Focus" and "Clear Focus" from the right click drop down list.
do
    for index, _ in pairs(UnitPopupMenus) do
        for key, value in pairs(UnitPopupMenus[index]) do
            if value == "SET_FOCUS" or value == "CLEAR_FOCUS" then
                table.remove(UnitPopupMenus[index], key)
            end
        end
    end
end

local menu = function(self)
    Dropdown:SetParent(self)
    ToggleDropDownMenu(1, nil, Dropdown, "cursor", 0, 0)
end

local SetUpAnimGroup = function(self)
    self.anim = self:CreateAnimationGroup("Flash")
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(1)
    self.anim.fadein:SetOrder(2)

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-1)
    self.anim.fadeout:SetOrder(1)
end

local Flash = function(self, duration)
    if not self.anim then
        SetUpAnimGroup(self)
    end

    if not self.anim:IsPlaying() or duration ~= self.anim.fadein:GetDuration() then
        self.anim.fadein:SetDuration(duration)
        self.anim.fadeout:SetDuration(duration)
        self.anim:Play()
    end
end

local StopFlash = function(self)
    if self.anim then
        self.anim:Finish()
    end
end

local SetFontString = function(parent, fontName, fontHeight, fontStyle)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(fontName, fontHeight, fontStyle)
    fs:SetJustifyH("LEFT")
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(0.75, -0.75)
    return fs
end

local ShortValue = function(value)
    if value >= 1e6 then
        return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
    elseif value >= 1e3 or value <= -1e3 then
        return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
    else
        return value
    end
end

local PostUpdateHealth = function(health, unit, min, max)
    local tapped = UnitIsTapped(unit) and not (UnitIsTappedByPlayer(unit) or UnitIsTappedByAllThreatList(unit))
    local dead = UnitIsDead(unit)
    local ghost = UnitIsGhost(unit)
    local disconnected = not UnitIsConnected(unit)
    local class = select(2, UnitClass(unit))

    if oUF.colors.class[class] then
        local color = oUF.colors.class[class]
        health.bg:SetVertexColor(color[1], color[2], color[3])
    else
        health.bg:SetVertexColor(0.3, 0.3, 0.3)
    end
    health:SetStatusBarColor(0, 0, 0)

    if tapped then
        health:SetStatusBarColor(unpack(oUF.colors.tapped))
    elseif disconnnected or dead or ghost then
        health:SetValue(max)
        
        if disconnnected then
            health:SetStatusBarColor(0.1, 0.1, 0.1)
            health.value:SetText("|cffD7BEA5".."Offline".."|r")
        elseif(ghost) then
            health:SetStatusBarColor(1, 1, 1)
            health.value:SetText("|cffD7BEA5".."Ghost".."|r")
        elseif(dead) then
            health:SetStatusBarColor(1, 0, 0)
            health.value:SetText("|cffD7BEA5".."Dead".."|r")
        end
    else
        --local r, g, b = oUF.ColorGradient(min, max, 0.78, 0.31, 0.31, 0.71, 0.43, 0.27, 0.17, 0.17, 0.24)
        local r, g, b = oUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)

        health:SetValue(min)
        
        if min ~= max then
            if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
                health.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
            elseif unit == "target" then
                health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
            elseif health:GetParent():GetName():match("oUF_Party") or health:GetParent():GetName():match("oUF_Raid") then
                health.value:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, ShortValue(floor(min - max)))
            else
                health.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
            end
        else
            if unit ~= "player" and unit ~= "pet" then
                health.value:SetText("|cff559655"..ShortValue(max).."|r")
            else
                health.value:SetText("|cff559655"..max.."|r")
            end
        end
    end
end

local PostUpdateName = function(self, power)
    self.Info:ClearAllPoints()
    if power.value:GetText() then
        self.Info:SetPoint("TOP", 0, PixelScale(-3.5))
    else
        self.Info:SetPoint("TOPLEFT", PixelScale(3.5), PixelScale(-3.5))
    end
end

local PreUpdatePower = function(power, unit)
    local _, pType = UnitPowerType(unit)

    local color = colors.power[pType]
    if color then
        power:SetStatusBarColor(color[1], color[2], color[3])
    end
end

local PostUpdatePower = function(power, unit, min, max)

    local self = power:GetParent()

    local pType, pToken = UnitPowerType(unit)
    local color = colors.power[pToken]

    if color then
        power.value:SetTextColor(color[1], color[2], color[3])
    end

    if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
        local class = select(2, UnitClass(unit))
        local color = UnitIsPlayer(unit) and oUF.colors.class[class] or {0.84, 0.75, 0.65}

        power:SetValue(0)
        power.bg:SetVertexColor(color[1], color[2], color[3])
    end

    if unit ~= "player" and unit ~= "pet" and unit ~= "target" then return end

    if min == 0 then
        power.value:SetText()
    elseif not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
        power.value:SetText()
    elseif UnitIsDead(unit) or UnitIsGhost(unit) then
        power.value:SetText()
    elseif min == max and (pType == 2 or pType == 3 and pToken ~= "POWER_TYPE_PYRITE") then
        power.value:SetText()
    else
        if min ~= max then
            if pType == 0 then
                if unit == "target" then
                    power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), ShortValue(max - (max - min)))
                elseif unit == "player" and power:GetAttribute("normalUnit") == "pet" or unit == "pet" then
                    power.value:SetFormattedText("%d%%", floor(min / max * 100))
                else
                    power.value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(min / max * 100), max - (max - min))
                end
            else
                power.value:SetText(max - (max - min))
            end
        else
            if unit == "pet" or unit == "target" then
                power.value:SetText(ShortValue(min))
            else
                power.value:SetText(min)
            end
        end
    end
    if self.Info then
        if unit == "pet" or unit == "target" then PostUpdateName(self, power) end
    end
end

local execDelay = 0
local UpdateExecLevel = function(self, elapsed)
    execDelay = execDelay + elapsed
    if self.parent.unit ~= "target" or execDelay < 0.2 then return end

    execDelay = 0

    local percExec = UnitHealth("target") / UnitHealthMax("target") * 100

    local threshold = nil

    if (playerClass == "PRIEST" or playerClass == "ROGUE") and execThreshold[playerClass][playerSpec] then
        threshold = execThreshold[playerClass][playerSpec]
    elseif execThreshold[playerClass] then
        threshold = execThreshold[playerClass]
    end

    if threshold and type(threshold) ~= "table" then
        if percExec <= threshold and not UnitIsDeadOrGhost("target") then
            self.WarningMsg:SetText("|cffaf5050FINISH IT|r")
            Flash(self, 0.3)
        else
            self.WarningMsg:SetText()
            StopFlash(self)
        end
    end
end

local manaDelay = 0
local UpdateManaLevel = function(self, elapsed)
    manaDelay = manaDelay + elapsed
    if self.parent.unit ~= "player" or manaDelay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end

    manaDelay = 0

    local percMana = UnitMana("player") / UnitManaMax("player") * 100

    if percMana <= manaThreshold then
        self.WarningMsg:SetText("|cffaf5050LOW MANA|r")
        Flash(self, 0.3)
    else
        self.WarningMsg:SetText()
        StopFlash(self)
    end
end

local UpdateDruidMana = function(self)
    if self.unit ~= "player" then return end

    local num, str = UnitPowerType("player")
    if num ~= 0 then
        local min, max = UnitPower("player", 0), UnitPowerMax("player", 0)

        local percMana = min / max * 100
        if percMana <= manaThreshold then
            self.FlashInfo.WarningMsg:SetText("|cffaf5050LOW MANA|r")
            Flash(self.FlashInfo, 0.3)
        else
            self.FlashInfo.WarningMsg:SetText()
            StopFlash(self.FlashInfo)
        end

        if min ~= max then
            if self.Power.value:GetText() then
                self.DruidMana:SetPoint("TOPLEFT", self.Power.value, "TOPRIGHT", PixelScale(1), 0)
                self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
            else
                self.DruidMana:SetPoint("TOPLEFT", PixelScale(3.5), PixelScale(-3.5))
                self.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
            end
        else
            self.DruidMana:SetText()
        end

        self.DruidMana:SetAlpha(1)
    else
        self.DruidMana:SetAlpha(0)
    end
end

local UpdateCPoints = function(self, event, unit)
    if unit == PlayerFrame.unit and unit ~= self.CPoints.unit then
        self.CPoints.unit = unit
    end
end

local PostCastStart = function(castbar, unit, name, rank, castid)
    castbar.channeling = false
    if unit == "vehicle" then unit = "player" end

    if unit == "player" then
        local latency = GetTime() - (castbar.castSent or 0)
        latency = latency > castbar.max and castbar.max or latency

        if latency then
            if castbar.Latency then
                castbar.Latency:SetText(("%d ms"):format(latency * 1e3))
            end

            if castbar.SafeZone then
                castbar.SafeZone:SetWidth(PixelScale(castbar:GetWidth() * latency / castbar.max))
                castbar.SafeZone:ClearAllPoints()
                castbar.SafeZone:SetPoint("TOPRIGHT")
                castbar.SafeZone:SetPoint("BOTTOMRIGHT")
            end
        end
    end

    if castbar.interrupt and UnitCanAttack("player", unit) then
        castbar:SetStatusBarColor(0.69, 0.31, 0.31)
    else
        castbar:SetStatusBarColor(0.55, 0.57, 0.61)
    end
end

local PostChannelStart = function(castbar, unit, name)
    castbar.channeling = true
    if unit == "vehicle" then unit = "player" end

    if unit == "player" then
        local latency = GetTime() - (castbar.castSent or 0)
        latency = latency > castbar.max and castbar.max or latency
        
        if castbar.Latency then
            castbar.Latency:SetText(("%d ms"):format(latency * 1e3))
        end
        
        castbar.SafeZone:SetWidth(PixelScale(castbar:GetWidth() * latency / castbar.max))
        castbar.SafeZone:ClearAllPoints()
        castbar.SafeZone:SetPoint("TOPLEFT")
        castbar.SafeZone:SetPoint("BOTTOMLEFT")
    end

    if castbar.interrupt and UnitCanAttack("player", unit) then
        castbar:SetStatusBarColor(0.69, 0.31, 0.31)
    else
        castbar:SetStatusBarColor(0.55, 0.57, 0.61)
    end
end

local CustomCastTimeText = function(self, duration)
    self.Time:SetText(("%.1f / %.2f"):format(self.channeling and duration or self.max - duration, self.max))
end

local CustomCastDelayText = function(self, duration)
    self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

local FormatTime = function(s)
    local day, hour, minute = 86400, 3600, 60
    if s >= day then
        return format("%dd", floor(s/day + 0.5)), s % day
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5)), s % hour
    elseif s >= minute then
        if s <= minute * 5 then
            return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
        end
        return format("%dm", floor(s/minute + 0.5)), s % minute
    elseif s >= minute / 12 then
        return floor(s + 0.5), (s * 100 - floor(s * 100))/100
    end
    return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local CreateAuraTimer = function(self, elapsed)
    if self.timeLeft then
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            if not self.first then
                self.timeLeft = self.timeLeft - self.elapsed
            else
                self.timeLeft = self.timeLeft - GetTime()
                self.first = false
            end
            if self.timeLeft > 0 then
                local time = FormatTime(self.timeLeft)
                self.remaining:SetText(time)
                if self.timeLeft < 5 then
                    self.remaining:SetTextColor(0.69, 0.31, 0.31)
                else
                    self.remaining:SetTextColor(0.84, 0.75, 0.65)
                end
            else
                self.remaining:Hide()
                self:SetScript("OnUpdate", nil)
            end
            self.elapsed = 0
        end
    end
end

local HideAura = function(self)
    if self.unit == "player" then
        if config.noPlayerAuras then
            self.Buffs:Hide()
            -- self.Debuffs:Hide()
        else
            local BuffFrame = _G["BuffFrame"]
            BuffFrame:UnregisterEvent"UNIT_AURA"
            BuffFrame:Hide()
            BuffFrame = _G["TemporaryEnchantFrame"]
            BuffFrame:Hide()
        end
    elseif self.unit == "pet" and config.noPetAuras or self.unit == "targettarget" and config.noToTAuras then
        self.Auras:Hide()
    elseif self.unit == "target" and config.noTargetAuras then
        self.Buffs:Hide()
        self.Debuffs:Hide()
    end
end

local PostCreateAura = function(auras, button)
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    button.backdrop = CreateFrame("Frame", nil, button)
    button.backdrop:SetPoint("TOPLEFT", PixelScale(-5), PixelScale(5))
    button.backdrop:SetPoint("BOTTOMRIGHT", PixelScale(5), PixelScale(-5))
    button.backdrop:SetBackdrop(media.border_table)
    button.backdrop:SetBackdropBorderColor(0, 0, 0)

    button.gloss = CreateFrame("Frame", nil, button)
    button.gloss:SetPoint("TOPLEFT", PixelScale(-3), PixelScale(3))
    button.gloss:SetPoint("BOTTOMRIGHT", PixelScale(3), PixelScale(-3))
    button.gloss:SetBackdrop({
        bgFile = media.files.button_gloss,
        insets = {top = PixelScale(-1), left = PixelScale(-1), bottom = PixelScale(-1), right = PixelScale(-1)},
    })
    button.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0.5)

    button.count:SetPoint("BOTTOMRIGHT", PixelScale(1), PixelScale(1.5))
    button.count:SetFont(fontn, 8, "OUTLINE")
    button.count:SetTextColor(0.84, 0.75, 0.65)
    button.count:SetJustifyH("RIGHT")

    button.cd.noOCC = true
    button.cd.noCooldownCount = true
    auras.disableCooldown = true

    button.overlay:SetTexture(buttonTex)
    button.overlay:SetPoint("TOPLEFT", PixelScale(-3.5), PixelScale(3.5))
    button.overlay:SetPoint("BOTTOMRIGHT", PixelScale(3.5), PixelScale(-3.5))
    button.overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay.Hide = function(self) end

    button.remaining = SetFontString(button.backdrop, fontn, 8, "OUTLINE")
    button.remaining:SetPoint("TOP", 0, PixelScale(-2))
end

local CreateEnchantTimer = function(self, icons)
    for i = 1, 3 do
        local icon = icons[i]
        if icon.expTime then
            icon.timeLeft = icon.expTime - GetTime()
            icon.remaining:Show()
        else
            icon.remaining:Hide()
        end
        icon:SetScript("OnUpdate", CreateAuraTimer)
    end
end

local PostUpdateIcon

do
    local playerUnits = {
        player = true,
        pet = true,
        vehicle = true,
    }

    PostUpdateIcon = function(icons, unit, icon, index, offset)
        local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
        if playerUnits[unitCaster] then
            if icon.isDebuff then
                icon.overlay:SetVertexColor(0.69, 0.31, 0.31)
                icon.gloss:SetBackdropColor(0.69, 0.31, 0.31, 0.5)
            else
                icon.overlay:SetVertexColor(0.33, 0.59, 0.33)
                icon.gloss:SetBackdropColor(0.33, 0.59, 0.33, 0.5)
            end
        else
            if UnitIsEnemy("player", unit) then
                if icon.isDebuff then
                    icon.icon:SetDesaturated(true)
                end
            end
            icon.overlay:SetVertexColor(0.5, 0.5, 0.5)
            icon.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0.5)
        end

        if duration and duration > 0 then
            icon.remaining:Show()
            icon.timeLeft = expirationTime
            icon:SetScript("OnUpdate", CreateAuraTimer)
        else
            icon.remaining:Hide()
            icon.timeLeft = math.huge
            icon:SetScript("OnUpdate", nil)
        end

        icon.first = true
    end
end

local CustomFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, expiration, caster)

    --    if not UnitPlayerControlled(caster) and not UnitIsPlayer(caster) then
    --        return true
    --    end

    if UnitCanAttack("player", unit) then
        local casterClass

        if caster then
            casterClass = select(2, UnitClass(caster))
        end

        if not icon.isDebuff or (casterClass and casterClass == playerClass) then
            return true
        end
    else
        local isPlayer

        if caster == "player" or caster == "pet" or caster == "vehicle" then
            isPlayer = true
        end

        if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
            icon.isPlayer = isPlayer
            return true
        end
    end
end

local SortAura = function(a, b)
    return (a.timeLeft and a.timeLeft) > (b.timeLeft and b.timeLeft)
end

local PreSetPosition = function(auras)
    sort(auras, SortAura)
end

local SetStyle = function(self, unit)

    local unitInRaid = self:GetParent():GetName():match("oUF_Raid")
    local unitInParty = self:GetParent():GetName():match("oUF_Party") -- unit and unit:match("party%d")
    local unitIsPartyPet = self:GetAttribute("unitsuffix") == "pet" -- unit and unit:match("partypet%d")
    local unitIsPartyTarget = self:GetAttribute("unitsuffix") == "target" -- unit and unit:match("party%dtarget")
    local unitClass = select(2, UnitClass(unit))

    self.menu = menu
    self.colors = colors
    self:RegisterForClicks("AnyUp")

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    self:HookScript("OnShow", function(frame)
        for _, v in ipairs(frame.__elements) do
            v(frame, "UpdateElement", frame.unit)
        end
    end)

    self.FrameBackdrop = CreateFrame("Frame", nil, self)
    self.FrameBackdrop:SetFrameLevel(self:GetFrameLevel() - 1)
    self.FrameBackdrop:SetPoint("TOPLEFT", self, PixelScale(-3), PixelScale(3))
    self.FrameBackdrop:SetFrameStrata("MEDIUM")

    if unit == "player" and (playerClass == "DEATHKNIGHT" or (playerClass == "DRUID" and GetPrimaryTalentTree() == 1) or (IsAddOnLoaded("oUF_TotemBar") and playerClass == "SHAMAN")) then
        self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, PixelScale(3), PixelScale(-12))
    else
        self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, PixelScale(3), PixelScale(-3))
    end

    self.Health = CreateFrame("StatusBar", self:GetName().."_Health", self)
    self.Health:SetHeight((unit == "player" or unit == "target") and PixelScale(30) or unitInRaid and PixelScale(20) or unitIsPartyPet and PixelScale(10) or PixelScale(16))
    self.Health:SetPoint("TOPLEFT", PixelScale(1), PixelScale(-1))
    self.Health:SetPoint("TOPRIGHT", PixelScale(-1), PixelScale(-1))
    self.Health:SetStatusBarTexture(normtex)
    self.Health:SetBackdrop(backdrop)
    self.Health:SetStatusBarColor(0, 0, 0)
    self.Health:SetBackdropColor(0, 0, 0)

    self.Health.frequentUpdates = true
    self.Health.Smooth = true

    self.Health.PostUpdate = PostUpdateHealth

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetTexture(normtex)

    self.Health.value = SetFontString(self.Health, font,(unit == "player" or unit == "target") and 11 or 9)
    if unitInRaid then
        self.Health.value:SetPoint("BOTTOMRIGHT", PixelScale(-1), PixelScale(2))
    elseif unitIsPartyPet then
        self.Health.value:SetPoint("RIGHT", PixelScale(-1), PixelScale(1))
    else
        self.Health.value:SetPoint("TOPRIGHT", PixelScale(-3.5), PixelScale(-3.5))
    end

    if not unitIsPartyPet then
        self.Power = CreateFrame("StatusBar", self:GetName().."_Power", self)
        self.Power:SetHeight((unit == "player" or unit == "target") and PixelScale(15) or PixelScale(5))
        if unitInRaid then
            self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, PixelScale(-1))
            self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, PixelScale(-1))
        else
            self.Power:SetPoint("BOTTOMLEFT", PixelScale(1), PixelScale(1))
            self.Power:SetPoint("BOTTOMRIGHT", PixelScale(-1), PixelScale(1))
        end
        self.Power:SetStatusBarTexture(normtex)
        self.Power:SetBackdrop(backdrop)
        self.Power:SetBackdropColor(0, 0, 0)

        self.Power.colorPower = unit == "player" or unit == "pet" and true
        self.Power.colorClass = true
        self.Power.colorReaction = true

        self.Power.frequentUpdates = true
        self.Power.Smooth = true

        self.Power.PreUpdate = PreUpdatePower
        self.Power.PostUpdate = PostUpdatePower

        self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
        self.Power.bg:SetAllPoints()
        self.Power.bg:SetTexture(normtex)
        self.Power.bg.multiplier = 0.5

        self.Power.value = SetFontString(self.Health, font, (unit == "player" or unit == "target") and PixelScale(11) or PixelScale(9))
        self.Power.value:SetPoint("TOPLEFT", PixelScale(3.5), PixelScale(-3.5))
    end

    if unitInRaid then
        self.Nameplate = CreateFrame("Frame", nil, self.FrameBackdrop)
        self.Nameplate:SetFrameLevel(self:GetFrameLevel() + 1)
        self.Nameplate:SetPoint("TOPLEFT", self, 0, PixelScale(-28))
        self.Nameplate:SetPoint("BOTTOMRIGHT", self)
        self.Nameplate:SetBackdrop {
            bgFile = media.files.background,
            edgeFile = media.files.background,
            tile = false, tileSize = 0, edgeSize = PixelScale(1),
            insets = {left = 0, right = 0, top = 1, bottom = 0}
        }
        self.Nameplate:SetBackdropColor(0.15, 0.15, 0.15)
        self.Nameplate:SetBackdropBorderColor(0, 0, 0)
    end

    if unit ~= "player" then
        self.Info = SetFontString(unitInRaid and self.Nameplate or self.Health, font, unit == "target" and 11 or 9)
        if unitInRaid then
            self.Info:SetPoint("BOTTOM", self, 0, PixelScale(3))
            self:Tag(self.Info, "[caellian:getnamecolor][caellian:nameshort]")
        elseif unit == "target" then
            self.Info:SetPoint("TOPLEFT", PixelScale(3.5), PixelScale(-3.5))
            self:Tag(self.Info, "[caellian:getnamecolor][caellian:namelong] [caellian:diffcolor][level] [shortclassification]")
        elseif unit == pet then
            self.Info:SetPoint("LEFT", PixelScale(1), PixelScale(1))
            self:Tag(self.Info, "[caellian:getnamecolor][caellian:nameshort]")
        else
            self.Info:SetPoint("LEFT", PixelScale(1), PixelScale(1))
            self:Tag(self.Info, "[caellian:getnamecolor][caellian:namemedium]")
        end
    end

    if unit == "player" then
        self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
        self.Combat:SetSize(PixelScale(12), PixelScale(12))
        self.Combat:SetPoint("TOP", 0, PixelScale(-3.5))
        self.Combat:SetTexture(bubbleTex)
        self.Combat:SetVertexColor(0.69, 0.31, 0.31)

        if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
            self.Resting = self.Power:CreateTexture(nil, "OVERLAY")
            self.Resting:SetSize(PixelScale(18), PixelScale(18))
            self.Resting:SetPoint("BOTTOMLEFT", PixelScale(-8.5), PixelScale(-8.5))
            self.Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
            self.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
        end

        self.MyHealBar = CreateFrame("StatusBar", nil, self.Health)
        self.MyHealBar:SetWidth(PixelScale(230))
        self.MyHealBar:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
        self.MyHealBar:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
        self.MyHealBar:SetStatusBarTexture(normtex)
        self.MyHealBar:SetStatusBarColor(0.33, 0.59, 0.33, 0.75)

        self.OtherHealBar = CreateFrame("StatusBar", nil, self.Health)
        self.OtherHealBar:SetWidth(PixelScale(230))
        self.OtherHealBar:SetPoint("TOPLEFT", self.MyHealBar:GetStatusBarTexture(), "TOPRIGHT")
        self.OtherHealBar:SetPoint("BOTTOMLEFT", self.MyHealBar:GetStatusBarTexture(), "BOTTOMRIGHT")
        self.OtherHealBar:SetStatusBarTexture(normtex)
        self.OtherHealBar:SetStatusBarColor(0.33, 0.59, 0.33, 0.75)

        self.HealPrediction = {
            myBar = self.MyHealBar,
            otherBar = self.OtherHealBar,
            maxOverflow = 1,
        }

        if IsAddOnLoaded("oUF_WeaponEnchant") then
            self.Enchant = CreateFrame("Frame", nil, self)
            self.Enchant.size = auraSize
            self.Enchant:SetWidth(PixelScale((self.Enchant.size * 3) + 9))
            self.Enchant:SetHeight(self.Enchant.size)
            self.Enchant:SetPoint("TOPLEFT", self, "TOPRIGHT", PixelScale(9), PixelScale(-1))
            self.Enchant.spacing = 6
            self.Enchant.initialAnchor = "TOPLEFT"
            self.Enchant["growth-x"] = "RIGHT"
            self.PostCreateEnchantIcon = PostCreateAura
            self.PostUpdateEnchantIcons = CreateEnchantTimer
        end

        if playerClass == "DEATHKNIGHT" then
            self.Runes = CreateFrame("Frame", nil, self)
            self.Runes:SetPoint("TOPLEFT", self, "BOTTOMLEFT", PixelScale(1), PixelScale(-1.5))
            self.Runes:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", PixelScale(-1), PixelScale(-1.5))
            self.Runes:SetHeight(PixelScale(7))
            self.Runes:SetBackdrop(backdrop)
            self.Runes:SetBackdropColor(0, 0, 0)

            for i = 1, 6 do
                self.Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self.Runes)
                self.Runes[i]:SetSize(PixelScale(((230 - 5) / 6)), PixelScale(7))
                if (i == 1) then
                    self.Runes[i]:SetPoint("LEFT")
                else
                    self.Runes[i]:SetPoint("LEFT", self.Runes[i-1], "RIGHT", PixelScale(1), 0)
                end
                self.Runes[i]:SetStatusBarTexture(normtex)
                self.Runes[i]:SetStatusBarColor(unpack(runeloadcolors[i]))

                self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BORDER")
                self.Runes[i].bg:SetAllPoints()
                self.Runes[i].bg:SetTexture(normtex)
                self.Runes[i].bg.multiplier = 0.5
            end
        end

        -- Make local check on SHAMAN class first before we make remote call to IsAddOnLoaded.
        if playerClass == "SHAMAN" and IsAddOnLoaded("oUF_TotemBar") then
            self.TotemBar = {}
            self.TotemBar.Destroy = true
            for i = 1, 4 do
                self.TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
                self.TotemBar[i]:SetSize(PixelScale(((230 - 3) / 4)), PixelScale(7))
                if (i == 1) then
                    self.TotemBar[i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", PixelScale(1), PixelScale(-1.5))
                else
                    self.TotemBar[i]:SetPoint("LEFT", self.TotemBar[i-1], "RIGHT", PixelScale(1), 0)
                end
                self.TotemBar[i]:SetStatusBarTexture(normtex)
                self.TotemBar[i]:SetMinMaxValues(0, 1)

                self.TotemBar[i]:SetBackdrop(backdrop)
                self.TotemBar[i]:SetBackdropColor(0, 0, 0)

                self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
                self.TotemBar[i].bg:SetAllPoints()
                self.TotemBar[i].bg:SetTexture(normtex)
                self.TotemBar[i].bg.multiplier = 0.5
            end
        end

        if playerClass == "PALADIN" then
            self.HolyPower = CreateFrame("Frame", nil, self.Power)
            self.HolyPower:SetAllPoints()
            for i = 1, 3 do
                self.HolyPower[i] = self.HolyPower:CreateTexture(nil, "OVERLAY")
                self.HolyPower[i]:SetSize(PixelScale(12), PixelScale(12))
                self.HolyPower[i]:SetTexture(bubbleTex)
                if (i == 1) then
                    self.HolyPower[i]:SetPoint("LEFT", PixelScale(3.5), PixelScale(-9))
                    self.HolyPower[i]:SetVertexColor(0.69, 0.31, 0.31)
                else
                    self.HolyPower[i]:SetPoint("LEFT", self.HolyPower[i-1], "RIGHT", PixelScale(1))
                end
            end
            self.HolyPower[2]:SetVertexColor(0.65, 0.63, 0.35)
            self.HolyPower[3]:SetVertexColor(0.33, 0.59, 0.33)
        end

        if playerClass == "WARLOCK" then
            self.SoulShards = CreateFrame("Frame", nil, self.Power)
            self.SoulShards:SetAllPoints()
            for i = 1, 3 do
                self.SoulShards[i] = self.SoulShards:CreateTexture(nil, "OVERLAY")
                self.SoulShards[i]:SetSize(PixelScale(12), PixelScale(12))
                self.SoulShards[i]:SetTexture(bubbleTex)
                if (i == 1) then
                    self.SoulShards[i]:SetPoint("LEFT", PixelScale(3.5), PixelScale(-9))
                    self.SoulShards[i]:SetVertexColor(0.69, 0.31, 0.31)
                else
                    self.SoulShards[i]:SetPoint("LEFT", self.SoulShards[i-1], "RIGHT", PixelScale(1))
                end
            end
            self.SoulShards[2]:SetVertexColor(0.65, 0.63, 0.35)
            self.SoulShards[3]:SetVertexColor(0.33, 0.59, 0.33)
        end

        --[[
        if playerClass == "DRUID" then
            CreateFrame("Frame"):SetScript("OnUpdate", function() UpdateDruidMana(self) end)
            self.DruidMana = SetFontString(self.Health, font, 11)
            self.DruidMana:SetTextColor(1, 0.49, 0.04)

            self.EclipseBar = CreateFrame("Frame", nil, self)
            self.EclipseBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", PixelScale(1), PixelScale(-1.5))
            self.EclipseBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", PixelScale(-1), PixelScale(-1.5))
            self.EclipseBar:SetHeight(PixelScale(7))
            self.EclipseBar:SetBackdrop(backdrop)
            self.EclipseBar:SetBackdropColor(0, 0, 0)

            self.EclipseBar.LunarBar = CreateFrame("StatusBar", nil, self.EclipseBar)
            self.EclipseBar.LunarBar:SetPoint("LEFT")
            self.EclipseBar.LunarBar:SetSize(PixelScale(228), PixelScale(7))
            self.EclipseBar.LunarBar:SetStatusBarTexture(normtex)
            self.EclipseBar.LunarBar:SetStatusBarColor(0.34, 0.1, 0.86)

            self.EclipseBar.SolarBar = CreateFrame("StatusBar", nil, self.EclipseBar)
            self.EclipseBar.SolarBar:SetPoint("LEFT", self.EclipseBar.LunarBar:GetStatusBarTexture(), "RIGHT", PixelScale(1), 0)
            self.EclipseBar.SolarBar:SetSize(PixelScale(228), PixelScale(7))
            self.EclipseBar.SolarBar:SetStatusBarTexture(normtex)
            self.EclipseBar.SolarBar:SetStatusBarColor(0.95, 0.73, 0.15)
        end
        --]]
    end

    if unit == "pet" or unit == "targettarget" then
        self.Auras = CreateFrame("Frame", nil, self)
        self.Auras.size = auraSize
        self.Auras:SetWidth(PixelScale((self.Auras.size * 8) + 42))
        self.Auras:SetHeight(self.Auras.size)
        self.Auras.spacing = 6
        self.Auras.numBuffs = 16
        self.Auras.numDebuffs = 16
        self.Auras.gap = true
        self.Auras.PostCreateIcon = PostCreateAura
        self.Auras.PostUpdateIcon = PostUpdateIcon
        if unit == "pet" then
            self.Auras:SetPoint("TOPRIGHT", self, "TOPLEFT", PixelScale(-9), PixelScale(-1))
            self.Auras.initialAnchor = "TOPRIGHT"
            self.Auras["growth-x"] = "LEFT"
        else
            self.Auras:SetPoint("TOPLEFT", self, "TOPRIGHT", PixelScale(9), PixelScale(-1))
            self.Auras.initialAnchor = "TOPLEFT"
        end
    end

    if unit == "player" or unit == "target" then
        self.Portrait = CreateFrame("PlayerModel", nil, self)
        self.Portrait:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", PixelScale(7.5), PixelScale(10))
        self.Portrait:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", PixelScale(-7.5), PixelScale(-7.5))
        self.Portrait:SetFrameLevel(self:GetFrameLevel() + 3)
        self.Portrait:SetBackdrop(backdrop)
        self.Portrait:SetBackdropColor(0, 0, 0)

        self.Overlay = CreateFrame("StatusBar", self:GetName().."_Overlay", self)
        self.Overlay:SetFrameLevel(self.Portrait:GetFrameLevel() + 1)
        self.Overlay:SetParent(self.Portrait)
        self.Overlay:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", PixelScale(7.5), PixelScale(10))
        self.Overlay:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", PixelScale(-7.5), PixelScale(-7.5))
        self.Overlay:SetStatusBarTexture(shaderTex)
        self.Overlay:SetStatusBarColor(0.1, 0.1, 0.1, 0.75)

        local checkDelay = 5
        local needChecking = true

        self.FlashInfo = CreateFrame("Frame", "FlashInfo", self.Overlay)
        self.FlashInfo.parent = self
        self.FlashInfo:SetToplevel(true)
        self.FlashInfo:SetAllPoints()

        --oUF_Caellian_player.FlashInfo:SetScript("OnUpdate", UpdateManaLevel)
        self.FlashInfo:SetScript("OnUpdate", UpdateManaLevel)

        self.FlashInfo.WarningMsg = SetFontString(self.FlashInfo, fontn, 14, "OUTLINE")
        self.FlashInfo.WarningMsg:SetPoint("TOP", 0, PixelScale(-3.5))

        local FinishIt_OnUpdate = function(self, elapsed)
            if checkDelay then
                checkDelay = checkDelay - elapsed
                if checkDelay <= 0 then
                    playerSpec = GetPrimaryTalentTree()
                    self:SetScript("OnUpdate", nil)
                end
            end
        end

        main:RegisterEvent("PLAYER_ENTERING_WORLD")
        main:SetScript("OnEvent", function(self, event)
            if needChecking then
                main:SetScript("OnUpdate", FinishIt_OnUpdate)
                oUF_Caellian_target.FlashInfo:SetScript("OnUpdate", UpdateExecLevel)
                needChecking = nil
            end
        end)

        self.Buffs = CreateFrame("Frame", nil, self)
        self.Buffs.size = auraSize
        self.Buffs:SetWidth(PixelScale((self.Buffs.size * 8) + 42))
        self.Buffs:SetHeight(self.Buffs.size)
        self.Buffs.spacing = 6
        self.Buffs.PostSetPosition = PreSetPosition
        self.Buffs.PostCreateIcon = PostCreateAura
        self.Buffs.PostUpdateIcon = PostUpdateIcon

        self.Debuffs = CreateFrame("Frame", nil, self)
        self.Debuffs.size = auraSize
        self.Debuffs:SetWidth(PixelScale(230))
        self.Debuffs:SetHeight(self.Debuffs.size)
        self.Debuffs.spacing = 6
        self.Debuffs.PostSetPosition = PreSetPosition
        self.Debuffs.PostCreateIcon = PostCreateAura
        self.Debuffs.PostUpdateIcon = PostUpdateIcon
        if unit == "player" then
            self.Buffs:SetPoint("TOPRIGHT", self, "TOPLEFT", PixelScale(-9), PixelScale(-1))
            self.Buffs.initialAnchor = "TOPRIGHT"
            self.Buffs["growth-x"] = "LEFT"
            self.Buffs["growth-y"] = "DOWN"
            self.Buffs.filter = true

            self.Debuffs.initialAnchor = "TOPLEFT"
            self.Debuffs["growth-y"] = "DOWN"
            if playerClass == "DEATHKNIGHT" or IsAddOnLoaded("oUF_TotemBar") and playerClass == "SHAMAN" then
                self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, PixelScale(-15))
            else
                self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, PixelScale(-7.5))
            end

        elseif unit == "target" then
            self.Buffs:SetPoint("TOPLEFT", self, "TOPRIGHT", PixelScale(9), PixelScale(-1))
            self.Buffs.initialAnchor = "TOPLEFT"
            self.Buffs["growth-y"] = "DOWN"

            self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, PixelScale(-8))
            self.Debuffs.initialAnchor = "TOPLEFT"
            self.Debuffs["growth-y"] = "DOWN"
            self.Debuffs.onlyShowPlayer = false
            if not config.noClassDebuffs then
                self.Debuffs.CustomFilter = CustomFilter
            end

            self.CPoints = CreateFrame("Frame", nil, self.Power)
            self.CPoints:SetAllPoints()
            self.CPoints.unit = PlayerFrame.unit
            for i = 1, 5 do
                self.CPoints[i] = self.CPoints:CreateTexture(nil, "ARTWORK")
                self.CPoints[i]:SetSize(PixelScale(12), PixelScale(12))
                self.CPoints[i]:SetTexture(bubbleTex)
                if i == 1 then
                    self.CPoints[i]:SetPoint("LEFT", PixelScale(3.5), PixelScale(-9))
                    self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
                else
                    self.CPoints[i]:SetPoint("LEFT", self.CPoints[i-1], "RIGHT", PixelScale(1))
                end
            end
            self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
            self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
            self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
            self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
            self:RegisterEvent("UNIT_COMBO_POINTS", UpdateCPoints)
        end

        self.CombatFeedbackText = SetFontString(self.Overlay, fontn, 14, "OUTLINE")
        self.CombatFeedbackText:SetPoint("CENTER")
        self.CombatFeedbackText.colors = {
            DAMAGE = {0.69, 0.31, 0.31},
            CRUSHING = {0.69, 0.31, 0.31},
            CRITICAL = {0.69, 0.31, 0.31},
            GLANCING = {0.69, 0.31, 0.31},
            STANDARD = {0.84, 0.75, 0.65},
            IMMUNE = {0.84, 0.75, 0.65},
            ABSORB = {0.84, 0.75, 0.65},
            BLOCK = {0.84, 0.75, 0.65},
            RESIST = {0.84, 0.75, 0.65},
            MISS = {0.84, 0.75, 0.65},
            HEAL = {0.33, 0.59, 0.33},
            CRITHEAL = {0.33, 0.59, 0.33},
            ENERGIZE = {0.31, 0.45, 0.63},
            CRITENERGIZE = {0.31, 0.45, 0.63},
        }

        self.Status = SetFontString(self.Overlay, font, 18, "OUTLINE")
        self.Status:SetPoint("CENTER", 0, PixelScale(2))
        self.Status:SetTextColor(0.69, 0.31, 0.31, 0)
        self:Tag(self.Status, "[pvp]")

        self:SetScript("OnEnter", function(self) self.Status:SetAlpha(0.5); UnitFrame_OnEnter(self) end)
        self:SetScript("OnLeave", function(self) self.Status:SetAlpha(0); UnitFrame_OnLeave(self) end)
    end

    self.cDebuffFilter = true

    self.cDebuff = CreateFrame("StatusBar", nil, (unit == "player" or unit == "target") and self.Overlay or self.Health)
    self.cDebuff:SetFrameLevel(self:GetFrameLevel() + 1)
    self.cDebuff:SetSize(PixelScale(16), PixelScale(16))
    self.cDebuff:SetPoint("CENTER")

    self.cDebuffBackdrop = self.cDebuff:CreateTexture(nil, "OVERLAY")
    self.cDebuffBackdrop:SetAllPoints(unitInRaid and self.Nameplate or self.Health)
    self.cDebuffBackdrop:SetTexture(highlightTex)
    self.cDebuffBackdrop:SetBlendMode("ADD")
    self.cDebuffBackdrop:SetVertexColor(0, 0, 0, 0)

    self.cDebuff.icon = self.cDebuff:CreateTexture(nil, "OVERLAY")
    self.cDebuff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.cDebuff.icon:SetAllPoints()

    self.cDebuff.border = CreateFrame("Frame", nil, self.cDebuff)
    self.cDebuff.border:SetPoint("TOPLEFT", PixelScale(-1.5), PixelScale(1.5))
    self.cDebuff.border:SetPoint("BOTTOMRIGHT", PixelScale(1.5), PixelScale(-1.5))
    self.cDebuff.border:SetBackdrop({
        bgFile = media.files.button_normal,
        insets = {top = PixelScale(-1), left = PixelScale(-1), bottom = PixelScale(-1), right = PixelScale(-1)},
    })

    self.cDebuff.gloss = CreateFrame("Frame", nil, self.cDebuff.border)
    self.cDebuff.gloss:SetPoint("TOPLEFT", PixelScale(-1), PixelScale(1))
    self.cDebuff.gloss:SetPoint("BOTTOMRIGHT", PixelScale(1), PixelScale(-1))
    self.cDebuff.gloss:SetBackdrop({
        bgFile = media.files.button_gloss,
        insets = {top = PixelScale(-1), left = PixelScale(-1), bottom = PixelScale(-1), right = PixelScale(-1)},
    })

    if not (unitInRaid or unitIsPartyPet) then
        self.Castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", (unit == "player" or unit == "target") and self.Portrait or self.Power)
        self.Castbar:SetStatusBarTexture(normtex)
        self.Castbar:SetAlpha(0.75)

        self.Castbar.PostCastStart = PostCastStart
        self.Castbar.PostChannelStart = PostChannelStart

        if unit == "player" or unit == "target" then
            self.Castbar:SetAllPoints(self.Overlay)
        else
            self.Castbar:SetHeight(PixelScale(5))
            self.Castbar:SetAllPoints()
        end

        if unit == "player" or unit == "target" then
            self.Castbar.Time = SetFontString(self.Overlay, font, 9)
            self.Castbar.Time:SetPoint("TOPRIGHT", PixelScale(-3.5), 0)
            self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
            self.Castbar.Time:SetJustifyH("RIGHT")
            self.Castbar.CustomTimeText = CustomCastTimeText
            self.Castbar.CustomDelayText = CustomCastDelayText

            self.Castbar.Text = SetFontString(self.Overlay, font, 11)
            self.Castbar.Text:SetPoint("LEFT", PixelScale(3.5), PixelScale(1))
            self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", PixelScale(-1), 0)
            self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)

            self.Castbar:HookScript("OnShow", function() self.Castbar.Text:Show(); self.Castbar.Time:Show() end)
            self.Castbar:HookScript("OnHide", function() self.Castbar.Text:Hide(); self.Castbar.Time:Hide() end)
        end

        if unit == "player" then
            self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
            self.Castbar.SafeZone:SetTexture(normtex)
            self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

            self.Castbar.Latency = SetFontString(self.Overlay, font, 9)
            self.Castbar.Latency:SetPoint("BOTTOMRIGHT", PixelScale(-3.5), 0)
            self.Castbar.Latency:SetTextColor(0.84, 0.75, 0.65)

            self.Castbar:HookScript("OnShow", function() self.Castbar.Latency:Show() end)
            self.Castbar:HookScript("OnHide", function() self.Castbar.Latency:Hide() end)

            self:RegisterEvent("UNIT_SPELLCAST_SENT", function(self, event, caster)
                if caster == "player" or caster == "vehicle" then
                    self.Castbar.castSent = GetTime()
                end
            end)
        end
    end

    if unitInParty and not unitIsPartyPet and not unitIsPartyTarget or unitInRaid or unit == "player" then
        self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
        self.Leader:SetSize(PixelScale(14), PixelScale(14))
        self.Leader:SetPoint("TOPLEFT", 0, PixelScale(8))

        self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
        self.Assistant:SetSize(PixelScale(14), PixelScale(14))
        self.Assistant:SetPoint("TOPLEFT", 0, PixelScale(8))

        self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
        self.MasterLooter:SetHeight(PixelScale(11), PixelScale(11))
        self.MasterLooter:SetPoint("TOPRIGHT", 0, PixelScale(6.5))
        if not unit == "player" then
            self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
            self.ReadyCheck:SetParent(unitInRaid and self.Nameplate or self.Health)
            self.ReadyCheck:SetSize(PixelScale(12), PixelScale(12))
            self.ReadyCheck.fadeTimer = 5
            if unitInRaid then
                self.ReadyCheck:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", PixelScale(-5), PixelScale(2))
            else
                self.ReadyCheck:SetPoint("TOPRIGHT", PixelScale(7), PixelScale(7))
            end
        end

        if unitInParty and not unitIsPartyPet and not unitIsPartyTarget then
            self.LFGRole = SetFontString(self.Health, font, 9)
            self.LFGRole:SetPoint("LEFT", self.Info, "RIGHT")
            self:Tag(self.LFGRole, "[caellian:lfgrole]")
        end
    end

    if playerClass == "DRUID" then
        self:SetAttribute("type3", "spell")
        self:SetAttribute("spell3", GetSpellInfo(29166)) -- Innervate
    elseif playerClass == "HUNTER" then
        self:SetAttribute("type3", "spell")
        self:SetAttribute("spell3", GetSpellInfo(34477)) -- Misdirection
    elseif playerClass == "PALADIN" then
        self:SetAttribute("type3", "spell")
        self:SetAttribute("spell3", GetSpellInfo(31789)) -- Righteous Defense
    elseif playerClass == "WARRIOR" then
        self:SetAttribute("type3", "spell")
        self:SetAttribute("spell3", GetSpellInfo(3411)) -- Intervene
    end

    if unit == "player" or unit == "target" then
        self:SetSize(PixelScale(230), PixelScale(52))
    elseif unitIsPartyPet then
        self:SetSize(PixelScale(113), PixelScale(10))
    elseif unitInRaid then
        self:SetSize(PixelScale(64), PixelScale(43))
    else
        self:SetSize(PixelScale(113), PixelScale(25))
    end

    self.RaidIcon = self:CreateTexture(nil, "OVERLAY")
    self.RaidIcon:SetParent(unitInRaid and self.Nameplate or self.Health)
    self.RaidIcon:SetTexture(raidIcons)
    self.RaidIcon:SetSize(unitInRaid and PixelScale(14) or PixelScale(18), unitInRaid and PixelScale(14) or PixelScale(18))
    if unitInRaid then
        self.RaidIcon:SetPoint("CENTER", 0, PixelScale(10))
    else
        self.RaidIcon:SetPoint("TOP", 0, PixelScale(10))
    end

    if unitInParty or unitInRaid then
        self.Range = {insideAlpha = 1, outsideAlpha = 0.5}
    elseif unit == "target" then
        -- Frame to enable cRange element
        self.cRange = CreateFrame("Frame", nil, self)
        self.cRange:SetFrameLevel(self:GetFrameLevel() + 3)

        self.cRange.text = SetFontString(self.cRange, font, 11, "OUTLINE")
        self.cRange.text:SetAllPoints(self.Portrait)
        self.cRange.text:SetTextColor(0.69, 0.31, 0.31)
        self.cRange.text:SetJustifyH("CENTER")
    else
        self.cRange = {insideAlpha = 1, outsideAlpha = 0.5}
    end

    local AggroSelect = function()
        if (UnitExists("target")) then
            PlaySound("igCreatureAggroSelect")
        end
    end
    self:RegisterEvent("PLAYER_TARGET_CHANGED", AggroSelect)

    self:SetScale(config.scale)
    if self.Auras then self.Auras:SetScale(config.scale) end
    if self.Buffs then self.Buffs:SetScale(config.scale) end
    if self.Debuffs then self.Debuffs:SetScale(config.scale) end

    HideAura(self)
    return self
end

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if "groupFilter" is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinate (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the ammount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]

oUF:RegisterStyle("Caellian", SetStyle)

oUF:Factory(function(self)

    self:SetActiveStyle("Caellian")

    self:Spawn("player", "oUF_Caellian_player"):SetPoint("BOTTOM", UIParent, PixelScale(config.coords.playerX), PixelScale(config.coords.playerY))
    self:Spawn("target", "oUF_Caellian_target"):SetPoint("BOTTOM", UIParent, PixelScale(config.coords.targetX), PixelScale(config.coords.targetY))

    self:Spawn("pet", "oUF_Caellian_pet"):SetPoint("BOTTOMLEFT", oUF_Caellian_player, "TOPLEFT", 0, PixelScale(10))
    self:Spawn("focus", "oUF_Caellian_focus"):SetPoint("BOTTOMRIGHT", oUF_Caellian_player, "TOPRIGHT", 0, PixelScale(10))
    self:Spawn("focustarget", "oUF_Caellian_focustarget"):SetPoint("BOTTOMLEFT", oUF_Caellian_target, "TOPLEFT", 0, PixelScale(10))
    self:Spawn("targettarget", "oUF_Caellian_targettarget"):SetPoint("BOTTOMRIGHT", oUF_Caellian_target, "TOPRIGHT", 0, PixelScale(10))

    if not config.noParty then
        local party = self:SpawnHeader("oUF_Party", nil, "custom [@raid6,exists] hide; show",
        "showParty", true,
        "showPlayer", true,
        "yOffset", PixelScale(-27.5),
        "template", "oUF_cParty",
        "oUF-initialConfigFunction", ([[self:SetWidth(113) self:SetHeight(22)]])
        )

        if healingSpecs[playerClass] then
            if (playerClass ~= "PRIEST" and playerSpec == healingSpecs[playerClass]) or (playerClass == "PRIEST" and playerSpec ~= healingSpecs[playerClass]) then
                party:SetPoint("TOPLEFT", UIParent, PixelScale(config.coords.healing.partyX), PixelScale(config.coords.healing.partyY))
            else
                party:SetPoint("TOPLEFT", UIParent, PixelScale(config.coords.other.partyX), PixelScale(config.coords.other.partyY))
            end
        else
            party:SetPoint("TOPLEFT", UIParent, PixelScale(config.coords.other.partyX), PixelScale(config.coords.other.partyY))
        end
    end

    if not config.noRaid then
        local raid = {}
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:Hide()
        for i = 1, NUM_RAID_GROUPS do
            local raidgroup = self:SpawnHeader("oUF_Raid"..i, nil, "custom [@raid6,exists] show; hide",
            "groupFilter", tostring(i),
            "showRaid", true,
            "yOffSet", PixelScale(-3.5),
            "oUF-initialConfigFunction", ([[self:SetWidth(113) self:SetHeight(22)]])
            )
            insert(raid, raidgroup)
            if i == 1 then
                if healingSpecs[playerClass] then
                    if (playerClass ~= "PRIEST" and playerSpec == healingSpecs[playerClass]) or (playerClass == "PRIEST" and playerSpec ~= healingSpecs[playerClass]) then
                        raidgroup:SetPoint("TOPLEFT", UIParent, PixelScale(config.coords.healing.raidX), PixelScale(config.coords.healing.raidY))
                    end
                else
                    raidgroup:SetPoint("TOPLEFT", UIParent, PixelScale(config.coords.other.raidX), PixelScale(config.coords.other.raidY))
                end
            else
                raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", PixelScale(60 * config.scale - 60) + PixelScale(3.5), 0)
            end
        end
    end

    local boss = {}
    for i = 1, MAX_BOSS_FRAMES do
        boss[i] = self:Spawn("boss"..i, "oUF_Boss"..i)

        if i == 1 then
            boss[i]:SetPoint("TOP", UIParent, 0, PixelScale(-15))
        else
            boss[i]:SetPoint("TOP", boss[i-1], "BOTTOM", 0, PixelScale(-26.5))
        end
    end

    for i, v in ipairs(boss) do v:Show() end

    if not config.noArena then
        local arena = {}
        for i = 1, 5 do
            arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)

            if i == 1 then
                if healingSpecs[playerClass] then
                    if (playerClass ~= "PRIEST" and playerSpec == healingSpecs[playerClass]) or (playerClass == "PRIEST" and playerSpec ~= healingSpecs[playerClass]) then
                        arena[i]:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", PixelScale(config.coords.healing.arenaX), PixelScale(config.coords.healing.arenaY))
                    end
                else
                    arena[i]:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", PixelScale(config.coords.other.arenaX), PixelScale(config.coords.other.arenaY))
                end
            else
                arena[i]:SetPoint("TOP", arena[i-1], "BOTTOM", 0, PixelScale(-26.5))
            end
        end

        for i, v in ipairs(arena) do v:Show() end

        local arenatarget = {}
        for i = 1, 5 do
            arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
            if i == 1 then
                arenatarget[i]:SetPoint("TOPRIGHT", arena[i], "TOPLEFT", PixelScale(-7.5), 0)
            else
                arenatarget[i]:SetPoint("TOP", arenatarget[i-1], "BOTTOM", 0, PixelScale(-26.5))
            end
        end

        for i, v in ipairs(arenatarget) do v:Show() end
    end
end)
