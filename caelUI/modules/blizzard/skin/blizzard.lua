local SkinBlizzard = CreateModule("SkinBlizzardFrames")
local private = unpack(select(2, ...))

--[[    Reskin Blizzard windows ]]

local PixelScale = SkinBlizzard.PixelScale
local media      = SkinBlizzard:GetMedia()
local backdrop   = media.backdrop_table
local color      = RAID_CLASS_COLORS[private.GetDatabase("config").player.class]

local function SetModifiedBackdrop (self)
    self:SetBackdropColor(color.r * 0.25, color.g * 0.25, color.b * 0.25, 0.7)
    self:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function SetOriginalBackdrop(self)
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:SetBackdropBorderColor(0, 0, 0, 1)
end

local function SkinPanel (frame)
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 1) 
end

local function SkinButton (frame)
    if frame:GetName() then
        for _, region in next, {"Left", "Middle", "Right", "LeftDisabled", "RightDisabled", "MiddleDisabled", "TabSpacer", "TabSpacer1", "TabSpacer2"} do
            local texture = _G[frame:GetName() .. region]

            if texture then
                texture:SetAlpha(0)
            end
        end
    end

    if frame.SetNormalTexture then
        frame:SetNormalTexture(nil)
    end

    if frame.SetHighlightTexture then
        frame:SetHighlightTexture(nil)
    end

    if frame.SetPushedTexture then
        frame:SetPushedTexture(nil)
    end

    if frame.SetDisabledTexture then
        frame:SetDisabledTexture(nil)
    end
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.7)
    frame:SetBackdropBorderColor(0, 0, 0)

    if frame:GetName() ~= "InterfaceOptionsFrameTab1" or frame:GetName() ~= "InterfaceOptionsFrameTab2" then
        frame:HookScript("OnEnter", SetModifiedBackdrop)
        frame:HookScript("OnLeave", SetOriginalBackdrop)
    end
end

SkinBlizzard:RegisterEvent("ADDON_LOADED", function(self, _, addon)
    if addon ~= "caelUI" then return end

    -- Reskin popup buttons
    for i = 1, 3 do
        for j = 1, 3 do
            SkinButton(_G["StaticPopup"..i.."Button"..j])
        end
    end

    -- Blizzard Frame reskin
    for _, frame in pairs{
        "StaticPopup1",
        "StaticPopup2",
        "StaticPopup3",
        "GameMenuFrame",
        "InterfaceOptionsFrame",
        "VideoOptionsFrame",
        "AudioOptionsFrame",
        "LFGDungeonReadyStatus",
        "BNToastFrame",
        "TicketStatusFrameButton",
        "DropDownList1MenuBackdrop",
        "DropDownList2MenuBackdrop",
        "DropDownList1Backdrop",
        "DropDownList2Backdrop",
        "LFGSearchStatus",
        "AutoCompleteBox",
        "ReadyCheckFrame",
        "ColorPickerFrame",
        "ConsolidatedBuffsTooltip",
        "LFGDungeonReadyPopup",
        "VoiceChatTalkers",
        "ChannelPulloutBackground",
        "FriendsTooltip",
        "LFGDungeonReadyDialog",
        "GuildInviteFrame",
        "ChatConfigFrame",
        "RolePollPopup",
        "InterfaceOptionsFramePanelContainer",
        "InterfaceOptionsFrameAddOns",
        "InterfaceOptionsFrameCategories",
        "InterfaceOptionsFrameTab1",
        "InterfaceOptionsFrameTab2",
        "VideoOptionsFrameCategoryFrame",
        "VideoOptionsFramePanelContainer",
        "AudioOptionsFrameCategoryFrame",
        "AudioOptionsSoundPanel",
        "AudioOptionsSoundPanelPlayback",
        "AudioOptionsSoundPanelHardware",
        "AudioOptionsSoundPanelVolume",
        "AudioOptionsVoicePanel",
        "AudioOptionsVoicePanelTalking",
        "AudioOptionsVoicePanelBinding",
        "AudioOptionsVoicePanelListening",
        "GhostFrameContentsFrame",
        "ChatConfigCategoryFrame",
        "ChatConfigBackgroundFrame",
        "ChatConfigChatSettingsClassColorLegend",
        "ChatConfigChatSettingsLeft",
    } do
        SkinPanel(_G[frame])

        if frame == "InterfaceOptionsFrameTab1" or frame == "InterfaceOptionsFrameTab2" then
            SkinButton(_G[frame])
            _G[frame]:SetScript("OnEnter", SetModifiedBackdrop)
            _G[frame]:SetScript("OnLeave", SetOriginalBackdrop)
            _G[frame]:SetScript("OnShow", nil)
            _G[frame .. "Text"]:ClearAllPoints()
            _G[frame .. "Text"]:SetPoint("CENTER", _G[frame], "CENTER")
            _G[frame .. "Text"].SetPoint = function() return end
        end
    end

    local ChatMenus = {
        "ChatMenu",
        "EmoteMenu",
        "LanguageMenu",
        "VoiceMacroMenu",
    }
    
    for i = 1, getn(ChatMenus) do
        if _G[ChatMenus[i]] == _G["ChatMenu"] then
            _G[ChatMenus[i]]:HookScript("OnShow", function(self) SkinPanel(self) self:ClearAllPoints() self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30) end)
        else
            _G[ChatMenus[i]]:HookScript("OnShow", function(self) SkinPanel(self) end)
        end
    end
    
    -- Reskin all esc/menu buttons
    local BlizzardMenuButtons = {
        "Help",
        "Options",
        "SoundOptions",
        "UIOptions",
        "Keybindings",
        "Macros",
        "Ratings",
        "AddOns",
        "Logout",
        "Quit",
        "Continue",
        "MacOptions",
        "OptionHouse",
        "AddonManager",
        "SettingsGUI",
    }
    
    for _, button in next, BlizzardMenuButtons do
        local UIMenuButtons = _G["GameMenuButton" .. button]

        if UIMenuButtons then
            SkinButton(UIMenuButtons)

            for _, region in next, {"Left", "Right", "Middle"} do
                _G["GameMenuButton" .. button .. region]:SetTexture(nil)
            end
        end
    end

    -- Hide header textures and move text/buttons
    local BlizzardHeader = {
        "GameMenuFrame", 
        "InterfaceOptionsFrame", 
        "AudioOptionsFrame", 
        "VideoOptionsFrame",
        "ColorPickerFrame",
        "ChatConfigFrame",
    }
    
    for _, frame in next, BlizzardHeader do
        local title = _G[frame .. "Header"]

        if title then
            title:SetTexture("")
            title:ClearAllPoints()

            if title == _G["GameMenuFrameHeader"] then
                title:SetPoint("TOP", GameMenuFrame, 0, 7)
            elseif title == _G["ColorPickerFrameHeader"] then
                title:SetPoint("TOP", ColorPickerFrame, 0, 7)
            elseif title == _G["ChatConfigFrameHeader"] then
                title:SetPoint("TOP", ChatConfigFrame, 0, 7)
            else
                title:SetPoint("TOP", frame, 0, 0)
            end
        end
    end
    
    -- Reskin all "normal" buttons
    for _, button in next, {
        "VideoOptionsFrameOkay",
        "VideoOptionsFrameCancel",
        "VideoOptionsFrameDefaults",
        "VideoOptionsFrameApply",
        "AudioOptionsFrameOkay",
        "AudioOptionsFrameCancel",
        "AudioOptionsFrameDefaults",
        "InterfaceOptionsFrameDefaults",
        "InterfaceOptionsFrameOkay",
        "InterfaceOptionsFrameCancel",
        "ReadyCheckFrameYesButton",
        "ReadyCheckFrameNoButton",
        "ColorPickerOkayButton",
        "ColorPickerCancelButton",
        "GuildInviteFrameJoinButton",
        "GuildInviteFrameDeclineButton",
        "LFGDungeonReadyDialogLeaveQueueButton",
        "LFGDungeonReadyDialogEnterDungeonButton",
        "ChatConfigFrameDefaultButton",
        "ChatConfigFrameOkayButton",
        "RolePollPopupAcceptButton",
        "LFDRoleCheckPopupAcceptButton",
        "LFDRoleCheckPopupDeclineButton"
    } do
        SkinButton(_G[button])
    end

    -- Button position or text
    _G["VideoOptionsFrameCancel"]:ClearAllPoints()
    _G["VideoOptionsFrameCancel"]:SetPoint("RIGHT", _G["VideoOptionsFrameApply"], "LEFT", -4, 0)     
    _G["VideoOptionsFrameOkay"]:ClearAllPoints()
    _G["VideoOptionsFrameOkay"]:SetPoint("RIGHT", _G["VideoOptionsFrameCancel"], "LEFT", -4, 0)
    _G["AudioOptionsFrameOkay"]:ClearAllPoints()
    _G["AudioOptionsFrameOkay"]:SetPoint("RIGHT", _G["AudioOptionsFrameCancel"], "LEFT", -4, 0)
    _G["InterfaceOptionsFrameOkay"]:ClearAllPoints()
    _G["InterfaceOptionsFrameOkay"]:SetPoint("RIGHT", _G["InterfaceOptionsFrameCancel"], "LEFT", -4, 0)
    _G["ColorPickerOkayButton"]:ClearAllPoints()
    _G["ColorPickerOkayButton"]:SetPoint("BOTTOMLEFT", _G["ColorPickerFrame"], "BOTTOMLEFT", 6, 6)       
    _G["ColorPickerCancelButton"]:ClearAllPoints()
    _G["ColorPickerCancelButton"]:SetPoint("BOTTOMRIGHT", _G["ColorPickerFrame"], "BOTTOMRIGHT", -6, 6)
    _G["ReadyCheckFrameYesButton"]:SetParent(_G["ReadyCheckFrame"])
    _G["ReadyCheckFrameNoButton"]:SetParent(_G["ReadyCheckFrame"]) 
    _G["ReadyCheckFrameYesButton"]:SetPoint("RIGHT", _G["ReadyCheckFrame"], "CENTER", 0, -22)
    _G["ReadyCheckFrameNoButton"]:SetPoint("LEFT", _G["ReadyCheckFrameYesButton"], "RIGHT", 3, 0)
    _G["ReadyCheckFrameText"]:SetParent(_G["ReadyCheckFrame"])  
    _G["ReadyCheckFrameText"]:ClearAllPoints()
    _G["ReadyCheckFrameText"]:SetPoint("TOP", 0, -12)
    _G["InterfaceOptionsFrameTab1"]:ClearAllPoints()
    _G["InterfaceOptionsFrameTab1"]:SetPoint("TOPLEFT", _G["InterfaceOptionsFrameCategories"], "TOPLEFT", 0, 25)
    _G["InterfaceOptionsFrameTab1"]:SetWidth(80)
    _G["InterfaceOptionsFrameTab2"]:ClearAllPoints()
    _G["InterfaceOptionsFrameTab2"]:SetPoint("TOPRIGHT", _G["InterfaceOptionsFrameCategories"], "TOPRIGHT", 0, 25)
    _G["InterfaceOptionsFrameTab2"]:SetWidth(80)
    _G["ChatConfigFrameDefaultButton"]:SetWidth(125)
    _G["ChatConfigFrameDefaultButton"]:ClearAllPoints()
    _G["ChatConfigFrameDefaultButton"]:SetPoint("TOP", _G["ChatConfigCategoryFrame"], "BOTTOM", 0, -4)
    _G["ChatConfigFrameOkayButton"]:ClearAllPoints()
    _G["ChatConfigFrameOkayButton"]:SetPoint("TOPRIGHT", _G["ChatConfigBackgroundFrame"], "BOTTOMRIGHT", 0, -4)
    
    -- Others
    _G["ReadyCheckListenerFrame"]:SetAlpha(0)
    _G["ReadyCheckFrame"]:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end)
    _G["PlayerPowerBarAlt"]:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self.ClearAllPoints = function () end
        self:SetPoint("BOTTOM", caelPanel_Minimap, "TOP", 0, PixelScale(25))
        self.SetPoint = function () end
    end)
    SkinPanel(_G["StackSplitFrame"])
    SkinButton(_G["StackSplitOkayButton"])
    SkinButton(_G["StackSplitCancelButton"])
    _G["StackSplitFrame"]:GetRegions():Hide()

    -- Kill off all the frame textures related to the interface options left side pane.
    for _, frame in next, {"InterfaceOptionsFrameAddOns", "InterfaceOptionsFrameCategories"} do
        for _, region in next, {"Top", "Bottom", "BottomRight", "BottomLeft", "TopRight", "TopLeft", "Right", "Left"} do
            local texture = _G[frame .. region]

            if texture then
                texture:SetTexture(nil)
            end
        end
    end
end)
