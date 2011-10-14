local last_use = 0

local function CollisionCheck(newtext)
    local destination_scroll_area = recScrollAreas.anim_strings[newtext.scrollarea]
    local current_animations = #destination_scroll_area
    if current_animations > 0 then -- Only if there are already animations running

        -- Scale the per pixel time based on the animation speed.
        local perPixelTime = recScrollAreas.scroll_area_frames[newtext.scrollarea].movement_speed / newtext.animationSpeed
        local curtext = newtext -- start with our new string
        local previoustext, previoustime

        -- cycle backwards through the table of fontstrings since our newest ones have the highest index
        for x = current_animations, 1, -1 do
            previoustext = destination_scroll_area[x]

            if not newtext.sticky then
                -- Calculate the elapsed time for the top point of the previous display event.
                -- TODO: Does this need to be changed since we anchor LEFT and not TOPLEFT?
                previoustime = previoustext.totaltime - (previoustext.fontSize + recScrollAreas.animation_vertical_spacing) * perPixelTime

                --[[If there is a collision, then we set the older fontstring to a higher animation time
                Which 'pushes' it upward to make room for the new one--]]
                if (previoustime <= curtext.totaltime) then
                    previoustext.totaltime = curtext.totaltime + (previoustext.fontSize + recScrollAreas.animation_vertical_spacing) * perPixelTime
                else
                    return -- If there was no collision, then we can safely stop checking for more of them
                end
            else
                previoustext.curpos = previoustext.curpos + (previoustext.fontSize + recScrollAreas.animation_vertical_spacing)
            end

            -- Check the next one against the current one
            curtext = previoustext
        end
    end
end

local blink_id = 0
local make_blink_group = function(self) 
    blink_id = blink_id + 1
    self.anim = self:CreateAnimationGroup("Blink"..blink_id) 
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn") 
    self.anim.fadein:SetChange(1) 
    self.anim.fadein:SetOrder(2) 

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut") 
    self.anim.fadeout:SetChange(-1) 
    self.anim.fadeout:SetOrder(1) 
end 

local start_blinking = function(self, duration) 
    if not self.anim then 
        make_blink_group(self) 
    end 

    self.anim.fadein:SetDuration(duration) 
    self.anim.fadeout:SetDuration(duration) 
    self.anim:Play() 
end 

local stop_blinking = function(self) 
    if self.anim then 
        self.anim:Finish() 
    end 
end 

local function Move(self, elapsed)
    local t
    -- Loop through all active fontstrings
    for k,v in pairs(recScrollAreas.anim_strings) do

        for l,u in pairs(recScrollAreas.anim_strings[k]) do
            t = recScrollAreas.anim_strings[k][l]

            if t and t.inuse then
                --increment it's timer until the animation delay is fulfilled
                t.timer = (t.timer or 0) + elapsed
                if t.timer >= recScrollAreas.animation_delay then

                    --[[we store it's elapsed time separately so we can continue to delay
                    its animation (so we're not updating every onupdate, but can still
                    tell what its full animation duration is)--]]
                    t.totaltime = t.totaltime + t.timer

                    --[[If the animation is not complete, then we need to animate it by moving
                    its Y coord (in our sample scrollarea) the proper amount.  If it is complete,
                    then we hide it and flag it for recycling --]]
                    local percentDone = t.totaltime / recScrollAreas.scroll_area_frames[t.scrollarea].animation_duration
                    if (percentDone <= 1) then
                        t.text:ClearAllPoints()
                        local area_height = recScrollAreas.scroll_area_frames[t.scrollarea]:GetHeight()
                        if not t.sticky then
                            -- Scroll the text
                            if recScrollAreas.scroll_area_frames[t.scrollarea].direction == "up" then
                                t.curpos = area_height * percentDone -- move up
                            else
                                t.curpos = area_height - (area_height * percentDone)
                            end
                            t.text:SetPoint(recScrollAreas.scroll_area_frames[t.scrollarea].textalign, recScrollAreas.scroll_area_frames[t.scrollarea], "BOTTOMLEFT", 0, t.curpos)
                        else
                            -- Static text
                            if t.curpos > area_height/2 then t.totaltime = 99 end
                            t.text:SetPoint(recScrollAreas.scroll_area_frames[t.scrollarea].textalign, recScrollAreas.scroll_area_frames[t.scrollarea], recScrollAreas.scroll_area_frames[t.scrollarea].textalign, 0, t.curpos)
                        end

                        -- Blink text
                        if t.sticky and t.blink then
                            if not t.blinking then
                                t.text:SetAlpha(1)
                                t.blinking = true
                            end
                            start_blinking(t.text, recScrollAreas.blink_speed)
                        elseif (percentDone <= recScrollAreas.fade_in_time) then
                            -- Fade in
                            --if (percentDone <= recScrollAreas.fade_in_time) then
                            t.text:SetAlpha(1 * (percentDone / recScrollAreas.fade_in_time))
                            -- Fade out
                        elseif (percentDone >= recScrollAreas.fade_out_time) then
                            t.text:SetAlpha(1 * (1 - percentDone) / (1 - recScrollAreas.fade_out_time))
                            -- Full vis for times inbetween
                        else
                            t.text:SetAlpha(1)
                        end
                    else
                        -- /script recScrollAreas:AddText("Kill Shot", true, "Notification", true)
                        if t.blink then
                            stop_blinking(t.text)
                            t.blink  = false
                            t.blinking = false
                        end
                        t.text:Hide()
                        t.inuse = false
                    end

                    t.timer = 0        --reset our animation delay timer
                end
            end

            --[[Now, we loop backwards through the fontstrings to determine which ones
            can be recycled --]]
            for j = #recScrollAreas.anim_strings[k], 1, -1 do
                t = recScrollAreas.anim_strings[k][j]
                if not t.inuse then
                    table.remove(recScrollAreas.anim_strings[k], j)
                    -- Place the used frame into our recycled cache
                    recScrollAreas.empty_strings[(#recScrollAreas.empty_strings or 0) + 1] = t.text
                    for key in next, t do t[key] = nil end
                    recScrollAreas.empty_tables[(#recScrollAreas.empty_tables or 0)+1] = t
                end
            end
        end
    end
end

function recScrollAreas:AddText(text, sticky, scrollarea, blink)
    if not text or not scrollarea then return end
    local destination_area
    if not sticky then
        destination_area = recScrollAreas.anim_strings[scrollarea]
    else
        destination_area = recScrollAreas.anim_strings[scrollarea.."sticky"]
    end
    if not destination_area then return end
    local t
    -- If there are too many frames in the animation area, steal one of them first
    if (destination_area and (#destination_area or 0) >= recScrollAreas.animations_per_scrollframe) then
        t = table.remove(destination_area, 1)

        -- If there are frames in the recycle bin, then snatch one of them!
    elseif (#recScrollAreas.empty_tables or 0) > 0 then
        t = table.remove(recScrollAreas.empty_tables, 1)

        -- If we still don't have a frame, then we'll just have to create a brand new one
    else
        t = {}
    end
    if not t.text then
        t.text = table.remove(recScrollAreas.empty_strings, 1) or recScrollAreas.event_frame:CreateFontString(nil, "BORDER")
    end

    -- Settings which need to be set/reset on each fontstring after it is created/obtained
    if sticky then
        t.fontSize = recScrollAreas.scroll_area_frames[scrollarea.."sticky"].font_size
    else
        t.fontSize = recScrollAreas.scroll_area_frames[scrollarea].font_size
    end
    t.sticky = sticky
    if blink then
        t.blink = true
        t.blinking = false
    else
        t.blink = false
        t.blinking = false
    end
    t.text:SetFont(sticky and recScrollAreas.scroll_area_frames[scrollarea.."sticky"].font_face or recScrollAreas.scroll_area_frames[scrollarea].font_face, t.fontSize, sticky and recScrollAreas.scroll_area_frames[scrollarea.."sticky"].font_flags or recScrollAreas.scroll_area_frames[scrollarea].font_flags)
    t.text:SetText(text)
    t.direction = destination_area.direction
    t.inuse = true
    t.timer = 0
    t.totaltime = 0
    t.curpos = 0
    t.text:ClearAllPoints()
    if t.sticky then
        t.text:SetPoint(recScrollAreas.scroll_area_frames[scrollarea.."sticky"].textalign, recScrollAreas.scroll_area_frames[scrollarea.."sticky"], recScrollAreas.scroll_area_frames[scrollarea.."sticky"].textalign, 0, 0)
        t.text:SetDrawLayer("OVERLAY") -- on top of normal texts.
    else
        t.text:SetPoint(recScrollAreas.scroll_area_frames[scrollarea].textalign, recScrollAreas.scroll_area_frames[scrollarea], "BOTTOMLEFT", 0, 0)
        t.text:SetDrawLayer("ARTWORK")
    end
    t.text:SetAlpha(0)
    t.text:Show()
    t.animationSpeed = recScrollAreas.animation_speed
    t.scrollarea = t.sticky and scrollarea.."sticky" or scrollarea

    -- Make sure that adding this fontstring will not collide with anything!
    CollisionCheck(t)

    -- Add the fontstring into our table which gets looped through during the OnUpdate
    destination_area[#destination_area+1] = t
    last_use = 0
end

local function OnUpdate(s,e)
    Move(s, e)
    -- Keep footprint down by releasing stored tables and strings after we've been idle for a bit.
    last_use = last_use + e
    if last_use > 30 then
        if #recScrollAreas.empty_tables and #recScrollAreas.empty_tables > 0 then
            recScrollAreas.empty_tables = {}
        end
        if #recScrollAreas.empty_strings and #recScrollAreas.empty_strings > 0 then
            recScrollAreas.empty_strings = {}
        end
        last_use = 0
    end
end
recScrollAreas.event_frame = CreateFrame("Frame")
recScrollAreas.event_frame:SetScript("OnUpdate", OnUpdate)
