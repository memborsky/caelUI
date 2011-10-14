local _, caelMap = ...

caelMap.eventFrame = CreateFrame"Frame"

local kill = caelLib.kill
local dummy = caelLib.dummy

local media = caelUI.media
local pixelScale = caelUI.config.pixelScale

local Player = WorldMapButton:CreateFontString(nil, "ARTWORK")
Player:SetPoint("TOPLEFT", WorldMapButton, 0, 40)
Player:SetFont(media.fonts.NORMAL, 12)
Player:SetTextColor(0.84, 0.75, 0.65)

local Cursor = WorldMapButton:CreateFontString(nil, "ARTWORK")
Cursor:SetPoint("TOPLEFT", WorldMapButton, 0, 20)
Cursor:SetFont(media.fonts.NORMAL, 12)
Cursor:SetTextColor(0.84, 0.75, 0.65)

local function setupMap(self)
    WORLDMAP_QUESTLIST_SIZE = 0.7

    if WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
        ToggleFrame(WorldMapFrame)
        WorldMapFrame_ToggleWindowSize()
        ToggleFrame(WorldMapFrame)
    end

    WorldMap_ToggleSizeDown = dummy
    WorldMap_ToggleSizeUp = dummy

    WorldMapFrame.oArrow = PositionWorldMapArrowFrame
    PositionWorldMapArrowFrame = function(point, frame, anchor, x, y)
        local playerX, playerY = GetPlayerMapPosition("player")
        playerX = playerX * WorldMapDetailFrame:GetWidth()
        playerY = -playerY * WorldMapDetailFrame:GetHeight()
        WorldMapFrame.oArrow(point, frame, anchor, playerX * WORLDMAP_QUESTLIST_SIZE, playerY * WORLDMAP_QUESTLIST_SIZE)
    end

    SetCVar("questPOI", 1)
    WatchFrame.showObjectives = true
    QuestLogFrameShowMapButton:Show()
    WorldMapQuestShowObjectives:SetChecked(1)
    WorldMapShowDigSites:SetChecked(1)

    WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE

    UIPanelWindows["WorldMapFrame"] = { area = "center", pushable = 9, whileDead = 1 };

    kill(BlackoutWorld)
    kill(WorldMapQuestDetailScrollFrame)
    kill(WorldMapQuestRewardScrollFrame)
    kill(WorldMapQuestScrollFrame)
    kill(WorldMapQuestShowObjectives)
    kill(WorldMapShowDigSites)
    kill(WorldMapFrameSizeDownButton)
    kill(WorldMapFrameSizeUpButton)
    kill(WorldMapFrameCloseButton)
    kill(WorldMapZoneMinimapDropDown)
    kill(WorldMapZoomOutButton)
    kill(WorldMapLevelDropDown)
    kill(WorldMapFrameTitle)
    kill(WorldMapContinentDropDown)
    kill(WorldMapZoneDropDown)
    kill(WorldMapLevelUpButton)
    kill(WorldMapLevelDownButton)
    kill(WorldMapTrackQuest)

    WorldMapFrame:EnableKeyboard(false)
    WorldMapFrame:EnableMouse(false)
    WorldMapFrame.EnableKeyboard = dummy
    WorldMapFrame.EnableMouse = dummy

    WorldMap_LoadTextures = dummy

    WorldMapPositioningGuide:ClearAllPoints()
    WorldMapPositioningGuide:SetPoint("CENTER")
    WorldMapPositioningGuide.ClearAllPoints = dummy
    WorldMapPositioningGuide.SetPoint = dummy

    WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -502, -69)

    local function StopMessingWithMyShitBlizzard(frame)
        frame:SetScale(WORLDMAP_QUESTLIST_SIZE)
        frame.ClearAllPoints = dummy
        frame.SetPoint = dummy
        frame.SetScale = dummy
        frame.SetWidth = dummy
        frame.SetHeight = dummy
        frame.SetSize = dummy
    end

    StopMessingWithMyShitBlizzard(WorldMapPositioningGuide)
    StopMessingWithMyShitBlizzard(WorldMapDetailFrame)
    StopMessingWithMyShitBlizzard(WorldMapFrame)
    StopMessingWithMyShitBlizzard(WorldMapButton)
    StopMessingWithMyShitBlizzard(WorldMapFrameAreaFrame)

    WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)

    WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -502, -69)

    WorldMapFrame_SetPOIMaxBounds()

    WorldMapQuestPOI_OnLeave = function()
        WorldMapTooltip:Hide()
    end

    WorldMapFrame:SetAlpha(0.75)
    WorldMapFrame.SetAlpha = dummy

    WorldMapDetailFrame.bg = CreateFrame("Frame", nil, WorldMapDetailFrame)
    WorldMapDetailFrame.bg:SetPoint("TOPLEFT", -10, 50)
    WorldMapDetailFrame.bg:SetPoint("BOTTOMRIGHT", 10, -10)
    WorldMapDetailFrame.bg:SetBackdrop({
        bgFile = media.files.bgFile,
        edgeFile = media.files.edgeFile, edgeSize = 4,
        insets = {left = 3, right = 3, top = 3, bottom = 3}
    })
    WorldMapDetailFrame.bg:SetFrameStrata("BACKGROUND")
    WorldMapDetailFrame.bg:SetBackdropColor(0.15, 0.15, 0.15, 1)
    WorldMapDetailFrame.bg:SetBackdropBorderColor(0, 0, 0)

    WorldMapButton.cursor_coordinates = WorldMapButton:CreateFontString(nil, "ARTWORK")
    WorldMapButton.cursor_coordinates:SetPoint("BOTTOMLEFT", WorldMapButton, "BOTTOMLEFT", 5, 5)
    WorldMapButton.cursor_coordinates:SetFont(media.fonts.NORMAL, 12)
    WorldMapButton.cursor_coordinates:SetTextColor(0.84, 0.75, 0.65)
    WorldMapButton.timer = 0.1

    WorldMapButton:HookScript("OnUpdate", function(self, elapsed)
        self.timer = self.timer - elapsed
        if self.timer > 0 then return end
        self.timer = 0.1

        local PlayerX, PlayerY = GetPlayerMapPosition("player")
        Player:SetFormattedText("Player X, Y • %.1f, %.1f", PlayerX * 100, PlayerY * 100)

        local CenterX, CenterY = WorldMapDetailFrame:GetCenter()
        local CursorX, CursorY = GetCursorPosition()
        CursorX = ((CursorX / WORLDMAP_QUESTLIST_SIZE) - (CenterX - (WorldMapDetailFrame:GetWidth() / 2))) / 10
        CursorY = (((CenterY + (WorldMapDetailFrame:GetHeight() / 2)) - (CursorY / WORLDMAP_QUESTLIST_SIZE)) / WorldMapDetailFrame:GetHeight()) * 100

        if CursorX >= 100 or CursorY >= 100 or CursorX <= 0 or CursorY <= 0 then
            Cursor:SetText("Cursor X, Y • |cffAF5050Out of bounds.|r")
        else
            Cursor:SetFormattedText("Cursor X, Y • %.1f, %.1f", CursorX, CursorY)
        end
    end)

    self:UnregisterEvent"PLAYER_ENTERING_WORLD"
end

local function fixMapIcon(unit, size)
    local frame = _G[unit]
    if not frame then return end

    frame:SetWidth(size)
    frame:SetHeight(size)
end

caelMap.eventFrame:RegisterEvent"WORLD_MAP_UPDATE"
caelMap.eventFrame:RegisterEvent"PLAYER_ENTERING_WORLD"
caelMap.eventFrame:RegisterEvent"PLAYER_REGEN_ENABLED"
caelMap.eventFrame:RegisterEvent"PLAYER_REGEN_DISABLED"
caelMap.eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        setupMap(self)
        setupMap = nil

        -- Scale the player icons on the map to be a little bigger then default width and height
        for index = 1, 4 do
            fixMapIcon(format("WorldMapParty%d", index), pixelScale(24))
            if BattlefieldMinimap then
                fixMapIcon(format("BattlefieldMinimapParty%d", index), pixelScale(24))
            end
        end
        for index = 1, 40 do
            fixMapIcon(format("WorldMapRaid%d", index), pixelScale(24))
            if BattlefieldMinimap then
                fixMapIcon(format("BattlefieldMinimapRaid%d", index), pixelScale(24))
            end
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        WorldMapArchaeologyDigSites:Hide()
        WorldMapBlobFrame:Hide()
        WorldMapPOIFrame:Hide()

        WorldMapArchaeologyDigSites.Show = dummy
        WorldMapBlobFrame.Show = dummy
        WorldMapPOIFrame.Show = dummy

        WatchFrame_Update()
    elseif event == "PLAYER_REGEN_ENABLED" then
        WorldMapArchaeologyDigSites.Show = WorldMapArchaeologyDigSites:Show()
        WorldMapBlobFrame.Show = WorldMapBlobFrame:Show()
        WorldMapPOIFrame.Show = WorldMapPOIFrame:Show()

        WorldMapArchaeologyDigSites:Show()
        WorldMapBlobFrame:Show()
        WorldMapPOIFrame:Show()

        WatchFrame_Update()
    elseif event == "WORLD_MAP_UPDATE" then
        -- Hack to hide the bar at the bottom of the screen from showing
        -- because it is more special then the other 17 textures that make up the world map frame
        if WorldMapFrameTexture18:IsShown() then
            WorldMapFrameTexture18:Hide()
        end
    end
end)
