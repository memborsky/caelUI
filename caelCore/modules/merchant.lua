--[[    $Id$    ]]

local _, caelCore = ...

local function debug(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end

--[[
This is where you will add your characters, their realm, and the stock levels
of each item they will want auto-stocked.
--]]
local reagents = {
    ["Earthen Ring"] = {
        ["Keltric"]     = {
            [58257] = 40 -- 58257 = Highland Spring Water (Use: Restores 96000 mana over 30 sec.  Must remain seated while drinking.)
        },
        ["Belliofria"]  = {
            [58261] = 40, -- 58261 = Buttery Wheat Roll (Use: Restores 96000 health over 30 sec.  Must remain seated while eating.)
        },
    }
}

--[[    Auto sell junk & auto repair    ]]

local merchant = caelCore.createModule("Merchant")

-- Internal settings
local playerName            = caelLib.playerName
local playerRealm           = caelLib.playerRealm
--[[
Ensures that we have the player's name, their realm, and that a table actually exists for
that particular character before scanning the vendor for purchases.
--]]
local my_reagents           = reagents[playerRealm] and reagents[playerRealm][playerName] and reagents[playerRealm][playerName] or nil
local itemid_pattern        = "item:(%d+)"
local itemCount, sellValue  = 0, 0                      -- Used to display selling count and total sell value of junk.

-- Localizing our global variables and functions.
local GetContainerNumSlots  = _G.GetContainerNumSlots
local GetContainerItemLink  = _G.GetContainerItemLink
local GetContainerItemInfo  = _G.GetContainerItemInfo
local GetMerchantNumItems   = _G.GetMerchantNumItems
local GetMerchantItemInfo   = _G.GetMerchantItemInfo
local GetMerchantItemLink   = _G.GetMerchantItemLink
local BuyMerchantItem       = _G.BuyMerchantItem
local GetItemInfo           = _G.GetItemInfo
local GetMoney              = _G.GetMoney
local select                = select
local format                = string.format

--[[
Returns the amount of checkid which would be needed to stock the item to the preset level.
This does NOT return the amount of the item which will be purchased (due to possible
overstock), rather the total amount which would be ideal.
--]]
local function HowMany(checkid)
    if not my_reagents[checkid] then return 0 end

    local total = 0
    local link, id, stack

    for bag = 0, NUM_BAG_FRAMES do

        for slot = 1, GetContainerNumSlots(bag) do

            link = GetContainerItemLink(bag, slot)

            if link then

                id = tonumber(select(3, string.find(link, itemid_pattern)))
                stack = select(2, GetContainerItemInfo(bag, slot))

                if id == checkid then
                    total = total + stack
                end
            end
        end
    end

    return math.max(0, (my_reagents[checkid] - total))
end

--[[
Purchases the required amount of reagents to come as close as possible to the requested
stock level.  Does NOT overstock, so you may end up with less than the stock level you
asked for.
--]]
local function BuyReagents()
    local link, id, stock, price, stack, quantity, fullstack

    for i = 1, GetMerchantNumItems() do

        link = GetMerchantItemLink(i)

        if link then
            id = tonumber(select(3, string.find(link, itemid_pattern)))
        end

        if id and my_reagents[id] then

            price, stack, stock = select(3, GetMerchantItemInfo(i))
            quantity = HowMany(id)

            if quantity > 0 then

                if stock ~= -1 then
                    quantity = math.min(quantity, stock)
                end

                subtotal = price * (quantity/stack)

                if subtotal > GetMoney() then
                    print("|cffD7BEA5cael|rMerchant: Not enough money to purchase reagents.");
                    return
                end

                fullstack = select(8, GetItemInfo(id))

                while quantity > fullstack do
                    BuyMerchantItem(i, fullstack)
                    quantity = quantity - fullstack
                end

                if quantity > 0 then
                    BuyMerchantItem(i, quantity)
                end
            end
        end

        -- Reset the quantity to make sure we don't buy more then we bargin for.
        quantity = 0
    end
end

local function formatMoney(value)
    if value >= 1e4 then
        return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
    elseif value >= 1e2 then
        return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
    else
        return format("|cffeda55f%dc|r", strsub(value, -2))
    end
end

-- The traffic cop to make all the magic happen when we talk to a merchant.

merchant:RegisterEvent"MERCHANT_SHOW"
merchant:SetScript("OnEvent", function(self, event)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = GetContainerItemLink(bag, slot)
            if item then
                local itemValue = select(11, GetItemInfo(item)) * GetItemCount(item)

                if select(3, GetItemInfo(item)) == 0 then
                    ShowMerchantSellCursor(1)
                    UseContainerItem(bag, slot)

                    itemCount = itemCount + GetItemCount(item)
                    sellValue = sellValue + itemValue
                end
            end
        end
    end

    if sellValue > 0 then
        print(format("|cffd7bea5cael|rCore: Sold %d trash item%s for %s", itemCount, itemCount ~= 1 and "s" or "", formatMoney(sellValue)))
        itemCount, sellValue = 0, 0
    end

    if CanMerchantRepair() then
        local cost, needed = GetRepairAllCost()
        if needed then
            local GuildWealth = CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost
            if GuildWealth then
                RepairAllItems(1)
                print(format("|cffD7BEA5cael|rMerchant: Guild bank repaired for %s.", formatMoney(cost)))
            elseif cost < GetMoney() then
                RepairAllItems()
                print(format("|cffD7BEA5cael|rMerchant: Repaired for %s.", formatMoney(cost)))
            else
                print("|cffD7BEA5cael|rMerchant: Repairs were unaffordable.")
            end
        end
    end

    -- Buy reagents.
    if my_reagents then
        BuyReagents()
    end
end)
