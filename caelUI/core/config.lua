local F, P, M = unpack(select(2, ...))

local config = P.database.get("config")

if config == {} then
    config.player = {
        ["name"]    = UnitName("player"),
        ["realm"]   = GetRealmName(),
        ["class"]   = select(2, UnitClass("player"))
        ["iLvl"]    = math.floor(GetAverageItemLevel("player"))
    }

    config.locale = GetLocale()
end

-- Save our database including functions.
P.database.save(config)
