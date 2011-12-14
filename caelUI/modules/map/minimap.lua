local Map = unpack(select(2, ...)).NewModule("Minimap", true)

-- Setup the Minimap container frame.
Map:SetSize(130)
Map:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 20)
Map:CreateBackdrop()

local function Initialize (self)
    for _, object in next, {
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
    } do
        if object:GetObjectType() == "Texture" then
            object:SetTexture(nil)
        else
            object:Hide()
        end
    end

    Minimap:EnableMouse(true)
    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function(frame, direction)
        if direction > 0 then
            Minimap_ZoomIn()
        else
            Minimap_ZoomOut()
        end
    end)

    Minimap:ClearAllPoints()
    Minimap:SetParent(self)
    Minimap:SetFrameLevel(self:GetFrameLevel() + 1)
    Minimap:SetPoint("CENTER")
    Minimap:SetSize(self:GetSize())

    Minimap:SetMaskTexture(self:GetMedia().files.background)
    --Minimap:SetBlipTexture([=[Interface\Addons\caelUI\media\miscellaneous\charmed.tga]=])

    MinimapCluster:EnableMouse(false)

    MiniMapBattlefieldFrame:SetParent(Minimap)
    MiniMapBattlefieldFrame:ClearAllPoints()
    MiniMapBattlefieldFrame:SetPoint("TOPRIGHT")

    MiniMapTracking:SetParent(Minimap)
    MiniMapTracking:ClearAllPoints()
    MiniMapTracking:SetPoint("TOPLEFT")
    MiniMapTracking:SetAlpha(0)

    MiniMapTrackingButton:SetHighlightTexture(nil)
    MiniMapTrackingButton:SetScript("OnEnter", function() MiniMapTracking:SetAlpha(1) end)
    MiniMapTrackingButton:SetScript("OnLeave", function() MiniMapTracking:SetAlpha(0) end)

    MiniMapInstanceDifficulty:ClearAllPoints()
    MiniMapInstanceDifficulty:SetParent(Minimap)
    MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", -5, 0)
    MiniMapInstanceDifficulty:SetScale(0.75)

    GuildInstanceDifficulty:ClearAllPoints()
    GuildInstanceDifficulty:SetParent(Minimap)
    GuildInstanceDifficulty:SetPoint("TOPRIGHT", -5, 0)
    GuildInstanceDifficulty:SetScale(0.75)

    DurabilityFrame:UnregisterAllEvents()
    MiniMapMailFrame:UnregisterAllEvents()

    self:UnregisterEvent("PLAYER_ENTERING_WORLD", Initialize)
end

Map:RegisterEvent("PLAYER_ENTERING_WORLD", Initialize(Map))

do
    local farm = false

    function SlashCmdList.FARMMODE(msg, editbox)
        if farm == false then
            Map:SetSize(250)
            Minimap:SetSize(Map:GetWidth(), Map:GetHeight())
            Map:ClearAllPoints()
            Map:SetPoint("CENTER", UIParent, "CENTER", 0, -225)
            farm = true
        else
            Map:SetSize(130)
            Minimap:SetSize(Map:GetWidth(), Map:GetHeight())
            Map:ClearAllPoints()
            Map:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 20)
            farm = false
        end

        if msg == "reset" then
            Map:SetSize(caelPanel_DataFeedMinimap:GetWidth(), caelPanel_DataFeedMinimap:GetWidth())
            Minimap:SetSize(Map:GetWidth(), Map:GetHeight())
            Map:ClearAllPoints()
            Map:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 20)
            farm = false
        end
    end
    SLASH_FARMMODE1 = '/farmmode'
end