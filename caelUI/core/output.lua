local private = unpack(select(2, ...))

local strings = {
    ["cael"] = "|cffD7BEA5cael|r%s: ",
}

function private.print (addon, ...)
    print(strings.cael:format(addon), ...)
end

function private.error (...)
    private.print("Error", ...)
end

function private.debug (...)
    private.print("Debug", ...)
end
