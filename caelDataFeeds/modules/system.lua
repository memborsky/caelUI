--[[    $Id: system.lua 1728 2010-11-18 23:23:58Z sdkyron@gmail.com $    ]]

local _, caelDataFeeds = ...

local system = caelDataFeeds.createModule("System")

local pixelScale = caelUI.pixelScale

system.text:SetPoint("LEFT", caelPanel_DataFeed, "LEFT", pixelScale(10), 0)

local Addons = {}

local format = string.format

local AddonsMemoryCompare = function(a, b)
    return Addons[a] > Addons[b]
end

local FormatMemoryNumber = function(number)
    if number > 1000 then
        return format("%.2f |cffD7BEA5mb|r", number / 1000)
    else
        return format("%.1f |cffD7BEA5kb|r", number)
    end
end

local ColorizeLatency = function(number)
    if number <= 100 then
        return {r = 0.33, g = 0.59, b = 0.33}
    elseif number <= 200 then
        return {r = 0.65, g = 0.63, b = 0.35}
    else
        return {r = 0.69, g = 0.31, b = 0.31}
    end
end

local memory, addon, i
local latency, totalMemory
local memText, lagText, fpsText
local function UpdateMemory(self)
    totalMemory = 0
    UpdateAddOnMemoryUsage()

    for i = 1, GetNumAddOns(), 1 do
        if IsAddOnLoaded(i) then
            memory = GetAddOnMemoryUsage(i)
            Addons[GetAddOnInfo(i)] = memory 
            totalMemory = totalMemory + memory
        end
    end
end

local delta = 5
local maxLatency = 400
local delay1, delay2 = 0, 0
local lowThreshold, highThreshold = 0, 0

system:SetScript("OnUpdate", function(self, elapsed)
    delay1 = delay1 - elapsed
    delay2 = delay2 - elapsed

    latency = select(4, GetNetStats())
    local latencyColor = ColorizeLatency(latency)

    if delay1 < 0 then
        UpdateMemory(self)
        memText = FormatMemoryNumber(totalMemory)

        lagText = format("|cff%02x%02x%02x%s|r |cffD7BEA5ms|r", latencyColor.r * 255, latencyColor.g * 255, latencyColor.b * 255, latency)

        if latency > maxLatency then latency = maxLatency end

        if latency <= lowThreshold or latency >= highThreshold then
            SetCVar("MaxSpellStartRecoveryOffset", latency)
            lowThreshold = latency - delta
            highThreshold = latency + delta
        end

        delay1 = 5
    end

    if delay2 < 0 then
        fpsText = format("%.1f |cffD7BEA5fps|r", GetFramerate())
        self.text:SetFormattedText("%s - %s - %s", memText, lagText, fpsText)
        delay2 = 1
    end
end)

system:SetScript("OnEnter", function(self)
    if IsShiftKeyDown() then
        GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, pixelScale(4))

        local SortingTable = {}
        for name in pairs(Addons) do
            SortingTable[#SortingTable + 1] = name
        end
        table.sort(SortingTable, AddonsMemoryCompare)

        local i = 0
        for _, addon in ipairs(SortingTable) do
            GameTooltip:AddDoubleLine(addon, FormatMemoryNumber(Addons[addon]), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)

            i = i + 1

            if i >= 50 then
                break
            end
        end

        GameTooltip:AddDoubleLine("---------- ----------", "---------- ----------", 0.55, 0.57, 0.61, 0.55, 0.57, 0.61)
        GameTooltip:AddDoubleLine("Addon Memory Usage", FormatMemoryNumber(totalMemory), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)
        GameTooltip:Show()
    end
end)

system:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        local collected = collectgarbage("count")
        collectgarbage("collect")
        GameTooltip:AddDoubleLine("---------- ----------", "---------- ----------", 0.55, 0.57, 0.61, 0.55, 0.57, 0.61)
        GameTooltip:AddDoubleLine("Garbage Collected:", FormatMemoryNumber(collected - collectgarbage("count")), 0.84, 0.75, 0.65, 0.65, 0.63, 0.35)
        GameTooltip:Show()
    end
end)
