local cChat = CreateFrame("Frame")
cChat:RegisterEvent("ADDON_LOADED")
cChat:SetScript("OnEvent", function(self, event, arg1)
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
		ChatFrame1EditBox:SetFont([[Interface\AddOns\cChat\Media\Expressway_Free_NORMAL.ttf]], 15)
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

		local function ModChat(self)
			local chat = _G[self]
			local font, fontsize, fontflags = chat:GetFont()
			chat:SetFont([[Interface\AddOns\cChat\Media\Expressway_Free_NORMAL.ttf]], fontsize, dbOutline and 'THINOUTLINE' or fontflags)
			
			if (self ~= 'ChatFrame2') then
				chat.AddMessage = FCF_AddMessage
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


			-- add a sound notification on incoming whispers

		local f = CreateFrame('Frame')
		f:RegisterEvent('ADDON_LOADED')
		f:RegisterEvent('CHAT_MSG_WHISPER')
		f:RegisterEvent('CHAT_MSG_BN_WHISPER')
		f:SetScript('OnEvent', function(_, event)
			if (event == 'CHAT_MSG_WHISPER' or event == 'CHAT_MSG_BN_WHISPER') then
				PlaySoundFile([[Interface\AddOns\cChat\Media\Whisper.mp3]])
			end
		end)


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
		
	end
	
	SlashCmdList['RELOADUI'] = function()
		ReloadUI()
	end
	SLASH_RELOADUI1 = '/rl'	
		
end)