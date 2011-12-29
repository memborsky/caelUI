local private = unpack(select(2, ...))

local config = private.GetDatabase("config")

config.player = {
    ["name"]        = UnitName("player"),
    ["realm"]       = GetRealmName(),
    ["class"]       = select(2, UnitClass("player")),
    ["level"]       = UnitLevel("player"),
    ["item_level"]  = math.floor(GetAverageItemLevel("player")),
    ["zone"]        = GetRealZoneText() or "",
}

do
    local frame = CreateFrame("Frame")

    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    frame:SetScript("OnEvent", function()
        config.player.zone = GetRealZoneText()
    end)
end

config.locale = GetLocale()

-- Save our database including functions.
config:Save()
