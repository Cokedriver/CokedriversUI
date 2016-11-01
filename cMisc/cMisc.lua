
-- Enable Seperate Parts of cMISC
db = {
	cMerchant = true,
	cRareAlert = true,
	cPowerBar = true,
	cMiniMap = true,
	cAltBuy = true,
	cAutogreed = true,
	cChatBubble = false,
	cAuction = true,
	cSpellID = true,
	cCoords = true,
}


-- Coords From NeavUI
if db.cCoords == true then
	local CoordsFrame = CreateFrame('Frame', nil, WorldMapFrame)
	CoordsFrame:SetParent(WorldMapFrame.BorderFrame)

	CoordsFrame.Player = CoordsFrame:CreateFontString(nil, 'OVERLAY')
	CoordsFrame.Player:SetFont('Fonts\\ARIALN.ttf', 15, 'THINOUTLINE')
	CoordsFrame.Player:SetJustifyH('LEFT')
	CoordsFrame.Player:SetPoint('BOTTOM', WorldMapFrame.BorderFrame, "BOTTOM", -100, 8)
	CoordsFrame.Player:SetTextColor(1, 0.82, 0)

	CoordsFrame.Cursor = CoordsFrame:CreateFontString(nil, 'OVERLAY')
	CoordsFrame.Cursor:SetFont('Fonts\\ARIALN.ttf', 15, 'THINOUTLINE')
	CoordsFrame.Cursor:SetJustifyH('LEFT')
	CoordsFrame.Cursor:SetPoint('BOTTOMLEFT', CoordsFrame.Player, "BOTTOMLEFT", 120, 0)
	CoordsFrame.Cursor:SetTextColor(1, 0.82, 0)

	CoordsFrame:SetScript('OnUpdate', function(self, elapsed)
		local width = WorldMapDetailFrame:GetWidth()
		local height = WorldMapDetailFrame:GetHeight()
		local mx, my = WorldMapDetailFrame:GetCenter()
		local px, py = GetPlayerMapPosition('player')
		local cx, cy = GetCursorPosition()
		
		if (px) then
			mx = ((cx / WorldMapDetailFrame:GetEffectiveScale()) - (mx - width / 2)) / width
			my = ((my + height / 2) - (cy / WorldMapDetailFrame:GetEffectiveScale())) / height

			if (mx >= 0 and my >= 0 and mx <= 1 and my <= 1) then
				CoordsFrame.Cursor:SetText(MOUSE_LABEL..format(': %.0f x %.0f', mx * 100, my * 100))
			else
				CoordsFrame.Cursor:SetText('')
			end

			if (px ~= 0 and py ~= 0) then
				CoordsFrame.Player:SetText(" "..PLAYER..format(': %.0f x %.0f', px * 100, py * 100).." / ")
			else
				CoordsFrame.Player:SetText('')
			end
		else
			CoordsFrame.Cursor:SetText('')
			CoordsFrame.Player:SetText('')
		end
	end)
end
-- SpellID From NeavUI
if db.cSpellID == true then
	hooksecurefunc(GameTooltip, 'SetUnitBuff', function(self,...)
		local id = select(11, UnitBuff(...))
		if (id) then
			self:AddLine('SpellID: '..id, 1, 1, 1)
			self:Show()
		end
	end)

	hooksecurefunc(GameTooltip, 'SetUnitDebuff', function(self,...)
		local id = select(11, UnitDebuff(...))
		if (id) then
			self:AddLine('SpellID: '..id, 1, 1, 1)
			self:Show()
		end
	end)

	hooksecurefunc(GameTooltip, 'SetUnitAura', function(self,...)
		local id = select(11, UnitAura(...))
		if (id) then
			self:AddLine('SpellID: '..id, 1, 1, 1)
			self:Show()
		end
	end)

	hooksecurefunc('SetItemRef', function(link, text, button, chatFrame)
		if (string.find(link,'^spell:')) then
			local id = string.sub(link, 7)
			ItemRefTooltip:AddLine('SpellID: '..id, 1, 1, 1)
			ItemRefTooltip:Show()
		end
	end)

	GameTooltip:HookScript('OnTooltipSetSpell', function(self)
		local id = select(3, self:GetSpell())
		if (id) then
			-- Workaround for weird issue when this gets triggered twice on the Talents frame
			-- https://github.com/renstrom/NeavUI/issues/76
			for i = 1, self:NumLines() do
				if _G['GameTooltipTextLeft'..i]:GetText() == 'SpellID: '..id then
					return
				end
			end

			self:AddLine('SpellID: '..id, 1, 1, 1)
			self:Show()
		end
	end)

end

-- Merchant
if db.cMerchant == true then
	local merchantUseGuildRepair = false	-- let your guild pay for your repairs if they allow.

	local MerchantFilter = {
		[6289]  = true, -- Raw Longjaw Mud Snapper
		[6291]  = true, -- Raw Brilliant Smallfish
		[6308]  = true, -- Raw Bristle Whisker Catfish
		[6309]  = true, -- 17 Pound Catfish
		[6310]  = true, -- 19 Pound Catfish
		[41808] = true, -- Bonescale Snapper
		[42336] = true, -- Bloodstone Band
		[42337] = true, -- Sun Rock Ring
		[43244] = true, -- Crystal Citrine Necklace
		[43571] = true, -- Sewer Carp
		[43572] = true, -- Magic Eater		
	}

	local Merchant_Frame = CreateFrame("Frame")
	Merchant_Frame:SetScript("OnEvent", function()
		local Cost = 0
		
		for Bag = 0, 4 do
			for Slot = 1, GetContainerNumSlots(Bag) do
				local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
				
				if (Link and ID) then
					local Price = 0
					local Mult1, Mult2 = select(11, GetItemInfo(Link)), select(2, GetContainerItemInfo(Bag, Slot))
					
					if (Mult1 and Mult2) then
						Price = Mult1 * Mult2
					end
					
					if (select(3, GetItemInfo(Link)) == 0 and Price > 0) then
						UseContainerItem(Bag, Slot)
						PickupMerchantItem()
						Cost = Cost + Price
					end
					
					if MerchantFilter[ID] then
						UseContainerItem(Bag, Slot)
						PickupMerchantItem()
						Cost = Cost + Price
					end
				end
			end
		end
		
		if (Cost > 0) then
			local Gold, Silver, Copper = math.floor(Cost / 10000) or 0, math.floor((Cost % 10000) / 100) or 0, Cost % 100
			
			DEFAULT_CHAT_FRAME:AddMessage("Your grey item's have been sold for".." |cffffffff"..Gold.."|cffffd700g|r".." |cffffffff"..Silver.."|cffc7c7cfs|r".." |cffffffff"..Copper.."|cffeda55fc|r"..".",255,255,0)
		end
		
		if (not IsShiftKeyDown()) then
			if CanMerchantRepair() then
				local Cost, Possible = GetRepairAllCost()
				
				if (Cost > 0) then
					if (IsInGuild() and merchantUseGuildRepair) then
						local CanGuildRepair = (CanGuildBankRepair() and (Cost <= GetGuildBankWithdrawMoney()))
						
						if CanGuildRepair then
							RepairAllItems(1)
							
							return
						end
					end
					
					if Possible then
						RepairAllItems()
						
						local Copper = Cost % 100
						local Silver = math.floor((Cost % 10000) / 100)
						local Gold = math.floor(Cost / 10000)
						if guildRepairFlag == 1 then
							DEFAULT_CHAT_FRAME:AddMessage("Your guild payed".." |cffffffff"..Gold.."|cffffd700g|r".." |cffffffff"..Silver.."|cffc7c7cfs|r".." |cffffffff"..Copper.."|cffeda55fc|r".." to repair your gear.",255,255,0)
						else
							DEFAULT_CHAT_FRAME:AddMessage("You payed".." |cffffffff"..Gold.."|cffffd700g|r".." |cffffffff"..Silver.."|cffc7c7cfs|r".." |cffffffff"..Copper.."|cffeda55fc|r".." to repair your gear.",255,255,0)
						end
					else
						DEFAULT_CHAT_FRAME:AddMessage("You don't have enough money for repair!", 255, 0, 0)
					end
				end
			end
		end		
	end)

	Merchant_Frame:RegisterEvent("MERCHANT_SHOW")
end

--Minimap
if db.cMiniMap == true then

    -- Bigger Minimap
	MinimapCluster:SetScale(1.2) 
	MinimapCluster:EnableMouse(false)
	
	-- Garrison Button
	GarrisonLandingPageMinimapButton:SetSize(36, 36)

    -- Hide all Unwanted Things	
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	 	 
	MiniMapTracking:UnregisterAllEvents()
	MiniMapTracking:Hide()

	
	-- Enable Mousewheel Zooming
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, delta)
		if (delta > 0) then
			_G.MinimapZoomIn:Click()
		elseif delta < 0 then
			_G.MinimapZoomOut:Click()
		end
	end)

	-- Modify the Minimap Tracking		
	Minimap:SetScript('OnMouseUp', function(self, button)
		if (button == 'RightButton') then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
		else
			Minimap_OnClick(self)
		end
	end)
end

-- Autogreed from NeavUI
if db.cAutogreed == true then

	-- A skip list for green stuff you might not wanna auto-greed on
	local skipList = {
		--['Stone Scarab'] = true,
		--['Silver Scarab'] = true,
	}

	local AutogreedFrame = CreateFrame('Frame')
	AutogreedFrame:RegisterEvent('START_LOOT_ROLL')
	AutogreedFrame:SetScript('OnEvent', function(_, _, rollID)
		local _, name, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(rollID)
		if (quality == 2 and not BoP and not skipList[name]) then
			RollOnLoot(rollID, canDisenchant and 3 or 2)
		end
	end)
end

--ChatBubble Frame from NeavUI
if db.cChatBubble == true then
	local events = {
		CHAT_MSG_SAY = 'chatBubbles', 
		CHAT_MSG_YELL = 'chatBubbles',
		CHAT_MSG_PARTY = 'chatBubblesParty', 
		CHAT_MSG_PARTY_LEADER = 'chatBubblesParty',
		CHAT_MSG_MONSTER_SAY = 'chatBubbles', 
		CHAT_MSG_MONSTER_YELL = 'chatBubbles', 
		CHAT_MSG_MONSTER_PARTY = 'chatBubblesParty',
	}

	local function SkinFrame(frame)
		for i = 1, select('#', frame:GetRegions()) do
			local region = select(i, frame:GetRegions())
			if (region:GetObjectType() == 'FontString') then
				frame.text = region
			else
				region:Hide()
			end
		end

		frame.text:SetFontObject('GameFontHighlight')
		frame.text:SetJustifyH('LEFT')

		frame:ClearAllPoints()
		frame:SetPoint('TOPLEFT', frame.text, -10, 25)
		frame:SetPoint('BOTTOMRIGHT', frame.text, 10, -10)
		frame:SetBackdrop({
			bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
			edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
			tileSize = 16,
			edgeSize = 16,
			insets = {left=3, right=3, top=3, bottom=3},
		})
		frame:SetBackdropColor(0, 0, 0, 1)
		frame:SetBackdropBorderColor(.5, .5, .5, 0.9)

		frame.sender = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		frame.sender:SetPoint('BOTTOMLEFT', frame.text, 'TOPLEFT', 0, 4)
		frame.sender:SetJustifyH('LEFT')

		frame:HookScript('OnHide', function() 
			frame.inUse = false 
		end)
	end

	local function UpdateFrame(frame, guid, name)
		if (not frame.text) then 
			SkinFrame(frame) 
		end
		frame.inUse = true

		local class
		if (guid ~= nil and guid ~= '') then
			_, class, _, _, _, _ = GetPlayerInfoByGUID(guid)
		end

		if (name) then
			local color = RAID_CLASS_COLORS[class] or { r = 0.5, g = 0.5, b = 0.5 }
			frame.sender:SetText(('|cFF%2x%2x%2x%s|r'):format(color.r * 255, color.g * 255, color.b * 255, name))
			if frame.text:GetWidth() < frame.sender:GetWidth() then
				frame.text:SetWidth(frame.sender:GetWidth())
			end
		end
	end

	local function FindFrame(msg)
		for i = 1, WorldFrame:GetNumChildren() do
			local frame = select(i, WorldFrame:GetChildren())
			if (not frame:GetName() and not frame.inUse) then
				for i = 1, select('#', frame:GetRegions()) do
					local region = select(i, frame:GetRegions())
					if region:GetObjectType() == 'FontString' and region:GetText() == msg then
						return frame
					end
				end
			end
		end
	end

	local ChatBubbleFrame = CreateFrame('Frame')
	for event, cvar in pairs(events) do 
		ChatBubbleFrame:RegisterEvent(event) 
	end

	ChatBubbleFrame:SetScript('OnEvent', function(self, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
		if (GetCVarBool(events[event])) then
			ChatBubbleFrame.elapsed = 0
			ChatBubbleFrame:SetScript('OnUpdate', function(self, elapsed)
				self.elapsed = self.elapsed + elapsed
				local frame = FindFrame(msg)
				if (frame or self.elapsed > 0.3) then
					ChatBubbleFrame:SetScript('OnUpdate', nil)
					if (frame) then 
						UpdateFrame(frame, guid, sender) 
					end
				end
			end)
		end
	end)
end

-- Powerbar From NeavUI
if db.cPowerBar == true then
	local PowerDB = {
		position = {'CENTER', UIParent, 0, -110},
		sizeWidth = 200,		
		scale = 1.0,

		showCombatRegen = true,

		activeAlpha = 1,
		inactiveAlpha = 0.3,
		emptyAlpha = 0,

		valueAbbrev = true,

		valueFont = 'Fonts\\ARIALN.ttf',
		valueFontSize = 20,
		valueFontOutline = true,
		valueFontAdjustmentX = 0,

		showSoulshards = true,
		showHolypower = true,
		showComboPoints = true,
		showChi = true,
		showRunes = true,
		showArcaneCharges = true,

		-- Resource text shown above the bar.
		extraFont = 'Fonts\\ARIALN.ttf',
		extraFontSize = 22,
		extraFontOutline = true,

		mana = {
			show = true,
		},

		energy = {
			show = true,
		},

		focus = {
			show = true,
		},

		rage = {
			show = true,
		},

		lunarPower = {
			show = true,
		},

		rune = {
			show = true,

			runeFont = 'Fonts\\ARIALN.ttf',
			runeFontSize = 20,
			runeFontOutline = true,
		},

		insanity = {
			show = true,
		},

		maelstrom = {
			show = true,
		},

		fury = {
			show = true,
		},

		pain = {
			show = true,
		},
	}

	local format = string.format
	local floor = math.floor

	local function FormatValue(self)
		if (self >= 10000) then
			return ('%.1fk'):format(self / 1e3)
		else
			return self
		end
	end

	local function PowerRound(num, idp)
		local mult = 10^(idp or 0)
		return floor(num * mult + 0.5) / mult
	end

	local function PowerFade(frame, timeToFade, startAlpha, endAlpha)
		if (PowerRound(frame:GetAlpha(), 1) ~= endAlpha) then
			local mode = startAlpha > endAlpha and 'In' or 'Out'
			securecall('UIFrameFade'..mode, frame, timeToFade, startAlpha, endAlpha)
		end
	end

	local playerClass = select(2, UnitClass('player'))

	local PBFrame = CreateFrame('Frame', nil, UIParent)
	PBFrame:SetScale(PowerDB.scale)
	PBFrame:SetSize(18, 18)
	PBFrame:SetPoint(unpack(PowerDB.position))
	PBFrame:EnableMouse(false)

	PBFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	PBFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	PBFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
	PBFrame:RegisterUnitEvent('UNIT_COMBO_POINTS', 'player')
	PBFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
	PBFrame:RegisterEvent('RUNE_TYPE_UPDATE')
	PBFrame:RegisterUnitEvent('UNIT_DISPLAYPOWER', 'player')
	PBFrame:RegisterUnitEvent('UNIT_POWER_FREQUENT', 'player')
	PBFrame:RegisterEvent('UPDATE_SHAPESHIFT_FORM')

	if (PowerDB.showCombatRegen) then
		PBFrame:RegisterUnitEvent('UNIT_AURA', 'player')
	end

	PBFrame:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
	PBFrame:RegisterUnitEvent('UNIT_ENTERING_VEHICLE', 'player')
	PBFrame:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
	PBFrame:RegisterUnitEvent('UNIT_EXITING_VEHICLE', 'player')

	if (playerClass == 'WARLOCK' and PowerDB.showSoulshards
		or playerClass == 'PALADIN' and PowerDB.showHolypower
		or playerClass == 'ROGUE' and PowerDB.showComboPoints
		or playerClass == 'DRUID' and PowerDB.showComboPoints
		or playerClass == 'MONK' and PowerDB.showChi
		or playerClass == 'MAGE' and PowerDB.showArcaneCharges) then

		PBFrame.extraPoints = PBFrame:CreateFontString(nil, 'ARTWORK')

		if (PowerDB.extraFontOutline) then
			PBFrame.extraPoints:SetFont(PowerDB.extraFont, PowerDB.extraFontSize, 'THINOUTLINE')
			PBFrame.extraPoints:SetShadowOffset(0, 0)
		else
			PBFrame.extraPoints:SetFont(PowerDB.extraFont, PowerDB.extraFontSize)
			PBFrame.extraPoints:SetShadowOffset(1, -1)
		end

		PBFrame.extraPoints:SetParent(PBFrame)
		PBFrame.extraPoints:SetPoint('CENTER', 0, 0)
	end

	if (playerClass == 'DEATHKNIGHT' and PowerDB.showRunes) then
		for i = 1, 7 do
			RuneFrame:UnregisterAllEvents()
			_G['RuneButtonIndividual'..i]:Hide()
		end
		PBFrame.Rune = {}

		for i = 1, 6 do
			PBFrame.Rune[i] = PBFrame:CreateFontString(nil, 'ARTWORK')

			if (PowerDB.rune.runeFontOutline) then
				PBFrame.Rune[i]:SetFont(PowerDB.rune.runeFont, PowerDB.rune.runeFontSize, 'THINOUTLINE')
				PBFrame.Rune[i]:SetShadowOffset(0, 0)
			else
				PBFrame.Rune[i]:SetFont(PowerDB.rune.runeFont, PowerDB.rune.runeFontSize)
				PBFrame.Rune[i]:SetShadowOffset(1, -1)
			end

			PBFrame.Rune[i]:SetShadowOffset(0, 0)
			PBFrame.Rune[i]:SetParent(PBFrame)
		end

		PBFrame.Rune[1]:SetPoint('CENTER', -65, 0)
		PBFrame.Rune[2]:SetPoint('CENTER', -39, 0)
		PBFrame.Rune[3]:SetPoint('CENTER', 39, 0)
		PBFrame.Rune[4]:SetPoint('CENTER', 65, 0)
		PBFrame.Rune[5]:SetPoint('CENTER', -13, 0)
		PBFrame.Rune[6]:SetPoint('CENTER', 13, 0)
	end

	PBFrame.Power = CreateFrame('StatusBar', nil, UIParent)
	PBFrame.Power:SetScale(PBFrame:GetScale())
	PBFrame.Power:SetSize(PowerDB.sizeWidth, 8)
	PBFrame.Power:SetPoint('CENTER', PBFrame, 0, -28)
	PBFrame.Power:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	PBFrame.Power:SetAlpha(0)

	PBFrame.Power.Value = PBFrame.Power:CreateFontString(nil, 'ARTWORK')

	if (PowerDB.valueFontOutline) then
		PBFrame.Power.Value:SetFont(PowerDB.valueFont, PowerDB.valueFontSize, 'THINOUTLINE')
		PBFrame.Power.Value:SetShadowOffset(0, 0)
	else
		PBFrame.Power.Value:SetFont(PowerDB.valueFont, PowerDB.valueFontSize)
		PBFrame.Power.Value:SetShadowOffset(1, -1)
	end

	PBFrame.Power.Value:SetPoint('CENTER', PBFrame.Power, 0, PowerDB.valueFontAdjustmentX)
	PBFrame.Power.Value:SetVertexColor(1, 1, 1)

	PBFrame.Power.Background = PBFrame.Power:CreateTexture(nil, 'BACKGROUND')
	PBFrame.Power.Background:SetAllPoints(PBFrame.Power)
	PBFrame.Power.Background:SetTexture([[Interface\DialogFrame\UI-DialogBox-Background-Dark]])
	PBFrame.Power.Background:SetVertexColor(0.25, 0.25, 0.25, 1)

	PBFrame.Power.Below = PBFrame.Power:CreateTexture(nil, 'BACKGROUND')
	PBFrame.Power.Below:SetHeight(14)
	PBFrame.Power.Below:SetWidth(14)
	PBFrame.Power.Below:SetTexture([[Interface\AddOns\cMisc\Media\textureArrowBelow]])

	PBFrame.Power.Above = PBFrame.Power:CreateTexture(nil, 'BACKGROUND')
	PBFrame.Power.Above:SetHeight(14)
	PBFrame.Power.Above:SetWidth(14)
	PBFrame.Power.Above:SetTexture([[Interface\AddOns\cMisc\Media\textureArrowAbove]])
	PBFrame.Power.Above:SetPoint('BOTTOM', PBFrame.Power.Below, 'TOP', 0, PBFrame.Power:GetHeight())

	if (PowerDB.showCombatRegen) then
		PBFrame.mpreg = PBFrame.Power:CreateFontString(nil, 'ARTWORK')
		PBFrame.mpreg:SetFont(PowerDB.valueFont, 12, 'THINOUTLINE')
		PBFrame.mpreg:SetShadowOffset(0, 0)
		PBFrame.mpreg:SetPoint('TOP', PBFrame.Power.Below, 'BOTTOM', 0, 4)
		PBFrame.mpreg:SetParent(PBFrame.Power)
		PBFrame.mpreg:Show()
	end

	local function GetRealMpFive()
		local _, activeRegen = GetPowerRegen()
		local realRegen = activeRegen * 5
		local _, powerType = UnitPowerType('player')

		if (powerType == 'MANA' or UnitHasVehicleUI('player')) then
			return math.floor(realRegen)
		else
			return ''
		end
	end

	local function SetPowerColor()
		local powerType
		if ( playerClass == 'ROGUE' or playerClass == 'DRUID' ) then
			powerType = SPELL_POWER_COMBO_POINTS
		elseif ( playerClass == 'MONK' ) then
			powerType = SPELL_POWER_CHI
		elseif ( playerClass == 'MAGE' ) then
			powerType = SPELL_POWER_ARCANE_CHARGES
		elseif ( playerClass == 'PALADIN' ) then
			powerType = SPELL_POWER_HOLY_POWER
		elseif ( playerClass == 'WARLOCK' ) then
			powerType = SPELL_POWER_SOUL_SHARDS
		end
			
		local currentPower = UnitPower("player", powerType)
		local maxPower = UnitPowerMax("player", powerType)

		if ( UnitIsDeadOrGhost('target') ) then
			return 1, 1, 1
		elseif ( currentPower == maxPower-1 ) then
			return 0.9, 0.7, 0.0
		elseif ( currentPower == maxPower ) then
			return 1, 0, 0
		else
			return 1, 1, 1
		end
	end

	local function CalcRuneCooldown(self)
		local start, duration, runeReady = GetRuneCooldown(self)
		local time = floor(GetTime() - start)
		local cooldown = ceil(duration - time)

		if (runeReady or UnitIsDeadOrGhost('player')) then
			return '#'
		elseif (not UnitIsDeadOrGhost('player') and cooldown) then
			return cooldown
		end
	end

	local function UpdateBarVisibility()
		local _, powerType = UnitPowerType('player')
		local newAlpha = nil

		if ((not PowerDB.energy.show and powerType == 'ENERGY')
			or (not PowerDB.focus.show and powerType == 'FOCUS')
			or (not PowerDB.rage.show and powerType == 'RAGE')
			or (not PowerDB.mana.show and powerType == 'MANA')
			or (not PowerDB.rune.show and powerType == 'RUNEPOWER')
			or (not PowerDB.fury.show and powerType == 'FURY')
			or (not PowerDB.pain.show and powerType == 'PAIN')
			or (not PowerDB.lunarPower.show and powerType == 'LUNAR_POWER')
			or (not PowerDB.insanity.show and powerType == 'INSANITY')
			or (not PowerDB.maelstrom.show and powerType == 'MAELSTROM')
			or UnitIsDeadOrGhost('player') or UnitHasVehicleUI('player')) then
			PBFrame.Power:SetAlpha(0)
		elseif (InCombatLockdown()) then
			newAlpha = PowerDB.activeAlpha
		elseif (not InCombatLockdown() and UnitPower('player') > 0) then
			newAlpha = PowerDB.inactiveAlpha
		else
			newAlpha = PowerDB.emptyAlpha
		end

		if (newAlpha) then
			PowerFade(PBFrame.Power, 0.3, PBFrame.Power:GetAlpha(), newAlpha)
		end
	end

	local function UpdateArrow()
		if (UnitPower('player') == 0) then
			PBFrame.Power.Below:SetAlpha(0.3)
			PBFrame.Power.Above:SetAlpha(0.3)
		else
			PBFrame.Power.Below:SetAlpha(1)
			PBFrame.Power.Above:SetAlpha(1)
		end

		local newPosition = UnitPower('player') / UnitPowerMax('player') * PBFrame.Power:GetWidth()
		PBFrame.Power.Below:SetPoint('TOP', PBFrame.Power, 'BOTTOMLEFT', newPosition, 0)
	end

	local function UpdateBarValue()
		local min = UnitPower('player')
		PBFrame.Power:SetMinMaxValues(0, UnitPowerMax('player', f))
		PBFrame.Power:SetValue(min)

		if (PowerDB.valueAbbrev) then
			PBFrame.Power.Value:SetText(min > 0 and FormatValue(min) or '')
		else
			PBFrame.Power.Value:SetText(min > 0 and min or '')
		end
	end

	local function UpdateBarColor()
		local powerType, powerToken, altR, altG, altB = UnitPowerType('player')
		local unitPower = PowerBarColor[powerToken]

		if (unitPower) then
			if ( powerType == 0 ) then
				PBFrame.Power:SetStatusBarColor(0,0.55,1)
			else
				PBFrame.Power:SetStatusBarColor(unitPower.r, unitPower.g, unitPower.b)
			end
		else
			PBFrame.Power:SetStatusBarColor(altR, altG, altB)
		end
	end

	local function UpdateBar()
		UpdateBarColor()
		UpdateBarValue()
		UpdateArrow()
	end

	PBFrame:SetScript('OnEvent', function(self, event, arg1)
		if (PBFrame.extraPoints) then
			if (UnitHasVehicleUI('player')) then
				if (PBFrame.extraPoints:IsShown()) then
					PBFrame.extraPoints:Hide()
				end
			else
				local nump
				if (playerClass == 'WARLOCK') then
					nump = UnitPower('player', SPELL_POWER_SOUL_SHARDS)
				elseif (playerClass == 'PALADIN') then
					nump = UnitPower('player', SPELL_POWER_HOLY_POWER)
				elseif (playerClass == 'ROGUE' or playerClass == 'DRUID' ) then
					nump = UnitPower('player', SPELL_POWER_COMBO_POINTS)
				elseif (playerClass == 'MONK' ) then
					nump = UnitPower('player', SPELL_POWER_CHI)
				elseif (playerClass == 'MAGE' ) then
					nump = UnitPower('player', SPELL_POWER_ARCANE_CHARGES)
				end

				PBFrame.extraPoints:SetTextColor(SetPowerColor())
				PBFrame.extraPoints:SetText(nump == 0 and '' or nump)

				if (not PBFrame.extraPoints:IsShown()) then
					PBFrame.extraPoints:Show()
				end
			end
		end

		if (PBFrame.mpreg and (event == 'UNIT_AURA' or event == 'PLAYER_ENTERING_WORLD')) then
			PBFrame.mpreg:SetText(GetRealMpFive())
		end

		UpdateBar()
		UpdateBarVisibility()

		if (event == 'PLAYER_ENTERING_WORLD') then
			if (InCombatLockdown()) then
				securecall('UIFrameFadeIn', PBFrame, 0.35, PBFrame:GetAlpha(), 1)
			else
				securecall('UIFrameFadeOut', PBFrame, 0.35, PBFrame:GetAlpha(), PowerDB.inactiveAlpha)
			end
		end

		if (event == 'PLAYER_REGEN_DISABLED') then
			securecall('UIFrameFadeIn', PBFrame, 0.35, PBFrame:GetAlpha(), 1)
		end

		if (event == 'PLAYER_REGEN_ENABLED') then
			securecall('UIFrameFadeOut', PBFrame, 0.35, PBFrame:GetAlpha(), PowerDB.inactiveAlpha)
		end
	end)

	if (PBFrame.Rune) then
		local updateTimer = 0
		PBFrame:SetScript('OnUpdate', function(self, elapsed)
			updateTimer = updateTimer + elapsed

			if (updateTimer > 0.1) then
				for i = 1, 6 do
					if (UnitHasVehicleUI('player')) then
						if (PBFrame.Rune[i]:IsShown()) then
							PBFrame.Rune[i]:Hide()
						end
					else
						if (not PBFrame.Rune[i]:IsShown()) then
							PBFrame.Rune[i]:Show()
						end
					end

					PBFrame.Rune[i]:SetText(CalcRuneCooldown(i))
					PBFrame.Rune[i]:SetTextColor(0.0, 0.6, 0.8)
				end

				updateTimer = 0
			end
		end)
	end
end

-- Rare Alert
if db.cRareAlert == true then
	local blacklist = {
		[971] = true, -- Alliance garrison
		[976] = true, -- Horde garrison
	}

	local RareFrame = CreateFrame("Frame")
	RareFrame:RegisterEvent("VIGNETTE_ADDED")
	RareFrame:SetScript("OnEvent", function()
		if blacklist[GetCurrentMapAreaID()] then return end

		PlaySoundFile("Sound\\Spells\\PVPFlagTaken.ogg")
		RaidNotice_AddMessage(RaidWarningFrame, "Rare Spotted!", ChatTypeInfo["RAID_WARNING"])
	end)
end


-- From daftAuction by Daftwise - US Destromath
if db.cAuction == true then
	local undercutPercent = .97

	local duration = 3 -- 1, 2, 3 for 12h, 24h, 48h


	local PRICE_BY = "VENDOR" -- QUALITY or VENDOR

	-- PRICE BY QUALITY, where 1000 = 1 gold
		local POOR_PRICE = 100000
		local COMMON_PRICE = 200000
		local UNCOMMON_PRICE = 2500000
		local RARE_PRICE = 5000000
		local EPIC_PRICE = 10000000

	-- PRICE BY VENDOR, where formula is vendor price * number
		local POOR_MULTIPLIER = 20
		local COMMON_MULTIPLIER = 30
		local UNCOMMMON_MULTIPLIER = 40
		local RARE_MULTIPLIER = 50
		local EPIC_MULTIPLIER = 60

	local STARTING_MULTIPLIER = 0.9

	---------END CONFIG---------

	local cAuction = CreateFrame("Frame", "cAuction", UIParent)

	cAuction:RegisterEvent("AUCTION_HOUSE_SHOW")
	cAuction:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")

	local selectedItem
	local selectedItemVendorPrice
	local selectedItemQuality
	local currentPage = 0
	local myBuyoutPrice, myStartPrice
	local myName = UnitName("player")

	cAuction:SetScript("OnEvent", function(self, event)
		
		if event == "AUCTION_HOUSE_SHOW" then
				
			AuctionsItemButton:HookScript("OnEvent", function(self, event)
				
				if event=="NEW_AUCTION_UPDATE" then -- user placed an item into auction item box
					self:SetScript("OnUpdate", nil)
					myBuyoutPrice = nil
					myStartPrice = nil
					currentPage = 0
					selectedItem = nil
					selectedItem, texture, count, quality, canUse, price, _, stackCount, totalCount, selectedItemID = GetAuctionSellItemInfo();
					local canQuery = CanSendAuctionQuery()
					
					if canQuery and selectedItem then -- query auction house based on item name
						ResetCursor()
						QueryAuctionItems(selectedItem)
					end
				end
			end)

		elseif event == "AUCTION_ITEM_LIST_UPDATE" then -- the auction list was updated or sorted
			
			if (selectedItem ~= nil) then -- an item was placed in the auction item box
				local batch, totalAuctions = GetNumAuctionItems("list")
				
				if totalAuctions == 0 then -- No matches
					_, _, selectedItemQuality, selectedItemLevel, _, _, _, _, _, _, selectedItemVendorPrice = GetItemInfo(selectedItem)
								
					if PRICE_BY == "QUALITY" then
					
						if selectedItemQuality == 0 then myBuyoutPrice = POOR_PRICE end
						if selectedItemQuality == 1 then myBuyoutPrice = COMMON_PRICE end
						if selectedItemQuality == 2 then myBuyoutPrice = UNCOMMON_PRICE end
						if selectedItemQuality == 3 then myBuyoutPrice = RARE_PRICE end
						if selectedItemQuality == 4 then myBuyoutPrice = EPIC_PRICE end
					
					elseif PRICE_BY == "VENDOR" then
					
						if selectedItemQuality == 0 then myBuyoutPrice = selectedItemVendorPrice * POOR_MULTIPLIER end
						if selectedItemQuality == 1 then myBuyoutPrice = selectedItemVendorPrice * COMMON_MULTIPLIER end
						if selectedItemQuality == 2 then myBuyoutPrice = selectedItemVendorPrice * UNCOMMMON_MULTIPLIER end
						if selectedItemQuality == 3 then myBuyoutPrice = selectedItemVendorPrice * RARE_MULTIPLIER end
						if selectedItemQuality == 4 then myBuyoutPrice = selectedItemVendorPrice * EPIC_MULTIPLIER end
					end
					
					myStartPrice = myBuyoutPrice * STARTING_MULTIPLIER
				end
				
				local currentPageCount = floor(totalAuctions/50)
				
				for i=1, batch do -- SCAN CURRENT PAGE
					local postedItem, _, count, _, _, _, _, minBid, _, buyoutPrice, _, _, _, owner = GetAuctionItemInfo("list",i)
					
					if postedItem == selectedItem and owner ~= myName then -- selected item matches the one found on auction list
						
						if myBuyoutPrice == nil and myStartPrice == nil then
							myBuyoutPrice = (buyoutPrice/count) * undercutPercent
							myStartPrice = (minBid/count) * undercutPercent
							
						elseif myBuyoutPrice > (buyoutPrice/count) then
							myBuyoutPrice = (buyoutPrice/count) * undercutPercent
							myStartPrice = (minBid/count) * undercutPercent
						end
					end
				end
				
				if currentPage < currentPageCount then -- GO TO NEXT PAGES
					
					self:SetScript("OnUpdate", function(self, elapsed)
						
						if not self.timeSinceLastUpdate then 
							self.timeSinceLastUpdate = 0 
						end
						self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
						
						if self.timeSinceLastUpdate > .1 then -- a cycle has passed, run this
							selectedItem = GetAuctionSellItemInfo()
							local canQuery = CanSendAuctionQuery()
							
							if canQuery then -- check the next page of auctions
								currentPage = currentPage + 1
								QueryAuctionItems(selectedItem, nil, nil, currentPage)
								self:SetScript("OnUpdate", nil)
							end
							self.timeSinceLastUpdate = 0
						end
					end)
				
				else -- ALL PAGES SCANNED
					self:SetScript("OnUpdate", nil)
					local stackSize = AuctionsStackSizeEntry:GetNumber()
						
					if myStartPrice ~= nil then
							
						if stackSize > 1 then -- this is a stack of items
								
							if UIDropDownMenu_GetSelectedValue(PriceDropDown) == PRICE_TYPE_UNIT then -- input price per item
								MoneyInputFrame_SetCopper(StartPrice, myStartPrice)
								MoneyInputFrame_SetCopper(BuyoutPrice, myBuyoutPrice)
								
							else -- input price for entire stack
								MoneyInputFrame_SetCopper(StartPrice, myStartPrice*stackSize)
								MoneyInputFrame_SetCopper(BuyoutPrice, myBuyoutPrice*stackSize)
							end
							
						else -- this is not a stack
							MoneyInputFrame_SetCopper(StartPrice, myStartPrice) 
							MoneyInputFrame_SetCopper(BuyoutPrice, myBuyoutPrice)
						end
						
						UIDropDownMenu_SetSelectedValue(DurationDropDown, 3);
					end
						
					myBuyoutPrice = nil
					myStartPrice = nil
					currentPage = 0
					selectedItem = nil
				end
			end
		end
	end)
end