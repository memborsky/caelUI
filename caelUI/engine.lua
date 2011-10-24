local addon, ns = ...

ns[1] = {} -- (private) Functions
ns[2] = {} -- modules
ns[3] = {} -- (public) Functions

-- We don't need to allow the addons to interface to anything that we don't push into the public range.
caelUI = ns[3]
--caelUIdebug = ns[1]

local private, modules, public = unpack(select(2, ...))

local Event_Frame = CreateFrame("Frame")

Event_Frame:RegisterEvent("ADDON_LOADED")
Event_Frame:RegisterEvent("PLAYER_LOGOUT")
Event_Frame:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS")
Event_Frame:RegisterEvent("PLAYER_LEAVING_WORLD")
Event_Frame:SetScript("OnEvent", function(self, event, addon)
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
        private.database.initialize()

        -- Set our UI Scale so we can provide pixel perfection.
        if cael_user.scale then
            private.set_scale(cael_user.scale)
        else
            private.set_scale()
        end
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
