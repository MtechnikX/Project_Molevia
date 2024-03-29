local addonName = "Altoholic"
local addon = _G[addonName]

local function _EnableIcon(frame)
	-- frame:Enable()
	frame.Icon:SetDesaturated(false)
end

local function _DisableIcon(frame)
	-- frame:Disable()
	frame.Icon:SetDesaturated(true)
end

local function _SetSpell(frame, spellID, availableAt)
	if not spellID then return end

	local name, info, icon = GetSpellInfo(spellID)
	if not name or not info or not icon then return end	-- exit on invalid data
	
	frame.spellID = spellID
	frame.SpellName:SetText(name)
			
	if availableAt == 0 then	-- 0 = already known
		frame.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		frame.SubSpellName:SetText(info)
		frame.SubSpellName:SetTextColor(0.50, 0.25, 0)
		frame.Icon:SetDesaturated(false)
		frame.Icon:SetVertexColor(1.0, 1.0, 1.0)
	else
		frame.SpellName:SetTextColor(0.4, 0.4, 0.4)
		frame.SubSpellName:SetFormattedText(SPELLBOOK_AVAILABLE_AT, availableAt)
		frame.SubSpellName:SetTextColor(0.4, 0.4, 0.4)
		frame.Icon:SetDesaturated(true)
		frame.Icon:SetVertexColor(0.4, 0.4, 0.4)
	end
	
	frame.Icon:SetWidth(30)
	frame.Icon:SetHeight(30)
	frame.Icon:SetAllPoints(frame)
	frame.Icon:SetTexture(icon)
	
	frame.Icon:Show()
	frame.SpellName:Show()
	frame.SubSpellName:Show()
end

addon:RegisterClassExtensions("AltoSpellButton", {
	EnableIcon = _EnableIcon,
	DisableIcon = _DisableIcon,
	SetSpell = _SetSpell,
})
