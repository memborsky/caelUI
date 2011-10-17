local addonName, caelCore = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame.modules = {}

caelCore.createModule = function(name)

    -- Create module frame.
    local module = CreateFrame("Frame", format("caelCoreModule%s", name), UIParent)
    frame.modules[name] = module
    
    return module
end

initSchedule = {}

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= addonName then return end
        
        self:UnregisterEvent(event)
    
        if not caelCoreDB then
            caelCoreDB = {}
        end
        
        caelCore.db = caelCoreDB
        
        for name, module in pairs(self.modules) do
            if not caelCore.db[name] then
                caelCore.db[name] = {}
            end
            
            module.db = caelCore.db[name]
            
            if (module.initOn) then
                if (module.initOn == "ADDON_LOADED") then
                    module:init()
                elseif (module.initOn) then
                    self:RegisterEvent(module.initOn)
                    if (not initSchedule[module.initOn]) then
                        initSchedule[module.initOn] = {}
                    end
                    
                    table.insert(initSchedule[module.initOn], module)
                end
            end
        end
    elseif (initSchedule[event]) then
        for i, module in ipairs(initSchedule[event]) do
            module:init()
        end
        initSchedule[event] = nil
        self:UnregisterEvent(event)
    end
end)
