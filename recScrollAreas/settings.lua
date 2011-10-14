-- Font Settings
recScrollAreas.font_face                    = caelUI.media.fonts.SCROLLFRAME_NORMAL
recScrollAreas.font_face_sticky             = caelUI.media.fonts.SCROLLFRAME_BOLD
recScrollAreas.font_flags                   = "OUTLINE"    -- Some text can be hard to read without it.
recScrollAreas.font_flags_sticky            = "OUTLINE"
recScrollAreas.font_size                    = 9
recScrollAreas.font_size_sticky             = 12

-- Animation Settings
recScrollAreas.blink_speed                  = 0.5
recScrollAreas.fade_in_time                 = 0.2   -- Percentage of the animation start spent fading in.
recScrollAreas.fade_out_time                = 0.8   -- At what percentage should we begin fading out.
recScrollAreas.animation_duration           = 5     -- Time it takes for an animation to complete. (in seconds)
recScrollAreas.animation_duration_sticky    = 2.5   -- Time it takes for a sticky animation to complete. (in seconds)
recScrollAreas.animations_per_scrollframe   = 15    -- Maximum number of displayed animations in each scrollframe.
recScrollAreas.animation_vertical_spacing   = 10    -- Minimum spacing between animations.
recScrollAreas.animation_speed              = 1     -- Modifies animation_duration.  1 = 100%
recScrollAreas.animation_delay              = 0.015 -- Frequency of animation updates. (in seconds)

-- Make your scroll areas
-- Format: recScrollAreas:CreateScrollArea(identifier, height, x_pos, y_pos, textalign, direction[, font_face][, font_size][, font_flags][, font_face_sticky][, font_size_sticky][, font_flags_sticky][, animation_duration][, animation_duration_sticky])
-- Frames are relative to BOTTOM UIParent BOTTOM
--
-- Then you can pipe input into each scroll area using:
-- recScrollAreas:AddText(text_to_show, sticky_style, scroll_area_identifer)
--
recScrollAreas:CreateScrollArea("Error", 75, 0, 750, "CENTER", "up", nil, nil, nil, nil, nil, nil, 2.5, 2.5)
recScrollAreas:CreateScrollArea("Notification", 110, 0, 585, "CENTER", "down", nil, nil, nil, nil, nil, nil, 3.5, 3.5)
recScrollAreas:CreateScrollArea("Information", 100, 0, 160, "CENTER", "down", nil, nil, nil, nil, nil, nil, 2.5, 1.25)
recScrollAreas:CreateScrollArea("Outgoing", 150, 162.5, 385, "LEFT", "up")
recScrollAreas:CreateScrollArea("Incoming", 150, -162.5, 385, "RIGHT", "down")
