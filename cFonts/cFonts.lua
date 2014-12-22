local Addon = CreateFrame("Frame", UIParent)

Addon:RegisterEvent("ADDON_LOADED")
Addon:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "cFonts" then

		local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
			obj:SetFont(font, size, style)
			if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
			if sox and soy then obj:SetShadowOffset(sox, soy) end
			if r and g and b then obj:SetTextColor(r, g, b)
			elseif r then obj:SetAlpha(r) end
		end

		local NORMAL 		= [[Interface\AddOns\cFonts\Media\Expressway_Free_NORMAL.ttf]]
		local BOLD 			= [[Interface\AddOns\cFonts\Media\Expressway_Rg _BOLD.ttf]]
		local BOLDITALIC 	= [[Interface\AddOns\cFonts\Media\Expressway_Sb_ITALIC.ttf]]
		local ITALIC 		= [[Interface\AddOns\cFonts\Media\Expressway_Rg_BOLDITALIC.ttf]]


		UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
		CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17}

		UNIT_NAME_FONT     = NORMAL
		DAMAGE_TEXT_FONT   = NORMAL
		STANDARD_TEXT_FONT = NORMAL	

		-- Base fonts
		SetFont(AchievementFont_Small,                BOLD, 14)
		SetFont(FriendsFont_Large,                  NORMAL, 15, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(FriendsFont_Normal,                 NORMAL, 14, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(FriendsFont_Small,                  NORMAL, 13, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(FriendsFont_UserText,               NORMAL, 14, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(GameTooltipHeader,                    BOLD, 18, "OUTLINE")
		SetFont(GameFont_Gigantic,                    BOLD, 32, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(GameNormalNumberFont,                 BOLD, 12)
		SetFont(GameFontNormalSmall,                  BOLD, 14)
		SetFont(InvoiceFont_Med,                    ITALIC, 14, nil, 0.15, 0.09, 0.04)
		SetFont(InvoiceFont_Small,                  ITALIC, 13, nil, 0.15, 0.09, 0.04)
		SetFont(MailFont_Large,                     ITALIC, 15, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
		SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL, 14, "OUTLINE")
		SetFont(NumberFont_Outline_Huge,            NORMAL, 30, "THICKOUTLINE", 30)
		SetFont(NumberFont_Outline_Large,           NORMAL, 17, "OUTLINE")
		SetFont(NumberFont_Outline_Med,             NORMAL, 14, "OUTLINE")
		SetFont(NumberFont_Shadow_Med,              NORMAL, 14)
		SetFont(NumberFont_Shadow_Small,            NORMAL, 14)
		SetFont(QuestFont_Shadow_Small,             NORMAL, 16)
		SetFont(QuestFont_Large,                    NORMAL, 16)
		SetFont(QuestFont_Shadow_Huge,                BOLD, 19, nil, nil, nil, nil, 0.54, 0.4, 0.1)
		SetFont(QuestFont_Super_Huge,                 BOLD, 24)
		SetFont(ReputationDetailFont,                 BOLD, 14, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(SpellFont_Small,                      BOLD, 13)
		SetFont(SystemFont_InverseShadow_Small,       BOLD, 13)
		SetFont(SystemFont_Large,                   NORMAL, 17)
		SetFont(SystemFont_Med1,                    NORMAL, 15)
		SetFont(SystemFont_Med2,                    ITALIC, 14, nil, 0.15, 0.09, 0.04)
		SetFont(SystemFont_Med3,                    NORMAL, 15)
		SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 22, "THICKOUTLINE")
		SetFont(SystemFont_OutlineThick_Huge4,  	  BOLD, 27, "THICKOUTLINE")
		SetFont(SystemFont_OutlineThick_WTF,    	  BOLD, 31, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(SystemFont_Outline_Small,           NORMAL, 13, "OUTLINE")
		SetFont(SystemFont_Shadow_Huge1,              BOLD, 20)
		SetFont(SystemFont_Shadow_Huge3,              BOLD, 25)
		SetFont(SystemFont_Shadow_Large,            NORMAL, 17)
		SetFont(SystemFont_Shadow_Med1,             NORMAL, 14)
		SetFont(SystemFont_Shadow_Med2,             NORMAL, 14)
		SetFont(SystemFont_Shadow_Med3,             NORMAL, 15)
		SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 22, "OUTLINE")
		SetFont(SystemFont_Shadow_Small,              BOLD, 14)
		SetFont(SystemFont_Small,                   NORMAL, 14)
		SetFont(SystemFont_Tiny,                    NORMAL, 13)
		SetFont(Tooltip_Med,                        NORMAL, 15)
		SetFont(Tooltip_Small,                        BOLD, 14)
		SetFont(WhiteNormalNumberFont,                BOLD, 13)

		-- Derived fonts
		SetFont(BossEmoteNormalHuge,     	   BOLD, 27, "THICKOUTLINE")
		SetFont(CombatTextFont,              NORMAL, 26)
		SetFont(ErrorFont,                   ITALIC, 16, nil, 60)
		SetFont(QuestFontNormalSmall,          BOLD, 14, nil, nil, nil, nil, 0.54, 0.4, 0.1)
		SetFont(WorldMapTextFont,        	   BOLD, 31, "THICKOUTLINE",  40, nil, nil, 0, 0, 0, 1, -1)

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
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end)