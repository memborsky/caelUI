local _, caelCore = ...

--[[    GM chat frame enhancement    ]]

local gmframe = caelCore.createModule("GMFrame")

local pixel_scale = caelUI.config.pixel_scale

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOP", UIParent, 0, pixel_scale(-5))

gmframe:RegisterEvent("ADDON_LOADED")
gmframe:SetScript("OnEvent", function(self, event, name)
    if (event ~= "ADDON_LOADED") or (name ~= "Blizzard_GMChatUI") then return end

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

    enhanceGMFrame = function () end
end)
