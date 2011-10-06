local F = select(1, unpack(select(2, ...)))

function F.is_in (needle, haystack)
    if type(haystack) == "table" then
        for key, value in pairs(haystack) do
            if key == needle then
                return true
            elseif value == needle then
                return true
            end
        end
    elseif type(needle) == type(haystack) and type(needle) == "string" then
        -- ZZZ: Parse the string to see if needle is in haystack.
        --return true
        nil
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
function F.explode (text, delimiter)
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
@param  num     num     This is the argument number in the list. The numbering should start at 1.
--]]
function F.argcheck (value, num, ...)
    assert(type(num) == 'number', "Bad argument #2 to 'argcheck' (number expected, got " .. type(num) .. ")")

    for index = 1, select("#", ...) do
        if type(value) == select(index, ...) then
            return
        end
    end

    local types = strjoin(", ", ...)
    local name = string.match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
    F.error(("Bad argument #%d to '%s' (%s expected, got %s"):format(num, name, types, type(value)), 3)
end
