-- Original TimerTracker work by Elv, modified for caelUI by Jankly

-- Dummy Bar: /run TimerTracker_OnLoad(TimerTracker); TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, 30, 30)

local TimerBars = unpack(select(2, ...)).CreateModule("TimerBars")

-- Redefin the MirrorTimerColors
MirrorTimerColors = {
    ["EXHAUSTION"]  = {r = 1,       g = 0.9,    b = 0},
    ["BREATH"]      = {r = 0.31,    g = 0.43,   b = 0.7},
    ["DEATH"]       = {r = 1,       g = 0.7,    b = 0},
    ["FEIGNDEATH"]  = {r = 1,       g = 0.7,    b = 0},
}

local SkinBar

do
    local media = TimerBars:GetMedia()
    local PixelScale = TimerBars.PixelScale

    function SkinBar(bar)
        local name = bar:GetName()
        local barType = name:find("MirrorTimer%d") and "mirror" or "timer"

        -- Increase the size of the bars just ever so slightly.
        bar:SetHeight(PixelScale(22))
        bar:SetWidth(PixelScale(220))

        for index = 1, bar:GetNumRegions() do
            local region = select(index, bar:GetRegions())

            if region:GetObjectType() == "Texture" then
                region:SetTexture(nil)
            elseif region:GetObjectType() == "FontString" then
                region:SetFont(media.fonts.normal, 11, "THICKOUTLINE")
                region:SetShadowColor(0, 0, 0, 0)
                region:SetTextColor(1, 1, 1)

                -- Recenter the text into the middle of the bar.
                region:ClearAllPoints()
                region:SetAllPoints(bar)
            end
        end

        if barType == "timer" then
            bar:SetStatusBarTexture(media.files.statusbar_e)
            bar:SetStatusBarColor(bar:GetStatusBarColor())
        elseif barType == "mirror" then
            local statusbar = _G[name .. "StatusBar"]
            statusbar:SetStatusBarTexture(media.files.statusbar_e)
            statusbar:SetAllPoints(bar)
        end

        TimerBars.CreateBackdrop(bar)

        bar.skinned = true
    end
end

-- The two below blocks will make the entire skinning happen.
TimerBars:RegisterEvent("START_TIMER", function()
    for _, timer in next, TimerTracker.timerList do
        local bar = timer["bar"]

        if bar and not bar.skinned then
            SkinBar(bar, "timer")
        end
    end
end)

-- {EXHAUSTION, BREATH, DEATH, FEIGNDEATH}
TimerBars:RegisterEvent("MIRROR_TIMER_START", function()
    for index = 1, MIRRORTIMER_NUMTIMERS do
        local bar = _G["MirrorTimer" .. index]
        if not bar.skinned then
            SkinBar(bar, "mirror")
        end
    end
end)
