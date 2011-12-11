local AutoRelease = unpack(select(2, ...)).NewModule("AutoRelease")

--[[
Allows us to auto release in pvp zones or inside of a battleground.
--]]
AutoRelease:RegisterEvent("PLAYER_DEAD", function()
	local _, instance_type = IsInInstance()
	local zone = GetRealZoneText()

	if instance_type == "pvp" or (zone == "Wintergrasp" or zone == "Tol Barad") then
		RepopMe()
	end
end)
