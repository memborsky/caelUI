local private = unpack(select(2, ...))

local databases = {}
local system_generated_count = 0

-- The following functions are for internal caelUI use only.
function private.GetDatabase (name)
    -- No matter what we pass in here, the name of the table will always be lower case.
    name = name:lower()

    if databases[name] and databases[name] ~= {} then
        return databases[name]
    end

    return {
        name = name,
        Save = function(self)
            if self.name then
                databases[self.name] = self
            else
                if type(self) == "table" then
                    self.name = "system_" .. system_generated_count
                    databases[self.name] = self
                    system_generated_count = system_generated_count + 1
                end
            end

            -- XXX: This should not be needed with the addon declaring this variable on load.
            if cael_user then
                cael_user["databases"] = databases
            else
                cael_user = {}
                cael_user["databases"] = {}
                cael_user["databases"][self.name] = self
            end
        end
    }
end

-- This will setup our database system upon the addon being loading.
private.events:RegisterEvent("ADDON_LOADED", function (_, event)
    if not cael_user then
        cael_user = {}
    end

    if not cael_global then
        cael_global = {}
    end

    if cael_user and (cael_user["databases"] and cael_user["databases"] ~= {}) then
        databases = cael_user["databases"]
    else
        cael_user["databases"] = {}
    end

    private.events:UnregisterEvent(event, self)
end)
