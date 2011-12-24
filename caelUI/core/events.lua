--[[
-- The original concept of this events engine was created by haste in his oUF addon.
-- This is a modified version of that system for usage in caelUI only.
-- His original version can be found at https://github.com/haste/oUF
--
-- This is our internal events system. This allows us to overload the same frame for multiple events
-- without having to handle the event management on a bunch of different frames.
--]]
local private = unpack(select(2, ...))

local argument_check = private.argument_check
local error = private.error

--[[
The registry for our all of our events. We can allow multiple functions to be registered to the same event this way.
--]]
local RegisterEvent, UnregisterEvent, IsEventRegistered

local Registered_Events = {}
local Event_Frame = CreateFrame("Frame")

local events_metatable = {
    __index = {}
}

Event_Frame:SetScript("OnEvent", function(self, event, ...)
    if Registered_Events[event] then
        for _, func in pairs(Registered_Events[event]) do
            func(self, event, ...)
        end
    end
end)

--[[
Public: Handles the registration of the function to the event.

self - The frame we are operating on.
event - The event we are registering for.
func - The function we are registering to the event.

Examples

    private.events:RegisterEvent("PLAYER_ENTERING_WORLD", function() private.print("Hello World!") end)
    # => 'Hello World!' is displayed in the players default chat window.
--]]
function events_metatable.__index:RegisterEvent(events, func, name)
    argument_check(events, 2, "string", "table")

    if not func then
        private.error(string.format("Attempted to register event [%s] with no function.", type(events) == "string" and events or "{" .. unpack(events) .. "}"))
    end

    if type(events) == "table" then
        for _, event in pairs(events) do
            self:RegisterEvent(event, func, name)
        end
    else
        if not Registered_Events[events] then
            Registered_Events[events] = {}
            Event_Frame:RegisterEvent(events)
        end

        if name then
            Registered_Events[events][name] = func
        else
            table.insert(Registered_Events[events], func)
        end
    end
end

--[[
Public: Handles the un-registration of the event and possible function to the event.

self - The frame we are operating on.
event - The event we are unregistering for.
func - The function we are unregistering to the event.

Examples

    private.events:UnregisterEvent("PLAYER_ENTERING_WORLD", function() private.print("Hello World!") end)
--]]
function events_metatable.__index:UnregisterEvent(events, name)
    argument_check(events, 2, "string", "table")

    if type(events) == "table" then
        for _, event in pairs(events) do
            self:UnregisterEvent(event, name)
        end
    else
        if Registered_Events[events] and Registered_Events[events][name] then
            Registered_Events[events][name] = false

            if not next(Registered_Events[events]) then
                Registered_Events[events][name] = nil
                Event_Frame:UnregisterEvent(events)
            end
        end
    end
end

--[[
Public: Checks to see if the event is registered.

self - The frame we are operating on.
event - The event we are unregistering for.

Examples

    private.events:IsEventRegistered("PLAYER_ENTERING_WORLD")

Returns boolean value.
--]]
function events_metatable.__index:IsEventRegistered(event, name)
    if Registered_Events[event] and Registered_Events[event][name] then
        return true
    end

    return false
end

-- This sets up our private.events table as an object child of events_metatable.
private.events = setmetatable({}, events_metatable)
