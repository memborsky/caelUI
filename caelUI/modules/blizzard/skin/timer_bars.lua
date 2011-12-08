-- Original TimerTracker work by Elv, modified for caelUI by Jankly

-- Dummy Bar: /run TimerTracker_OnLoad(TimerTracker); TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, 30, 30)

local private = unpack(select(2, ...))

-- Redefin the MirrorTimerColors
MirrorTimerColors = {
    ["EXHAUSTION"]  = {r = 1,       g = 0.9,    b = 0},
    ["BREATH"]      = {r = 0.31,    g = 0.43,   b = 0.7},
    ["DEATH"]       = {r = 1,       g = 0.7,    b = 0},
    ["FEIGNDEATH"]  = {r = 1,       g = 0.7,    b = 0},
}

local SkinBar

do
    local media = private.GetDatabase("media")
    local pixel_scale = private.pixel_scale

    function SkinBar(bar)
        local name = bar:GetName()
        local barType = name:find("MirrorTimer%d") and "mirror" or "timer"

        -- Increase the size of the bars just ever so slightly.
        bar:SetHeight(pixel_scale(22))
        bar:SetWidth(pixel_scale(220))

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

        bar.backdrop = CreateFrame("Frame", nil, bar)
        bar.backdrop:SetFrameLevel(bar:GetFrameLevel() - 1)
        bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", pixel_scale(-2), pixel_scale(2))
        bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", pixel_scale(2), pixel_scale(-2))
        bar.backdrop:SetBackdrop(media.backdrop_table)
        bar.backdrop:SetBackdropBorderColor(0, 0, 0)
        bar.backdrop:SetBackdropColor(0, 0, 0, 0.4)

        bar.skinned = true
    end
end

-- The two below blocks will make the entire skinning happen.
private.events:RegisterEvent("START_TIMER", function()
    for _, timer in next, TimerTracker.timerList do
        local bar = timer["bar"]

        if bar and not bar.skinned then
            SkinBar(bar, "timer")
        end
    end
end)

-- {EXHAUSTION, BREATH, DEATH, FEIGNDEATH}
private.events:RegisterEvent("MIRROR_TIMER_START", function()
    for index = 1, MIRRORTIMER_NUMTIMERS do
        local bar = _G["MirrorTimer" .. index]
        if not bar.skinned then
            SkinBar(bar, "mirror")
        end
    end
end)
