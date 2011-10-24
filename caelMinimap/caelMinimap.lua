local caelMinimap = CreateFrame("Frame", nil, Minimap)
local pixel_scale = caelUI.config.pixel_scale

for _, object in pairs({
    GameTimeFrame,
    MinimapBorder,
    MinimapZoomIn,
    MinimapZoomOut,
    MinimapNorthTag,
    MinimapBorderTop,
    MinimapToggleButton,
    MiniMapWorldMapButton,
    MinimapZoneTextButton,
    MiniMapBattlefieldBorder,
    MiniMapTrackingBackground,
    MiniMapTrackingIconOverlay,
    MiniMapTrackingButtonBorder,
}) do
if object:GetObjectType() == "Texture" then
    object:SetTexture(nil)
else
    object:Hide()
end
end

Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")
Minimap:SetScript("OnEvent", function(self, event, ...)
    self:EnableMouse(true)
    self:EnableMouseWheel(true)
    self:SetScript("OnMouseWheel", function(frame, direction)
        if direction > 0 then
            Minimap_ZoomIn()
        else
            Minimap_ZoomOut()
        end
    end)

    self:ClearAllPoints()
    self:SetParent(caelPanel_Minimap)
    self:SetFrameLevel(caelPanel_Minimap:GetFrameLevel() + 1)
    self:SetPoint("CENTER")
    self:SetSize(caelPanel_Minimap:GetWidth() - pixel_scale(5), caelPanel_Minimap:GetHeight() - pixel_scale(5))

    self:SetMaskTexture(caelUI.media.files.background)
    --self:SetBlipTexture([=[Interface\Addons\caelUI\media\miscellaneous\charmed.tga]=])

    MinimapCluster:EnableMouse(false)

    MiniMapBattlefieldFrame:SetParent(self)
    MiniMapBattlefieldFrame:ClearAllPoints()
    MiniMapBattlefieldFrame:SetPoint("TOPRIGHT")

    MiniMapTracking:SetParent(self)
    MiniMapTracking:ClearAllPoints()
    MiniMapTracking:SetPoint("TOPLEFT")
    MiniMapTracking:SetAlpha(0)

    MiniMapTrackingButton:SetHighlightTexture(nil)
    MiniMapTrackingButton:SetScript("OnEnter", function() MiniMapTracking:SetAlpha(1) end)
    MiniMapTrackingButton:SetScript("OnLeave", function() MiniMapTracking:SetAlpha(0) end)

    MiniMapInstanceDifficulty:ClearAllPoints()
    MiniMapInstanceDifficulty:SetParent(Minimap)
    MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", pixel_scale(-5), 0)
    MiniMapInstanceDifficulty:SetScale(0.75)

    GuildInstanceDifficulty:ClearAllPoints()
    GuildInstanceDifficulty:SetParent(Minimap)
    GuildInstanceDifficulty:SetPoint("TOPRIGHT", pixel_scale(-5), 0)
    GuildInstanceDifficulty:SetScale(0.75)

    DurabilityFrame:UnregisterAllEvents()
    MiniMapMailFrame:UnregisterAllEvents()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

local farm = false

function SlashCmdList.FARMMODE(msg, editbox)
    if farm == false then
        caelPanel_Minimap:SetSize(250, 250)
        Minimap:SetSize(caelPanel_Minimap:GetWidth() - pixel_scale(5), caelPanel_Minimap:GetHeight() - pixel_scale(5))
        caelPanel_Minimap:ClearAllPoints()
        caelPanel_Minimap:SetPoint("CENTER", UIParent, "CENTER", 0, pixel_scale(-225))
        farm = true
    else
        caelPanel_Minimap:SetSize(caelPanel_DataFeedMinimap:GetWidth(), caelPanel_DataFeedMinimap:GetWidth())
        Minimap:SetSize(caelPanel_Minimap:GetWidth() - pixel_scale(5), caelPanel_Minimap:GetHeight() - pixel_scale(5))
        caelPanel_Minimap:ClearAllPoints()
        caelPanel_Minimap:SetPoint("BOTTOMLEFT", caelPanel_DataFeedMinimap, "TOPLEFT", 0, pixel_scale(1))
        farm = false
    end

    if msg == "reset" then
        caelPanel_Minimap:SetSize(caelPanel_DataFeedMinimap:GetWidth(), caelPanel_DataFeedMinimap:GetWidth())
        Minimap:SetSize(caelPanel_Minimap:GetWidth() - pixel_scale(5), caelPanel_Minimap:GetHeight() - pixel_scale(5))
        caelPanel_Minimap:ClearAllPoints()
        caelPanel_Minimap:SetPoint("BOTTOMLEFT", caelPanel_DataFeedMinimap, "TOPLEFT", 0, pixel_scale(1))
        farm = false
    end
end
SLASH_FARMMODE1 = '/farmmode'
