local private, modules, public = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
public.media = private.database.get("media")

-- Allow exteranl addons to have access to the config database.
public.config = private.database.get("config")

-- Allow the usage of specific functions from our private API interface.
public.utf8sub = private.utf8sub
public.GetSpellName = private.GetSpellName

-- XXX: This will change once we build an external Addon interface to the UI. It will pass
--      back a frame at creation doing everything that is in this function and more.
public.createBackdrop = private.database.get("panels").createBackdrop
