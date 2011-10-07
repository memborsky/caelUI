local F = select(1, unpack(select(2, ...)))

-- Localizing pixelScale
local pixelScale = F.pixelScale

-- Get our media database if it exists or create a new one.
local media = F.get_database("media")

media.directory = [=[Interface\Addons\caelUI\media]=]

media.files = {
    bgFile              = [=[Interface\ChatFrame\ChatFrameBackground]=],
    edgeFile            = [=[Interface\Addons\media\borders\glowtex3]=],
    raidIcons           = [=[Interface\Addons\media\miscellaneous\raidicons]=],
    statusBarA          = [=[Interface\Addons\media\statusbars\normtexa]=],
    statusBarB          = [=[Interface\Addons\media\statusbars\normtexb]=],
    statusBarC          = [=[Interface\Addons\media\statusbars\normtexc]=],
    statusBarD          = [=[Interface\Addons\media\statusbars\normtexd]=],
    statusBarE          = [=[Interface\Addons\media\statusbars\normtexe]=],

    buttonNormal        = [=[Interface\AddOns\media\buttons\buttonnormal]=],
    buttonPushed        = [=[Interface\AddOns\media\buttons\buttonpushed]=],
    buttonChecked       = [=[Interface\AddOns\media\buttons\buttonchecked]=],
    buttonHighlight     = [=[Interface\AddOns\media\buttons\buttonhighlight]=],
    buttonFlash         = [=[Interface\AddOns\media\buttons\buttonflash]=],
    buttonBackdrop      = [=[Interface\AddOns\media\buttons\buttonbackdrop]=],
    buttonGloss         = [=[Interface\AddOns\media\buttons\buttongloss]=],

    soundAlarm          = [=[Interface\Addons\media\sounds\alarm.mp3]=],
    soundLeavingCombat  = [=[Interface\Addons\media\sounds\combat-.mp3]=],
    soundEnteringCombat = [=[Interface\Addons\media\sounds\combat+.mp3]=],
    soundCombo          = [=[Interface\Addons\media\sounds\combo.mp3]=],
    soundComboMax       = [=[Interface\Addons\media\sounds\finish.mp3]=],
    soundGodlike        = [=[Interface\Addons\media\sounds\godlike.mp3]=],
    soundLnLProc        = [=[Interface\Addons\media\sounds\lnl.mp3]=],
    soundskillUp        = [=[Interface\Addons\media\sounds\skill up.mp3]=],
    soundWarning        = [=[Interface\Addons\media\sounds\warning.mp3]=],
    soundAggro          = [=[Interface\Addons\media\sounds\aggro.mp3]=],
    soundWhisper        = [=[Interface\Addons\media\sounds\whisper.mp3]=]
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

media.createBackdrop = function(parent)
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
