local private = unpack(select(2, ...))

-- Localized variables
local PixelScale = private.PixelScale

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

function module_metatable.__index:GetMedia()
    return private.media
end

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

function CreateModule(name, create_frame)
    -- Make a black table if we aren't to be create a frame
    local self = {}

    -- If we are creating this module as a frame, we need to create the frame and overwrite some of the
    -- frame functions to be managed our way and to make the code a in the module look a lot cleaner.
    if create_frame then
        self = CreateFrame("Frame", "caelUI_" .. name, UIParent)
    end

    -- Set our modules metatable to our returned self.
    setmetatable(self, module_metatable)

    -- Make sure we know what the name of the object was if we reference it again.
    self.name = name

    -- We pass the PixelScale function with the table/frame we create because we occasionally still need
    -- it on frame modifications that are not created with this function.
    self.PixelScale = private.PixelScale

    -- Return the data.
    return self
end
