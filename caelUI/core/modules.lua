local private = unpack(select(2, ...))

-- Localized variables
local PixelScale = private.PixelScale
local media = private.media
local databases = private.GetDatabase()
local argument_check = private.argument_check

-- We use this to reference a blank frame for calling frame related functions when we modify them.
local reference_frame = CreateFrame("Frame")

local module_metatable = {
    __index = {},

    __call = function(funcs, self, ...)
        for _, func in next, funcs do
            func(self, ...)
        end
    end
}

--[[
Public: Print the text into the chatbox.

... - The formatted text that we will print to the chatbox

Examples:
    <module>:Print("Hello World!")
    # => 'Hello World!'

Returns nothing
--]]
function module_metatable.__index:Print(...)
    local name = self.name or "UI"

    private.print(name, ...)
end

-- Rebind our event table functions to our module frame.
function module_metatable.__index.RegisterEvent(self, event, func, name)
    if not name then
        name = self:GetName()
    end
    
    private.events.RegisterEvent(self, event, func, name)
end

function module_metatable.__index.UnregisterEvent(self, event, name)
    if not name then
        name = self:GetName()
    end

    private.events.UnregisterEvent(self, event, name)
end

function module_metatable.__index.IsEventRegistered(self, event, name)
    if not name then
        name = self:GetName()
    end

    private.events.IsEventRegistered(self, event, name)
end

-- Format money output
module_metatable.__index.FormatMoney = private.format_money

-- Format a time
module_metatable.__index.FormatTime = private.format_time

-- Moved our create_backdrop into the media files for ease of access to both modules, addons, and API.
module_metatable.__index.CreateBackdrop = media.create_backdrop

--[[
Public: Pixel perfect scale our value.

Examples:
    <module>.PixelScale(3)
    # => 3 (At a UIScale of 1)

Returns a float of scaled value.
--]]
module_metatable.__index.PixelScale = PixelScale

--[[
Public: Get Media table

file - name of file to return

Examples:
    <module>:GetMedia()
    # => <table of media>

Returns Lua table of all our media files.
--]]
do
    local function CheckTable(needle, haystack)
        for key, value in pairs(haystack) do
            if type(value) == "table" then
                return CheckTable(needle, value)
            elseif key:lower() == needle then
                return value
            end
        end
    end
end

function module_metatable.__index:GetMedia()
    return media
end

--[[
Public: Get Player details defined by field.

field - What part of the players information are we wanting.

Examples:
    <module>:GetPlayer("name")
    # => "Belliofria"

Returns string of data requested
--]]
-- Returns the players detailed information like realm, name, spec, etc.
do
    local details = {
        ["name"]        = UnitName("player"),
        ["realm"]       = GetRealmName(),
        ["class"]       = select(2, UnitClass("player")),
        ["level"]       = UnitLevel("player"),
        ["item level"]  = math.floor(GetAverageItemLevel("player")),
        ["zone"]        = GetRealZoneText() or "",
    }

    local function GetDetail(detail)
        if not detail then
            private.error(format("Attempting to access GetDetail(%s) on a non-string variable.", detail))
            return nil
        end
        detail = detail:lower()

        return details[detail] and details[detail] or nil
    end

    function module_metatable.__index:GetPlayer(details)
        if type(details) == "string" then
            return GetDetail(details)
        elseif type(details) == "table" then
            local result = {}

            for _, detail in next, details do
                table.insert(result, GetDetail(detail))
            end

            return unpack(result)
        end
    end
end

--[[
Public: Set the frame width and height. If only one variable is passed, set it to both width and height.

width - Frame width
height - Frame height

Examples:
    <module>:SetSize(130)

Returns nothing.
--]]
function module_metatable.__index:SetSize(width, height)
    if not height then
        height = width
    end

    -- If we have already created a backdrop on the frame, take into account for this when we set the frames size.
    if self.backdrop and self ~= self.backdrop then
        width = width - 4
        height = height - 4
    end

    reference_frame.SetSize(self, PixelScale(width), PixelScale(height))
end

--[[
Public: Set the frame width.

width - Frame width

Examples:
    <module>:SetWidth(130)

Returns nothing.
--]]
function module_metatable.__index:SetWidth(width)
    argument_check(width, 2, "number")

    -- If we have already created a backdrop on the frame, take into account for this when we set the frames width.
    if self.backdrop then
        width = width - 4
    end

    reference_frame.SetWidth(self, PixelScale(width))
end

--[[
Public: Set the frame height.

height - Frame height

Examples:
    <module>:SetWidth(130)

Returns nothing.
--]]
function module_metatable.__index:SetHeight(height)
    argument_check(height, 2, "number")

    -- If we have already created a backdrop on the frame, take into account for this when we set the frames height.
    if self.backdrop then
        height = height + 4
    end

    reference_frame.SetHeight(self, PixelScale(height))
end

-- Rewrite the SetPoint on our frame so we can use PixelScale here instead of in the actual module.
function module_metatable.__index:SetPoint(...)
    local points = {}

    for index = 1, select("#", ...) do
        local argument = select(index, ...)

        if type(argument) == "number" then
            -- If we have a backdrop created on the frame, we need to bump it by 2px because of the border.
            if self.backdrop and argument > 0 then
                argument = argument + 2
            end
            
            argument = PixelScale(argument)
        end
        
        points[index] = argument
    end

    reference_frame.SetPoint(self, unpack(points))
end

--[[
Public: Set the frame scale

scale - Frame scale

Examples:
    <module>:SetScale(130)

Returns nothing.
--]]
function module_metatable.__index:SetScale(scale)
    argument_check(scale, 2, "number")

    reference_frame.SetScale(self, PixelScale(scale))
end

function module_metatable.__index:GetName()
    if self.name then
        return self.name
    elseif self.GetName then
        return self:GetName()
    elseif self.GetParent and self:GetParent():GetName() then
        return self:GetParent():GetName()
    else
        return ""
    end
end

--[[
Public: Create a new module for the UI.

name         - The name to be given to the module frame or how we can reference future naming.
create_frame - Boolean flag to create the module as a frame instead of just using it as a table.

Examples:
    NewModule("HelloWorld")

Returns either a WoW Frame or a Lua table.
--]]
function private.NewModule(name, create_frame, inherit_frame)
    local self = {}

    if create_frame then
        local frame_metatable = getmetatable(reference_frame).__index

        for key, value in next, frame_metatable do
            if not module_metatable.__index[key] then
                module_metatable.__index[key] = value
            end
        end

        self = CreateFrame("Frame", name and "caelUI_" .. name or nil, UIParent, inherit_frame or nil)
    end

    -- Set our modules metatable to our returned self.
    setmetatable(self, module_metatable)

    -- Make sure we know what the name of the object was if we reference it again.
    self.name = name

    -- Return the data.
    return self
end

--[[
Public: Module register and retrieval.

name - The name of the module we are wanting to register or retrieve.

Examples:
    <module>:RegisterModule()

RegisterModule returns nothing.
GetModule returns the actual module.
--]]
do
    local registered_modules = {}

    function module_metatable.__index:RegisterModule(name)
        if self.name then
            registered_modules[self.name] = self
        elseif name then
            registered_modules[name] = self
        else
            self.Print("Error", "Attempting to register a module with no name.")
        end
    end

    function private.GetModule(name, ...)
        if name and registered_modules[name] then
            return registered_modules[name]
        end

        return private.NewModule(name, ...)
    end
end
