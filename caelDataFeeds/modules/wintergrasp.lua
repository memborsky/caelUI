if UnitLevel("player") ~= MAX_PLAYER_LEVEL then return end

local _, caelDataFeeds = ...

local wgtimer = caelDataFeeds.createModule("WintergraspTimer", Minimap)

local pixelScale = caelUI.pixelScale

wgtimer.text:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, pixelScale(5))
wgtimer.text:SetParent(Minimap)

local delay = 0
wgtimer:SetScript("OnUpdate", function(self, elapsed)
    delay = delay - elapsed
    if delay < 0 then
        local inInstance, instanceType = IsInInstance()
        local _, localizedName, isActive, canQueue, startTime = GetWorldPVPAreaInfo(1)

        if inInstance == nil then
            if startTime > 0 and not isActive then
                local nextBattleTime = SecondsToTime(startTime)

                if nextBattleTime and startTime > 9e2 then
                    self.text:SetFormattedText("|cffD7BEA5"..localizedName..":|r %s", nextBattleTime)
                else
                    self.text:SetText("|cffD7BEA5"..localizedName..":|r Available")
                end
            elseif isActive and canQueue then
                self.text:SetText("|cffD7BEA5"..localizedName..":|r In progress")
            end
        else
            self.text:SetText("|cffD7BEA5"..localizedName..":|r Unavailable")
        end
        delay = 1
    end
end)
