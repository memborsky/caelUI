local F, P, M = unpack(select(2, ...))

local config = P.database.get("config")

config.player = {
    ["name"]    = UnitName("player"),
    ["realm"]   = GetRealmName(),
    ["class"]   = select(2, UnitClass("player")),
    ["level"]	= UnitLevel("player"),
    ["iLvl"]    = math.floor(GetAverageItemLevel("player")),
}

config.locale = GetLocale()

-- Save our database including functions.
P.database.save(config)
