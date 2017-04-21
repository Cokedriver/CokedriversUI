local cUnitframes = CreateFrame("Frame")
cUnitframes:RegisterEvent("ADDON_LOADED")
cUnitframes:SetScript("OnEvent", function(self, event, arg1)

	if event == "ADDON_LOADED" and arg1 == "cUnitframes" then
		local UnitScale = 1.2
		local UnitframeFont = [[Interface\Addons\cUnitframes\Media\Expressway_Rg _BOLD.ttf]]

		--[[ Unit Font Style ]]--
		----------------------------------------------------------
		local shorts = {
			{ 1e10, 1e9, "%.0fB" }, --  10b+ as  12B
			{  1e9, 1e9, "%.1fB" }, --   1b+ as 8.3B
			{  1e7, 1e6, "%.0fM" }, --  10m+ as  14M
			{  1e6, 1e6, "%.1fM" }, --   1m+ as 7.4M
			{  1e5, 1e3, "%.0fK" }, -- 100k+ as 840K
			{  1e3, 1e3, "%.1fK" }, --   1k+ as 2.5K
			{    0,   1,    "%d" }, -- < 1k  as  974
		}
		for i = 1, #shorts do
			shorts[i][4] = shorts[i][3] .. " (%.0f%%)"
		end

		hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(statusBar, textString, value, valueMin, valueMax)
			if value == 0 then
				return textString:SetText("")
			end

			local style = GetCVar("statusTextDisplay")
			if style == "PERCENT" then
				return textString:SetFormattedText("%.0f%%", value / valueMax * 100)
			end
			for i = 1, #shorts do
				local t = shorts[i]
				if value >= t[1] then
					if style == "BOTH" then
						return textString:SetFormattedText(t[4], value / t[2], value / valueMax * 100)
					else
						if value < valueMax then
							for j = 1, #shorts do
								local v = shorts[j]
								if valueMax >= v[1] then
									return textString:SetFormattedText(t[3] .. " / " .. v[3], value / t[2], valueMax / v[2])
								end
							end
						end
						return textString:SetFormattedText(t[3], value / t[2])
					end
				end
			end
		end)
		----------------------------------------------------------


		--[[ Unit Font Color ]]--
		----------------------------------------------------------
		CUSTOM_FACTION_BAR_COLORS = {
			[1] = {r = 1, g = 0, b = 0},
			[2] = {r = 1, g = 0, b = 0},
			[3] = {r = 1, g = 1, b = 0},
			[4] = {r = 1, g = 1, b = 0},
			[5] = {r = 0, g = 1, b = 0},
			[6] = {r = 0, g = 1, b = 0},
			[7] = {r = 0, g = 1, b = 0},
			[8] = {r = 0, g = 1, b = 0},
		}

		hooksecurefunc("UnitFrame_Update", function(self, isParty)
			if not self.name or not self:IsShown() then return end

			local PET_COLOR = { r = 157/255, g = 197/255, b = 255/255 }
			local unit, color = self.unit
			if UnitPlayerControlled(unit) then
				if UnitIsPlayer(unit) then
					color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
				else
					color = PET_COLOR
				end
			elseif UnitIsDeadOrGhost(unit) then
				color = GRAY_FONT_COLOR
			else
				color = CUSTOM_FACTION_BAR_COLORS[UnitIsEnemy(unit, "player") and 1 or UnitReaction(unit, "player") or 5]
			end

			if not color then
				color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)["PRIEST"]
			end

			self.name:SetTextColor(color.r, color.g, color.b)
			if isParty then
				self.name:SetText(GetUnitName(self.overrideName or unit))
			end
		end)
		----------------------------------------------------------


		--[[ Unit Name Background Color ]]--
		----------------------------------------------------------
		for _, region in pairs({
			TargetFrameNameBackground,
			FocusFrameNameBackground,
			Boss1TargetFrameNameBackground, 
			Boss2TargetFrameNameBackground, 
			Boss3TargetFrameNameBackground, 
			Boss4TargetFrameNameBackground,
			Boss5TargetFrameNameBackground, 
			
		}) do
			region:SetColorTexture(0, 0, 0, 0.5)
		end
		----------------------------------------------------------


		--[[ Unit Name Font Size ]]--
		----------------------------------------------------------
		for _, names in pairs({
			PlayerName,
			TargetFrameTextureFrameName,
			FocusFrameTextureFrameName,
		}) do
			names:SetFont(UnitframeFont, 16)

		end
		----------------------------------------------------------


		--[[ Unit Level Text Centering ]]--
		----------------------------------------------------------
		-- PlayerFrame
		hooksecurefunc("PlayerFrame_UpdateLevelTextAnchor", function(level)
		  if ( level >= 100 ) then
			PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -61, -16);
		  else
			PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -62, -16);
		  end
		end)

		-- TargetFrame
		hooksecurefunc("TargetFrame_UpdateLevelTextAnchor",  function(self, targetLevel)
		  if ( targetLevel >= 100 ) then
			self.levelText:SetPoint("CENTER", 62, -16);
		  else
			self.levelText:SetPoint("CENTER", 62, -16);
		  end
		end)



		--[[ Castbar Scaling ]]--
		----------------------------------------------------------
		-- Player Castbar
		CastingBarFrame:SetScale(UnitScale)
		--CastingBarFrame:ClearAllPoints()
		--CastingBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

		-- Target Castbar
		--Target_Spellbar_AdjustPosition = function() end
		--TargetFrameSpellBar:SetParent(UIParent)
		--TargetFrameSpellBar:ClearAllPoints()
		--TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
		--TargetFrameSpellBar:SetScale(UnitScale)
		--TargetFrameSpellBar:SetScript("OnShow", nil)
		----------------------------------------------------------


		--[[ Main Unit Frames Scaling ]]--
		----------------------------------------------------------
		for _, frames in pairs({
			PlayerFrame,
			TargetFrame,
			FocusFrame,
		}) do
			frames:SetScale(UnitScale)
		end
		----------------------------------------------------------


		--[[ Party Member Frame Scaling ]]--
		----------------------------------------------------------
		for i = 1, MAX_PARTY_MEMBERS do
			_G["PartyMemberFrame"..i]:SetScale(UnitScale)
		end
		----------------------------------------------------------


		--[[ Arena Frames Scaling ]]--
		----------------------------------------------------------
		--local function ScaleArenaFrames()
			--for i = 1, MAX_ARENA_ENEMIES do
				--_G["ArenaPrepFrame"..i]:SetScale(UnitScale)
				--_G["ArenaEnemyFrame"..i]:SetScale(UnitScale)
			--end
		--end

		--if IsAddOnLoaded("Blizzard_ArenaUI") then
			--ScaleArenaFrames()
		--else
			--local f = CreateFrame("Frame")
			--f:RegisterEvent("ADDON_LOADED")
			--f:SetScript("OnEvent", function(self, event, addon)
				--if addon == "Blizzard_ArenaUI" then
					--self:UnregisterEvent(event)
					--ScaleArenaFrames()
				--end
			--end)
		--end
		----------------------------------------------------------


		--[[ Boss Frames Scaling ]]--
		----------------------------------------------------------
		for i = 1, MAX_BOSS_FRAMES do
			_G["Boss"..i.."TargetFrame"]:SetScale(UnitScale)
		end
		----------------------------------------------------------
		self:UnregisterEvent("ADDON_LOADED")
	end	
	
  
end)

-------------------------------------------------
-- Borrowerd from nPlates by Grimsbain
-------------------------------------------------
local cPlates = CreateFrame("Frame")

local len = string.len
local gsub = string.gsub

---------------
-- Functions
---------------

	-- PvP Icon
local pvpIcons = {
	Alliance = "\124TInterface/PVPFrame/PVP-Currency-Alliance:16\124t",
	Horde = "\124TInterface/PVPFrame/PVP-Currency-Horde:16\124t",
}

cPlates.PvPIcon = function(unit)
	if ( cPlatesDB.ShowPvP and UnitIsPlayer(unit) ) then
		local isPVP = UnitIsPVP(unit)
		local faction = UnitFactionGroup(unit)
		local icon = (isPVP and faction) and pvpIcons[faction] or ""

		return icon
	end
	return ""
end

	-- Check for "Larger Nameplates"

cPlates.IsUsingLargerNamePlateStyle = function()
	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
	return namePlateVerticalScale > 1.0
end

	-- Check if the frame is a nameplate.

cPlates.FrameIsNameplate = function(frame)
	if ( string.match(frame.displayedUnit,"nameplate") ~= "nameplate") then
		return false
	else
		return true
	end
end

	-- Checks to see if target has tank role.

cPlates.PlayerIsTank = function(target)
	local assignedRole = UnitGroupRolesAssigned(target)

	return assignedRole == "TANK"
end

	-- Abbreviate Function

cPlates.Abbrev = function(str,length)
	if ( str ~= nil and length ~= nil ) then
		str = (len(str) > length) and gsub(str, "%s?(.[\128-\191]*)%S+%s", "%1. ") or str
		return str
	end
	return ""
end

	-- RBG to Hex Colors

cPlates.RGBHex = function(r, g, b)
	if ( type(r) == "table" ) then
		if ( r.r ) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

-- Off Tank Color Checks

cPlates.UseOffTankColor = function(target)
	if ( cPlatesDB.UseOffTankColor and (UnitPlayerOrPetInRaid(target) or UnitPlayerOrPetInParty(target)) ) then
		if ( not UnitIsUnit("player",target) and cPlates.PlayerIsTank(target) and cPlates.PlayerIsTank("player") ) then
			return true
		end
	end
	return false
end

	-- Format Health
	
cPlates.FormatValue = function(number)
	if number < 1e3 then
		return floor(number)
	elseif number >= 1e12 then
		return string.format("%.3ft", number/1e12)
	elseif number >= 1e9 then
		return string.format("%.3fb", number/1e9)
	elseif number >= 1e6 then
		return string.format("%.2fm", number/1e6)
	elseif number >= 1e3 then
		return string.format("%.1fk", number/1e3)
	end
end

	-- Totem Data and Functions

local function TotemName(SpellID)
	local name = GetSpellInfo(SpellID)
	return name
end

local totemData = {
	[TotemName(192058)] = "Interface\\Icons\\spell_nature_brilliance",          -- Lightning Surge Totem
	[TotemName(98008)]  = "Interface\\Icons\\spell_shaman_spiritlink",          -- Spirit Link Totem
	[TotemName(192077)] = "Interface\\Icons\\ability_shaman_windwalktotem",     -- Wind Rush Totem
	[TotemName(204331)] = "Interface\\Icons\\spell_nature_wrathofair_totem",    -- Counterstrike Totem
	[TotemName(204332)] = "Interface\\Icons\\spell_nature_windfury",            -- Windfury Totem
	[TotemName(204336)] = "Interface\\Icons\\spell_nature_groundingtotem",      -- Grounding Totem
	-- Water
	[TotemName(157153)] = "Interface\\Icons\\ability_shaman_condensationtotem", -- Cloudburst Totem
	[TotemName(5394)]   = "Interface\\Icons\\INV_Spear_04",                     -- Healing Stream Totem
	[TotemName(108280)] = "Interface\\Icons\\ability_shaman_healingtide",       -- Healing Tide Totem
	-- Earth
	[TotemName(207399)] = "Interface\\Icons\\spell_nature_reincarnation",       -- Ancestral Protection Totem
	[TotemName(198838)] = "Interface\\Icons\\spell_nature_stoneskintotem",      -- Earthen Shield Totem
	[TotemName(51485)]  = "Interface\\Icons\\spell_nature_stranglevines",       -- Earthgrab Totem
	[TotemName(61882)]  = "Interface\\Icons\\spell_shaman_earthquake",          -- Earthquake Totem
	[TotemName(196932)] = "Interface\\Icons\\spell_totem_wardofdraining",       -- Voodoo Totem
	-- Fire
	[TotemName(192222)] = "Interface\\Icons\\spell_shaman_spewlava",            -- Liquid Magma Totem
	[TotemName(204330)] = "Interface\\Icons\\spell_fire_totemofwrath",          -- Skyfury Totem
	-- Totem Mastery
	[TotemName(202188)] = "Interface\\Icons\\spell_nature_stoneskintotem",      -- Resonance Totem
	[TotemName(210651)] = "Interface\\Icons\\spell_shaman_stormtotem",          -- Storm Totem
	[TotemName(210657)] = "Interface\\Icons\\spell_fire_searingtotem",          -- Ember Totem
	[TotemName(210660)] = "Interface\\Icons\\spell_nature_invisibilitytotem",   -- Tailwind Totem
}

cPlates.UpdateTotemIcon = function(frame)
	if ( not cPlates.FrameIsNameplate(frame) ) then return end

	local name = UnitName(frame.displayedUnit)

	if name == nil then return end
	if (totemData[name] and cPlatesDB.ShowTotemIcon ) then
		if (not frame.TotemIcon) then
			frame.TotemIcon = CreateFrame("Frame", "$parentTotem", frame)
			frame.TotemIcon:EnableMouse(false)
			frame.TotemIcon:SetSize(24, 24)
			frame.TotemIcon:SetPoint("BOTTOM", frame.BuffFrame, "TOP", 0, 10)
		end

		if (not frame.TotemIcon.Icon) then
			frame.TotemIcon.Icon = frame.TotemIcon:CreateTexture("$parentIcon","BACKGROUND")
			frame.TotemIcon.Icon:SetSize(24,24)
			frame.TotemIcon.Icon:SetAllPoints(frame.TotemIcon)
			frame.TotemIcon.Icon:SetTexture(totemData[name])
			frame.TotemIcon.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end

		if (not frame.TotemIcon.Icon.Border) then
			frame.TotemIcon.Icon.Border = frame.TotemIcon:CreateTexture("$parentOverlay", "BORDER")
			frame.TotemIcon.Icon.Border:SetTexCoord(0, 1, 0, 1)
			frame.TotemIcon.Icon.Border:ClearAllPoints()
			frame.TotemIcon.Icon.Border:SetPoint("TOPRIGHT", frame.TotemIcon.Icon, 2.5, 2.5)
			frame.TotemIcon.Icon.Border:SetPoint("BOTTOMLEFT", frame.TotemIcon.Icon, -2.5, -2.5)
			frame.TotemIcon.Icon.Border:SetTexture(iconOverlay)
			frame.TotemIcon.Icon.Border:SetVertexColor(unpack(borderColor))
		end

		if ( frame.TotemIcon ) then
			frame.TotemIcon:Show()
		end
	else
		if (frame.TotemIcon) then
			frame.TotemIcon:Hide()
		end
	end
end

	-- Set Defaults

cPlates.RegisterDefaultSetting = function(key,value)
	if ( cPlatesDB == nil ) then
		cPlatesDB = {}
	end
	if ( cPlatesDB[key] == nil ) then
		cPlatesDB[key] = value
	end
end	


C_Timer.After(.1, function()

		-- Set Default Options

	cPlates.RegisterDefaultSetting("ColorNameByThreat", false)
	cPlates.RegisterDefaultSetting("ShowHP", true)
	cPlates.RegisterDefaultSetting("ShowCurHP", true)
	cPlates.RegisterDefaultSetting("ShowPercHP", true)
	cPlates.RegisterDefaultSetting("ShowFullHP", true)
	cPlates.RegisterDefaultSetting("ShowLevel", true)
	cPlates.RegisterDefaultSetting("ShowServerName", false)
	cPlates.RegisterDefaultSetting("AbrrevLongNames", true)
	cPlates.RegisterDefaultSetting("HideFriendly", false)
	cPlates.RegisterDefaultSetting("DontClamp", false)
	cPlates.RegisterDefaultSetting("ShowTotemIcon", false)
	cPlates.RegisterDefaultSetting("UseOffTankColor", false)
	cPlates.RegisterDefaultSetting("OffTankColor", { r = 0.60, g = 0.20, b = 1.0})
	cPlates.RegisterDefaultSetting("ShowPvP", false)

		-- Set CVars

	if not InCombatLockdown() then
		-- Set min and max scale.
		SetCVar("namePlateMinScale", 1)
		SetCVar("namePlateMaxScale", 1)

		-- Set sticky nameplates.
		if ( not cPlatesDB.DontClamp ) then
			SetCVar("nameplateOtherTopInset", -1,true)
			SetCVar("nameplateOtherBottomInset", -1,true)
		else
			for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v),true) end
		end
	end
end)

-----------------
-- Update Name
-----------------
hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if ( not cPlates.FrameIsNameplate(frame) ) then return end

		-- Totem Icon

	if ( cPlatesDB.ShowTotemIcon ) then
		cPlates.UpdateTotemIcon(frame)
	end

		-- Hide Friendly Nameplates

	if ( UnitIsFriend(frame.displayedUnit,"player") and not UnitCanAttack(frame.displayedUnit,"player") and cPlatesDB.HideFriendly ) then
		frame.healthBar:Hide()
	else
		frame.healthBar:Show()
	end

	if ( not ShouldShowName(frame) ) then
		frame.name:Hide()
	else

			-- PvP Icon

		local pvpIcon = cPlates.PvPIcon(frame.displayedUnit)

			-- Class Color Names

		if ( UnitIsPlayer(frame.displayedUnit) ) then
			local r,g,b = frame.healthBar:GetStatusBarColor()
			frame.name:SetTextColor(r,g,b)
		end

			-- Shorten Long Names

		local newName = GetUnitName(frame.displayedUnit, cPlatesDB.ShowServerName) or UNKNOWN
		if ( cPlatesDB.AbrrevLongNames ) then
			newName = cPlates.Abbrev(newName,20)
		end

			-- Level

		if ( cPlatesDB.ShowLevel ) then
			local playerLevel = UnitLevel("player")
			local targetLevel = UnitLevel(frame.displayedUnit)
			local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
			local levelColor = cPlates.RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

			if ( targetLevel == -1 ) then
				frame.name:SetText(pvpIcon..newName)
			else
				frame.name:SetText(pvpIcon.."|cffffff00|r"..levelColor..targetLevel.."|r "..newName)
			end
		else
			frame.name:SetText(pvpIcon..newName or newName)
		end

			-- Color Name To Threat Status

		if ( cPlatesDB.ColorNameByThreat ) then
			local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
			if ( isTanking and threatStatus ) then
				if ( threatStatus >= 3 ) then
					frame.name:SetTextColor(0,1,0)
				elseif ( threatStatus == 2 ) then
					frame.name:SetTextColor(1,0.6,0.2)
				end
			else
				local target = frame.displayedUnit.."target"
				if ( cPlates.UseOffTankColor(target) ) then
					frame.name:SetTextColor(cPlatesDB.OffTankColor.r, cPlatesDB.OffTankColor.g, cPlatesDB.OffTankColor.b)
				end
			end
		end
	end
end)

	-- Updated Health Text

hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
	if ( not cPlates.FrameIsNameplate(frame) ) then return end

	local font = select(1,frame.name:GetFont())
	local hexa = ("|cff%.2x%.2x%.2x"):format(255, 255, 51)
	local hexb = "|r"

	if ( cPlatesDB.ShowHP ) then
		if ( not frame.healthBar.healthString ) then
			frame.healthBar.healthString = frame.healthBar:CreateFontString("$parentHeathValue", "OVERLAY")
			frame.healthBar.healthString:Hide()
			frame.healthBar.healthString:SetPoint("CENTER", frame.healthBar, 0, .5)
			frame.healthBar.healthString:SetFont(font, 12)
			frame.healthBar.healthString:SetShadowOffset(.5, -.5)
		end
	else
		if ( frame.healthBar.healthString ) then frame.healthBar.healthString:Hide() end
		return
	end

	local health = UnitHealth(frame.displayedUnit)
	local maxHealth = UnitHealthMax(frame.displayedUnit)
	local perc = (health/maxHealth)*100

	if ( perc >= 100 and health > 5 and cPlatesDB.ShowFullHP ) then
		if ( cPlatesDB.ShowCurHP and perc >= 100 ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s"..hexb, cPlates.FormatValue(health))
		elseif ( cPlatesDB.ShowCurHP and cPlatesDB.ShowPercHP ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s - %s%%"..hexb, cPlates.FormatValue(health), cPlates.FormatValue(perc))
		elseif ( cPlatesDB.ShowCurHP ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s"..hexb, cPlates.FormatValue(health))
		elseif ( cPlatesDB.ShowPercHP ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s%%"..hexb, cPlates.FormatValue(perc))
		else
			frame.healthBar.healthString:SetText("")
		end
	elseif ( perc < 100 and health > 5 ) then
		if ( cPlatesDB.ShowCurHP and cPlatesDB.ShowPercHP ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s - %s%%"..hexb, cPlates.FormatValue(health), cPlates.FormatValue(perc))
		elseif ( cPlatesDB.ShowCurHP ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s"..hexb, cPlates.FormatValue(health))
		elseif ( cPlatesDB.ShowPercHP ) then
			frame.healthBar.healthString:SetFormattedText(hexa.."%s%%"..hexb, cPlates.FormatValue(perc))
		else
			frame.healthBar.healthString:SetText("")
		end
	else
		frame.healthBar.healthString:SetText("")
	end
	frame.healthBar.healthString:Show()
end)	