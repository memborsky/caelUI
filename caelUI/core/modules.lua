local private = unpack(select(2, ...))

-- Localized variables
local PixelScale = private.PixelScale
local media = private.media
local databases = private.GetDatabase()

-- We use this to reference a blank frame for calling frame related functions when we modify them.
local reference_frame = CreateFrame("Frame")

local module_metatable = {
    __index = CreateFrame("Frame"),

    __call = function(funcs, self, ...)
        for _, func in next, funcs do
            func(self, ...)
        end
    end
}

function module_metatable.__index:Print(...)
    local name = self.name or "UI"

    if #(...) > 1 then
        name = ...
    end

    private.print(name, ...)
end

-- Rebind our event table functions to our module frame.
module_metatable.__index.RegisterEvent = private.events.RegisterEvent
module_metatable.__index.UnregisterEvent = private.events.UnregisterEvent
module_metatable.__index.IsEventRegistered = private.events.IsEventRegistered

-- Format money output
module_metatable.__index.FormatMoney = private.format_money

-- Rewrite the SetPoint on our frame so we can use PixelScale here instead of in the actual module.
function module_metatable.__index:SetPoint(...)
    local argument_count = #(...)

    if argument_count == 5 then
        local point, relative_frame, relative_point, offsetX, offsetY = ...
        reference_frame.SetPoint(self, point, relative_frame, relative_point, PixelScale(offsetX), PixelScale(offsetY))
    else
        if argument_count == 3 and type(select(3, ...)) == "number" then
            local point, offsetX, offsetY = ...

            reference_frame.SetPoint(self, point, PixelScale(offsetX), PixelScale(offsetY))
        else
            reference_frame.SetPoint(self, ...)
        end
    end
end

--[[
Public: Create a default frame backdrop.

Examples:
    <module>:CreateBackdrop()
--]]
function module_metatable.__index:CreateBackdrop()
    local name

    if self.name then
        name = self.name .. "Backdrop"
    elseif self.GetParent and self:GetParent():GetName() then
        name = self:GetParent():GetName() .. "Backdrop"
    else
        name = nil
    end

    self.backdrop = CreateFrame("Frame", name, self)
    self.SetPoint(self.backdrop, "TOPLEFT", self, "TOPLEFT", -2, 2)
    self.SetPoint(self.backdrop, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
    self.backdrop:SetFrameLevel(self:GetFrameLevel() - 1 > 0 and self:GetFrameLevel() - 1 or 0)
    self.backdrop:SetBackdrop(media.backdrop_table)
    self.backdrop:SetBackdropColor(0, 0, 0, 0.4)
    self.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    self.backdrop:SetFrameStrata("BACKGROUND")
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

    function private.GetModule(name)
        if self.name and registered_modules[self.name] then
            return registered_modules[self.name]
        elseif name and registered_modules[name] then
            return registered_modules[name]
        end

        -- Create new module and return it with name.
    end
end

--[[
Private: Create a new module for the UI.

name         - The name to be given to the module frame or how we can reference future naming.
create_frame - Boolean flag to create the module as a frame instead of just using it as a table.

Examples:
    NewModule("HelloWorld")

Returns either a WoW Frame or a Lua table.
--]]
function private.NewModule(name, create_frame)
    local self = {}

    if create_frame then
        self = CreateFrame("Frame", name and "caelUI_" .. name or nil, UIParent)
    end

    -- Set our modules metatable to our returned self.
    setmetatable(self, module_metatable)

    -- Make sure we know what the name of the object was if we reference it again.
    self.name = name

    -- We pass the PixelScale function with the table/frame we create because we occasionally still need
    -- it on frame modifications that are not created with this function.
    self.PixelScale = PixelScale

    -- Return the media table so we don't have to include private in our modules.
    self.GetMedia = function() return media end

    -- Returns the players detailed information like realm, name, spec, etc.
    self.GetPlayerDetails = function() return databases.config.player end

    -- Return the data.
    return self
end
