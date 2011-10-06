local F = select(1, unpack(select(2, ...)))

-- Returns the name of the spell ID.
function F.GetSpellName (spellId)
    return GetSpellInfo(spellId)
end


function F.utf8sub (string, index, dots)
    local bytes = string:len()

    if bytes <= index then
        return string
    else
        local length, position = 0, 1

        while position <= bytes do
            length = length + 1
            local char = string:byte(position)
            if char > 240 then
                position = position + 4
            elseif char > 225 then
                position = position + 3
            elseif char > 192 then
                position = position + 2
            else
                position = position + 1
            end

            if length == index then
                break
            end
        end

        if length == index and position <= bytes then
            return string:sub(1, position - 1)..(dots and "..." or "")
        else
            return string
        end
    end
end
