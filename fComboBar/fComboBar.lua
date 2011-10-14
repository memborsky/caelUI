local movable = false;

local pixelScale = caelUI.config.pixelScale
local media = caelUI.media

--- Options ---
local LAYOUT = 2; -- 1 = Vertical, Anything else = Horizontal
local WIDTH = 40;
local HEIGHT = 10;
local SPACING = 3;
local COLORS = {
    {0, 0.6, 0},
    {0.3, 0.6, 0},
    {0.6, 0.6, 0},
    {0.6, 0.3, 0},
    {0.6, 0, 0}
}
---------------

local function SetFontString (parent, fontName, fontHeight, fontStyle)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(fontName, fontHeight, fontStyle)
    fs:SetJustifyH("LEFT")
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(1.25, -1.25)
    return fs
end

local function CreateShadow(f, t)
    if f.shadow then return end -- we seriously don't want to create shadow 2 times in a row on the same frame.

    borderr, borderg, borderb = 0, 0, 0
    backdropr, backdropg, backdropb = 0, 0, 0

    if t == "ClassColor" then
        local c = T.oUF_colors.class[class]
        borderr, borderg, borderb = c[1], c[2], c[3]
        backdropr, backdropg, backdropb = 0, 0, 0
    end

    local shadow = CreateFrame("Frame", nil, f)
    shadow:SetFrameLevel(1)
    shadow:SetFrameStrata(f:GetFrameStrata())
    shadow:SetPoint("TOPLEFT", -3, 3)
    shadow:SetPoint("BOTTOMLEFT", -3, -3)
    shadow:SetPoint("TOPRIGHT", 3, 3)
    shadow:SetPoint("BOTTOMRIGHT", 3, -3)
    shadow:SetBackdrop( { 
        edgeFile = media.files.edgeFile, edgeSize = pixelScale(3),
        insets = {left = pixelScale(5), right = pixelScale(5), top = pixelScale(5), bottom = pixelScale(5)},
    })
    shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
    shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.8)
    f.shadow = shadow
end

-- Anchorframe
TukuiComboAnchor = caelPanels.createPanel("TukuiComboAnchor", {pixelScale(150), pixelScale(13)}, {"CENTER", UIParent, "CENTER", pixelScale(0), pixelScale(100)})
TukuiComboAnchor.text = SetFontString(TukuiComboAnchor, media.fonts.NORMAL, 11, "MONOCHROMEOUTLINE");
TukuiComboAnchor.text:SetText("COMBO POINTS");
TukuiComboAnchor.text:SetPoint("CENTER", 0, 1);
TukuiComboAnchor:SetMovable(true);
TukuiComboAnchor:SetUserPlaced(true);
TukuiComboAnchor:RegisterForDrag("LeftButton", "RightButton");
TukuiComboAnchor:SetScript("OnDragStart", function(self)
    self:StartMoving();
end);       
TukuiComboAnchor:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing();
end);
TukuiComboAnchor:Hide();

local function CreateComboButton()
    local button = CreateFrame("Frame", nil, UIParent);
    button:SetSize(WIDTH, HEIGHT);
    button:SetBackdrop(media.backdropTable)
    button:SetBackdropColor(0, 0, 0)
    button.overlay = button:CreateTexture(nil, "OVERLAY")
    --button:CreateOverlay();
    button.overlay:SetAlpha(0.5);
    CreateShadow(button);
    button:SetAlpha(0);
    
    function button:FadeIn()
        UIFrameFadeIn(self, (0.1 * (1-self:GetAlpha())), self:GetAlpha(), 1)
    end

    function button:FadeOut()
        UIFrameFadeOut(self, (0.1 * (0+self:GetAlpha())), self:GetAlpha(), 0)
    end
    
    return button;
end

-- Creating comboframes
for i = 1, 5 do
    tinsert(TukuiComboAnchor, CreateComboButton());
end

-- Setting up layout (double iteration wont be noticable, easier to solve perfect horizontal anchoring this way)
for i = 1, 5 do
    if (LAYOUT == 1) then
        if (i == 1) then
            TukuiComboAnchor[i]:SetPoint("BOTTOM", TukuiComboAnchor, "TOP", 0, 3);
        else
            TukuiComboAnchor[i]:SetPoint("BOTTOM", TukuiComboAnchor[i-1], "TOP", 0, SPACING);
        end
    else
        TukuiComboAnchor[3]:SetPoint("TOP", TukuiComboAnchor, "BOTTOM", 0, -SPACING);
        TukuiComboAnchor[2]:SetPoint("RIGHT", TukuiComboAnchor[3], "LEFT", -SPACING, 0);
        TukuiComboAnchor[1]:SetPoint("RIGHT", TukuiComboAnchor[2], "LEFT", -SPACING, 0);
        TukuiComboAnchor[4]:SetPoint("LEFT", TukuiComboAnchor[3], "RIGHT", SPACING, 0);
        TukuiComboAnchor[5]:SetPoint("LEFT", TukuiComboAnchor[4], "RIGHT", SPACING, 0);
    end
end

local function GetCPs()
    if (movable) then
        return 5;
    end
    return GetComboPoints("player", "target");
end

local function UpdateCPs()
    local cp = GetCPs();
    for i = 1, 5 do
        if cp > 0 then
            TukuiComboAnchor[i]:SetBackdropBorderColor(unpack(COLORS[cp]));
            TukuiComboAnchor[i].overlay:SetVertexColor(unpack(COLORS[cp]));
        end
        if (i > cp) then
            TukuiComboAnchor[i]:FadeOut();
        else
            TukuiComboAnchor[i]:FadeIn();
        end
    end
end

-- Eventhandling
TukuiComboAnchor:RegisterEvent("PLAYER_ENTERING_WORLD");
TukuiComboAnchor:RegisterEvent("UNIT_COMBO_POINTS");
TukuiComboAnchor:RegisterEvent("PLAYER_TARGET_CHANGED");
TukuiComboAnchor:SetScript("OnEvent", UpdateCPs)

-- SlashCmd
SLASH_TUKUICOMBO1 = "/tcp";
SlashCmdList["TUKUICOMBO"] = function()
    movable = not movable;
    
    if (movable) then
        TukuiComboAnchor:Show();
        TukuiComboAnchor:EnableMouse(true);
    else
        TukuiComboAnchor:Hide();
        TukuiComboAnchor:EnableMouse(false);
    end
    UpdateCPs();
end
