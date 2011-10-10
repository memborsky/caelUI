local F = select(1, unpack(select(2, ...)))

-- Localizing pixelScale
local pixelScale = F.pixelScale

-- Get our media database if it exists or create a new one.
local media = F.get_database("media")

media.directory = [=[Interface\Addons\caelUI\media\]=]

media.files = {
    bgFile              = [=[Interface\ChatFrame\ChatFrameBackground]=],
    edgeFile            = media.directory .. [=[borders\glowtex3]=],
    raidIcons           = media.directory .. [=[miscellaneous\raidicons]=],
    statusBarA          = media.directory .. [=[statusbars\normtexa]=],
    statusBarB          = media.directory .. [=[statusbars\normtexb]=],
    statusBarC          = media.directory .. [=[statusbars\normtexc]=],
    statusBarD          = media.directory .. [=[statusbars\normtexd]=],
    statusBarE          = media.directory .. [=[statusbars\normtexe]=],

    buttonNormal        = media.directory .. [=[buttons\buttonnormal]=],
    buttonPushed        = media.directory .. [=[buttons\buttonpushed]=],
    buttonChecked       = media.directory .. [=[buttons\buttonchecked]=],
    buttonHighlight     = media.directory .. [=[buttons\buttonhighlight]=],
    buttonFlash         = media.directory .. [=[buttons\buttonflash]=],
    buttonBackdrop      = media.directory .. [=[buttons\buttonbackdrop]=],
    buttonGloss         = media.directory .. [=[buttons\buttongloss]=],

    soundAlarm          = media.directory .. [=[sounds\alarm.mp3]=],
    soundLeavingCombat  = media.directory .. [=[sounds\combat-.mp3]=],
    soundEnteringCombat = media.directory .. [=[sounds\combat+.mp3]=],
    soundCombo          = media.directory .. [=[sounds\combo.mp3]=],
    soundComboMax       = media.directory .. [=[sounds\finish.mp3]=],
    soundGodlike        = media.directory .. [=[sounds\godlike.mp3]=],
    soundLnLProc        = media.directory .. [=[sounds\lnl.mp3]=],
    soundskillUp        = media.directory .. [=[sounds\skill up.mp3]=],
    soundWarning        = media.directory .. [=[sounds\warning.mp3]=],
    soundAggro          = media.directory .. [=[sounds\aggro.mp3]=],
    soundWhisper        = media.directory .. [=[sounds\whisper.mp3]=]
}

media.insetTable = {
    left    = pixelScale(2),
    right   = pixelScale(2),
    top     = pixelScale(2),
    bottom  = pixelScale(2)
}

media.backdropTable = {
    bgFile   = media.files.bgFile,
    edgeFile = media.files.edgeFile,
    edgeSize = pixelScale(2),
    insets   = media.insetTable
}

media.borderTable = {
    bgFile   = nil,
    edgeFile = media.files.edgeFile,
    edgeSize = pixelScale(4),
    insets   = media.insetTable
}

function media.createBackdrop (parent)
    local backdrop = CreateFrame("Frame", nil, parent)
    backdrop:SetPoint("TOPLEFT", parent, "TOPLEFT", pixelScale(-2.5), pixelScale(2.5))
    backdrop:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", pixelScale(2.5), pixelScale(-2.5))
    backdrop:SetFrameLevel(parent:GetFrameLevel() -1 > 0 and parent:GetFrameLevel() -1 or 0)
    backdrop:SetBackdrop(media.backdropTable)
    backdrop:SetBackdropColor(0, 0, 0, 0.5)
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    return backdrop
end

-- We do this just to make sure that everything is getting saved to the users variables.
media:save()
