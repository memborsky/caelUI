local private = unpack(select(2, ...))

local original_fonts

local media = private.database.get("media")

do
    local function custom_font(font, alternate_font)
        if media.custom_fonts and media.custom_fonts[font] then
            return media.custom_fonts[font]
        end

        return alternate_font
    end

    local font_path = media.directory .. [=[fonts\]=]

    local base_fonts = {
        normal      = custom_font("normal",      font_path .. [=[neuropol x cd rg.ttf]=]),
        bold        = custom_font("bold",        font_path .. [=[neuropol x cd bd.ttf]=]),
        italic      = custom_font("italic",      font_path .. [=[neuropol x cd rg it.ttf]=]),
        bold_italic = custom_font("bold_italic", font_path .. [=[neuropol x cd bd it.ttf]=]),
    }

    original_fonts = {
        normal      = base_fonts.normal,
        bold        = base_fonts.bold,
        bold_italic = base_fonts.bold_italic,
        italic      = base_fonts.italic,
        number      = base_fonts.bold,

        unit_name     = custom_font("unit_name",     base_fonts.normal),
        nameplate     = custom_font("nameplate",     base_fonts.bold),
        damage_text   = custom_font("damage_text",   base_fonts.bold),
        standard_text = custom_font("standard_text", base_fonts.normal),
        chat          = custom_font("chat",          font_path .. [=[xenara rg.ttf]=]),

        -- addon related stuff.
        custom_number       = custom_font("custom_numberfont",   font_path .. [=[russel square lt.ttf]=]),
        scroll_frame_normal = custom_font("scroll_frame_normal", base_fonts.normal),
        scroll_frame_bold   = custom_font("scroll_frame_bold",   base_fonts.bold),
        nameplate           = custom_font("nameplate",           font_path .. [=[xenara rg.ttf]=]),
    }
end

media.fonts = original_fonts

private.database.save(media)
