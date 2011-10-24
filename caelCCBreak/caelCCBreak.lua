local _, caelCCBreak = ...

caelCCBreak.eventFrame = CreateFrame("Frame", nil, UIParent)

local grouped = nil
local messageStrings = {
    ["frFR"] = {
        [1] = "%s %s enlevé par |cff559655%s|r",
        [2] = "%s %s sur |cffAF5050%s|r enlevé par |cff559655%s|r%s",
    },
    ["enUS"] = {
        [1] = "%s %s broken by |cff559655%s|r",
        [2] = "%s %s on |cffAF5050%s|r broken by |cff559655%s|r%s"
    }
}
local messageNumber = 2

local locale = caelUI.config.locale

local hostile = COMBATLOG_OBJECT_REACTION_HOSTILE or 64 or 0x00000040

local GetSpellName = caelUI.get_spell_name

-- Note: We are only considering crowd controls lasting at least 20 seconds.

local spells = {
    GetSpellName(118),      -- Polymorph
    GetSpellName(28272),    -- Polymorph (pig)
    GetSpellName(28271),    -- Polymorph (turtle)
    GetSpellName(59634),    -- Polymorph (penguin)
    GetSpellName(61025),    -- Polymorph (Serpent)
    GetSpellName(61305),    -- Polymorph (black cat)
    GetSpellName(61721),    -- Polymorph (rabbit)
    GetSpellName(61780),    -- Polymorph (turkey)

    GetSpellName(9484),     -- Shackle Undead

    GetSpellName(3355),     -- Freezing Trap Effect
    GetSpellName(19386),    -- Wyvern Sting

    GetSpellName(339),      -- Entagling Roots
    GetSpellName(2637),     -- Hibernate

    GetSpellName(6770),     -- Sap

    GetSpellName(5782),     -- Fear

    GetSpellName(6358),     -- Seduction (succubus)

    GetSpellName(10326),    -- Turn Evil
    GetSpellName(20066),    -- Repentance

    GetSpellName(51514),    -- Hex
    GetSpellName(76780),    -- Bind Elemental
}

caelCCBreak.eventFrame:RegisterEvent"PARTY_MEMBERS_CHANGED"
caelCCBreak.eventFrame:SetScript("OnEvent", function(self, event, _, subEvent, _, sourceName, _, _, destName, destFlags, spellID, spellName, _, _, extraSpellName, ...)
    if event == "PARTY_MEMBERS_CHANGED" then

        local numParty = GetNumPartyMembers()

        if not grouped and numParty > 0 then
            self:RegisterEvent"COMBAT_LOG_UNFILTERED_EVENT"
            grouped = true
        elseif grouped and numParty == 0 then
            self:UnregisterEvent"COMBAT_LOG_UNFILTERED_EVENT"
            grouped = nil
        end

    else

        if subEvent == "SPELL_AURA_BROKEN_SPELL" or subEvent == "SPELL_AURA_BROKEN" then
            if bit.band(destFlags, hostile) == hostile then
                for key, value in pairs(spells) do
                    if value == spellName then

                        if messageStrings[locale] and messageStrings[locale][messageNumber] then
                            local msg = messageStrings[locale][messageNumber]

                            if messageNumber == 1 then
                                DEFAULT_CHAT_FRAME:AddMessage(msg:format("|cffD7BEA5cael|rCCBreak:", GetSpellLink(spellID), sourceName and sourceName or "Unknown"))
                            elseif messageNumber == 2 then
                                DEFAULT_CHAT_FRAME:AddMessage(msg:format("|cffD7BEA5cael|rCCBreak:", GetSpellLink(spellID), destName, sourceName and sourceName or "Unknown", extraSpellName and "'s "..GetSpellLink(extraSpellName) or ""))
                            else
                                DEFAULT_CHAT_FRAME:AddMessage("|cffD7BEA5cael|rCCBreak: Something broke, please fix your string number to 1 or 2.")
                            end
                        else
                            local msg = messageStrings["enUS"][1]

                            DEFAULT_CHAT_FRAME:AddMessage(msg:format("|cffD7BEA5cael|rCCBreak:", GetSpellLink(spellID), sourceName and sourceName or "Unknown"))
                        end

                        break

                    end
                end
            end
        end
    end
end)
