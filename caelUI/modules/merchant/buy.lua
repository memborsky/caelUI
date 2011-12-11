local Merchant = unpack(select(2, ...)).GetModule("Merchant")

-- Our reagents list.
reagents = {
    ["Earthen Ring"] = {
        ["Keltric"] = {
            [58257] = 40 -- 58257 = Highland Spring Water (Use: Restores 96000 mana over 30 sec.  Must remain seated while drinking.)
        },
        ["Belliofria"] = {
            [58261] = 40, -- 58261 = Buttery Wheat Roll (Use: Restores 96000 health over 30 sec.  Must remain seated while eating.)
        },
        ["Burlesque"] = {
            [58261] = 40, -- 58261 = Buttery Wheat Roll (Use: Restores 96000 health over 30 sec. Must remain seated while eating.)
            [3775]  = 20, --  3775 = Crippling Poison
            [10918] = 20, -- 10918 = Wound Poison
            [5237]  = 20, --  5237 = Mind-Numbing Poison
            [6947]  = 20, --  6947 = Instant Poison
            [2892]  = 40, --  2892 = Deadly Poison
        },
    }
}

-- Internal: Returns how many of the given item we are needing to buy.
--
-- CheckID         - The item's identification number to be check purchased.
-- RequiredAmount - The amount we are suppposed to have for the given ItemID.
-- 
-- Examples:
--
-- HowMany(58257, 40)
-- # => 40
--
-- Returns the integer of how many to be purchased.
local function HowMany (CheckID, RequiredAmount)
    local total = 0
    local ItemLink, stack = nil, 0

    for bag = 0, NUM_BAG_FRAMES do

        for slot = 1, GetContainerNumSlots(bag) do

            ItemLink = GetContainerItemLink(bag, slot)

            if ItemLink and CheckID == tonumber(select(3, string.find(ItemLink, "item:(%d+)"))) then
                stack = select(2, GetContainerItemInfo(bag, slot))
                total = total + stack
            end
        end
    end

    return math.max(0, (RequiredAmount - total))
end

-- Internal: Buys our reagents for player on realm.
--
-- reagents - Our list of reagents for the given player.
--
-- Examples
--
-- BuyReagents(reagents)
--  # => true
--
-- Returns boolean for success or failure to successfulness to buying reagents.
local function BuyReagents (reagents)
    local ItemLink, ItemID, stock, price, stack, quantity, fullstack

    for MerchantIDIndex = 1, GetMerchantNumItems() do

        ItemLink = GetMerchantItemLink(MerchantIDIndex)

        if ItemLink then
            ItemID = tonumber(select(3, string.find(ItemLink, "item:(%d+)")))
        end

        if ItemID and reagents[ItemID] then

            price, stack, stock = select(3, GetMerchantItemInfo(MerchantIDIndex))
            quantity = HowMany(ItemID, reagents[ItemID])

            if quantity > 0 then

                if stock ~= -1 then
                    quantity = math.min(quantity, stock)
                end

                subtotal = price * (quantity/stack)

                if subtotal > GetMoney() then
                    Merchant:Print("Not enough money to purchase reagents.");
                    return
                end

                fullstack = select(8, GetItemInfo(ItemID))

                while quantity > fullstack do
                    BuyMerchantItem(MerchantIDIndex, fullstack)
                    quantity = quantity - fullstack
                end

                if quantity > 0 then
                    BuyMerchantItem(MerchantIDIndex, quantity)
                end
            end
        end

        -- Reset the quantity to make sure we don't buy more then we bargin for.
        quantity = 0
    end
end

do
    local name, realm = Merchant:GetPlayer({"name", "realm"})

    if reagents[realm] and reagents[realm][name] then
        Merchant:RegisterEvent("MERCHANT_SHOW", function()
            BuyReagents(reagents[realm][name])
        end)
    end
end