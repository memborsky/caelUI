--[[    $Id$    ]]

local _, caelTimers = ...

caelTimers.eventFrame = CreateFrame("Frame", nil, UIParent)

local floor, format, mod, pairs = math.floor, string.format, mod, pairs
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff
local pixelScale = caelUI.pixelScale
local media = caelUI.get_database("media")

--[[
local aura_colors  = {
    ["Magic"]   = {r = 0.00, g = 0.25, b = 0.45}, 
    ["Disease"] = {r = 0.40, g = 0.30, b = 0.10}, 
    ["Poison"]  = {r = 0.00, g = 0.40, b = 0.10}, 
    ["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
    ["None"]    = {r = 0.69, g = 0.31, b = 0.31}
}
--]]

-- CONFIG VARIABLES
local BAR_HEIGHT            = 10
local BAR_SPACING           = 1
local ICON_POSITION         = "left"
local ICON_COLOR            = {0, 0, 0, 0}
local SPARK                 = true
local CAST_SEPARATOR        = true
local CAST_SEPARATOR_COLOR  = {0, 0, 0, 0.5}

local bars = {}

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

local OnUpdate = function(self, elapsed)
    self.timer = self.timer - elapsed
    
    if self.timer > 0 then return end
    self.timer = 0.1
    
    if self.active then
        if self.expires >= GetTime() then
            self:SetValue(self.expires - GetTime())
            self:SetMinMaxValues(0, self.duration)
            if not self.hide_name then
                self.text:SetText(format("%s%s - %s", self.spellName, self.count > 1 and format(" x%d", self.count) or "", FormatTime(self.expires - GetTime())))
            else
                self.text:SetText(format("%s", FormatTime(self.expires - GetTime())))
            end
        else
            self.active = false
        end
    end
    
    if not self.active then
        self:Hide()
    end
end

-- Function to position bar based on talent spec.
local PlaceBar = function(bar)
    local spec = GetActiveTalentGroup()
    bar:ClearAllPoints()
    bar:SetPoint(bar.position[spec].attach_point, bar.position[spec].parentFrame, bar.position[spec].relative_point, bar.position[spec].xOffset, bar.position[spec].yOffset)
end

function caelTimers.CreateNewBar (spellList)
    local newId = (#bars or 0) + 1

end


function caelTimers.Create (spellName, unit, buffType, selfOnly, r, g, b, width, height, attach_point1, parentFrame1, relative_point1, xOffset1, yOffset1, attach_point2, parentFrame2, relative_point2, xOffset2, yOffset2, hide_name)
    local newId = (#bars or 0) + 1
    bars[newId] = CreateFrame("StatusBar", format("caelTimers_Bar_%d", newId), parentFrame)
    caelTimers.SmoothBar(bars[newId])
    bars[newId]:SetHeight(pixelScale(height))
    bars[newId]:SetWidth(pixelScale(width))
    bars[newId].spellName = spellName
    bars[newId].unit = unit
    bars[newId].buffType = buffType
    bars[newId].selfOnly = selfOnly
    bars[newId].hide_name = hide_name
    bars[newId].count     = 0
    bars[newId].active    = false
    bars[newId].expires   = 0
    bars[newId].duration  = 0
    bars[newId].timer     = 0
    
    -- Store values for each talent spec position.
    bars[newId].position = {
        -- Talent spec 1 references
        [1] = {
            attach_point   = attach_point1,
            parentFrame   = parentFrame1,
            relative_point = relative_point1,
            xOffset       = pixelScale(xOffset1),
            yOffset       = pixelScale(yOffset1)
        },
        -- Talent spec 2 references - default to spec 1 values if user did not provide them.
        [2] = {
            attach_point   = attach_point2   or attach_point1,
            parentFrame   = parentFrame2   or parentFrame1,
            relative_point = relative_point2 or relative_point1,
            xOffset       = pixelScale(xOffset2 and xOffset2 or xOffset1),
            yOffset       = pixelScale(yOffset2 and yOffset2 or yOffset1)
        }
    }
    
    bars[newId].tx = bars[newId]:CreateTexture(nil, "ARTWORK")
    bars[newId].tx:SetAllPoints()
    bars[newId].tx:SetTexture(media.files.statusBarC)
    -- Color bar with user values unless they enter nil values.  If so, then we color bar based on aura type
    if r and g and b then
        bars[newId].tx:SetVertexColor(r, g, b, 1)
    else
        bars[newId].auto_color = true
    end
    bars[newId]:SetStatusBarTexture(bars[newId].tx)

    bars[newId].soft_edge = CreateFrame("Frame", nil, bars[newId])
    bars[newId].soft_edge:SetPoint("TOPLEFT", pixelScale(-3.5), pixelScale(3.5))
    bars[newId].soft_edge:SetPoint("BOTTOMRIGHT", pixelScale(3.5), pixelScale(-3.5))
    bars[newId].soft_edge:SetBackdrop({
        bgFile = media.files.bgFile,
        edgeFile = media.files.edgeFile, edgeSize = pixelScale(3),
        insets = {left = pixelScale(3), right = pixelScale(3), top = pixelScale(3), bottom = pixelScale(3)}
    })
    bars[newId].soft_edge:SetFrameStrata("BACKGROUND")
    bars[newId].soft_edge:SetBackdropColor(0.25, 0.25, 0.25)
    bars[newId].soft_edge:SetBackdropBorderColor(0, 0, 0)

    bars[newId].bg = bars[newId]:CreateTexture(nil, "BORDER")
    bars[newId].bg:SetPoint("TOPLEFT")
    bars[newId].bg:SetPoint("BOTTOMRIGHT")
    bars[newId].bg:SetTexture(media.files.statusBarC)
    bars[newId].bg:SetVertexColor(0.25, 0.25, 0.25, 1)

    bars[newId].icon = bars[newId]:CreateTexture(nil, "BORDER")
    bars[newId].icon:SetHeight(height)
    bars[newId].icon:SetWidth(height)
    bars[newId].icon:SetPoint("TOPRIGHT", bars[newId], "TOPLEFT", 0, 0)
    bars[newId].icon:SetTexture(nil)
    
    bars[newId].text = bars[newId]:CreateFontString(format("caelTimers_Bartext_%d", newId), "OVERLAY")
    bars[newId].text:SetFont(media.fonts.NORMAL, 8)
    bars[newId].text:SetPoint("CENTER", bars[newId], "CENTER", 0, pixelScale(1))
    
    if ( SPARK ) then
        local spark = bars[newId]:CreateTexture(nil, "OVERLAY", nil);
        spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
        spark:SetWidth(12);
        spark:SetHeight(height);
        spark:SetBlendMode("ADD");
        spark:Show();
        bars[newId].spark = spark;
    end

    if ( CAST_SEPARATOR ) then
        local castSeparator = bars[newId]:CreateTexture( nil, "OVERLAY", nil );
        castSeparator:SetTexture( unpack( CAST_SEPARATOR_COLOR ) );
        castSeparator:SetWidth( 1 );
        castSeparator:SetHeight( height );
        castSeparator:Show();
        bars[newId].castSeparator = castSeparator;
    end

    PlaceBar(bars[newId])
    
    bars[newId]:Hide()
end

local CheckBuffs = function()
    for _, bar in pairs(bars) do
        local icon, count, duration, expiration, caster
        
        if bar.buffType == "buff" then
            _, _, icon, count, aura_type, duration, expiration, caster = UnitBuff(bar.unit, bar.spellName)
        else
            _, _, icon, count, aura_type, duration, expiration, caster = UnitDebuff(bar.unit, bar.spellName)
        end
        
        if icon and (not(bar.selfOnly) or (bar.selfOnly and (caster == "player"))) then
            --bar.icon:SetTexture(icon)
            bar.count = count
            bar.active = true
            bar.expires = expiration
            bar.duration = duration
            
            if duration and duration > 0 then
                bar:SetScript("OnUpdate", OnUpdate)
            else
                bar:SetScript("OnUpdate", nil)
                bar.text:SetText(format("%s%s", bar.spellName, bar.count > 1 and format("(%d)", bar.count) or ""))
            end
            
            -- If we need to color the bar automatically, do so.
            if bar.auto_color then
--              bar.tx:SetVertexColor(aura_colors[aura_type or "None"].r, aura_colors[aura_type or "None"].g, aura_colors[aura_type or "None"].b, 1)
                bar.tx:SetVertexColor(DebuffTypeColor[aura_type or "none"].r, DebuffTypeColor[aura_type or "none"].g, DebuffTypeColor[aura_type or "none"].b, 1)
            end
            
            bar:Show()
        end
    end
end

local OnCleu = function(...)
    local _, event, sourceGuid, _, _, destGuid, _, _, spellId, spellName = ...
    if spellId then
    
            if event == "SPELL_AURA_REMOVED" then
                for _, bar in pairs(bars) do
                    if destGuid == UnitGUID(bar.unit) and spellName == bar.spellName then
                        if not(bar.selfOnly) or (bar.selfOnly and (sourceGuid == UnitGUID("player"))) then
                            bar.count = 0
                            bar.active = false
                            bar.expires = 0
                            bar:Hide()
                        end
                    end
                end
            end
        
        return CheckBuffs()
    end
end

caelTimers.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
caelTimers.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
caelTimers.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelTimers.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
caelTimers.eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        for _, bar in pairs(bars) do
            if bar.unit == "target" then
                bar:Hide()
            end
        end
        CheckBuffs()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCleu(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        CheckBuffs()
    elseif event == "PLAYER_TALENT_UPDATE" then
        for index, _ in pairs(bars) do
            PlaceBar(bars[index])
        end
    end
end)