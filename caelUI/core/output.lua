local P = select(2, unpack(select(2, ...)))

local strings = {
    ["cael"] = "|cffD7BEA5cael|r%s: ",
}

function P.print (addon, ...)
    print(strings.cael:format(addon), ...)
end

function P.error (...)
    print("Error", string.format(...))
end

function P.debug (...)
    print("Debug", string.format(...))
end
