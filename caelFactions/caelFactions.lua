local _, caelFactions = ...

caelFactions.eventFrame = CreateFrame("Frame", nil, UIParent)

local factionName, factionValue
local standings = {}

local factionIncrease = FACTION_STANDING_INCREASED:gsub("%%s", "(.-)"):gsub("%%d", "(%%d+)")
local factionDecrease = FACTION_STANDING_DECREASED:gsub("%%s", "(.-)"):gsub("%%d", "(%%d+)")

local watchFaction = function(factionName, factionValue, increase)
    local current = GetWatchedFactionInfo()
    for i = 1, GetNumFactions() do
        local name, _, standingID, _, barMax, barValue = GetFactionInfo(i)
        local repToGo = barMax - barValue
        if name == factionName then
            if name ~= current then
                SetWatchedFactionIndex(i)
            end

            if StandingID == 8 and repToGo == 1 then
                SetFactionInactive(i)
            else
                if increase then
                    print(string.format("|cffD7BEA5cael|rFaction: %s: |cff559655%s%d|r (%d to |cff%02x%02x%02x%s|r)", name, "+", factionValue, repToGo, FACTION_BAR_COLORS[standingID].r * 255, FACTION_BAR_COLORS[standingID].g * 255, FACTION_BAR_COLORS[standingID].b * 255,(standingID < 8 and standings[standingID + 1] or "cap")))
                else
                    print(string.format("|cffD7BEA5cael|rFaction: %s: |cffAF5050%s%d|r (%d to |cff%02x%02x%02x%s|r)", name, "-", factionValue, repToGo, FACTION_BAR_COLORS[standingID].r * 255, FACTION_BAR_COLORS[standingID].g * 255, FACTION_BAR_COLORS[standingID].b * 255,(standingID < 8 and standings[standingID + 1] or "cap")))
                end
            end
        end
    end
end

caelFactions.eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
caelFactions.eventFrame:SetScript("OnEvent", function(self, event, msg)
    factionName, factionValue = string.match(msg, factionIncrease)
    if factionName then
        watchFaction(factionName, factionValue, true)
    end

    factionName, factionValue = string.match(msg, factionDecrease)
    if factionName then
        watchFaction(factionName, factionValue, false)
    end
end)

for i = 1, 8  do
    standings[i] = _G["FACTION_STANDING_LABEL"..i]
end
