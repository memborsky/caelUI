local private = unpack(select(2, ...))

function private.is_in (needle, haystack)
    if type(haystack) == "table" then
        for key, value in next, haystack do
            if key == needle then
                return true
            elseif value == needle then
                return true
            end
        end
    --elseif type(needle) == type(haystack) and type(needle) == "string" then
        -- ZZZ: Parse the string to see if needle is in haystack.
        --return true
    end

    return false
end


--[[
Explode string seperated by delimiter

This function works exactly like the PHP explode function. It will take an input string (str) and output a table of strings that were broken by a deliminter (sep).

@param  str     string  Our base string we are wanting to explode.
@param  sep     string  Our deliminter.
@return         table   This is our results table indexed by # and valued with our words between the delimiter.
--]]
function private.explode (text, delimiter)
    if not delimiter or type(delimiter) ~= "string" then
        delimiter = ":"
    end

    local text_length = string.len(text)
    local result = {}
    local position = 1

    while position < text_length do
        local place = string.find(text, delimiter, position)

        if place then
            tinsert(result, strsub(text, position, place - 1))
            position = place + 1
        else
            tinsert(result, strsub(text, position))

            -- effectively the same as 'break'
            position = text_length
        end
    end

    return result
end


--[[
Used to check our function arguments

We will go through the process of checking the given argument type against the parameter list given.
If it is found to be invalid, then it will print an error message, else it will just return to the caller with no response.

@param  str     value   This is the type name we are passing in to check our parameter against.
@param  num     number  This is the argument number in the list. The numbering should start at 1.
--]]
function private.argument_check (value, number, ...)
    assert(type(number) == 'number', "Bad argument #2 to 'argcheck' (number expected, got " .. type(number) .. ")")

    for index = 1, select("#", ...) do
        if type(value) == select(index, ...) then
            return
        end
    end

    local types = strjoin(", ", ...)
    local name = string.match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
    private.error(("Bad argument #%d to '%s' (%s expected, got %s"):format(number, name, types, type(value)), 3)
end

-- Returns the name of the spell ID.
function private.GetSpellName (spell_id)
    return GetSpellInfo(spell_id)
end


function private.UTF8_substitution (string, index, dots)
    local bytes = string:len()

    if bytes <= index then
        return string
    else
        local length, position = 0, 1

        while position <= bytes do
            length = length + 1

            local character = string:byte(position)

            if character > 240 then
                position = position + 4
            elseif character > 225 then
                position = position + 3
            elseif character > 192 then
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

-- Kill off everything attached to the frame object and basically render it useless.
function private.kill (object)
    local object_reference = object

    if type(object) == "string" then
        object_reference = _G[object]
    else
        object_reference = object
    end
    if not object_reference then return end
    if type(object_reference) == "frame" then
        object_reference:UnregisterAllEvents()
    end
    object_reference:Hide()
    object_reference.Show = object_reference.Hide
end

function private:format_money (value)
    if value >= 1e4 then
        return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
    elseif value >= 1e2 then
        return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
    else
        return format("|cffeda55f%dc|r", strsub(value, -2))
    end
end
