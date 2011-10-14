if not oUF then return end

local _, oUF_Caellian = ...

local playerClass = caelUI.config.player.class

local ObjectRanges = {}

local _FRAMES = {}
local OnRangeFrame

-- Class-specific spell info
local HelpIDs, HelpName -- Array of possible spell IDs in order of priority, and the name of the highest known priority spell
local HarmIDs, HarmName

oUF_cRange = CreateFrame("Frame", nil, UIParent)

local IsInRange
do
    local UnitIsConnected = UnitIsConnected
    local UnitCanAssist = UnitCanAssist
    local UnitCanAttack = UnitCanAttack
    local UnitIsUnit = UnitIsUnit
    local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
    local UnitIsDead = UnitIsDead
    local UnitOnTaxi = UnitOnTaxi
    local UnitInRange = UnitInRange
    local IsSpellInRange = IsSpellInRange
    local CheckInteractDistance = CheckInteractDistance
    --- Uses an appropriate range check for the given unit.
    -- Actual range depends on reaction, known spells, and status of the unit.
    -- @param UnitID  Unit to check range for.
    -- @return True if in casting range.
    IsInRange = function(UnitID)

        if UnitIsConnected(UnitID) then

            if UnitCanAssist("player", UnitID) then

                if (HelpName and not UnitIsDead(UnitID)) then

                    return IsSpellInRange(HelpName, UnitID) == 1

                elseif (not UnitOnTaxi("player") and (UnitIsUnit(UnitID, "player") or UnitIsUnit(UnitID, "pet")
                    or UnitPlayerOrPetInParty(UnitID) or UnitPlayerOrPetInRaid(UnitID)))then

                    return UnitInRange(UnitID)

                end

            elseif (HarmName and not UnitIsDead(UnitID) and UnitCanAttack("player", UnitID)) then

                return IsSpellInRange(HarmName, UnitID) == 1

            end

            return CheckInteractDistance(UnitID, 4) and true or false
        end
    end
end
oUF_cRange.IsInRange = IsInRange

local OnRangeUpdate
do
    local timer = 0
    --- Updates the range display for all visible oUF unit frames on an interval.
    OnRangeUpdate = function(self, elapsed)
        timer = timer + elapsed

        if (timer >= 0.2) then
            for _, object in next, _FRAMES do
                if object:IsShown() then
                    local InRange = IsInRange(object.unit)
                    local cRange = object.cRange

                    if (ObjectRanges[object] ~= InRange) then
                        ObjectRanges[object] = InRange

                        local portrait = object.Portrait
                        local cRange = object.cRange

                        if object.unit == "target" then
                            if InRange then
                                if (portrait and not portrait:IsShown()) then
                                    portrait:Show()
                                    portrait:SetCamera(0)
                                    portrait:SetModelScale(4.25)
                                    portrait:SetPosition(0, 0, -1.5)
                                end

                                cRange.text:SetText("")
                            else
                                if portrait and portrait:IsShown() then
                                    portrait:Hide()
                                end

                                cRange.text:SetText("Out of Range")
                            end
                        elseif object.unit == "targettarget" or object.unit == "focus" or object.unit == "focustarget" then
                            if InRange then
                                if (object:GetAlpha() ~= cRange.insideAlpha) then
                                    object:SetAlpha(cRange.insideAlpha)
                                end
                            else
                                if (object:GetAlpha() ~= cRange.outsideAlpha) then
                                    object:SetAlpha(cRange.outsideAlpha)
                                end
                            end
                        end

                    end
                end
            end
        end
    end
end

local OnSpellsChanged
do
    local IsSpellKnown = IsSpellKnown
    local GetSpellInfo = GetSpellInfo
    --- @return Highest priority spell name available, or nil if none.
    local GetSpellName = function(IDs)
        if IDs then
            for _, ID in ipairs(IDs) do
                if IsSpellKnown(ID) then
                    return GetSpellInfo(ID)
                end
            end
        end
    end
    --- Checks known spells for the highest priority spell name to use.
    OnSpellsChanged = function()
        HelpName, HarmName = GetSpellName(HelpIDs), GetSpellName(HarmIDs)
    end
end

local Enable = function(self, UnitID)
    local cRange = self.cRange

    if cRange then

        -- Disable the built in oUF Range
        if (self.Range) then
            self:DisableElement("Range")
            self.Range = nil
        end

        table.insert(_FRAMES, self)

        if not OnRangeFrame then
            OnRangeFrame = CreateFrame"Frame"
            OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
            OnRangeFrame:SetScript("OnEvent", OnSpellsChanged)
            OnRangeFrame:RegisterEvent("SPELLS_CHANGED")

            ObjectRanges[self] = nil
        end

        OnRangeFrame:Show()
        OnSpellsChanged()

    end
end

local Disable = function(self)
    local cRange = self.cRange

    if cRange then
        for k, frame in next, _FRAMES do
            if (frame == self) then
                table.remove(_FRAMES, k)
                break
            end
        end

        if (#_FRAMES == 0) then
            OnRangeFrame:Hide()
            OnRangeFrame:UnregisterEvent("SPELLS_CHANGED")
        end

        ObjectRanges[self] = nil
    end
end

oUF:AddElement("cRange", nil, Enable, Disable)

--- Optional lists of low level baseline skills with greater than 28 yard range.
-- First known spell in the appropriate class list gets used.
-- Note: Spells probably shouldn't have minimum ranges!
HelpIDs = ({
    DEATHKNIGHT = {47541}; -- Death Coil (40yd) - Starter
    DRUID = {5185}; -- Healing Touch (40yd) - Lvl 3
    -- HUNTER = {};
    MAGE = {475}; -- Remove Curse (40yd) - Lvl 30
    PALADIN = {85673}; -- Word of Glory (40yd) - Lvl 9
    PRIEST = {2061}; -- Flash Heal (40yd) - Lvl 3
    -- ROGUE = {};
    SHAMAN = {331}; -- Healing Wave (40yd) - Lvl 7
    WARLOCK = {5697}; -- Unending Breath (30yd) - Lvl 16
    -- WARRIOR = {};
})[playerClass]

HarmIDs = ({
    DEATHKNIGHT = {47541}; -- Death Coil (30yd) - Starter
    DRUID = {5176}; -- Wrath (40yd) - Starter
    HUNTER = {75}; -- Auto Shot (5-40yd) - Starter
    MAGE = {133}; -- Fireball (40yd) - Starter
    PALADIN = {
        62124, -- Hand of Reckoning (30yd) - Lvl 14
        879, -- Exorcism (30yd) - Lvl 18
    };
    PRIEST = {589}; -- Shadow Word: Pain (40yd) - Lvl 4
    -- ROGUE = {};
    SHAMAN = {403}; -- Lightning Bolt (30yd) - Starter
    WARLOCK = {686}; -- Shadow Bolt (40yd) - Starter
    WARRIOR = {355}; -- Taunt (30yd) - Lvl 12
})[playerClass]
