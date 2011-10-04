--[[    $Id$    ]]

local _, caelBags = ...

_G["caelBags"] = caelBags

-- Dummy func so we can trash some functions we can't avoid being called.
local dummy = caelLib.dummy

-- Constants
local NUM_BAG_SLOTS = NUM_BAG_SLOTS         -- Amount of bag slots.
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS       -- Amount of bankbag slots.
local NUM_BANKITEM_SLOTS = NUM_BANKGENERIC_SLOTS        -- Amount of regular bank item slots.

local BACKPACK = BACKPACK_CONTAINER         -- BagID of the backpack.
local BANK = BANK_CONTAINER             -- BagID of the bank.
local FIRST_BANKBAG = NUM_BAG_SLOTS + 1         -- BagID of first bankbag slot.
local LAST_BANKBAG = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS   -- BagID of the last bankbag slot.

-- Prevent automatic resizing of the container frames.
updateContainerFrameAnchors = dummy

-- Layout settings
-- Sizing
local numBagColumns = 10
local numBankColumns = 20
local buttonSize = caelLib.scale(28)
local buttonSpacing = caelLib.scale(-2)

-- Margins
local bottomButtonMargin = caelLib.scale(30)
local bottomMargin = caelLib.scale(5)
local sideMargin   = caelLib.scale(5)
local topMargin    = caelLib.scale(5)

-- Methods we will use for the containers.
local Container = CreateFrame("Button")
Container.containers = {}
local ContainerMT = {__index = Container}

-- Updates the size and height of a container, depending on the amount of 
-- shown buttons it holds.
function Container:UpdateSize()
    self:SetHeight((self.row + (self.col == 0 and 0 or 1)) * (buttonSize + buttonSpacing) + abs(buttonSpacing) +(self.hasButtons and bottomButtonMargin or bottomMargin) + topMargin)
    self:SetWidth(self.maxColumns * buttonSize + buttonSpacing * (self.maxColumns - 1) + (2 * sideMargin))
    
    if not self:IsShown() then
        self:Show()
    end
end

-- Anchor the button correctly.
function Container:AnchorButton(button)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", self, "TOPLEFT", self.col * (buttonSize + buttonSpacing) + sideMargin, -1 * self.row * (buttonSize + buttonSpacing) -topMargin)

    if self.col > (self.maxColumns - 2) then
        self.col = 0
        self.row = self.row + 1
    else
        self.col = self.col + 1
    end
end

-- Adds a button to the container, placing it in the right position.
function Container:AddButton(button)
    self:AnchorButton(button)
    tinsert(self.buttons, button)
end

-- Removes a button from the container.
function Container:RemoveButton(remButton)
    local index = 1
    local button = self.buttons[index]
    
    while button do
        if button == remButton then
            table.remove(self.buttons, index)
            break
        end
        
        index = index + 1
        button = self.buttons[index]
    end
end

-- Return a new container.
function Container:New(name, maxColumns)
--  local c = CreateFrame("Button", nil, UIParent)
    local c = CreateFrame("Button", format("caelBags%s", name), UIParent)
    c:SetFrameStrata("HIGH")
    c:SetBackdrop(caelMedia.backdropTable)
    c:Hide()
    
    c.col, c.row = 0, 0
    c.maxColumns = maxColumns
    c.buttons = {}
    
    self.containers[name] = c
    setmetatable(c, ContainerMT)
    
    return c
end

-- Reanchor all buttons and update the container size.
function Container:Refresh()
    local numButtons = #self.buttons
    
    if numButtons == 0 then
        return self:Close()
    end
    
    self.col, self.row = 0, 0
    for index = 1, numButtons do
        self:AnchorButton(self.buttons[index])
    end
    
    self:UpdateSize()
end

function Container:Close()
    self.buttons = {}
    self.col, self.row = 0, 0
    self:Hide()
end

-- Create the frames for each type of container: bag, bank and ammo.
local bags = Container:New("bag", numBagColumns)
bags:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", caelLib.scale(-30), caelLib.scale(-168))
bags:SetBackdropColor(0, 0, 0, 0.7)
bags:SetBackdropBorderColor(0, 0, 0)
bags.preventCloseAll = true
bags.hasButtons = true
caelBags.bags = bags

local bank = Container:New("bank", numBankColumns)
bank:SetPoint("BOTTOMRIGHT", bags, "BOTTOMLEFT", 0, 0)
bank:SetBackdropColor(0, 0, 0, 0.7)
bank:SetBackdropBorderColor(0, 0, 0)
bank.hasButtons = true
caelBags.bank = bank

-- Make em closable on escape.
tinsert(UISpecialFrames, caelBags.bank)
tinsert(UISpecialFrames, caelBags.bags)

-- Returns the holder frame for a given bagID.
local function GetContainerForBag(bagID)
    local type

    if bagID >= FIRST_BANKBAG or bagID == BANK then
        type = "bank" 
    elseif bagID >= BACKPACK then
        type = "bags"
    else
        error(format("Invalid bagID passed to GetContainer. Got %q", tostring(bagID)))
    end
    
    return caelBags[type]
end

-- Applies desired layout to the item button.
local function ApplyButtonLayout(button)
    local name = button:GetName()
    local normalTexture = _G[format("%sNormalTexture", name)]
    local itemCount = _G[format("%sCount", name)]
    local iconTexture = _G[format("%sIconTexture", name)]
    local questTexture = _G[format("%sIconQuestTexture", name)]

    -- Hide that ugly new quest border
    questTexture:Hide()
    questTexture.Show = dummy

    -- Replace textures.
    button:SetNormalTexture(caelMedia.files.buttonNormal)
    button:SetPushedTexture(caelMedia.files.buttonPushed)
    button:SetHighlightTexture(caelMedia.files.buttonHighlight)
    
    -- Set size.
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    
    -- Set frame strata.
    button:SetFrameStrata("HIGH")
    
    -- Offset the icon image a little to remove 'round' edges
    iconTexture:SetTexCoord(.08, .92, .08, .92)
    -- Position icon using SetPoint relative to the button.
    iconTexture:ClearAllPoints()
    iconTexture:SetPoint("TOPLEFT", button, caelLib.scale(4), caelLib.scale(-3))
    iconTexture:SetPoint("BOTTOMRIGHT", button, caelLib.scale(-3), caelLib.scale(4))
    
    -- Size and position the NormalTexture (the "bagFrame" around the button)
    normalTexture:SetHeight(buttonSize)
    normalTexture:SetWidth(buttonSize)
    normalTexture:ClearAllPoints()
    normalTexture:SetPoint("CENTER")
    normalTexture:SetVertexColor(0.25, 0.25, 0.25)
    
    -- Move item count text into a readable position.
    itemCount:ClearAllPoints()
    itemCount:SetPoint("BOTTOMRIGHT", button, caelLib.scale(-3), caelLib.scale(3))
    itemCount:SetFont(caelMedia.fonts.CHAT_FONT, 10, "OUTLINE")
end

-- Override Blizzard's GenerateFrame function with our own.
-- This function is called whenever a bag is opened.
function ContainerFrame_GenerateFrame(frame, size, id)
    frame.size = size;
    local name = frame:GetName();
    frame:SetID(id);
    ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = name
    
    local container = GetContainerForBag(id)

    -- Show active buttons and set their ID.
    for index = 1, size do
        local itemButton = _G[("%sItem%d"):format(name, index)]
        itemButton:SetID(index)
        itemButton:Show()
        
        container:AddButton(itemButton)
    end
    
    container:UpdateSize()
    
    -- Hide the unused buttons.
    for i = size + 1, MAX_CONTAINER_ITEMS, 1 do
        _G[name.."Item"..i]:Hide();
    end

    _G[frame:GetName().."PortraitButton"]:SetID(id);
    frame:Show();
end

-- Init function. Removes a whole bunch of texture from the default frames.
do
    local i=1
    local containerFrame = ContainerFrame1
    while containerFrame do
        local name = containerFrame:GetName()
        
        if not containerFrame then
            return print(bagID)
        end
        containerFrame:EnableMouse(false)
        
        -- Apply layout to the frame's item buttons.
        for buttonID = 1, MAX_CONTAINER_ITEMS do
            ApplyButtonLayout(_G[format("%sItem%d", name, buttonID)])
        end
        
        -- Trash some textures.
        for i = 1, 7 do
            select(i, containerFrame:GetRegions()):SetAlpha(0)
        end
        
        -- Trash some buttons.
        _G[format("%sCloseButton", name)]:Hide()
        _G[format("%sPortraitButton", name)]:EnableMouse(false)
        
        i=i+1
        containerFrame = _G["ContainerFrame"..i]
    end

    -- Fix token frame glitch
    BackpackTokenFrame:Hide()
    BackpackTokenFrame.Show = dummy
    
    -- Trash some BankFrame functionality.
    BankFrame:EnableMouse(false)
    BankCloseButton:Hide()
    
    BankFramePurchaseInfo:Hide()
    BankFramePurchaseInfo.Show = dummy
    
    BankFrameMoneyFrame:Hide()
    BankFrameMoneyFrame.Show = dummy

    
    for i = 1, 7 do 
        _G[format("BankFrameBag%s", i)]:Hide()
    end
    
    -- And finally trash some BankFrame textures. Rock on!
    for i = 1, 5 do
        select(i, BankFrame:GetRegions()):SetAlpha(0)
    end
    
    -- Change the BankFrame ID so we can use our generic OnHide later on.
    BankFrame:SetID(BANK)
    BankFrame.size = NUM_BANKITEM_SLOTS
    
    -- Apply the layout to the bank item buttons.
    for i = 1, NUM_BANKITEM_SLOTS do
        local button = _G["BankFrameItem"..i]
        button:ClearAllPoints()
        ApplyButtonLayout(button)
    end
end

-- Hook the open/close/toggle bag functions.
local function ContainerFrameOnHide(self)
    local container = GetContainerForBag(self:GetID())
    
    if container then
        local name = self:GetName()
        for index = 1, self.size do
            container:RemoveButton(_G[("%sItem%d"):format(name, index)])
        end
    end

    --[[
    if not container.preventCloseAll then
        CloseAllBags()
    end
    --]]

    container:Refresh()
end

for i = 1, NUM_CONTAINER_FRAMES do
    _G["ContainerFrame"..i]:HookScript("OnHide", ContainerFrameOnHide)
end

BankFrame:HookScript("OnShow", function()
    for i = 1, NUM_BANKITEM_SLOTS do
        caelBags.bank:AddButton(_G["BankFrameItem"..i])
    end
    
    local size, name, itemButton

    local minBagSlot = 6
    local maxBagSlot = GetNumBankSlots()

    if maxBagSlot ~= 0 then
        -- Adjust for container values
        maxBagSlot = minBagSlot + maxBagSlot

        if minBagSlot ~= 0 then
            for id = minBagSlot, maxBagSlot do
                name = "ContainerFrame" .. id
                size = _G[name].size

                -- Remove all the buttons
                if size and size > 0 then
                    for index = 1, size do
                        itemButton = _G[("%sItem%d"):format(name, index)]
                        caelBags.bank:RemoveButton(itemButton)
                    end

                    -- Remove the blank space from the previous removal of all the buttons on the bank frame.
                    caelBags.bank:Refresh()

                    -- Add all the buttons back
                    for index = 1, size do
                        itemButton = _G[("%sItem%d"):format(name, index)]
                        caelBags.bank:AddButton(itemButton)
                    end

                    -- Hide the unused buttons.
                    for i = size + 1, MAX_CONTAINER_ITEMS, 1 do
                        _G[name.."Item"..i]:Hide();
                    end
                end
            end
        end
    end

    caelBags.bank:UpdateSize()
end)

BankFrame:HookScript("OnHide", ContainerFrameOnHide)

-- Start a timer OnHide so we can catch if all bags are hidden.

--[[ Show & Hide functions etc ]]
tinsert(UISpecialFrames, caelBags.bank)
tinsert(UISpecialFrames, caelBags.bags)

local closeBags = function()
    caelBags.bank:Hide()
    caelBags.bags:Hide()

    for i = 0, 11 do
        CloseBag(i)
    end
    CloseBag(-2)
end

local openBags = function()
    for b = 0, 11 do
--      if not IsAmmoBag(b) then
            OpenBag(b)
--      end
    end
end

local toggleBags = function()
    if(IsBagOpen(0)) then
        CloseBankFrame()
        closeBags()
    else
        openBags()
    end
end

hooksecurefunc(BankFrame, "Show", openBags)
hooksecurefunc(BankFrame, "Hide", closeBags)

ToggleBackpack = toggleBags
OpenAllBags = toggleBags
OpenBackpack = openBags
CloseBackpack = closeBags
CloseAllBags = closeBags
