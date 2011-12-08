local private, moedules, public = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
public.media = private.GetDatabase("media")

-- Allow exteranl addons to have access to the config database.
public.config = private.GetDatabase("config")

-- XXX: Hacking around the change we made internally for pixel_scale to make sure everything works inside first.
public.config.pixel_scale = private.pixel_scale

-- Allow the usage of specific functions from our private API interface.
public.UTF8_substitution = private.UTF8_substitution
public.get_spell_name = private.get_spell_name
public.kill = private.kill
