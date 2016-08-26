
-- Enable Seperate Parts of cMISC
local cFlashingNods = false
local cMerchant = true
local cVellum = false	
local cRareAlert = true
local cPowerBar = true
local cMiniMap = true
local cAltBuy = true
local cQuicky = false
local cAutogreed = true
local cChatBubble = false
local cCoords = false
local cAuction = true

-- Flashing Gather Nodes
if cFlashingNods == true then
	if not IsAddOnLoaded('Zygor Guides Viewer 5.0') and not IsAddOnLoaded('DugiGuidesViewer |cffffffff7.415|r') then 

		function AssignButtonTexture(obj,tx,num,total)
			self.ChainCall(obj):SetNormalTexture(CreateTexWithCoordsNum(obj,tx,num,total,1,4))
				:SetPushedTexture(CreateTexWithCoordsNum(obj,tx,num,total,2,4))
				:SetHighlightTexture(CreateTexWithCoordsNum(obj,tx,num,total,3,4))
				:SetDisabledTexture(CreateTexWithCoordsNum(obj,tx,num,total,4,4))
		end

		local nodeFrame = CreateFrame("Frame")
		function nodeFrame.ChainCall(obj)  local T={}  setmetatable(T,{__index=function(self,fun)  if fun=="__END" then return obj end  return function(self,...) assert(obj[fun],fun.." missing in object") obj[fun](obj,...) return self end end})  return T  end
		
		local flash_interval=0.35

		local flash=nil
		function nodeFrame:MinimapNodeFlash(s)
			flash=not flash
			if flash then
				Minimap:SetBlipTexture("Interface\\MINIMAP\\ObjectIcons")
			else
				Minimap:SetBlipTexture("Interface\\AddOns\\cMisc\\Media\\objecticons_off")
			end
		end
		function nodeFrame:MinimapNodeFlashOff()
			Minimap:SetBlipTexture("INTERFACE\\MINIMAP\\OBJECTICONS")
		end

		local q=0

		do
			local F = CreateFrame("FRAME","PointerExtraFrame")
			local ant_last=GetTime()
			local flash_last=GetTime()
			F:SetScript("OnUpdate",function(self,elapsed)
				local t=GetTime()

				-- Flashing node dots. Prettier than the standard, too. And slightly bigger.  Also, s/ode do/ude ti/.
				if t-flash_last>=flash_interval then
					nodeFrame:MinimapNodeFlash()
					flash_last=t-(t-flash_last)%flash_interval
				end
			end)
			
			F:SetPoint("CENTER",UIParent)
			F:Show()

			-- these make sure the flashing dots don't blink-glitch when their texture changes.
			nodeFrame.ChainCall(F:CreateTexture("PointerDotOn","OVERLAY")) :SetTexture("Interface\\MINIMAP\\ObjectIcons") :SetSize(50,50) :SetPoint("RIGHT") :SetNonBlocking(true) :Show()
			nodeFrame.ChainCall(F:CreateTexture("PointerDotOff","OVERLAY")) :SetTexture("Interface\\AddOns\\cMisc\\Media\\objecticons_off") :SetSize(50,50) :SetPoint("RIGHT") :SetNonBlocking(true) :Show()
		end	

	end
end

-- Merchant
if cMerchant == true then
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
if cMiniMap == true then
	MinimapCluster:SetScale(1.2) 

	GarrisonLandingPageMinimapButton:SetSize(36, 36)
	 
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	Minimap:SetScript('OnMouseWheel', function(self, direction)
		self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
	end)
	 
	 
	MiniMapTracking:UnregisterAllEvents()
	MiniMapTracking:Hide()

	MinimapZoneTextButton:SetScript('OnMouseDown', function(self, button)
		if (button == 'LeftButton') then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
		end
	end)
end

-- This is Velluminous from Tekkub
-- You can find the main addon at https://github.com/TekNoLogic/Velluminous
if cVellum == true then

	if not TradeSkillFrame then
		print("What the fuck?  Velluminous cannot initialize.  BAIL!  BAIL!  BAIL!")
		return
	end


	local butt = CreateFrame("Button", nil, TradeSkillFrame.DetailsFrame.CreateButton, "SecureActionButtonTemplate")
	butt:SetAttribute("type", "macro")
	butt:SetAttribute("macrotext", "/click TradeSkillFrame.DetailsFrame.CreateButton()\n/use item:38682")

	butt:SetText("Vellum")

	butt:SetPoint("RIGHT", TradeSkillFrame.DetailsFrame.CreateButton, "LEFT")

	butt:SetWidth(80) butt:SetHeight(22)

	-- Fonts --
	butt:SetDisabledFontObject(GameFontDisable)
	butt:SetHighlightFontObject(GameFontHighlight)
	butt:SetNormalFontObject(GameFontNormal)

	-- Textures --
	butt:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	butt:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	butt:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	butt:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	butt:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetBlendMode("ADD")

	local hider = CreateFrame("Frame", nil, TradeSkillCreateAllButton)
	hider:SetScript("OnShow", function() butt:Hide() end)
	hider:SetScript("OnHide", function() butt:Show() end)
end

SlashCmdList['RELOADUI'] = function()
	ReloadUI()
end
SLASH_RELOADUI1 = '/rl'


-- Alt-Buy Full Stack from NeavUI
if cAltBuy == true then
	local NEW_ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY
	ITEM_VENDOR_STACK_BUY = '|cffa9ff00'..NEW_ITEM_VENDOR_STACK_BUY..'|r'

		-- alt-click to buy a stack

	local origMerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
	local function MerchantItemButton_OnModifiedClickHook(self, ...)
		origMerchantItemButton_OnModifiedClick(self, ...)

		if (IsAltKeyDown()) then
			local maxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))
			local _, _, _, quantity = GetMerchantItemInfo(self:GetID())

			if (maxStack and maxStack > 1) then
				BuyMerchantItem(self:GetID(), floor(maxStack / quantity))
			end
		end
	end
	MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClickHook

		-- Google translate ftw...NOT

	local function GetAltClickString()
		if (GetLocale() == 'enUS') then
			return '<Alt-click, to buy an stack>'
		elseif (GetLocale() == 'frFR') then
			return '<Alt-clic, d acheter une pile>'
		elseif (GetLocale() == 'esES') then
			return '<Alt-clic, para comprar una pila>'
		elseif (GetLocale() == 'deDE') then
			return '<Alt-klicken, um einen ganzen Stapel zu kaufen>'
		else
			return '<Alt-click, to buy an stack>'
		end
	end

		-- add a hint to the tooltip

	local function IsMerchantButtonOver()
		return GetMouseFocus():GetName() and GetMouseFocus():GetName():find('MerchantItem%d')
	end

	GameTooltip:HookScript('OnTooltipSetItem', function(self)
		if (MerchantFrame:IsShown() and IsMerchantButtonOver()) then 
			for i = 2, GameTooltip:NumLines() do
				if (_G['GameTooltipTextLeft'..i]:GetText():find('<[sS]hift')) then
					GameTooltip:AddLine('|cff00ffcc'..GetAltClickString()..'|r')
				end
			end
		end
	end)
end

-- Quicky From Neav UI
if cQuicky == true then
	local QuickyFrame = CreateFrame('Frame')

	QuickyFrame.Head = CreateFrame('Button', nil, CharacterHeadSlot)
	QuickyFrame.Head:SetFrameStrata('HIGH')
	QuickyFrame.Head:SetSize(16, 32)
	QuickyFrame.Head:SetPoint('LEFT', CharacterHeadSlot, 'CENTER', 9, 0)

	QuickyFrame.Head:SetScript('OnClick', function() 
		ShowHelm(not ShowingHelm()) 
	end)

	QuickyFrame.Head:SetScript('OnEnter', function(self) 
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 13, -10)
		GameTooltip:AddLine(SHOW_HELM)
		GameTooltip:Show()
	end)

	QuickyFrame.Head:SetScript('OnLeave', function() 
		GameTooltip:Hide()
	end)

	QuickyFrame.Head:SetNormalTexture('Interface\\AddOns\\cMisc\\Media\\textureNormal')
	QuickyFrame.Head:SetHighlightTexture('Interface\\AddOns\\cMisc\\Media\\textureHighlight')
	QuickyFrame.Head:SetPushedTexture('Interface\\AddOns\\cMisc\\Media\\texturePushed')

	CharacterHeadSlotPopoutButton:SetScript('OnShow', function()
		QuickyFrame.Head:ClearAllPoints()
		QuickyFrame.Head:SetPoint('RIGHT', CharacterHeadSlot, 'CENTER', -9, 0)
	end)

	CharacterHeadSlotPopoutButton:SetScript('OnHide', function()
		QuickyFrame.Head:ClearAllPoints()
		QuickyFrame.Head:SetPoint('LEFT', CharacterHeadSlot, 'CENTER', 9, 0)
	end)

	QuickyFrame.Cloak = CreateFrame('Button', nil, CharacterBackSlot)
	QuickyFrame.Cloak:SetFrameStrata('HIGH')
	QuickyFrame.Cloak:SetSize(16, 32)
	QuickyFrame.Cloak:SetPoint('LEFT', CharacterBackSlot, 'CENTER', 9, 0)

	QuickyFrame.Cloak:SetScript('OnClick', function() 
		ShowCloak(not ShowingCloak()) 
	end)

	QuickyFrame.Cloak:SetScript('OnEnter', function(self) 
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 13, -10)
		GameTooltip:AddLine(SHOW_CLOAK)
		GameTooltip:Show()
	end)

	QuickyFrame.Cloak:SetScript('OnLeave', function() 
		GameTooltip:Hide()
	end)

	QuickyFrame.Cloak:SetNormalTexture('Interface\\AddOns\\cMisc\\Media\\textureNormal')
	QuickyFrame.Cloak:SetHighlightTexture('Interface\\AddOns\\cMisc\\Media\\textureHighlight')
	QuickyFrame.Cloak:SetPushedTexture('Interface\\AddOns\\cMisc\\Media\\texturePushed')

	CharacterBackSlotPopoutButton:SetScript('OnShow', function()
		QuickyFrame.Cloak:ClearAllPoints()
		QuickyFrame.Cloak:SetPoint('RIGHT', CharacterBackSlot, 'CENTER', -9, 0)
	end)

	CharacterBackSlotPopoutButton:SetScript('OnHide', function()
		QuickyFrame.Cloak:ClearAllPoints()
		QuickyFrame.Cloak:SetPoint('LEFT', CharacterBackSlot, 'CENTER', 9, 0)
	end)
end

-- Autogreed from NeavUI
if cAutogreed == true then

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
if cChatBubble == true then
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
if cPowerBar == true then
	local PowerDB = {
		position = {
			selfAnchor = "CENTER",
			frameParent = "UIParent",
			offSetX = 0,
			offSetY = -100
		},
		sizeWidth = 200,
		
		showCombatRegen = true, 

		activeAlpha = 1,
		inactiveAlpha = 0.5,
		emptyAlpha = 0,
		
		valueAbbrev = true,
			
		valueFontSize = 20,
		valueFontOutline = true,
		valueFontAdjustmentX = 0,

		showSoulshards = true,
		showHolypower = true,
		showMana = true,
		showFocus = true,
		showRage = true,
		showInsanity = true,
		
		
		extraFontSize = 16,                             -- The fontsize for the holypower and soulshard number
		extraFontOutline = true,                        
			
		
		energy = {
			show = true,
			showComboPoints = true,
			comboPointsBelow = false,
			
			comboFontSize = 16,
			comboFontOutline = true,
		},
		
		
		rune = {
			showRuneCooldown = true,
		   
			runeFontSize = 16,
			runeFontOutline = true,
		},
	}

	local playerClass = select(2, UnitClass('player'))

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

	local ComboColor = {
		[1] = {r = 1.0, g = 1.0, b = 1.0},
		[2] = {r = 1.0, g = 1.0, b = 1.0},
		[3] = {r = 1.0, g = 1.0, b = 1.0},
		[4] = {r = 0.9, g = 0.7, b = 0.0},
		[5] = {r = 1.0, g = 0.0, b = 0.0},
	}

	local RuneColor = {
		[1] = {r = 0, g = 0.82, b = 1},
		[2] = {r = 0, g = 0.82, b = 1},
		[3] = {r = 0, g = 0.82, b = 1},
		[4] = {r = 0, g = 0.82, b = 1},
		[5] = {r = 0, g = 0.82, b = 1},
		[6] = {r = 0, g = 0.82, b = 1},
	}

	local MPFrame = CreateFrame('Frame', nil, UIParent)
	MPFrame:SetScale(1.4)
	MPFrame:SetSize(18, 18)
	MPFrame:SetPoint(PowerDB.position.selfAnchor, PowerDB.position.frameParent, PowerDB.position.offSetX, PowerDB.position.offSetY)
	MPFrame:EnableMouse(false)

	MPFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	MPFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	MPFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
	MPFrame:RegisterUnitEvent('UNIT_COMBO_POINTS', 'player')
	MPFrame:RegisterEvent('PLAYER_TARGET_CHANGED')

	if (PowerDB.rune.showRuneCooldown) then
		MPFrame:RegisterEvent('RUNE_TYPE_UPDATE')
	end

	MPFrame:RegisterUnitEvent('UNIT_DISPLAYPOWER', 'player')
	MPFrame:RegisterUnitEvent('UNIT_POWER_FREQUENT', 'player')
	MPFrame:RegisterEvent('UPDATE_SHAPESHIFT_FORM')

	if (PowerDB.showCombatRegen) then
		MPFrame:RegisterUnitEvent('UNIT_AURA', 'player')
	end

	MPFrame:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
	MPFrame:RegisterUnitEvent('UNIT_ENTERING_VEHICLE', 'player')
	MPFrame:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
	MPFrame:RegisterUnitEvent('UNIT_EXITING_VEHICLE', 'player')

	if (PowerDB.energy.showComboPoints) then
		MPFrame.ComboPoints = {}

		for i = 1, 5 do
			MPFrame.ComboPoints[i] = MPFrame:CreateFontString(nil, 'ARTWORK')

			if (PowerDB.energy.comboFontOutline) then
				MPFrame.ComboPoints[i]:SetFont('Fonts\\ARIALN.ttf', PowerDB.energy.comboFontSize, 'THINOUTLINE')
				MPFrame.ComboPoints[i]:SetShadowOffset(0, 0)
			else
				MPFrame.ComboPoints[i]:SetFont('Fonts\\ARIALN.ttf', PowerDB.energy.comboFontSize)
				MPFrame.ComboPoints[i]:SetShadowOffset(1, -1)
			end

			MPFrame.ComboPoints[i]:SetParent(MPFrame)
			MPFrame.ComboPoints[i]:SetText(i)
			MPFrame.ComboPoints[i]:SetAlpha(0)
		end

		local yOffset = PowerDB.energy.comboPointsBelow and -35 or 0
		MPFrame.ComboPoints[1]:SetPoint('CENTER', -52, yOffset)
		MPFrame.ComboPoints[2]:SetPoint('CENTER', -26, yOffset)
		MPFrame.ComboPoints[3]:SetPoint('CENTER', 0, yOffset)
		MPFrame.ComboPoints[4]:SetPoint('CENTER', 26, yOffset)
		MPFrame.ComboPoints[5]:SetPoint('CENTER', 52, yOffset) 	
	end

	if (playerClass == 'MONK') then
		MPFrame.Chi = {}
		MPFrame.Chi.maxChi = 4

		for i = 1, 6 do 
			MPFrame.Chi[i] = MPFrame:CreateFontString(nil, 'ARTWORK')

			MPFrame.Chi[i]:SetFont('Fonts\\ARIALN.ttf', PowerDB.energy.comboFontSize, 'THINOUTLINE')
			MPFrame.Chi[i]:SetShadowOffset(0, 0)

			MPFrame.Chi[i]:SetParent(MPFrame)
			MPFrame.Chi[i]:SetText(i)
			MPFrame.Chi[i]:SetAlpha(0)
		end

		local yOffset = PowerDB.energy.comboPointsBelow and -35 or 0
		MPFrame.Chi[1]:SetPoint('CENTER', -39, yOffset)
		MPFrame.Chi[2]:SetPoint('CENTER', -13, yOffset)
		MPFrame.Chi[3]:SetPoint('CENTER', 13, yOffset)
		MPFrame.Chi[4]:SetPoint('CENTER', 39, yOffset)
		
		MPFrame.Chi[5]:Hide()
		MPFrame.Chi[6]:Hide()
	end

	if (playerClass == 'WARLOCK' and PowerDB.showSoulshards or playerClass == 'PALADIN' and PowerDB.showHolypower or playerClass == 'PRIEST' and PowerDB.showShadowOrbs) then
		MPFrame.extraPoints = MPFrame:CreateFontString(nil, 'ARTWORK')

		if (PowerDB.extraFontOutline) then
			MPFrame.extraPoints:SetFont('Fonts\\ARIALN.ttf', PowerDB.extraFontSize, 'THINOUTLINE')
			MPFrame.extraPoints:SetShadowOffset(0, 0)
		else
			MPFrame.extraPoints:SetFont('Fonts\\ARIALN.ttf', PowerDB.extraFontSize)
			MPFrame.extraPoints:SetShadowOffset(1, -1)
		end

		MPFrame.extraPoints:SetParent(MPFrame)
		MPFrame.extraPoints:SetPoint('CENTER', 0, 0)
	end

	if (playerClass == 'DEATHKNIGHT' and PowerDB.rune.showRuneCooldown) then
		for i = 1, 7 do
			RuneFrame:UnregisterAllEvents()
			_G['RuneButtonIndividual'..i]:Hide()
		end

		MPFrame.Rune = {};

		for i = 1, 6 do
			MPFrame.Rune[i] = MPFrame:CreateFontString(nil, 'ARTWORK')

			if (PowerDB.rune.runeFontOutline) then
				MPFrame.Rune[i]:SetFont('Fonts\\ARIALN.ttf', PowerDB.rune.runeFontSize, 'THINOUTLINE')
				MPFrame.Rune[i]:SetShadowOffset(0, 0)
			else
				MPFrame.Rune[i]:SetFont('Fonts\\ARIALN.ttf', PowerDB.rune.runeFontSize)
				MPFrame.Rune[i]:SetShadowOffset(1, -1)
			end

			MPFrame.Rune[i]:SetShadowOffset(0, 0)
			MPFrame.Rune[i]:SetParent(MPFrame)
		end

		MPFrame.Rune[1]:SetPoint('CENTER', -65, 0)
		MPFrame.Rune[2]:SetPoint('CENTER', -39, 0)
		MPFrame.Rune[3]:SetPoint('CENTER', 39, 0)
		MPFrame.Rune[4]:SetPoint('CENTER', 65, 0)
		MPFrame.Rune[5]:SetPoint('CENTER', -13, 0)
		MPFrame.Rune[6]:SetPoint('CENTER', 13, 0)
	end

	MPFrame.Power = CreateFrame('StatusBar', nil, UIParent)
	MPFrame.Power:SetScale(1)
	MPFrame.Power:SetSize(PowerDB.sizeWidth, 8)
	MPFrame.Power:SetPoint('CENTER', MPFrame, 0, -28)
	MPFrame.Power:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	MPFrame.Power:SetAlpha(0)

	MPFrame.Power.Value = MPFrame.Power:CreateFontString(nil, 'ARTWORK')

	if (PowerDB.valueFontOutline) then
		MPFrame.Power.Value:SetFont('Fonts\\ARIALN.ttf', PowerDB.valueFontSize, 'THINOUTLINE')
		MPFrame.Power.Value:SetShadowOffset(0, 0)
	else
		MPFrame.Power.Value:SetFont('Fonts\\ARIALN.ttf', PowerDB.valueFontSize)
		MPFrame.Power.Value:SetShadowOffset(1, -1)
	end

	MPFrame.Power.Value:SetPoint('CENTER', MPFrame.Power, 0, PowerDB.valueFontAdjustmentX)
	MPFrame.Power.Value:SetVertexColor(1, 1, 1)

	MPFrame.Power.Background = MPFrame.Power:CreateTexture(nil, 'BACKGROUND')
	MPFrame.Power.Background:SetAllPoints(MPFrame.Power)
	MPFrame.Power.Background:SetTexture([[Interface\DialogFrame\UI-DialogBox-Background-Dark]])
	MPFrame.Power.Background:SetVertexColor(0.25, 0.25, 0.25, 1)

	MPFrame.Power.Below = MPFrame.Power:CreateTexture(nil, 'BACKGROUND')
	MPFrame.Power.Below:SetHeight(14)
	MPFrame.Power.Below:SetWidth(14)
	MPFrame.Power.Below:SetTexture([[Interface\AddOns\cMisc\Media\textureArrowBelow]])

	MPFrame.Power.Above = MPFrame.Power:CreateTexture(nil, 'BACKGROUND')
	MPFrame.Power.Above:SetHeight(14)
	MPFrame.Power.Above:SetWidth(14)
	MPFrame.Power.Above:SetTexture([[Interface\AddOns\cMisc\Media\textureArrowAbove]])
	MPFrame.Power.Above:SetPoint('BOTTOM', MPFrame.Power.Below, 'TOP', 0, MPFrame.Power:GetHeight())

	if (PowerDB.showCombatRegen) then
		MPFrame.mpreg = MPFrame.Power:CreateFontString(nil, 'ARTWORK')
		MPFrame.mpreg:SetFont('Fonts\\ARIALN.ttf', 12, 'THINOUTLINE')
		MPFrame.mpreg:SetShadowOffset(0, 0)
		MPFrame.mpreg:SetPoint('TOP', MPFrame.Power.Below, 'BOTTOM', 0, 4)
		MPFrame.mpreg:SetParent(MPFrame.Power)
		MPFrame.mpreg:Show()
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

	local function SetComboColor(i)
		local comboPoints = GetComboPoints('player', 'target') or 0

		if (i > comboPoints or UnitIsDeadOrGhost('target')) then
			return 1, 1, 1
		else
			return ComboColor[i].r, ComboColor[i].g, ComboColor[i].b
		end
	end

	local function SetComboAlpha(i)
		local comboPoints = GetComboPoints('player', 'target') or 0

		if (i == comboPoints) then
			return 1
		else
			return 0
		end
	end

	local function UpdateChi()
		local chi = UnitPower('player', SPELL_POWER_CHI)
		local maxChi = UnitPowerMax('player', SPELL_POWER_CHI)
		local yOffset = PowerDB.energy.comboPointsBelow and -35 or 0

		if (MPFrame.Chi.maxChi ~= maxChi) then
			MPFrame.Chi.maxChi = maxChi

			local startX = -39
			if (maxChi == 6) then
				startX = -65
				MPFrame.Chi[5]:Show()
				MPFrame.Chi[6]:Show()
			elseif (maxChi == 5) then
				startX = -52
				MPFrame.Chi[5]:Show()
				MPFrame.Chi[6]:Hide()
			else
				MPFrame.Chi[5]:Hide()
				MPFrame.Chi[6]:Hide()
			end

			for i = 1, 6 do
				MPFrame.Chi[i]:SetPoint('CENTER', startX + (i - 1) * 26, yOffset)
			end
		end

		for i = 1, maxChi do
			if (UnitHasVehicleUI('player')) then
				if (MPFrame.Chi[i]:IsShown()) then
					MPFrame.Chi[i]:Hide()
				end
			else
				if (not MPFrame.Chi[i]:IsShown()) then
					MPFrame.Chi[i]:Show()
				end
			end
			MPFrame.Chi[i]:SetAlpha(i == chi and 1 or 0)
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

	local function SetRuneColor(i)
		if (MPFrame.Rune[i].type == 4) then
			return 1, 0, 1
		else
			return RuneColor[i].r, RuneColor[i].g, RuneColor[i].b
		end
	end

	local function UpdateBarVisibility()
		local _, powerType = UnitPowerType('player')
		local newAlpha = nil

		if ((not PowerDB.energy.show and powerType == 'ENERGY') or (not PowerDB.showFocus and powerType == 'FOCUS') or (not PowerDB.showRage and powerType == 'RAGE') or (not PowerDB.showMana and powerType == 'MANA') or (not PowerDB.showInsanity and powerType == 'INSANITY') or (not PowerDB.rune.show and powerType == 'RUNEPOWER') or UnitIsDeadOrGhost('player') or UnitHasVehicleUI('player')) then
			MPFrame.Power:SetAlpha(0)
		elseif (InCombatLockdown()) then
			--securecall('UIFrameFadeIn', MPFrame.Power, 0.3, MPFrame.Power:GetAlpha(), PowerDB.activeAlpha)
			newAlpha = PowerDB.activeAlpha
		elseif (not InCombatLockdown() and UnitPower('player') > 0) then
			--securecall('UIFrameFadeOut', MPFrame.Power, 0.3, MPFrame.Power:GetAlpha(), PowerDB.inactiveAlpha)
			newAlpha = PowerDB.inactiveAlpha
		else
			--securecall('UIFrameFadeOut', MPFrame.Power, 0.3, MPFrame.Power:GetAlpha(), PowerDB.emptyAlpha)
			newAlpha = PowerDB.emptyAlpha
		end

		if (newAlpha) then
			PowerFade(MPFrame.Power, 0.3, MPFrame.Power:GetAlpha(), newAlpha)
		end
	end

	local function UpdateArrow()
		if (UnitPower('player') == 0) then
			MPFrame.Power.Below:SetAlpha(0.3)
			MPFrame.Power.Above:SetAlpha(0.3)
		else
			MPFrame.Power.Below:SetAlpha(1)
			MPFrame.Power.Above:SetAlpha(1)
		end

		local newPosition = UnitPower('player') / UnitPowerMax('player') * MPFrame.Power:GetWidth()
		MPFrame.Power.Below:SetPoint('TOP', MPFrame.Power, 'BOTTOMLEFT', newPosition, 0)
	end

	local function UpdateBarValue()
		local min = UnitPower('player')
		MPFrame.Power:SetMinMaxValues(0, UnitPowerMax('player', MPFrame))
		MPFrame.Power:SetValue(min)

		if (PowerDB.valueAbbrev) then
			MPFrame.Power.Value:SetText(min > 0 and FormatValue(min) or '')
		else
			MPFrame.Power.Value:SetText(min > 0 and min or '')
		end
	end

	local function UpdateBarColor()
		local _, powerType, altR, altG, altB = UnitPowerType('player')
		local unitPower = PowerBarColor[powerType]

		if (unitPower) then
			MPFrame.Power:SetStatusBarColor(unitPower.r, unitPower.g, unitPower.b)
		else
			MPFrame.Power:SetStatusBarColor(altR, altG, altB)
		end
	end

	local function UpdateBar()
		UpdateBarColor()
		UpdateBarValue()
		UpdateArrow()
	end

	MPFrame:SetScript('OnEvent', function(self, event, arg1)
		if (MPFrame.ComboPoints) then
			if (event == 'UNIT_COMBO_POINTS' or event == 'PLAYER_TARGET_CHANGED') then
				for i = 1, 5 do
					MPFrame.ComboPoints[i]:SetTextColor(SetComboColor(i))
					MPFrame.ComboPoints[i]:SetAlpha(SetComboAlpha(i))
				end
			end
		end

		if (event == 'RUNE_TYPE_UPDATE' and PowerDB.rune.showRuneCooldown) then
			MPFrame.Rune[arg1].type = GetRuneType(arg1)
		end

		if (MPFrame.extraPoints) then
			if (UnitHasVehicleUI('player')) then
				if (MPFrame.extraPoints:IsShown()) then
					MPFrame.extraPoints:Hide()
				end
			else
				local nump
				if (playerClass == 'WARLOCK') then
					nump = UnitPower('player', SPELL_POWER_SOUL_SHARDS)
				elseif (playerClass == 'PALADIN') then
					nump = UnitPower('player', SPELL_POWER_HOLY_POWER)
				elseif (playerClass == 'PRIEST') then
					nump = UnitPower('player', SPELL_POWER_SHADOW_ORBS)
				end

				MPFrame.extraPoints:SetText(nump == 0 and '' or nump)
				
				if (not MPFrame.extraPoints:IsShown()) then
					MPFrame.extraPoints:Show()
				end			
			end
		end

		if (MPFrame.Chi) then
			UpdateChi()
		end

		if (MPFrame.mpreg and (event == 'UNIT_AURA' or event == 'PLAYER_ENTERING_WORLD')) then
			MPFrame.mpreg:SetText(GetRealMpFive())
		end

		UpdateBar()
		UpdateBarVisibility()

		if (event == 'PLAYER_ENTERING_WORLD') then
			if (InCombatLockdown()) then
				securecall('UIFrameFadeIn', MPFrame, 0.35, MPFrame:GetAlpha(), 1)
			else
				securecall('UIFrameFadeOut', MPFrame, 0.35, MPFrame:GetAlpha(), PowerDB.inactiveAlpha)
			end
		end

		if (event == 'PLAYER_REGEN_DISABLED') then
			securecall('UIFrameFadeIn', MPFrame, 0.35, MPFrame:GetAlpha(), 1)
		end

		if (event == 'PLAYER_REGEN_ENABLED') then
			securecall('UIFrameFadeOut', MPFrame, 0.35, MPFrame:GetAlpha(), PowerDB.inactiveAlpha)
		end
	end)

	if (MPFrame.Rune) then
		local updateTimer = 0
		MPFrame:SetScript('OnUpdate', function(self, elapsed)
			updateTimer = updateTimer + elapsed

			if (updateTimer > 0.1) then
				for i = 1, 6 do
					if (UnitHasVehicleUI('player')) then
						if (MPFrame.Rune[i]:IsShown()) then
							MPFrame.Rune[i]:Hide()
						end
					else
						if (not MPFrame.Rune[i]:IsShown()) then
							MPFrame.Rune[i]:Show()
						end
					end

					MPFrame.Rune[i]:SetText(CalcRuneCooldown(i))
					MPFrame.Rune[i]:SetTextColor(SetRuneColor(i))
				end

				updateTimer = 0
			end
		end)
	end
end

-- Rare Alert
if cRareAlert == true then
	local blacklist = {
		[971] = true, -- Alliance garrison
		[976] = true, -- Horde garrison
	}

	local f = CreateFrame("Frame")
	f:RegisterEvent("VIGNETTE_ADDED")
	f:SetScript("OnEvent", function()
		if blacklist[GetCurrentMapAreaID()] then return end

		PlaySoundFile("Sound\\Spells\\PVPFlagTaken.ogg")
		RaidNotice_AddMessage(RaidWarningFrame, "Rare Spotted!", ChatTypeInfo["RAID_WARNING"])
	end)
end

-- Coords from NeavUI
if cCoords == true then
	local f = CreateFrame('Frame', nil, WorldMapFrame)
	f:SetParent(WorldMapButton)

	f.Player = f:CreateFontString(nil, 'OVERLAY')
	f.Player:SetFont('Fonts\\ARIALN.ttf', 26)
	f.Player:SetShadowOffset(1, -1)
	f.Player:SetJustifyH('LEFT')
	f.Player:SetPoint('BOTTOMLEFT', WorldMapButton, 7, 4)
	f.Player:SetTextColor(1, 0.82, 0)

	f.Cursor = f:CreateFontString(nil, 'OVERLAY')
	f.Cursor:SetFont('Fonts\\ARIALN.ttf', 26)
	f.Cursor:SetShadowOffset(1, -1)
	f.Cursor:SetJustifyH('LEFT')
	f.Cursor:SetPoint('BOTTOMLEFT', f.Player, 'TOPLEFT')
	f.Cursor:SetTextColor(1, 0.82, 0)

	f:SetScript('OnUpdate', function(self, elapsed)
		local width = WorldMapDetailFrame:GetWidth()
		local height = WorldMapDetailFrame:GetHeight()
		local mx, my = WorldMapDetailFrame:GetCenter()
		local px, py = GetPlayerMapPosition('player')
		local cx, cy = GetCursorPosition()

		mx = ((cx / WorldMapDetailFrame:GetEffectiveScale()) - (mx - width / 2)) / width
		my = ((my + height / 2) - (cy / WorldMapDetailFrame:GetEffectiveScale())) / height

		if (mx >= 0 and my >= 0 and mx <= 1 and my <= 1) then
			f.Cursor:SetText(MOUSE_LABEL..format(': %.0f x %.0f', mx * 100, my * 100))
		else
			f.Cursor:SetText('')
		end

		if (px ~= 0 and py ~= 0) then
			f.Player:SetText(PLAYER..format(': %.0f x %.0f', px * 100, py * 100))
		else
			f.Player:SetText('')
		end
	end)
end


-- From daftAuction by Daftwise - US Destromath
if cAuction == true then
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