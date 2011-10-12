local F = select(1, unpack(select(2, ...)))

local databases = {}
local system_generated_count = 0

function F.initialize_databases ()
    if cael_user and (cael_user.databases and cael_user.databases ~= {}) then
        databases = cael_user.databases
    else
        cael_user.databases = {}
    end
end

function F.get_database (name)
    if databases[name] and databases[name] ~= {} then
        return databases[name]
    end

    return {name = name}
end

function F.save_database (self)
    if self.name then
        databases[self.name] = self
    else
        if type(self) == "table" then
            self.name = "sys" .. system_generated_count
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

function F.clear_databases ()
    databases = {}
end