if UnitLevel("player") == MAX_PLAYER_LEVEL and (UnitLevel("pet") == 0 or UnitLevel("pet") == MAX_PLAYER_LEVEL) then return end

local _, caelDataFeeds = ...

local experience = caelDataFeeds.createModule("Experience")

local PixelScale = caelUI.config.PixelScale

experience.text:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", PixelScale(5), PixelScale(5))
experience:SetFrameLevel(Minimap:GetFrameLevel() + 2)
experience:SetFrameStrata("MEDIUM")
experience.text:SetParent(Minimap)
--experience.text:SetFrameLevel(Minimap:GetFrameLevel() + 2)

experience:RegisterEvent("UNIT_LEVEL")
experience:RegisterEvent("UNIT_EXPERIENCE")
experience:RegisterEvent("PLAYER_XP_UPDATE")
experience:RegisterEvent("PLAYER_ENTERING_WORLD")
experience:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

local format, find, tonumber = string.format, string.find, tonumber

local lastXp, a, b = 0
local OnEvent = function(retVal, self, event, ...)
    if event == "CHAT_MSG_COMBAT_XP_GAIN" then
        _, _, lastXp = find(select(1, ...), ".*gain (.*) experience.*")
        lastXp = tonumber(lastXp)
        return
    end

    local xp = UnitXP("player")
    local maxXp = UnitXPMax("player")
    local restedXp = GetXPExhaustion()

    experience.text:SetFont(caelUI.media.fonts.normal, 10, "OUTLINE")
    experience.text:SetText(format("|cffD7BEA5xp|r "..(restedXp and "|cff5073a0%.1f%%|r" or "|cffffffff%.1f%%|r"), ((xp/maxXp)*100)))

end

experience:SetScript("OnEvent", function(...) OnEvent(false, ...) end)

experience:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, PixelScale(4))
    GameTooltip:AddLine(playerXp)
    GameTooltip:Show()
end)
