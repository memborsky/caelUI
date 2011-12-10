local private = unpack(select(2, ...))

-- Localized variables
local PixelScale = private.PixelScale
local media = private.media

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

-- If the module doesn't pass in a name and we are creating a frame, we need to assign it a name so we can 
-- have better global management of it.
local system_count = 0

function CreateModule(name, create_frame)
    -- Make a black table if we aren't to be create a frame
    local self = {}

    -- If we are creating this module as a frame, we need to create the frame and overwrite some of the
    -- frame functions to be managed our way and to make the code a in the module look a lot cleaner.
    if create_frame then
        self = CreateFrame("Frame", "caelUI_" .. name and name or "SystemGenerated" .. system_count, UIParent)

        -- Increase the system counter if we had no named passed in.
        if not name then
            system_count = system_count + 1
        end
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

    -- Return the data.
    return self
end
