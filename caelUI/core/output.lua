local private = unpack(select(2, ...))

local strings = {
    ["cael"] = "|cffD7BEA5cael|r%s: ",
}

function private.print (addon, ...)
    print(strings.cael:format(addon), ...)
end

local print = private.print

function private.error (...)
    print("Error", ...)
end

function private.debug (...)
    print("Debug", ...)
end
