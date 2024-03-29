-- **************************************************************************
-- * TitanXP.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Development Team
-- **************************************************************************

-- ******************************** Constants *******************************
local TITAN_XP_ID = "XP";
local _G = getfenv(0);
local TITAN_XP_FREQUENCY = 1;
local updateTable = {TITAN_XP_ID, TITAN_PANEL_UPDATE_ALL};
-- ******************************** Variables *******************************
local TitanPanelXPButton_ButtonAdded = nil;
local found = nil;
local lastMobXP, lastXP, XPGain = 0, 0, 0
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
-- ******************************** Functions *******************************

--[[
Add commas or period in the value given as needed
--]]
local function comma_value(amount)
	local formatted = amount
	local k
	local sep = (TitanGetVar(TITAN_XP_ID, "UseSeperatorComma") and "UseComma" or "UsePeriod")
	while true do
		if sep == "UseComma" then formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2') end
		if sep == "UsePeriod" then formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2') end
		if (k==0) then
			break
		end
	end
	return formatted
end

-- **************************************************************************
-- NAME : TitanPanelXP_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelXPButton_OnLoad(self)
	self.registry = { 
		id = TITAN_XP_ID,
		category = "Built-ins",
		version = TITAN_VERSION,
		menuText = L["TITAN_XP_MENU_TEXT"],
		buttonTextFunction = "TitanPanelXPButton_GetButtonText",
		tooltipTitle = L["TITAN_XP_TOOLTIP"],
		tooltipTextFunction = "TitanPanelXPButton_GetTooltipText",
		iconWidth = 16,
		controlVariables = {
			ShowIcon = true,
			ShowLabelText = true,
			ShowRegularText = false,
			ShowColoredText = false,
			DisplayOnRightSide = false
		},
		savedVariables = {
			DisplayType = "ShowXPPerHourSession",
			ShowIcon = 1,
			ShowLabelText = 1,
			ShowSimpleRested = false,
			ShowSimpleToLevel = false,
			ShowSimpleNumOfKills = false,
			ShowSimpleNumOfGains = false,
			UseSeperatorComma = true, 
			UseSeperatorPeriod = false, 
		}
	};

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("TIME_PLAYED_MSG");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_OnShow()
-- DESC : Display the icon in the bar
-- NOTE : For a lack of better check at the moment TitanPanel_ButtonAdded
--        is a global variable set to true only when a button has just been
--        added to the panel
-- **************************************************************************
function TitanPanelXPButton_OnShow()
	TitanPanelXPButton_SetIcon();
	found = nil;
	if not TitanPanelXPButton_ButtonAdded then
		if not TitanAllGetVar("Silenced") then
			RequestTimePlayed();
		end
		TitanPanelXPButton_ButtonAdded = true;
	end
end


function TitanPanelXPButton_OnHide()
	if (TitanPanelSettings) then
		for i = 1, table.getn(TitanPanelSettings.Buttons) do		
			if(TitanPanelSettings.Buttons[i] == TITAN_XP_ID) then
				found = true;			
			end	
		end
		if not found then
			TitanPanelXPButton_ButtonAdded = nil
		end
	end
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_OnEvent(arg1, arg2)
-- DESC : Parse events registered to addon and act on them
-- VARS : arg1 = <research> , arg2 = <research>
-- **************************************************************************
function TitanPanelXPButton_OnEvent(self, event, a1, a2, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		if (not self.sessionTime) then
			self.sessionTime = time();
		end
		if (not self.initXP) then
			self.initXP = UnitXP("player");
			self.accumXP = 0;
			self.sessionXP = 0;
			self.startSessionTime = time();
			lastXP = self.initXP;
		end
	elseif (event == "TIME_PLAYED_MSG") then
		-- Remember play time
		self.totalTime = a1;
		self.levelTime = a2;
	elseif (event == "PLAYER_XP_UPDATE") then
		if (not self.initXP) then
			self.initXP = UnitXP("player");
			self.accumXP = 0;
			self.sessionXP = 0;
			self.startSessionTime = time();
		end
		XPGain = UnitXP("player") - lastXP;
		lastXP = UnitXP("player");
		if XPGain < 0 then XPGain = 0 end
		self.sessionXP = UnitXP("player") - self.initXP + self.accumXP;
	elseif (event == "PLAYER_LEVEL_UP") then
		self.levelTime = 0;
		self.accumXP = self.accumXP + UnitXPMax("player") - self.initXP;
		self.initXP = 0;
	elseif (event == "CHAT_MSG_COMBAT_XP_GAIN") then
		local _,_,_,killXP = string.find(a1, "^"..L["TITAN_XP_GAIN_PATTERN"])
		if killXP then lastMobXP = tonumber(killXP) end
		if lastMobXP < 0 then lastMobXP = 0 end
	end
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_OnUpdate(elapsed)
-- DESC : Update button data
-- VARS : elapsed = <research>
-- **************************************************************************
function TitanPanelXPButton_OnUpdate(self, elapsed)
	TITAN_XP_FREQUENCY = TITAN_XP_FREQUENCY - elapsed;
	if (TITAN_XP_FREQUENCY <=0) then
		TITAN_XP_FREQUENCY = 1;
		TitanPanelPluginHandle_OnUpdate(updateTable)
	end
	if (self.totalTime) then
		self.totalTime = self.totalTime + elapsed;
		self.levelTime = self.levelTime + elapsed;
	end
end


-- **************************************************************************
-- NAME : TitanPanelXPButton_GetButtonText(id)
-- DESC : Calculate time based logic for button text
-- VARS : id = button ID
-- NOTE : Because the panel gets loaded before XP we need to check whether
--        the variables have been initialized and take action if they haven't
-- **************************************************************************
function TitanPanelXPButton_GetButtonText(id)
	if (TitanPanelXPButton.startSessionTime == nil) then
		return;
	end

	local button, id = TitanUtils_GetButton(id, true);
	local totalXP = UnitXPMax("player");
	local currentXP = UnitXP("player");
	local toLevelXP = totalXP - currentXP;
	local sessionXP = button.sessionXP;
	local xpPerHour, xpPerHourText, timeToLevel, timeToLevelText;
	local sessionTime = time() - TitanPanelXPButton.startSessionTime;
	local levelTime = TitanPanelXPButton.levelTime;
	local numofkills, numofgains;
	if lastMobXP ~= 0 then numofkills = math.ceil(toLevelXP / lastMobXP) else numofkills = _G["UNKNOWN"] end
	if XPGain ~= 0 then numofgains = math.ceil(toLevelXP / XPGain) else numofgains = _G["UNKNOWN"] end

	if (levelTime) then
		if (TitanGetVar(TITAN_XP_ID, "DisplayType") == "ShowXPPerHourSession") then
			xpPerHour = sessionXP / sessionTime * 3600;
--			timeToLevel = TitanUtils_Ternary((sessionXP == 0), -1, toLevelXP / sessionXP * sessionTime);
			timeToLevel = (sessionXP == 0) and -1 or toLevelXP / sessionXP * sessionTime;

			xpPerHourText = comma_value(math.floor(xpPerHour+0.5));
			timeToLevelText = TitanUtils_GetEstTimeText(timeToLevel);

			return L["TITAN_XP_BUTTON_LABEL_XPHR_SESSION"], TitanUtils_GetHighlightText(xpPerHourText),
				L["TITAN_XP_BUTTON_LABEL_TOLEVEL_TIME_LEVEL"], TitanUtils_GetHighlightText(timeToLevelText);
		elseif (TitanGetVar(TITAN_XP_ID,"DisplayType") == "ShowXPPerHourLevel") then
			xpPerHour = currentXP / levelTime * 3600;
--			timeToLevel = TitanUtils_Ternary((currentXP == 0), -1, toLevelXP / currentXP * levelTime);
			timeToLevel = (currentXP == 0) and -1 or toLevelXP / currentXP * levelTime;

			xpPerHourText = comma_value(math.floor(xpPerHour+0.5));
			timeToLevelText = TitanUtils_GetEstTimeText(timeToLevel);

			return L["TITAN_XP_BUTTON_LABEL_XPHR_LEVEL"], TitanUtils_GetHighlightText(xpPerHourText),
				L["TITAN_XP_BUTTON_LABEL_TOLEVEL_TIME_LEVEL"], TitanUtils_GetHighlightText(timeToLevelText);
		elseif (TitanGetVar(TITAN_XP_ID,"DisplayType") == "ShowSessionTime") then
			return L["TITAN_XP_BUTTON_LABEL_SESSION_TIME"], TitanUtils_GetHighlightText(TitanUtils_GetAbbrTimeText(sessionTime));
		elseif (TitanGetVar(TITAN_XP_ID,"DisplayType") == "ShowXPSimple") then
			local toLevelXPText = "";
			local rest = "";
			local labelrested = "";
			local labeltolevel = "";
			local labelnumofkills = "";
			local labelnumofgains = "";
			local percent = floor(10000*(currentXP/totalXP)+0.5)/100;
			if TitanGetVar(TITAN_XP_ID,"ShowSimpleToLevel") then
				toLevelXPText = TitanUtils_GetColoredText(format(L["TITAN_XP_FORMAT"], comma_value(math.floor(toLevelXP+0.5))), _G["GREEN_FONT_COLOR"]);
				labeltolevel = L["TITAN_XP_XPTOLEVELUP"];
			end
			if TitanGetVar(TITAN_XP_ID,"ShowSimpleRested") then
				rest = TitanUtils_GetColoredText(comma_value(GetXPExhaustion()==nil and "0" or GetXPExhaustion()),{r=0.44, g=0.69, b=0.94});
				labelrested = L["TITAN_XP_TOTAL_RESTED"];
			end
			if TitanGetVar(TITAN_XP_ID,"ShowSimpleNumOfKills") then
				numofkills = TitanUtils_GetColoredText(comma_value(numofkills), {r=0.24, g=0.7, b=0.44})
				labelnumofkills = L["TITAN_XP_KILLS_LABEL_SHORT"];
			else
				numofkills = ""
			end
			if TitanGetVar(TITAN_XP_ID,"ShowSimpleNumOfGains") then
				numofgains = TitanUtils_GetColoredText(comma_value(numofgains), {r=1, g=0.49, b=0.04})
				labelnumofgains = L["TITAN_XP_XPGAINS_LABEL_SHORT"];
			else
				numofgains = ""
			end

			if TitanGetVar(TITAN_XP_ID,"ShowSimpleNumOfGains") then
				return L["TITAN_XP_LEVEL_COMPLETE"], TitanUtils_GetHighlightText(percent .. "%"), labelrested, rest , labeltolevel, toLevelXPText, labelnumofgains, numofgains
			else
				return L["TITAN_XP_LEVEL_COMPLETE"], TitanUtils_GetHighlightText(percent .. "%"), labelrested, rest , labeltolevel, toLevelXPText, labelnumofkills, numofkills
			end
		end
	else
		return "("..L["TITAN_XP_UPDATE_PENDING"]..")";
	end
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelXPButton_GetTooltipText()
	local totalTime = TitanPanelXPButton.totalTime;
	local sessionTime = time() - TitanPanelXPButton.startSessionTime;
	local levelTime = TitanPanelXPButton.levelTime;
	-- failsafe to ensure that an error wont be returned
	if not levelTime then return end
	local totalXP = UnitXPMax("player");
	local currentXP = UnitXP("player");
	local toLevelXP = totalXP - currentXP;
	local currentXPPercent = currentXP / totalXP * 100;
	local toLevelXPPercent = toLevelXP / totalXP * 100;
	local xpPerHourThisLevel = currentXP / levelTime * 3600;
	local xpPerHourThisSession = TitanPanelXPButton.sessionXP / sessionTime * 3600;
	local estTimeToLevelThisLevel = TitanUtils_Ternary((currentXP == 0), -1, toLevelXP / (max(currentXP,1)) * levelTime);
	local estTimeToLevelThisSession = 0;
	if TitanPanelXPButton.sessionXP > 0 then
		estTimeToLevelThisSession = TitanUtils_Ternary((TitanPanelXPButton.sessionXP == 0), -1, toLevelXP / TitanPanelXPButton.sessionXP * sessionTime);
	end
	local numofkills, numofgains;
	if lastMobXP ~= 0 then numofkills = math.ceil(toLevelXP / lastMobXP) else numofkills = _G["UNKNOWN"] end
	if XPGain ~= 0 then numofgains = math.ceil(toLevelXP / XPGain) else numofgains = _G["UNKNOWN"] end
	return ""..
		L["TITAN_XP_TOOLTIP_TOTAL_TIME"].."\t"..TitanUtils_GetHighlightText(TitanUtils_GetAbbrTimeText(totalTime)).."\n"..
		L["TITAN_XP_TOOLTIP_LEVEL_TIME"].."\t"..TitanUtils_GetHighlightText(TitanUtils_GetAbbrTimeText(levelTime)).."\n"..
		L["TITAN_XP_TOOLTIP_SESSION_TIME"].."\t"..TitanUtils_GetHighlightText(TitanUtils_GetAbbrTimeText(sessionTime)).."\n"..
		"\n"..
		L["TITAN_XP_TOOLTIP_TOTAL_XP"].."\t"..TitanUtils_GetHighlightText(comma_value(totalXP)).."\n".. 
		L["TITAN_XP_TOTAL_RESTED"].."\t"..TitanUtils_GetHighlightText(comma_value(GetXPExhaustion()==nil and "0" or GetXPExhaustion())).."\n".. 
		L["TITAN_XP_TOOLTIP_LEVEL_XP"].."\t"..TitanUtils_GetHighlightText(comma_value(currentXP).." "..format(L["TITAN_XP_PERCENT_FORMAT"], currentXPPercent)).."\n"..
		L["TITAN_XP_TOOLTIP_TOLEVEL_XP"].."\t"..TitanUtils_GetHighlightText(comma_value(toLevelXP).." "..format(L["TITAN_XP_PERCENT_FORMAT"], toLevelXPPercent)).."\n"..
		L["TITAN_XP_TOOLTIP_SESSION_XP"].."\t"..TitanUtils_GetHighlightText(comma_value(TitanPanelXPButton.sessionXP)).."\n"..
		format(L["TITAN_XP_KILLS_LABEL"], comma_value(lastMobXP)).."\t"..TitanUtils_GetHighlightText(comma_value(numofkills)).."\n"..
		format(L["TITAN_XP_XPGAINS_LABEL"], comma_value(XPGain)).."\t"..TitanUtils_GetHighlightText(comma_value(numofgains)).."\n"..
		"\n"..
		L["TITAN_XP_TOOLTIP_XPHR_LEVEL"].."\t"..TitanUtils_GetHighlightText(format(L["TITAN_XP_FORMAT"], comma_value(math.floor(xpPerHourThisLevel+0.5)))).."\n"..
		L["TITAN_XP_TOOLTIP_XPHR_SESSION"].."\t"..TitanUtils_GetHighlightText(format(L["TITAN_XP_FORMAT"], comma_value(math.floor(xpPerHourThisSession+0.5)))).."\n"..
		L["TITAN_XP_TOOLTIP_TOLEVEL_LEVEL"].."\t"..TitanUtils_GetHighlightText(TitanUtils_GetAbbrTimeText(estTimeToLevelThisLevel)).."\n"..
		L["TITAN_XP_TOOLTIP_TOLEVEL_SESSION"].."\t"..TitanUtils_GetHighlightText(TitanUtils_GetAbbrTimeText(estTimeToLevelThisSession));
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_SetIcon()
-- DESC : Define icon based on faction
-- **************************************************************************
function TitanPanelXPButton_SetIcon()
	local icon = TitanPanelXPButtonIcon;
	local factionGroup, factionName = UnitFactionGroup("player");

	if (factionGroup == "Alliance") then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance");
		icon:SetTexCoord(0.046875, 0.609375, 0.03125, 0.59375);
	elseif (factionGroup == "Horde") then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde");
		icon:SetTexCoord(0.046875, 0.609375, 0.015625, 0.578125);
	else
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		icon:SetTexCoord(0.046875, 0.609375, 0.03125, 0.59375);
	end
end

local function Seperator(chosen)
--[[
TitanDebug("Sep: "
..(chosen or "?").." "
)
--]]
	if chosen == "UseSeperatorComma" then
		TitanSetVar(TITAN_XP_ID, "UseSeperatorComma", true);
		TitanSetVar(TITAN_XP_ID, "UseSeperatorPeriod", false);
	end
	if chosen == "UseSeperatorPeriod" then
		TitanSetVar(TITAN_XP_ID, "UseSeperatorComma", false);
		TitanSetVar(TITAN_XP_ID, "UseSeperatorPeriod", true);
	end
	TitanPanelButton_UpdateButton(TITAN_XP_ID);
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareXPMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareXPMenu()

	local info = {};
	if LIB_UIDROPDOWNMENU_MENU_LEVEL == 2 then
		TitanPanelRightClickMenu_AddTitle(L["TITAN_XP_MENU_SIMPLE_BUTTON_TITLE"], 2);

		info = {};
		info.text = L["TITAN_XP_MENU_SIMPLE_BUTTON_RESTED"];
		info.func = function() TitanPanelRightClickMenu_ToggleVar({TITAN_XP_ID, "ShowSimpleRested"}) end
		info.checked = TitanUtils_Ternary(TitanGetVar(TITAN_XP_ID, "ShowSimpleRested"), 1, nil);
		info.keepShownOnClick = 1;
		Lib_UIDropDownMenu_AddButton(info, 2);

		info = {};
		info.text = L["TITAN_XP_MENU_SIMPLE_BUTTON_TOLEVELUP"];
		info.func = function() TitanPanelRightClickMenu_ToggleVar({TITAN_XP_ID, "ShowSimpleToLevel"}) end
		info.checked = TitanUtils_Ternary(TitanGetVar(TITAN_XP_ID, "ShowSimpleToLevel"), 1, nil);
		info.keepShownOnClick = 1;
		Lib_UIDropDownMenu_AddButton(info, 2);

		info = {};
		info.text = L["TITAN_XP_MENU_SIMPLE_BUTTON_KILLS"];
		info.func = function() TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfKills", true) TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfGains", false) end
		info.checked = TitanUtils_Ternary(TitanGetVar(TITAN_XP_ID, "ShowSimpleNumOfKills"), 1, nil);
		Lib_UIDropDownMenu_AddButton(info, 2);

		info = {};
		info.text = L["TITAN_XP_MENU_SIMPLE_BUTTON_XPGAIN"];
		info.func = function() TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfGains", true) TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfKills", false) end
		info.checked = TitanUtils_Ternary(TitanGetVar(TITAN_XP_ID, "ShowSimpleNumOfGains"), 1, nil);
		Lib_UIDropDownMenu_AddButton(info, 2);
	else
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_XP_ID].menuText);
		info = {};
		info.text = L["TITAN_XP_MENU_SHOW_XPHR_THIS_SESSION"];
		info.func = TitanPanelXPButton_ShowXPPerHourSession;
		info.checked = TitanUtils_Ternary("ShowXPPerHourSession" == TitanGetVar(TITAN_XP_ID, "DisplayType"), 1, nil);
		Lib_UIDropDownMenu_AddButton(info);

		info = {};
		info.text = L["TITAN_XP_MENU_SHOW_XPHR_THIS_LEVEL"];
		info.func = TitanPanelXPButton_ShowXPPerHourLevel;
		info.checked = TitanUtils_Ternary("ShowXPPerHourLevel" == TitanGetVar(TITAN_XP_ID, "DisplayType"), 1, nil);
		Lib_UIDropDownMenu_AddButton(info);

		info = {};
		info.text = L["TITAN_XP_MENU_SHOW_SESSION_TIME"];
		info.func = TitanPanelXPButton_ShowSessionTime;
		info.checked = TitanUtils_Ternary("ShowSessionTime" == TitanGetVar(TITAN_XP_ID, "DisplayType"), 1, nil);
		Lib_UIDropDownMenu_AddButton(info);
 
		info = {};
		info.text = L["TITAN_XP_MENU_SHOW_RESTED_TOLEVELUP"];
		info.func = TitanPanelXPButton_ShowXPSimple;
		info.hasArrow = 1;
		info.checked = TitanUtils_Ternary("ShowXPSimple" == TitanGetVar(TITAN_XP_ID, "DisplayType"), 1, nil);
		Lib_UIDropDownMenu_AddButton(info);

		TitanPanelRightClickMenu_AddSpacer();
		TitanPanelRightClickMenu_AddCommand(L["TITAN_XP_MENU_RESET_SESSION"], TITAN_XP_ID, "TitanPanelXPButton_ResetSession");
		TitanPanelRightClickMenu_AddCommand(L["TITAN_XP_MENU_REFRESH_PLAYED"], TITAN_XP_ID, "TitanPanelXPButton_RefreshPlayed");

		TitanPanelRightClickMenu_AddSpacer();
		TitanPanelRightClickMenu_AddToggleIcon(TITAN_XP_ID);
		TitanPanelRightClickMenu_AddToggleLabelText(TITAN_XP_ID);

		TitanPanelRightClickMenu_AddSpacer();

		local info = {};
		info.text = L["TITAN_USE_COMMA"];
		info.checked = TitanGetVar(TITAN_XP_ID, "UseSeperatorComma");
		info.func = function()
			Seperator("UseSeperatorComma")
		end
	Lib_UIDropDownMenu_AddButton(info, _G["LIB_UIDROPDOWNMENU_MENU_LEVEL"]);
	local info = {};
	info.text = L["TITAN_USE_PERIOD"];
	info.checked = TitanGetVar(TITAN_XP_ID, "UseSeperatorPeriod");
	info.func = function()
		Seperator("UseSeperatorPeriod")
	end
	Lib_UIDropDownMenu_AddButton(info, _G["LIB_UIDROPDOWNMENU_MENU_LEVEL"]);

	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_XP_ID, TITAN_PANEL_MENU_FUNC_HIDE);
	end
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_ShowSessionTime()
-- DESC : Display session time in bar if set
-- **************************************************************************
function TitanPanelXPButton_ShowSessionTime()
	TitanSetVar(TITAN_XP_ID, "DisplayType", "ShowSessionTime");
	TitanPanelButton_UpdateButton(TITAN_XP_ID);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleRested", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleToLevel", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfKills", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfGains", false);
end


-- **************************************************************************
-- NAME : TitanPanelXPButton_ShowXPPerHourSession()
-- DESC : Display per hour in session data in bar if set
-- **************************************************************************
function TitanPanelXPButton_ShowXPPerHourSession()
	TitanSetVar(TITAN_XP_ID, "DisplayType", "ShowXPPerHourSession");
	TitanPanelButton_UpdateButton(TITAN_XP_ID);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleRested", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleToLevel", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfKills", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfGains", false);
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_ShowXPPerHourLevel()
-- DESC : Display per hour to level data in bar if set
-- **************************************************************************
function TitanPanelXPButton_ShowXPPerHourLevel()
	TitanSetVar(TITAN_XP_ID, "DisplayType", "ShowXPPerHourLevel");
	TitanPanelButton_UpdateButton(TITAN_XP_ID);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleRested", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleToLevel", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfKills", false);
	TitanSetVar(TITAN_XP_ID, "ShowSimpleNumOfGains", false);
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_ShowXPSimple()
-- DESC : Display simple XP data (% level, rest, xp to level) in bar if set
-- **************************************************************************
 function TitanPanelXPButton_ShowXPSimple()
	TitanSetVar(TITAN_XP_ID, "DisplayType", "ShowXPSimple");
	TitanPanelButton_UpdateButton(TITAN_XP_ID);
 end

-- **************************************************************************
-- NAME : TitanPanelXPButton_ResetSession()
-- DESC : Reset session and accumulated variables
-- **************************************************************************
function TitanPanelXPButton_ResetSession()
	TitanPanelXPButton.initXP = UnitXP("player");
	TitanPanelXPButton.accumXP = 0;
	TitanPanelXPButton.sessionXP = 0;
	TitanPanelXPButton.startSessionTime = time();
	lastXP = TitanPanelXPButton.initXP;
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_RefreshPlayed()
-- DESC : Get total time played
-- **************************************************************************
function TitanPanelXPButton_RefreshPlayed()
	RequestTimePlayed();
end
