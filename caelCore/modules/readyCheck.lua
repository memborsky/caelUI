local _, caelCore = ...

--[[    Force readycheck warning    ]]

local readycheck = caelCore.createModule("ReadyCheck")

ReadyCheckListenerFrame:SetScript("OnShow", nil) -- Stop the default
readycheck:RegisterEvent("READY_CHECK")
readycheck:SetScript("OnEvent", function(self, event)
    PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)
