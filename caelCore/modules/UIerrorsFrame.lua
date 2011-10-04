--[[    $Id$    ]]

local _, caelCore = ...

--[[    Blacklist some UIerrorFrame messages    ]]

local errorFrame = caelCore.createModule("UIerrorFrame")

local eventBlacklist = {
    [ERR_NO_ATTACK_TARGET] = true,
    [ERR_OUT_OF_RAGE] = true,
    [ERR_OUT_OF_ENERGY] = true,
    [ERR_ABILITY_COOLDOWN] = true,
    [ERR_ITEM_COOLDOWN] = true,
    [ERR_SPELL_COOLDOWN] = true,
    [ERR_MUST_EQUIP_ITEM] = true,
    [SPELL_FAILED_NO_COMBO_POINTS] = true,
    [SPELL_FAILED_SPELL_IN_PROGRESS] = true,
    [SPELL_FAILED_CUSTOM_ERROR_32] = true,
    [SPELL_FAILED_AURA_BOUNCED] = true,
}

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

errorFrame:RegisterEvent("UI_ERROR_MESSAGE")

errorFrame:SetScript("OnEvent", function(self, event, error)
    if(not eventBlacklist[error]) then
        --        UIerrorFrame:AddMessage(error, 0.69, 0.31, 0.31)
        recScrollAreas:AddText("|cffAF5050"..error.."|r", false, "Error")
    end
end)
