local F = select(1, unpack(select(2, ...)))

local originalFonts

local media = F.get_database("media")

do
    local function customFont(font, altFont)
        if caelMedia.customFonts and caelMedia.customFonts[font] then
            return caelMedia.customFonts[font]
        end

        return altFont
    end

    local fontPath = [=[Interface\Addons\caelUI\media\fonts\]=]

    local baseFonts = {
        NORMAL     = customFont("NORMAL",        fontPath .. [=[neuropol x cd rg.ttf]=]),
        BOLD       = customFont("BOLD",          fontPath .. [=[neuropol x cd bd.ttf]=]),
        ITALIC     = customFont("ITALIC",        fontPath .. [=[neuropol x cd rg it.ttf]=]),
        BOLDITALIC = customFont("BOLDITALIC",    fontPath .. [=[neuropol x cd bd it.ttf]=]),
    }

    originalFonts = {
        NORMAL              = baseFonts.NORMAL,
        BOLD                = baseFonts.BOLD,
        BOLDITALIC          = baseFonts.BOLDITALIC,
        ITALIC              = baseFonts.ITALIC,
        NUMBER              = baseFonts.BOLD,

        UNIT_NAME_FONT      = customFont("UNIT_NAME_FONT",       baseFonts.NORMAL),
        NAMEPLATE_FONT      = customFont("NAMEPLATE_FONT",       baseFonts.BOLD),
        DAMAGE_TEXT_FONT    = customFont("DAMAGE_TEXT_FONT",     baseFonts.BOLD),
        STANDARD_TEXT_FONT  = customFont("STANDARD_TEXT_FONT",   baseFonts.NORMAL),
        CHAT_FONT           = customFont("CHAT_FONT",            fontPath .. [=[xenara rg.ttf]=]),

        -- Addon related stuff.
        CUSTOM_NUMBERFONT   = customFont("CUSTOM_NUMBERFONT",    fontPath .. [=[russel square lt.ttf]=]),
        SCROLLFRAME_NORMAL  = customFont("SCROLLFRAME_NORMAL",   baseFonts.NORMAL),
        SCROLLFRAME_BOLD    = customFont("SCROLLFRAME_BOLD",     baseFonts.BOLD),
        CAELNAMEPLATE_FONT  = customFont("CAELNAMEPLATE_FONT",   fontPath .. [=[xenara rg.ttf]=]),
    }
end

--local media = F.get_database("media")

media.fonts = originalFonts
