local a = CreateFrame("Frame", "Snoopy", UIParent)

local _G = getfenv(0)
local GameTooltip, strsub = GameTooltip, strsub
local CheckInteractDistance, GetInventoryItemLink = CheckInteractDistance, GetInventoryItemLink
local UnitExists, UnitIsPlayer, UnitCanAttack = UnitExists, UnitIsPlayer, UnitCanAttack
local oInspectPaperDollFrame_OnShow, oInspectPaperDollItemSlotButton_Update

local cache = { }
local elap, schedule, text = 0, 0.25, nil
local UpdateAllData, UpdateUnit, UpdateNote, UpdateTitleText
local nothing = function() end

UnitPopupButtons.INSPECT.dist = 0  -- enables "Inspect" option in dropdown
BINDING_HEADER_INSPECT = INSPECT
BINDING_NAME_INSPECT = INSPECT

a:SetScript("OnEvent", function(self, event, a1)
	self[event](self, a1)
end)
a:Hide()
a:RegisterEvent("ADDON_LOADED")
local hide = PlayerFrameFlash.Hide
function a:ADDON_LOADED(a1)
	if a1 ~= "Blizzard_InspectUI" then return end
	a:UnregisterEvent("ADDON_LOADED")
	a:SetScript("OnEvent", nil)
	a.ADDON_LOADED = nil
	InspectFrame:RegisterEvent("INSPECT_READY")
	InspectFrame:SetScript("OnUpdate", nil)
	if oGlow then
		oGlow.preventInspect = true
	end
	
	function UpdateAllData()  -- try to update all of the inspect window data
		InspectPaperDollFrame_OnShow()
		InspectPVPFrame_OnShow()
		InspectTalentFrame_UpdateTabs()
		SetPortraitTexture(InspectFramePortrait, InspectFrame.unit)
	end
	function UpdateNote(note, timer)  -- inspect status text
		if note then
			elap, schedule = 0, timer
			text:SetText(note)
			a:Show()
		else
			text:SetText("")
			a:Hide()
		end
	end
	function UpdateUnit(unit)  -- update unit
		if not UnitIsPlayer(unit) then return end
		InspectFrame.unit = unit
		ShowUIPanel(InspectFrame)
		NotifyInspect(unit)
		InspectFrameTitleText:SetText(UnitPVPName(unit))
		UpdateTitleText(unit)
		UpdateAllData()
		if not UnitCanAttack("player", unit) then
			UpdateNote(not CheckInteractDistance(unit, 1) and "Out of Inspect Range", 0.25)
		else
			UpdateNote("Cannot Inspect PVP Enemy", 2)
		end
	end
	function UpdateTitleText(unit, reset)
		local gname, gtitle = GetGuildInfo(unit)
		local talenttext = ""
		if not reset and GetNumTalentTabs() > 0 then
			local ctalent = GetActiveTalentGroup(true)
			for j = 1, GetNumTalentGroups(true), 1 do
				for i = 1, 3, 1 do
					local _, name, _, _, pts = GetTalentTabInfo(i, true, false, j)
					if not name then return end
					if i == 1 then
						if j > 1 then
							talenttext = format("%s - ", talenttext)
						end
						if ctalent == j then
							talenttext = format("%s|cffffff00", talenttext)
						end
					end
					talenttext = format("%s%s%d %s%s", talenttext, i == 1 and "" or " / ", pts, strsub(name, 1, 3), (ctalent == 1 and i == 3 and "|r") or "")
				end
			end
		else
			talenttext = "-"
		end
		if gname then
			InspectTitleText:SetFormattedText("%s of <%s>\n%s", gtitle, gname, talenttext)
		else
			InspectTitleText:SetFormattedText("-\n%s", talenttext)
		end
		InspectFrameTitleText:SetText(UnitPVPName(unit))
	end

	InspectFrame_Show = function(unit)
		if not UnitIsPlayer(unit) then return end
		PlaySound("igCharacterInfoOpen")
		UpdateUnit(unit)
	end
	
	InspectFrame_OnEvent = function(self, ev, a1)
		if not InspectFrame:IsShown() then return end
		local unit = InspectFrame.unit
		if ((ev == "PLAYER_TARGET_CHANGED" and unit == "target") or (ev == "PARTY_MEMBERS_CHANGED" and unit ~= "target")) then
			if UnitExists(unit) then
				UpdateUnit(unit)
			end
		elseif ev == "UNIT_PORTRAIT_UPDATE" and unit == a1 then
			SetPortraitTexture(InspectFramePortrait, unit)
			UpdateUnit(unit)
		elseif ev == "UNIT_NAME_UPDATE" and unit == a1 then
			InspectFrameTitleText:SetText(UnitPVPName(unit))
		elseif ev == "INSPECT_READY" then
			UpdateUnit(unit)
		end
	end
	InspectFrame:SetScript("OnEvent", InspectFrame_OnEvent)
	
	oInspectPaperDollItemSlotButton_Update = InspectPaperDollItemSlotButton_Update
	InspectPaperDollItemSlotButton_Update = function(self, ...)
		oInspectPaperDollItemSlotButton_Update(self, ...)
		local id = self:GetID()
		local link
		if CheckInteractDistance(InspectFrame.unit, 1) then
			link = GetInventoryItemLink(InspectFrame.unit, id)
			cache[id] = link
		end
		if oGlow then
			if link then
				local quality = select(3, GetItemInfo(link))
				oGlow(self, quality)
				if self.bc then
					self.bc.Hide = nothing
					if (type(quality) == "number" and quality > 1) or type(quality) == "string" then
						self.bc:Show()
					else
						hide(self.bc)
					end
				end
			elseif self.bc then
				hide(self.bc)
			end
		end
	end
	
	InspectPaperDollItemSlotButton_OnEnter = function(self)
		self = self or this
		local unit, id = InspectFrame.unit, self:GetID()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if UnitExists(unit) and CheckInteractDistance(unit, 1) and GameTooltip:SetInventoryItem(unit, id) then
		
		elseif cache[id] then  -- retrieved from cache
			GameTooltip:SetHyperlink(cache[id])
		else  -- empty slot
			GameTooltip:SetText((self.checkRelic and UnitHasRelicSlot(unit) and _G.RELICSLOT) or _G[strupper(strsub(self:GetName(), 8))])
		end
		CursorUpdate(self)
	end
	
	local function onclick(self, button)
		local unit, id = InspectFrame.unit, self:GetID()
		if UnitExists(unit) and CheckInteractDistance(unit, 1) then
			HandleModifiedItemClick(GetInventoryItemLink(unit, id))
		elseif cache[id] then  -- retrieved from cache
			HandleModifiedItemClick(cache[id])
		end
	end
	local GetFrameType = a.GetFrameType or a.GetObjectType
	for _, frame in ipairs({ InspectPaperDollFrame:GetChildren() }) do
		if GetFrameType(frame) == "Button" and strmatch(frame:GetName() or "", "Inspect(.+)Slot") then
			frame:SetScript("OnClick", onclick)
			frame:SetScript("OnEnter", InspectPaperDollItemSlotButton_OnEnter)
		end
	end
	
	oInspectPaperDollFrame_OnShow = InspectPaperDollFrame_OnShow
	InspectPaperDollFrame_OnShow = function(...)
		if not UnitIsPlayer(InspectFrame.unit) then return end
		oInspectPaperDollFrame_OnShow(...)
	end
	InspectPaperDollFrame:SetScript("OnShow", InspectPaperDollFrame_OnShow)
	
	local oInspectPaperDollFrame_SetLevel = InspectPaperDollFrame_SetLevel
	InspectPaperDollFrame_SetLevel = function(...)
		if UnitExists(InspectFrame.unit) then
			oInspectPaperDollFrame_SetLevel(...)
		end
	end
	
	local oInspectGuildFrame_Update = InspectGuildFrame_Update
	InspectGuildFrame_Update = function(...)
		if UnitExists(InspectFrame.unit) then
			oInspectGuildFrame_Update(...)
		end
	end
	
	InspectFrameTitleText:SetWidth(330)
	InspectTitleText:Show()
	InspectTitleText:SetText("")
	text = InspectFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("TOP", InspectFrame, "TOP", 0, -2)
	text:SetAlpha(0.8)
	
	a:SetScript("OnUpdate", function(this, a1)
		elap = elap + a1
		if elap < schedule then return end
		elap = 0
		
		local unit = InspectFrame.unit
		if not UnitExists(unit) or schedule == 2 then 
			UpdateNote()
		elseif CheckInteractDistance(unit, 1) then
			NotifyInspect(unit)
			UpdateAllData()
			UpdateNote("Inspect Successful", 2)
		end
	end)
end
