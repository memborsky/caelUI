local _, caelPanels = ...

local bar1OnLeft = false
local chatOnLeft = false

caelPanels.eventFrame = CreateFrame("frame", nil, UIParent)

local panels = {}
local PixelScale = caelUI.config.PixelScale
local media = caelUI.media

local defaultPanel = {
    ["EnableMouse"] = false,
    ["SetFrameStrata"] = "BACKGROUND",
    ["SetBackdrop"] = media.backdrop_table,
    ["SetBackdropColor"] = {0, 0, 0, 0.5},
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
    local width = PixelScale(panel:GetWidth() - 6)
    local height = PixelScale(panel:GetHeight() / 5)
    local bgTexture = media.files.background

    local gradientTop = panel:CreateTexture(nil, "BORDER")
    gradientTop:SetTexture(bgTexture)
    gradientTop:SetSize(width, height)
    gradientTop:SetPoint("TOPLEFT", PixelScale(3), PixelScale(-2))
    gradientTop:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.84, 0.75, 0.65, 0.5)

    local gradientBottom = panel:CreateTexture(nil, "BORDER")
    gradientBottom:SetTexture(bgTexture)
    gradientBottom:SetSize(width, height)
    gradientBottom:SetPoint("BOTTOMRIGHT", PixelScale(-3), PixelScale(2))
    gradientBottom:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.75, 0, 0, 0, 0)
end

caelPanels.eventFrame:RegisterEvent("ADDON_LOADED")
caelPanels.eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...

        if addon == "caelPanels" then
            -- This variable lets us change the size of caelPanel_ActionBar<1-4> with ease.
            -- local actionBarSize = {PixelScale(161), PixelScale(53)}
            local actionBarSize = {PixelScale(172), PixelScale(60)}

            local createPanel = caelPanels.createPanel
            
            createPanel("caelPanel_DataFeed", {PixelScale(1124), PixelScale(18)}, {"BOTTOM", UIParent, "BOTTOM", 0, PixelScale(2)})
            createPanel("caelPanel_Minimap", {PixelScale(130), PixelScale(130)}, {"BOTTOM", UIParent, "BOTTOM", 0, PixelScale(20)}, {["SetFrameStrata"] = "MEDIUM"})
            createPanel("caelPanel_ChatFrame", {PixelScale(321), PixelScale(130)}, {"BOTTOM", UIParent, "BOTTOM", PixelScale(401), PixelScale(20)})
            createPanel("caelPanel_EditBox", {caelPanel_ChatFrame:GetWidth(), PixelScale(20)}, {"BOTTOMLEFT", caelPanel_ChatFrame, "TOPLEFT"})
            createPanel("caelPanel_CombatLog", {PixelScale(321), PixelScale(130)}, {"BOTTOM", UIParent, "BOTTOM", -PixelScale(401), PixelScale(20)})
            createPanel("caelPanel_ActionBar1", actionBarSize, {"BOTTOM", UIParent, "BOTTOM", PixelScale(153), PixelScale(90)})
            createPanel("caelPanel_ActionBar2", actionBarSize, {"BOTTOM", UIParent, "BOTTOM", -PixelScale(153), PixelScale(90)})
            createPanel("caelPanel_ActionBar3", actionBarSize, {"BOTTOM", UIParent, "BOTTOM", -PixelScale(153), PixelScale(20)})
            createPanel("caelPanel_ActionBar4", actionBarSize, {"BOTTOM", UIParent, "BOTTOM", PixelScale(153), PixelScale(20)})
            createPanel("caelPanel_ActionBar5", {PixelScale(31), PixelScale(336)}, {"RIGHT", UIParent, "RIGHT"})            

            -- Damage Meter
            if IsAddOnLoaded("alDamageMeter") then
                createPanel("caelPanel_DamageMeter", {PixelScale(167), PixelScale(148)}, {"BOTTOM", UIParent, "BOTTOM", -PixelScale(647), PixelScale(2)})
            end

            -- Threat Meter
            -- XXX: hack_threat_01, recThreatMeter currently requires that we always make the panel and just hide it here if we aren't using it.
            createPanel("caelPanel_ThreatMeter", {PixelScale(167), PixelScale(148)}, {"BOTTOM", UIParent, "BOTTOM", PixelScale(647), PixelScale(2)}):Hide()
        end
    end
end)

function caelPanels.SetupAddonPanel(panel, frame)
    panel:SetParent(frame)
    panel:SetFrameStrata("BACKGROUND")
    --caelPanels.gradientPanel(panel)

    frame:ClearAllPoints()
    frame:SetWidth(panel:GetWidth() - PixelScale(2))
    frame:SetHeight(panel:GetHeight() - PixelScale(2))
    frame:SetAllPoints(panel)
    frame:SetFrameLevel(panel:GetFrameLevel() + 1)
end

-- Push panels table into global scope.
_G["caelPanels"] = caelPanels
