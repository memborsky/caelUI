local F = select(1, unpack(select(2, ...)))

local strings = {
    ["cael"] = "|cffD7BEA5cael|r%s: ",
}

function F.print (addon, ...)
    print(strings.cael:format(addon), ...)
end

function F.error (...)
    print("Error", string.format(...))
end

function F.debug (...)
    print("Debug", string.format(...))
end

