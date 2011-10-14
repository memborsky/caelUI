local _, caelBars = ...

local pixelScale = caelUI.config.pixelScale
local playerClass = caelUI.config.player.class

local bar1 = CreateFrame("Frame", "bar1", caelPanel_ActionBar1, "SecureHandlerStateTemplate")
bar1:ClearAllPoints()
bar1:SetAllPoints(caelPanel_ActionBar1)

--[[
Bonus bar classes id

DRUID: Caster: 0, Cat: 1, Tree of Life: 0, Bear: 3, Moonkin: 4
WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
ROGUE: Normal: 0, Stealthed: 1
PRIEST: Normal: 0, Shadowform: 1

When Possessing a Target: 5
]]--

local barPage = {
    ["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
    ["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
    ["PRIEST"] = "[bonusbar:1] 7;",
    ["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
    ["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
    local condition = barPage["DEFAULT"]
    local page = barPage[playerClass]

    if page then
        condition = condition.." "..page
    end

    condition = condition.." 1"

    return condition
end

bar1:RegisterEvent("PLAYER_LOGIN")
bar1:RegisterEvent("PLAYER_ENTERING_WORLD")
bar1:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar1:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar1:RegisterEvent("BAG_UPDATE")
bar1:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bar1:SetScript("OnEvent", function(self, event, ...)

    if event == "PLAYER_LOGIN" then

        local button

        for i = 1, NUM_ACTIONBAR_BUTTONS do
            button = _G["ActionButton"..i]
            self:SetFrameRef("ActionButton"..i, button)
        end

        self:Execute([[
        buttons = table.new()
        for i = 1, 12 do
            table.insert(buttons, self:GetFrameRef("ActionButton"..i))
        end
        ]])

        self:SetAttribute("_onstate-page", [[
        for i, button in ipairs(buttons) do
            button:SetAttribute("actionpage", tonumber(newstate))
        end
        ]])

        RegisterStateDriver(self, "page", GetBar())

    elseif event == "PLAYER_ENTERING_WORLD" then

        local button
        for i = 1, 12 do
            button = _G["ActionButton"..i]
            button:SetScale(0.68625)
            button:ClearAllPoints()
            button:SetParent(bar1)
            button:SetAlpha(0.45)

            if i == 1 then
                button:SetPoint("TOPLEFT", caelPanel_ActionBar1, pixelScale(2), pixelScale(-2))
            elseif i == 7 then
                button:SetPoint("TOPLEFT", _G["ActionButton1"], "BOTTOMLEFT", 0, pixelScale(-2))
            else
                button:SetPoint("LEFT", _G["ActionButton"..i-1], "RIGHT", pixelScale(2), 0)
            end
        end

    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        if not IsAddOnLoaded("Blizzard_GlyphUI") then
            LoadAddOn("Blizzard_GlyphUI")
        end
    else
        MainMenuBar_OnEvent(self, event, ...)
    end
end)
