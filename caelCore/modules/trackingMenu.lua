--[[    $Id$    ]]

if caelLib.locale ~= "enUS" then return end

--    Rawr! GTFO POI tracking!  Default _Init, with filter for only find/track/quest entries.
function MiniMapTrackingDropDown_Initialize()
    local name, texture, active, category
    local anyActive, checked
    local count = GetNumTrackingTypes()
    local info
    for id = 1, count do
        name, texture, active, category  = GetTrackingInfo(id)

        if name:find("Find") or name:find("Track") or name:find("Sense") or name:find("Quests") then
            info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.checked = active
            info.func = MiniMapTracking_SetTracking
            info.icon = texture
            info.arg1 = id
            if ( category == "spell" ) then
                info.tCoordLeft = 0.0625
                info.tCoordRight = 0.9
                info.tCoordTop = 0.0625
                info.tCoordBottom = 0.9
            else
                info.tCoordLeft = 0
                info.tCoordRight = 1
                info.tCoordTop = 0
                info.tCoordBottom = 1
            end
            UIDropDownMenu_AddButton(info)
            if ( active ) then
                anyActive = active
            end
        end
    end

    if ( anyActive ) then
        checked = nil
    else
        checked = 1
    end

    info = UIDropDownMenu_CreateInfo()
    info.text = NONE
    info.checked = checked
    info.func = MiniMapTracking_SetTracking
    info.arg1 = nil
    UIDropDownMenu_AddButton(info)
end
UIDropDownMenu_Initialize(MiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU")
