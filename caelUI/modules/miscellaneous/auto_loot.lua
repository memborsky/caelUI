-- We automatically confirm loot if we are not in a party or raid.
StaticPopupDialogs["LOOT_BIND"].OnCancel = function(_, slot)
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        ConfirmLootSlot(slot)
    end
end
