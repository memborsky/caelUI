-- Original TimerTracker work by Elv, modified for caelUI by Jankly

-- Dummy Bar: /run TimerTracker_OnLoad(TimerTracker); TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, 30, 30)

local addonName, caelCore = ...

-- Local Variables
local media = caelUI.media
local pixel_scale = caelUI.config.pixel_scale

local statusBarTexture = media.files.statusbar_e
local font = media.fonts.normal

-- Redefined the MirrorTimerColors list
MirrorTimerColors = {
    ["EXHAUSTION"]  = {r = 1,       g = 0.9,    b = 0},
    ["BREATH"]      = {r = 0.31,    g = 0.43,   b = 0.7},
    ["DEATH"]       = {r = 1,       g = 0.7,    b = 0},
    ["FEIGNDEATH"]  = {r = 1,       g = 0.7,    b = 0},
}

local function SkinBar(bar)
    local name = bar:GetName()
    local barType = "default"
    local color = {}

    -- Increase the size of the bars just ever so slightly.
    bar:SetHeight(pixel_scale(22))
    bar:SetWidth(pixel_scale(220))

    if name:find("MirrorTimer%d") then
        barType = "mirror"
    elseif name:find("TimerTracker") then
        barType = "tracker"
    end

    for index = 1, bar:GetNumRegions() do
        local region = select(index, bar:GetRegions())

        if region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
        elseif region:GetObjectType() == "FontString" then
            region:SetFont(font, 11, "THICKOUTLINE")
            region:SetShadowColor(0, 0, 0, 0)
            region:SetTextColor(1, 1, 1)

            -- Recenter the text into the middle of the bar.
            region:ClearAllPoints()
            region:SetAllPoints(bar)
        end
    end

    bar.backdrop = CreateFrame("Frame", nil, bar)
    bar.backdrop:SetFrameLevel(0)
    bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", pixel_scale(-2), pixel_scale(2))
    bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", pixel_scale(2), pixel_scale(-2))

    if barType == "tracker" then
        bar:SetStatusBarTexture(statusBarTexture)
    elseif barType == "mirror" then
        local statusbar = _G[name .. "StatusBar"]
        statusbar:SetStatusBarTexture(statusBarTexture)
        statusbar:SetAllPoints(bar)
    end

    bar.backdrop:SetBackdrop(media.backdrop_table)
    bar.backdrop:SetBackdropBorderColor(0, 0, 0)
    bar.backdrop:SetBackdropColor(0, 0, 0, 0.4)

    bar.skinned = true
end

local function SkinBlizzTimer(self, event)
    if event == "START_TIMER" then
        for _, b in pairs(TimerTracker.timerList) do
            local bar = b["bar"]

            if bar and not bar.skinned then
                SkinBar(bar)
            end
        end
    elseif event == "MIRROR_TIMER_START" then
        for index = 1, MIRRORTIMER_NUMTIMERS do
            local bar = _G["MirrorTimer" .. index]
            SkinBar(bar)

            -- Move the bars apart from each other just a little.
            if index ~= 1 then
                bar:SetPoint("TOP", _G["MirrorTimer" .. index - 1], "BOTTOM", 0, pixel_scale(-5))
            end
        end
    end
end

timer_bars = caelCore.createModule("timer_bars")
timer_bars:RegisterEvent("START_TIMER")
timer_bars:RegisterEvent("MIRROR_TIMER_START")
timer_bars:SetScript("OnEvent", function(self, event) SkinBlizzTimer(self, event) end)
