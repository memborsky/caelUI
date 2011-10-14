local _, caelCooldowns = ...

local minScale = 0.5
local minDuration = caelUI.config.player.class == "HUNTER" and 1 or 1.5

local format = string.format
local floor = math.floor
local min = math.min

local day, hour, minute = 86400, 3600, 60

local GetFormattedTime = function(s)
    if s >= day then
        return format("%dd", floor(s/day + 0.5)), s % day
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5)), s % hour
    elseif s >= minute then
        if s <= minute * 5 then
            return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
--          return format("%d.%d", mm, ss), s - floor(s)
        end
        return format("%dm", floor(s/minute + 0.5)), s % minute
    elseif s >= minute / 12 then
        return floor(s + 0.5), (s * 100 - floor(s * 100))/100
--      return floor(s + 0.5), s - floor(s)
    end
    return format("%.1f", s), (s * 100 - floor(s * 100))/100
--  return floor(s*10)/10, 0.02 -- s-floor(s*10)/20
end

local timerUpdate = function(self, elapsed)
    if self.text:IsShown() then
        if self.nextUpdate > 0 then
            self.nextUpdate = self.nextUpdate - elapsed
        else
            if (self:GetEffectiveScale()/UIParent:GetEffectiveScale()) < minScale then
                self.text:SetText("")
                self.nextUpdate = 1
            else
                local remain = self.duration - (GetTime() - self.start)
                if floor(remain + 0.5) > 0 then
                    local time, nextUpdate = GetFormattedTime(remain)
                    self.text:SetText(time)
                    self.nextUpdate = nextUpdate
                else
                    self.text:Hide()
                end
            end
        end
    end
end

local timerCreate = function(self)
    local scale = min(self:GetParent():GetWidth() / 32, 1)
    if scale < minScale then
        self.noOCC = true
    else
        local text = self:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", 0, 1)
        text:SetFont(caelUI.media.fonts.NORMAL, 12 * scale, "OUTLINE")
        text:SetTextColor(0.84, 0.75, 0.65)

        self.text = text
        self:HookScript("OnHide", function(self) self.text:Hide() end)
        self:SetScript("OnUpdate", timerUpdate)
        return text
    end
end

local timerStart = function(self, start, duration)
    self.start = start
    self.duration = duration
    self.nextUpdate = 0

    local text = self.text or (not self.noOCC and timerCreate(self))
    if text then
        text:Show()
    end
end

local methods = getmetatable(_G["ActionButton1Cooldown"]).__index
hooksecurefunc(methods, "SetCooldown", function(self, start, duration)
    if self.ocd then return end
    if start > 0 and duration > minDuration then
        timerStart(self, start, duration)
    else
        local text = self.text
        if text then
            text:Hide()
        end
    end
end)

--[[
hooksecurefunc("CooldownFrame_SetTimer", function(self, start, duration, enable)
    if enable > 0 and duration == minDuration then
        self:SetAlpha(0)
    else
        self:SetAlpha(1)
    end
end)
--]]
