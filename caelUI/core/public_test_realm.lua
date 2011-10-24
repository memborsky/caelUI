local private = unpack(select(2, ...))

--[[
Original version from Elv22 at http://github.com/Elv22/Tukui
Check to see if the UI is loaded on the PTR server

@return boolean True for PTR server
--]]
function private.ptr_check ()
    local version = select(2, GetBuildInfo())

    if tonumber(version) > 14732 then
        return true
    else
        return false
    end
end
