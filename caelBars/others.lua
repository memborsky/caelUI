local _, caelBars = ...

local pixel_scale = caelUI.config.pixel_scale

-----------------------------------------------
-- Hide default Blizzard frames we don't need
-----------------------------------------------

do
    for _, element in next, {
        MainMenuBar,
        MainMenuBarArtFrame,
        BonusActionBarFrame,
        VehicleMenuBar,
        PossessBarFrame,
    } do
        if element:GetObjectType() == "Frame" then
            element:UnregisterAllEvents()
        end

        if element == MainMenuBar then
            element:SetAlpha(0)
            element:SetScale(0.001)
        else
            element.Show = element.Hide
            element:Hide()
        end

    end

    -- UI Parent Manager frame nil'ing
    for _, frame in next, {
        "MultiBarLeft", "MultiBarRight", "MultiBarBottomLeft", "MultiBarBottomRight",
        "ShapeshiftBarFrame",
        "PossessBarFrame", "PETACTIONBAR_YPOS",
        "MultiCastActionBarFrame", "MULTICASTACTIONBAR_YPOS",
    } do
        UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
    end
end


---------------------------------
-- Toggle for mouseover on bars
---------------------------------

function caelBars.MouseOverBar(panel, bar, button, alpha)
    if bar ~= nil then
        bar:SetAlpha(alpha)
    end

    if panel ~= nil then
        panel:SetAlpha(alpha)
    end

    if button ~= nil then
        for index = 1, 12 do
            _G[button .. index]:SetAlpha(alpha)
        end
    end
end

----------------------
-- Setup button grid
----------------------

local buttonGrid = CreateFrame("Frame")
buttonGrid:RegisterEvent("PLAYER_ENTERING_WORLD")
buttonGrid:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    SetActionBarToggles(1, 1, 1, 1)

    if caelBars.actionBar["settings"].showGrid == true then
        for index = 1, 12 do
            local button = _G[format("ActionButton%d", index)]
            button:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(button)

            button = _G[format("BonusActionButton%d", index)]
            button:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(button)

            button = _G[format("MultiBarRightButton%d", index)]
            button:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(button)

            button = _G[format("MultiBarBottomRightButton%d", index)]
            button:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(button)

            button = _G[format("MultiBarLeftButton%d", index)]
            button:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(button)

            button = _G[format("MultiBarBottomLeftButton%d", index)]
            button:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(button)
        end
    end
end)

-------------------
-- SHAPESHIFT BAR
-------------------

local barShift = CreateFrame("Frame", "barShift", UIParent)
barShift:ClearAllPoints()
barShift:SetPoint("BOTTOMLEFT", caelPanel_ActionBar1, "TOPLEFT",  pixel_scale(3), 0)
barShift:SetWidth(29)
barShift:SetHeight(58)

-- Place buttons in the bar frame and set the barShift as the parent frame
-- ShapeshiftBarFrame:GetParent():Hide()
ShapeshiftBarFrame:SetParent(barShift)
--ShapeshiftBarFrame:SetWidth(0.00001)
for index = 1, NUM_SHAPESHIFT_SLOTS do
    local button = _G["ShapeshiftButton" .. index]
    local buttonPrev = _G["ShapeshiftButton" .. index - 1]
    button:ClearAllPoints()
    button:SetScale(0.68625)
    if index == 1 then
        button:SetPoint("BOTTOMLEFT", barShift, 0, pixel_scale(2))
    else
        button:SetPoint("LEFT", buttonPrev, "RIGHT", pixel_scale(2), 0)
    end
end

-- Hook the updating of the shapeshift bar
local function MoveShapeshift()
    ShapeshiftButton1:SetPoint("BOTTOMLEFT", barShift, 0, pixel_scale(2))
end
hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)

------------
-- PET BAR
------------

-- Create pet bar frame and put it into place
local barPet = CreateFrame("Frame", "barPet", UIParent, "SecureHandlerStateTemplate")
barPet:ClearAllPoints()
barPet:SetWidth(pixel_scale(120))
barPet:SetHeight(pixel_scale(47))
barPet:SetPoint("BOTTOM", UIParent, pixel_scale(-337), pixel_scale(359))

-- Setup Blizzard pet action bar.
PetActionBarFrame:SetParent(barPet)
PetActionBarFrame:SetWidth(0.01)

-- Show grid for pet actionbar
if caelBars.actionBar["settings"].showPetGrid == true then
    PetActionBar_ShowGrid()
end

-- function to toggle the display of the pet bar
local function togglePetBar(alpha)
    for index = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. index]
        button:SetAlpha(alpha)
    end
end

do
    local button1 = _G["PetActionButton1"]
    for index = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. index]
        local buttonPrev = _G["PetActionButton" .. index - 1]

        button:ClearAllPoints()

        -- Set Parent for position purposes
        button:SetParent(barPet)

        -- Set Scale for the button size.
        button:SetScale(0.63) 

        if index == 1 then
            button:SetPoint("TOPLEFT", barPet, pixel_scale(4.5), pixel_scale(-4.5))
        elseif index == ((NUM_PET_ACTION_SLOTS / 2) + 1) then -- Get our middle button + 1 to make the rows even
            button:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, pixel_scale(-5))
        else
            button:SetPoint("LEFT", buttonPrev, "RIGHT", pixel_scale(4.5), 0)
        end

        -- Toggle buttons if mouse over is turned on.
        if caelBars.actionBar["settings"].mouseOverPetBar == true then
            button:SetAlpha(0)
            button:HookScript("OnEnter", function(self) togglePetBar(1) end)
            button:HookScript("OnLeave", function(self) togglePetBar(0) end)
        end
    end
end

-- Toggle pet bar if mouse over is turned on.
if caelBars.actionBar["settings"].mouseOverPetBar == true then
    barPet:EnableMouse(true)
    barPet:SetScript("OnEnter", function(self) togglePetBar(1) end)
    barPet:SetScript("OnLeave", function(self) togglePetBar(0) end)
end

--------------
-- TOTEMS BAR
--------------
local totemBar = _G["MultiCastActionBarFrame"]

if totemBar then
    totemBar:SetScript("OnUpdate", nil)
    totemBar:SetScript("OnShow", nil)
    totemBar:SetScript("OnHide", nil)
    totemBar:SetParent(caelPanel_ActionBar1)
    totemBar:ClearAllPoints()
    totemBar:SetPoint("BOTTOMLEFT", caelPanel_ActionBar1, "TOPLEFT", 0, pixel_scale(2))
    totemBar:SetScale(0.75)

    hooksecurefunc("MultiCastActionButton_Update", function(self)
        if not InCombatLockdown() then
            self:SetAllPoints(self.slotButton)
        end
    end)
end

------------
-- VEHICLE
------------

-- Vehicle button
local vehicleExitButton = CreateFrame("BUTTON", nil, UIParent, "SecureActionButtonTemplate")

vehicleExitButton:SetSize(pixel_scale(33), pixel_scale(33))
vehicleExitButton:SetPoint("BOTTOM", pixel_scale(-146), pixel_scale(263))

vehicleExitButton:RegisterForClicks("AnyUp")
vehicleExitButton:SetScript("OnClick", function() VehicleExit() end)

vehicleExitButton:SetNormalTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]=])
vehicleExitButton:SetPushedTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]=])
vehicleExitButton:SetHighlightTexture([=[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]=])

vehicleExitButton:RegisterEvent("UNIT_ENTERING_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_EXITING_VEHICLE")
vehicleExitButton:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicleExitButton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
vehicleExitButton:SetScript("OnEvent", function(self, event, arg1)
    if (((event == "UNIT_ENTERING_VEHICLE") or (event == "UNIT_ENTERED_VEHICLE"))
        and arg1 == "player") then
        vehicleExitButton:SetAlpha(1)
    elseif (
        (
        (event == "UNIT_EXITING_VEHICLE") or (event == "UNIT_EXITED_VEHICLE")
        ) and
        arg1 == "player") or (
        event == "ZONE_CHANGED_NEW_AREA" and not UnitHasVehicleUI("player")
        ) then
        vehicleExitButton:SetAlpha(0)
    end
end)

vehicleExitButton:SetAlpha(0)
