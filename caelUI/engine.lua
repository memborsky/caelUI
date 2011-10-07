local addon, ns = ...

ns[1] = {} -- Functions
ns[2] = {} -- Modules

-- Allow other addons to load the caelUI namespace.
caelUI = ns

local F = select(1, unpack(select(2, ...)))

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event)
	if addon ~= "caelUI" then
		return
	end

	if not cael_user then
		cael_user = {}
	end

	if not cael_global then
		cael_global = {}
	end

	F.initialize_database()
end)