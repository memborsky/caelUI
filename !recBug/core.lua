--[[    $Id$    ]]
----------------------------------------
-- NOTE:
-- You probably do not have this stuff set, as it is from recMedia.
-- If not, you need to uncomment the following 3 lines and set your own font and edge file.
----------------------------------------
-- local font = CreateFont("Oceania")
-- font:SetFont([[Interface\AddOns\Media\Fonts\SomeFont.ttf]], 11, nil)

local errors = {}

local function make_backdrop(frame)
    frame.bg = CreateFrame("Frame", nil, frame)
    frame.bg:SetPoint("TOPLEFT")
    frame.bg:SetPoint("BOTTOMRIGHT")
    if caelUI then
        frame.bg:SetBackdrop({
            bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
            edgeFile = [=[Interface\Addons\caelUI\media\borders\glowtex3]=], edgeSize = 2,
            insets = {left = 3, right = 3, top = 3, bottom = 3}
        })
    end
    frame.bg:SetFrameStrata("BACKGROUND")
    frame.bg:SetBackdropColor(0, 0, 0, .5)
    frame.bg:SetBackdropBorderColor(0, 0, 0)
end

local error_frame = CreateFrame("Frame", "recBug")

local function make_button(name, text)
    local button = CreateFrame("Button", name, error_frame)
    button:SetHeight(28)
    button:SetWidth(28)
    button:SetNormalFontObject(NumberFont_Shadow_Small)
    button:SetText(text)
    make_backdrop(button)
    return button
end
error_frame:Hide()
error_frame:SetHeight(280)
error_frame:SetWidth(500)
error_frame:SetPoint("CENTER")
error_frame:SetFrameStrata("TOOLTIP")
error_frame.closed = false
error_frame.notified = false
make_backdrop(error_frame)

local close_button = make_button("recBug_Close", "X")
close_button:SetPoint("TOPRIGHT", error_frame, "TOPRIGHT")
close_button:SetScript("OnClick", function(self)
    self:GetParent().closed = true
    self:GetParent().notified = false
    self:GetParent():Hide()
end)

local next_button = make_button("recBug_Next", ">>")
next_button:SetPoint("RIGHT", close_button, "LEFT")
next_button:SetScript("OnClick", function(self) self:GetParent():Hide() end)

local previous_button = make_button("recBug_Previous", "<<")
previous_button:SetPoint("RIGHT", next_button, "LEFT")
previous_button:SetScript("OnClick", function(self) self:GetParent():Hide() end)

local error_scroll = CreateFrame("ScrollFrame", "recBug_Scroll", error_frame, "UIPanelScrollFrameTemplate")
error_scroll:SetPoint("TOPLEFT", error_frame, "TOPLEFT", 20, -20)
error_scroll:SetPoint("RIGHT", error_frame, "RIGHT", -30, 0)

local output_frame = CreateFrame("EditBox", "recBug_Edit", error_scroll)
output_frame:SetWidth(450)
output_frame:SetHeight(85)
output_frame:SetPoint("CENTER")
output_frame:SetMultiLine(true)
output_frame:SetAutoFocus(false)
output_frame:SetFontObject(NumberFont_Shadow_Small)
output_frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
error_scroll:SetScrollChild(output_frame)

local NULL_FRAME = { GetName = function() return "Global" end }
local UNNAMED = "Unnamed"
local ANONYMOUS = "Anonymous"
local NULL_MESSAGE = ""

local function show_error(index)
    if errors[index] then
        local message = errors[index].message:gsub("(.-):(%d+): ", "%1 line %2:\n   "):gsub("Interface(\\%w+\\)", "..%1"):gsub(": in function `(.-)`", ": %1"):gsub("|", "||"):gsub("{{{", "|cffff8855"):gsub("}}}", "|r")
        local stack = "   "..errors[index].stack:gsub("Interface\\AddOns\\", ""):gsub("Interface(\\%w+\\)", "..%1"):gsub(": in function `(.-)'", ": %1()"):gsub(": in function <(.-)>", ":\n   %1"):gsub(": in main chunk ", ": "):gsub("\n$",""):gsub("\n", "\n   ")
        output_frame:SetText(
        string.format(
        "|cffff5533ID:|r %s\n|cffff5533Error occured in:|r %s\n|cffff5533Message:|r\n%s\n|cffff5533Debug:|r\n%s\n",
        index or "nil",
        errors[index].frame_name or "nil",
        message or "nil",
        stack or "nil"
        )
        )
        next_button.id = index + 1
        if not errors[next_button.id] then
            next_button:Disable()
            next_button:SetAlpha(.25)
        else
            next_button:Enable()
            next_button:SetAlpha(1)
        end
        previous_button.id = index - 1
        if not errors[previous_button.id] then
            previous_button:Disable()
            previous_button:SetAlpha(.25)
        else
            previous_button:Enable()
            previous_button:SetAlpha(1)
        end
        error_scroll:UpdateScrollChildRect()
        output_frame:ClearFocus()
        if (not error_frame:IsShown()) and (not error_frame.closed) then
            error_frame:Show()
        elseif error_frame.closed and (not error_frame.notified) then
            print("recBug: An error has occurred. /bug or /recbug to show")
            error_frame.notified = true
        end
    end
end

next_button:SetScript("OnClick", function(self) show_error(self.id) end)
previous_button:SetScript("OnClick", function(self) show_error(self.id) end)

local function on_error(message, frame, stack, etype, ...)
    message = message or NULL_MESSAGE
    frame = frame or NULL_FRAME
    stack = stack or debugstack(2, 20, 20)
    local frame_name = (frame and frame.GetName and frame:GetName()) or (frame and UNNAMED) or ANONYMOUS
    tinsert(errors, {
        frame_name = frame_name,
        message = message,
        stack = stack,
    })
    show_error(1)
end

seterrorhandler(on_error)

local function on_event(self, event, ...)
    if event == "ADDON_ACTION_BLOCKED" then
        local addon, func = ...
        if InCombatLockdown() then
            on_error(
            string.format("%s attempted to call a protected function (%s) during combat lockdown.", addon, func),
                string.format("addon: %s", addon),
                debugstack(2, 20, 20),
                event,
                ...)
            else
                on_error(
                string.format("%s attempted to call a protected function (%s) which may require interaction.", addon, func),
                    string.format("addon: %s", addon),
                    debugstack(2, 20, 20),
                    event,
                    ...)
                end
            elseif (event == "ADDON_ACTION_FORBIDDEN") then
                local addon, func = ...
                on_error(
                string.format("%s attempted to call a forbidden function (%s) from a tainted execution path.", addon, func),
                    string.format("addon: ", addon),
                    debugstack(2, 20, 20),
                    event,
                    ...)
                elseif (event == "PLAYER_ENTERING_WORLD") then
                    if #errors and #errors > 0 then
                        show_error(1)
                    end
                end
            end

            output_frame:SetScript("OnEvent", on_event)
            output_frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
            output_frame:RegisterEvent("ADDON_ACTION_BLOCKED")
            output_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
            UIParent:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
            UIParent:UnregisterEvent("ADDON_ACTION_BLOCKED")

            SLASH_RECBUG1 = "/bug"
            SLASH_RECBUG2 = "/recbug"
            SlashCmdList["RECBUG"] = function()
                error_frame.closed = false
                error_frame:Show()
            end
