local Addon = CreateFrame("Frame", UIParent)

Addon:RegisterEvent("ADDON_LOADED")
Addon:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "cBuffs" then
		BuffFrame:SetScale(1.193)
	end
end)