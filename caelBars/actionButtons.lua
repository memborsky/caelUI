local _G = _G

local media = caelUI.media
local pixel_scale = caelUI.config.pixel_scale

local hideHotkeys = true

local backdrop = {
    bgFile = media.files.button_gloss,
    insets = {top = pixel_scale(-1), left = pixel_scale(-1), bottom = pixel_scale(-1), right = pixel_scale(-1)},
}

local function StyleButton(name, action)

    local isPet        = name:find("PetActionButton")
    local isShapeshift = name:find("ShapeshiftButton")

    local button = _G[name]
    local border  = _G[format("%sBorder", name)]
    local icon = _G[format("%sIcon", name)]
    local flash = _G[format("%sFlash", name)]
    local cooldown  = _G[format("%sCooldown", name)]
    local texture = (isPet or isShapeshift) and _G[format("%sNormalTexture2", name)] or _G[format("%sNormalTexture", name)]

    button:SetNormalTexture(media.files.button_normal)
    button:SetPushedTexture(media.files.button_pushed)
    button:SetCheckedTexture(media.files.button_checked)
    button:SetHighlightTexture(media.files.button_highlight)

    if border then
        border:SetPoint("TOPLEFT", button, pixel_scale(-1), pixel_scale(1))
        border:SetPoint("BOTTOMRIGHT", button, pixel_scale(1), pixel_scale(-1))
        border:SetTexture(media.files.button_normal)
    end

    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetPoint("TOPLEFT", button, pixel_scale(4.5), pixel_scale(-4.5))
    icon:SetPoint("BOTTOMRIGHT", button, pixel_scale(-4.5), pixel_scale(4.5))

    flash:SetTexture(media.files.button_flash)

    cooldown:SetAllPoints(icon)

    if texture then
        texture:SetAllPoints()
        texture:SetVertexColor(0.5, 0.5, 0.5, 1)
    end

    if not button.backdrop then
        button.backdrop = CreateFrame("Frame", nil, button)
        button.backdrop:SetPoint("TOPLEFT", pixel_scale(-1), pixel_scale(1))
        button.backdrop:SetPoint("BOTTOMRIGHT", pixel_scale(1), pixel_scale(-1))
        button.backdrop:SetBackdrop(media.border_table)
        button.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    end

    if not button.gloss then
        button.gloss = CreateFrame("Frame", nil, button)
        button.gloss:SetAllPoints()
        button.gloss:SetBackdrop(backdrop)
        button.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0.5)
    end

    if action then
        local count  = _G[format("%sCount", name)]
        local hotkey  = _G[format("%sHotKey", name)]
        local cooldown  = _G[format("%sCooldown", name)]
        local name  = _G[format("%sName", name)]

        if count then
            count:SetParent(button.gloss)
            count:SetFont(media.fonts.normal, 12, "OUTLINEMONOCHROME")
            count:SetPoint("BOTTOMRIGHT", pixel_scale(3), pixel_scale(-1))
        end

        if not hideHotkeys then
            hotkey:SetFont(media.fonts.normal, 12, "OUTLINEMONOCHROME")
            hotkey:ClearAllPoints()
            hotkey:SetPoint("TOPRIGHT", pixel_scale(3), pixel_scale(1))
        else
            hotkey:Hide()
            hotkey.Show = hotkey.Hide
        end

        if name then
            name:Hide()
        end
--[[
        if not button.glow then
            button.glow = button:CreateTexture(nil, "OVERLAY")
            button.glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
            button.glow:SetPoint("CENTER", button)
            button.glow:SetHeight(button:GetHeight() * 1.3)
            button.glow:SetWidth(button:GetWidth() * 1.3)
            button.glow:SetTexCoord("0.00781250", "0.50781250", "0.83818625", "0.78515625")
            button.glow:SetVertexColor(1, 0, 0, 0.5)
            button.glow:SetBlendMode("ADD")
            button.glow:Hide()
        end
--]]
    end
end

local function caelButtons_Action(self)
    StyleButton(self:GetName(), self.action)
end

local function caelButtons_Pet()
    for i = 1, NUM_PET_ACTION_SLOTS do
        StyleButton(format("PetActionButton%d", i))
    end
end

local function caelButtons_Shapeshift()    
    for i = 1, NUM_SHAPESHIFT_SLOTS do
        StyleButton(format("ShapeshiftButton%d", i))
    end
end

local function caelButtons_ActionUsable(self)
    local name = self:GetName()
    local action = self.action
    local icon = _G[format("%sIcon", name)]
    local texture  = _G[format("%sNormalTexture", name)]

    if IsEquippedAction(action) then
        texture:SetVertexColor(0.33, 0.59, 0.33, 1)
        if self.gloss then
            self.gloss:SetBackdropColor(0.33, 0.59, 0.33, 0.5)
        end
    else
        texture:SetVertexColor(0.5, 0.5, 0.5, 1)
        if self.gloss then
            self.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0.5)
        end
    end

    local isUsable, notEnoughPower = IsUsableAction(action)

    if ActionHasRange(action) and IsActionInRange(action) == 0 then
        icon:SetVertexColor(0.69, 0.31, 0.31)
        return
    elseif notEnoughPower then
        icon:SetVertexColor(0.31, 0.45, 0.63)
        return
    elseif isUsable then
        icon:SetVertexColor(1, 1, 1)
        return
    else
        icon:SetVertexColor(0.2, 0.2, 0.2)
        return
    end
end

local function caelButtons_FixGrid(self)
    local name = self:GetName()
    local action = self.action
    local texture  = _G[format("%sNormalTexture", name)]
    if IsEquippedAction(action) then
        texture:SetVertexColor(0.33, 0.59, 0.33, 1)
    else
        texture:SetVertexColor(0.5, 0.5, 0.5, 1)
    end  
end

local function caelButtons_OnUpdate(self, elapsed)
    local t = self.cAB_range
    if (not t) then
        self.cAB_range = 0
        return
    end
    t = t + elapsed
    if (t < TOOLTIP_UPDATE_TIME + 0.1) then
        self.cAB_range = t
        return
    else
        self.cAB_range = 0
        caelButtons_ActionUsable(self)
    end
end

ActionButton_OnUpdate = caelButtons_OnUpdate

hooksecurefunc("ActionButton_Update", caelButtons_Action)
hooksecurefunc("ActionButton_UpdateUsable", caelButtons_ActionUsable)
hooksecurefunc("ShapeshiftBar_Update", caelButtons_Shapeshift)
hooksecurefunc("ShapeshiftBar_UpdateState", caelButtons_Shapeshift)
hooksecurefunc("PetActionBar_Update", caelButtons_Pet)
hooksecurefunc("ActionButton_ShowGrid", caelButtons_FixGrid)

--[[    Enable glowing overlays on macros.    ]]

local overlayedSpells = {}

hooksecurefunc("ActionButton_HideOverlayGlow", function(button)
    if button.__LAB_Version then return end

    local actionType, id = GetActionInfo(button.action)

    if actionType == "macro" and overlayedSpells[GetMacroSpell(id) or false] then
        return ActionButton_ShowOverlayedGlow(button)
    end
end)

hooksecurefunc("ActionButton_OnEvent", function(button, event, spellId)
    if event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" or event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
        local spellName = GetSpellInfo(spellId)
        local actionType, id = GetActionInfo(button.action)
        local glowVisible = event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW"

        overlayedSpells[spellName] = glowVisisble

        if actionType == "macro" and GetMacroSpell(id) == spellName then
            if glowVisible then
                return ActionButton_ShowOverlayGlow(button)
            else
                return ActionButton_HideOverlayGlow(button)
            end
        end
    end
end)
