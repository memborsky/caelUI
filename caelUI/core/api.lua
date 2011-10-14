local private, modules, public = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
public.media = private.database.get("media")

-- Allow exteranl addons to have access to the config database.
public.config = private.database.get("config")

-- Allow the usage of specific functions using a built database (table) here.
public.functions = {
    ["utf8sub"]         = private.utf8sub,
    ["GetSpellName"]    = private.GetSpellName,
}
