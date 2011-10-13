local addon, ns = ...

ns[1] = {} -- (Public) Functions
ns[2] = {} -- (Private) Functions
ns[3] = {} -- Modules

-- We don't need to allow the addons to interface to anything that we don't push into the public range.
caelUI = ns[1]

local F, P, M = unpack(select(2, ...))

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS")
eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if addon ~= "caelUI" then
        return
    end

    if event == "ADDON_LOADED" then
        if not cael_user then
            cael_user = {}
        end

        if not cael_global then
            cael_global = {}
        end

        -- Initialize our databases.
        P.database.initialize()

        -- Set our UI Scale so we can provide pixel perfection.
        P.SetScale()
    elseif event == "PLAYER_LEAVING_WORLD" then
        -- XXX: Needs to be moved to event system.
        cael_user.scale = math.floor(GetCVar("uiScale") * 100 + 0.5)/100
    elseif event == "PLAYER_LOGOUT" then
        -- XXX: Needs to be moved to event system.
        cael_user.scale = math.floor(GetCVar("uiScale") * 100 + 0.5)/100
    elseif event == "UPDATE_FLOATING_CHAT_WINDOWS" then
        -- XXX: Needs to be moved to event system.
        cael_user.scale = math.floor(GetCVar("uiScale") * 100 + 0.5)/100
    end
end)
