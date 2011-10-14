if UnitLevel("player") == MAX_PLAYER_LEVEL and (UnitLevel("pet") == 0 or UnitLevel("pet") == MAX_PLAYER_LEVEL) then return end

local _, caelDataFeeds = ...

local experience = caelDataFeeds.createModule("Experience")

local pixelScale = caelUI.pixelScale

experience.text:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", pixelScale(5), pixelScale(5))
experience:SetFrameLevel(Minimap:GetFrameLevel() + 2)
experience:SetFrameStrata("MEDIUM")
experience.text:SetParent(Minimap)
--experience.text:SetFrameLevel(Minimap:GetFrameLevel() + 2)

experience:RegisterEvent("UNIT_PET")
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

    local petXp, petMaxXp

    local xp = UnitXP("player")
    local maxXp = UnitXPMax("player")
    local restedXp = GetXPExhaustion()

    if UnitGUID("pet") then
        petXp, petMaxXp = GetPetExperience()
    end

    local xpString

    if not petMaxXp or petMaxXp == 0 then
        --xpString = format("|cffD7BEA5xp|r %.1f%%", ((xp/maxXp)*100))
        xpString = format("|cffD7BEA5xp|r "..(restedXp and "|cff5073a0%.1f%%|r" or "|cffffffff%.1f%%|r"), ((xp/maxXp)*100))
    elseif UnitLevel("player") == MAX_PLAYER_LEVEL and UnitLevel("pet") ~= MAX_PLAYER_LEVEL then
        xpString = format("|cffd7bea5pet|r " .. ("|cffffffff%.1f%%|r"), ((petXp/petMaxXp)*100))
    else
        --xpString = string.format("|cffD7BEA5xp|r %.1f%% |cffD7BEA5pet|r %.0f%%", ((xp/maxXp)*100), ((petXp/petMaxXp)*100))
        xpString = format("|cffD7BEA5xp|r "..(restedXp and "|cff5073a0%.1f%%|r " or "|cffffffff%.1f%%|r ").."|cffD7BEA5pet|r %.0f%%", ((xp/maxXp)*100), ((petXp/petMaxXp)*100))
    end

    experience.text:SetFont(caelUI.get_database("media")["fonts"]["NORMAL"], 10, "OUTLINE")
    experience.text:SetText(xpString)

    if retVal then
        return format("|cffD7BEA5player|r %s / %s", xp, maxXp), (petMaxXp and petMaxXp > 0) and format("|cffD7BEA5pet|r %s / %s", petXp, petMaxXp) or nil
    end
end

experience:SetScript("OnEvent", function(...) OnEvent(false, ...) end)

experience:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, pixelScale(4))
    local playerXp, petXp = OnEvent(true)
    GameTooltip:AddLine(playerXp)
    if petXp then
        GameTooltip:AddLine(petXp)
    end
    GameTooltip:Show()
end)
