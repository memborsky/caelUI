local private = unpack(select(2, ...))

--[[
The following section handles all of our UI Pixel Perfection that we need to make sure everything scales
like we want it when we build the UI for all user screen sizes.
--]]

-- This is our scales database. We only need this inside this file because we only reference it here.
local scales = {
    ["720"]     = { ["576"]  = 0.65  },
    ["800"]     = { ["600"]  = 0.70  },
    ["960"]     = { ["600"]  = 0.84  },
    ["1024"]    = { ["600"]  = 0.89, ["768"]  = 0.7},
    ["1152"]    = { ["864"]  = 0.70  },
    ["1176"]    = { ["664"]  = 0.93  },
    ["1280"]    = { ["800"]  = 0.84, ["720"]  = 0.93, ["768"]  = 0.87, ["960"] = 0.7, ["1024"] = 0.65},
    ["1360"]    = { ["768"]  = 0.93  },
    ["1366"]    = { ["768"]  = 0.93  },
    ["1440"]    = { ["900"]  = 0.84  },
    ["1600"]    = { ["1200"] = 0.70, ["1024"] = 0.82, ["900"]  = 0.93},
    ["1680"]    = { ["1050"] = 0.84  },
    ["1768"]    = { ["992"]  = 0.93  },
    ["1920"]    = { ["1440"] = 0.70, ["1200"] = 0.84, ["1080"] = 0.93},
    ["2048"]    = { ["1536"] = 0.70  },
    ["2560"]    = { ["1440"] = 0.93, ["1600"] = 0.84},
}

-- Our scale offset to screen resolution.
local scaleFix

-- Our screen width and height.
local screenWidth, screenHeight = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")

-- Used to set our scale when the ADDON_LOADED event is triggered.
-- XXX: This needs to be moved into the events interface when it gets built.
function private.SetScale ()
    local uiScale = cael_user.scale or scales[screenWidth] and scales[screenWidth][screenHeight] or 1
    scaleFix = (768/tonumber(GetCVar("gxResolution"):match("%d+x(%d+)"))) / uiScale
end

do
    local config = private.database.get("config")

    -- This will scale our given value to our scale offset.
    function config.pixelScale (value)
        return scaleFix * math.floor(value / scaleFix + 0.5)
    end

    private.database.save(config)
end

