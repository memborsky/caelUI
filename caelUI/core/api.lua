local F, P, M = unpack(select(2, ...))

-- Allow external addons to pull back databases.
F.get_database = P.database.get
