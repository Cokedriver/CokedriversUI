local cUnitframes = CreateFrame("Frame")
cUnitframes:RegisterEvent("ADDON_LOADED")
cUnitframes:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "cUnitframes" then
		local UnitScale = 1.2
		
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
			elseif UnitIsDeadOrGhost(unit) or UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
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
			region:SetTexture(0, 0, 0, 0.5)
		end
		----------------------------------------------------------
		
		
		--[[ Unit Name Font Size ]]--
		----------------------------------------------------------
		for _, names in pairs({
			PlayerName,
			TargetFrameTextureFrameName,
			FocusFrameTextureFrameName,
		}) do
			names:SetFont([[Interface\AddOns\cUnitframes\Media\Expressway_Rg _BOLD.ttf]], 16)
		
		end
		----------------------------------------------------------
		
		
		--[[ Unit Level Text Centering ]]--
		----------------------------------------------------------
		-- PlayerFrame
		hooksecurefunc("PlayerFrame_UpdateLevelTextAnchor", function(level)
		  if ( level >= 100 ) then
			PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -60.5, -15);
		  else
			PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -61, -15);
		  end
		end)
		
		-- TargetFrame
		hooksecurefunc("TargetFrame_UpdateLevelTextAnchor",  function(self, targetLevel)
		  if ( targetLevel >= 100 ) then
			self.levelText:SetPoint("CENTER", 62, -15);
		  else
			self.levelText:SetPoint("CENTER", 62, -15);
		  end
		end)
		----------------------------------------------------------
		
		
		--[[ Castbar Scaling ]]--
		----------------------------------------------------------
		-- Player Castbar
		CastingBarFrame:SetScale(UnitScale)
		
		-- Target Castbar
		Target_Spellbar_AdjustPosition = function() end
		TargetFrameSpellBar:SetParent(UIParent)
		TargetFrameSpellBar:ClearAllPoints()
		TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
		TargetFrameSpellBar:SetScale(UnitScale)
		TargetFrameSpellBar:SetScript("OnShow", nil)
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
		local function ScaleArenaFrames()
			for i = 1, MAX_ARENA_ENEMIES do
				_G["ArenaPrepFrame"..i]:SetScale(UnitScale)
				_G["ArenaEnemyFrame"..i]:SetScale(UnitScale)
			end
		end

		if IsAddOnLoaded("Blizzard_ArenaUI") then
			ScaleArenaFrames()
		else
			local f = CreateFrame("Frame")
			f:RegisterEvent("ADDON_LOADED")
			f:SetScript("OnEvent", function(self, event, addon)
				if addon == "Blizzard_ArenaUI" then
					self:UnregisterEvent(event)
					ScaleArenaFrames()
				end
			end)
		end
		----------------------------------------------------------
		
		
		--[[ Boss Frames Scaling ]]--
		----------------------------------------------------------
		for i = 1, MAX_BOSS_FRAMES do
			_G["Boss"..i.."TargetFrame"]:SetScale(UnitScale)
		end
		----------------------------------------------------------
		
		--self:UnregisterEvent("ADDON_LOADED")
	end

	SlashCmdList['RELOADUI'] = function()
		ReloadUI()
	end
	SLASH_RELOADUI1 = '/rl'

end)