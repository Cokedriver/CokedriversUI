
BuffFrame:SetScale(1.193)

local origSecondsToTimeAbbrev = _G.SecondsToTimeAbbrev
local function SecondsToTimeAbbrevHook(seconds)

	if (seconds >= 86400) then
		return '%dd', ceil(seconds / 86400)
	end

	if (seconds >= 3600) then
		return '%dh', ceil(seconds / 3600)
	end

	if (seconds >= 60) then
		return '%dm', ceil(seconds / 60)
	end

	return '%d', seconds
end
SecondsToTimeAbbrev = SecondsToTimeAbbrevHook


hooksecurefunc('AuraButton_Update', function(buttonName, index)
	local font = 'Fonts\\ARIALN.ttf'
	local button = _G[buttonName..index]
	local duration = _G[buttonName..index..'Duration']
	if (duration) then
		duration:ClearAllPoints()
		duration:SetPoint('BOTTOM', button, 'BOTTOM', 0, -2)
		if button.symbol then
			duration:SetFont(font, 12, 'THINOUTLINE')
		else
			duration:SetFont(font, 12, 'THINOUTLINE')
		end
		duration:SetShadowOffset(0, 0)
		duration:SetDrawLayer('OVERLAY')
	end

	local count = _G[buttonName..index..'Count']
	if (count) then
		count:ClearAllPoints()
		count:SetPoint('TOPRIGHT', button)
		if button.symbol then
			count:SetFont(font, 12, 'THINOUTLINE')
		else
			count:SetFont(font, 12, 'THINOUTLINE')
		end
		count:SetShadowOffset(0, 0)
		count:SetDrawLayer('OVERLAY')	
	end
end)

SlashCmdList['RELOADUI'] = function()
ReloadUI()
end
SLASH_RELOADUI1 = '/rl'
