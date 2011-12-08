local _, caelCooldowns = ...

local minScale = 0.5
local minDuration = caelUI.config.player.class == "HUNTER" and 1 or 1.5
local pixel_scale = caelUI.config.pixel_scale

local format = string.format
local floor = math.floor
local min = math.min

local day, hour, minute = 86400, 3600, 60

local function GetFormattedTime (time)
    if time >= day then
        return format("%dd", floor(time / day + 0.5)), time % day
    elseif time >= hour then
        return format("%dh", floor(time / hour + 0.5)), time % hour
    elseif time >= minute then
        local result = format("%dm", floor(time / minute + 0.5)), time % minute

        if time <= minute * 5 then
            result = format("%d:%02d", floor(time / 60), time % minute), time - floor(time)
        end

        return result
    elseif time >= minute / 12 then
        return floor(time + 0.5), (time * 100 - floor(time * 100))/100
    end

    return format("%.1f", time), (time * 100 - floor(time * 100))/100
end

local function TimerUpdate (self, elapsed)
    if self.text:IsShown() then

        if self.nextUpdate > 0 then
            self.nextUpdate = self.nextUpdate - elapsed
        else
            if (self:GetEffectiveScale() / UIParent:GetEffectiveScale()) < minScale then
                self.text:SetText("")
                self.nextUpdate = 1
            else
                local remain = self.duration - (GetTime() - self.start)

                if floor(remain + 0.5) > 0 then
                    local time, nextUpdate = GetFormattedTime(remain)

                    self.text:SetText(time)
                    self.nextUpdate = nextUpdate or 0
                else
                    self.text:Hide()
                end
            end
        end
    end
end

local function TimerCreate (self)
    local scale = min(self:GetParent():GetWidth() / 32, 1)

    if scale < minScale then
        self.noOCC = true
    else
        local text = self:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", pixel_scale(2), 0)
        text:SetJustifyH("CENTER")
        text:SetFont(caelUI.media.fonts.normal, 13 * scale, "THICKOUTLINE")
        text:SetTextColor(244 / 255, 250 / 255, 210 / 255)

        self.text = text
        self:HookScript("OnHide", function(self) self.text:Hide() end)
        self:SetScript("OnUpdate", TimerUpdate)
        return text
    end
end

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", function(self, start, duration)
    if self.noOCC then return end

    if start > 0 and duration > 1.5 then
        local text = self.text or TimerCreate(self)
        self.start = start
        self.duration = duration
        self.nextUpdate = 0

        if text then
            text:Show()
        end
    else
        if self.text then
            self.text:Hide()
        end
    end
end)

-- Hides the GCD animation for abilities that don't have a cooldown but are just the GCD cooldown.
-- XXX: This currently does not work and still shows the GCD timer.
-- hooksecurefunc("CooldownFrame_SetTimer", function(self, start, duration, enable)
--     if enable > 0 and duration == minDuration then
--         self:SetAlpha(0)
--     else
--         self:SetAlpha(1)
--     end
-- end)

-- XXX: Hack to get SetCooldown to work again
if ActionBarButtonEventsFrame.frames then
    local hooked = {}
    local active = {}

    local EventFrame = CreateFrame('Frame'); EventFrame:Hide()
    EventFrame:SetScript('OnEvent', function(self, event)
        for cooldown in pairs(active) do
            local button = cooldown:GetParent()
            local start, duration, enable = GetActionCooldown(button.action)
            cooldown:SetCooldown(start, duration)
        end
    end)
    EventFrame:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')

    local function Cooldown_OnShow(self)
        active[self] = true
    end

    local function Cooldown_OnHide(self)
        active[self] = nil
    end

    local function ActionButton_Register(frame)
        local cooldown = frame.cooldown
        if not hooked[cooldown] then
            cooldown:HookScript('OnShow', Cooldown_OnShow)
            cooldown:HookScript('OnHide', Cooldown_OnHide)
            hooked[cooldown] = true
        end
    end

    for _, frame in next, ActionBarButtonEventsFrame.frames do
        ActionButton_Register(frame)
    end

    hooksecurefunc('ActionBarButtonEventsFrame_RegisterFrame', ActionButton_Register)
end