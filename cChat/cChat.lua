
local TransparentChatBubbles = false
local BubbleBobble = true

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


local AddMessage = ChatFrame1.AddMessage
local function FCF_AddMessage(self, text, ...)
	if (type(text) == 'string') then
		text = gsub(text, '(|HBNplayer.-|h)%[(.-)%]|h', '%1%2|h')
		text = gsub(text, '(|Hplayer.-|h)%[(.-)%]|h', '%1%2|h')
		text = gsub(text, '%[(%d0?)%. (.-)%]', '[%1]') 			
	end

	return AddMessage(self, text, ...)
end

	-- Modify the editbox
	
--[[for k = 6, 11 do
   select(k, ChatFrame1EditBox:GetRegions()):SetTexture(1,1,1,0)
end]]

ChatFrame1EditBox:SetAltArrowKeyMode(false)
ChatFrame1EditBox:ClearAllPoints()
--ChatFrame1EditBox:SetFont('Fonts\\FRIZQT__.TTF', 15)
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

hooksecurefunc('ChatEdit_UpdateHeader', function(editBox)
	local type = editBox:GetAttribute('chatType')
	if (not type) then
		return
	end

	local info = ChatTypeInfo[type]
	ChatFrame1EditBox:SetBackdropBorderColor(info.r, info.g, info.b)
end)

--[[local HyperFrame = CreateFrame('Frame')

local linktypes = {
	-- These use GameTooltip:
	achievement    = true,
	enchant        = true,
	glyph          = true,
	item           = true,
	instancelock   = true,
	quest          = true,
	spell          = true,
	talent         = true,
	unit           = true,
	currency	   = true,
	-- This uses FloatingBattlePetTooltip:
	battlepet      = true,
	-- This uses FloatingPetBattleAbilityTooltip:
	battlePetAbil = true,
	-- This uses FloatingGarrisonFollowerTooltip:
	garrfollower  = true,
	-- This uses FloatingGarrisonFollowerAbilityTooltip:
	garrfollowerability = true,
	-- This uses FloatingGarrisonMissionTooltip:
	garrmission   = true,
}

local function OnHyperlinkEnter(HyperFrame, link, text)
	local linkType = strsplit(":", link)
	if linktypes[linkType] and not IsModifiedClick() then
		ChatFrame_OnHyperlinkShow(HyperFrame, link, texT)
	end
end	

local function OnHyperlinkLeave(HyperFrame, link, text)
	local linkType = strsplit(":", link)
	if linktypes[linkType] and not IsModifiedClick() then
		ChatFrame_OnHyperlinkShow(HyperFrame, link, text)
	end
end	]]	

local tooltipForLinkType = {
	-- Normal tooltip things:
	achievement  = ItemRefTooltip,
	enchant      = ItemRefTooltip,
	glyph        = ItemRefTooltip,
	item         = ItemRefTooltip,
	instancelock = ItemRefTooltip,
	quest        = ItemRefTooltip,
	spell        = ItemRefTooltip,
	talent       = ItemRefTooltip,
	unit         = ItemRefTooltip,
	currency     = ItemRefTooltip,
	-- Special tooltip things:
	battlepet           = FloatingBattlePetTooltip,
	battlePetAbil       = FloatingPetBattleAbilityTooltip,
	garrfollowerability = FloatingGarrisonFollowerAbilityTooltip,
	garrfollower        = FloatingGarrisonFollowerTooltip,
	garrmission         = FloatingGarrisonMissionTooltip,
}

local allowReposition, data = true, { }

local function RepositionTooltip(tooltip)
	local button = GetMouseFocus()
	if button:IsObjectType('HyperLinkButton') then
		data.tooltip, data.point, data.relFrame, data.relPoint, data.x, data.y = tooltip, tooltip:GetPoint()
		local uiX, uiY = UIParent:GetCenter()
		local x, y = button:GetCenter()
		tooltip:ClearAllPoints()
		if x <= uiX then
			if y <= uiY then
				tooltip:SetPoint('BOTTOMLEFT', button, 'TOPRIGHT', 2, -4)
			else
				tooltip:SetPoint('TOPLEFT', button, 'BOTTOMRIGHT', 2, 0)
			end
		elseif y <= uiY then
			tooltip:SetPoint('BOTTOMRIGHT', button, 'TOPLEFT', 0, -4)
		else
			tooltip:SetPoint('TOPRIGHT', button, 'BOTTOMLEFT', 0, 0)
		end
		if tooltip.CloseButton then
			tooltip.CloseButton:Hide()
		end
	end
end

local function RestoreTooltip(tooltip)
	if tooltip and tooltip == data.tooltip then
		data.tooltip = nil
		tooltip:ClearAllPoints()
		tooltip:SetPoint(data.point, data.relFrame, data.relPoint, data.x, data.y)
		if tooltip.CloseButton then
			tooltip.CloseButton:Show()
		end
		return tooltip
	end
end

local function OnHyperlinkEnter(frame, linkData, link)
	local tooltip = tooltipForLinkType[linkData:match("^(.-):")]
	if tooltip then
		tooltip:Hide()
		SetItemRef(linkData, link, 'LeftButton', frame)
		if allowReposition then
			RepositionTooltip(tooltip)
		end
	end
end

local function OnHyperlinkLeave(frame, linkData, link)
	local tooltip = RestoreTooltip(tooltipForLinkType[linkData:match("^(.-):")])
	if tooltip then
		tooltip:Hide()
	end
end

local function OnHyperlinkClick(frame, linkData, link, button)
	local tooltip = RestoreTooltip(tooltipForLinkType[linkData:match("^(.-):")])
	if tooltip then
		if tooltip:IsObjectType('GameTooltip') then
			allowReposition = nil
			OnHyperlinkEnter(frame, linkData, link)
			allowReposition = true
		else
			tooltip:Show()
		end
	else
		OnHyperlinkEnter(frame, linkData, link)
	end
end

local function RegisterMessageFrame(frame)
	frame:HookScript('OnHyperlinkClick', OnHyperlinkClick)
	frame:SetScript('OnHyperlinkEnter', OnHyperlinkEnter)
	frame:SetScript('OnHyperlinkLeave', OnHyperlinkLeave)
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', function(self, event, name)
	if event == 'PLAYER_LOGIN' then
		for index = 1, NUM_CHAT_WINDOWS do
			RegisterMessageFrame(_G['ChatFrame' .. index])
		end
	end
	if GuildBankMessageFrame then
		RegisterMessageFrame(GuildBankMessageFrame)
		self:UnregisterAllEvents()
		self:SetScript('OnEvent', nil)
	elseif event ~= 'ADDON_LOADED' then
		self:RegisterEvent('ADDON_LOADED')
	end
end)
frame:RegisterEvent('PLAYER_LOGIN')

if ItemRefTooltip and ItemRefCloseButton then
	ItemRefTooltip.CloseButton = ItemRefCloseButton
end		

local function ModChat(self)
	local chat = _G[self]
	local font, fontsize, fontflags = chat:GetFont()
	--chat:SetFont('Fonts\\FRIZQT__.TTF', fontsize, dbOutline and 'THINOUTLINE' or fontflags)
	chat:SetClampedToScreen(false)

	chat:SetClampRectInsets(0, 0, 0, 0)
	chat:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
	chat:SetMinResize(150, 25)

	if (self ~= 'ChatFrame2') then
		chat.AddMessage = FCF_AddMessage
	end

	--chat:HookScript('OnHyperlinkEnter', OnHyperlinkEnter)
	--chat:HookScript('OnHyperlinkLeave', OnHyperlinkLeave)
	
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
		buttonBottom:SetPoint('BOTTOMLEFT', chat, -1, -3)
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


	-- add a sound notification on incoming whispers

local SoundFrame = CreateFrame('Frame')
SoundFrame:RegisterEvent('ADDON_LOADED')
SoundFrame:RegisterEvent('CHAT_MSG_WHISPER')
SoundFrame:RegisterEvent('CHAT_MSG_BN_WHISPER')
SoundFrame:SetScript('OnEvent', function(_, event)
	if (event == 'CHAT_MSG_WHISPER' or event == 'CHAT_MSG_BN_WHISPER') then
		PlaySoundFile([[Interface\AddOns\cChat\Media\Whisper.mp3]])
	end
end)	



-- Chat Bubbles
local events = {
    CHAT_MSG_SAY = 'chatBubbles',
    CHAT_MSG_YELL = 'chatBubbles',
    CHAT_MSG_PARTY = 'chatBubblesParty',
    CHAT_MSG_PARTY_LEADER = 'chatBubblesParty',
    CHAT_MSG_MONSTER_SAY = 'chatBubbles',
    CHAT_MSG_MONSTER_YELL = 'chatBubbles',
    CHAT_MSG_MONSTER_PARTY = 'chatBubblesParty',
}

local function SkinFrame(frame, guid)
    for i = 1, select('#', frame:GetRegions()) do
        local region = select(i, frame:GetRegions())
        if (region:GetObjectType() == 'FontString') then
            frame.text = region
        else
            region:Hide()
        end
    end

    frame.text:SetFontObject('SystemFont_Small')
    frame.text:SetJustifyH('LEFT')

    frame:ClearAllPoints()
    frame:SetPoint('TOPLEFT', frame.text, -7, 25)
    frame:SetPoint('BOTTOMRIGHT', frame.text, 7, -7)
    frame:SetBackdrop({
        bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
		tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {left=3, right=3, top=3, bottom=3},
    })
    frame:SetBackdropColor(0, 0, 0, 1)

    frame.sender = frame:CreateFontString(nil, 'OVERLAY', 'NumberFont_Outline_Med')
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
		local color = RAID_CLASS_COLORS[class] or {r = 1, g = 1, b = 0.2}
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



SlashCmdList['RELOADUI'] = function()
	ReloadUI()
end
SLASH_RELOADUI1 = '/rl'	