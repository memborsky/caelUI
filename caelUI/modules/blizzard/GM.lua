local SkinGMChat = CreateModule("SkinGMChat")
local pixel_scale = SkinGMChat.pixel_scale

--[[    GM chat frame enhancement    ]]

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOP", UIParent, 0, pixel_scale(-5))

HelpOpenTicketButton:SetParent(Minimap)
HelpOpenTicketButton:ClearAllPoints()
HelpOpenTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")

-- XXX: This needs to be moved to the blizzard/skins folder when that system gets created.
local function SkinGMChatFrame (self, _, name)
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

    self:UnregisterEvent("ADDON_LOADED", SkinGMChatFrame)
end

SkinGMChat:RegisterEvent("ADDON_LOADED", SkinGMChatFrame)
