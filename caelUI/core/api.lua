local F, P, M = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
F.media = P.database.get("media")

-- Allow exteranl addons to have access to the config database.
F.config = P.database.get("config")
