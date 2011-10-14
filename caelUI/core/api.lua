local F, P, M = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
F.media = P.database.get("media")

-- Allow exteranl addons to have access to the config database.
F.config = P.database.get("config")

-- Allow the usage of specific functions using a built database (table) here.
F.functions = {
    ["utf8sub"]         = P.utf8sub,
    ["GetSpellName"]    = P.GetSpellName,
}
