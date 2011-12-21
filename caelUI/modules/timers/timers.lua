local Timers = unpack(select(2, ...)).NewModule("ClassTimers", true)

local media = Timers:GetMedia()

local BAR_HEIGHT = 25

--[[
local aura_colors  = {
    ["Magic"]   = {r = 0.00, g = 0.25, b = 0.45}, 
    ["Disease"] = {r = 0.40, g = 0.30, b = 0.10}, 
    ["Poison"]  = {r = 0.00, g = 0.40, b = 0.10}, 
    ["Curse"]   = {r = 0.40, g = 0.00, b = 0.40},
    ["None"]    = {r = 0.69, g = 0.31, b = 0.31}
}
--]]

do 
    local frame = CreateFrame("Frame", Timers:GetName() .. "PlayerFrame", Timers)
    Timers.SetPoint(frame, "BOTTOM", UIParent, "BOTTOM", -278.5, 370)
    Timers.SetSize(frame, 230, 600)
    frame:Show()

    frame = CreateFrame("Frame", Timers:GetName() .. "TargetFrame", Timers)
    Timers.SetPoint(frame, "BOTTOM", UIParent, "BOTTOM", 278.5, 370)
    Timers.SetSize(frame, 230, 600)
    frame:Show()
end

local bar_prototype = {
    __index = {},
    height = BAR_HEIGHT,
    width = 100
}

local bars = {}
caelTimers = bars

do
    timers_metatable = getmetatable(Timers).__index

    for key, value in next, timers_metatable do
        bar_prototype.__index[key] = value
    end
end

function bar_prototype.__index:Create(spellId, unit, buffType, playerOnly, autoColor, frame)
    local bar = CreateFrame("StatusBar", string.format(Timers:GetName() and Timers:GetName() .. "Bar%d" or "TimerBar%d", (#bars + 1 or 0)), _G[Timers:GetName() .. frame:gsub("%a", string.upper, 1) .. "Frame"])

    -- SmoothBar(bar)
    bar:SetPoint("BOTTOMRIGHT", bar:GetParent(), "BOTTOMRIGHT")
    self.SetSize(bar, bar:GetParent():GetWidth() - BAR_HEIGHT, BAR_HEIGHT)
    bar:CreateBackdrop(bar:GetName())

    bar.texture = bar:CreateTexture(nil, "ARTWORK")
    bar.texture:SetAllPoints()
    bar.texture:SetTexture(media.files.statusbar_g)

    if buffType == "debuff" then
        bar.texture:SetVertexColor(0.69, 0.31, 0.31, 1)
    else
        bar.texture:SetVertexColor(0.33, 0.59, 0.33, 1)
    end

    bar.icon = bar:CreateTexture("$parentIcon", "BACKGROUND")
    self.SetSize(bar.icon, BAR_HEIGHT)
    self.SetPoint(bar.icon, "RIGHT", bar, "LEFT", -5, 0)
    bar.icon:SetTexture(nil)
    bar.icon:CreateBackdrop(bar.icon:GetName())

    bar:SetStatusBarTexture(bar.texture)

    bar.spell = bar:CreateFontString("$parentSpellName", "OVERLAY")
    bar.spell:SetFont(media.fonts.normal, 9)
    bar.spell:SetText(GetSpellInfo(spellId))
    self.SetPoint(bar.spell, "LEFT", bar, "LEFT", 3, 0)
    bar.spell:SetJustifyH("LEFT")

    bar.stacks = bar:CreateFontString("$parentStackCount", "OVERLAY")
    bar.stacks:SetFont(media.fonts.normal, 9)
    self.SetPoint(bar.stacks, "LEFT", bar.spell, "RIGHT")
    bar.stacks:SetJustifyH("LEFT")

    bar.time = bar:CreateFontString("$parentTimer", "OVERLAY")
    bar.time:SetFont(media.fonts.normal, 9)
    self.SetPoint(bar.time, "RIGHT", bar, "RIGHT", -3, 0)
    bar.time:SetJustifyH("RIGHT")

    bar.spark = bar:CreateTexture("$parentSpark", "OVERLAY")
    bar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
    self.SetWidth(bar.spark, 15)
    bar.spark:SetBlendMode("ADD")
    bar.spark:Show()

    bar.spellId    = spellId
    bar.unit       = unit
    bar.buffType   = buffType
    bar.playerOnly = playerOnly
    bar.autoColor  = autoColor
    bar.count      = 0
    bar.active     = false
    bar.expiration = 0
    bar.duration   = 0
    bar.auraType   = buffType == "debuff" and "HARMFUL" or "HELPFUL"

    bar.Update = function(self)
        local _, _, icon, count, _, duration, expiration = UnitAura(self.unit, GetSpellInfo(self.spellId), nil, self.playerOnly and "PLAYER|" .. self.auraType or self.auraType)

        if icon then
            self.icon:SetTexture(icon)
            self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            self.count = count
            self.expiration = expiration or 0
            self.duration = duration

            if self.buffType == "debuff" and self.autoColor then
                -- self.tx:SetVertexColor(aura_colors[aura_type or "None"].r, aura_colors[aura_type or "None"].g, aura_colors[aura_type or "None"].b, 1)
                self.texture:SetVertexColor(DebuffTypeColor[self.auraType or "none"].r, DebuffTypeColor[self.auraType or "none"].g, DebuffTypeColor[self.auraType or "none"].b, 1)
            end

            return true
        end

        return false
    end

    bar.Enable = function(self)
        self.active = true
        self:SetScript("OnUpdate", self.OnUpdate)
        self:Show()
    end

    bar.Disable = function(self)
        self.count = 0
        self.expiration = 0
        self.duration = 0
        self.active = false
        self:SetScript("OnUpdate", nil)
        self:Hide()
    end

    bar.OnUpdate = function(self)
        local time = GetTime()

        if self.active and self.expiration >= time then
            local remaining = self.expiration - time

            self:SetValue(remaining)
            self:SetMinMaxValues(0, self.duration)

            self.stacks:SetText(string.format("%s", self.count > 1 and string.format(" - %d", self.count) or ""))
            self.time:SetText(string.format("%s", Timers:FormatTime(remaining)))

            self.SetPoint(self.spark, "CENTER", self, "LEFT", self:GetWidth() * remaining / self.duration, 0)
        end
    end

    bar:RegisterEvent("UNIT_AURA")
    bar:SetScript("OnEvent", function(self, _, unit)
        if self.active and self.unit == unit then
            if not self:Update() then
                self:Disable()
            end
        end
    end)

    -- Make sure the bar gets hidden.
    bar:Hide()

    return bar
end

local function UpdateBars(unit)

    local frame = _G[Timers:GetName() .. unit:gsub("%a", string.upper, 1) .. "Frame"]
    local children  = { frame:GetChildren() }

    -- Sort the bars.
    do
        local time = GetTime()
        local sorted

        repeat
            sorted = true

            for key, value in pairs(children) do
                local nextBar = key + 1
                local nextBarValue = bars[nextBar]

                if nextBarValue == nil then
                    break
                end

                local currentRemaining = value.expiration == 0 and 4294967295 or math.max(value.expiration - time, 0)
                local nextRemaining = nextBarValue.expiration == 0 and 4294967295 or math.max(nextBarValue.expiration - time, 0)

                if currentRemaining < nextRemaining then
                    bars[key] = nextBarValue
                    bars[nextBar] = value
                    sorted = false
                end
            end

        until (sorted == true)
    end

    -- Redisplay the bars in the right location.
    do
        local last = nil

        for _, bar in pairs(children) do
            if bar.active then
                if not last then
                    bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
                else
                    bar:SetPoint("BOTTOMRIGHT", last, "TOPRIGHT", 0, 5)
                end

                last = bar
            end
        end
    end
end

function Timers:CreateList (list)
    local bar_table = setmetatable({}, bar_prototype)

    -- Create and save the bar we create to the bars table.
    for frame, barsList in pairs(list) do
        for _, bar in pairs(barsList) do
            table.insert(bars, bar_table:Create(bar.spellId, bar.unit, bar.buffType, bar.playerOnly, bar.autoColor, frame))
        end
    end
end

Timers:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    for _, bar in pairs(bars) do
        if bar.unit == "player" and bar:Update() then
            bar:Enable()
        end
    end

    UpdateBars("player")
end)

Timers:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, _, _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId)

    local unit

    if spellId and subEvent == "SPELL_AURA_APPLIED" then
        for _, bar in pairs(bars) do
            if destGUID == UnitGUID(bar.unit) and spellId == bar.spellId then
                unit = bar.unit
                bar:Enable()
                bar:Update()
                break
            end
        end

        if unit then
            UpdateBars(unit)
        end

    end
end)

-- If a new target exists, we update the bars, else we disable all the target bars.
Timers:RegisterEvent("PLAYER_TARGET_CHANGED", function()
    if UnitExists("target") then
        for _, bar in pairs(bars) do
            if bar.unit == "target" then
                if bar:Update() then
                    bar:Enable()
                else
                    bar:Disable()
                end
            end
        end
    else
        for _, bar in pairs(bars) do
            if bar.unit == "target" then
                bar:Disable()
            end
        end
    end

    UpdateBars("target")
end)

Timers:RegisterModule("ClassTimers")
