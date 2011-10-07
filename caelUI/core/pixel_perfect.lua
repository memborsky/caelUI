local F = select(1, unpack(select(2, ...)))

local screenWidth, screenHeight = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")

local scales = {
        ["720"] = { ["576"] = 0.65},
        ["800"] = { ["600"] = 0.7},
        ["960"] = { ["600"] = 0.84},
        ["1024"] = { ["600"] = 0.89, ["768"] = 0.7},
        ["1152"] = { ["864"] = 0.7},
        ["1176"] = { ["664"] = 0.93},
        ["1280"] = { ["800"] = 0.84, ["720"] = 0.93, ["768"] = 0.87, ["960"] = 0.7, ["1024"] = 0.65},
        ["1360"] = { ["768"] = 0.93},
        ["1366"] = { ["768"] = 0.93},
        ["1440"] = { ["900"] = 0.84},
        ["1600"] = { ["1200"] = 0.7, ["1024"] = 0.82, ["900"] = 0.93},
        ["1680"] = { ["1050"] = 0.84},
        ["1768"] = { ["992"] = 0.93},
        ["1920"] = { ["1440"] = 0.7, ["1200"] = 0.84, ["1080"] = 0.93},
        ["2048"] = { ["1536"] = 0.7},
        ["2560"] = { ["1600"] = 0.64},
}

function F.pixelScale(value)
    local UIScale

    local scale = nil

    if cael_user and cael_user.scale then
        scale = cael_user.scale
    end

    if not scale then
        UIScale = 1
    elseif type(scale) == "number" then
        UIScale = scale
    else
        UIScale = scales[screenWidth] and scales[screenWidth][screenHeight] or 1
    end

    local scaleFix = (768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)")))/UIScale

    return scaleFix * math.floor(value / scaleFix + 0.5)
end