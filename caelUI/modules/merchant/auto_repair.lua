local private = unpack(select(2, ...))

private.events:RegisterEvent("MERCHANT_SHOW", function()
    if CanMerchantRepair() then
        local cost, needed = GetRepairAllCost()
        if needed then

            if private.IsGuildGroup() and CanGuildBankRepair() then
                -- Repair by the guild repair if we are in a guild group and have the ability to repair by guild repair.

                local GuildWealth = GetGuildBankWithdrawMoney() > cost
                if GuildWealth then
                    RepairAllItems(1)
                    private.print("Merchant", format("Guild bank repaired for %s.", private.FormatMoney(cost)))
                end
            elseif cost < GetMoney() then
                -- Else try to repair by our own money.

                RepairAllItems()
                private.print("Merchant", format("Repaired for %s.", private.FormatMoney(cost)))
            else
                -- Else we can't repair.

                private.print("Merchant", "Could not repair as you do not have enough gold.")
            end
        end
    end
end)