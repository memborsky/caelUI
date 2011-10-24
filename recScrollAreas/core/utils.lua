local pixel_scale = caelUI.config.pixel_scale

function recScrollAreas:CreateScrollArea(id, height, x_pos, y_pos, textalign, direction, font_face, font_size, font_flags, font_face_sticky, font_size_sticky, font_flags_sticky, animation_duration, animation_duration_sticky)
    recScrollAreas.scroll_area_frames[id] = CreateFrame("Frame", nil, UIParent)
    recScrollAreas.scroll_area_frames[id.."sticky"] = CreateFrame("Frame", nil, UIParent)
    -- Enable these two lines to see the scroll area on the screen for more accurate placement, etc
    -- recScrollAreas.scroll_area_frames[id]:SetBackdrop({ bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeFile = nil, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0} })
    -- recScrollAreas.scroll_area_frames[id]:SetBackdropColor(0, 0, 0, 1)

    -- Set frame width
    recScrollAreas.scroll_area_frames[id]:SetWidth(pixel_scale(1))
    recScrollAreas.scroll_area_frames[id.."sticky"]:SetWidth(pixel_scale(1))

    -- Set frame height
    recScrollAreas.scroll_area_frames[id]:SetHeight(pixel_scale(height))
    recScrollAreas.scroll_area_frames[id.."sticky"]:SetHeight(pixel_scale(height))

    -- Position frame
    recScrollAreas.scroll_area_frames[id]:SetPoint("BOTTOM", UIParent, "BOTTOM", pixel_scale(x_pos), pixel_scale(y_pos))
    recScrollAreas.scroll_area_frames[id.."sticky"]:SetPoint("BOTTOM", UIParent, "BOTTOM", pixel_scale(x_pos), pixel_scale(y_pos))

    -- Text alignment
    recScrollAreas.scroll_area_frames[id].textalign = textalign
    recScrollAreas.scroll_area_frames[id.."sticky"].textalign = textalign

    -- Scroll direction
    recScrollAreas.scroll_area_frames[id].direction = direction or "up"
    recScrollAreas.scroll_area_frames[id.."sticky"].direction = direction or "up"

    -- Font face
    recScrollAreas.scroll_area_frames[id].font_face = font_face or recScrollAreas.font_face
    recScrollAreas.scroll_area_frames[id.."sticky"].font_face = font_face_sticky or recScrollAreas.font_face_sticky

    -- Font size
    recScrollAreas.scroll_area_frames[id].font_size = font_size or recScrollAreas.font_size
    recScrollAreas.scroll_area_frames[id.."sticky"].font_size = font_size_sticky or recScrollAreas.font_size_sticky

    -- Font flags
    recScrollAreas.scroll_area_frames[id].font_flags = font_flags or recScrollAreas.font_flags
    recScrollAreas.scroll_area_frames[id.."sticky"].font_flags = font_flags_sticky or recScrollAreas.font_flags_sticky

    -- Create anim_string table
    recScrollAreas.anim_strings[id] = {}
    recScrollAreas.anim_strings[id.."sticky"] = {}

    -- Set movement speed
    recScrollAreas.scroll_area_frames[id].movement_speed = (animation_duration or recScrollAreas.animation_duration) / pixel_scale(height)
    recScrollAreas.scroll_area_frames[id.."sticky"].movement_speed = (animation_duration_sticky or recScrollAreas.animation_duration_sticky) / pixel_scale(height)

    -- Set animation duration
    recScrollAreas.scroll_area_frames[id].animation_duration = animation_duration or recScrollAreas.animation_duration
    recScrollAreas.scroll_area_frames[id.."sticky"].animation_duration = animation_duration_sticky or recScrollAreas.animation_duration_sticky
end
