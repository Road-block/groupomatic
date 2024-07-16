--[[
==============================================
this file contains test cases for group o matic and is not loaded by default. if you want to load it you need to add it to groupomatic.toc *after* the other .lua files

be aware though that this file is designed to emulate being in a raid group, and therefore loading (and running) it will modify functions like GetRaidRosterInfo

if you don't know what you're doing, don't mess with this stuff, it's for advanced configuration of the addon. wow doesn't even know this file is here unless you tell it manually, so it's safe to ignore or delete.


this is for reference, copied from groupomatic.lua
you do NOT need to (and can't, easily) modify these definitions during an actual execution of the auto-arranger
however in order to create your own test cases and definitions you need to have some understanding of how they work
the indeces of the "roles" tables map to these meanings, if myRoles[1] == true, then i am a main tank, etc.
tank, healer, and the 3 dps are considered "primary" roles, at least one of them MUST be true. you can set more than one to be true (for the purpose of a test case), but normally it won't happen during an actual auto-arrange
the other roles are generally related to a single talent, for example, hunters with hunting party get MANA_BATTERY
DECURSER is special, and of course is totally dependant on class, so don't mess with it :P
local roleIndex = {
	["MAIN_TANK"] = 1, --MEAT_SHIELD is also 1
	["TANK"] = 2,
	["TANK_BUFFER"] = 3,
	["HEALER"] = 4,
	["MANA_BATTERY"] = 5,
	["HEAL_BUFFER"] = 6,
	["MELEE_BUFFER"] = 7,
	["RANGE_BUFFER"] = 8,
	["SPELL_BUFFER"] = 9,
	["MELEE_DPS"] = 10,
	["RANGE_DPS"] = 11,
	["SPELL_DPS"] = 12,
	["DECURSER"] = 13,
}


===============
===============

EXAMPLE currRaidTestOriginal's:

note that you must explicitly define empty groups as an empty table, do not just do [8]= whatever. i've used that notation for clarity here, but the {},{},{},..., beforehand is neccessary
remember to do the same after the last group, unless of course group 8 isn't empty

--simple case, 3 people in group 8, 1 w/o a spec
currRaidTestOriginal = {{},{},{},{},{},{},{},
	[8]={
		"player", --this must exist in exactly one index, and means to use the actual current player. the raid index is always 1, because that's simpler
		{2,"WARRIOR","A",{false, true, false, false, false, false, true, false, false, true, false, false}}, -- raid id, class, name, roles table
		{3,"WARLOCK","B",nil}, --use nil for the roles table to simulate a player that did not reply to the talent request
	},
}

--same as above except with another 4 people in group 3. by default rules, the druid F should get put into the tanking group along with the 2 tanks, the warrior, and the lock8
currRaidTestOriginal = {{},{},{
		{5,"ROGUE","D",nil},
		{4,"DRUID","C",{false, true, false, false, false, false, true, false, false, true, false, false}},
		{6,"DRUID","E",{false, false, false, true, false, false, false, false, false, false, false, false}},
		{7,"DRUID","F",{false, false, true, true, false, false, false, false, false, false, false, false}}
	},{},{},{},{},{
		"player",
		{2,"WARRIOR","A",{false, true, false, false, false, false, true, false, false, true, false, false}},
		{3,"WARLOCK","B",nil}
	}
}

--full 25 man raid with noone replying
currRaidTestOriginal = {{
		{2, "WARRIOR","A", nil},
		{3, "DRUID","B", nil},
		{4, "ROGUE","C", nil},
		{5, "HUNTER","D", nil},
		{6, "SHAMAN","E", nil}
	},
	{
		{7, "WARLOCK","F", nil},
		{8, "DRUID","G", nil},
		{9, "PRIEST","H", nil},
		{10, "MAGE","I", nil},
		{11, "PRIEST","J", nil}
	},
	{
		{12, "MAGE","K", nil},
		{13, "WARLOCK","L", nil},
		{14, "WARRIOR","M", nil},
		{15, "DRUID","N", nil},
		{16, "PALADIN","O", nil}
	},
	{
		{17, "PALADIN","P", nil},
		{18, "ROGUE","Q", nil},
		{19, "HUNTER","R", nil},
		{20, "MAGE","S", nil},
		{21, "WARRIOR","T", nil}
	},
	{
		{22, "PRIEST","U", nil},
		{23, "SHAMAN","V", nil},
		{24, "WARLOCK","W", nil},
		{25, "PRIEST","X", nil},
		"player"
	},{},{},{}
}

--AB testing
currRaidTestOriginal = {{
		{2, "WARRIOR","DPS1", {false,false,false,false,false,false,true,false,false,true,false,false}, "Blacksmith"},
		{3, "DRUID","Tree1", {false, false, true, true, false, false, false, false, false, false, false, false}, "Trollbane Hall"},
		{4, "DRUID","Bear1", {false, true, false, false, false, false, true, false, false, true, false, false}, "Lumber Mill"},
		{5, "DRUID","Tree2", {false, false, true, true, false, false, false, false, false, false, false, false}, "Arathi Basin"},
		"player"
	},
	{
		{6, "PRIEST","Shadow1", {false, false, true, false, true, false, false, false, false, false, false, true}, "Offline"},
		{7, "DRUID","TestTree3", {false, false, true, true, false, false, false, false, false, false, false, false}, "Defilers' Den"},				
		{8, "PRIEST","H", nil, "Terrokar Forrest"},
		{10, "MAGE","I", nil, "Blacksmith"},
		{11, "PRIEST","J", nil, "Blacksmith"}
	},
	{
		{12, "MAGE","K", nil, "Mine"},
		{13, "WARLOCK","L", nil, "Mine"},
		{14, "WARRIOR","M", nil, "Blacksmith"},
		{15, "PALADIN","P", nil, "Farm"},		
		{9, "PALADIN","O", nil, "Stables"}
	},{},{},{},{},{}
}

--full 40 man raid with noone replying
local currRaidTestOriginal = {{
		{2, "WARRIOR","A", nil},
		{3, "DRUID","B", nil},
		{4, "ROGUE","C", nil},
		{5, "HUNTER","D", nil},
		{6, "SHAMAN","E", nil}
	},
	{
		{7, "WARLOCK","F", nil},
		{8, "DRUID","G", nil},
		{9, "PRIEST","H", nil},
		{10, "MAGE","I", nil},
		{11, "PRIEST","J", nil}
	},
	{
		{12, "MAGE","K", nil},
		{13, "WARLOCK","L", nil},
		{14, "WARRIOR","M", nil},
		{15, "DRUID","N", nil},
		{16, "PALADIN","O", nil}
	},
	{
		{17, "PALADIN","P", nil},
		{18, "ROGUE","Q", nil},
		{19, "HUNTER","R", nil},
		{20, "MAGE","S", nil},
		{21, "WARRIOR","T", nil}
	},
	{
		{22, "PRIEST","U", nil},
		{23, "SHAMAN","V", nil},
		{24, "WARLOCK","W", nil},
		{25, "PRIEST","X", nil},
		"player"
	},
	{
		{26, "PALADIN","Y", nil},
		{27, "ROGUE","Z", nil},
		{28, "WARLOCK","AA", nil},
		{29, "MAGE","AB", nil},
		{30, "WARRIOR","AC", nil}
	},
	{
		{31, "DRUID","AD", nil},
		{32, "PRIEST","AE", nil},
		{33, "WARLOCK","AF", nil},
		{34, "MAGE","AG", nil},
		{35, "WARRIOR","AH", nil}
	},
	{
		{36, "MAGE","AI", nil},
		{37, "ROGUE","AJ", nil},
		{38, "SHAMAN","AK", nil},
		{39, "DRUID","AL", nil},
		{40, "PALADIN","AM", nil}
	},
}]]
--==============================================


-------------------------------------------------------------------------
 --put the test case to run here
 
--same as above except with another 4 people in group 3. by default rules, the druid F should get put into the tanking group along with the 2 tanks, the warrior, and the lock8
currRaidTestOriginal = {{},{},{
		{5,"ROGUE","dps1",{false,false,true,false}},
		{4,"DRUID","healer1",{false, true}},
		{6,"DRUID","healer2",{false, true}},
		{5,"ROGUE","dps2",{false,false,true,false}}
	},{},{},{},{},{
		"player",
		{2,"WARRIOR","tank1",{true}},
		{3,"WARLOCK","tank2",{true}}
	}
}


-------------------------------------------------------------------------



-------------------------------------------------------------------------
--don't worry about modifying anything after this
-------------------------------------------------------------------------

local active = false

local currRaid = CopyTable(currRaidTestOriginal)

local function cout(msg)
	if(DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0, 1.0);	
	end
end

function GOMTEST_GetNumPartyMembers()
	local num = 0
	
	foreachi(currRaid, function(i,v)
		foreachi(v, function(i,v)
			num = num + 1
		end)
	end)
	
	return num
end

function GOMTEST_CanInspectUnit()
	return not UnitIsUnit(u, "player")
end

function GOMTEST_GetMinimapZoneText()
	return "Blacksmith"
end

function GOMTEST_GetRaidRosterInfo(index)

	local name, rank, subgroup, level, class, fileName, zone, online, isDead = nil, 0, nil, 80, (UnitClass("raid"..index)), select(2, UnitClass("raid"..index)), "<ZONE>", true, false
	
	if index==1 then
		name = UnitName("player")
		for i=1, 8 do
			local g=currRaid[i]
			for j=1, getn(g) do
				if type (g[j]) == "string" then
					if g[j] == "player" then
						subgroup = i
						rank = 2
						zone = "Blacksmith"
						break
					end
				end
			end
		end
	else
		for i=1, 8 do
			local g=currRaid[i]
			for j=1, getn(g) do
				if type (g[j]) == "table" then
					if g[j][1] == index then
						subgroup = i
						zone = g[j][5] or "<ZONE>"
						name = g[j][3]
						break
					end
				end
			end
		end
	end
	
	if not name then
		return nil
	end
	
	return name, rank, subgroup, level, class, fileName, zone, online, isDead
end

function GOMTEST_IsPartyLeader()
	return true
end

local function LocalizeClass(class)
	return ({["WARRIOR"]="Warrior",["ROGUE"]="Rogue",["PALADIN"]="Paladin",["MAGE"]="Mage",["DRUID"]="Druid",["WARLOCK"]="Warlock",["HUNTER"]="Hunter",["SHAMAN"]="Shaman",["PRIEST"]="Priest",["DEATHKNIGHT"]="DeathKnight"})[class]
end

function GOMTEST_UnitClass(unit, ...)
	local _,_,index = unit:find("raid(%d+)")
	index = tonumber(index)
	if index then
		if index == 1 then
			return GOMTEST_OldUnitClass("player")
		end
		for i=1, 8 do
			local g=currRaid[i]
			for j=1, getn(g) do
				if type (g[j]) == "table" then
					if g[j][1] == index then
						return LocalizeClass(g[j][2]), g[j][2]
					end
				end
			end
		end
	end
	
	return GOMTEST_OldUnitClass(unit, ...) 
end

function GOMTEST_UnitName(unit, ...)
	local _,_,index = unit:find("raid(%d+)")
	index = tonumber(index)
	if index then
		if index == 1 then
			return GOMTEST_OldUnitName("player")
		end
		for i=1, 8 do
			local g=currRaid[i]
			for j=1, getn(g) do
				if type (g[j]) == "table" then
					if g[j][1] == index then
						return g[j][3]
					end
				end
			end
		end
	end
	
	return GOMTEST_OldUnitName(unit, ...) 
end

function GOMTEST_UnitExists(unit, ...)
	local _,_,index = unit:find("raid(%d+)")
	index = tonumber(index)
	if index then
		for i=1, 8 do
			local g=currRaid[i]
			for j=1, getn(g) do
				if type (g[j]) == "table" then				
					if g[j][1] == index then
						return true
					end
				elseif type (g[j]) == "string" and g[j] == "player" then
					if index == 1 then
						return true
					end
				end
			end
		end
		
		return false
	end
	
	return GOMTEST_OldUnitExists(unit, ...) 
end

local function IsGroupFull(group)
	return getn(currRaid[group]) >= 5
end

function GOMTEST_SetRaidSubgroup(index, group)
local m1, m2 = index or "nil", group or "nil"
--cout("set "..m1..", "..m2)
	if IsGroupFull(group) then cout("FULLFULLFULLFULLFULL") return end
	
	local currGroup,currGroupIndex = nil, nil
	
	for i=1, 8 do
		local g=currRaid[i]
		for j=1, getn(g) do
			if type (g[j]) == "table" then
				if g[j][1] == index then
					currGroup = i
					currGroupIndex = j
					break
				end
			elseif type(g[j]) == "string" and g[j] == "player" then
				if index == 1 then
					currGroup = i
					currGroupIndex = j
					break
				end
			end
		end
	end
	
	table.insert(currRaid[group], table.remove(currRaid[currGroup], currGroupIndex))
	
	RaidFrame_LoadUI()
	RaidFrame_Update()
	RaidPullout_RenewFrames()
end

function GOMTEST_SwapRaidSubgroup (i1, i2)
local m1, m2 = i1 or "nil", i2 or "nil"
--cout("swap "..m1..", "..m2)
	local currGroup1, currGroup2, currIndex1, currIndex2 = nil, nil, nil, nil
	
	for i=1, 8 do
		local g=currRaid[i]
		for j=1, getn(g) do
			if type (g[j]) == "table" then
				if g[j][1] == i1 then
					currGroup1 = i
					currIndex1 = j		
				elseif g[j][1] == i2 then
					currGroup2 = i
					currIndex2 = j		
				end
			elseif type(g[j]) == "string" and g[j] == "player" then
				if 1 == i1 then
					currGroup1 = i
					currIndex1 = j		
				elseif 1 == i2 then
					currGroup2 = i
					currIndex2 = j		
				end
			end
		end
	end	
		
	m1 = table.remove(currRaid[currGroup1], currIndex1)
	m2 = table.remove(currRaid[currGroup2], currIndex2)
	table.insert(currRaid[currGroup2], m1)
	table.insert(currRaid[currGroup1], m2)
	
	RaidFrame_LoadUI()
	RaidFrame_Update()
	RaidPullout_RenewFrames()
end

local function display()
	local i = 1
	while i < 8 do
		for j=1, 5 do
			local g=currRaid[i]

			local msg = i..","..j
			if g and g[j] then				
				if type(g[j]) == "string" and g[j] == "player" then
					msg = msg..": PLAYER"
				elseif type(g[j]) == "table" then
					msg = msg..","..g[j][1]..": "..g[j][2].." "..g[j][3]
					if g[j][5] then
						msg = msg.." "..g[j][5]
					end
				end
			else
				msg = msg.."<EMPTY>"
			end
			
			g=currRaid[i + 1]
			msg = msg.."     "..tostring(i + 1)..","..j

			if g and g[j] then
				if type(g[j]) == "string" and g[j] == "player" then
					msg = msg..": PLAYER"
				elseif type(g[j]) == "table" then
					msg = msg..","..g[j][1]..": "..g[j][2].." "..g[j][3]
					if g[j][5] then
						msg = msg.." "..g[j][5]
					end
				end
			else
				msg = msg.."<EMPTY>"
			end
			
			cout(msg)
		end
		cout("\n")
		i = i + 2
	end	
	cout("You can also use the Blizzard Raid window.")
end

GOMTEST_TalentReplyCounter = {1,1}

function GOMTEST_SendAddonMessage(prefix, body, chnl, target)
	if chnl and chnl == "RAID" and prefix and prefix == "GOMTALENT" then
			GOMTEST_TalentReplyCounter = {1,1}
			GOMatic_TestFrame:SetScript("OnUpdate", GOMTestFrame_OnUpdate)
			GOMatic_TestFrame:Show()
	else
		GOMTEST_OldSendAddonMessage(prefix, body, chnl, target)
	end
end

function GOMTestFrame_OnUpdate()
	if not (GOMatic_TalentRequestFrame and GOMatic_TalentRequestFrame:IsVisible() ) then
		GOMatic_TestFrame:SetScript("OnUpdate", nil)
	end

	local x, y = GOMTEST_TalentReplyCounter[1], GOMTEST_TalentReplyCounter[2]
	
	local m = currRaid[x][y]
	
	if m then
		--only table because we don't send a talent reply to ourself
		if type(m) == "table" and m[4] then
			local self, event, prefix, body, chan, target = GOMatic_TalentRequestFrame, "CHAT_MSG_ADDON", "GOMTALENTR", GrOM.RolesToString(m[4]), "WHISPER", m[3]
			GrOM.TalentRequest_OnEvent(self, event, prefix, body, chan, target)
		end
	end
	GOMTEST_TalentReplyCounter[2] = GOMTEST_TalentReplyCounter[2] + 1
	if GOMTEST_TalentReplyCounter[2] == 6 then
		GOMTEST_TalentReplyCounter[2] = 1
		GOMTEST_TalentReplyCounter[1] = GOMTEST_TalentReplyCounter[1] + 1
		if GOMTEST_TalentReplyCounter[1] == 9 then
			GOMatic_TestFrame:SetScript("OnUpdate", nil)
		end
	end
end

local function ClearCache()
	for i=1, 8 do
		local g=currRaid[i]
		for j=1, getn(g) do
			if type (g[j]) == "table" then				
				local n = g[j][3]
				if type(n) == "string" then
					GrOM.RemoveFromCache(n)
				end
			end
		end
	end
end

SlashCmdList["GROUPOMATICTEST"] = function(msg)
	if msg == "display" then
		display()
	elseif msg == "add" then		
		local xxx = nil
		for i=1, 8 do
			local g=currRaid[i]
			if getn(g) < 5 then						
				if not xxx then
					table.insert(currRaid[i], {34, "SHAMAN","QQ", nil})
					xxx = 1
					RaidFrame_LoadUI()
					RaidFrame_Update()
					RaidPullout_RenewFrames()				
				elseif xxx == 1 then
					xxx = 2
					table.insert(currRaid[i], {35, "DRUID","Tree4", {false, false, true, true, false, false, false, false, false, false, false, false}} )
					RaidFrame_LoadUI()
					RaidFrame_Update()
					RaidPullout_RenewFrames()				
				else
					table.insert(currRaid[i], {36, "WARLOCK","T.T", nil} )
					RaidFrame_LoadUI()
					RaidFrame_Update()
					RaidPullout_RenewFrames()				
					return
				end				
			end
		end
	elseif msg == "reset" then
		currRaid = CopyTable(currRaidTestOriginal)
		RaidFrame_LoadUI()
		RaidFrame_Update()
		RaidPullout_RenewFrames()
	else
		if not active then
			active = true
			
			GOMTEST_OldSetRaidSubgroup = SetRaidSubgroup
			GOMTEST_OldSwapRaidSubgroup = SwapRaidSubgroup
			GOMTEST_OldUnitName = UnitName
			GOMTEST_OldUnitClass = UnitClass
			GOMTEST_OldUnitExists = UnitExists
			GOMTEST_OldIsPartyLeader = UnitIsGroupLeader
			GOMTEST_OldGetRaidRosterInfo = GetRaidRosterInfo
			GOMTEST_OldGetNumPartyMembers = GetNumPartyMembers
			GOMTEST_OldSendAddonMessage = SendAddonMessage
			GOMTEST_OldGetMinimapZoneText = GetMinimapZoneText
			GOMTEST_OldCanInspectUnit = CanInspectUnit
			
			CanInspectUnit = GOMTEST_CanInspectUnit
			SetRaidSubgroup = GOMTEST_SetRaidSubgroup
			SwapRaidSubgroup = GOMTEST_SwapRaidSubgroup
			UnitName = GOMTEST_UnitName
			UnitClass = GOMTEST_UnitClass
			UnitExists = GOMTEST_UnitExists
			UnitIsGroupLeader = GOMTEST_IsPartyLeader
			GetRaidRosterInfo = GOMTEST_GetRaidRosterInfo
			GetNumPartyMembers = GOMTEST_GetNumPartyMembers
			SendAddonMessage = GOMTEST_SendAddonMessage
			GetMinimapZoneText = GOMTEST_GetMinimapZoneText
			
			RaidFrame_LoadUI()
			RaidFrame_Update()
			RaidPullout_RenewFrames()
			
			CreateFrame("Frame", "GOMatic_TestFrame")	

			if not ArrangeProxy then GrOM.TestLoaded() end
		
			cout("Group O Matic test functions loaded. Run GOM as you would normally and then type /gomtest display to see the results or /gomtest reset to reload the test.")
		end
	end
end
SLASH_GROUPOMATICTEST1 = "/gomtest"

cout("GOM test module loaded. /gomtest to start /gomtest display to view results.")
