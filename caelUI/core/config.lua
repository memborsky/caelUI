local private = unpack(select(2, ...))

local config = private.database.get("config")

config.player = {
    ["name"]    	= UnitName("player"),
    ["realm"]   	= GetRealmName(),
    ["class"]   	= select(2, UnitClass("player")),
    ["level"]   	= UnitLevel("player"),
    ["item_level"]	= math.floor(GetAverageItemLevel("player")),
    ["zone"]		= GetRealZoneText() or "",
}

private.events:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
	config.player.zone = GetRealZoneText()
end)

config.locale = GetLocale()

-- Save our database including functions.
private.database.save(config)
