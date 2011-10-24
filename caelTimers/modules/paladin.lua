--[[
Bar creation reference.

Create = function(spell_name, unit, buff_type, only_self, r, g, b, width, height, attach_point1, parent_frame1, relative_point1, x_offset1, y_offset1, attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2, hide_name)

spell_name:    Name of the buff/debuff.
unit:          Unit to monitor (player, target, focus, party1, etc)
buff_type:     Buff or debuff.
only_self:     If set to false, timer will always show if buff/debuff is present.  If set to true, timer will only show if you were the player who cast the buff/debuff.
r, g, b:       Color of the timer bar.  If nil, they will automatically color to aura type. (poison, curse, etc)
width, height: Width and height of the timer bar.

The first set of points positions the bar for your primary talent spec.
attach_point1:        Which point on the timer to use when positioning the bar.
parent_frame1:        Which frame to use when positioning the bar.  Normally UIParent.
relative_point1:      Which point of the parent_frame to use when positioning the bar.
x_offset1, y_offset1: X/Y offset values from the attach point.
attach_point2, parent_frame2, relative_point2, x_offset2, y_offset2: Secondary talent spec values.  You may enter 'nil' to use the same values as primary spec.

hide_name:   This will hide the name of the buff/debuff if set to true.  You may need to set this if your bar is too short to contain the name.

EVERYONE
    --Create("Well Fed", "player", "buff",    false, .4, .4, .4,    200, 10, "CENTER", UIParent, "CENTER", 0, 0)
    --Create("Toasty Fire",    "player", "buff",    false, .4, .4, .4,    200, 10, "CENTER", UIParent, "CENTER", 0, 0)

LEVELBASED
if caelUI.config.player.level == 80 then
end
--]]

if caelUI.config.player.class ~= "PALADIN" then return end

local _, caelTimers = ...

local Create = caelTimers.Create

local GetSpellName = caelUI.get_spell_name

-- 331
-- 316
-- 301
-- 286
-- 271
-- 256
-- 241
-- 226
-- 211
-- 196

-- Beaon of Light
Create("Beacon of Light", "focus", "buff", true, 0.31, 0.45, 0.63, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 316)

-- Judgements of the Pure
Create("Judgements of the Pure", "player", "buff", true, 0.31, 0.45, 0.63, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 301)

-- Conviction
Create("Conviction", "player", "buff", true, 0.31, 0.45, 0.63, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 271)

-- Daybreak
Create("Daybreak", "player", "buff", true, 0.31, 0.45, 0.63, 158, 10, "BOTTOM", UIParent, "BOTTOM", 0, 256)
