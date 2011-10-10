local F = select(1, unpack(select(2, ...)))

local media = F.get_database("media")

--[=[

Custom fonts should be added to the following table.

There are a number of different fonts being used through the UI.
The default font has various different styles, with names that speak for themselves:

NORMAL, BOLD, BOLDITALIC, ITALIC, CUSTOM_NUMBERFONT, CHAT_FONT

The UI will always fall back to the default caelUI font if you don't specify a custom font,
so there is no need to specify all fonts.

Example:

media.customFonts = {
	BOLD = [[Folder path\To my font\font.ttf]],
}
]=]

media.customFonts = {
	NORMAL				= [=[Interface\Addons\caelUI\media\fonts\Continuum_Medium.ttf]=],
	DAMAGE_TEXT_FONT	= [=[Interface\Addons\caelUI\media\fonts\tramyad.ttf]=],
}
