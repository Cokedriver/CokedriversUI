local cUnitframes = CreateFrame("Frame")
cUnitframes:RegisterEvent("ADDON_LOADED")
cUnitframes:SetScript("OnEvent", function(self, event, arg1)

	if event == "ADDON_LOADED" and arg1 == "cUnitframes" then
		local UnitScale = 1.2
		local UnitframeFont = [[Interface\AddOns\CokedriversUI\Media\Expressway_Rg _BOLD.ttf]]
		
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
		----------------------------------------------------------
		--[[] Unit Healthbar and Powerbar Text
		for _, HPMPText in pairs({
			PlayerFrameHealthBarText,
			PlayerFrameManaBarText,
			TargetFrameTextureFrameHealthBarText,
			TargetFrameTextureFrameManaBarText,
		}) do
			HPMPText:SetFont('Fonts\\ARIALN.ttf', 12, 'THINOUTLINE')
		end]]
		----------------------------------------------------------
		
		
		--[[ Castbar Scaling ]]--
		----------------------------------------------------------
		-- Player Castbar
		CastingBarFrame:SetScale(UnitScale)
		--CastingBarFrame:ClearAllPoints()
		--CastingBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		
		--[[ Target Castbar
		Target_Spellbar_AdjustPosition = function() end
		TargetFrameSpellBar:SetParent(UIParent)
		TargetFrameSpellBar:ClearAllPoints()
		TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
		TargetFrameSpellBar:SetScale(UnitScale)
		TargetFrameSpellBar:SetScript("OnShow", nil)]]
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

	-- Nameplates Percentage
	
	local frequency = 0.2 -- how frequently to look for new nameplates and update visible percents
	local numChildren = 0 -- number of WorldFrame's children
	local overlays = {} -- indexed by overlay frame added to each nameplate's statusBar

	local PercentFrame = CreateFrame("Frame",nil,UIParent)
	PercentFrame.timer = 0
	PercentFrame.knownChildren = 0 -- number of WorldFrame's children that we know about

	-- updates the percentOverlay text on the nameplate's statusbar
	local function UpdatePercent(self)
		local parent = self:GetParent()
		local value = parent:GetValue()
		local _,maxValue = parent:GetMinMaxValues()
		if maxValue and value<maxValue then
			self:SetText(('|cFF%2x%2x%2x%s|r'):format(255, 255, 51, format("%d%%",100*value/maxValue)))
		else
			self:SetText("") -- blank if no relevant values or value is maxValue (100% life)
		end
	end

	-- when a nameplate shows, add it to frame.statusBars
	local function ShowPercent(self)
		overlays[self.percentOverlay] = 1
	end

	-- when a nameplate hides, remove it from frame.statusBars
	local function HidePercent(self)
		overlays[self.percentOverlay] = nil
		self.percentOverlay:SetText("") -- blank for when nameplate reused
	end

	-- look for new nameplates that don't have a percent overlay and add one
	function PercentFrame:ScanNameplates(...)
	  for i=1,select("#",...) do
		local plate = select(i,...)
			local name = plate:GetName()
			if name and name:match("^NamePlate") then
				-- the statusBar is the first child of the first child of the nameplate
				local statusBar = plate:GetChildren():GetChildren()
				if not statusBar.percentOverlay then
					statusBar.percentOverlay = statusBar:CreateFontString(nil,"OVERLAY","ReputationDetailFont")
					local percent = statusBar.percentOverlay
					percent:SetPoint("CENTER")
					statusBar:HookScript("OnShow",ShowPercent)
					statusBar:HookScript("OnHide",HidePercent)
					overlays[statusBar.percentOverlay] = 1 -- add new child to next update batch
				end
		end
	  end
	end

	function PercentFrame:OnUpdate(elapsed)
		self.timer = self.timer + elapsed
		if self.timer > frequency then
			self.timer = 0
			-- first look for any new nameplates (if WorldFrame has a new kid, it's likely a nameplate)
		numChildren = WorldFrame:GetNumChildren()
			if numChildren > self.knownChildren then
				self.knownChildren = numChildren
		  self:ScanNameplates(WorldFrame:GetChildren())
		end
			-- next update percents for all visible nameplate statusBars
			for overlay in pairs(overlays) do
				UpdatePercent(overlay)
			end
	  end
	end
	PercentFrame:SetScript("OnUpdate",PercentFrame.OnUpdate)

	-- Borrowerd from nPlates by Grimsbain
	local config = {
		-- Colors by threat. Green = Tanking, Orange = Loosing Threat, Red = Lost Threat
		colorNameWithThreat = false,

		showLevel = true,
		showServerName = false,
		abbrevLongNames = true,

		-- Use class colors on all player nameplates.
		alwaysUseClassColors = true,
	}	

	local function RGBHex(r, g, b)
		if ( type(r) == 'table' ) then
			if ( r.r ) then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end

		return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
	end	
	local len = string.len
	local gsub = string.gsub
	local function UpdateName(frame)
		if ( string.match(frame.displayedUnit,'nameplate') ~= 'nameplate' ) then return end


		if ( not ShouldShowName(frame) ) then
			frame.name:Hide()
		else

				-- Friendly Nameplate Class Color

			if ( config.alwaysUseClassColors ) then
				if ( UnitIsPlayer(frame.displayedUnit) ) then
					frame.name:SetTextColor(frame.healthBar:GetStatusBarColor())
					DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = true
				end
			end

				-- Shorten Long Names

			local newName = GetUnitName(frame.displayedUnit, config.showServerName) or 'Unknown'
			if ( config.abbrevLongNames ) then
				newName = (len(newName) > 20) and gsub(newName, '%s?(.[\128-\191]*)%S+%s', '%1. ') or newName
			end

				-- Level

			if ( config.showLevel ) then
				local playerLevel = UnitLevel('player')
				local targetLevel = UnitLevel(frame.displayedUnit)
				local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
				local levelColor = RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

				if ( targetLevel == -1 ) then
					frame.name:SetText(newName)
				else
					frame.name:SetText('|cffffff00|r'..levelColor..targetLevel..'|r '..newName)
				end
			else
				frame.name:SetText(newName)
			end

				-- Color Name To Threat Status

			if ( config.colorNameWithThreat ) then
				local isTanking, threatStatus = UnitDetailedThreatSituation('player', frame.displayedUnit)
				if ( isTanking and threatStatus ) then
					if ( threatStatus >= 3 ) then
						frame.name:SetTextColor(0,1,0)
					elseif ( threatStatus == 2 ) then
						frame.name:SetTextColor(1,0.6,0.2)
					end
				end
			end
		end
	end
	hooksecurefunc('CompactUnitFrame_UpdateName', UpdateName)
end)