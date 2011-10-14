local private = unpack(select(2, ...))

local strings = {
    ["cael"] = "|cffD7BEA5cael|r%s: ",
}

function private.print (addon, ...)
    print(strings.cael:format(addon), ...)
end

function private.error (...)
    print("Error", string.format(...))
end

function private.debug (...)
    print("Debug", string.format(...))
end
