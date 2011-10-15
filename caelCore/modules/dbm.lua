if not IsAddOnLoaded("DBM-Core") then return end

local _, caelCore = ...

local dbm = caelCore.createModule("Deadly Boss Mods")

local caelUI = caelUI
local media = caelUI.media

local SkinBars = function(self)
    for bar in self:GetBarIterator() do
        if not bar.injected then
            bar.ApplyStyle = function()
                local frame     =   bar.frame
                local tbar      =   _G[frame:GetName().."Bar"]
                local spark     =   _G[frame:GetName().."BarSpark"]
                local texture   =   _G[frame:GetName().."BarTexture"]
                local icon1     =   _G[frame:GetName().."BarIcon1"]
                local icon2     =   _G[frame:GetName().."BarIcon2"]
                local name      =   _G[frame:GetName().."BarName"]
                local timer     =   _G[frame:GetName().."BarTimer"]

                if icon1 then
                    icon1:SetSize(15, 15)
                    icon1:SetPoint("RIGHT", frame, "LEFT", -3, 0)
                end

                if icon2 then
                    icon2:SetSize(15, 15)
                end

                if not frame.styled then
                    frame:SetScale(1)
                    frame:SetHeight(15)
                    frame.background = caelUI.createBackdrop(frame)
                    frame.styled = true
                end

                if not tbar.styled then
                    tbar:SetAllPoints(frame)
                    frame.styled = true
                end

                if not spark.killed then
                    spark:SetAlpha(0)
                    spark:SetTexture(nil)
                    spark.killed = true
                end

                if not icon1.styled then
                    icon1:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                    icon1.frame = CreateFrame("Frame", nil, tbar)
                    icon1.frame:SetFrameStrata("BACKGROUND")
                    icon1.frame:SetAllPoints(icon1)
                    icon1.frame.background = caelUI.createBackdrop(icon1.frame)
                    icon1.styled = true
                end

                if not texture.styled then
                    texture:SetTexture(media.files.statusBarC)
                    texture.styled = true
                end

                if not name.styled then
                    name:SetFont(media.fonts.NORMAL, 10)
                    name:SetShadowOffset(0, 0)
                    name.SetFont = function() end
                    name.styled = true
                end

                if not timer.styled then    
                    timer:SetFont(media.fonts.CUSTOM_NUMBERFONT, 10)
                    timer:SetShadowOffset(0, 0)
                    timer.SetFont = function() end
                    timer.styled = true
                end

                frame:Show()
                bar:Update(0)
                bar.injected = true
            end
            bar:ApplyStyle()
        end
    end
end

local SetupDBM = function()
    DBM_SavedOptions.Enabled = true
    DBM_SavedOptions.ShowMinimapButton = false
    DBM_SavedOptions.ShowSpecialWarnings = true
    DBM_SavedOptions.SpecialWarningPoint = "CENTER"
    DBM_SavedOptions.SpecialWarningX = 0
    DBM_SavedOptions.SpecialWarningY = 200
    DBM_SavedOptions.SpecialWarningFont = media.fonts.NORMAL
    DBM_SavedOptions.SpecialWarningFontColor = {0.69, 0.31, 0.31}
    DBM_SavedOptions.SpecialWarningFontSize = 15
    DBM_SavedOptions.WarningIconLeft = false
    DBM_SavedOptions.WarningIconRight = false
    DBM_SavedOptions.AlwaysShowHealthFrame = false
    DBM_SavedOptions.ShowSpecialWarnings = true
    DBM_SavedOptions.ShowFakedRaidWarnings = true
    DBM_SavedOptions.DontShowBossAnnounces = true
    DBM_SavedOptions.AlwaysShowSpeedKillTimer = false
    DBM_SavedOptions.LatencyThreshold = 50
    DBM_SavedOptions.InfoFramePoint = "TOP"
    DBM_SavedOptions.InfoFrameX = 315
    DBM_SavedOptions.InfoFrameY = -5
    DBM_SavedOptions.InfoFrameLocked = true
    DBM_SavedOptions.RangeFramePoint = "TOP"
    DBM_SavedOptions.RangeFrameX = -315
    DBM_SavedOptions.RangeFrameY = -5
    DBM_SavedOptions.RangeFrameLocked = true

    DBT_SavedOptions["DBM"].Scale = 1
    DBT_SavedOptions["DBM"].HugeScale = 1
    DBT_SavedOptions["DBM"].BarXOffset = 0
    DBT_SavedOptions["DBM"].BarYOffset = -5
    DBT_SavedOptions["DBM"].HugeBarXOffset = 0
    DBT_SavedOptions["DBM"].HugeBarYOffset = -5
    DBT_SavedOptions["DBM"].Font = media.fonts.NORMAL
    DBT_SavedOptions["DBM"].FontSize = 10
    DBT_SavedOptions["DBM"].Width = 170
    DBT_SavedOptions["DBM"].HugeWidth = 170
    DBT_SavedOptions["DBM"].TimerX = 107.5
    DBT_SavedOptions["DBM"].TimerY = 0
    DBT_SavedOptions["DBM"].TimerPoint = "LEFT"
    DBT_SavedOptions["DBM"].FillUpBars = true
    DBT_SavedOptions["DBM"].IconLeft = true
    DBT_SavedOptions["DBM"].ExpandUpwards = true
    DBT_SavedOptions["DBM"].Texture = media.files.statusBarC
    DBT_SavedOptions["DBM"].IconRight = false
    DBT_SavedOptions["DBM"].HugeBarsEnabled = true
end

hooksecurefunc(DBT, "CreateBar", SkinBars)

DBM.InfoFrame:Show(5, "health", nil)
DBM.InfoFrame:Hide()

DBM.Frames.infoFrame:HookScript("OnShow", function(self)
    self:SetBackdrop(nil)
    caelUI.createBackdrop(self)
end)

DBM.RangeCheck:Show()
DBM.RangeCheck:Hide()
--[[
DBM.RangeCheck:HookScript("OnShow", function(self)
    self:SetBackdrop(nil)
    caelUI.createBackdrop(self)
end)
--]]
dbm:RegisterEvent("PLAYER_LOGIN")
dbm:SetScript("OnEvent", function(self, event)
    SetupDBM()
end)
