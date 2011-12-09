local addon, ns = ...

ns[1] = {} -- (private) Functions
ns[2] = {} -- (public) Functions

-- We don't need to allow the addons to interface to anything that we don't push into the public range.
caelUI = ns[2]
--caelUIdebug = ns[1]
