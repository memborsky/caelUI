local _, caelCore = ...

local battleground = caelCore.createModule("Battleground")

--[[    Auto release in battleground    ]]

battleground:RegisterEvent("PLAYER_DEAD")
battleground:SetScript("OnEvent", function(self, event)
    local _, instanceType = IsInInstance()
    local zone = tostring(GetZoneText())
    if instanceType == "pvp" or (zone == "Wintergrasp" or zone == "Tol Barad") then
        RepopMe()
    end
end)
