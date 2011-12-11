local Merchant = unpack(select(2, ...)).GetModule("Merchant")

Merchant:RegisterEvent("MERCHANT_SHOW", function(self)
    if CanMerchantRepair() then
        local cost, needed = GetRepairAllCost()
        if needed then

            if CanGuildBankRepair() then
                -- Repair by the guild repair if we are in a guild group and have the ability to repair by guild repair.

                local GuildWealth = GetGuildBankWithdrawMoney() > cost
                if GuildWealth then
                    RepairAllItems(1)
                    self:Print(format("Guild bank repaired for %s.", self:FormatMoney(cost)))
                end
            elseif cost < GetMoney() then
                -- Else try to repair by our own money.

                RepairAllItems()
                self:Print(format("Repaired for %s.", self:FormatMoney(cost)))
            else
                -- Else we can't repair.

                self:Print("Could not repair as you do not have enough gold.")
            end
        end
    end
end)