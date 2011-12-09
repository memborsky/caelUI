-- Play a better sound for the ready check sound when one is issued.
ReadyCheckListenerFrame:SetScript("OnShow", function()
	PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
end)
