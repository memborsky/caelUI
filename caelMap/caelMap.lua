local _, caelMap = ...

caelMap = CreateFrame("Frame")

local kill = caelUI.kill
local pixelScale = caelUI.config.pixel_scale
local media = caelUI.media

WORLDMAP_WINDOWED_SIZE = 1

local Player = WorldMapButton:CreateFontString(nil, "ARTWORK")
Player:SetPoint("TOPLEFT", WorldMapButton, 0, 40)
Player:SetFont(media.fonts.normal, 12)
Player:SetTextColor(0.84, 0.75, 0.65)

local Cursor = WorldMapButton:CreateFontString(nil, "ARTWORK")
Cursor:SetPoint("TOPLEFT", WorldMapButton, 0, 20)
Cursor:SetFont(media.fonts.normal, 12)
Cursor:SetTextColor(0.84, 0.75, 0.65)

local ForceSmallMap = GetCVarBool("miniWorldMap")
if ForceSmallMap == nil then
    SetCVar("miniWorldMap", 1)
end

local SetupMap = function(self)

    SetCVar("questPOI", 1)
    WatchFrame.showObjectives = true
    QuestLogFrameShowMapButton:Show()
    WorldMapQuestShowObjectives:SetChecked(1)
    WorldMapShowDigSites:SetChecked(1)

    kill(BlackoutWorld)
    kill(WorldMapFrameCloseButton)
    kill(WorldMapFrameMiniBorderLeft)
    kill(WorldMapFrameMiniBorderRight)
    kill(WorldMapFrameSizeDownButton)
    kill(WorldMapFrameSizeUpButton)
    kill(WorldMapLevelDropDown)
    kill(WorldMapPositioningGuide)
    kill(WorldMapQuestShowObjectives)
    kill(WorldMapTitleButton)
    kill(WorldMapTrackQuest)

    WorldMapFrame:SetAlpha(0.75)

    WorldMapShowDigSites:ClearAllPoints()

    WorldMapBlobFrame.Show = WorldMapBlobFrame.Hide

    -- Hack to get around :Hide() not being called while in combat.
    WorldMapBlobFrame.Hide = function() return end

    WorldMapDetailFrame:ClearAllPoints()
    WorldMapDetailFrame:SetPoint("BOTTOM", caelPanel_Minimap, "TOP", 0, pixelScale(75))
    WorldMapDetailFrame:SetFrameStrata("MEDIUM")
    --WorldMapFrame:SetScale(pixelScale(1 / WORLDMAP_WINDOWED_SIZE))

    WorldMapFrameTitle:ClearAllPoints()
    WorldMapFrameTitle:SetParent(WorldMapDetailFrame)
    WorldMapFrameTitle:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP", 0, pixelScale(15))
    WorldMapFrameTitle:SetFont(media.fonts.normal, 40)
    WorldMapFrameTitle:SetTextColor(0.84, 0.75, 0.65)

    WorldMapFrameAreaLabel:SetFont(media.fonts.normal, 40)

    hooksecurefunc("WorldMapQuestPOI_OnLeave", function() WorldMapTooltip:Hide() end)

    WorldMapDetailFrame.bg = CreateFrame("Frame", nil, WorldMapDetailFrame)
    WorldMapDetailFrame.bg:SetScale(1 / WORLDMAP_WINDOWED_SIZE)
    WorldMapDetailFrame.bg:SetPoint("TOPLEFT", pixelScale(-10), pixelScale(50))
    WorldMapDetailFrame.bg:SetPoint("BOTTOMRIGHT", pixelScale(10), pixelScale(-10))
    WorldMapDetailFrame.bg:SetBackdrop({
        bgFile = media.files.background,
        edgeFile = media.files.edge, edgeSize = pixelScale(4),
        insets = {left = pixelScale(3), right = pixelScale(3), top = pixelScale(3), bottom = pixelScale(3)}
    })
    WorldMapDetailFrame.bg:SetFrameStrata("MEDIUM")
    WorldMapDetailFrame.bg:SetBackdropColor(0.15, 0.15, 0.15, 1)
    WorldMapDetailFrame.bg:SetBackdropBorderColor(0, 0, 0)
    WorldMapDetailFrame.bg:SetFrameLevel(20)

    WorldMapButton:SetAllPoints(WorldMapDetailFrame)

    WorldMapButton.timer = 0.1

    WorldMapButton:HookScript("OnUpdate", function(self, elapsed)
        self.timer = self.timer - elapsed
        if self.timer > 0 then
            return
        end

        self.timer = 0.1

        local PlayerX, PlayerY = GetPlayerMapPosition("player")
        Player:SetFormattedText("Player X, Y • %.1f, %.1f", PlayerX * 100, PlayerY * 100)

        local Scale = WorldMapDetailFrame:GetEffectiveScale()
        local Width, Height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()

        local CursorX, CursorY = GetCursorPosition()
        local CenterX, CenterY = WorldMapDetailFrame:GetCenter()

        CursorX = (CursorX / Scale - (CenterX - (Width / 2))) / Width * 100
        CursorY = (CenterY + (Height / 2) - CursorY / Scale) / Height * 100

        if CursorX >= 100 or CursorY >= 100 or CursorX <= 0 or CursorY <= 0 then
            Cursor:SetText("Cursor X, Y • |cffAF5050Out of bounds.|r")
        else
            Cursor:SetFormattedText("Cursor X, Y • %.1f, %.1f", CursorX, CursorY)
        end
    end)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local function FixMapIcon(unit, size)
    local frame = _G[unit]

    if not frame then
        return
    end

    frame:SetWidth(size)
    frame:SetHeight(size)
end

caelMap:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        SetupMap(self)
        SetupMap = nil

        for index = 1, 4 do
            FixMapIcon(format("WorldMapParty%d", index), pixelScale(24))
            if BattlefieldMinimap then
                FixMapIcon(format("BattlefieldMinimapParty%d", index), pixelScale(24))
            end
        end
        for index = 1, 40 do
            FixMapIcon(format("WorldMapRaid%d", index), pixelScale(24))
            if BattlefieldMinimap then
                FixMapIcon(format("BattlefieldMinimapRaid%d", index), pixelScale(24))
            end
        end
    elseif event == "WORLD_MAP_UPDATE" then
        if WorldMapFrameTitle:GetText() ~= GetRealZoneText() then
            WorldMapFrameTitle:SetText(GetRealZoneText())
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, false)
        WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, true)

        WatchFrame_Update()
    elseif event == "PLAYER_REGEN_ENABLED" then
        WatchFrame_Update()
    end
end)

for _, event in next, {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "WORLD_MAP_UPDATE"
} do
    caelMap:RegisterEvent(event)
end
