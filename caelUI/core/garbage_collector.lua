-- Only return true of we are in combat and have 25k+ events since our last garbage clean
-- -OR-
-- we are at 10k+ events since our last garbage clean outside of combat.
local function checkCount (currentCount)
    if (InCombatLockdown() and eventCount > 25000) or eventCount > 10000 then
        return true
    end
end

-- Our event counter.
local eventCount = 0
local garbageCollector = CreateFrame("Frame")

garbageCollector:RegisterAllEvents()
garbageCollector:SetScript("OnEvent", function(self, event)
    eventCount = eventCount + 1

    if checkCount(eventCount) then
        collectgarbage("collect")
        eventCount = 0        
    end
end)
