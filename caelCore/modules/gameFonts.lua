local _, caelCore = ...

local gameFonts = caelCore.createModule("gameFonts")

local fonts = caelUI.media.fonts

local SetFont = function(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
    obj:SetFont(font, size, style)

    if sr and sg and sb then
        obj:SetShadowColor(sr, sg, sb)
    end

    if sox and soy then
        obj:SetShadowOffset(sox, soy)
    end

    if r and g and b then
        obj:SetTextColor(r, g, b)
    elseif r then
        obj:SetAlpha(r)
    end
end

gameFonts:RegisterEvent("ADDON_LOADED")
gameFonts:SetScript("OnEvent", function(self, event, addon)

    if addon ~= "caelCore" then return end

    UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 11
    CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

    UNIT_NAME_FONT     = fonts.unit_name
    NAMEPLATE_FONT     = fonts.nameplate
    DAMAGE_TEXT_FONT   = fonts.damage_text
    STANDARD_TEXT_FONT = fonts.standard_text

    -- Base fonts
    SetFont(AchievementFont_Small,                  fonts.bold,         10)
    SetFont(GameTooltipHeader,                      fonts.bold,         13, "OUTLINE")
    SetFont(InvoiceFont_Med,                        fonts.italic,       11, nil, 0.15, 0.09, 0.04)
    SetFont(InvoiceFont_Small,                      fonts.italic,       9, nil, 0.15, 0.09, 0.04)
    SetFont(MailFont_Large,                         fonts.italic,       13, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
    SetFont(NumberFont_OutlineThick_Mono_Small,     fonts.number,       11, "OUTLINE")
    SetFont(NumberFont_Outline_Huge,                fonts.number,       28, "THICKOUTLINE", 28)
    SetFont(NumberFont_Outline_Large,               fonts.number,       15, "OUTLINE")
    SetFont(NumberFont_Outline_Med,                 fonts.number,       13, "OUTLINE")
    SetFont(NumberFont_Shadow_Med,                  fonts.normal,       12)
    SetFont(NumberFont_Shadow_Small,                fonts.normal,       10)
    SetFont(QuestFont_Large,                        fonts.normal,       14)
    SetFont(QuestFont_Shadow_Huge,                  fonts.bold,         17, nil, nil, nil, nil, 0.54, 0.4, 0.1)
    SetFont(ReputationDetailFont,                   fonts.bold,         10, nil, nil, nil, nil, 0, 0, 0, 1, -1)
    SetFont(SpellFont_Small,                        fonts.bold,         9)
    SetFont(SystemFont_InverseShadow_Small,         fonts.bold,         9)
    SetFont(SystemFont_Large,                       fonts.normal,       15)
    SetFont(SystemFont_Med1,                        fonts.normal,       11)
    SetFont(SystemFont_Med2,                        fonts.italic,       12, nil, 0.15, 0.09, 0.04)
    SetFont(SystemFont_Med3,                        fonts.normal,       13)
    SetFont(SystemFont_OutlineThick_Huge2,          fonts.normal,       20, "THICKOUTLINE")
    SetFont(SystemFont_OutlineThick_Huge4,          fonts.bold_italic,   25, "THICKOUTLINE")
    SetFont(SystemFont_OutlineThick_WTF,            fonts.bold_italic,   29, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
    SetFont(SystemFont_Outline_Small,               fonts.number,       11, "OUTLINE")
    SetFont(SystemFont_Shadow_Huge1,                fonts.bold,         18)
    SetFont(SystemFont_Shadow_Huge3,                fonts.bold,         23)
    SetFont(SystemFont_Shadow_Large,                fonts.normal,       15)
    SetFont(SystemFont_Shadow_Med1,                 fonts.normal,       11)
    SetFont(SystemFont_Shadow_Med3,                 fonts.normal,       13)
    SetFont(SystemFont_Shadow_Outline_Huge2,        fonts.normal,       20, "OUTLINE")
    SetFont(SystemFont_Shadow_Small,                fonts.bold,         9)
    SetFont(SystemFont_Small,                       fonts.normal,       10)
    SetFont(SystemFont_Tiny,                        fonts.normal,       9)
    SetFont(Tooltip_Med,                            fonts.normal,       11)
    SetFont(Tooltip_Small,                          fonts.bold,         10)

    -- Derived fonts
    SetFont(BossEmoteNormalHuge,                    fonts.bold_italic,   25, "THICKOUTLINE")
    SetFont(CombatTextFont,                         fonts.normal,       24)
    SetFont(ErrorFont,                              fonts.italic,        14, nil, 58)
    SetFont(QuestFontNormalSmall,                   fonts.bold,         11, nil, nil, nil, nil, 0.54, 0.4, 0.1)
    SetFont(WorldMapTextFont,                       fonts.bold_italic,   29, "THICKOUTLINE",  38, nil, nil, 0, 0, 0, 1, -1)

    for i = 1, NUM_CHAT_WINDOWS do
        local frame =_G[format("ChatFrame%s", i)]
        local _, size = frame:GetFont()
        frame:SetFont(fonts.chat, size)
    end

    SetFont = nil
    self:SetScript("OnEvent", nil)
    self:UnregisterAllEvents()
    self = nil
end)
