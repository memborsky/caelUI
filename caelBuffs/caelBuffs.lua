local _, caelBuffs = ...

caelBuffs.eventFrame = CreateFrame("Frame", nil, UIParent)

local pixelScale = caelUI.config.PixelScale
local media = caelUI.media

local BuffFrame               = _G["BuffFrame"]
local TemporaryEnchantFrame   = _G["TemporaryEnchantFrame"]
local ConsolidatedBuffs       = _G["ConsolidatedBuffs"]

BuffFrame:SetParent(WatchFrame)
BuffFrame:ClearAllPoints()
BuffFrame:SetPoint("TOPRIGHT", WatchFrame, "TOPLEFT", pixelScale(-50), 0)

local DebuffTypeColor = {
	["Magic"]	= {r = 0.2, g = 0.6, b = 1},
	["Curse"]	= {r = 0.6, g = 0, b = 1},
	["Disease"]	= {r = 0.6, g = 0.4, b = 0},
	["Poison"]	= {r = 0, g = 0.6, b = 0},
}

local updateBuffAnchors = function()
	local numBuffs = 0
	local buff, previousBuff, aboveBuff

	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = _G["BuffButton"..i]
		buff:SetParent(BuffFrame)
		buff.consolidated = nil
		buff.parent = BuffFrame
		buff:ClearAllPoints()
		numBuffs = numBuffs + 1
		i = numBuffs

		if ((i > 1) and (mod(i, 8) == 1)) then
			buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, pixelScale(-5))
			aboveBuff = buff
		elseif i == 1 then
			buff:SetPoint("TOPRIGHT")
			aboveBuff = buff
		else
			buff:SetPoint("RIGHT", previousBuff, "LEFT", pixelScale(-5), 0)
		end
		previousBuff = buff
	end
end

local updateDebuffAnchors = function(buttonName, i)
	local numBuffs = BUFF_ACTUAL_DISPLAY

	local buffRows = ceil(numBuffs / 8)

	local gap = 5

	if buffRows == 0 then
		gap = 0
	end

	local buff = _G[buttonName..i]
	if ((i > 1) and (mod(i, 8) == 1)) then
		buff:SetPoint("TOP", _G[buttonName..(i - 8)], "BOTTOM", 0, pixelScale(-5))
	elseif (i == 1) then
		buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, pixelScale(-(buffRows * (5 + buff:GetHeight()) + gap)))
	else
		buff:SetPoint("RIGHT", _G[buttonName..(i-1)], "LEFT", pixelScale(-5), 0)
	end
end

local updateTempEnchantAnchors = function()
	local numBuffs = BUFF_ACTUAL_DISPLAY
	local numDebuffs = DEBUFF_ACTUAL_DISPLAY

	local buffRows = ceil(numBuffs / 8)
	local debuffRows = ceil(numDebuffs / 8)

	local gap

	if (buffRows + debuffRows) == 0 then
		gap = 0
	elseif buffRows == 0 and debuffRows ~= 0 then
		gap = 5
	else
		gap = 10
	end

	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local buff = _G["TempEnchant"..i]
		if buff then
			if ((i > 1) and (mod(i, 8) == 1)) then
				buff:SetPoint("TOP", _G["TempEnchant"..(i - 8)], "BOTTOM", 0, pixelScale(-5))
			elseif (i == 1) then
				buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, pixelScale(-((buffRows + debuffRows) * (5 + buff:GetHeight()) + gap)))
			else
				buff:SetPoint("RIGHT", _G["TempEnchant"..(i-1)], "LEFT", pixelScale(-5), 0)
			end
		end
	end
end

local durationSetText = function(duration, arg1, arg2)
	duration:SetText(format("|cffffffff"..string.gsub(arg1, " ", "").."|r", arg2))
end

local SkinButton = function(button, buttons)
	if button then
		button:SetSize(pixelScale(28), pixelScale(28))
		local icon = _G[buttons.."Icon"]

		local border = _G[buttons.."Border"]

		if border then
			border:Hide()
		end

		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetDrawLayer("BACKGROUND", 1)

		button.border = CreateFrame("Frame", nil, button)
		button.border:SetPoint("TOPLEFT", pixelScale(-1.5), pixelScale(1.5))
		button.border:SetPoint("BOTTOMRIGHT", pixelScale(1.5), pixelScale(-1.5))
		button.border:SetBackdrop({
			bgFile = media.files.button_normal,
			insets = {top = pixelScale(-1.5), left = pixelScale(-1.5), bottom = pixelScale(-1.5), right = pixelScale(-1.5)},
		})

		button.backdrop = button:CreateTexture(nil, "BACKGROUND")
		button.backdrop:SetPoint("TOPLEFT", pixelScale(-1), pixelScale(1))
		button.backdrop:SetPoint("BOTTOMRIGHT", pixelScale(1), pixelScale(-1))
		button.backdrop:SetTexture(media.files.background)
		button.backdrop:SetVertexColor(0, 0, 0)

		button.gloss = CreateFrame("Frame", nil, button)
		button.gloss:SetAllPoints()
		button.gloss:SetBackdrop({
			bgFile = media.files.button_gloss,
			insets = {top = pixelScale(-1.5), left = pixelScale(-1.5), bottom = pixelScale(-1.5), right = pixelScale(-1.5)},
		})
		button.gloss:SetBackdropColor(0.25, 0.25, 0.25, 0.5)

		button.duration:SetParent(button.gloss)
		button.duration:SetFont(media.fonts.number, 9)
		button.duration:ClearAllPoints()
		button.duration:SetPoint("BOTTOM", 0, pixelScale(-2))
		button.duration:SetJustifyH("CENTER")
		button.duration:SetShadowColor(0, 0, 0)
		button.duration:SetShadowOffset(0.75, -0.75)

		hooksecurefunc(button.duration, "SetFormattedText", durationSetText)

		button.count:SetParent(button.gloss)
		button.count:SetFont(media.fonts.number, 9)
		button.count:ClearAllPoints()
		button.count:SetPoint("TOP", 0, pixelScale(-2))
		button.count:SetJustifyH("CENTER")
		button.count:SetShadowColor(0, 0, 0)
		button.count:SetShadowOffset(0.75, -0.75)

		button.styled = true
	end
end

local checkauras = function(button)
	local color

	for i = 1, BUFF_MAX_DISPLAY do
		local button = _G["BuffButton"..i]
		if button and not button.styled then
			SkinButton(button, "BuffButton"..i)
		end

		if button then
			local _, _, _, _, _, _, _, unitCaster = UnitBuff("player", i)

			if unitCaster then
				color = RAID_CLASS_COLORS[select(2, UnitClass(unitCaster))]
				if color then
					button.border:SetBackdropColor(color.r, color.g, color.b)
				else
					button.border:SetBackdropColor(0, 0, 0)
				end
			else
				button.border:SetBackdropColor(0.33, 0.59, 0.33)
			end
		end


	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		local button = _G["DebuffButton"..i]
		if button and not button.styled then
			SkinButton(button, "DebuffButton"..i)
		end

		if button then
			local _, _, _, _, debuffType = UnitDebuff("player", i)

			if debuffType then
				color = DebuffTypeColor[debuffType]
				button.border:SetBackdropColor(color.r, color.g, color.b)
			else
				button.border:SetBackdropColor(0.69, 0.31, 0.31)
			end
		end
	end

	updateTempEnchantAnchors()
end

for i = 1, NUM_TEMP_ENCHANT_FRAMES do
	SkinButton(_G["TempEnchant"..i], "TempEnchant"..i)
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)

caelBuffs.eventFrame:RegisterEvent("UNIT_AURA")
caelBuffs.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
caelBuffs.eventFrame:SetScript("OnEvent", function(self, event, ...)
	local unit = ...
	if event == "PLAYER_ENTERING_WORLD" then
		checkauras()
	elseif event == "UNIT_AURA" then
		if (unit == PlayerFrame.unit) then
			checkauras()
		end
	end
end)