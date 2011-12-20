local private = unpack(select(2, ...))

-- localizing PixelScale
local PixelScale = private.PixelScale

-- Create the media table.
private.media = {}

local media = private.media

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
    statusbar_f             = media.directory .. [=[statusbars\normtexf]=],
    statusbar_g             = media.directory .. [=[statusbars\normtexg]=],

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
    sound_whisper           = media.directory .. [=[sounds\whisper.mp3]=],

    largeshadertex1         = media.directory .. [=[miscellaneous\largeshadertex1]=],
    largeshadertex2         = media.directory .. [=[miscellaneous\largeshadertex2]=]
}

media.inset_table = {
    left    = PixelScale(2),
    right   = PixelScale(2),
    top     = PixelScale(2),
    bottom  = PixelScale(2)
}

media.backdrop_table = {
    bgFile   = media.files.background,
    edgeFile = media.files.edge,
    edgeSize = PixelScale(2),
    insets   = media.inset_table
}

media.border_table = {
    bgFile   = nil,
    edgeFile = media.files.edge,
    edgeSize = PixelScale(4),
    insets   = media.inset_table
}

function media.create_backdrop (self, name)
    local parent

    -- If we are creating a backdrop, we are creating a border on the frame so we need to shrink the actual frame just ever so slightly.
    do
        local width, height = self:GetSize()

        self:SetSize(width - 4, height - 4)
    end

    if self:GetObjectType() == "Frame" or self:GetObjectType() == "StatusBar" then
        parent = self
    elseif self.GetParent and self:GetParent():GetObjectType() == "Frame" or self:GetParent():GetObjectType() == "StatusBar" then
        parent = self:GetParent()
    else
        parent = UIParent
    end

    self.backdrop = CreateFrame("Frame", name and name .. "Backdrop" or nil, parent)
    self.SetPoint(self.backdrop, "TOPLEFT", self, "TOPLEFT", -2, 2)
    self.SetPoint(self.backdrop, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
    self.backdrop:SetFrameLevel(parent:GetFrameLevel() - 1 > 0 and parent:GetFrameLevel() - 1 or 0)
    self.backdrop:SetBackdrop(media.backdrop_table)
    self.backdrop:SetBackdropColor(0, 0, 0, 0.4)
    self.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    self.backdrop:SetFrameStrata("BACKGROUND")

    -- Move the frame back to where it was placed after the backdrop was created.
    self:SetPoint(self:GetPoint())

    return self
end

function media.create_blank_backdrop (parent, name)
    local overlay = CreateFrame("Frame", name and name or nil, parent)
    overlay:SetFrameLevel(parent:GetFrameLevel() - 1 > 0 and parent:GetFrameLevel() - 1 or 1)
    overlay:SetFrameStrata("BACKGROUND")
    overlay:SetPoint("TOPLEFT", parent, "TOPLEFT", PixelScale(-2.5), PixelScale(2.5))
    overlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", PixelScale(2.5), PixelScale(-2.5))
    overlay:SetBackdrop({
        bgFile = [[Interface\Addons\caelUI\media\borders\blank]],
        edgeFile = [[Interface\Addons\caelUI\media\borders\blank]],
        tile = false, tileSize = 0, edgeSize = PixelScale(1),
        insets = {left = -PixelScale(1), right = -PixelScale(1), top = -PixelScale(1), bottom = -PixelScale(1)}
    })
    overlay:SetBackdropColor(0, 0, 0, 0.5)
    overlay:SetBackdropBorderColor(0, 0, 0, 1)
    return overlay
end

function media.create_shadow (parent, name)
    local shadow = CreateFrame("Frame", name and name or nil, parent)
    shadow:SetFrameLevel(parent:GetFrameLevel() - 1 > 0 and parent:GetFrameLevel() - 1 or 1)
    shadow:SetFrameStrata("BACKGROUND")
    shadow:SetPoint("TOPLEFT", -PixelScale(3), PixelScale(3))
    shadow:SetPoint("BOTTOMLEFT", -PixelScale(3), -PixelScale(3))
    shadow:SetPoint("TOPRIGHT", PixelScale(3), PixelScale(3))
    shadow:SetPoint("BOTTOMRIGHT", PixelScale(3), -PixelScale(3))
    shadow:SetBackdrop({
        edgeFile = [[Interface\Addons\caelUI\media\borders\glowTex1]], edgeSize = PixelScale(3),
        insets = {left = PixelScale(5), right = PixelScale(5), top = PixelScale(5), bottom = PixelScale(5)},
    })
    shadow:SetBackdropColor(0, 0, 0, 0)
    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
    return shadow
end
