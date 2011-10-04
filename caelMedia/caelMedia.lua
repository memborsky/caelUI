--[[    $Id$    ]]

local _, caelMedia = ...
_G["caelMedia"] = caelMedia

caelMedia.DIRECTORY     = [=[Interface\Addons\caelMedia]=]

caelMedia.files = {
    bgFile              = [=[Interface\ChatFrame\ChatFrameBackground]=],
    edgeFile            = [=[Interface\Addons\caelMedia\borders\glowtex3]=],
    raidIcons           = [=[Interface\Addons\caelMedia\miscellaneous\raidicons]=],
    statusBarA          = [=[Interface\Addons\caelMedia\statusbars\normtexa]=],
    statusBarB          = [=[Interface\Addons\caelMedia\statusbars\normtexb]=],
    statusBarC          = [=[Interface\Addons\caelMedia\statusbars\normtexc]=],
    statusBarD          = [=[Interface\Addons\caelMedia\statusbars\normtexd]=],
    statusBarE          = [=[Interface\Addons\caelMedia\statusbars\normtexe]=],

    buttonNormal        = [=[Interface\AddOns\caelMedia\buttons\buttonnormal]=],
    buttonPushed        = [=[Interface\AddOns\caelMedia\buttons\buttonpushed]=],
    buttonChecked       = [=[Interface\AddOns\caelMedia\buttons\buttonchecked]=],
    buttonHighlight     = [=[Interface\AddOns\caelMedia\buttons\buttonhighlight]=],
    buttonFlash         = [=[Interface\AddOns\caelMedia\buttons\buttonflash]=],
    buttonBackdrop      = [=[Interface\AddOns\caelMedia\buttons\buttonbackdrop]=],
    buttonGloss         = [=[Interface\AddOns\caelMedia\buttons\buttongloss]=],

    soundAlarm          = [=[Interface\Addons\caelMedia\sounds\alarm.mp3]=],
    soundLeavingCombat  = [=[Interface\Addons\caelMedia\sounds\combat-.mp3]=],
    soundEnteringCombat = [=[Interface\Addons\caelMedia\sounds\combat+.mp3]=],
    soundCombo          = [=[Interface\Addons\caelMedia\sounds\combo.mp3]=],
    soundComboMax       = [=[Interface\Addons\caelMedia\sounds\finish.mp3]=],
    soundGodlike        = [=[Interface\Addons\caelMedia\sounds\godlike.mp3]=],
    soundLnLProc        = [=[Interface\Addons\caelMedia\sounds\lnl.mp3]=],
    soundskillUp        = [=[Interface\Addons\caelMedia\sounds\skill up.mp3]=],
    soundWarning        = [=[Interface\Addons\caelMedia\sounds\warning.mp3]=],
    soundAggro          = [=[Interface\Addons\caelMedia\sounds\aggro.mp3]=],
    soundWhisper        = [=[Interface\Addons\caelMedia\sounds\whisper.mp3]=],
}

--    caelMedia.fontObject = CreateFont("caelMediaFontObject")
--    caelMedia.fontObject:SetFont(caelMedia.files.fontRg, 10, nil)

caelMedia.insetTable = {
    left    = caelLib.scale(2),
    right   = caelLib.scale(2),
    top     = caelLib.scale(2),
    bottom  = caelLib.scale(2)
}

caelMedia.backdropTable = {
    bgFile   = caelMedia.files.bgFile,
    edgeFile = caelMedia.files.edgeFile,
    edgeSize = caelLib.scale(2),
    insets   = caelMedia.insetTable
}

caelMedia.borderTable = {
    bgFile   = nil,
    edgeFile = caelMedia.files.edgeFile,
    edgeSize = caelLib.scale(4),
    insets   = caelMedia.insetTable
}

caelMedia.createBackdrop = function(parent)
    local backdrop = CreateFrame("Frame", nil, parent)
    backdrop:SetPoint("TOPLEFT", parent, "TOPLEFT", caelLib.scale(-2.5), caelLib.scale(2.5))
    backdrop:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", caelLib.scale(2.5), caelLib.scale(-2.5))
    backdrop:SetFrameLevel(parent:GetFrameLevel() -1 > 0 and parent:GetFrameLevel() -1 or 0)
    backdrop:SetBackdrop(caelMedia.backdropTable)
    backdrop:SetBackdropColor(0, 0, 0, 0.5)
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    return backdrop
end

--[[
caelMedia.buttonTable = {
bgFile = caelMedia.files.buttonBackdrop,
edgeFile = nil,
edgeSize = 0,
insets = { left = 0, right = 0, top = 0, bottom = 0 }
}
--]]
