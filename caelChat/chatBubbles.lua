-- This skin was originally created by Elv/Tukz in the ElvUI/TukzUI UI.
--
-- Modified by Caellian & Jankly on 11/22/11
local _, caelChat = ...

caelChat.bubbles = CreateFrame("Frame", nil, UIParent)

bubbles = {}
local media = caelUI.media
local pixelScale = caelUI.config.pixel_scale

local SkinBubble = function(frame)
    for index = 1, frame:GetNumRegions() do
        local region = select(index, frame:GetRegions())
        if region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
        elseif region:GetObjectType() == "FontString" then
            frame.text = region
            frame.text:SetFont(media.fonts.chat, 9)
            frame.text:SetJustifyH("CENTER")
            frame.text:SetShadowColor(0, 0, 0)
            frame.text:SetShadowOffset(0.75, -0.75)
        end
    end

    frame:SetBackdrop(media.backdrop_table)
    frame:SetBackdropBorderColor(0, 0, 0)
    frame:SetBackdropColor(0, 0, 0, 0.33)

    tinsert(bubbles, frame)
end

local isChatBubble = function(frame)
    if frame:GetName() then return end
    if not frame:GetRegions() then return end

    return frame:GetRegions():GetTexture() == [=[Interface\Tooltips\ChatBubble-Background]=]
end

local numKids = 0
local lastUpdate = 0
caelChat.bubbles:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed

    if lastUpdate > 0.05 then
        lastUpdate = 0

        local newNumKids = WorldFrame:GetNumChildren()
        if newNumKids ~= numKids then
            for i = numKids + 1, newNumKids do
                local frame = select(i, WorldFrame:GetChildren())

                if isChatBubble(frame) then
                    SkinBubble(frame)
                end
            end
            numKids = newNumKids
        end

        for _, frame in next, bubbles do
            local red, green, blue = frame.text:GetTextColor()
            frame:SetBackdropBorderColor(red, green, blue, 0.33)
        end
    end
end)