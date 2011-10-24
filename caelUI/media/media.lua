local private = unpack(select(2, ...))

-- localizing pixel_scale
local pixel_scale = private.database.get("config").pixel_scale

-- get our media database if it exists or create a new one.
local media = private.database.get("media")

media.directory = [=[Interface\Addons\caelUI\media\]=]

media.files = {
    background              = [=[Interface\ChatFrame\ChatFrameBackground]=],
    edge                    = media.directory .. [=[borders\glowtex3]=],
    raid_icons              = media.directory .. [=[miscellaneous\raidicons]=],
    statusbar_a             = media.directory .. [=[statusbars\normtexa]=],
    statusbar_b             = media.directory .. [=[statusbars\normtexb]=],
    statusbar_c             = media.directory .. [=[statusbars\normtexc]=],
    statusbar_d             = media.directory .. [=[statusbars\normtexd]=],
    statusbar_e             = media.directory .. [=[statusbars\normtexe]=],

    button_normal           = media.directory .. [=[buttons\buttonnormal]=],
    button_pushed           = media.directory .. [=[buttons\buttonpushed]=],
    button_checked          = media.directory .. [=[buttons\buttonchecked]=],
    button_highlight        = media.directory .. [=[buttons\buttonhighlight]=],
    button_flash            = media.directory .. [=[buttons\buttonflash]=],
    button_backdrop         = media.directory .. [=[buttons\buttonbackdrop]=],
    button_gloss            = media.directory .. [=[buttons\buttongloss]=],

    sound_alarm             = media.directory .. [=[sounds\alarm.mp3]=],
    sound_leaving_combat    = media.directory .. [=[sounds\combat-.mp3]=],
    sound_entering_combat   = media.directory .. [=[sounds\combat+.mp3]=],
    sound_combo             = media.directory .. [=[sounds\combo.mp3]=],
    sound_combo_max         = media.directory .. [=[sounds\finish.mp3]=],
    sound_godlike           = media.directory .. [=[sounds\godlike.mp3]=],
    sound_lnlproc           = media.directory .. [=[sounds\lnl.mp3]=],
    sound_skillup           = media.directory .. [=[sounds\skill up.mp3]=],
    sound_warning           = media.directory .. [=[sounds\warning.mp3]=],
    sound_aggro             = media.directory .. [=[sounds\aggro.mp3]=],
    sound_whisper           = media.directory .. [=[sounds\whisper.mp3]=]
}

media.inset_table = {
    left    = pixel_scale(2),
    right   = pixel_scale(2),
    top     = pixel_scale(2),
    bottom  = pixel_scale(2)
}

media.backdrop_table = {
    bgFile   = media.files.background,
    edgeFile = media.files.edge,
    edgeSize = pixel_scale(2),
    insets   = media.inset_table
}

media.border_table = {
    bgFile   = nil,
    edgeFile = media.files.edge,
    edgeSize = pixel_scale(4),
    insets   = media.inset_table
}

private.database.get("panels").create_backdrop = function (parent)
    local backdrop = CreateFrame("Frame", nil, parent)
    backdrop:SetPoint("TOPLEFT", parent, "TOPLEFT", pixel_scale(-2.5), pixel_scale(2.5))
    backdrop:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", pixel_scale(2.5), pixel_scale(-2.5))
    backdrop:SetFrameLevel(parent:GetFrameLevel() - 1 > 0 and parent:GetFrameLevel() - 1 or 0)
    backdrop:SetBackdrop(media.backdrop_table)
    backdrop:SetBackdropColor(0, 0, 0, 0.5)
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    return backdrop
end

-- We do this just to make sure that everything is getting saved to the users variables.
private.database.save(media)
