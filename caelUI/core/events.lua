--[[
-- The original concept of this events engine was created by haste in his oUF addon.
-- This is a modified version of that system for usage in caelUI only.
-- His original version can be found at https://github.com/haste/oUF
--
-- This is our internal events system. This allows us to overload the same event for multiple frames
-- without having to handle the event management in the actual code.
--]]
local private = unpack(select(2, ...))

local argument_check = private.argument_check
local error = private.error

--[[
-- This is where all the magic happens for our events interface. We will register, unregister, and check to see if the event
-- is registered here. We also process the OnEvents as well.
--]]
local RegisterEvent, UnregisterEvent, IsEventRegistered

do
    local registry = {} -- This holds a list of events that have been registered.
    local event_frame = CreateFrame("Frame") -- Our master events frame.

    event_frame:SetScript("OnEvent", function(self, event, ...)
        local registered = registry[event]

        for frame in next, registered do
            if frame then
                frame[event](frame, event, ...)
            end
        end
    end)

    function RegisterEvent (self, event)
        if not registry[event] then
            registry[event] = {
                [self] = true
            }

            event_frame:RegisterEvent(event)
        else
            registry[event][self] = true
        end
    end

    function UnregisterEvent (self, event)
        if registry[event] then
            registry[event][self] = false

            if not next(registry[event]) then
                registry[event] = nil
                event_frame:UnregisterEvent(event)
            end
        end
    end

    function IsEventRegistered (self, event)
        return registry[event] and registry[event][self]
    end
end


-- This is the public interface to the above event registry system.
local events_metatable = {
    __index = CreateFrame("Frame"),

    __call = function(funcs, self, ...)
        for _, func in next, funcs do
            func(self, ...)
        end
    end
}

function events_metatable.__index:RegisterEvent (event, func)
    argument_check(event, 2, "string")

    if (type(func) == "string" and type(self[func]) == "function") then
        func = self[func]
    end

    local current_event = self[event]
    local kind = type(current_event)

    if (current_event and func) then
        if (kind == "function" and current_event ~= func) then
            self[event] = setmetatable({current_event, func}, events_metatable)
        elseif (kind == "table") then
            for _, infunc in next, current_event do
                if (infunc == func) then
                    return
                end
            end

            table.insert(current_event, func)
        end
    elseif (IsEventRegistered(self, event)) then
        return
    else
        if (type(func) == "function") then
            self[event] = func
        elseif (not self[event]) then
            return error("Trying to register event [%s] on frame [%s] that doesn't exist.", event, self.name or "unknown")
        end

        RegisterEvent(self, event)
    end
end

function events_metatable.__index:UnregisterEvent(event, func)
    argument_check(event, 2, "string")

    local current_event = self[event]

    if (type(current_event) == "table" and func) then
        for events, infunc in next, current_event do
            if (infunc == func) then
                table.remove(current_event, events)

                if (#current_event == 1) then
                    local _, handler = next(current_event)
                    self[event] = handler
                elseif (#current_event == 0) then
                    UnregisterEvent(self, event)
                end

                break
            end
        end
    elseif (current_event == func) then
        self[event] = nil
        UnregisterEvent(self, event)
    end
end

function events_metatable.__index:IsEventRegistered(event)
    return IsEventRegistered(self, event)
end

-- This sets up our private.events table as an object child of events_metatable.
private.events = setmetatable({}, events_metatable)
