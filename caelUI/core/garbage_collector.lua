-- Only return true of we are in combat and have 25k+ events since our last garbage clean
-- -OR-
-- we are at 10k+ events since our last garbage clean outside of combat.
local function check_event_counter (current_event_count)
    if (InCombatLockdown() and current_event_count > 25000) or current_event_count > 10000 then
        return true
    end
end

-- Our event counter.
local event_counter = 0
local garbage_collector = CreateFrame("Frame")

garbage_collector:RegisterAllEvents()
garbage_collector:SetScript("OnEvent", function()
    event_counter = event_counter + 1

    if check_event_counter(event_counter) then
        collectgarbage("collect")
        event_counter = 0
    end
end)
