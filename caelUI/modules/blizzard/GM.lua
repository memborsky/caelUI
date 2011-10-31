local private = unpack(select(2, ...))

--[[    GM chat frame enhancement    ]]

local pixel_scale = private.pixel_scale

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOP", UIParent, 0, pixel_scale(-5))

HelpOpenTicketButton:SetParent(Minimap)
HelpOpenTicketButton:ClearAllPoints()
HelpOpenTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")

-- XXX: This needs to be moved to the blizzard/skins folder when that system gets created.
local function skin_gmchat_frame (_, _, name)
    if name ~= "Blizzard_GMChatUI" then return end

    GMChatFrame:EnableMouseWheel()
    GMChatFrame:SetScript("OnMouseWheel", ChatFrame1:GetScript("OnMouseWheel"))
    GMChatFrame:ClearAllPoints()
    GMChatFrame:SetHeight(ChatFrame1:GetHeight())
    GMChatFrame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, pixel_scale(38))
    GMChatFrame:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, pixel_scale(38))
    GMChatFrameCloseButton:ClearAllPoints()
    GMChatFrameCloseButton:SetPoint("TOPRIGHT", GMChatFrame, "TOPRIGHT", pixel_scale(7), pixel_scale(8))
    GMChatFrameButtonFrame:Hide()
    --    Those buttons are childs of the frame above, there's no need to hide them anymore.
    --    GMChatFrameButtonFrameUpButton:Hide()
    --    GMChatFrameButtonFrameDownButton:Hide()
    --    GMChatFrameButtonFrameBottomButton:Hide()
    GMChatFrameResizeButton:Hide()
    GMChatTab:Hide()

    private.events:UnregisterEvent("ADDON_LOADED", skin_gmchat_frame)
    skin_gmchat_frame = nil
end

private.events:RegisterEvent("ADDON_LOADED", skin_gmchat_frame)
