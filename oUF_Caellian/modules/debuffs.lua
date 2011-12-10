if not oUF then return end

local _, oUF_Caellian = ...

local playerClass = caelUI.config.player.class
local GetSpellName = caelUI.GetSpellName

--------------------
-- Can we dispell --
--------------------

oUF_Caellian.eventFrame = CreateFrame("Frame")

local canDispel = {
    DRUID = {Curse = true, Poison = true},
    MAGE = {Curse = true},
    PALADIN = {Poison = true, Disease = true},
    PRIEST = {Disease = true, Magic = true},
    SHAMAN = {Curse = true}
}

oUF_Caellian.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
oUF_Caellian.eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
oUF_Caellian.eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
oUF_Caellian.eventFrame:SetScript("OnEvent", function()
    if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "SHAMAN" then
        local tab, index

        if playerClass == "DRUID" then
            tab, index = 3, 17
        elseif playerClass == "PALADIN" then
            tab, index = 1, 14
        elseif playerClass == "SHAMAN" then
            tab, index = 3, 12
        end

        local _, _, _, _, rank = GetTalentInfo(tab, index)

        canDispel[playerClass].Magic = rank == 1 and true
    end
end)

local dispelList = canDispel[playerClass] or {}

local DebuffTypeColor = {}

for k, v in pairs(_G["DebuffTypeColor"]) do
    DebuffTypeColor[k] = v
end

local backupColor = {r = 0.69, g = 0.31, b = 0.31}

setmetatable(DebuffTypeColor, {__index = function() return backupColor end})

local whiteList = {
    ------------
    -- Cataclysm
    ------------
--Baradin Hold
    -- Pit Lord Argaloth
    [GetSpellName(88954)] = true, -- Consuming Darkness
--Blackwing Descent
    --Magmaw
    [GetSpellName(78941)] = true, -- Parasitic Infection
    [GetSpellName(89773)] = true, -- Mangle
    --Omnitron Defense System
    [GetSpellName(79888)] = true, -- Lightning Conductor
    [GetSpellName(79505)] = true, -- Flamethrower
    [GetSpellName(80161)] = true, -- Chemical Cloud
    [GetSpellName(79501)] = true, -- Acquiring Target
    [GetSpellName(80011)] = true, -- Soaked in Poison
    [GetSpellName(80094)] = true, -- Fixate
    --Maloriak
    [GetSpellName(92973)] = true, -- Consuming Flames
    [GetSpellName(92978)] = true, -- Flash Freeze
    [GetSpellName(91829)] = true, -- Fixate
    --Atramedes
    [GetSpellName(78092)] = true, -- Tracking
    [GetSpellName(78897)] = true, -- Noisy
    [GetSpellName(78023)] = true, -- Roaring Flame
    --Chimaeron
    [GetSpellName(89084)] = true, -- Low Health
    [GetSpellName(82881)] = true, -- Break
    [GetSpellName(82890)] = true, -- Mortality
    --Nefarian
    [GetSpellName(94128)] = true, -- Tail Lash
    [GetSpellName(94075)] = true, -- Magma
--The Bastion of Twilight
    --Halfus
    [GetSpellName(39171)] = true, -- Malevolent Strikes
    [GetSpellName(86169)] = true, -- Furious Roar
    --Valiona & Theralion
    [GetSpellName(86788)] = true, -- Blackout
    [GetSpellName(86622)] = true, -- Engulfing Magic
    [GetSpellName(86202)] = true, -- Twilight Shift
    --Council
    [GetSpellName(82665)] = true, -- Heart of Ice
    [GetSpellName(82660)] = true, -- Burning Blood
    [GetSpellName(82762)] = true, -- Waterlogged
    [GetSpellName(83099)] = true, -- Lightning Rod
    [GetSpellName(82285)] = true, -- Elemental Stasis
    [GetSpellName(92488)] = true, -- Gravity Well
    --Cho'gall
    [GetSpellName(86028)] = true, -- Cho's Blast
    [GetSpellName(86029)] = true, -- Gall's Blast
    [GetSpellName(93189)] = true, -- Corrupted Blood
    [GetSpellName(93133)] = true, -- Debilitating Beam
    [GetSpellName(81836)] = true, -- Corruption: Accelerated
    [GetSpellName(81831)] = true, -- Corruption: Sickness
    [GetSpellName(82125)] = true, -- Corruption: Malformation
    [GetSpellName(82170)] = true, -- Corruption: Absolute
--Throne of the Four Winds
    --Conclave
    [GetSpellName(85576)] = true, -- Withering Winds
    [GetSpellName(85573)] = true, -- Deafening Winds
    [GetSpellName(93057)] = true, -- Slicing Gale
    [GetSpellName(86481)] = true, -- Hurricane
    [GetSpellName(93123)] = true, -- Wind Chill
    [GetSpellName(93121)] = true, -- Toxic Spores
    --Al'Akir
    [GetSpellName(87873)] = true, -- Static Shock
    [GetSpellName(88427)] = true, -- Electrocute
    [GetSpellName(93294)] = true, -- Lightning Rod
    [GetSpellName(93284)] = true, -- Squall Line

--[[
    --------
    -- WoTLK
    --------

    --    The Ruby Sanctum
    --      Halion
    [GetSpellName(74562)] = true,   --  Fiery Combustion
    [GetSpellName(75883)] = true,   --  Combustion
    [GetSpellName(74792)] = true,   --  Soul Consumption
    [GetSpellName(75876)] = true,   --  Consumption

    --    Icecrown Citadel
    --      The Lower Spire
    [GetSpellName(38028)] = true,   --  Web Wrap
    [GetSpellName(69483)] = true,   --  Dark Reckoning
    [GetSpellName(71124)] = true,   --  Curse of Doom

    --      The Plagueworks
    [GetSpellName(71089)] = true,   --  Bubbling Pus
    [GetSpellName(71127)] = true,   --  Mortal Wound
    [GetSpellName(71163)] = true,   --  Devour Humanoid
    [GetSpellName(71103)] = true,   --  Combobulating Spray
    [GetSpellName(71157)] = true,   --  Infested Wound

    --      The Crimson Hall
    [GetSpellName(70645)] = true,   --  Chains of Shadow
    [GetSpellName(70671)] = true,   --  Leeching Rot
    [GetSpellName(70432)] = true,   --  Blood Sap
    [GetSpellName(70435)] = true,   --  Rend Flesh

    --      Frostwing Hall
    [GetSpellName(71257)] = true,   --  Barbaric Strike
    [GetSpellName(71252)] = true,   --  Volley
    [GetSpellName(71327)] = true,   --  Web
    [GetSpellName(36922)] = true,   --  Bellowing Roar

    --      Lord Marrowgar
    [GetSpellName(70823)] = true,   --  Coldflame
    [GetSpellName(69065)] = true,   --  Impaled
    [GetSpellName(70835)] = true,   --  Bone Storm

    --      Lady Deathwhisper
    [GetSpellName(72109)] = true,   --  Death and Decay
    [GetSpellName(71289)] = true,   --  Dominate Mind
    [GetSpellName(71204)] = true,   --  Touch of Insignificance
    [GetSpellName(67934)] = true,   --  Frost Fever
    [GetSpellName(71237)] = true,   --  Curse of Torpor
    [GetSpellName(72491)] = true,   --  Necrotic Strike

    --      Gunship Battle
    [GetSpellName(69651)] = true,   --  Wounding Strike

    --      Deathbringer Saurfang
    [GetSpellName(72293)] = true,   --  Mark of the Fallen Champion
    [GetSpellName(72442)] = true,   --  Boiling Blood
    [GetSpellName(72449)] = true,   --  Rune of Blood
    [GetSpellName(72769)] = true,   --  Scent of Blood (heroic)

    --      Rotface
    [GetSpellName(71224)] = true,   --  Mutated Infection
    [GetSpellName(71215)] = true,   --  Ooze Flood
    [GetSpellName(69774)] = true,   --  Sticky Ooze

    --      Festergut
    [GetSpellName(69279)] = true,   --  Gas Spore
    [GetSpellName(71218)] = true,   --  Vile Gas
    [GetSpellName(72219)] = true,   --  Gastric Bloat

    --      Professor Putricide
    [GetSpellName(70341)] = true,   --  Slime Puddle
    [GetSpellName(72549)] = true,   --  Malleable Goo
    [GetSpellName(71278)] = true,   --  Choking Gas Bomb
    [GetSpellName(70215)] = true,   --  Gaseous Bloat
    [GetSpellName(70447)] = true,   --  Volatile Ooze Adhesive
    [GetSpellName(72454)] = true,   --  Mutated Plague
    [GetSpellName(70405)] = true,   --  Mutated Transformation
    [GetSpellName(72856)] = true,   --  Unbound Plague
    [GetSpellName(70953)] = true,   --  Plague Sickness

    --      Blood Princes
    [GetSpellName(72796)] = true,   --  Glittering Sparks
    [GetSpellName(71822)] = true,   --  Shadow Resonance

    --      Blood-Queen Lana'thel
    [GetSpellName(70838)] = true,   --  Blood Mirror
    [GetSpellName(72265)] = true,   --  Delirious Slash
    [GetSpellName(71473)] = true,   --  Essence of the Blood Queen
    [GetSpellName(71474)] = true,   --  Frenzied Bloodthirst
    [GetSpellName(73070)] = true,   --  Incite Terror
    [GetSpellName(71340)] = true,   --  Pact of the Darkfallen
    [GetSpellName(71265)] = true,   --  Swarming Shadows
    [GetSpellName(70923)] = true,   --  Uncontrollable Frenzy

    --      Valithria Dreamwalker
    [GetSpellName(70873)] = true,   --  Emerald Vigor
    [GetSpellName(71746)] = true,   --  Column of Frost
    [GetSpellName(71741)] = true,   --  Mana Void
    [GetSpellName(71738)] = true,   --  Corrosion
    [GetSpellName(71733)] = true,   --  Acid Burst
    [GetSpellName(71283)] = true,   --  Gut Spray
    [GetSpellName(71941)] = true,   --  Twisted Nightmares

    --      Sindragosa
    [GetSpellName(69762)] = true,   --  Unchained Magic
    [GetSpellName(69766)] = true,   --  Instability
    [GetSpellName(70126)] = true,   --  Frost Beacon
    [GetSpellName(70157)] = true,   --  Ice Tomb

    --      The Lich King
    [GetSpellName(70337)] = true,   --  Necrotic plague
    [GetSpellName(72149)] = true,   --  Shockwave
    [GetSpellName(70541)] = true,   --  Infest
    [GetSpellName(69242)] = true,   --  Soul Shriek
    [GetSpellName(69409)] = true,   --  Soul Reaper
    [GetSpellName(72762)] = true,   --  Defile
    [GetSpellName(68980)] = true,   --  Harvest Soul
--]]
}

local function GetDebuffType(unit, filter)
    if not UnitCanAssist("player", unit) then return end

    local dispelType, debuffIcon

    local i = 1
    local isWhiteList

    while true do
        local name, _, icon, _, debuffType = UnitAura(unit, i, "HARMFUL")

        if not icon then break end

        if dispelList[debuffType] or (not filter and debuffType) or whiteList[name] then
            dispelType = debuffType
            debuffIcon = icon

            if whiteList[name] then
                isWhiteList = true
                break
            end
        end

        i = i + 1
    end

    return dispelType, debuffIcon, isWhiteList
end

local function Update(self, event, unit)
    if self.unit ~= unit  then return end

    local dispelType, debuffIcon, isWhiteList = GetDebuffType(unit, self.cDebuffFilter)

    if self.cDebuffBackdrop then
        local color

        if debuffIcon then
            color = DebuffTypeColor[dispelType]
            self.cDebuffBackdrop:SetVertexColor(color.r, color.g, color.b, 1)
        else
            self.cDebuffBackdrop:SetVertexColor(0, 0, 0, 0)
        end
    end

    if self.cDebuff.icon then
        if debuffIcon then
            self.cDebuff.icon:SetTexture(debuffIcon)
            self.cDebuff.border:SetBackdropColor(0.5, 0.5, 0.5, 1)
            self.cDebuff.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0.5)
        else
            self.cDebuff.icon:SetTexture(nil)
            self.cDebuff.border:SetBackdropColor(0.5, 0.5, 0.5, 0)
            self.cDebuff.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0)
        end
    end
end

local function Enable(self)
    if not self.cDebuff then return end

    self:RegisterEvent("UNIT_AURA", Update)

    return true
end

local function Disable(self)
    if self.cDebuffBackdrop or self.cDebuff.icon then
        self:UnregisterEvent("UNIT_AURA", Update)
    end
end

oUF:AddElement("cDebuff", Update, Enable, Disable)
