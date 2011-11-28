--[[

Tukui_DBM skin by Affli@RU-Howling Fjord
All rights reserved.
Thanks ALZA, Shestak, Fernir, Tukz and everyone i've forgot to mention.

Modified for caelUI by Belliofria.

]]--
local private = unpack(select(2, ...))

if not IsAddOnLoaded("DBM-Core") then return end

-- Config Options
local Crop_RaidWarning_Icons = true -- crops blizz shitty borders from icons in RaidWarning messages
local Draw_Shadows = false          -- draw Tukui shadows around frames.
local RaidWarning_Icon_Size = 18    -- RaidWarning icon size, because 12 is small for me. Works only if Crop_RaidWarning_Icons=true

-- Localizations of globals
local media = private.database.get("media")
local config = private.database.get("config")

local pixel_scale = private.pixel_scale
-- local pixel_scale(1) = private.pixel_scale(1)()

-- Internal config values.
local My_Class_Color = RAID_CLASS_COLORS[config.player.class]
local Button_Size = 30

local function SkinBars(self)
    for bar in self:GetBarIterator() do
        if not bar.injected then
            local frame     = bar.frame
            local frame_bar = _G[frame:GetName().."Bar"]
            local spark     = _G[frame:GetName().."BarSpark"]
            local texture   = _G[frame:GetName().."BarTexture"]
            local icon1     = _G[frame:GetName().."BarIcon1"]
            local icon2     = _G[frame:GetName().."BarIcon2"]
            local name      = _G[frame:GetName().."BarName"]
            local timer     = _G[frame:GetName().."BarTimer"]

            if not icon1.overlay then
                icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", frame_bar)
                icon1.overlay:SetFrameLevel(1)
                icon1.overlay:SetHeight(pixel_scale(Button_Size))
                icon1.overlay:SetWidth(pixel_scale(Button_Size))
                icon1.overlay:SetFrameStrata("BACKGROUND")
                icon1.overlay:SetPoint("BOTTOMRIGHT", frame_bar, "BOTTOMLEFT", -pixel_scale(Button_Size / 4), -pixel_scale(2))
                icon1.overlay:SetBackdrop({
                    bgFile = [[Interface\Addons\caelUI\media\borders\blank]],
                    edgeFile = [[Interface\Addons\caelUI\media\borders\blank]],
                    tile = false, tileSize = 0, edgeSize = pixel_scale(1),
                    insets = {left = -pixel_scale(1), right = -pixel_scale(1), top = -pixel_scale(1), bottom = -pixel_scale(1)}
                })

                icon1.overlay:SetBackdropColor(0.1, 0.1, 0.1, 1)
                icon1.overlay:SetBackdropBorderColor(0.6, 0.6, 0.6)
                
                if Draw_Shadows and not icon1.overlay.shadow then
                    local shadow = CreateFrame("Frame", nil, icon1.overlay)
                    shadow:SetFrameLevel(1)
                    shadow:SetFrameStrata("BACKGROUND")
                    shadow:SetPoint("TOPLEFT", -pixel_scale(3), pixel_scale(3))
                    shadow:SetPoint("BOTTOMLEFT", -pixel_scale(3), -pixel_scale(3))
                    shadow:SetPoint("TOPRIGHT", pixel_scale(3), pixel_scale(3))
                    shadow:SetPoint("BOTTOMRIGHT", pixel_scale(3), -pixel_scale(3))
                    shadow:SetBackdrop( { 
                        edgeFile = [[Interface\Addons\caelUI\media\borders\glowTex1]], edgeSize = pixel_scale(3),
                        insets = {left = pixel_scale(5), right = pixel_scale(5), top = pixel_scale(5), bottom = pixel_scale(5)},
                    })
                    shadow:SetBackdropColor(0, 0, 0, 0)
                    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
                    icon1.overlay.shadow = shadow
                end

                local backdroptex = icon1.overlay:CreateTexture(nil, "BORDER")

                backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
                backdroptex:SetPoint("TOPLEFT", icon1.overlay, "TOPLEFT", pixel_scale(2), -pixel_scale(2))
                backdroptex:SetPoint("BOTTOMRIGHT", icon1.overlay, "BOTTOMRIGHT", -pixel_scale(2), pixel_scale(2))
                backdroptex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end

            if not icon2.overlay then
                icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", frame_bar)
                icon2.overlay:SetFrameLevel(1)
                icon2.overlay:SetHeight(pixel_scale(Button_Size))
                icon2.overlay:SetWidth(pixel_scale(Button_Size))
                icon2.overlay:SetFrameStrata("BACKGROUND")
                icon2.overlay:SetPoint("BOTTOMLEFT", frame_bar, "BOTTOMRIGHT", pixel_scale(Button_Size / 4), -pixel_scale(2))
                icon2.overlay:SetBackdrop({
                    bgFile = [[Interface\Addons\caelUI\media\borders\blank]],
                    edgeFile = [[Interface\Addons\caelUI\media\borders\blank]],
                    tile = false, tileSize = 0, edgeSize = pixel_scale(1),
                    insets = {left = -pixel_scale(1), right = -pixel_scale(1), top = -pixel_scale(1), bottom = -pixel_scale(1)}
                })

                icon2.overlay:SetBackdropColor(0.1, 0.1, 0.1, 1)
                icon2.overlay:SetBackdropBorderColor(0.6, 0.6, 0.6)

                if Draw_Shadows and not icon2.overlay.shadow then
                    local shadow = CreateFrame("Frame", nil, icon2.overlay)
                    shadow:SetFrameLevel(1)
                    shadow:SetFrameStrata("BACKGROUND")
                    shadow:SetPoint("TOPLEFT", -pixel_scale(3), pixel_scale(3))
                    shadow:SetPoint("BOTTOMLEFT", -pixel_scale(3), -pixel_scale(3))
                    shadow:SetPoint("TOPRIGHT", pixel_scale(3), pixel_scale(3))
                    shadow:SetPoint("BOTTOMRIGHT", pixel_scale(3), -pixel_scale(3))
                    shadow:SetBackdrop( { 
                        edgeFile = [[Interface\Addons\caelUI\media\borders\glowTex1]], edgeSize = pixel_scale(3),
                        insets = {left = pixel_scale(5), right = pixel_scale(5), top = pixel_scale(5), bottom = pixel_scale(5)},
                    })
                    shadow:SetBackdropColor(0, 0, 0, 0)
                    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
                    icon2.overlay.shadow = shadow
                end

                local backdroptex = icon2.overlay:CreateTexture(nil, "BORDER")

                backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
                backdroptex:SetPoint("TOPLEFT", icon2.overlay, "TOPLEFT", pixel_scale(2), -pixel_scale(2))
                backdroptex:SetPoint("BOTTOMRIGHT", icon2.overlay, "BOTTOMRIGHT", -pixel_scale(2), pixel_scale(2))
                backdroptex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end

            if bar.color then
                frame_bar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
            else
                frame_bar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
            end

            if bar.enlarged then frame:SetWidth(pixel_scale(bar.owner.options.HugeWidth)) else frame:SetWidth(pixel_scale(bar.owner.options.Width)) end
            if bar.enlarged then frame_bar:SetWidth(pixel_scale(bar.owner.options.HugeWidth)) else frame_bar:SetWidth(pixel_scale(bar.owner.options.Width)) end

            if not frame.styled then
                --frame:SetScale(1)
                frame:SetScale(0.9)

                frame.SetScale = function() return end

                frame:SetHeight(pixel_scale(Button_Size / 2))
                
                frame:SetBackdrop({
                    bgFile = [[Interface\Addons\caelUI\media\borders\blank]],
                    edgeFile = [[Interface\Addons\caelUI\media\borders\blank]],
                    tile = false, tileSize = 0, edgeSize = pixel_scale(1),
                    insets = {left = -pixel_scale(1), right = -pixel_scale(1), top = -pixel_scale(1), bottom = -pixel_scale(1)}
                })
                frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
                frame:SetBackdropBorderColor(0.6, 0.6, 0.6)

                if Draw_Shadows and not frame.shadow then
                    local shadow = CreateFrame("Frame", nil, frame.overlay)
                    shadow:SetFrameLevel(1)
                    shadow:SetFrameStrata("BACKGROUND")
                    shadow:SetPoint("TOPLEFT", -pixel_scale(3), pixel_scale(3))
                    shadow:SetPoint("BOTTOMLEFT", -pixel_scale(3), -pixel_scale(3))
                    shadow:SetPoint("TOPRIGHT", pixel_scale(3), pixel_scale(3))
                    shadow:SetPoint("BOTTOMRIGHT", pixel_scale(3), -pixel_scale(3))
                    shadow:SetBackdrop( { 
                        edgeFile = [[Interface\Addons\caelUI\media\borders\glowTex1]], edgeSize = pixel_scale(3),
                        insets = {left = pixel_scale(5), right = pixel_scale(5), top = pixel_scale(5), bottom = pixel_scale(5)},
                    })
                    shadow:SetBackdropColor(0, 0, 0, 0)
                    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
                    frame.shadow = shadow
                end

                frame.styled = true
            end

            if not spark.killed then
                spark:SetAlpha(0)
                spark:SetTexture(nil)
                spark.killed = true
            end

            if not icon1.styled then
                icon1:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                icon1:ClearAllPoints()
                icon1:SetPoint("TOPLEFT", icon1.overlay, pixel_scale(2), -pixel_scale(2))
                icon1:SetPoint("BOTTOMRIGHT", icon1.overlay, -pixel_scale(2), pixel_scale(2))
                icon1.styled = true
            end
            
            if not icon2.styled then
                icon2:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                icon2:ClearAllPoints()
                icon2:SetPoint("TOPLEFT", icon2.overlay, pixel_scale(2), -pixel_scale(2))
                icon2:SetPoint("BOTTOMRIGHT", icon2.overlay, -pixel_scale(2), pixel_scale(2))
                icon2.styled = true
            end

            if not texture.styled then
                texture:SetTexture(media.files.statusbar_c)
                texture.styled = true
            end

            frame_bar:SetStatusBarTexture(media.files.statusbar_c)
            if not frame_bar.styled then
                frame_bar:SetPoint("TOPLEFT", frame, "TOPLEFT", pixel_scale(2), -pixel_scale(2))
                frame_bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -pixel_scale(2), pixel_scale(2))
                
                frame_bar.styled = true
            end

            if not name.styled then
                name:ClearAllPoints()
                name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, pixel_scale(4))
                name:SetWidth(165)
                name:SetHeight(8)
                name:SetFont(media.fonts.normal, 12, "OUTLINE")
                name:SetJustifyH("LEFT")
                name:SetShadowColor(0, 0, 0, 0)
                name.SetFont = function() return end
                name.styled = true
            end
            
            if not timer.styled then    
                timer:ClearAllPoints()
                timer:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -pixel_scale(1), pixel_scale(2))
                timer:SetFont(media.fonts.normal, 12, "OUTLINE")
                timer:SetJustifyH("RIGHT")
                timer:SetShadowColor(0, 0, 0, 0)
                timer.SetFont = function() return end
                timer.styled = true
            end

            if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
            if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end
            frame_bar:SetAlpha(1)
            frame:SetAlpha(1)
            texture:SetAlpha(1)
            frame:Show()
            bar:Update(0)
            bar.injected = true
        end

    end
end
 
local SkinBossTitle = function()
    local anchor = DBMBossHealthDropdown:GetParent()
    if not anchor.styled then
        local header = {anchor:GetRegions()}
            if header[1]:IsObjectType("FontString") then
                header[1]:SetFont(media.fonts.normal, 12, "OUTLINE")
                header[1]:SetTextColor(1,1,1,1)
                header[1]:SetShadowColor(0, 0, 0, 0)
                anchor.styled = true  
            end
        header = nil
    end
    anchor = nil
end

local SkinBoss=function()
    local count = 1
    while (_G[format("DBM_BossHealth_Bar_%d", count)]) do
        local bar        = _G[format("DBM_BossHealth_Bar_%d", count)]
        local background = _G[bar:GetName().."BarBorder"]
        local progress   = _G[bar:GetName().."Bar"]
        local name       = _G[bar:GetName().."BarName"]
        local timer      = _G[bar:GetName().."BarTimer"]
        local prev       = _G[format("DBM_BossHealth_Bar_%d", count-1)]   

        if (count == 1) then
            local   _, anch, _ ,_, _ = bar:GetPoint()
            bar:ClearAllPoints()
            if DBM_SavedOptions.HealthFrameGrowUp then
                bar:SetPoint("BOTTOM", anch, "TOP" , 0 , pixel_scale(12))
            else
                bar:SetPoint("TOP", anch, "BOTTOM" , 0, -pixel_scale(Button_Size))
            end
        else
            bar:ClearAllPoints()
            if DBM_SavedOptions.HealthFrameGrowUp then
                bar:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, pixel_scale(Button_Size))
            else
                bar:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -pixel_scale(Button_Size))
            end
        end

        if not bar.styled then
            bar:SetHeight(pixel_scale(Button_Size / 3))

            bar:SetBackdrop({
                bgFile = [[Interface\Addons\caelUI\media\borders\blank]],
                edgeFile = [[Interface\Addons\caelUI\media\borders\blank]],
                tile = false, tileSize = 0, edgeSize = pixel_scale(1),
                insets = {left = -pixel_scale(1), right = -pixel_scale(1), top = -pixel_scale(1), bottom = -pixel_scale(1)}
            })

            bar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            bar:SetBackdropBorderColor(0.6, 0.6, 0.6)

            if Draw_Shadows and not bar.shadow then
                local shadow = CreateFrame("Frame", nil, bar.overlay)
                shadow:SetFrameLevel(1)
                shadow:SetFrameStrata("BACKGROUND")
                shadow:SetPoint("TOPLEFT", -pixel_scale(3), pixel_scale(3))
                shadow:SetPoint("BOTTOMLEFT", -pixel_scale(3), -pixel_scale(3))
                shadow:SetPoint("TOPRIGHT", pixel_scale(3), pixel_scale(3))
                shadow:SetPoint("BOTTOMRIGHT", pixel_scale(3), -pixel_scale(3))
                shadow:SetBackdrop( { 
                    edgeFile = [[Interface\Addons\caelUI\media\borders\glowTex1]], edgeSize = pixel_scale(3),
                    insets = {left = pixel_scale(5), right = pixel_scale(5), top = pixel_scale(5), bottom = pixel_scale(5)},
                })
                shadow:SetBackdropColor(0, 0, 0, 0)
                shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
                bar.shadow = shadow
            end

            background:SetNormalTexture(nil)

            bar.styled = true
        end 
        
        if not progress.styled then
            progress:SetStatusBarTexture(media.files.statusbar_c)
            progress.styled = true
        end

        progress:ClearAllPoints()
        progress:SetPoint("TOPLEFT", bar, "TOPLEFT", pixel_scale(2), -pixel_scale(2))
        progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -pixel_scale(2), pixel_scale(2))

        if not name.styled then
            name:ClearAllPoints()
            name:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", pixel_scale(1), pixel_scale(4))
            name:SetFont(media.fonts.normal, 12, "OUTLINE")
            name:SetJustifyH("LEFT")
            name:SetShadowColor(0, 0, 0, 0)
            name.styled = true
        end
        
        if not timer.styled then
            timer:ClearAllPoints()
            timer:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, pixel_scale(2))
            timer:SetFont(media.fonts.normal, 12, "OUTLINE")
            timer:SetJustifyH("RIGHT")
            timer:SetShadowColor(0, 0, 0, 0)
            timer.styled = true
        end

        count = count + 1
    end
end

-- mwahahahah, eat this ugly DBM.
hooksecurefunc(DBT, "CreateBar", SkinBars)
hooksecurefunc(DBM.BossHealth, "Show", SkinBossTitle)
hooksecurefunc(DBM.BossHealth, "AddBoss", SkinBoss)
hooksecurefunc(DBM.BossHealth, "UpdateSettings", SkinBoss)
DBM.RangeCheck:Show()
DBM.RangeCheck:Hide()
DBMRangeCheck:HookScript("OnShow", function(self)
    self:SetBackdrop({
        bgFile = [[Interface\Addons\caelUI\media\borders\blank]],
        edgeFile = [[Interface\Addons\caelUI\media\borders\blank]],
        tile = false, tileSize = 0, edgeSize = pixel_scale(1),
        insets = {left = -pixel_scale(1), right = -pixel_scale(1), top = -pixel_scale(1), bottom = -pixel_scale(1)}
    })
    self:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    self:SetBackdropBorderColor(0.6, 0.6, 0.6)

    if Draw_Shadows and not self.shadow then
        local shadow = CreateFrame("Frame", nil, self.overlay)
        shadow:SetFrameLevel(1)
        shadow:SetFrameStrata("BACKGROUND")
        shadow:SetPoint("TOPLEFT", -pixel_scale(3), pixel_scale(3))
        shadow:SetPoint("BOTTOMLEFT", -pixel_scale(3), -pixel_scale(3))
        shadow:SetPoint("TOPRIGHT", pixel_scale(3), pixel_scale(3))
        shadow:SetPoint("BOTTOMRIGHT", pixel_scale(3), -pixel_scale(3))
        shadow:SetBackdrop( { 
            edgeFile = [[Interface\Addons\caelUI\media\borders\glowTex1]], edgeSize = pixel_scale(3),
            insets = {left = pixel_scale(5), right = pixel_scale(5), top = pixel_scale(5), bottom = pixel_scale(5)},
        })
        shadow:SetBackdropColor(0, 0, 0, 0)
        shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
        self.shadow = shadow
    end
end)
if (Crop_RaidWarning_Icons) then
    local replace = string.gsub
    local old = RaidNotice_AddMessage
    RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
        if textString:find(" |T") then
            textString = replace(textString,"(:12:12)",":"..RaidWarning_Icon_Size..":"..RaidWarning_Icon_Size..":0:0:64:64:5:59:5:59")
        end
        return old(noticeFrame, textString, colorInfo)
    end
end

local function SetupDBM()
    DBM_SavedOptions.Enabled = true
    DBM_SavedOptions.ShowMinimapButton = false
    DBM_SavedOptions.ShowSpecialWarnings = true
    DBM_SavedOptions.SpecialWarningPoint = "TOP"
    DBM_SavedOptions.SpecialWarningX = 0
    DBM_SavedOptions.SpecialWarningY = 50
    DBM_SavedOptions.SpecialWarningFont = media.fonts.normal
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
    DBT_SavedOptions["DBM"].BarYOffset = 10
    DBT_SavedOptions["DBM"].HugeBarXOffset = 0
    DBT_SavedOptions["DBM"].HugeBarYOffset = 10
    DBT_SavedOptions["DBM"].Font = media.fonts.normal
    DBT_SavedOptions["DBM"].FontSize = 10
    DBT_SavedOptions["DBM"].Width = 170
    DBT_SavedOptions["DBM"].HugeWidth = 170
    DBT_SavedOptions["DBM"].TimerX = 110
    DBT_SavedOptions["DBM"].TimerY = 0
    DBT_SavedOptions["DBM"].TimerPoint = "LEFT"
    DBT_SavedOptions["DBM"].HugeTimerX = 0
    DBT_SavedOptions["DBM"].HugeTimerY = -120
    DBT_SavedOptions["DBM"].HugeTimerPoint = "CENTER"
    DBT_SavedOptions["DBM"].FillUpBars = false
    DBT_SavedOptions["DBM"].IconLeft = true
    DBT_SavedOptions["DBM"].ExpandUpwards = true
    DBT_SavedOptions["DBM"].Texture = media.files.statusbar_c
    DBT_SavedOptions["DBM"].IconRight = false
    DBT_SavedOptions["DBM"].HugeBarsEnabled = true
end

private.events:RegisterEvent("PLAYER_LOGIN", SetupDBM)

local function rt(i) return function() return i end end

local function healthdemo()
        DBM.BossHealth:Show("Scary bosses")
        DBM.BossHealth:AddBoss(rt(25), "Sinestra")
        DBM.BossHealth:AddBoss(rt(50), "Nefarian")
        DBM.BossHealth:AddBoss(rt(75), "Gamon")
        DBM.BossHealth:AddBoss(rt(100), "Hogger")
end

SLASH_DBMSKIN1 = "/dbmskin"
SlashCmdList["DBMSKIN"] = function(msg)
    if(msg=="test") then
        DBM:DemoMode()
    elseif(msg=="bh")then
        healthdemo()
    else
        private.print("Use |cffFF0000/dbmskin test|r to launch DBM testmode.")
        private.print("Use |cffFF0000/dbmskin bh|r to show test BossHealth frame.")
    end
end
