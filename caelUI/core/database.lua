local F = select(1, unpack(select(2, ...)))

local databases = {}

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

    local function save (self)
        databases[self.name] = self

        --- XXX: This should not be needed with the addon declaring this variable on load.
        if cael_user then
            cael_user["databases"] = databases
        else
            cael_user = {}
            cael_user["databases"] = {}
            cael_user["databases"][self.name] = self
        end
    end

    return {
        save = save,
        name = name
    }
end

function F.clear_databases ()
    databases = {}
end