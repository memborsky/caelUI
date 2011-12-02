local private = unpack(select(2, ...))

local media = private.database.get("media")

--[=[

Custom fonts should be added to the following table.

There are a number of different fonts being used through the UI.
The default font has various different styles, with names that speak for themselves:

Normal, Bold, Bold_Italic, Italic, Custom_Number, Chat

The UI will always fall back to the default caelUI font if you don't specify a custom font,
so there is no need to specify all fonts.

Example:

media.Custom_Fonts = {
    Bold = [[Folder path\To my font\font.ttf]],
}
]=]

media.custom_fonts = {
    normal      = [=[Interface\Addons\caelUI\media\fonts\Inconsolata.otf]=],
    damage_text = [=[Interface\Addons\caelUI\media\fonts\YanoneKaffeesatz-Bold.ttf]=],
}

private.database.save(media)
