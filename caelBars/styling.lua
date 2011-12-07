local media = caelUI.media
local pixel_scale = caelUI.config.pixel_scale
local player_class = caelUI.config.player.class
local class_color = RAID_CLASS_COLORS[player_class]

local hideHotkeys = false

local function StyleButton(name, action)

    local isPet        = name:find("PetActionButton")
    local isShapeshift = name:find("ShapeshiftButton")

    local button    = _G[name]
    local border    = _G[name .. "Border"]
    local icon      = _G[name .. "Icon"]
    local flash     = _G[name .. "Flash"]
    local cooldown  = _G[name .. "Cooldown"]
    local texture   = (isPet or isShapeshift) and _G[name .. "NormalTexture2"] or _G[name .. "NormalTexture"]

    button:SetNormalTexture("")

    -- Mouse over button color change.
    local hover = button:CreateTexture("Frame", nil, self)
    hover:SetTexture(class_color.r, class_color.g, class_color.b, 0.75)
    hover:SetHeight(button:GetHeight())
    hover:SetWidth(button:GetWidth())
    hover:SetPoint("TOPLEFT", button, pixel_scale(3), -pixel_scale(3))
    hover:SetPoint("BOTTOMRIGHT", button, -pixel_scale(3), pixel_scale(3))
    button:SetHighlightTexture(hover)

    -- Button pushes color change.
    local pushed = button:CreateTexture("Frame", nil, self)
    pushed:SetTexture(85 / 255, 98 / 255, 112 / 255, 1)
    pushed:SetHeight(button:GetHeight())
    pushed:SetWidth(button:GetWidth())
    pushed:SetPoint("TOPLEFT", button, pixel_scale(3), -pixel_scale(3))
    pushed:SetPoint("BOTTOMRIGHT", button, -pixel_scale(3), pixel_scale(3))
    button:SetPushedTexture(pushed)

    -- Checked button color change.
    local checked = button:CreateTexture("Frame", nil, self)
    checked:SetTexture(199 / 255, 244 / 255, 100 / 255, 0.4)
    checked:SetHeight(button:GetHeight())
    checked:SetWidth(button:GetWidth())
    checked:SetPoint("TOPLEFT", button, pixel_scale(3), -pixel_scale(3))
    checked:SetPoint("BOTTOMRIGHT", button, -pixel_scale(3), pixel_scale(3))
    button:SetCheckedTexture(checked)

    -- if border then
    --     border:ClearAllPoints()
    --     border:SetTexture("")
    --     border:Hide()
    -- end

    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetAllPoints(button)
    icon:SetPoint("TOPLEFT", button, pixel_scale(4), -pixel_scale(4))
    icon:SetPoint("BOTTOMRIGHT", button, -pixel_scale(4), pixel_scale(4))

    flash:SetTexture(0, 1, 0, 1)

    cooldown:SetParent(button)
    cooldown:ClearAllPoints()
    cooldown:SetAllPoints(icon)

    if texture then
        texture:SetAllPoints()
        texture:SetVertexColor(0, 0, 0, 1)
    end

    if not button.backdrop then
        button.backdrop = CreateFrame("Frame", nil, button)
        button.backdrop:SetSize(button:GetSize())
        button.backdrop:SetAllPoints(button)
        button.backdrop:SetBackdrop(media.border_table)
        button.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    end

    if action then
        local count  = _G[name .. "Count"]
        local hotkey = _G[name .. "HotKey"]
        local name   = _G[name .. "Name"]

        if count then
            count:SetParent(button)

            count:SetFont(media.fonts.normal, 12, "OUTLINEMONOCHROME")
            count:SetPoint("BOTTOMRIGHT", pixel_scale(3), pixel_scale(-1))
        end

        if not hideHotkeys then
            hotkey:SetFont(media.fonts.normal, 12, "OUTLINE")
            hotkey:SetShadowColor(0, 0, 0, 0.5)
            hotkey:SetShadowOffset(2, -2)
            hotkey:ClearAllPoints()
            hotkey:SetPoint("TOPRIGHT")
        else
            hotkey:Hide()
            hotkey.Show = hotkey.Hide
        end

        if name then
            name:Hide()
        end
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
    local icon = _G[self:GetName() .. "Icon"]

    local isUsable, notEnoughPower = IsUsableAction(self.action)

    if ActionHasRange(self.action) and IsActionInRange(self.action) == 0 then
        icon:SetVertexColor(196 / 255, 77 / 255, 88 / 255, 1)
        return
    elseif notEnoughPower then
        icon:SetVertexColor(0, 0, 0, 1)
        return
    elseif isUsable then
        icon:SetVertexColor(1, 1, 1, 1)
        return
    else
        icon:SetVertexColor(16 / 255, 127 / 255, 201 / 255, 1)
        return
    end
end

local function caelButtons_FixGrid(button)
    local texture = _G[button:GetName() .. "NormalTexture"]

    if texture then
        if IsEquippedAction(button.action) then
            texture:SetVertexColor(0.33, 0.59, 0.33, 1)
        else
            texture:SetVertexColor(0.5, 0.5, 0.5, 1)
        end
    end
end

local function caelButtons_OnUpdate(self, elapsed)
    local time = self.cAB_range

    if (not time) then
        self.cAB_range = 0
        return
    end

    if (time < TOOLTIP_UPDATE_TIME + 0.1) then
        self.cAB_range = time
        return
    else
        self.cAB_range = 0
        caelButtons_ActionUsable(self)
    end

    time = time + elapsed
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
