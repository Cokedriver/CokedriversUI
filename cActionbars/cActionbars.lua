
local showHotKeys = false
local showMacronames = false	
local hotkeyAlpha = showHotKeys and 1 or 0
local macroAlpha = showMacronames and 1 or 0

for i = 1, 12 do
	_G["ActionButton"..i.."HotKey"]:SetAlpha(hotkeyAlpha) -- main bar
	_G["MultiBarBottomRightButton"..i.."HotKey"]:SetAlpha(hotkeyAlpha) -- bottom right bar
	_G["MultiBarBottomLeftButton"..i.."HotKey"]:SetAlpha(hotkeyAlpha) -- bottom left bar
	_G["MultiBarRightButton"..i.."HotKey"]:SetAlpha(hotkeyAlpha) -- right bar
	_G["MultiBarLeftButton"..i.."HotKey"]:SetAlpha(hotkeyAlpha) -- left bar
end

for i = 1, 12 do
	_G["ActionButton"..i.."Name"]:SetAlpha(macroAlpha) -- main bar
	_G["MultiBarBottomRightButton"..i.."Name"]:SetAlpha(macroAlpha) -- bottom right bar
	_G["MultiBarBottomLeftButton"..i.."Name"]:SetAlpha(macroAlpha) -- bottom left bar
	_G["MultiBarRightButton"..i.."Name"]:SetAlpha(macroAlpha) -- right bar
	_G["MultiBarLeftButton"..i.."Name"]:SetAlpha(macroAlpha) -- left bar
end

local function UpdateRange( self, elapsed )
	local rangeTimer = self.rangeTimer
	local icon = self.icon;

	if( rangeTimer == TOOLTIP_UPDATE_TIME ) then
		local inRange = IsActionInRange( self.action );
		if( inRange == false ) then
			-- Red Out Button
			icon:SetVertexColor( 1, 0, 0 );
		else
			local canUse, amountMana = IsUsableAction( self.action );
			if( canUse ) then
				icon:SetVertexColor( 1.0, 1.0, 1.0 );
			elseif( amountMana ) then
				icon:SetVertexColor( 0.5, 0.5, 1.0 );
			else
				icon:SetVertexColor( 0.4, 0.4, 0.4 );
			end
		end
	end
end

do
	hooksecurefunc( "ActionButton_OnUpdate", UpdateRange );
end
	
SlashCmdList['RELOADUI'] = function()
	ReloadUI()
end
SLASH_RELOADUI1 = '/rl'
