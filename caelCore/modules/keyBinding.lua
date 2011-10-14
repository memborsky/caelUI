if not caelLib.isCharListA then return end

local _, caelCore = ...

local keybinding = caelCore.createModule("KeyBinding")

local bindings = {
    ["TAB"] = "TARGETNEARESTENEMY",
    ["SHIFT-TAB"] = "TARGETPREVIOUSENEMY",
}

keybinding:RegisterEvent("PLAYER_ENTERING_WORLD")
keybinding:RegisterEvent("ZONE_CHANGED_NEW_AREA")
keybinding:SetScript("OnEvent", function(self)
    if event == "PLAYER_ENTERING_WORLD" then
        --[[
        -- Remove all keybinds
        for i = 1, GetNumBindings() do
            local command = GetBinding(i)
            while GetBindingKey(command) do
                local key = GetBindingKey(command)
                SetBinding(key) -- Clear Keybind
            end
        end
        --]]

        -- Apply personal keybinds
        for key, bind in pairs(bindings) do
            SetBinding(key, bind)
        end

        -- Save keybinds
        SaveBindings(1)

        -- All done, clean up a bit.
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        bindings = nil  -- Remove table
        self = nil -- Remove frame
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        local _, instance = IsInInstance()
        if(instance == "pvp" or instance == "arena" or GetZonePVPInfo() == "combat") then
            SetBinding("TAB", "TARGETNEARESTENEMYPLAYER")
            SetBinding("SHIFT-TAB", "TARGETPREVIOUSENEMYPLAYER")
        else
            SetBinding("TAB", "TARGETNEARESTENEMY")
            SetBinding("SHIFT-TAB", "TARGETPREVIOUSENEMY")
        end

        -- Save keybinds
        SaveBindings(1)
    end
end)

--------------------------
---[[   Acceleration    ]]---
--------------------------
for i = 1, 12 do
    local currentButton = _G["ActionButton"..i]

    currentButton:RegisterForClicks("AnyDown")

--  SetOverrideBindingClick(button, true, KEYBIND, button:GetName(), MOUSEBUTTONTOFAKE)
    SetOverrideBindingClick(currentButton, true, i == 12 and "-" or i == 11 and ")" or i == 10 and "0" or i, currentButton:GetName(), "LeftButton")
end

local driver = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
-- Create binding map.
driver:Execute([[
    bindings = newtable("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ")", "-")
]])

-- Trigger func when form changes.
driver:SetAttribute("_onstate-form", [=[
    local name
    if newstate == "1" then
        name = "BonusActionButton%d"
    else
        name = "ActionButton%d"
    end

    for i=1, 12 do
            self:ClearBinding(bindings[i])
        self:SetBindingClick(true, bindings[i], name:format(i))
    end
]=])
RegisterStateDriver(driver, "form", "[vehicleui][bonusbar:5][form]1;0")
