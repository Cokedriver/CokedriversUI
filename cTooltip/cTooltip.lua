
local _G = _G
local select = select
local format = string.format

local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitExists = UnitExists
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitFactionGroup = UnitFactionGroup
local UnitCreatureType = UnitCreatureType
local GetQuestDifficultyColor = GetQuestDifficultyColor

local tankIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t'
local healIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t'
local damagerIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t'

local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local fontOutline = true
local disableFade = false                     		-- Can cause errors or a buggy tooltip!
local abbrevRealmNames = true 	
local hideInCombat = false                       -- Hide unit frame tooltips during combat	
local hideRealmText = true                      -- Hide the coalesced/interactive realm text	
local reactionBorderColor = true
local itemqualityBorderColor = true
local showPlayerTitles = true
local showPVPIcons = false                        	-- Show pvp icons instead of just a prefix
local showMouseoverTarget = true
local showOnMouseover = false
local showUnitRole = true
local showSpecializationIcon = false
local healthbar = {
	showHealthValue = true,
	showOutline = true,
	healthFormat = '$cur / $max',           -- Possible: $cur, $max, $deficit, $perc, $smartperc, $smartcolorperc, $colorperc
	healthFullFormat = '$cur',              -- if the tooltip unit has 100% hp 		
	textPos = "CENTER",                     -- Possible "TOP" "BOTTOM" "CENTER"	
	reactionColoring = false,
	custom = {
		apply = false,
		color =	{ r = 1, g = 1, b = 0},
	},		
	--fontSize = 15,
}		

SlashCmdList['RELOADUI'] = function()
	ReloadUI()
end
SLASH_RELOADUI1 = '/rl'

--GameTooltipHeaderText:SetFont([[Interface/Addons/cTooltip/Media/Expressway_Rg_BOLD.ttf]], 18, 'THINOUTLINE')
GameTooltipStatusBar:SetHeight(7)
GameTooltipStatusBar:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
GameTooltipStatusBar:SetBackdropColor(0, 1, 0, 0.3)

local CUSTOM_FACTION_BAR_COLORS = {
	[1] = {r = 1, g = 0, b = 0},
	[2] = {r = 1, g = 0, b = 0},
	[3] = {r = 1, g = 1, b = 0},
	[4] = {r = 1, g = 1, b = 0},
	[5] = {r = 0, g = 1, b = 0},
	[6] = {r = 0, g = 1, b = 0},
	[7] = {r = 0, g = 1, b = 0},
	[8] = {r = 0, g = 1, b = 0},
}
function GameTooltip_UnitColor(unit)
	local r, g, b

	if (UnitIsDead(unit) or UnitIsGhost(unit)) then
		r = 0.5
		g = 0.5
		b = 0.5 
	elseif (UnitIsPlayer(unit)) then
		if (UnitIsFriend(unit, 'player')) then
			local _, class = UnitClass(unit)
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		elseif (not UnitIsFriend(unit, 'player')) then
			r = 1
			g = 0
			b = 0
		end
	elseif (UnitPlayerControlled(unit)) then
		if (UnitCanAttack(unit, 'player')) then
			if (not UnitCanAttack('player', unit)) then
				r = 157/255
				g = 197/255
				b = 255/255
			else
				r = 1
				g = 0
				b = 0
			end
		elseif (UnitCanAttack('player', unit)) then
			r = 1
			g = 1
			b = 0
		elseif (UnitIsPVP(unit)) then
			r = 0
			g = 1
			b = 0
		else
			r = 157/255
			g = 197/255
			b = 255/255
		end
	else
		local reaction = UnitReaction(unit, 'player')

		if (reaction) then
			r = CUSTOM_FACTION_BAR_COLORS[reaction].r
			g = CUSTOM_FACTION_BAR_COLORS[reaction].g
			b = CUSTOM_FACTION_BAR_COLORS[reaction].b
		else
			r = 157/255
			g = 197/255
			b = 255/255
		end
	end

	return r, g, b
end
  
UnitSelectionColor = GameTooltip_UnitColor

local function ApplyTooltipStyle(self)
	local bgsize, bsize
	if (self == ConsolidatedBuffsTooltip) then
		bgsize = 1
		bsize = 8
	elseif (self == FriendsTooltip) then
		FriendsTooltip:SetScale(1.1)

		bgsize = 1
		bsize = 9
	else
		bgsize = 3
		bsize = 12
	end

	self:SetBackdrop({
		bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = true, tileSize = 16, edgeSize = 18,

		insets = {
			left = bgsize, right = bgsize, top = bgsize, bottom = bgsize
		}
	})
	self:HookScript('OnShow', function(self)
		self:SetBackdropColor(0, 0, 0, 0.7)
	end)

	self:HookScript('OnHide', function(self)
		self:SetBackdropColor(0, 0, 0, 0.7)
	end)

	self:HookScript('OnUpdate', function(self)
		self:SetBackdropColor(0, 0, 0, 0.7)
	end)
end

for _, tooltip in pairs({
	GameTooltip,
	ItemRefTooltip,

	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,

	WorldMapTooltip,

	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,

	ConsolidatedBuffsTooltip,

	ChatMenu,
	EmoteMenu,
	LanguageMenu,
	VoiceMacroMenu,

	FriendsTooltip,
	
	FloatingGarrisonFollowerTooltip,
}) do
	ApplyTooltipStyle(tooltip)
end

	-- Itemquaility border

if (itemqualityBorderColor) then
	for _, tooltip in pairs({
		GameTooltip,
		ItemRefTooltip,

		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
	}) do
		tooltip:HookScript('OnTooltipSetItem', function(self)
			local name, item = self:GetItem()
			if (item) then
				local quality = select(3, GetItemInfo(item))
				if (quality) then
					local r, g, b = GetItemQualityColor(quality)
					self:SetBackdropBorderColor(r, g, b)
				end
			end
		end)

		tooltip:HookScript('OnTooltipCleared', function(self)
			self:SetBackdropBorderColor(1, 1, 1)
		end)
	end
end

	-- Make sure we get a correct unit

local function GetRealUnit(self)
	if (GetMouseFocus() and not GetMouseFocus():GetAttribute('unit') and GetMouseFocus() ~= WorldFrame) then
		return select(2, self:GetUnit())
	elseif (GetMouseFocus() and GetMouseFocus():GetAttribute('unit')) then
		return GetMouseFocus():GetAttribute('unit')
	elseif (select(2, self:GetUnit())) then
		return select(2, self:GetUnit())
	else
		return 'mouseover'
	end
end

local function GetFormattedUnitType(unit)
	local creaturetype = UnitCreatureType(unit)
	if (creaturetype) then
		return creaturetype
	else
		return ''
	end
end

local function GetFormattedUnitClassification(unit)
	local class = UnitClassification(unit)
	if (class == 'worldboss') then
		return '|cffFF0000'..BOSS..'|r '
	elseif (class == 'rareelite') then
		return '|cffFF66CCRare|r |cffFFFF00'..ELITE..'|r '
	elseif (class == 'rare') then
		return '|cffFF66CCRare|r '
	elseif (class == 'elite') then
		return '|cffFFFF00'..ELITE..'|r '
	else
		return ''
	end
end

local function GetFormattedUnitLevel(unit)
	local diff = GetQuestDifficultyColor(UnitLevel(unit))
	if (UnitLevel(unit) == -1) then
		return '|cffff0000??|r '
	elseif (UnitLevel(unit) == 0) then
		return '? '
	else
		return format('|cff%02x%02x%02x%s|r ', diff.r*255, diff.g*255, diff.b*255, UnitLevel(unit))
	end
end

local function GetFormattedUnitClass(unit)
	local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	if (color) then
		return format(' |cff%02x%02x%02x%s|r', color.r*255, color.g*255, color.b*255, UnitClass(unit))
	end
end

local function GetFormattedUnitString(unit, specIcon)
	if (UnitIsPlayer(unit)) then
		if (not UnitRace(unit)) then
			return nil
		end
		return GetFormattedUnitLevel(unit)..UnitRace(unit)..GetFormattedUnitClass(unit)..(showSpecializationIcon and specIcon or '')
	else
		return GetFormattedUnitLevel(unit)..GetFormattedUnitClassification(unit)..GetFormattedUnitType(unit)
	end
end

local function GetUnitRoleString(unit)
	local role = UnitGroupRolesAssigned(unit)
	local roleList = nil

	if (role == 'TANK') then
		roleList = '   '..tankIcon..' '..TANK
	elseif (role == 'HEALER') then
		roleList = '   '..healIcon..' '..HEALER
	elseif (role == 'DAMAGER') then
		roleList = '   '..damagerIcon..' '..DAMAGER
	end

	return roleList
end

	-- Healthbar coloring funtion

local function SetHealthBarColor(unit)
	local r, g, b
	if (healthbar.custom.apply and not healthbar.reactionColoring) then
		r, g, b = healthbar.custom.color.r, healthbar.custom.color.g, healthbar.custom.color.b
	elseif (healthbar.reactionColoring and unit) then
		r, g, b = UnitSelectionColor(unit)
	else
		r, g, b = 0, 1, 0
	end

	GameTooltipStatusBar:SetStatusBarColor(r, g, b)
	GameTooltipStatusBar:SetBackdropColor(r, g, b, 0.3)
end

local function GetUnitRaidIcon(unit)
	local index = GetRaidTargetIndex(unit)

	if (index) then
		if (UnitIsPVP(unit) and showPVPIcons) then
			return ICON_LIST[index]..'11|t'
		else
			return ICON_LIST[index]..'11|t '
		end
	else
		return ''
	end
end

local function GetUnitPVPIcon(unit)
	local factionGroup = UnitFactionGroup(unit)

	if (UnitIsPVPFreeForAll(unit)) then
		if (showPVPIcons) then
			return '|TInterface\\AddOns\\cTooltip\\Media\\UI-PVP-FFA:12|t'
		else
			return '|cffFF0000# |r'
		end
	elseif (factionGroup and UnitIsPVP(unit)) then
		if (showPVPIcons) then
			return '|TInterface\\AddOns\\cTooltip\\Media\\UI-PVP-'..factionGroup..':12|t'
		else
			return '|cff00FF00# |r'
		end
	else
		return ''
	end
end

local function AddMouseoverTarget(self, unit)
	local unitTargetName = UnitName(unit..'target')
	local unitTargetClassColor = RAID_CLASS_COLORS[select(2, UnitClass(unit..'target'))] or { r = 1, g = 0, b = 1 }
	local unitTargetReactionColor = {
		r = select(1, UnitSelectionColor(unit..'target')),
		g = select(2, UnitSelectionColor(unit..'target')),
		b = select(3, UnitSelectionColor(unit..'target'))
	}

	if (UnitExists(unit..'target')) then
		if (UnitName('player') == unitTargetName) then
			self:AddLine(format('|cffFFFF00Target|r: '..GetUnitRaidIcon(unit..'target')..'|cffff00ff%s|r', string.upper("** YOU **")), 1, 1, 1)
		else
			if (UnitIsPlayer(unit..'target')) then
				self:AddLine(format('|cffFFFF00Target|r: '..GetUnitRaidIcon(unit..'target')..'|cff%02x%02x%02x%s|r', unitTargetClassColor.r*255, unitTargetClassColor.g*255, unitTargetClassColor.b*255, unitTargetName:sub(1, 40)), 1, 1, 1)
			else
				self:AddLine(format('|cffFFFF00Target|r: '..GetUnitRaidIcon(unit..'target')..'|cff%02x%02x%02x%s|r', unitTargetReactionColor.r*255, unitTargetReactionColor.g*255, unitTargetReactionColor.b*255, unitTargetName:sub(1, 40)), 1, 1, 1)
			end
		end
	end
end

GameTooltip.inspectCache = {}

GameTooltip:HookScript('OnTooltipSetUnit', function(self, ...)
	local unit = GetRealUnit(self)

	if (hideInCombat and InCombatLockdown()) then
		self:Hide()
		return
	end

	if (UnitExists(unit) and UnitName(unit) ~= UNKNOWN) then

		local name, realm = UnitName(unit)

			-- Hide player titles

		if (showPlayerTitles) then
			if (UnitPVPName(unit)) then
				name = UnitPVPName(unit)
			end
		end

		GameTooltipTextLeft1:SetText(name)

			-- Color guildnames

		if (GetGuildInfo(unit)) then
			if (GetGuildInfo(unit) == GetGuildInfo('player') and IsInGuild('player')) then
			   GameTooltipTextLeft2:SetText('|cffFF66CC'..GameTooltipTextLeft2:GetText()..'|r')
			end
		end

			-- Tooltip level text

		for i = 2, GameTooltip:NumLines() do
			if (_G['GameTooltipTextLeft'..i]:GetText():find('^'..TOOLTIP_UNIT_LEVEL:gsub('%%s', '.+'))) then
				_G['GameTooltipTextLeft'..i]:SetText(GetFormattedUnitString(unit, specIcon))
			end
		end

			-- Role text

		if (showUnitRole) then
			self:AddLine(GetUnitRoleString(unit), 1, 1, 1)
		end

			-- Mouse over target with raidicon support

		if (showMouseoverTarget) then
			AddMouseoverTarget(self, unit)
		end

			-- Pvp flag prefix

		for i = 3, GameTooltip:NumLines() do
			if (_G['GameTooltipTextLeft'..i]:GetText():find(PVP_ENABLED)) then
				_G['GameTooltipTextLeft'..i]:SetText(nil)
				GameTooltipTextLeft1:SetText(GetUnitPVPIcon(unit)..GameTooltipTextLeft1:GetText())
			end
		end

			-- Raid icon, want to see the raidicon on the left

		GameTooltipTextLeft1:SetText(GetUnitRaidIcon(unit)..GameTooltipTextLeft1:GetText())

			-- Afk and dnd prefix

		if (UnitIsAFK(unit)) then
			self:AppendText('|cff00ff00 <AFK>|r')
		elseif (UnitIsDND(unit)) then
			self:AppendText('|cff00ff00 <DND>|r')
		end

			-- Player realm names

		if (realm and realm ~= '') then
			if (abbrevRealmNames)   then
				self:AppendText(' (*)')
			else
				self:AppendText(' - '..realm)
			end
		end

			-- Move the healthbar inside the tooltip

		self:AddLine(' ')
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('LEFT', self:GetName()..'TextLeft'..self:NumLines(), 1, -3)
		GameTooltipStatusBar:SetPoint('RIGHT', self, -10, 0)

			-- Border coloring

		if (reactionBorderColor) then
			local r, g, b = UnitSelectionColor(unit)
				self:SetBackdropBorderColor(r, g, b)
		end

			-- Dead or ghost recoloring

		if (UnitIsDead(unit) or UnitIsGhost(unit)) then
			GameTooltipStatusBar:SetBackdropColor(0.5, 0.5, 0.5, 0.3)
		else
			if (not healthbar.custom.apply and not healthbar.reactionColoring) then
				GameTooltipStatusBar:SetBackdropColor(27/255, 243/255, 27/255, 0.3)
			else
				SetHealthBarColor(unit)
			end
		end

			-- Custom healthbar coloring

		if (healthbar.reactionColoring or healthbar.custom.apply) then
			GameTooltipStatusBar:HookScript('OnValueChanged', function()
				SetHealthBarColor(unit)
			end)
		end

	end
end)

GameTooltip:HookScript('OnTooltipCleared', function(self)
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0.5, 3)
	GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -1, 3)
	GameTooltipStatusBar:SetBackdropColor(0, 1, 0, 0.3)

	if (reactionBorderColor) then
		self:SetBackdropColor(1, 1, 1)
	end
end)


	-- Hide coalesced/interactive realm information

if (hideRealmText) then
	local COALESCED_REALM_TOOLTIP1 = string.split(FOREIGN_SERVER_LABEL, COALESCED_REALM_TOOLTIP)
	local INTERACTIVE_REALM_TOOLTIP1 = string.split(INTERACTIVE_SERVER_LABEL, INTERACTIVE_REALM_TOOLTIP)
	-- Dirty checking of the coalesced realm text because it's added
	-- after the initial OnShow
	GameTooltip:HookScript('OnUpdate', function(self)
		for i = 3, self:NumLines() do
			local row = _G['GameTooltipTextLeft'..i]
			local rowText = row:GetText()

			if (rowText) then
				if (rowText:find(COALESCED_REALM_TOOLTIP1) or rowText:find(INTERACTIVE_REALM_TOOLTIP1)) then
					row:SetText(nil)
					row:Hide()

					local previousRow = _G['GameTooltipTextLeft'..(i - 1)]
					previousRow:SetText(nil)
					previousRow:Hide()

					self:Show()
				end
			end
		end
	end)
end

hooksecurefunc('GameTooltip_SetDefaultAnchor', function(self, parent)
	if (showOnMouseover) then
		self:SetOwner(parent, 'ANCHOR_CURSOR')
	end
end)

local select = select
local tonumber = tonumber

local modf = math.modf
local gsub = string.gsub
local format = string.format

local bar = GameTooltipStatusBar
bar.Text = bar:CreateFontString(nil, 'OVERLAY')
bar.Text:SetPoint('CENTER', bar, healthbar.textPos, 0, 1)
bar.Text:SetFont('Fonts\\FRIZQT__.TTF', 14, 'THINOUTLINE')



local function ColorGradient(perc, ...)
	if (perc >= 1) then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif (perc <= 0) then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3

	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local function FormatValue(value)
	if (value >= 1e6) then
		return tonumber(format('%.1f', value/1e6))..'m'
	elseif (value >= 1e3) then
		return tonumber(format('%.1f', value/1e3))..'k'
	else
		return value
	end
end

local function DeficitValue(value)
	if (value == 0) then
		return ''
	else
		return '-'..FormatValue(value)
	end
end

local function GetHealthTag(text, cur, max)
	local perc = format('%d', (cur/max)*100)

	if (max == 1) then
		return perc
	end

	local r, g, b = ColorGradient(cur/max, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	text = gsub(text, '$cur', format('%s', FormatValue(cur)))
	text = gsub(text, '$max', format('%s', FormatValue(max)))
	text = gsub(text, '$deficit', format('%s', DeficitValue(max-cur)))
	text = gsub(text, '$perc', format('%d', perc)..'%%')
	text = gsub(text, '$smartperc', format('%d', perc))
	text = gsub(text, '$smartcolorperc', format('|cff%02x%02x%02x%d|r', r*255, g*255, b*255, perc))
	text = gsub(text, '$colorperc', format('|cff%02x%02x%02x%d', r*255, g*255, b*255, perc)..'%%|r')

	return text
end

GameTooltipStatusBar:HookScript('OnValueChanged', function(self, value)
	if (self.Text) then
		self.Text:SetText('')
	end

	if (not value) then
		return
	end

	local min, max = self:GetMinMaxValues()

	if ((value < min) or (value > max) or (value == 0) or (value == 1)) then
		return
	end

	if (not self.Text) then
		CreateHealthString(self)
	end

	local fullString = GetHealthTag(healthbar.healthFullFormat, value, max)
	local normalString = GetHealthTag(healthbar.healthFormat, value, max)

	local perc = (value/max)*100 
	if (perc >= 100 and currentValue ~= 1) then
		self.Text:SetText(fullString)
	elseif (perc < 100 and currentValue ~= 1) then
		self.Text:SetText(normalString)
	else
		self.Text:SetText('')
	end
end)

-- Add iLevel to Tooltip
-- decimal places of the equipped average item level. to assign '2' will show it like '123.45'
local DECIMAL_PLACES = 2

-- additional strings. if you don't like it just assign 'nil'. but do not delete these variables themselves.
local UPDATED = CANNOT_COOPERATE_LABEL -- '*'
local WAITING = CONTINUED -- '...'
local PENDING = CONTINUED .. CONTINUED -- '......'

-- output prefix. has to have unique strings to update the tooltip correctly
local PREFIX = STAT_FORMAT:format(STAT_AVERAGE_ITEM_LEVEL) .. '|Heqppditmlvl|h |h' .. HIGHLIGHT_FONT_COLOR_CODE


local f = CreateFrame('Frame')
f:SetScript('OnEvent', function(self, event, ...) return self[event](self, event, ...) end)
f:Hide()

local playerGUID, inCombat, updateTimer
local currentUnit, currentGUID
local isDelayed, isForced, isNotified, isReady

local function GetTipUnit()
	local _, unit = GameTooltip:GetUnit()
	if ( not unit ) then
		local mouseFocus = GetMouseFocus()
		unit = mouseFocus and (mouseFocus.unit or mouseFocus:GetAttribute('unit'))
	end

	return unit and UnitIsPlayer(unit) and unit
end

local SetTipText
do
	local function search (line, numLines)
		if ( line > numLines ) then return end

		local fontString = _G['GameTooltipTextLeft' .. line]
		local stringText = fontString and fontString:GetText()
		if ( stringText and stringText:match(PREFIX) ) then return fontString end

		return search(line + 1, numLines)
	end

	function SetTipText (text)
		if ( not text ) then return end

		local fontString = search(1, GameTooltip:NumLines()+1)
		if ( fontString ) then
			fontString:SetText(PREFIX .. text)
		else
			--GameTooltip:AddLine('')
			GameTooltip:AddLine(PREFIX .. text)
		end

		return GameTooltip:Show()
	end
end

local CanSafeInspect -- 6 times per 10 secs
do
	local limit, period = 6, 11
	local count, startTime = 0, 0

	hooksecurefunc('NotifyInspect', function ()
		local currentTime = GetTime()
		if ( currentTime - startTime > period ) then
			count, startTime = 1, currentTime
			return
		end

		count = count + 1
	end)

	function CanSafeInspect (unit)
		if ( not CanInspect(unit) or InspectFrame and InspectFrame:IsShown() or Examiner and Examiner:IsShown() ) then return end

		local pending = count > limit and period - (GetTime() - startTime)
		return true, pending and pending > 0 and pending
	end
end

local UnitItemLevel
do
	local formatString = '%.' .. DECIMAL_PLACES .. 'f'

	local function scan (unit, slot, total, count, twoHanded, incomplete)
		if ( slot > INVSLOT_LAST_EQUIPPED ) then return formatString:format(total / (twoHanded and count - 1 or count)), incomplete end

		if ( slot == INVSLOT_BODY or slot == INVSLOT_RANGED or slot == INVSLOT_TABARD ) then return scan(unit, slot + 1, total, count, twoHanded, incomplete) end

		local hasItem = GetInventoryItemTexture(unit, slot) and true
		local _, level, equipLoc

		local link = hasItem and GetInventoryItemLink(unit, slot)
		if ( link ) then
			repeat
				_, _, _, level, _, _, _, _, equipLoc = GetItemInfo(link)
			until level and equipLoc

			total = total + level
		end

		-- two-handed weapon and Titan's Grip
		if ( slot == INVSLOT_MAINHAND ) then
			twoHanded = equipLoc == 'INVTYPE_2HWEAPON' and 1 or not hasItem and 0
		elseif ( slot == INVSLOT_OFFHAND ) then
			twoHanded = twoHanded == 1 and not hasItem or twoHanded == 0 and equipLoc == 'INVTYPE_2HWEAPON'
		end

		local failed = hasItem and not link
		return scan(unit, slot + 1, total, failed and count or count + 1, twoHanded, incomplete or failed)
	end

	function UnitItemLevel (unit)
		if ( unit == 'player' or UnitIsUnit(unit, 'player') ) then
			local _, level = GetAverageItemLevel()
			return formatString:format(level)
		end

		return scan(unit, INVSLOT_FIRST_EQUIPPED, 0, 0)
	end
end

local UpdateItemLevel
do
	local cache = {}
	local cachedLevel

	local function update (unit, guid)
		local level, incomplete = UnitItemLevel(unit)

		if ( incomplete ) then
			updateTimer = TOOLTIP_UPDATE_TIME
			f:Show()
			level = cachedLevel or level
			return SetTipText(WAITING and level .. WAITING or level)
		end

		if ( isReady ) then
			cache[guid] = level
			return SetTipText(UPDATED and level .. UPDATED or level)
		end

		level = cachedLevel or level
		return SetTipText(WAITING and level .. WAITING or level)
	end

	function UpdateItemLevel ()
		cachedLevel = cache[currentGUID]

		if ( inCombat ) then return SetTipText(cachedLevel) end

		if ( isReady ) then return update(currentUnit, currentGUID) end

		if ( not isForced and cachedLevel ) then return SetTipText(cachedLevel) end

		if ( currentGUID == playerGUID ) then
			local level = UnitItemLevel('player')
			cache[playerGUID] = level
			return SetTipText(level)
		end

		local canInspect, pending = CanSafeInspect(currentUnit)
		if ( not canInspect ) then return SetTipText(cachedLevel) end

		if ( pending ) then
			updateTimer = pending
			f:Show()
--			return SetTipText(cachedLevel and (WAITING and cachedLevel .. WAITING or cachedLevel) or PENDING)
			return SetTipText(cachedLevel and cachedLevel .. PENDING or PENDING)
		end

		if ( not isDelayed ) then
			isDelayed = true
			updateTimer = TOOLTIP_UPDATE_TIME
			f:Show()
			return SetTipText(cachedLevel and (WAITING and cachedLevel .. WAITING or cachedLevel) or PENDING)
		end

		if ( not isNotified ) then
			isNotified = true
			NotifyInspect(currentUnit)
		end

		return update(currentUnit, currentGUID)
	end
end

local function OnTooltipSetUnit ()
	currentUnit, currentGUID, isDelayed, isForced, isNotified, isReady = GetTipUnit(), nil, nil, nil, nil, nil
	if ( not currentUnit ) then return end

	currentGUID, isForced = UnitGUID(currentUnit), UnitIsUnit(currentUnit, 'target')

	return UpdateItemLevel()
end
GameTooltip:HookScript('OnTooltipSetUnit', OnTooltipSetUnit)

f:SetScript('OnUpdate', function (self, elapsed)
	updateTimer = updateTimer - elapsed
	if ( updateTimer > 0 ) then return end
	self:Hide()

	if ( not currentGUID ) then return end

	local tipUnit = GetTipUnit()
	if ( not tipUnit or UnitGUID(tipUnit) ~= currentGUID ) then return end

	return UpdateItemLevel()
end)

function f:INSPECT_READY (_, guid)
	if ( not currentGUID or guid ~= currentGUID ) then return end

	local tipUnit = GetTipUnit()
	if ( not tipUnit or UnitGUID(tipUnit) ~= currentGUID ) then return end

	isReady = true
	-- we never know if the others are waiting for the further info about the same guid
	-- ClearInspectPlayer()
	-- we never know how many times 'INSPECT_READY' be fired
	-- f:UnregisterEvent('INSPECT_READY')

	return UpdateItemLevel()
end
f:RegisterEvent('INSPECT_READY')

function f:UNIT_INVENTORY_CHANGED (_, unit)
	if ( not currentGUID or UnitGUID(unit) ~= currentGUID ) then return end

	local tipUnit = GetTipUnit()
	if ( not tipUnit or UnitGUID(tipUnit) ~= currentGUID ) then return end

	isForced, isNotified, isReady = true, nil, nil

	return UpdateItemLevel()
end
f:RegisterEvent('UNIT_INVENTORY_CHANGED')

function f:PLAYER_TARGET_CHANGED ()
	return self:UNIT_INVENTORY_CHANGED (nil, 'target')
end
f:RegisterEvent('PLAYER_TARGET_CHANGED')

function f:PLAYER_REGEN_DISABLED ()
	inCombat = true
end
f:RegisterEvent('PLAYER_REGEN_DISABLED')

function f:PLAYER_REGEN_ENABLED ()
	inCombat = nil
end
f:RegisterEvent('PLAYER_REGEN_ENABLED')

function f:PLAYER_LOGIN ()
	self:UnregisterEvent('PLAYER_LOGIN')
	self.PLAYER_LOGIN = nil

	playerGUID = UnitGUID('player')
end

if ( IsLoggedIn() ) then
	f:PLAYER_LOGIN()
	inCombat = InCombatLockdown()
	return OnTooltipSetUnit()
end

return f:RegisterEvent('PLAYER_LOGIN')
