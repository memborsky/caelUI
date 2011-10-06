local F, DB, M = unpack(select(2, ...))

--[[
Check to see if the UI is loaded on the PTR server

@return boolean True for PTR server
--]]
function F.OnThePTR ()
    local _, version = GetBuildInfo()

    if tonumber(version) > 14732 then
        return true
    else
        return false
    end
end

