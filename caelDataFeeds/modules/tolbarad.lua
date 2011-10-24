if UnitLevel("player") ~= MAX_PLAYER_LEVEL or (UnitLevel("pet") ~= 0 and UnitLevel("pet") ~= MAX_PLAYER_LEVEL) then return end

local _, caelDataFeeds = ...

local tbtimer = caelDataFeeds.createModule("TolBaradTimer")

local pixel_scale = caelUI.config.pixel_scale

tbtimer:SetFrameStrata("HIGH")
tbtimer.text:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, pixel_scale(5))
tbtimer.text:SetParent(Minimap)

tbtimer.text:SetShadowColor(0, 0, 0)
tbtimer.text:SetShadowOffset(pixel_scale(1), pixel_scale(-1))

local delay = 0
tbtimer:SetScript("OnUpdate", function(self, elapsed)
    delay = delay - elapsed
    if delay < 0 then
        local inInstance, instanceType = IsInInstance()
        local _, localizedName, isActive, canQueue, startTime = GetWorldPVPAreaInfo(2)

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
