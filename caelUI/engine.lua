local addon, ns = ...

ns[1] = {} -- (Public) Functions
ns[2] = {} -- (Private) Functions
ns[3] = {} -- Modules

-- We don't need to allow the addons to interface to anything that we don't push into the public range.
caelUI = ns[1]

local F, P, M = unpack(select(2, ...))

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event)
    if addon ~= "caelUI" then
        return
    end

    if not cael_user then
        cael_user = {}
    end

    if not cael_global then
        cael_global = {}
    end

    P.database.initialize()
end)
