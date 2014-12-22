local Addon = CreateFrame("Frame", UIParent)

Addon:RegisterEvent("ADDON_LOADED")
Addon:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "cChat" then

		local type = type
		local select = select
		local unpack = unpack
		local tostring = tostring
		local concat = table.concat
		local find = string.find
		local gsub = string.gsub
		local format = string.format
		local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
		local disableFade = false
		local chatOutline = false
		local windowBorder = false
		local enableBorder = false
		local enableBottomButton =  false
		local enableHyperlinkTooltip = true
		local enableBorderColoring = true
		local chatTab = {
			fontSize = 15,
			fontOutline = true, 
			normalColor = {r = 1, g = 1, b = 1},
			specialColor = {r = 1, g = 0, b = 1},
			selectedColor = {r = 0, g = 0.75, b = 1},
		}		

		CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

		CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.5
		CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0


		CHAT_FONT_HEIGHTS = {
			[1] = 8,
			[2] = 9,
			[3] = 10,
			[4] = 11,
			[5] = 12,
			[6] = 13,
			[7] = 14,
			[8] = 15,
			[9] = 16,
			[10] = 17,
			[11] = 18,
			[12] = 19,
			[13] = 20,
		}


		CHAT_FLAG_AFK = '[AFK] '
		CHAT_FLAG_DND = '[DND] '
		CHAT_FLAG_GM = '[GM] '

		CHAT_GUILD_GET = '(|Hchannel:Guild|hG|h) %s:\32'
		CHAT_OFFICER_GET = '(|Hchannel:o|hO|h) %s:\32'

		CHAT_PARTY_GET = '(|Hchannel:party|hP|h) %s:\32'
		CHAT_PARTY_LEADER_GET = '(|Hchannel:party|hPL|h) %s:\32'
		CHAT_PARTY_GUIDE_GET = '(|Hchannel:party|hDG|h) %s:\32'
		CHAT_MONSTER_PARTY_GET = '(|Hchannel:raid|hR|h) %s:\32'

		CHAT_RAID_GET = '(|Hchannel:raid|hR|h) %s:\32'
		CHAT_RAID_WARNING_GET = '(RW!) %s:\32'
		CHAT_RAID_LEADER_GET = '(|Hchannel:raid|hL|h) %s:\32'

		CHAT_BATTLEGROUND_GET = '(|Hchannel:Battleground|hBG|h) %s:\32'
		CHAT_BATTLEGROUND_LEADER_GET = '(|Hchannel:Battleground|hBL|h) %s:\32'

		CHAT_INSTANCE_CHAT_GET = '|Hchannel:INSTANCE_CHAT|h[I]|h %s:\32';
		CHAT_INSTANCE_CHAT_LEADER_GET = '|Hchannel:INSTANCE_CHAT|h[IL]|h %s:\32';


		local channelFormat 
		do
			local a, b = '.*%[(.*)%].*', '%%[%1%%]'
			channelFormat = {
				[1] = {gsub(CHAT_BATTLEGROUND_GET, a, b), '[BG]'},
				[2] = {gsub(CHAT_BATTLEGROUND_LEADER_GET, a, b), '[BGL]'},

				[3] = {gsub(CHAT_GUILD_GET, a, b), '[G]'},
				[4] = {gsub(CHAT_OFFICER_GET, a, b), '[O]'},
				
				[5] = {gsub(CHAT_PARTY_GET, a, b), '[P]'},
				[6] = {gsub(CHAT_PARTY_LEADER_GET, a, b), '[PL]'},
				[7] = {gsub(CHAT_PARTY_GUIDE_GET, a, b), '[PL]'},

				[8] = {gsub(CHAT_RAID_GET, a, b), '[R]'},
				[9] = {gsub(CHAT_RAID_LEADER_GET, a, b), '[RL]'},
				[10] = {gsub(CHAT_RAID_WARNING_GET, a, b), '[RW]'},

				[11] = {gsub(CHAT_FLAG_AFK, a, b), '[AFK] '},
				[12] = {gsub(CHAT_FLAG_DND, a, b), '[DND] '},
				[13] = {gsub(CHAT_FLAG_GM, a, b), '[GM] '},
			}
		end


		local AddMessage = ChatFrame1.AddMessage
		local function FCF_AddMessage(self, text, ...)
			if (type(text) == 'string') then
				text = gsub(text, '(|HBNplayer.-|h)%[(.-)%]|h', '%1%2|h')
				text = gsub(text, '(|Hplayer.-|h)%[(.-)%]|h', '%1%2|h')
				text = gsub(text, '%[(%d0?)%. (.-)%]', '[%1]') 
				
				
				for i = 1, #channelFormat  do
					text = gsub(text, channelFormat[i][1], channelFormat[i][2])
				end
				
			end

			return AddMessage(self, text, ...)
		end

			-- Modify the editbox
			
		for k = 6, 11 do
		   select(k, ChatFrame1EditBox:GetRegions()):SetTexture(nil)
		end

		ChatFrame1EditBox:SetAltArrowKeyMode(false)
		ChatFrame1EditBox:ClearAllPoints()
		ChatFrame1EditBox:SetFont([[Interface\AddOns\CokeUI\Media\Expressway_Free_NORMAL.ttf]], 15)
		ChatFrame1EditBox:SetPoint('BOTTOMLEFT', ChatFrame1, 'TOPLEFT', 2, 33)
		ChatFrame1EditBox:SetPoint('BOTTOMRIGHT', ChatFrame1, 'TOPRIGHT', 0, 33)
		ChatFrame1EditBox:SetBackdrop({
			bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true, tileSize = 16, edgeSize = 18,
			insets = {left = 3, right = 3, top = 2, bottom = 3},
		})


		ChatFrame1EditBox:SetBackdropColor(0, 0, 0, 0.5)


			-- Hide the menu and friend button

		FriendsMicroButton:SetAlpha(0)
		FriendsMicroButton:EnableMouse(false)
		FriendsMicroButton:UnregisterAllEvents()

		ChatFrameMenuButton:SetAlpha(0)
		ChatFrameMenuButton:EnableMouse(false)

			-- Tab text colors for the tabs

		hooksecurefunc('FCFTab_UpdateColors', function(self, selected)
			if (selected) then
				self:GetFontString():SetTextColor(0, 0.75, 1)
			else
				self:GetFontString():SetTextColor(1, 1, 1)
			end
		end)

			-- Tab text fadeout

		local origFCF_FadeOutChatFrame = FCF_FadeOutChatFrame
		local function FCF_FadeOutChatFrameHook(chatFrame)
			origFCF_FadeOutChatFrame(chatFrame)

			local frameName = chatFrame:GetName()
			local chatTab = _G[frameName..'Tab']
			local tabGlow = _G[frameName..'TabGlow']

			if (not tabGlow:IsShown()) then
				if (frameName.isDocked) then
					securecall('UIFrameFadeOut', chatTab, CHAT_FRAME_FADE_OUT_TIME, chatTab:GetAlpha(), CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA)
				else
					securecall('UIFrameFadeOut', chatTab, CHAT_FRAME_FADE_OUT_TIME, chatTab:GetAlpha(), CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA)
				end
			end
		end
		FCF_FadeOutChatFrame = FCF_FadeOutChatFrameHook

			-- Improve mousewheel scrolling

		hooksecurefunc('FloatingChatFrame_OnMouseScroll', function(self, direction)
			if (direction > 0) then
				if (IsShiftKeyDown()) then
					self:ScrollToTop()
				else
					self:ScrollUp()
					self:ScrollUp()
				end
			elseif (direction < 0)  then
				if (IsShiftKeyDown()) then
					self:ScrollToBottom()
				else
					self:ScrollDown()
					self:ScrollDown()
				end
			end

			if (enableBottomButton) then
				local buttonBottom = _G[self:GetName() .. 'ButtonFrameBottomButton']
				if (self:AtBottom()) then
					buttonBottom:Hide()
				else
					buttonBottom:Show()
					buttonBottom:SetAlpha(0.7)
				end
			end
		end)

			-- Reposit toast frame

		BNToastFrame:HookScript('OnShow', function(self)
			BNToastFrame:ClearAllPoints()
			BNToastFrame:SetPoint('BOTTOMLEFT', ChatFrame1EditBox, 'TOPLEFT', 0, 15)
		end)

			-- Modify the chat tabs

		function SkinTab(self)
			local chat = _G[self]

			local tab = _G[self..'Tab']
			for i = 1, select('#', tab:GetRegions()) do
				local texture = select(i, tab:GetRegions())
				if (texture and texture:GetObjectType() == 'Texture') then
					texture:SetTexture(nil)
				end
			end

			local tabText = _G[self..'TabText']
			tabText:SetJustifyH('CENTER')
			tabText:SetWidth(60)
			if (chatTab.fontOutline) then
				tabText:SetFont([[Interface\AddOns\CokeUI\Media\Expressway_Rg _BOLD.ttf]], 16, 'THINOUTLINE')
				tabText:SetShadowOffset(0, 0)
			else
				tabText:SetFont([[Interface\AddOns\CokeUI\Media\Expressway_Rg _BOLD.ttf]], 16)
				tabText:SetShadowOffset(1, -1)
			end		

			local a1, a2, a3, a4, a5 = tabText:GetPoint()
			tabText:SetPoint(a1, a2, a3, a4, 1)

			local s1, s2, s3 = chatTab.specialColor.r, chatTab.specialColor.g, chatTab.specialColor.b 
			local e1, e2, e3 = chatTab.selectedColor.r, chatTab.selectedColor.g, chatTab.selectedColor.b
			local n1, n2, n3 = chatTab.normalColor.r, chatTab.normalColor.g, chatTab.normalColor.b

			local tabGlow = _G[self..'TabGlow']
			hooksecurefunc(tabGlow, 'Show', function()
				tabText:SetTextColor(s1, s2, s3, CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA)
			end)

			hooksecurefunc(tabGlow, 'Hide', function()
				tabText:SetTextColor(n1, n2, n3)
			end)

			tab:SetScript('OnEnter', function()
				tabText:SetTextColor(s1, s2, s3, tabText:GetAlpha())
			end)

			tab:SetScript('OnLeave', function()
				local hasNofication = tabGlow:IsShown()

				local r, g, b
				if (_G[self] == SELECTED_CHAT_FRAME and chat.isDocked) then
					r, g, b = e1, e2, e3
				elseif (hasNofication) then
					r, g, b = s1, s2, s3
				else
					r, g, b = n1, n2, n3
				end

				tabText:SetTextColor(r, g, b)
			end)

			hooksecurefunc(tab, 'Show', function()
				if (not tab.wasShown) then
					local hasNofication = tabGlow:IsShown()
					
					if (chat:IsMouseOver()) then
						tab:SetAlpha(CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA)
					else
						tab:SetAlpha(CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA)
					end

					local r, g, b
					if (_G[self] == SELECTED_CHAT_FRAME and chat.isDocked) then
						r, g, b = e1, e2, e3
					elseif (hasNofication) then
						r, g, b = s1, s2, s3
					else
						r, g, b = n1, n2, n3
					end

					tabText:SetTextColor(r, g, b)

					tab.wasShown = true
				end
			end)
		end

		local function ModChat(self)
			local chat = _G[self]

			if (not dbOutline) then
				chat:SetShadowOffset(1, -1)
			end

			if (disableFade) then
				chat:SetFading(false)
			end

			SkinTab(self)

			local font, fontsize, fontflags = chat:GetFont()
			chat:SetFont([[Interface\AddOns\CokeUI\Media\Expressway_Free_NORMAL.ttf]], fontsize, dbOutline and 'THINOUTLINE' or fontflags)
			chat:SetClampedToScreen(false)

			chat:SetClampRectInsets(0, 0, 0, 0)
			chat:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
			chat:SetMinResize(150, 25)
			
			if (self ~= 'ChatFrame2') then
				chat.AddMessage = FCF_AddMessage
			end

			local buttonUp = _G[self..'ButtonFrameUpButton']
			buttonUp:SetAlpha(0)
			buttonUp:EnableMouse(false)

			local buttonDown = _G[self..'ButtonFrameDownButton']
			buttonDown:SetAlpha(0)
			buttonDown:EnableMouse(false)

			local buttonBottom = _G[self..'ButtonFrameBottomButton']
			if (enableBottomButton) then
				buttonBottom:Hide()
				buttonBottom:ClearAllPoints()
				buttonBottom:SetPoint("BOTTOMRIGHT", chat, "BOTTOMRIGHT", 0, -4)
				buttonBottom:HookScript('OnClick', function(self)
					self:Hide()
				end)
			else
				buttonBottom:SetAlpha(0)
				buttonBottom:EnableMouse(false)
			end


			for _, texture in pairs({
				'ButtonFrameBackground',
				'ButtonFrameTopLeftTexture',
				'ButtonFrameBottomLeftTexture',
				'ButtonFrameTopRightTexture',
				'ButtonFrameBottomRightTexture',
				'ButtonFrameLeftTexture',
				'ButtonFrameRightTexture',
				'ButtonFrameBottomTexture',
				'ButtonFrameTopTexture',
			}) do
				_G[self..texture]:SetTexture(nil)
			end
		end

		local function SetChatStyle()
			for _, v in pairs(CHAT_FRAMES) do
				local chat = _G[v]
				if (chat and not chat.hasModification) then
					ModChat(chat:GetName())

					local convButton = _G[chat:GetName()..'ConversationButton']
					if (convButton) then
						convButton:SetAlpha(0)
						convButton:EnableMouse(false)
					end

					local chatMinimize = _G[chat:GetName()..'ButtonFrameMinimizeButton']
					if (chatMinimize) then
						chatMinimize:SetAlpha(0)
						chatMinimize:EnableMouse(0)
					end

					chat.hasModification = true
				end
			end
		end
		hooksecurefunc('FCF_OpenTemporaryWindow', SetChatStyle)
		SetChatStyle()

			-- Chat menu, just a middle click on the chatframe 1 tab

		hooksecurefunc('ChatFrameMenu_UpdateAnchorPoint', function()
			if (FCF_GetButtonSide(DEFAULT_CHAT_FRAME) == 'right') then
				ChatMenu:ClearAllPoints()
				ChatMenu:SetPoint('BOTTOMRIGHT', ChatFrame1Tab, 'TOPLEFT')
			else
				ChatMenu:ClearAllPoints()
				ChatMenu:SetPoint('BOTTOMLEFT', ChatFrame1Tab, 'TOPRIGHT')
			end
		end)

		ChatFrame1Tab:RegisterForClicks('AnyUp')
		ChatFrame1Tab:HookScript('OnClick', function(self, button)
			if (button == 'MiddleButton' or button == 'Button4' or button == 'Button5') then
				if (ChatMenu:IsShown()) then
					ChatMenu:Hide()
				else
					ChatMenu:Show()
				end
			else
				ChatMenu:Hide()
			end
		end)

			-- Modify the gm chatframe and add a sound notification on incoming whispers

		local f = CreateFrame('Frame')
		f:RegisterEvent('ADDON_LOADED')
		f:RegisterEvent('CHAT_MSG_WHISPER')
		f:RegisterEvent('CHAT_MSG_BN_WHISPER')
		f:SetScript('OnEvent', function(_, event)
			if (event == 'ADDON_LOADED' and arg1 == 'Blizzard_GMChatUI') then
				GMChatFrame:EnableMouseWheel(true)
				GMChatFrame:SetScript('OnMouseWheel', ChatFrame1:GetScript('OnMouseWheel'))
				GMChatFrame:SetHeight(200)

				GMChatFrameUpButton:SetAlpha(0)
				GMChatFrameUpButton:EnableMouse(false)

				GMChatFrameDownButton:SetAlpha(0)
				GMChatFrameDownButton:EnableMouse(false)

				GMChatFrameBottomButton:SetAlpha(0)
				GMChatFrameBottomButton:EnableMouse(false)
			end

			if (event == 'CHAT_MSG_WHISPER' or event == 'CHAT_MSG_BN_WHISPER') then
				PlaySoundFile([[Interface\AddOns\cChat\Media\Whisper.mp3]])
			end
		end)

		local combatLog = {
			text = 'CombatLog',
			colorCode = '|cffFFD100',
			isNotRadio = true,

			func = function() 
				if (not LoggingCombat()) then
					LoggingCombat(true) 
					DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGENABLED, 1, 1, 0)
				else
					LoggingCombat(false)
					DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGDISABLED, 1, 1, 0)
				end
			end,

			checked = function()
				if (LoggingCombat()) then
					return true
				else
					return false
				end
			end
		}

		local chatLog = {
			text = 'ChatLog',
			colorCode = '|cffFFD100',
			isNotRadio = true,

			func = function() 
				if (not LoggingChat()) then
					LoggingChat(true) 
					DEFAULT_CHAT_FRAME:AddMessage(CHATLOGENABLED, 1, 1, 0)
				else
					LoggingChat(false)
					DEFAULT_CHAT_FRAME:AddMessage(CHATLOGDISABLED, 1, 1, 0)
				end
			end,

			checked = function()
				if (LoggingChat()) then
					return true
				else
					return false
				end
			end
		}

		local origFCF_Tab_OnClick = FCF_Tab_OnClick
		local function FCF_Tab_OnClickHook(chatTab, ...)
			origFCF_Tab_OnClick(chatTab, ...)

			combatLog.arg1 = chatTab
			UIDropDownMenu_AddButton(combatLog)

			chatLog.arg1 = chatTab
			UIDropDownMenu_AddButton(chatLog)
		end
		FCF_Tab_OnClick = FCF_Tab_OnClickHook

		 -- Copy URL
		 
		local urlStyle = '|cffff00ff|Hurl:%1|h%1|h|r'
		local urlPatterns = {
			'(http://%S+)',                 -- http://xxx.com
			'(www%.%S+)',                   -- www.xxx.com/site/index.php
			'(%d+%.%d+%.%d+%.%d+:?%d*)',    -- 192.168.1.1 / 192.168.1.1:1110
		}

		local messageTypes = {
			'CHAT_MSG_CHANNEL',
			'CHAT_MSG_GUILD',
			'CHAT_MSG_PARTY',
			'CHAT_MSG_RAID',
			'CHAT_MSG_SAY',
			'CHAT_MSG_WHISPER',
		}

		local function urlFilter(self, event, text, ...)
			for _, pattern in ipairs(urlPatterns) do
				local result, matches = gsub(text, pattern, urlStyle)

				if (matches > 0) then
					return false, result, ...
				end
			end
		end

		for _, event in ipairs(messageTypes) do
			ChatFrame_AddMessageEventFilter(event, urlFilter)
		end

		local origSetItemRef = SetItemRef
		local currentLink
		local SetItemRefHook = function(link, text, button)
			if (link:sub(0, 3) == 'url') then
				currentLink = link:sub(5)
				StaticPopup_Show('UrlCopyDialog')
				return
			end

			return origSetItemRef(link, text, button)
		end

		SetItemRef = SetItemRefHook

		StaticPopupDialogs['UrlCopyDialog'] = {
			text = 'URL',
			button2 = CLOSE,
			hasEditBox = 1,
			editBoxWidth = 250,

			OnShow = function(frame)
				local editBox = _G[frame:GetName()..'EditBox']
				if (editBox) then
					editBox:SetText(currentLink)
					editBox:SetFocus()
					editBox:HighlightText(0)
				end

				local button = _G[frame:GetName()..'Button2']
				if (button) then
					button:ClearAllPoints()
					button:SetWidth(100)
					button:SetPoint('CENTER', editBox, 'CENTER', 0, -30)
				end
			end,

			EditBoxOnEscapePressed = function(frame) 
				frame:GetParent():Hide() 
			end,

			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
			maxLetters = 1024,
		}

		if (enableBorderColoring) then
			hooksecurefunc('ChatEdit_UpdateHeader', function(editBox)
				local type = editBox:GetAttribute('chatType')
				if (not type) then
					return
				end

				local info = ChatTypeInfo[type]
				ChatFrame1EditBox:SetBackdropBorderColor(info.r, info.g, info.b)
			end)
		else return
		end

		if (enableHyperlinkTooltip) then

			--[[

				All Create for hyperlink.lua goes to Neal, ballagarba, and Tuks.
				Neav UI = http://www.wowinterface.com/downloads/info13981-NeavUI.html.
				Tukui = http://www.tukui.org/download.php.
				Edited by Cokedriver.
				
			]]

			local _G = getfenv(0)
			local orig1, orig2 = {}, {}
			local GameTooltip = GameTooltip

			local linktypes = {
				item = true, 
				enchant = true, 
				spell = true, 
				quest = true, 
				unit = true, 
				talent = true, 
				achievement = true, 
				glyph = true
			}

			local function OnHyperlinkEnter(frame, link, ...)
				local linktype = link:match('^([^:]+)')
				if (linktype and linktypes[linktype]) then
					GameTooltip:SetOwner(ChatFrame1, 'ANCHOR_CURSOR', 0, 20)
					GameTooltip:SetHyperlink(link)
					GameTooltip:Show()
				else
					GameTooltip:Hide()
				end

				if (orig1[frame]) then 
					return orig1[frame](frame, link, ...) 
				end
			end

			local function OnHyperlinkLeave(frame, ...)
				GameTooltip:Hide()

				if (orig2[frame]) then 
					return orig2[frame](frame, ...) 
				end
			end

			local function EnableItemLinkTooltip()
				for _, v in pairs(CHAT_FRAMES) do
					local chat = _G[v]
					if (chat and not chat.URLCopy) then
						orig1[chat] = chat:GetScript('OnHyperlinkEnter')
						chat:SetScript('OnHyperlinkEnter', OnHyperlinkEnter)

						orig2[chat] = chat:GetScript('OnHyperlinkLeave')
						chat:SetScript('OnHyperlinkLeave', OnHyperlinkLeave)
						chat.URLCopy = true
					end
				end
			end
			hooksecurefunc('FCF_OpenTemporaryWindow', EnableItemLinkTooltip)
			EnableItemLinkTooltip()
		else
			return
		end



		for i = 1, NUM_CHAT_WINDOWS do
			local cf = _G['ChatFrame'..i]
			local bg = CreateFrame("Frame", nil, cf);
			bg:SetFrameStrata("BACKGROUND");
			
			if i == 2 then
				bg:SetPoint("TOPLEFT", -8, 32);
			else
				bg:SetPoint("TOPLEFT", -8, 8);
			end	
			bg:SetPoint("BOTTOMRIGHT", 8, -12);
			bg:SetBackdrop({
				edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
				tile = true, tileSize = 16, edgeSize = 18,
			})
			bg:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b)
			if (windowborder) then
				bg:Show()
			else
				bg:Hide()
			end		
		end
		
		SlashCmdList['RELOADUI'] = function()
			ReloadUI()
		end
		SLASH_RELOADUI1 = '/rl'	
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end)