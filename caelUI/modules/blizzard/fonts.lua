local Fonts = unpack(select(2, ...)).CreateModule("GameFonts")

local setup_font

do
    --- This will do all the heavy lifting of setting our font to frame as well as all the options.
    local function set_font (frame, font, size, style, red, green, blue, shadow_red, shadow_green, shadow_blue, shadow_offset_x, shadow_offset_y)
        frame:SetFont(font, size, style)

        if shadow_red and shadow_green and shadow_blue then
            frame:SetShadowColor(shadow_red, shadow_green, shadow_blue)
        end

        if shadow_offset_x and shadow_offset_y then
            frame:SetShadowOffset(shadow_offset_x, shadow_offset_y)
        end

        if red and green and blue then
            frame:SetTextColor(red, green, blue)
        elseif red then
            frame:SetAlpha(red)
        end
    end

    --- Localize our fonts table so we don't have to make external calls all the time.
    local fonts = Fonts:GetMedia()["fonts"]

    --- This function gets called from the ADDON_LOADED event handler.
    function setup_font(self, _, addon)
        --- Don't attempt to set the fonts unless we are loading this addon.
        if addon ~= "caelUI" then
            return
        end

        UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 11
        CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

        UNIT_NAME_FONT     = fonts.unit_name
        NAMEPLATE_FONT     = fonts.nameplate
        DAMAGE_TEXT_FONT   = fonts.damage_text
        STANDARD_TEXT_FONT = fonts.standard_text

        -- Base fonts
        set_font(AchievementFont_Small,                  fonts.bold,          10)
        set_font(GameTooltipHeader,                      fonts.bold,          13, "OUTLINE")
        set_font(InvoiceFont_Med,                        fonts.italic,        11, nil, 0.15, 0.09, 0.04)
        set_font(InvoiceFont_Small,                      fonts.italic,        9,  nil, 0.15, 0.09, 0.04)
        set_font(MailFont_Large,                         fonts.italic,        13, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
        set_font(NumberFont_OutlineThick_Mono_Small,     fonts.number,        11, "OUTLINE")
        set_font(NumberFont_Outline_Huge,                fonts.number,        28, "THICKOUTLINE", 28)
        set_font(NumberFont_Outline_Large,               fonts.number,        15, "OUTLINE")
        set_font(NumberFont_Outline_Med,                 fonts.number,        13, "OUTLINE")
        set_font(NumberFont_Shadow_Med,                  fonts.normal,        12)
        set_font(NumberFont_Shadow_Small,                fonts.normal,        10)
        set_font(QuestFont_Large,                        fonts.normal,        14)
        set_font(QuestFont_Shadow_Huge,                  fonts.bold,          17, nil, nil, nil, nil, 0.54, 0.4, 0.1)
        set_font(ReputationDetailFont,                   fonts.bold,          10, nil, nil, nil, nil, 0, 0, 0, 1, -1)
        set_font(SpellFont_Small,                        fonts.bold,          9)
        set_font(SystemFont_InverseShadow_Small,         fonts.bold,          9)
        set_font(SystemFont_Large,                       fonts.normal,        15)
        set_font(SystemFont_Med1,                        fonts.normal,        11)
        set_font(SystemFont_Med2,                        fonts.italic,        12, nil, 0.15, 0.09, 0.04)
        set_font(SystemFont_Med3,                        fonts.normal,        13)
        set_font(SystemFont_OutlineThick_Huge2,          fonts.normal,        20, "THICKOUTLINE")
        set_font(SystemFont_OutlineThick_Huge4,          fonts.bold_italic,   25, "THICKOUTLINE")
        set_font(SystemFont_OutlineThick_WTF,            fonts.bold_italic,   29, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
        set_font(SystemFont_Outline_Small,               fonts.number,        11, "OUTLINE")
        set_font(SystemFont_Shadow_Huge1,                fonts.bold,          18)
        set_font(SystemFont_Shadow_Huge3,                fonts.bold,          23)
        set_font(SystemFont_Shadow_Large,                fonts.normal,        15)
        set_font(SystemFont_Shadow_Med1,                 fonts.normal,        11)
        set_font(SystemFont_Shadow_Med3,                 fonts.normal,        13)
        set_font(SystemFont_Shadow_Outline_Huge2,        fonts.normal,        20, "OUTLINE")
        set_font(SystemFont_Shadow_Small,                fonts.bold,          9)
        set_font(SystemFont_Small,                       fonts.normal,        10)
        set_font(SystemFont_Tiny,                        fonts.normal,        9)
        set_font(Tooltip_Med,                            fonts.normal,        11)
        set_font(Tooltip_Small,                          fonts.bold,          10)

        -- Derived fonts
        set_font(BossEmoteNormalHuge,                    fonts.bold_italic,   25, "THICKOUTLINE")
        set_font(CombatTextFont,                         fonts.normal,        24)
        set_font(ErrorFont,                              fonts.italic,        14, nil, 58)
        set_font(QuestFontNormalSmall,                   fonts.bold,          11, nil, nil, nil, nil, 0.54, 0.4, 0.1)
        set_font(WorldMapTextFont,                       fonts.bold_italic,   29, "THICKOUTLINE",  38, nil, nil, 0, 0, 0, 1, -1)

        for chat_frame_index = 1, NUM_CHAT_WINDOWS do
            local frame =_G[format("ChatFrame%s", chat_frame_index)]
            frame:SetFont(fonts.chat, 11)
        end
    end
end

Fonts:RegisterEvent("ADDON_LOADED", setup_font)
