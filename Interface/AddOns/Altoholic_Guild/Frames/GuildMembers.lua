local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- *** Guild Members ***

local view
local viewSortField = "name"
local viewSortOrder
local isViewValid
local expandedHeaders = {}

local sortByMain = {	-- sort functions for the mains
	["name"] = function(a, b)
			if viewSortOrder then
				return a.name < b.name
			else
				return a.name > b.name 
			end
		end,
	["level"] = function(a, b)
			local levelA = select(4, DataStore:GetGuildMemberInfo(a.name))
			local levelB = select(4, DataStore:GetGuildMemberInfo(b.name))
			
			levelA = levelA or 0
			levelB = levelB or 0
			
			if viewSortOrder then
				return levelA < levelB
			else
				return levelA > levelB
			end
		end,
	["averageItemLvl"] = function(a, b)
			local guild = DataStore:GetGuild()
			local ailA = DataStore:GetGuildMemberAverageItemLevel(guild, a.name) or 0
			local ailB = DataStore:GetGuildMemberAverageItemLevel(guild, b.name) or 0
			
			if viewSortOrder then
				return ailA < ailB
			else
				return ailA > ailB
			end
		end,
	["version"] = function(a, b)
			local versionA = addon:GetGuildMemberVersion(a.name) or ""
			local versionB = addon:GetGuildMemberVersion(b.name) or ""
			
			if viewSortOrder then
				return versionA < versionB
			else
				return versionA > versionB
			end
		end,
	["englishClass"] = function(a, b)
			local classA = select(11, DataStore:GetGuildMemberInfo(a.name))
			local classB = select(11, DataStore:GetGuildMemberInfo(b.name))
			
			classA = classA or ""
			classB = classB or ""
			
			if viewSortOrder then
				return classA < classB
			else
				return classA > classB
			end
		end,
}

local sortByAlt = {-- sort functions for the alts
	["name"] = function(a, b)
			if viewSortOrder then
				return a < b
			else
				return a > b
			end
		end,
	["level"] = function(a, b)
			local levelA = select(4, DataStore:GetGuildMemberInfo(a))
			local levelB = select(4, DataStore:GetGuildMemberInfo(b))
			
			levelA = levelA or 0
			levelB = levelB or 0
			
			if viewSortOrder then
				return levelA < levelB
			else
				return levelA > levelB
			end
		end,
	["averageItemLvl"] = function(a, b)
			local guild = DataStore:GetGuild()
			local ailA = DataStore:GetGuildMemberAverageItemLevel(guild, a) or 0
			local ailB = DataStore:GetGuildMemberAverageItemLevel(guild, b) or 0
			
			if viewSortOrder then
				return ailA < ailB
			else
				return ailA > ailB
			end
		end,
	["version"] = function(a, b)
			local versionA = addon:GetGuildMemberVersion(a) or ""
			local versionB = addon:GetGuildMemberVersion(b) or ""
			
			if viewSortOrder then
				return versionA < versionB
			else
				return versionA > versionB
			end
		end,
	["englishClass"] = function(a, b)
			local classA = select(11, DataStore:GetGuildMemberInfo(a))
			local classB = select(11, DataStore:GetGuildMemberInfo(b))
			
			classA = classA or ""
			classB = classB or ""
			
			if viewSortOrder then
				return classA < classB
			else
				return classA > classB
			end
		end,
}

local NORMALPLAYER_LINE = 0		-- a guild mate who does not use altoholic
local ALTO_MAIN_LINE = 2			-- the currently connected character of a guild mate using altoholic
local ALTO_ALT_LINE = 3				-- an alt belonging to the previous line
local OFFLINEHEADER_LINE = 4
local OFFLINEMEMBER_LINE = 5

local HEADER_LINE = 0				-- line number modulo 2 = 0, it's a header

local function BuildView()
	view = view or {}
	wipe(view)
	
	local onlineMembers = {}		-- list of online guild members (and their alts)

	-- 1) Start by adding mains, users of altoholic or not
	for member in pairs(DataStore:GetOnlineGuildMembers()) do
		if addon:GetGuildMemberVersion(member) then			-- altoholic user
			table.insert(view, { lineType = ALTO_MAIN_LINE, name = member } )			-- main character first
		else		-- non altoholic user
			table.insert(view, { lineType = NORMALPLAYER_LINE, name = member } )
		end
		onlineMembers[member] = true
	end
	
	-- 2) sort the highest level
	table.sort(view, sortByMain[viewSortField])
	
	-- 3) add the alts whenever applicable
	for index, line in ipairs(view) do
		if line.lineType == ALTO_MAIN_LINE then
			local alts = DataStore:GetGuildMemberAlts(line.name)
			if alts then
				local altsTable = { strsplit("|", alts) }
				
				-- 4) sort the alts on the same criteria
				table.sort(altsTable, sortByAlt[viewSortField])
			
				local altCount = 1	-- because the insert must be done at index+1 for alt 1, index+2 for alt2, etc..
				for _, altName in ipairs(altsTable) do
					table.insert(view, index + altCount, { lineType = ALTO_ALT_LINE, name = altName } )
					onlineMembers[altName] = true
					altCount = altCount + 1
				end
			end
		end
	end
	
	-- 5) add the header "offline members"
	table.insert(view, {	lineType = OFFLINEHEADER_LINE, name = L["Offline Members"] } )
	
	-- 6) Prepare the list of offline members for which we have data, sort it, then add it to the view
	local offlineMembers = {}

	local guild = DataStore:GetGuild()
	
	for i=1, GetNumGuildMembers(true) do		-- browse all players (online & offline)
		local member = GetGuildRosterInfo(i)
		member = Ambiguate(member, "none")		
		if not onlineMembers[member] then
			offlineMembers[ #offlineMembers + 1 ] = member
		end		
	end
	
	table.sort(offlineMembers, sortByAlt[viewSortField])

	for _, member in ipairs(offlineMembers) do
		table.insert(view, {	lineType = OFFLINEMEMBER_LINE, name = member } )
	end
	
	isViewValid = true
end

local function OnPlayerEquipmentReceived(frame, event, sender, player)
	frame.Equipment:Update(player)
end

local function _Init(frame)
	addon:RegisterMessage("DATASTORE_PLAYER_EQUIPMENT_RECEIVED", OnPlayerEquipmentReceived, frame)
end

local function _Update(frame)
	if not isViewValid then
		BuildView()
	end
	
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	
	AltoholicTabGuild.Status:SetText(L["Click a character's AiL to see its equipment"])
	
	if #view == 0 then
		-- Hides all entries of the scrollframe, and updates it accordingly
		for rowIndex = 1, numRows do
			local rowFrame = scrollFrame:GetRow(rowIndex) 
			rowFrame:Hide()
		end
		scrollFrame:Update(numRows)
		return
	end
	
	local offset = scrollFrame:GetOffset()
	local numDisplayedLines = 0
	local numVisibleLines = 0
	local DrawAlts
	local rowIndex = 1
	local i=1
	
	local guild = DataStore:GetGuild()
	
	for lineIndex, v in pairs(view) do
		local rowFrame = scrollFrame:GetRow(rowIndex)
		
		local lineType = mod(v.lineType, 2)
	
		if (offset > 0) or (numDisplayedLines >= numRows) then		-- if the line will not be visible
			if v.lineType == NORMALPLAYER_LINE then
				numVisibleLines = numVisibleLines + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			elseif lineType == HEADER_LINE then							-- then keep track of counters
				if expandedHeaders[v.name] then
					DrawAlts = true
				else
					DrawAlts = false
				end
				numVisibleLines = numVisibleLines + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			elseif DrawAlts then
				numVisibleLines = numVisibleLines + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			end
		else		-- line will be displayed
			local member = v.name
			local _, _, _, level, class, _, _, _, _, _, englishClass = DataStore:GetGuildMemberInfo(member)
			level = level or 0
			
			local classText = L["N/A"]
			if class and englishClass then
				classText = format("%s%s", DataStore:GetClassColor(englishClass), class)
			end
			
			local version = addon:GetGuildMemberVersion(member) or L["N/A"]
			local averageItemLvl = DataStore:GetGuildMemberAverageItemLevel(guild, member) or 0
		
			if v.lineType == NORMALPLAYER_LINE then
			
				rowFrame:SetMember(member, colors.yellow, false)
				rowFrame:SetMemberInfo(level, averageItemLvl, version, classText)
				rowFrame:SetID(lineIndex)
				rowFrame:Show()
				
				rowIndex = rowIndex + 1
				numVisibleLines = numVisibleLines + 1
				numDisplayedLines = numDisplayedLines + 1
				
			elseif lineType == HEADER_LINE then
				if expandedHeaders[member] then
					rowFrame.Collapse:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
					DrawAlts = true
				else
					rowFrame.Collapse:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
					DrawAlts = false
				end
				
				rowFrame:SetMember(member, colors.yellow, true)
				if member == L["Offline Members"] then
					rowFrame:SetMemberInfo("", nil, "", "")
				else
					rowFrame:SetMemberInfo(level, averageItemLvl, version, classText)
				end
				rowFrame:SetID(lineIndex)
				rowFrame:Show()
				
				rowIndex = rowIndex + 1
				numVisibleLines = numVisibleLines + 1
				numDisplayedLines = numDisplayedLines + 1

			elseif DrawAlts then
		
				if v.lineType == ALTO_ALT_LINE then
					rowFrame:SetMember(member, colors.lightBlue, false)
				else
					rowFrame:SetMember(member, colors.grey, false)
				end				
				
				rowFrame:SetMemberInfo(level, averageItemLvl, version, classText)		
				rowFrame:SetID(lineIndex)
				rowFrame:Show()
				
				rowIndex = rowIndex + 1
				numVisibleLines = numVisibleLines + 1
				numDisplayedLines = numDisplayedLines + 1
			end
		end
	end
	
	while rowIndex <= numRows do
		local rowFrame = scrollFrame:GetRow(rowIndex) 
		
		rowFrame:SetID(0)
		rowFrame:Hide()
		rowIndex = rowIndex + 1
	end
	scrollFrame:Update(numVisibleLines)
	frame:Show()
end

local function _Sort(frame, field)
	viewSortField = field
	viewSortOrder = addon:GetOption("UI.Tabs.Guild.SortAscending")
	
	frame:InvalidateView()
	frame:Update()
end

local function _TogglePlayerAlts(frame, rowID)
	if rowID == 0 then return end
	local line = view[rowID]
	
	if expandedHeaders[line.name] then		-- toggle header
		expandedHeaders[line.name] = nil
	else
		expandedHeaders[line.name] = true
	end
	frame:Update()
end

local function _ShowPlayerEquipment(frame, rowID, characterName)
	if rowID == 0 or not characterName then return end
	
	local line = view[rowID]
	if line.lineType == NORMALPLAYER_LINE then return end

	DataStore:RequestGuildMemberEquipment(characterName)
	frame.Equipment.Name:SetText(characterName)
end

local function _InvalidateView()
	isViewValid = nil
end

addon:RegisterClassExtensions("AltoGuildMembers", {
	Init = _Init,
	Sort = _Sort,
	Update = _Update,
	Collapse_OnClick = _Collapse_OnClick,
	InvalidateView = _InvalidateView,
	TogglePlayerAlts = _TogglePlayerAlts,
	ShowPlayerEquipment = _ShowPlayerEquipment,
})


-- *** Equipment ***

local equipmentToFrame = { 1,3,5,9,10,6,7,8,11,12,13,14,15,4,2,19,16,17,18 }

local function _Init(frame)
	-- Set the textures of equipment icons
	for i = 1, 19 do
		local button = frame["Item"..i]
		-- button.Icon:SetTexture(addon:GetEquipmentSlotIcon(equipmentToFrame[i]))
		button:SetIcon(addon:GetEquipmentSlotIcon(equipmentToFrame[i]))
		button:Show()
	end
end

local function _Update(frame, member)
--[[
	button layout				equipment table layout
	
	1	5	9							1	10	11
	2	6	10 						3	6	12
	3	7	11							5	7	13
	4	8	12 						9	8	14
	
	15 13 14 16						2 15 4 19
	
	17 18 19							16 17 18
--]]

	local guild = DataStore:GetGuild()
	
	for i = 1, 19 do
		local button = frame["Item"..i]
		button.Count:Hide();
		button.IconBorder:Hide()
	
		local itemID = DataStore:GetGuildMemberInventoryItem(guild, member, equipmentToFrame[i])
		if itemID then
			-- display the coloured border
			local _, _, itemRarity, itemLevel = GetItemInfo(itemID)
			button:SetItem(itemID, nil, itemRarity)
			button:SetCount(itemLevel)
		else
			button:SetIcon(addon:GetEquipmentSlotIcon(equipmentToFrame[i]))
			button:SetInfo(nil, nil)
		end
		
		button:Show()
	end
end

addon:RegisterClassExtensions("AltoGuildMemberEquipment", {
	Init = _Init,
	Update = _Update,
})
