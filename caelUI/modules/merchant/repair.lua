local Merchant = unpack(select(2, ...)).GetModule("Merchant")

Merchant:RegisterEvent("MERCHANT_SHOW", function()
    if CanMerchantRepair() then
        local cost, needed = GetRepairAllCost()
        if needed then

            if CanGuildBankRepair() then
                -- Repair by the guild repair if we are in a guild group and have the ability to repair by guild repair.

                local GuildWealth = GetGuildBankWithdrawMoney() > cost
                if GuildWealth then
                    RepairAllItems(1)
                    Merchant:Print(format("Guild bank repaired for %s.", Merchant:FormatMoney(cost)))
                end
            elseif cost < GetMoney() then
                -- Else try to repair by our own money.

                RepairAllItems()
                Merchant:Print(format("Repaired for %s.", Merchant:FormatMoney(cost)))
            else
                -- Else we can't repair.

                Merchant:Print("Could not repair as you do not have enough gold.")
            end
        end
    end
end)