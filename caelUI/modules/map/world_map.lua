local Map = unpack(select(2, ...)).NewModule("WorldMap")
local media = Map:GetMedia()

WORLDMAP_WINDOWED_SIZE = 1

local function Initialize()

    -- Create the background container frame for the world map.
    WorldMapFrame.name = "WorldMapFrame"
    Map.CreateBackdrop(WorldMapFrame, WorldMapFrame:GetName())
    WorldMapFrame.backdrop:SetFrameStrata("MEDIUM")
    WorldMapFrame.backdrop:SetFrameLevel(20)

    WorldMapFrame.player = WorldMapFrame:CreateFontString(nil, "ARTWORK")
    Map.SetPoint(WorldMapFrame.player, "TOPLEFT", WorldMapFrame, "TOPLEFT", 5, -10)
    WorldMapFrame.player:SetFont(media.fonts.normal, 12)
    WorldMapFrame.player:SetTextColor(0.84, 0.75, 0.65)

    WorldMapFrame.cursor = WorldMapFrame:CreateFontString(nil, "ARTWORK")
    Map.SetPoint(WorldMapFrame.cursor, "TOPLEFT", WorldMapFrame, "TOPLEFT", 5, -30)
    WorldMapFrame.cursor:SetFont(media.fonts.normal, 12)
    WorldMapFrame.cursor:SetTextColor(0.84, 0.75, 0.65)

    -- Size the frame only when we load into the game to make sure everything else is loaded.
    WorldMapFrame:SetWidth((WorldMapDetailFrame:GetWidth() * WORLDMAP_WINDOWED_SIZE) + 4)
    WorldMapFrame:SetHeight((WorldMapDetailFrame:GetHeight() * WORLDMAP_WINDOWED_SIZE) + 50)

    -- Set the point for the world map frame and then make sure it doesn't change it.
    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint("CENTER", UIParent)
    WorldMapFrame.SetPoint = function() return end

    local function FixMapIcon(unit, size)
        local frame = _G[unit]

        if not frame then
            return
        end

        Map.SetSize(frame, size)
    end

    if GetCVarBool("miniWorldMap") == nil then
        SetCVar("miniWorldMap", 1)
    end

    SetCVar("questPOI", 1)
    WatchFrame.showObjectives = true
    QuestLogFrameShowMapButton:Show()
    WorldMapQuestShowObjectives:SetChecked(1)
    WorldMapShowDigSites:SetChecked(1)

    BlackoutWorld:Kill()
    WorldMapFrameCloseButton:Kill()
    WorldMapFrameMiniBorderLeft:Kill()
    WorldMapFrameMiniBorderRight:Kill()
    WorldMapFrameSizeDownButton:Kill()
    WorldMapFrameSizeUpButton:Kill()
    WorldMapLevelDropDown:Kill()
    WorldMapPositioningGuide:Kill()
    WorldMapQuestShowObjectives:Kill()
    WorldMapTitleButton:Kill()
    WorldMapTrackQuest:Kill()
    WorldMapShowDropDown:Kill()

    WorldMapQuestScrollFrame:Kill()
    WorldMapQuestDetailScrollFrame:Kill()
    WorldMapQuestRewardScrollFrame:Kill()

    WorldMapFrame:SetAlpha(0.75)

    WorldMapShowDigSites:ClearAllPoints()

    WorldMapBlobFrame.Show = WorldMapBlobFrame.Hide

    -- Hack to get around :Hide() not being called while in combat.
    WorldMapBlobFrame.Hide = function() return end

    WorldMapDetailFrame:ClearAllPoints()
    Map.SetPoint(WorldMapDetailFrame, "BOTTOMLEFT", WorldMapFrame.backdrop, "BOTTOMLEFT", 4, 4)
    WorldMapDetailFrame.SetPoint = function() return end
    WorldMapDetailFrame.SetSize = function() return end
    WorldMapDetailFrame.SetWidth = function() return end
    WorldMapDetailFrame.SetHeight = function() return end
    WorldMapDetailFrame.SetScale = function() return end

    WorldMapFrameTitle:ClearAllPoints()
    Map.SetPoint(WorldMapFrameTitle, "TOP", WorldMapFrame, "TOP", 0, -12.5)
    WorldMapFrameTitle:SetFont(media.fonts.normal, 40)
    WorldMapFrameTitle:SetTextColor(0.84, 0.75, 0.65)

    WorldMapFrameAreaLabel:SetFont(media.fonts.normal, 40)

    hooksecurefunc("WorldMapQuestPOI_OnLeave", function() WorldMapTooltip:Hide() end)

    WorldMapButton:SetSize(WorldMapDetailFrame:GetSize())
    WorldMapButton:ClearAllPoints()
    WorldMapButton:SetAllPoints(WorldMapDetailFrame)
    WorldMapButton.timer = 0.1

    WorldMapButton:HookScript("OnUpdate", function(self, elapsed)
        self.timer = self.timer - elapsed
        if self.timer > 0 then
            return
        end

        self.timer = 0.1

        local PlayerX, PlayerY = GetPlayerMapPosition("player")
        WorldMapFrame.player:SetFormattedText("Player X, Y • %.1f, %.1f", PlayerX * 100, PlayerY * 100)

        local Scale = WorldMapDetailFrame:GetEffectiveScale()
        local Width, Height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()

        local CursorX, CursorY = GetCursorPosition()
        local CenterX, CenterY = WorldMapDetailFrame:GetCenter()

        CursorX = (CursorX / Scale - (CenterX - (Width / 2))) / Width * 100
        CursorY = (CenterY + (Height / 2) - CursorY / Scale) / Height * 100

        if CursorX >= 100 or CursorY >= 100 or CursorX <= 0 or CursorY <= 0 then
            WorldMapFrame.cursor:SetText("Cursor X, Y • |cffAF5050Out of bounds.|r")
        else
            WorldMapFrame.cursor:SetFormattedText("Cursor X, Y • %.1f, %.1f", CursorX, CursorY)
        end
    end)

    for index = 1, 4 do
        FixMapIcon(format("WorldMapParty%d", index), 24)

        if BattlefieldMinimap then
            FixMapIcon(format("BattlefieldMinimapParty%d", index), 24)
        end
    end
    for index = 1, 40 do
        FixMapIcon(format("WorldMapRaid%d", index), 24)

        if BattlefieldMinimap then
            FixMapIcon(format("BattlefieldMinimapRaid%d", index), 24)
        end
    end

    Map:UnregisterEvent("PLAYER_ENTERING_WORLD", Initialize)
end

Map:RegisterEvent("PLAYER_ENTERING_WORLD", Initialize)

Map:RegisterEvent("WORLD_MAP_UPDATE", function()
    if WorldMapFrameTitle:GetText() ~= GetRealZoneText() then
        WorldMapFrameTitle:SetText(GetRealZoneText())
    end
end)

Map:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, false)
    WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, true)

    WatchFrame_Update()
end)

Map:RegisterEvent("PLAYRE_REGEN_ENABLED", function()
    WatchFrame_Update()
end)
