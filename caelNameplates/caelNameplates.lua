local _, caelNameplates = ...

caelNameplates.eventFrame = CreateFrame("Frame", nil, UIParent)

if not IsAddOnLoaded("caelCore") then
    -- 1 might make nameplates larger but it fixes the disappearing ones.
    SetCVar("bloattest", 0)

    -- 1 makes nameplates larger depending on threat percentage.
    SetCVar("bloatnameplates", 0)

    -- 1 makes nameplates resize depending on threat gain/loss. Only active when a mob has multiple units on its threat table.
    SetCVar("bloatthreat", 0)
end

-- Not sure (testing)
SetCVar("threatWarning", 3)
SetCVar("nameplateMotion", "0")
--InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown:Kill()

local media = caelUI.media
local barTexture = media.files.statusbar_c
local iconTexture = media.files.button_normal
local raidIcons = media.files.raid_icons
local overlayTexture = [=[Interface\Tooltips\Nameplate-Border]=]
local font, fontSize, fontOutline = media.fonts.nameplate, 9, 8
local pixel_scale = caelUI.config.pixel_scale

local UpdateTime = function(self, curValue)
    local minValue, maxValue = self:GetMinMaxValues()
    if self.channeling then
        self.time:SetFormattedText("%.1f ", curValue)
    else
        self.time:SetFormattedText("%.1f ", maxValue - curValue)
    end
end

local ThreatUpdate = function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= 0.2 then
        if not self.oldglow:IsShown() then
            self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
        else
            local r, g, b = self.oldglow:GetVertexColor()
            if g + b == 0 then
                self.healthBar.hpGlow:SetBackdropBorderColor(1, 0, 0)
            else
                self.healthBar.hpGlow:SetBackdropBorderColor(1, 1, 0)
            end
        end

        self.healthBar:SetStatusBarColor(self.r, self.g, self.b)

        self.elapsed = 0
    end
end

local UpdatePlate = function(self)
    -- Reset text color just in case
    self.name:SetTextColor(0.84, 0.75, 0.65)

    local r, g, b = self.healthBar:GetStatusBarColor()
    local newr, newg, newb
    if g + b == 0 then
        -- Hostile unit
        newr, newg, newb = 0.69, 0.31, 0.31
    elseif r + b == 0 then
        -- Friendly unit
        newr, newg, newb = 0.33, 0.59, 0.33
    elseif r + g == 0 then
        -- Friendly player
        newr, newg, newb = 0.31, 0.45, 0.63
    elseif 2 - (r + g) < 0.05 and b == 0 then
        -- Neutral unit
        newr, newg, newb = 0.65, 0.63, 0.35
    else
        -- Hostile player - class colored.
        newr, newg, newb = r, g, b
        self.name:SetTextColor(r, g, b)
    end

    self.healthBar:SetStatusBarColor(newr, newg, newb)

    self.r, self.g, self.b = newr, newg, newb

    self.healthBar:ClearAllPoints()
    self.healthBar:SetPoint("BOTTOM", self.healthBar:GetParent(), "BOTTOM")
    self.healthBar:SetHeight(pixel_scale(8))
    self.healthBar:SetWidth(pixel_scale(100))

    self.healthBar.hpBackground:SetVertexColor(self.r * 0.33, self.g * 0.33, self.b * 0.33, 0.75)
    self.castBar.IconOverlay:SetVertexColor(self.r, self.g, self.b)

    self.castBar:ClearAllPoints()
    self.castBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, pixel_scale(-4))
    self.castBar:SetHeight(pixel_scale(5))
    self.castBar:SetWidth(pixel_scale(100))

    self.highlight:ClearAllPoints()
    self.highlight:SetAllPoints(self.healthBar)

    local oldName = self.oldname:GetText()
    local newName = (string.len(oldName) > 20) and string.gsub(oldName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or oldName -- "%s?(.)%S+%s"

    self.name:SetText(newName)

    local level, elite, mylevel = tonumber(self.level:GetText()), self.elite:IsShown(), UnitLevel("player")
    self.level:ClearAllPoints()
    self.level:SetPoint("RIGHT", self.healthBar, "LEFT", pixel_scale(-2), 0)
    if self.boss:IsShown() then
        self.level:SetText("B")
        self.level:SetTextColor(0.8, 0.05, 0)
        self.level:Show()
    elseif not elite and (mylevel == MAX_PLAYER_LEVEL and level == mylevel) then
        self.level:Hide()
    else
        self.level:SetText(level..(elite and "+" or ""))
    end
end

local FixCastbar = function(self)
    self.castbarOverlay:Hide()

    self:SetHeight(pixel_scale(5))
    self:ClearAllPoints()
    self:SetPoint("TOP", self.healthBar, "BOTTOM", 0, pixel_scale(-4))
end

local ColorCastBar = function(self, shielded)
    if shielded then
        self:SetStatusBarColor(0.8, 0.05, 0)
        self.cbGlow:SetBackdropBorderColor(0.75, 0.75, 0.75)
    else
        self.cbGlow:SetBackdropBorderColor(0, 0, 0)
    end
end

local OnSizeChanged = function(self)
    self.needFix = true
end

local OnValueChanged = function(self, curValue)
    UpdateTime(self, curValue)
    if self.needFix then
        FixCastbar(self)
        self.needFix = nil
    end
end

local OnShow = function(self)
    self.channeling  = UnitChannelInfo("target")
    FixCastbar(self)
    ColorCastBar(self, self.shieldedRegion:IsShown())
    self.IconOverlay:Show()
end

local OnHide = function(self)
    self.highlight:Hide()
    self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
end

local OnEvent = function(self, event, unit)
    if unit == "target" then
        if self:IsShown() then
            ColorCastBar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
        end
    end
end

local CreatePlate = function(frame)
    if frame.done then
        return
    end

    frame.nameplate = true

    frame.healthBar, frame.castBar = frame:GetChildren()
    local healthBar, castBar = frame.healthBar, frame.castBar
    
    local glowRegion, overlayRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()
    local _, castbarOverlay, shieldedRegion, spellIconRegion = castBar:GetRegions()

    frame.oldname = nameTextRegion
    nameTextRegion:Hide()

    frame.name = frame:CreateFontString()
    frame.name:SetPoint("BOTTOM", healthBar, "TOP", 0, pixel_scale(2))
    frame.name:SetFont(font, fontSize, fontOutline)
    frame.name:SetTextColor(0.84, 0.75, 0.65)
    frame.name:SetShadowOffset(1.25, -1.25)

    frame.level = levelTextRegion
    levelTextRegion:SetFont(font, fontSize, fontOutline)
    levelTextRegion:SetShadowOffset(1.25, -1.25)

    healthBar:SetStatusBarTexture(barTexture)
    healthBar:SetFrameLevel(frame.healthBar:GetFrameLevel())
    healthBar:SetFrameStrata(frame.healthBar:GetFrameStrata())

    healthBar.hpBackground = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBar.hpBackground:SetAllPoints()
    healthBar.hpBackground:SetTexture(barTexture)

    healthBar.hpGlow = CreateFrame("Frame", nil, healthBar)
    healthBar.hpGlow:SetFrameLevel(healthBar:GetFrameLevel() -1 > 0 and healthBar:GetFrameLevel() -1 or 0)
    healthBar.hpGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", pixel_scale(-2), pixel_scale(2))
    healthBar.hpGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", pixel_scale(2), pixel_scale(-2))
    healthBar.hpGlow:SetBackdrop(media.backdrop_table)
    healthBar.hpGlow:SetBackdropColor(0, 0, 0, 0)
    healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)

    castBar.castbarOverlay = castbarOverlay
    castBar.healthBar = healthBar
    castBar.shieldedRegion = shieldedRegion
    castBar:SetStatusBarTexture(barTexture)

    castBar:HookScript("OnShow", OnShow)
    castBar:HookScript("OnSizeChanged", OnSizeChanged)
    castBar:HookScript("OnValueChanged", OnValueChanged)
    castBar:HookScript("OnEvent", OnEvent)
    castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

    castBar.time = castBar:CreateFontString(nil, "ARTWORK")
    castBar.time:SetPoint("RIGHT", castBar, "LEFT", pixel_scale(-2), 0)
    castBar.time:SetFont(font, fontSize, fontOutline)
    castBar.time:SetTextColor(0.84, 0.75, 0.65)
    castBar.time:SetShadowOffset(1.25, -1.25)

    castBar.cbBackground = castBar:CreateTexture(nil, "BACKGROUND")
    castBar.cbBackground:SetAllPoints()
    castBar.cbBackground:SetTexture(barTexture)
    castBar.cbBackground:SetVertexColor(0.25, 0.25, 0.25, 0.75)

    castBar.cbGlow = CreateFrame("Frame", nil, castBar)
    castBar.cbGlow:SetFrameLevel(castBar:GetFrameLevel() -1 > 0 and castBar:GetFrameLevel() -1 or 0)
    castBar.cbGlow:SetPoint("TOPLEFT", castBar, pixel_scale(-2), pixel_scale(2))
    castBar.cbGlow:SetPoint("BOTTOMRIGHT", castBar, pixel_scale(2), pixel_scale(-2))
    castBar.cbGlow:SetBackdrop(media.backdrop_table)
    castBar.cbGlow:SetBackdropColor(0, 0, 0, 0)
    castBar.cbGlow:SetBackdropBorderColor(0, 0, 0)

    castBar.HolderA = CreateFrame("Frame", nil, castBar)
    castBar.HolderA:SetFrameLevel(castBar.HolderA:GetFrameLevel() + 1)
    castBar.HolderA:SetAllPoints()

    spellIconRegion:ClearAllPoints()
    spellIconRegion:SetParent(castBar.HolderA)
    spellIconRegion:SetPoint("LEFT", castBar, pixel_scale(8), 0)
    spellIconRegion:SetSize(pixel_scale(15), pixel_scale(15))

    castBar.HolderB = CreateFrame("Frame", nil, castBar)
    castBar.HolderB:SetFrameLevel(castBar.HolderA:GetFrameLevel() + 2)
    castBar.HolderB:SetAllPoints()

    castBar.IconOverlay = castBar.HolderB:CreateTexture(nil, "OVERLAY")
    castBar.IconOverlay:SetPoint("TOPLEFT", spellIconRegion, pixel_scale(-1.5), pixel_scale(1.5))
    castBar.IconOverlay:SetPoint("BOTTOMRIGHT", spellIconRegion, pixel_scale(1.5), pixel_scale(-1.5))
    castBar.IconOverlay:SetTexture(iconTexture)

    highlightRegion:SetTexture(barTexture)
    highlightRegion:SetVertexColor(0.25, 0.25, 0.25)
    frame.highlight = highlightRegion

    raidIconRegion:ClearAllPoints()
    raidIconRegion:SetPoint("RIGHT", healthBar, pixel_scale(-8), 0)
    raidIconRegion:SetSize(pixel_scale(15), pixel_scale(15))
    raidIconRegion:SetTexture(raidIcons)

    frame.oldglow = glowRegion
    frame.elite = stateIconRegion
    frame.boss = bossIconRegion

    frame.done = true

    glowRegion:SetTexture(nil)
    overlayRegion:SetTexture(nil)
    shieldedRegion:SetTexture(nil)
    castbarOverlay:SetTexture(nil)
    stateIconRegion:SetTexture(nil)
    bossIconRegion:SetTexture(nil)

    UpdatePlate(frame)
    frame:SetScript("OnShow", UpdatePlate)
    frame:SetScript("OnHide", OnHide)

    frame.elapsed = 0
    frame:SetScript("OnUpdate", ThreatUpdate)
end

local numKids = 0
local lastUpdate = 0
caelNameplates.eventFrame:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed

    if lastUpdate > 0.1 then
        lastUpdate = 0

        local newNumKids = WorldFrame:GetNumChildren()
        if newNumKids ~= numKids then
            for i = numKids + 1, newNumKids do
                local frame = select(i, WorldFrame:GetChildren())

                if (frame:GetName() and frame:GetName():find("NamePlate%d")) then
                    CreatePlate(frame)
                end
            end
            numKids = newNumKids
        end
    end
end)

caelNameplates.eventFrame:SetScript("OnEvent", function(self, event, ...)
    if type(self[event]) == "function" then
        return self[event](self, event, ...)
    end
end)

function caelNameplates.eventFrame:PLAYER_REGEN_ENABLED()
    SetCVar("nameplateShowEnemies", 0)
end

function caelNameplates.eventFrame:PLAYER_REGEN_DISABLED()
    SetCVar("nameplateShowEnemies", 1)
end

caelNameplates.eventFrame:RegisterEvent("ADDON_LOADED")
function caelNameplates.eventFrame:ADDON_LOADED(event, addon)
    if addon and addon:lower() == "caelnameplates" then
        if not caelNameplatesDB then
            caelNameplatesDB = {}
        end
        
        caelNameplates.settings = caelNameplatesDB
        
        if caelNameplates.settings.autotoggle then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            self:RegisterEvent("PLAYER_REGEN_DISABLED")
        end
    end
end

SlashCmdList["caelNameplates"] = function(parameters)
    if parameters == "autotoggle" then
        local newsetting = not caelNameplates.settings.autotoggle
        caelNameplates.settings.autotoggle = newsetting
        
        local func = newsetting and "RegisterEvent" or "UnregisterEvent"
        
        caelNameplates.eventFrame[func](caelNameplates.eventFrame, "PLAYER_REGEN_ENABLED")
        caelNameplates.eventFrame[func](caelNameplates.eventFrame, "PLAYER_REGEN_DISABLED")
        print("Auto toggling of nameplates based on combat state " .. (caelNameplates.settings.autotoggle and "|cff00ff00enabled|r." or "|cffff0000disabled|r."))
    end
end

SLASH_caelNameplates1 = "/caelnameplates"
