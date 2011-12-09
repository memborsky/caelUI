local _, caelChat = ...

local _G = getfenv(0)

_G["caelChat"] = caelChat

FCF_ResetChatWindows() -- This should fix issues with the Dimension problems a while ago in the chat-config.txt

caelChat.eventFrame = CreateFrame("Frame", nil, UIParent)

-- Local the global
local caelUI = caelUI

local media = caelUI.media
local PixelScale = caelUI.config.PixelScale
local playerClass = caelUI.config.player.class

local kill = caelUI.kill

CHAT_TELL_ALERT_TIME = 0 -- sound on every whisper
DEFAULT_CHATFRAME_ALPHA = 0 -- remove mouseover background

-- Hides the new Friends button next to the chatbox (possibly temporary)
FriendsMicroButton:Hide()

local function KillTextures(chatName)
    local chatTabName = chatName .. "Tab"
    local chatEditBoxName = chatName .. "EditBox"
    local chatButtonFrame = chatName .. "ButtonFrame"

    -- Remove junk from the bottom of the chat frame to allow it to move to the bottom of the screen.
    _G[chatName]:SetClampRectInsets(0, 0, 0, 0)
    _G[chatName]:SetClampedToScreen(false)

    -- nil out chat frame textures
    for index = 1, #CHAT_FRAME_TEXTURES do
        _G[chatName .. CHAT_FRAME_TEXTURES[index]]:SetTexture(nil)
    end

    -- Kill the chat tab
    kill(_G[chatTabName])

    -- Kill off Left/Middle/Right regioned textures.
    do
        local regions = {"Left", "Middle", "Right"}

        for _, region in pairs(regions) do
            -- Kill off ChatFrame#Tab textures
            -- normal
            kill(_G[chatTabName .. region])

            -- selected
            kill(_G[chatTabName .. "Selected" .. region])

            -- highlight
            kill(_G[chatTabName .. "Highlight" .. region])

            -- selected
            kill(_G[chatTabName .. "Selected" .. region])

            -- Because Blizzard can't keep common naming conventions, we are going to use
            -- this little if check to force "Mid" instead of Middle for the left texture
            if region == "Middle" then
                kill(_G[chatEditBoxName .. "FocusMid"])
                kill(_G[chatEditBoxName .. "Mid"])
            else
                kill(_G[chatEditBoxName .. "Focus" .. region])
                kill(_G[chatEditBoxName .. region])
            end

        end
    end

    -- Kill default chat frame tab glow
    kill(_G[chatTabName .. "Glow"])

    -- Kill chat frame buttons
    kill(_G[chatButtonFrame .. "UpButton"])
    kill(_G[chatButtonFrame .. "DownButton"])
    kill(_G[chatButtonFrame .. "BottomButton"])
    kill(_G[chatButtonFrame .. "MinimizeButton"])
    kill(_G[chatButtonFrame])


    -- Disable alt key usage
    _G[chatEditBoxName]:SetAltArrowKeyMode(false)
end


local colorize = function(r, g, b)
    caelPanel_EditBox:SetBackdropBorderColor(r, g, b)
end

-- Handle the color changes to the chatbox edit frame panel (caelPanel_EditBox)
hooksecurefunc("ChatEdit_UpdateHeader", function(editbox)

    local type = editbox:GetAttribute("chatType")
    local color = ChatTypeInfo[type] or {['r'] = 0.1, ['g'] = 0.1, ['b'] = 0.1}

    if (type == "CHANNEL") then
        local channel, channelName = GetChannelName(editbox:GetAttribute("channelTarget"))

        if (channelName and (channel > 0)) then
            color = ChatTypeInfo[type .. channel]
        end
    end

    colorize(color.r, color.g, color.b)
end)

local mergedTable = {
    -- coloredChats values only
    [0] = "CHANNEL5",

    -- Values which coloredChats and messageGroups have in common.
    [1] = "SAY",
    [2] = "EMOTE",
    [3] = "YELL",
    [4] = "GUILD",
    [5] = "OFFICER",
    [6] = "GUILD_ACHIEVEMENT",
    [7] = "WHISPER",
    [8] = "PARTY",
    [9] = "PARTY_LEADER",
    [10] = "RAID",
    [11] = "RAID_LEADER",
    [12] = "RAID_WARNING",
    [13] = "BATTLEGROUND",
    [14] = "BATTLEGROUND_LEADER",
    [15] = "ACHIEVEMENT",

    -- MessageGroups only.
    [16] = "BN_WHISPER",
    [17] = "BN_CONVERSATION",
    [18] = "MONSTER_SAY",
    [19] = "MONSTER_EMOTE",
    [20] = "MONSTER_YELL",
    [21] = "MONSTER_WHISPER",
    [22] = "MONSTER_BOSS_EMOTE",
    [23] = "MONSTER_BOSS_WHISPER",
    [24] = "BG_HORDE",
    [25] = "BG_ALLIANCE",
    [26] = "BG_NEUTRAL",
    [27] = "SYSTEM",
    [28] = "ERRORS",
    [29] = "IGNORED",
    [30] = "CHANNEL",
}

-- Container frame for tab buttons
local cftbb = CreateFrame("Frame", "ChatButtonBar", UIParent)

-- Make chat tab flash.
local FlashTab = function(tab, start)
    if start and tab.flash:IsShown() then
        return
    elseif not start and not tab.flash:IsShown() then
        return
    elseif start then
        tab.flash:SetAlpha(0)
        tab.flash.elapsed = 0
        tab.flash:Show()
    else
        tab.flash:Hide()
    end
end

-- FCF override funcs
local GetCurrentChatFrame = function(...)
    -- Gets the chat frame which should be currently shown.
    return _G[format("ChatFrame%s", ChatButtonBar.id)]
end

local GetChatFrameID = function(...)
    -- Gets the current chat frame's id.
    return ChatButtonBar.id
end

caelChat.GetChatFrameEditBox = function(...)
    -- Gets the current chat frame edit box which should be currently active
    return _G[format("ChatFrame%sEditBox", GetChatFrameID())]
end

local ShowChatFrame = function(self)
    -- Set required id variables.
    ChatButtonBar.id = self.id
    SELECTED_CHAT_FRAME = _G[format("ChatFrame%s", self.id)]

    -- Hide all chat frames
    for i = 1, 4 do
        if i ~= 2 then
            _G[format("ChatButton%s", i)]:SetBackdropColor(0, 0, 0, 0.33)
            _G[format("ChatFrame%s", i)]:Hide()
            _G[format("ChatFrame%sEditBox", i)]:Hide()
        end
    end

    -- Make sure tab is not flashing (stop on click)
    FlashTab(self)

    -- Change our tab to a colored version so the user can see which tab is selected.
    self:SetBackdropColor(0.84, 0.75, 0.65, 0.5)

    _G[format("ChatFrame%s", self.id)]:Show()
    _G[format("ChatFrame%sEditBox", self.id)]:Show()

    _G[format("ChatFrame%sEditBox", self.id)]:SetFocus()
    _G[format("ChatFrame%sEditBox", self.id)]:ClearFocus()
end

local ctddm = CreateFrame("Frame", "ChatTabDropDown")
ctddm.displayMode = "MENU"
ctddm.info = {}
ctddm.initialize = function(self, level)
    local info = self.info
    local id = self.id

    if level == 1 then
        wipe(info)
        info.text = "Config"
        info.notCheckable = 1
        info.hasArrow = false
        info.func = function() ShowUIPanel(ChatConfigFrame) end
        UIDropDownMenu_AddButton(info, level)
        wipe(info)
        info.text = "Font Size"
        info.notCheckable = 1
        info.hasArrow = true
        info.value = "FONTSIZE"
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == "FONTSIZE" then
            for _, size in pairs(CHAT_FONT_HEIGHTS) do
                wipe(info)
                info.text = format(FONT_SIZE_TEMPLATE, size)
                info.value = size
                info.func = function()
                    FCF_SetChatWindowFontSize(self, _G[format("ChatFrame%s", id)], size)
                end
                local _, currentSize, _ = _G[format("ChatFrame%s", id)]:GetFont()
                if size == floor(currentSize+.5) then
                    info.checked = 1
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

caelChat.eventFrame:RegisterEvent("ADDON_LOADED")
caelChat.eventFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" then
        if addon == "Blizzard_CombatLog" then
            ChatConfigFrame_OnEvent(nil, "PLAYER_ENTERING_WORLD", addon)
            caelChat.eventFrame:UnregisterEvent("ADDON_LOADED")
            for i = 1, NUM_CHAT_WINDOWS do 
                local frame = _G[format("ChatFrame%s", i)]
                local cfeb = _G[format("ChatFrame%sEditBox", i)]
                local cfebh = _G[format("ChatFrame%sEditBoxHeader", i)]
                local cft = _G[format("ChatFrame%sTab", i)]
                local cftf = _G[format("ChatFrame%sTabFlash", i)]

                -- Kill off all the chat frame/tab/editbox textures.
                KillTextures(frame:GetName())

                frame:SetFading(true)
                frame:SetFadeDuration(5)
                frame:SetTimeVisible(30)

                -- Change the positions of the chatframes and editboxes.
                if i ~= 2 then
                    frame:ClearAllPoints()
                    --frame:SetAllPoints(caelPanel_ChatFrame)
                    frame:SetWidth(caelPanel_ChatFrame:GetWidth() - PixelScale(10))
                    frame:SetHeight(caelPanel_ChatFrame:GetHeight() - PixelScale(5))
                    frame:SetPoint("TOPLEFT", caelPanel_ChatFrame, "TOPLEFT", PixelScale(5), PixelScale(-5))
                    frame:SetPoint("BOTTOMRIGHT", caelPanel_ChatFrame, "BOTTOMRIGHT", PixelScale(-5), PixelScale(5))
                    frame:SetMaxLines(1500)
                    --frame.SetPoint = function() end

                    cfeb:ClearAllPoints()
                    cfeb:SetHeight(20)
                    cfeb:SetAllPoints(caelPanel_EditBox)
                    cfeb:SetMaxLetters(99999)
                    cfeb:SetAutoFocus(false)
                    cfeb:EnableMouse(true)
                    cfeb:SetFont(media.fonts.normal, 12)
                    cfebh:SetPoint("LEFT", caelPanel_EditBox, PixelScale(5), PixelScale(1))
                    cfebh:SetFont(media.fonts.normal, 12)

                    -- Hide editbox on load
                    cfeb:Hide()
                    caelPanel_EditBox:Hide()

                    -- Show/Hide editbox
                    cfeb:HookScript("OnEditFocusGained", function(self) self:Show() caelPanel_EditBox:Show() end)
                    cfeb:HookScript("OnEditFocusLost", function(self) self:Hide() caelPanel_EditBox:Hide() end)

                    -- Redock the frames together.
                    if (i == 1) then
                        FCF_DockFrame(frame, frame:GetID())
                    else
                        FCF_DockFrame(frame, frame:GetID()-1)
                    end

                    -- Save chat position and dimension to combat the blizzard 3.3.5 bug with DIMENSION and POSITION in chat-config.txt
                    FCF_SavePositionAndDimensions(frame)
                end

                -- Setup the chatframes

                --[[
                
                if isCharListA then
                    ChatFrame_RemoveAllChannels(frame)
                    ChatFrame_RemoveAllMessageGroups(frame)
                end
                --]]

                if i == 1 then
                    FCF_SetWindowName(frame, "• Gen •")

                    --[[
                    -- XXX: We are removing all usage of isCharListA and myChars due to globalization of the UI.
                    if isCharListA then
                        for i = 0, 30 do
                            if i < 16 then -- Everything up to 15
                                ToggleChatColorNamesByClassGroup(true, mergedTable[i])
                            end
                            if i > 0 then -- Everything except index 0
                                ChatFrame_AddMessageGroup(frame, mergedTable[i])
                            end
                        end
                    end
                    --]]
                elseif i == 2 then
                    FCF_SetWindowName(frame, "• Log •")
                    FCF_UnDockFrame(frame)
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", caelPanel_CombatLog, "TOPLEFT", PixelScale(5), PixelScale(-30))
                    frame:SetPoint("BOTTOMRIGHT", caelPanel_CombatLog, "BOTTOMRIGHT", PixelScale(-5), PixelScale(-10))
                    frame.SetPoint = function() end
                    FCF_SetTabPosition(frame, 0)
                    frame:SetJustifyH("RIGHT")
                    frame:Hide()
                    frame:UnregisterEvent("COMBAT_LOG_EVENT")
                elseif i == 3 then
                    FCF_SetWindowName(frame, "• w <-> •")

                    ChatFrame_AddMessageGroup(frame, "WHISPER")
                    ChatFrame_AddMessageGroup(frame, "WHISPER_INFORM")
                    ChatFrame_AddMessageGroup(frame, "BN_WHISPER")
                    ChatFrame_AddMessageGroup(frame, "BN_WHISPER_INFORM")
                elseif i == 4 then
                    FCF_SetWindowName(frame, "• Loot •")

                    ChatFrame_AddMessageGroup(frame, "LOOT")
                    ChatFrame_AddMessageGroup(frame, "MONEY")
                else
                    frame.isInitialized = 0
                    FCF_SetTabPosition(frame, 0)
                    FCF_Close(frame)
                    FCF_UnDockFrame(frame)
                    FCF_SetWindowName(frame, "")
                    ChatFrame_RemoveAllMessageGroups(frame)
                    ChatFrame_RemoveAllChannels(frame)
                end

                -- save original function to alternate name
                cfeb.oldSetTextInsets = cfeb.SetTextInsets
                -- override function to modify values.
                cfeb.SetTextInsets = function(self, left, right, top, bottom)
                    left = PixelScale(left - 10)
                    top = PixelScale(top - 2)
                    -- call original function
                    cfeb.oldSetTextInsets(self, left, right, top, bottom)
                end

                cfeb:HookScript("OnEscapePressed", function()
                    caelPanel_EditBox:SetBackdropColor(0.1, 0.1, 0.1)
                    caelPanel_EditBox:SetBackdropBorderColor(0, 0, 0)
                end)

                if i < 5 then
                    --FCF_SetChatWindowFontSize(nil, frame, 9)
                    FCF_SetWindowColor(frame, 0, 0, 0)
                    FCF_SetWindowAlpha(frame, 0)
                    frame:SetFrameStrata("LOW")
                    --FCF_SetLocked(frame, 1)
                    if i ~= 2 then frame:Show() end
                end
            end

            -- Custom chat tabs
            local MakeButton = function(id, txt, tip)
                local btn = CreateFrame("Button", format("ChatButton%s", id), cftbb)
                btn.id = id
                btn:SetSize(PixelScale(30), PixelScale(20))
                -- If you want them to only show on_enter
                --btn:SetScript("OnEnter", function(...) ChatButtonBar:SetAlpha(1) end)
                --btn:SetScript("OnLeave", function(...) ChatButtonBar:SetAlpha(0) end)
                btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")
                btn:SetScript("OnClick", function(self, button, ...)
                    if button == "RightButton" then
                        if self.id == ChatButtonBar.id then
                            ChatTabDropDown.id = self.id
                            ToggleDropDownMenu(1, nil, ChatTabDropDown, "cursor")
                        end
                    else
                        ShowChatFrame(self)
                    end
                end)
                btn:SetScript("OnEnter", function(self)
                    --GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, PixelScale(3))
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                    GameTooltip:AddLine(tip)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                btn.t = btn:CreateFontString(nil, "OVERLAY")
                btn.t:SetFont(media.fonts.normal, 9)
                btn.t:SetPoint("CENTER", 0, PixelScale(1))
                btn.t:SetTextColor(1, 1, 1)
                btn.t:SetText(txt)

                btn:SetBackdrop(media.backdrop_table)
                btn:SetBackdropColor(0.1, 0.1, 0.1, 0)
                btn:SetBackdropBorderColor(0.1, 0.1, 0.1)

                -- Create the flash frame
                btn.flash = CreateFrame("Frame", format("ChatButton%sFlash", id), btn)
                btn.flash:SetAllPoints()
                btn.flash:SetBackdrop(media.backdrop_table)
                btn.flash:SetBackdropColor(0.69, 0.31, 0.31, 0.5)
                btn.flash:SetBackdropBorderColor(0, 0, 0)
                btn.flash.frequency = .025
                btn.flash.elapsed = 0
                btn.flash.isFading = false
                btn.flash:SetScript("OnUpdate", function(self, elapsed)
                    -- Check if update should happen yet
                    self.elapsed = self.elapsed + elapsed
                    if self.elapsed <= self.frequency then return end
                    self.elapsed = 0

                    -- Determine if we should fade or not
                    local currentAlpha = self:GetAlpha()
                    if self.isFading and currentAlpha <= 0 then
                        self.isFading = false
                    elseif not self.isFading and currentAlpha >= 1 then
                        self.isFading = true
                    end

                    -- Change alpha
                    self:SetAlpha(currentAlpha + (self.isFading and -.1 or .1))
                end)
                -- Stop flashing if player sends an outgoing whisper
                btn.flash:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
                btn.flash:SetScript("OnEvent", function(self, event, ...)
                    FlashTab(self:GetParent())
                end)

                btn.flash:Hide()


                --[[
                btn.skinTop = btn:CreateTexture(nil, "BORDER")
                btn.skinTop:SetTexture(media.files.background)
                btn.skinTop:SetHeight(PixelScale(4))
                btn.skinTop:SetPoint("TOPLEFT", PixelScale(2), PixelScale(-2))
                btn.skinTop:SetPoint("TOPRIGHT", PixelScale(-2), PixelScale(-2))
                btn.skinTop:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0.84, 0.75, 0.65, 0.5)

                btn.skinBottom = btn:CreateTexture(nil, "BORDER")
                btn.skinBottom:SetTexture(media.files.background)
                btn.skinBottom:SetHeight(PixelScale(4))
                btn.skinBottom:SetPoint("TOPLEFT", PixelScale(2), PixelScale(-12))
                btn.skinBottom:SetPoint("BOTTOMRIGHT", PixelScale(-2), PixelScale(2))
                btn.skinBottom:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.75, 0, 0, 0, 0)
                --]]

                return btn
            end

            local cft1 = MakeButton(1, "G", "• Gen •")
            -- 2 would be combat log, but not for gotChat
            local cft3 = MakeButton(3, "W", "• w <-> •")
            local cft4 = MakeButton(4, "L", "• Loot •")

            cft4:SetPoint("TOPRIGHT", caelPanel_ChatFrame, "TOPRIGHT", 0, PixelScale(-1.5))
            cft3:SetPoint("RIGHT", cft4, "LEFT")
            cft1:SetPoint("RIGHT", cft3, "LEFT")

            -- Override old tab bar functions so that we can use our custom buttons to open chat options
            FCF_GetCurrentChatFrameID = GetChatFrameID
            FCF_GetCurrentChatFrame = GetCurrentChatFrame

            -- Start with chat frame 1 shown.
            ShowChatFrame(cft1)

            -- Prevent Blizzard from changing to chat tab 1 (on instance enter, flight path end etc).
            ChatFrame1:HookScript("OnShow", function()
                if ChatButtonBar.id ~= 1 then
                    ShowChatFrame(_G[format("ChatButton%d", ChatButtonBar.id)])
                end
            end)

            -- Hook cf3's add message so we can flash.
            local oAddMessage = ChatFrame3.AddMessage
            ChatFrame3.AddMessage = function(...)
                -- Flash if tab is not selected.
                if ChatButtonBar.id ~= 3 then
                    FlashTab(cft3, true)
                end
                oAddMessage(...)
            end
        end
    end
end)

local chatStuff = function()
    local _, instanceType = IsInInstance()
    if instanceType ~= "raid" then
        ChatFrame_AddChannel(ChatFrame1, "General")
        ChatFrame_AddChannel(ChatFrame1, "Trade")
    else
        ChatFrame_RemoveChannel(ChatFrame1, "General")
    end
end

local delay1 = 5
local delay2 = 10
local caelChat_OnUpdate = function(self, elapsed)
    if delay1 then
        delay1 = delay1 - elapsed
        if delay1 <= 0 then
            for i = 1, NUM_CHAT_WINDOWS do
                local frame = _G[format("ChatFrame%s", i)]
                if(i == 1) then
                    chatStuff()
                end
            end
            delay1 = nil -- This stops the OnUpdate for this timer.
        end
    end

    if delay2 then
        delay2 = delay2 - elapsed
        if delay2 <= 0 then
            ChangeChatColor("CHANNEL1", 0.55, 0.57, 0.61)
            ChangeChatColor("CHANNEL2", 0.55, 0.57, 0.61)
            ChangeChatColor("CHANNEL5", 0.84, 0.75, 0.65)
            ChangeChatColor("WHISPER", 0.3, 0.6, 0.9)
            ChangeChatColor("WHISPER_INFORM", 0.3, 0.6, 0.9)

            -- Caellian stuff
            --[[
            -- XXX: We are removing all usage of isCharListA and myChars due to globalization of the UI.
            if isCharListA and playerClass == "HUNTER" then
                JoinTemporaryChannel("WeDidHunter")
                ChatFrame_AddChannel(_G.ChatFrame1, "WeDidHunter")
                ChangeChatColor("CHANNEL5", 0.67, 0.83, 0.45)
            elseif isCharListA and playerClass == "DRUID" or playerClass == "ROGUE" or playerClass == "WARRIOR" or playerClass == "DEATHKNIGHT" then
                JoinTemporaryChannel("WeDidCaC")
                ChatFrame_AddChannel(_G.ChatFrame1, "WeDidCaC")
                if playerClass == "DRUID" then ChangeChatColor("CHANNEL5", 1, 0.49, 0.04) end
                if playerClass == "ROGUE" then ChangeChatColor("CHANNEL5", 1, 0.96, 0.41) end
                if playerClass == "WARRIOR" then ChangeChatColor("CHANNEL5", 0.78, 0.61, 0.43) end
                if playerClass == "DEATHKNIGHT" then ChangeChatColor("CHANNEL5", 0.77, 0.12, 0.23) end
            end
            --]]

            print("|cffD7BEA5cael|rChat: Chatframes setup complete")
            self:SetScript("OnUpdate", nil) -- Done now, nil the OnUpdate completely.
        end
    end
end

local first = true
caelChat.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelChat.eventFrame:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        chatStuff()

        if first then
            caelChat.eventFrame:SetScript("OnUpdate", caelChat_OnUpdate)
            first = nil
        end
    end
end)
