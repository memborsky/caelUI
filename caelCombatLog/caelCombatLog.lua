local _, caelCombatLog = ...

local media = caelUI.media

local cCL, collumns = caelCombatLog.frame, caelCombatLog.frame.collumns

local holdTime = 5
local player, damage, duration
local deathChar = "††"

local red = "|cffAF5050"
local green = "|cff559655"
local lightgreen = "|cff7DCD6E"
local beige = "|cffD7BEA5" -- 215, 190, 165

local link = "|HClog:%s|h"

local find = string.find
local format = string.format

local missTypes = {
    ABSORB = "Absorb",
    BLOCK = "Block",
    DEFLECT = "Deflect",
    DODGE = "Dodge",
    EVADE = "Evade",
    IMMUNE = "Immune",
    MISS = "Miss",
    PARRY = "Parry",
    REFLECT = "Reflect",
    RESIST = "Resist",
}

local schoolColors = {}

local powerColors = {
    [0]    = "|cff5073A0",    -- Mana -- |cff0000FF -- 80, 115, 160
    [1]    = "|cffAF5050",    -- Rage -- |cffFF0000 -- 175, 80, 80
    [2]    = "|cffB46E46",    -- Focus -- |cff643219 -- 180, 110, 70
    [3]    = "|cffA5A05A",    -- Energy -- |cffFFFF00 -- 165, 160, 90
    [4]    = "|cff329696",    -- Happiness -- cff00FFFF -- 50, 150, 150
    [5]    = "|cff8C919B",    -- Runes -- |cff323232 -- 140, 145, 155
    [6]    = "|cff005264",    -- Runic Power
    [7]    = "|cffD4A017", -- Soul Shards(Needs color correction)
    [8]    = "|cffD4A017", -- Eclipse (Needs color correction)
    [9]    = "|cffD4A017", -- Holy Power (Needs color correction)
}

setmetatable(powerColors, {__index = function(t, k) return "|cffD7BEA5" end})

local powerStrings = {
    [SPELL_POWER_MANA] = MANA, -- 0
    [SPELL_POWER_RAGE] = RAGE, -- 1
    [SPELL_POWER_FOCUS] = FOCUS, -- 2
    [SPELL_POWER_ENERGY] = ENERGY, -- 3
    --[SPELL_POWER_HAPPINESS] = HAPPINESS, -- 4
    [SPELL_POWER_RUNES] = RUNES, -- 5
    [SPELL_POWER_RUNIC_POWER] = RUNIC_POWER, -- 6
    [SPELL_POWER_SOUL_SHARDS] = SOUL_SHARDS, -- 7
    [SPELL_POWER_ECLIPSE] = ECLIPSE, -- 8
    [SPELL_POWER_HOLY_POWER] = HOLY_POWER, -- 9
}

local eventTable = {
    ["SWING_DAMAGE"] = "damage",
    ["RANGE_DAMAGE"] = "damage",
    ["SPELL_DAMAGE"] = "damage",
    ["SPELL_PERIODIC_DAMAGE"] = "damage",
    ["ENVIRONMENTAL_DAMAGE"] = "damage",
    ["SPELL_HEAL"] = "healing",
    ["SPELL_PERIODIC_HEAL"] = "healing",
}

local data = {damageOut = 0, damageIn = 0, healingOut = 0, healingIn = 0}

local function clearSummary()
    data.damageIn = 0
    data.damageOut = 0
    data.healingIn = 0
    data.healingOut = 0
end

local formatStrings = {
    ["SPELL_ENERGIZE"] = "%s + %d%s",
    ["SPELL_PERIODIC_ENERGIZE"] = "%s + %d%s",
    ["SPELL_PERIODIC_HEAL"] = "%s + %d%s",
    ["SPELL_PERIODIC_DAMAGE"] = "%s + %d%s",
    ["SPELL_PERIODIC_DRAIN"] = sourceGUID == player and "« %s + %d%s" or "» %s - %d%s",
    ["SPELL_PERIODIC_LEECH"] = sourceGUID == player and "« %s + %d%s" or "» %s - %d%s",
    ["Volley"] = "%s %d%s",
}

local excludedSpells = {}

local throttledEvents = {
    ["SPELL_ENERGIZE"] = {petIn = {}, playerIn = {}},
    ["SPELL_PERIODIC_ENERGIZE"] = {petIn = {}, playerIn = {}},
    ["SPELL_PERIODIC_HEAL"] = {petIn = {}, playerIn = {}},
    ["SPELL_PERIODIC_DAMAGE"] = {petIn = {}, petOut = {}, playerIn = {}, playerOut = {}},
    ["SPELL_PERIODIC_DRAIN"] = {petIn = {}, petOut = {}, playerIn = {}, playerOut = {}},
    ["SPELL_PERIODIC_LEECH"] = {petIn = {}, petOut = {}, playerIn = {}, playerOut = {}},
}

local throttledSpells = {
    ["Volley"] = {
        playerIn = {amount = 0, isHit = 0, isCrit = 0, reportOnFade = true, format = formatStrings["Volley"]},
        playerOut = {amount = 0, isHit = 0, isCrit = 0, reportOnFade = true, format = formatStrings["Volley"]},
        petIn = {amount = 0, isHit = 0, isCrit = 0, reportOnFade = true, format = formatStrings["Volley"]},
    },
}

local tooltipStrings = {
    [1] = "%s %s %s %s %s for %d %s",
    [2] = "%s %s suffer %d from %s",
    [3] = "%s %s %s %s %s for %d %s %s",
    [4] = "%s %s %s miss %s %s",
}

for event, entry in pairs(throttledEvents) do
    local mt = {__index = function(t, k)
        local newTable = {amount = 0, isHit = 0, isCrit = 0, extraAmount = 0, format = formatStrings[event]}
        t[k] = newTable
        return newTable
    end}

    for unit, entry in pairs(entry) do
        setmetatable(entry, mt)
    end
end

local Output = function(frame, rsaFrame, color, text, rsaText, critical, pet, prefix, suffix, tooltipMsg, throttle, noccl)
    local msg = format("%s%s%s%s%s|h", link:format(tooltipMsg or ""), ((frame == 2 or frame == 3) and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""), (color or ""), text, ((frame == 1 or frame == 2) and suffix and suffix ~= "" and "|cffD7BEA5"..suffix.."|r" or ""))

    if not(noccl) then
        for i, v in pairs(collumns) do
            v:AddMessage(i == frame and msg or " ")
        end
    end

    if recScrollAreas and (not(throttle) or (throttle and noccl)) then
        local rsamsg = format("%s%s%s%s|h", ((frame == 2 or frame == 3) and prefix and prefix ~= "" and "|cffD7BEA5"..prefix.."|r" or ""), (color or ""), rsaText or text, ((frame == 1 or frame == 2) and suffix and suffix ~= "" and "|cffD7BEA5"..suffix.."|r" or ""))
        recScrollAreas:AddText(rsamsg, critical, rsaFrame and rsaFrame or frame == 1 and "Incoming" or frame == 3 and "Outgoing" or "Information")
    end
end

cCL:RegisterEvent("PLAYER_LOGIN")
cCL:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        player = UnitGUID("player")
        for i, v in pairs(COMBATLOG_DEFAULT_COLORS.schoolColoring) do
            schoolColors[i] = format("|cff%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
        end
        self:UnregisterEvent("PLAYER_LOGIN")
        self.PLAYER_LOGIN = nil
    end
end)

local FormatMissType = function(event, missType, amountMissed)
    local resultStr
    if (missType == "RESIST" or missType == "BLOCK" or missType == "ABSORB") then
        if amountMissed == 0 then
            resultStr = ""
        else
            resultStr = format(_G["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed)
        end
    else
        resultStr = _G["ACTION_SWING_MISSED_"..missType]
    end
    return resultStr
end

local ShortName = function(spellName)
    if find(spellName, "[%s%-]") then
        spellName = string.gsub(spellName, "(%a)[%l]*[%s%-]*", "%1")
    else
        spellName = string.sub(spellName, 1, 3)
    end
    return spellName
end

local report = {}
cCL:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
cCL:HookScript("OnEvent", function(self, event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local pet = UnitGUID("pet")

        if not (sourceGUID == player or destGUID == player or sourceGUID == pet or destGUID == pet) then return end

        local meSource, meTarget, isPet = sourceGUID == player, destGUID == player, sourceGUID == pet or destGUID == pet
        local modString, tooltipMsg, rsaFrame, isEclipseEnergize
        local color, crit, prefix, suffix, scrollFrame, text, rsaText, noccl
        local absorbed, amount, blocked, critical, crushing, enviromentalType, extraAmount, glancing, missAmount, missType, overheal, overkill, powerType, resisted, school, spellId, spellName, spellSchool
        local timeStamp = date("%H:%M:%S", timestamp)

        scrollFrame = (sourceGUID == player or sourceGUID == pet) and 3 or 1

        local direction = (destGUID == player or destGUID == pet) and "In" or "Out"
        local unitDirection = (isPet and "pet" or "player")..direction

        if subEvent == "SWING_DAMAGE" then

            amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
            text, rsaText, crit, color = amount - overkill, amount, critical, schoolColors[school <= 1 and 0 or school]

            modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
            tooltipMsg = format(tooltipStrings[1], timeStamp, (meSource and "Your" or sourceName.."'s"), "melee swing", "hit", (meTarget and "you" or destName), amount, modString)

        elseif subEvent == "RANGE_DAMAGE"  or subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE" or subEvent == "DAMAGE_SHIELD" or subEvent == "DAMAGE_SPLIT" then

            spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
            if subEvent == "RANGE_DAMAGE" then spellSchool = school end

            text, rsaText, crit, color = amount - overkill, format("%s %s", ShortName(spellName), amount), critical, subEvent == "RANGE_DAMAGE" and schoolColors[school <= 1 and 0 or school] or schoolColors[spellSchool]

            modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
            tooltipMsg = format(tooltipStrings[1], timeStamp, (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), (subEvent == "RANGE_DAMAGE"  or subEvent == "SPELL_DAMAGE") and "hit" or "damaged", (meTarget and "you" or destName), amount, modString)

        elseif subEvent == "ENVIRONMENTAL_DAMAGE" then

            enviromentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
            text, rsaText, color = amount, format("%s %s", _G["ACTION_ENVIRONMENTAL_DAMAGE_"..enviromentalType], amount), schoolColors[school <= 1 and 0 or school]

            tooltipMsg = format(tooltipStrings[2], timeStamp, (meTarget and "You" or destName), amount, _G["ACTION_ENVIRONMENTAL_DAMAGE_"..enviromentalType])

        elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then

            spellId, spellName, spellSchool, amount, overheal, absorbed, critical = ...
            if overheal < amount then
                text, rsaText, crit, prefix = amount - overheal, format("%s %s", ShortName(spellName), amount), critical, sourceGUID == player and destGUID ~= player and "» " or "« "
            end

            color = subEvent == "SPELL_PERIODIC_HEAL" and lightgreen or green
            scrollFrame = 2

            modString = CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overheal, textMode, spellId, overkill) or ""
            tooltipMsg = format(tooltipStrings[1], timeStamp, (meSource and "Your" or sourceName.."'s"), (spellName), "heal", (meTarget and "you" or destName), amount, modString)

        elseif subEvent:find("ENERGIZE") or subEvent:find("DRAIN") or subEvent:find("LEECH") then

            spellId, spellName, spellSchool, amount, powerType, extraAmount = ...

            if amount == 0 then
                return
            else
                scrollFrame = 2
            end

            isEclipseEnergize = powerType == 8

            text = extraAmount and format("%s (%s %s)", amount, meSource and "+" or "-", extraAmount - amount) or isEclipseEnergize and abs(amount) or amount

            if isEclipseEnergize then
                rsaText = format("%s %s", isEclipseEnergize and (amount > 0 and "Solar Energy +" or "Lunar Energy +"), abs(amount))
            else
                rsaText = format("%s %s %s", ShortName(spellName), extraAmount and (meSource and "+" or "-") or "", extraAmount and extraAmount or amount)
            end

            crit = critical
            color = powerColors[powerType]

            tooltipMsg = format(subEvent:find("ENERGIZE") and tooltipStrings[1] or tooltipStrings[3],
            timeStamp,
            meSource and "Your" or sourceName and sourceName.."'s" or "",
            spellName,
            subEvent:find("ENERGIZE") and "energize" or subEvent:find("DRAIN") and "drain" or "leech",
            meTarget and "you" or destName,
            isEclipseEnergize and abs(amount) or amount,
            isEclipseEnergize and (amount > 0 and "Solar Energy" or "Lunar Energy") or powerStrings[powerType],
            extraAmount and format("(%s %s)", extraAmount, meSource and "gained" or "lost") or ""
            )

        elseif subEvent == "SWING_MISSED" then

            missType, missAmount = ...
            text = missTypes[missType] or missType

            tooltipMsg = format(tooltipStrings[4], timeStamp, (meSource and "You" or sourceName.."'s"), "melee swing", (meTarget and "you" or destName), FormatMissType(subEvent, missType, missAmount))

        elseif subEvent == "RANGE_MISSED" or subEvent == "SPELL_MISSED" or subEvent == "SPELL_PERIODIC_MISSED" or subEvent == "DAMAGE_SHIELD_MISSED" then

            spellId, spellName, spellSchool, missType, missAmount = ...
            text, rsaText = missTypes[missType] or missType, format("%s %s", ShortName(spellName), missTypes[missType] or missType), schoolColors[spellSchool]

            tooltipMsg = format(tooltipStrings[4], timeStamp, (meSource and "Your" or sourceName and sourceName.."'s" or ""), (spellName), (meTarget and "you" or destName), FormatMissType(subEvent, missType, missAmount) or "")

        elseif subEvent:find("AURA_APPLIED") or subEvent:find("AURA_REMOVED") then

            spellId, spellName, spellSchool, auraType, amount = ...

            color, noccl = schoolColors[spellSchool], true

            if auraType == "DEBUFF" and meTarget then
                scrollFrame = 1
            elseif auraType == "DEBUFF" and meSource then
                scrollFrame = 3
            elseif auraType == "BUFF" and meSource and meTarget then
                scrollFrame = 2
                crit = true
            else
                return
            end

            if spellName == "Lock and Load" then
                rsaFrame = "Notification"
                PlaySoundFile(media.files.soundLnLProc)
            end

            if not (throttledSpells[spellName] and throttledSpells[spellName][unitDirection]) then
                text = format("%s%s", scrollFrame == 2 and spellName or ShortName(spellName), amount and format(" (%d)", amount) or "")
            end

            if throttledSpells[spellName] and throttledSpells[spellName][unitDirection] and throttledSpells[spellName][unitDirection].reportOnFade then
                throttledSpells[spellName][unitDirection].elapsed = holdTime
            end

        elseif subEvent == "PARTY_KILL" or subEvent == "UNIT_DIED" or subEvent == "UNIT_DESTROYED" or subEvent == "UNIT_DISSIPATES" then

            text, color, crit, scrollFrame, rsaFrame = deathChar.." "..destName.." "..deathChar, beige, true, 2, "Notification"

            if meTarget then
                tooltipMsg = table.concat(report, "\n")
                for k, v in pairs(report) do
                    report[k] = nil
                end
            end
        end

        if scrollFrame == 1 then
            suffix = format("%s%s%s%s%s%s%s%s%s%s%s%s",
            suffix or "",
            isPet and "·" or "",
            blocked and " b" or "",
            crushing and " c" or "",
            glancing and " g" or "",
            resisted and " r" or "",
            absorbed and absorbed > 0 and " a" or "",
            overheal and overheal > 0 and " h" or "",
            overkill and overkill > 0 and " k" or "",
            critical and " •" or "",
            subEvent:find("AURA_APPLIED") and not throttledSpells[spellName] and " ++" or "",
            subEvent:find("AURA_REMOVED") and not throttledSpells[spellName] and " --" or ""
            )
        elseif scrollFrame == 2 then
            suffix = format("%s%s%s%s%s",
            suffix or "",
            isPet and "·" or "",
            critical and " •" or "",
            subEvent:find("AURA_APPLIED") and not throttledSpells[spellName] and " ++" or "",
            subEvent:find("AURA_REMOVED") and not throttledSpells[spellName] and " --" or ""
            )
            prefix = format("%s%s%s%s%s%s",
            prefix or "",
            extraAmount and (meSource and "« " or "» ") or "",
            overheal and overheal > 0 and "h " or "",
            critical and "• " or "",
            subEvent:find("AURA_APPLIED") and not throttledSpells[spellName] and "++ " or "",
            subEvent:find("AURA_REMOVED") and not throttledSpells[spellName] and "-- " or "",
            isPet and "·" or ""
            )
        elseif scrollFrame == 3 then
            prefix = format("%s%s%s%s%s%s%s%s%s%s%s%s",
            prefix or "",
            blocked and "b " or "",
            crushing and "c " or "",
            glancing and "g " or "",
            resisted and "r " or "",
            absorbed and absorbed > 0 and "a " or "",
            overheal and overheal > 0 and "h " or "",
            overkill and overkill > 0 and "k " or "",
            critical and "• " or "",
            subEvent:find("AURA_APPLIED") and not throttledSpells[spellName] and "++ " or "",
            subEvent:find("AURA_REMOVED") and not throttledSpells[spellName] and "-- " or "",
            isPet and "·" or ""
            )
        end

        local valueType = eventTable[subEvent]

        if valueType then
            data[valueType..direction] = data[valueType..direction] + amount
        end

        local throttle
        if (throttledEvents[subEvent] and throttledEvents[subEvent][unitDirection] or throttledSpells[spellName] and throttledSpells[spellName][unitDirection]) and not excludedSpells[spellName] and not isEclipseEnergize then
            if throttledSpells[spellName] then
                throttle = throttledSpells[spellName][unitDirection]
            else
                throttle = throttledEvents[subEvent][unitDirection][spellName]
            end
            throttle.amount = throttle.amount + (amount or 0) - (overheal or overkill or 0)
            if extraAmount then
                throttle.extraAmount = throttle.extraAmount + (extraAmount or 0)
            end
            if not throttle.elapsed and not throttle.reportOnFade then
                throttle.elapsed = 0
            end

            throttle.color = color

            if not throttle.scrollFrame then
                throttle.scrollFrame = scrollFrame
            end

            if critical then
                throttle.isCrit = throttle.isCrit + 1
            else
                throttle.isHit = throttle.isHit + 1
            end
        end

        if text then
            Output(scrollFrame, rsaFrame, color, text, rsaText, crit, isPet, prefix, suffix, tooltipMsg, throttle, noccl)
        end

        if meTarget and ((find(subEvent, "DAMAGE") and not (find(subEvent, "MISS")) or find(subEvent, "HEAL"))) then
            table.insert(report, tooltipMsg)
            if #report > 5 then
                table.remove(report, 1)
            end
        end
    end
end)

--        Output(scrollFrame, rsaFrame, color, text, rsaText, crit, isPet, prefix, suffix, tooltipMsg, throttle, noccl)
--[[
local oldstate = nil
cCL:RegisterEvent("UNIT_AURA")
cCL:HookScript("OnEvent", function(self, event)
if event == "UNIT_AURA" then
local newstate = UnitAura("player", "Lock and Load")
if newstate and not oldstate then
Output(nil, "Notification", red, "++ Lock and Load ++", nil, true)
elseif oldstate and not newstate then
Output(nil, "Notification", red, "-- Lock and Load --", nil, true)
end
oldstate = newstate
end
end)
--]]
local UpdateThrottle = function(v, unit, spellName, elapsed)
    if v.elapsed then
        v.elapsed = v.elapsed + elapsed
        if v.elapsed >= holdTime then

            local isPet = unit:find("pet")
            local hitString
            if v.isCrit  > 0 then
                hitString = format(" (%d |4hit:hits;, %d |4crit:crits;)", v.isHit, v.isCrit)
            elseif v.isHit  > 1 then
                hitString = format(" (%d hits)", v.isHit)
            else
                hitString = ""
            end
            if v.amount > 0 then
                Output(v.scrollFrame, nil, v.color, format(v.format, ShortName(spellName), v.amount, hitString), rsaText, nil, isPet, nil, nil, nil, true, true)
            end
            v.amount = 0
            v.isHit = 0
            v.isCrit = 0
            v.elapsed = nil
        end
    end
end

cCL:SetScript("OnUpdate", function(self, elapsed)
    for event, t in pairs(throttledEvents) do
        for unit, throttledEvents in pairs(t) do
            for spellName, v in pairs(throttledEvents) do
                UpdateThrottle(v, unit, spellName, elapsed)
            end
        end
    end

    for spellName, units in pairs(throttledSpells) do
        for unit, data in pairs(units) do
            UpdateThrottle(data, unit, spellName, elapsed)
        end
    end
end)

cCL:RegisterEvent("PLAYER_REGEN_DISABLED")
cCL:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        Output(2, "Information", red, "++ Combat ++", nil, true)
        PlaySoundFile(media.files.soundEnteringCombat)

        duration = GetTime()
        clearSummary()
    end
end)

local ShortValue = function(value)
    if value >= 1e6 then
        return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
    elseif value >= 1e3 or value <= -1e3 then
        return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
    else
        return value
    end
end

local t = {}
cCL:RegisterEvent("PLAYER_REGEN_ENABLED")
cCL:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        duration = GetTime() - duration

        for k,_ in pairs(t) do t[k] = nil end

        t[#t+1] = (data.damageOut) > 0 and red..ShortValue(data.damageOut).."|r"  or nil
        t[#t+1] = (data.damageIn) > 0 and red..ShortValue(data.damageIn).."|r" or nil
        t[#t+1] = (data.healingOut) > 0 and green..ShortValue(data.healingOut).."|r" or nil
        t[#t+1] = (data.healingIn) > 0 and green..ShortValue(data.healingIn).."|r" or nil

        Output(2, "Information", green, "-- Combat --", nil, true)
        PlaySoundFile(media.files.soundLeavingCombat)

        if #t > 0 then
            local tooltipMsg = format("%s%s%s%s%s",
            (floor(duration / 60) > 0) and (floor(duration / 60).."m "..(floor(duration) % 60).."s") or (floor(duration).."s").." in combat\n",
            data.damageOut > 0 and "Damage done: "..(data.damageOut).."\n" or "",
            data.damageIn > 0 and "Damage received: "..(data.damageIn).."\n" or "",
            data.healingOut > 0 and "Healing done: "..data.healingOut.."\n" or "",
            data.healingIn > 0 and "Healing received: "..data.healingIn.."\n" or ""
            )
            Output(2, "Notification", nil, table.concat(t, beige.." ¦ "), nil, true, nil, nil, nil, tooltipMsg)
        end
    end
end)

cCL:RegisterEvent("UNIT_COMBO_POINTS")
cCL:HookScript("OnEvent", function(self, event)
    if event == "UNIT_COMBO_POINTS" then
        local comboPoints = GetComboPoints("player", "target")
        if comboPoints > 0 and comboPoints ~= MAX_COMBO_POINTS then
            PlaySoundFile(media.files.soundCombo)
        elseif comboPoints == MAX_COMBO_POINTS then
            PlaySoundFile(media.files.soundComboMax)
        end
    end
end)
