local _, caelPanels = ...

local bar1OnLeft = false
local chatOnLeft = false

caelPanels.eventFrame = CreateFrame("frame", nil, UIParent)

local panels = {}
local pixel_scale = caelUI.config.pixel_scale
local media = caelUI.media

local defaultPanel = {
    ["EnableMouse"] = false,
    ["SetFrameStrata"] = "BACKGROUND",
    ["SetBackdrop"] = media.backdrop_table,
    ["SetBackdropColor"] = {0, 0, 0, 0.8},
    ["SetBackdropBorderColor"] = {0, 0, 0, 1},
}

function caelPanels.createPanel (name, size, point, override)
    local function SetPoint (panel, packedPoint)
        local p1, p2, p3, p4, p5 = unpack(packedPoint)
        panel:SetPoint(p1, p2, p3, p4, p5)
    end

    local panel = CreateFrame("Frame", name, UIParent)

    if override then

        for key, value in pairs(defaultPanel) do
            panel[key](panel, override[key] and override[key] or value)
        end

        panel:SetBackdropColor(override.SetBackdropColor and unpack(override.SetBackdropColor) or unpack(defaultPanel["SetBackdropColor"]))
        panel:SetBackdropBorderColor(override.SetBackdropBorderColor and unpack(override.SetBackdropBorderColor) or unpack(defaultPanel["SetBackdropBorderColor"]))

    else

        for key, value in pairs(defaultPanel) do
            panel[key](panel, value)
        end

        panel:SetBackdropColor(unpack(defaultPanel["SetBackdropColor"]))
        panel:SetBackdropBorderColor(unpack(defaultPanel["SetBackdropBorderColor"]))

    end

    if size then
        if type(size) == "table" then
            panel:SetSize(unpack(size))
        else
            panel:SetSize(size)
        end
    end

    if point then
        if type(unpack(point)) == "table" then
            for key, value in pairs(point) do
                SetPoint(panel, value)
            end
        else
            SetPoint(panel, point)
        end
    end

    -- Push the panel name into the global namespace
    _G[name] = panel

    -- We assume that the panel you are creating is going to be shown.
    -- If not define function call as caelPanels.createPanel():Hide() and it will hide the panel on creation.
    panel:Show()
    return panel
end

function caelPanels.gradientPanel (panel)
    local width = pixel_scale(panel:GetWidth() - 6)
    local height = pixel_scale(panel:GetHeight() / 5)
    local bgTexture = media.files.background

    local gradientTop = panel:CreateTexture(nil, "BORDER")
    gradientTop:SetTexture(bgTexture)
    gradientTop:SetSize(width, height)
    gradientTop:SetPoint("TOPLEFT", pixel_scale(3), pixel_scale(-2))
    gradientTop:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.84, 0.75, 0.65, 0.5)

    local gradientBottom = panel:CreateTexture(nil, "BORDER")
    gradientBottom:SetTexture(bgTexture)
    gradientBottom:SetSize(width, height)
    gradientBottom:SetPoint("BOTTOMRIGHT", pixel_scale(-3), pixel_scale(2))
    gradientBottom:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.75, 0, 0, 0, 0)
end

caelPanels.eventFrame:RegisterEvent("ADDON_LOADED")
caelPanels.eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...

        if addon == "caelPanels" then
            -- Setup all our movable points depending on which side of the screen our user wants their frames to be placed.
            local chatPoint   = {}
            local combatPoint = {}
            local bar1Point   = {}
            local bar2Point   = {}
            local damagePoint = {}
            local threatPoint = {}

            -- This variable lets us change the size of caelPanel_ActionBar<1-4> with ease.
            local actionBarSize = {pixel_scale(161), pixel_scale(53)}

            local createPanel = caelPanels.createPanel

            -- DataFeed bar
            createPanel("caelPanel_DataFeed", {pixel_scale(1120), pixel_scale(20)}, {"BOTTOM", UIParent, "BOTTOM", 0, pixel_scale(2)})

            -- MiniMap
            createPanel("caelPanel_Minimap", {pixel_scale(140), pixel_scale(140)}, {"BOTTOM", caelPanel_DataFeed, "TOP", 0, pixel_scale(2)})


            --  AB1 ON LEFT LAYOUT  --
            -- BAR 1 -- MM -- BAR 2 --
            -- BAR 3 -- MM -- BAR 4 --

            --  DEFAULT BAR LAYOUT  --
            -- BAR 2 -- MM -- BAR 1 --
            -- BAR 3 -- MM -- BAR 4 --
            if bar1OnLeft then
                bar1Point = {"TOPRIGHT", caelPanel_Minimap, "TOPLEFT", pixel_scale(-2), 0}
                bar2Point = {"TOPLEFT", caelPanel_Minimap, "TOPRIGHT", pixel_scale(2), 0}
            else
                bar1Point = {"TOPLEFT", caelPanel_Minimap, "TOPRIGHT", pixel_scale(2), 0}
                bar2Point = {"TOPRIGHT", caelPanel_Minimap, "TOPLEFT", pixel_scale(-2), 0}
            end

            -- bar1
            createPanel("caelPanel_ActionBar1", actionBarSize, bar1Point)

            -- bar2
            createPanel("caelPanel_ActionBar2", actionBarSize, bar2Point)

            -- bar3
            createPanel("caelPanel_ActionBar3", actionBarSize, {"BOTTOMRIGHT", caelPanel_Minimap, "BOTTOMLEFT", pixel_scale(-2), 0})

            -- bar4
            createPanel("caelPanel_ActionBar4", actionBarSize, {"BOTTOMLEFT", caelPanel_Minimap, "BOTTOMRIGHT", pixel_scale(2), 0})

            -- bar5
            createPanel("caelPanel_ActionBar5", {pixel_scale(29), pixel_scale(314)}, {"RIGHT", UIParent, "Right", pixel_scale(-2), 0})


            -- Chat Frame & Editbox / Combat Log
            if bar1OnLeft == true then
                if chatOnLeft == true then
                    chatPoint = {"TOPRIGHT", caelPanel_ActionBar1, "TOPLEFT", pixel_scale(-2), 0}
                    combatPoint = {"TOPLEFT", caelPanel_ActionBar2, "TOPRIGHT", pixel_scale(2), 0}
                else
                    chatPoint = {"TOPLEFT", caelPanel_ActionBar2, "TOPRIGHT", pixel_scale(2), 0}
                    combatPoint = {"TOPRIGHT", caelPanel_ActionBar1, "TOPLEFT", pixel_scale(-2), 0}
                end
            else
                if chatOnLeft == true then
                    chatPoint = {"TOPRIGHT", caelPanel_ActionBar2, "TOPLEFT", pixel_scale(-2), 0}
                    combatPoint = {"TOPLEFT", caelPanel_ActionBar1, "TOPRIGHT", pixel_scale(2), 0}
                else
                    chatPoint = {"TOPLEFT", caelPanel_ActionBar1, "TOPRIGHT", pixel_scale(2), 0}
                    combatPoint = {"TOPRIGHT", caelPanel_ActionBar2, "TOPLEFT", pixel_scale(-2), 0}
                end
            end

            -- Chat Frame
            createPanel("caelPanel_ChatFrame", {pixel_scale(324), pixel_scale(140)}, chatPoint)

            -- Editbox
            createPanel("caelPanel_EditBox", {caelPanel_ChatFrame:GetWidth(), pixel_scale(20)}, {"BOTTOMLEFT", caelPanel_ChatFrame, "TOPLEFT", pixel_scale(-1), pixel_scale(0)})

            -- Combat Log
            createPanel("caelPanel_CombatLog", {pixel_scale(324), pixel_scale(140)}, combatPoint)

            if bar1OnLeft == true then
                if chatOnLeft == true then
                    damagePoint = {"TOPRIGHT", caelPanel_ChatFrame, "TOPLEFT", pixel_scale(-2), 0}
                    threatPoint = {"TOPLEFT", caelPanel_CombatLog, "TOPRIGHT", pixel_scale(2), 0}
                else
                    damagePoint = {"TOPRIGHT", caelPanel_CombatLog, "TOPLEFT", pixel_scale(-2), 0}
                    threatPoint = {"TOPLEFT", caelPanel_ChatFrame, "TOPRIGHT", pixel_scale(2), 0}
                end
            else
                if chatOnLeft == true then
                    damagePoint = {"TOPRIGHT", caelPanel_ChatFrame, "TOPLEFT", pixel_scale(-2), 0}
                    threatPoint = {"TOPLEFT", caelPanel_CombatLog, "TOPRIGHT", pixel_scale(2), 0}
                else
                    damagePoint = {"TOPRIGHT", caelPanel_CombatLog, "TOPLEFT", pixel_scale(-2), 0}
                    threatPoint = {"TOPLEFT", caelPanel_ChatFrame, "TOPRIGHT", pixel_scale(2), 0}
                end
            end

            -- Damage Meter
            if IsAddOnLoaded("alDamageMeter") then
                caelPanels.createPanel("caelPanel_DamageMeter", {pixel_scale(165), pixel_scale(162)}, damagePoint)
            end

            -- Threat Meter
            -- XXX: hack_threat_01, recThreatMeter currently requires that we always make the panel and just hide it here if we aren't using it.
            createPanel("caelPanel_ThreatMeter", {pixel_scale(165), pixel_scale(162)}, threatPoint):Hide()

            for index = 1, 12 do
                --caelPanels.gradientPanel(_G["caelPanel" .. index])
            end
        end
    end
end)

function caelPanels.SetupAddonPanel(panel, frame)
    panel:SetParent(frame)
    panel:SetFrameStrata("BACKGROUND")
    --caelPanels.gradientPanel(panel)

    frame:ClearAllPoints()
    frame:SetWidth(panel:GetWidth() - pixel_scale(2))
    frame:SetHeight(panel:GetHeight() - pixel_scale(2))
    frame:SetAllPoints(panel)
    frame:SetFrameLevel(panel:GetFrameLevel() + 1)
end

-- Push panels table into global scope.
_G["caelPanels"] = caelPanels

--[[
caelPanels.createPanel = function(name, x, y, width, height, point, rpoint, anchor, parent, strata)

caelPanels.createPanel("caelPanel_ChatFrame", 401, 20, 321, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- Chatframes
caelPanels.createPanel("caelPanel_EditBox", 401, 150, 321, 20, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- ChatFrameEditBox
caelPanels.createPanel("caelPanel_CombatLog", -401, 20, 321, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- CombatLog
caelPanels.createPanel("caelPanel_Minimap", 0, 20, 130, 130, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- Minimap
caelPanels.createPanel("caelPanel_ActionBar1", -153, 90, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- TopLeftBar
caelPanels.createPanel("caelPanel_ActionBar2", 153, 90, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- TopRightBar
caelPanels.createPanel("caelPanel_ActionBar3", -153, 20, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- BottomLeftBar
caelPanels.createPanel("caelPanel_ActionBar4", 153, 20, 172, 60, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- BottomRightBar
caelPanels.createPanel("caelPanel_ActionBar5", -30, 0, 31, 336, "RIGHT", "RIGHT", UIParent, UIParent, "BACKGROUND") -- Side Action Bar
caelPanels.createPanel("caelPanel_DataFeed", 0, 2, 1124, 18, "BOTTOM", "BOTTOM", UIParent, UIParent, "BACKGROUND") -- DataFeeds bar
caelPanels.createPanel("caelPanel_DamageMeter", -647, 2, 167, 148, "BOTTOM", "BOTTOM", UIParent, alDamageMeterFrame, "BACKGROUND") -- MeterLeft
caelPanels.createPanel("caelPanel_ThreatMeter", 647, 2, 167, 148, "BOTTOM", "BOTTOM", UIParent, recThreatMeter, "BACKGROUND") -- MeterRight
--]]

