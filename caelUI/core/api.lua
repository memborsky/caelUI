local F, P, M = unpack(select(2, ...))

-- Allow external addons to pull back databases.
F.get_database = P.database.get

-- Allow external addons to build pixel perfect UI stuff with our UI scaling.
F.pixelScale = P.database.get("config")["pixelScale"]
