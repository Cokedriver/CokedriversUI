
local merchantUseGuildRepair = false	-- let your guild pay for your repairs if they allow.
local vellumEnable = true	

-- Flashing Gather nodes
if not IsAddOnLoaded('Zygor Guides Viewer 5.0') then 

	function AssignButtonTexture(obj,tx,num,total)
		self.ChainCall(obj):SetNormalTexture(CreateTexWithCoordsNum(obj,tx,num,total,1,4))
			:SetPushedTexture(CreateTexWithCoordsNum(obj,tx,num,total,2,4))
			:SetHighlightTexture(CreateTexWithCoordsNum(obj,tx,num,total,3,4))
			:SetDisabledTexture(CreateTexWithCoordsNum(obj,tx,num,total,4,4))
	end

	local nodeFrame = CreateFrame("Frame")
	function nodeFrame.ChainCall(obj)  local T={}  setmetatable(T,{__index=function(self,fun)  if fun=="__END" then return obj end  return function(self,...) assert(obj[fun],fun.." missing in object") obj[fun](obj,...) return self end end})  return T  end

	local flash_interval = 0.25

	local flash = nil
	local MinimapNodeFlash = function(s)
		flash = not flash
		Minimap:SetBlipTexture("Interface\\AddOns\\cMisc\\Media\\objecticons_"..(flash and "on" or "off"))
	end

	local q = 0
	do
		local flashgathernodes = true
		local flashFrame = CreateFrame("FRAME","PointerExtraFrame")
		local ant_last=GetTime()
		local flash_last=GetTime()
		flashFrame:SetScript("OnUpdate",function(self,elapsed)
			local t=GetTime()

			-- Flashing node dots. Prettier than the standard, too. And slightly bigger.
			if flashgathernodes == true then
				if t-flash_last>=flash_interval then
					MinimapNodeFlash()
					flash_last=t-(t-flash_last)%flash_interval
				end
			else
				Minimap:SetBlipTexture("Interface\\AddOns\\cMisc\\Media\\objecticons_on")		
			end
		end)

		flashFrame:SetPoint("CENTER",UIParent)
		flashFrame:Show()
		nodeFrame.ChainCall(flashFrame:CreateTexture("PointerDotOn","OVERLAY")) :SetTexture("Interface\\AddOns\\cMisc\\Media\\objecticons_on") :SetSize(50,50) :SetPoint("CENTER") :SetNonBlocking(true) :Show()
		nodeFrame.ChainCall(flashFrame:CreateTexture("PointerDotOff","OVERLAY")) :SetTexture("Interface\\AddOns\\cMisc\\Media\\objecticons_off") :SetSize(50,50) :SetPoint("RIGHT") :SetNonBlocking(true) :Show()
	end
end

-- Merchant
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

--Minimap
MinimapCluster:SetScale(1.2) 
 
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
Minimap:SetScript('OnMouseWheel', function(self, direction)
	self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
end)
 
 
MiniMapTracking:UnregisterAllEvents()
MiniMapTracking:Hide()

Minimap:SetScript('OnMouseDown', function(self, button)
	if (button == 'RightButton') then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
	end
end)

-- This is Velluminous from Tekkub
-- You can find the main addon at https://github.com/TekNoLogic/Velluminous
------------------------------------------------------------------------------------

if not TradeSkillFrame then
	print("What the fuck?  Velluminous cannot initialize.  BAIL!  BAIL!  BAIL!")
	return
end


local butt = CreateFrame("Button", nil, TradeSkillCreateButton, "SecureActionButtonTemplate")
butt:SetAttribute("type", "macro")
butt:SetAttribute("macrotext", "/click TradeSkillCreateButton\n/use item:38682")

butt:SetText("Vellum")

butt:SetPoint("RIGHT", TradeSkillCreateButton, "LEFT")

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
------------------------------------------------------------------------------------

SlashCmdList['RELOADUI'] = function()
	ReloadUI()
end
SLASH_RELOADUI1 = '/rl'