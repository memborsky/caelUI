--[[    $Id$    ]]

local _, caelTooltips = ...

caelTooltips = CreateFrame("Frame", nil, UIParent)

local _G = getfenv(0)
local orig1, orig2 = {}, {}
local height
local pixelScale = caelUI.pixelScale
local media = caelUI.get_database("media")

-- Used to allow the tooltips to be enabled on the cursor
local cursor = true

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local gsub, find, format = string.gsub, string.find, string.format

_G["GameTooltipHeaderText"]:SetFont(media.fonts.NORMAL, 10)
_G["GameTooltipText"]:SetFont(media.fonts.NORMAL, 10)
_G["GameTooltipTextSmall"]:SetFont(media.fonts.NORMAL, 9)

local Tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip}

local linkTypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local classification = {
    worldboss = "|cffAF5050Boss|r",
    rareelite = "|cffAF5050+ Rare|r",
    elite = "|cffAF5050+|r",
    rare = "|cffAF5050Rare|r",
}

local OnHyperlinkEnter = function(frame, link, ...)
    local linkType = link:match("^([^:]+)")
    if linkType and linkTypes[linkType] then
        GameTooltip:SetOwner(frame, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOM", caelPanel_EditBox, "TOP", 0, pixelScale(10))
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end

    if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local OnHyperlinkLeave = function(frame, ...)
    GameTooltip:Hide()
    if orig2[frame] then return orig2[frame](frame, ...) end
end

for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame"..i]
    orig1[frame] = frame:GetScript("OnHyperlinkEnter")
    frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

    orig2[frame] = frame:GetScript("OnHyperlinkLeave")
    frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
end

local FormatMoney = function(money)
    local gold = floor(math.abs(money) / 10000)
    local silver = mod(floor(math.abs(money) / 100), 100)
    local copper = mod(floor(math.abs(money)), 100)

    if gold ~= 0 then
        return format("%s|cffffd700g|r %s|cffc7c7cfs|r %s|cffeda55fc|r", gold, silver, copper)
    elseif silver ~= 0 then
        return format("%s|cffc7c7cfs|r %s|cffeda55fc|r", silver, copper)
    else
        return format("%s|cffeda55fc|r", copper)
    end
end

GameTooltip_SetDefaultAnchor = function(self, parent)
    if cursor == true then
        if IsAddOnLoaded("oUF_Caellian_Heal") and parent ~= UIParent then 
            self:SetOwner(parent, "ANCHOR_NONE")
            self:SetPoint("BOTTOMRIGHT", caelPanel_EditBox, "TOPRIGHT", 0, pixelScale(10))
        else
            self:SetOwner(parent, "ANCHOR_CURSOR")
        end
    else
        local frame = GetMouseFocus():GetName()

        if frame and frame:match("Button%d") then
            self:SetOwner(parent, "ANCHOR_TOP")
        else
            self:SetOwner(parent, "ANCHOR_NONE")
            self:SetPoint("BOTTOM", caelPanel_ActionBar1, "TOP", 0, pixelScale(5))
        end
    end

    self.default = 1
end

GameTooltip_UnitColor = function(unit)
    local r, g, b

    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
    elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit) or UnitIsDead(unit) then
        r, g, b = 0.55, 0.57, 0.61
    else
        r, g, b = UnitSelectionColor(unit)
    end

    return r, g, b
end

GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local _, link = self:GetItem()
    if link then
        local id = tonumber(link:match("item:(%d+):"))

        if id then
            local _, _, _, level, _, itype, subtype, stack = GetItemInfo(id)
            if level then
                local typetext = itype and subtype and format("Type: %s - %s", itype, subtype) or nil
                local r, g, b = 0.84, 0.75, 0.65

                self:AddDoubleLine("iLevel: "..level, "ItemID: "..id, r, g, b, r, g, b)
                if stack ~= 1 then
                    self:AddDoubleLine(typetext, "Stacks to: "..stack, r, g, b, r, g, b)
                else
                    self:AddLine(typetext, r, g, b)
                end
                self:Show()
            end
        end
    end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local lines = self:NumLines()
    local _, unit = self:GetUnit()
    if(not unit or not UnitExists(unit)) then return end

    local race = UnitRace(unit)
    local level = UnitLevel(unit)
    local guild = GetGuildInfo(unit)
    local name, realm = UnitName(unit)
    local crtype = UnitCreatureType(unit)
    local classif = UnitClassification(unit)
    local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

    _G["GameTooltipTextLeft1"]:SetFormattedText("%s%s", name, realm and realm ~= "" and " (*)" or "")

    if(UnitIsPlayer(unit)) then
        if UnitIsAFK(unit) then
            self:AppendText(("|cff559655 %s|r"):format(CHAT_FLAG_AFK))
        elseif UnitIsDND(unit) then 
            self:AppendText(("|cff559655 %s|r"):format(CHAT_FLAG_DND))
        end

        local offset = 2
        if guild then
            _G["GameTooltipTextLeft2"]:SetPoint("TOPLEFT", _G["GameTooltipTextLeft1"], "BOTTOMLEFT", 0, -1)
            _G["GameTooltipTextLeft2"]:SetFormattedText("%s", IsInGuild() and GetGuildInfo("player") == guild and "|cff0090ff« "..guild.." »|r" or "|cff00ff10« "..guild.." »|r")
            offset = offset + 1
        end

        for i= offset, lines do
            if(_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
                _G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s", r*255, g*255, b*255, level > 0 and level or "??", race)
                break
            end
        end
    else
        for i = 2, lines do
            if((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
                _G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level or "", classification[classif] or "", crtype or "")
                break
            end
        end
    end

    local pvpLine
    for i = 1, lines do
        local text = _G["GameTooltipTextLeft"..i]:GetText()
        if text and text == PVP_ENABLED then
            pvpLine = _G["GameTooltipTextLeft"..i]
            pvpLine:SetText()
            break
        end
    end

    if(UnitExists(unit.."target") and unit ~= "player") then
        local r, g, b = 0.33, 0.59, 0.33
        local text = ""

        if(UnitIsEnemy("player", unit.."target")) then
            r, g, b = 0.69, 0.31, 0.31
        elseif(not UnitIsFriend("player", unit.."target")) then
            r, g, b = 0.65, 0.63, 0.35
        end

        if(UnitName(unit.."target") == UnitName("player")) then
            text = "You"
        else
            text = UnitName(unit.."target")
        end

        if pvpLine then
            pvpLine:SetText("|cffD7BEA5Target:|r "..text)
            pvpLine:SetTextColor(r,g,b)
        else
            self:AddLine("|cffD7BEA5Target:|r "..text, r, g, b)
        end
    end

    local r, g, b = GameTooltip_UnitColor(unit)
    GameTooltipStatusBar:SetStatusBarColor(r, g, b, 0.5)

end)

GameTooltipStatusBar:SetScript("OnValueChanged", nil)

GameTooltip:HookScript("OnTooltipAddMoney", function(self, cost, maxcost)
    local r, g, b = 0.84, 0.75, 0.65
    self:AddLine("Value: "..FormatMoney(cost), r, g, b)
end)

--[[
local gradientTop = caelTooltips:CreateTexture(nil, "BORDER")
gradientTop:SetTexture(media.files.bgFile)
gradientTop:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.84, 0.75, 0.65, 0.5)

local gradientBottom = caelTooltips:CreateTexture(nil, "BORDER")
gradientBottom:SetTexture(media.files.bgFile)
gradientBottom:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.75, 0, 0, 0, 0)
--]]

local healthBar = GameTooltipStatusBar
healthBar:ClearAllPoints()
healthBar:SetHeight(pixelScale(6))
healthBar:SetPoint("BOTTOMLEFT", healthBar:GetParent(), "TOPLEFT", pixelScale(3), pixelScale(2))
healthBar:SetPoint("BOTTOMRIGHT", healthBar:GetParent(), "TOPRIGHT", pixelScale(-3), pixelScale(2))
healthBar:SetStatusBarTexture(media.files.statusBarC)

healthBar.border = CreateFrame("Frame", nil, healthBar)
healthBar.border:SetPoint("TOPLEFT", pixelScale(-3), pixelScale(3))
healthBar.border:SetPoint("BOTTOMRIGHT", pixelScale(3), pixelScale(-3))
healthBar.border:SetFrameStrata("BACKGROUND")
healthBar.border:SetBackdrop(media.backdropTable)
healthBar.border:SetBackdropColor(0.25, 0.25, 0.25, 0)

healthBar.bg = healthBar:CreateTexture(nil, "BORDER")
healthBar.bg:SetAllPoints()
healthBar.bg:SetTexture(media.files.statusBarC)

local BorderColor = function(self)
    local _, unit = self:GetUnit()
    local reaction = unit and UnitReaction("player", unit)

    if reaction then
        local r, g, b = FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
        self:SetBackdropBorderColor(r, g, b)
        healthBar.border:SetBackdropBorderColor(r, g, b)
    else
        local _, link = self:GetItem()
        local quality = link and select(3, GetItemInfo(link))
        if quality and quality >= 2 then
            local r, g, b = GetItemQualityColor(quality)
            self:SetBackdropBorderColor(r, g, b, borderAlpha)
        else
            self:SetBackdropBorderColor(0, 0, 0)
            --healthBar.border:SetBackdropBorderColor(0, 0, 0)
        end
    end
    self:SetBackdropColor(0.1, 0.1, 0.1, 1)
    --self:SetBackdropColor(0, 0, 0, GetMouseFocus() == WorldFrame and 0.33 or 0.66)
end

local SetStyle = function(self)
    self:SetSize(pixelScale(self:GetWidth()), pixelScale(self:GetHeight()))

    local r, g, b = healthBar:GetStatusBarColor()
    healthBar.bg:SetVertexColor(r * 0.33, g * 0.33, b * 0.33, 0.85)

    BorderColor(self)

    height = pixelScale(self:GetHeight() / 5)

    --[[
    gradientTop:SetParent(self)
    gradientTop:SetPoint("TOPLEFT", pixelScale(3), pixelScale(-3))
    gradientTop:SetPoint("TOPRIGHT", pixelScale(-3), pixelScale(-3))
    gradientTop:SetHeight(height)

    gradientBottom:SetParent(self)
    gradientBottom:SetPoint("BOTTOMLEFT", pixelScale(3), pixelScale(3))
    gradientBottom:SetPoint("BOTTOMRIGHT", pixelScale(-3), pixelScale(3))
    gradientBottom:SetHeight(height)
    --]]
end

caelTooltips:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTooltips:SetScript("OnEvent", function(self)
    for _, v in ipairs(Tooltips) do
        v:HookScript("OnShow", SetStyle)
        v:SetScale(0.9)

        v:SetBackdrop(media.backdropTable)
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", nil)
end)
