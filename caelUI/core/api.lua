local private, public = unpack(select(2, ...))

-- Allow external addons to have access to the media database.
public.media = private.media

-- Allow exteranl addons to have access to the config database.
public.config = private.GetDatabase("config")

-- XXX: Hacking around the change we made internally for PixelScale to make sure everything works inside first.
public.config.PixelScale = private.PixelScale

-- Allow the usage of specific functions from our private API interface.
public.UTF8_substitution = private.UTF8_substitution
public.GetSpellName = private.GetSpellName
public.kill = private.kill

do
    local function addapi(object)
        local metatable = getmetatable(object).__index
        if not object.Kill then metatable.Kill = private.kill end
    end

    local handled = {["Frame"] = true}
    local object = CreateFrame("Frame")
    addapi(object)
    addapi(object:CreateTexture())
    addapi(object:CreateFontString())

    object = EnumerateFrames()
    while object do
        if not handled[object:GetObjectType()] then
            addapi(object)
            handled[object:GetObjectType()] = true
        end

        object = EnumerateFrames(object)
    end
end