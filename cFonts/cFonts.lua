
local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

local NORMAL 		= [[Interface\AddOns\cFonts\Media\Expressway_Free_NORMAL.ttf]]
local BOLD 			= [[Interface\AddOns\cFonts\Media\Expressway_Rg_BOLD.ttf]]
local ITALIC 		= [[Interface\AddOns\cFonts\Media\Expressway_Sb_ITALIC.ttf]]
local BOLDITALIC 	= [[Interface\AddOns\cFonts\Media\Expressway_Rg_BOLDITALIC.ttf]]



UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17}

local FONTZ = false -- Set to true only if you have not changed your master fonts.

if FONTZ == true then
	UNIT_NAME_FONT     = NORMAL
	DAMAGE_TEXT_FONT   = NORMAL
	STANDARD_TEXT_FONT = NORMAL	
end


-- Font Normally Used FRIZQT__.TTF
SetFont(SystemFont_Tiny,                	NORMAL, 11)
SetFont(SystemFont_Small,                	NORMAL, 13)
SetFont(SystemFont_Outline_Small,           NORMAL, 13, "OUTLINE")
SetFont(SystemFont_Outline,                	NORMAL, 15)
SetFont(SystemFont_Shadow_Small,            NORMAL, 13)
SetFont(SystemFont_InverseShadow_Small,		NORMAL, 13)
SetFont(SystemFont_Med1,                	NORMAL, 15)
SetFont(SystemFont_Shadow_Med1,             NORMAL, 15)
SetFont(SystemFont_Med2,                	NORMAL, 15, nil, 0.15, 0.09, 0.04)
SetFont(SystemFont_Shadow_Med2,             NORMAL, 15)
SetFont(SystemFont_Med3,                	NORMAL, 15)
SetFont(SystemFont_Shadow_Med3,             NORMAL, 15)
SetFont(SystemFont_Large,                	BOLD, 	17)
SetFont(SystemFont_Shadow_Large,            BOLD, 	17)
SetFont(SystemFont_Huge1,                	BOLD, 	20)
SetFont(SystemFont_Shadow_Huge1,            BOLD, 	20)
SetFont(SystemFont_OutlineThick_Huge2,      BOLD, 	22, "THICKOUTLINE")
SetFont(SystemFont_Shadow_Outline_Huge2,    BOLD, 	22, "OUTLINE")
SetFont(SystemFont_Shadow_Huge3,            BOLD, 	25)
SetFont(SystemFont_OutlineThick_Huge4,      BOLD, 	26, "THICKOUTLINE")
SetFont(SystemFont_OutlineThick_WTF,        BOLD, 	32, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
SetFont(GameTooltipHeader,                	BOLD, 	18)
SetFont(SpellFont_Small,                	NORMAL, 13)
SetFont(InvoiceFont_Med,                	NORMAL, 15, nil, 0.15, 0.09, 0.04)
SetFont(InvoiceFont_Small,                	NORMAL, 13, nil, 0.15, 0.09, 0.04)
SetFont(Tooltip_Med,                		NORMAL, 15)
SetFont(Tooltip_Small,                		NORMAL, 13)
SetFont(AchievementFont_Small,              NORMAL, 13)
SetFont(ReputationDetailFont,               NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
SetFont(GameFont_Gigantic,                	BOLD, 	32, nil, nil, nil, nil, 0, 0, 0, 1, -1)

-- Font Normally Used ARIALN.TTF
SetFont(NumberFont_Shadow_Small,			BOLD, 13)
SetFont(NumberFont_OutlineThick_Mono_Small,	BOLD, 13, "OUTLINE")
SetFont(NumberFont_Shadow_Med,              BOLD, 15)
SetFont(NumberFont_Outline_Med,             BOLD, 15, "OUTLINE")
SetFont(NumberFont_Outline_Large,           BOLD, 17, "OUTLINE")
SetFont(NumberFont_GameNormal,				BOLD, 13)
SetFont(FriendsFont_UserText,               BOLD, 15)

-- Font Normally Used skurri.ttf
SetFont(NumberFont_Outline_Huge,            BOLD, 30, "THICKOUTLINE")

-- Font Normally Used MORPHEUS.ttf
SetFont(QuestFont_Large,                	ITALIC, 17)
SetFont(QuestFont_Shadow_Huge,              ITALIC, 18, nil, nil, nil, nil, 0.54, 0.4, 0.1)
SetFont(QuestFont_Shadow_Small,             ITALIC, 13)
SetFont(MailFont_Large,                		ITALIC, 17, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)

-- Font Normally Used FRIENDS.TTF
SetFont(FriendsFont_Normal,                	NORMAL, 15, nil, nil, nil, nil, 0, 0, 0, 1, -1)
SetFont(FriendsFont_Small,                	NORMAL, 13, nil, nil, nil, nil, 0, 0, 0, 1, -1)
SetFont(FriendsFont_Large,                	BOLD, 	17, nil, nil, nil, nil, 0, 0, 0, 1, -1)


SetFont(GameFontNormalSmall,                BOLD, 	13)
SetFont(GameFontNormal,                		NORMAL, 15)
SetFont(GameFontNormalLarge,                BOLD, 	17)
SetFont(GameFontNormalHuge,                	BOLD, 	20)
SetFont(GameFontHighlightSmallLeft,			NORMAL, 15)
--SetFont(GameNormalNumberFont,               BOLD, 13)



for i=1,7 do
	local f = _G["ChatFrame"..i]
	local font, size = f:GetFont()
	f:SetFont(NORMAL, size)
end

-- I have no idea why the channel list is getting fucked up
-- but re-setting the font obj seems to fix it
for i=1,MAX_CHANNEL_BUTTONS do
	local f = _G["ChannelButton"..i.."Text"]
	f:SetFontObject(GameFontNormalSmallLeft)
	-- function f:SetFont(...) error("Attempt to set font on ChannelButton"..i) end
end

for _,butt in pairs(PaperDollTitlesPane.buttons) do butt.text:SetFontObject(GameFontHighlightSmallLeft) end
	

SlashCmdList['RELOADUI'] = function()
	ReloadUI()
end
	SLASH_RELOADUI1 = '/rl'