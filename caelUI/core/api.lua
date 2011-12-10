local private, public = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
public.media = private.media

-- Allow exteranl addons to have access to the config database.
public.config = private.GetDatabase("config")

-- XXX: Hacking around the change we made internally for PixelScale to make sure everything works inside first.
public.config.PixelScale = private.PixelScale

-- Allow the usage of specific functions from our private API interface.
public.UTF8_substitution = private.UTF8_substitution
public.GetSpellName = private.GetSpellName
public.kill = private.kill
