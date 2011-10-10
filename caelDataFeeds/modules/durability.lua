--[[    $Id$    ]]

local _, caelDataFeeds = ...

local durability = caelDataFeeds.createModule("Durability")

local pixelScale = caelUI.pixelScale

durability.text:SetPoint("CENTER", caelPanel_DataFeed, "CENTER", pixelScale(225), 0)

durability:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

local Total = 0
local current, max
local Slots = {
    [1] = {1, "Head", 1},
    [2] = {3, "Shoulder", 1},
    [3] = {5, "Chest", 1},
    [4] = {6, "Waist", 1},
    [5] = {7, "Legs", 1},
    [6] = {8, "Feet", 1},
    [7] = {9, "Wrist", 1},
    [8] = {10, "Hands", 1},
    [9] = {16, "Main Hand", 1},
    [10] = {17, "Off Hand", 1},
    [11] = {18, "Ranged", 1}
}

local sorting = function(a, b)
    return a[3] < b[3]
end

durability:SetScript("OnEvent", function(self, event)
    for i = 1, 11 do
        if GetInventoryItemLink("player", Slots[i][1]) ~= nil then
            current, max = GetInventoryItemDurability(Slots[i][1])
            if current then
                Slots[i][3] = current/max
                Total = Total + 1
            end
        end
    end
    table.sort(Slots, sorting)

    if Total > 0 then
        self.text:SetFormattedText("|cffD7BEA5dur|r %d%s", floor(Slots[1][3] * 100), "%")
    else
        self.text:SetText("100% |cffD7BEA5armor|r")
    end
end)

durability:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, pixelScale(4))

    for i = 1, 11 do
        if Slots[i][3] ~= 1 then
            green = Slots[i][3] * 2
            red = 1 - green
            GameTooltip:AddDoubleLine(Slots[i][2], floor(Slots[i][3]*100).."%", 0.84, 0.75, 0.65, red + 1, green, 0)
        end
    end
    GameTooltip:Show()
    Total = 0
end)
