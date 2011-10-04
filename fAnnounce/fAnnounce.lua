local function Aura(spellID, duration, auraID)
    local spell = {}
    spell["spellID"] = spellID
    spell["auraID"] = auraID or spellID
    spell["duration"] = duration or 0
    return spell
end

local auraids = {
    -- Warriors
    Aura(871,   12),    -- Shield Wall
    Aura(12975, 20),    -- Last Stand
    Aura(97462, 10),    -- Rallying Cry
    Aura(1161,  6),     -- Challenging Shout
    
    -- Druids
    Aura(22812, 12),    -- Barkskin
    Aura(61336, 12),    -- Survival Instincts
    Aura(22842, 20),    -- Frenzied Regeneration
    
    -- Paladins
    Aura(498,   10),      -- Divine Protection
    Aura(70940, 6),     -- Divine Guardian
    Aura(86150),        -- Guardian of Ancient Kings
    Aura(31850, 10),    -- Ardent Defender
    Aura(6940,  12),     -- Hand of Sacrifice
    
    -- Death Knights
    Aura(48792, 12),    -- Icebound Fortitude
    -- XXX: Needs to have a glyph check for increase of 2 seconds on duration.
    Aura(48707, 5),     -- Anti-magic Shell
    Aura(49222),        -- Bone Shield
    Aura(55233, 10),    -- Vampiric Blood
}

local activeauras = {}

local fAnnounce = CreateFrame("Frame")
fAnnounce:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
fAnnounce:RegisterEvent("UNIT_AURA")
fAnnounce:SetScript("OnEvent", function(self, event, unit, _, _, _, id)
    if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player") then
        for key, spell in pairs(auraids) do
            if (id == spell.spellID) then

                local output
                if (GetRealNumRaidMembers() > 0) then
                    output = "RAID"
                elseif (GetRealNumPartyMembers() > 0) then
                    output = "PARTY"
                end
                if (output) then
                    local message

                    if spell.duration > 0 then
                        message = string.format(GetSpellLink(id) .. " is active for %d seconds", spell.duration)
                    else
                        message = GetSpellLink(id) .. " activated!"
                    end

                    SendChatMessage(message, output, nil, nil)
                    activeauras[spell.auraID] = spell.auraID
                end
            end
        end
    elseif (event == "UNIT_AURA") then
        for key, id in pairs(activeauras) do
            local name = UnitAura("player", select(1, GetSpellInfo(id)))
            if (name == nil) then
                local output
                if (GetRealNumRaidMembers() > 0) then
                    output = "RAID"
                elseif (GetRealNumPartyMembers() > 0) then
                    output = "PARTY"
                end
                if (output) then
                    SendChatMessage(GetSpellLink(id) .. " faded!", output, nil, nil)
                    activeauras[id] = nil
                    break
                end
            end
        end
    end
end)