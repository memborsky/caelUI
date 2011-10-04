--[[    $Id$    ]]

--[[    Rename this file to customFonts.lua if you want to use custom fonts    ]]

local _, caelMedia = ...

--[=[     Custom fonts should be added to the following table.
There are a number of different fonts being used through the UI.
The default font has various different styles, with names that speak for themselves:
NORMAL, BOLD, BOLDITALIC, ITALIC, CUSTOM_NUMBERFONT, CHAT_FONT

The UI will always fall back to the default caelUI font if you don't specify a custom font,
so there is no need to specify all fonts.

Example:

caelMedia.customFonts = {
	BOLD = [[Folder path\To my font\font.ttf]],
}
]=]

caelMedia.customFonts = {
	NORMAL				= [=[Interface\Addons\caelMedia\fonts\Continuum_Medium.ttf]=],
	DAMAGE_TEXT_FONT	= [=[Interface\Addons\caelMedia\fonts\tramyad.ttf]=],
}
