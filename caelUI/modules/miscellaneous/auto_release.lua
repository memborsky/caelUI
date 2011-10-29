local private = unpack(select(2, ...))

--[[    Auto release in battleground or pvp zones.    ]]

private.events:RegisterEvent("PLAYER_DEAD", function()
	local _, instance_type = IsInInstance()
	local zone = GetRealZoneText()

	if instance_type == "pvp" or (zone == "Wintergrasp" or zone == "Tol Barad") then
		RepopMe()
	end
end)
