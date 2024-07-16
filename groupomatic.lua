GrOM.Version_String = "4.0.0CU"
local curSaveVersion, _ = 4
local currentDecurserMeanings = {"DISEASE","POISON","MAGIC","CURSE"}

pcall(function()if not ScriptErrors then ScriptErrors = BasicScriptErrors ScriptErrors_Message = BasicScriptErrorsText end end)

GrOM_Vars = {
	rolesByNameCache = {},
	classByNameCache = {},
	SavedRaidLayouts = {},
	AlwaysSure = false,
	Silent = false,
	ShowGUI = true,
	LocalOverridesRemote = false, --old var name, what this==true does now is disable the direct talent check entirely
	userTemplateToUse = nil,
	expanded = false,
	exclude = {false, false, false, false, false, false, false, false},
	excludeSaves = false,
	autoThrottle = 9,
	MVPs = {},
	restoreMethod = "dumb-separate",
	disableTalentRequest = true,
	enableContinuousScan = true,
	alwaysActive = false,
	ezTemplates = {},
	pos = {500, 500},
	ignoreDead = false,
	ignoreBelowLevel = nil,
	ignoreOffline = false,
	syncOut = false,
	syncProfiles = {},
	cacheSecondaryTalents = false,
	saveVersion = curSaveVersion,
	onlyDoRaidMemberAddActionsIfLeader = true,
	oncePerRaid = {}, --flag things that shouldn't happen more than once per raid, this gets completely cleared if the player leaves a raid or loggs in while not in one
	syncSettings = {} --rolesByNameCache, SavedRaidLayouts,  MVPs, ezTemplates
}

GrOM_G_Vars = {
	profiles = {}
}

local function RolesTableToNum(roles)
	local newRoles = 0
	
	if type(roles) ~= "table" then return end
	
	for i, v in pairs(roles) do
		if v then
			newRoles = newRoles + 2 ^ (i - 1)
		end
	end
	
	return newRoles
end

local function RolesNumToTable(roles)
	if type(roles) ~= "number" then return end
	
	local newRoles = {false, false, false, false}--, false, false, false, false, false, false, false, false}
	
	for i = 1, 4--[[12]] do
		newRoles[i] = ( bit.band(roles, 2 ^ (i - 1)) > 0 )
	end
	
	return newRoles
end

function GrOM.Cleanup()
	GrOM_G_Vars.profiles = {}
	GrOM_Vars.rolesByNameCache = {}
	ReloadUI()
end

local function UpdateGVars()
	if not GrOM_G_Vars.profiles then
		GrOM_G_Vars.profiles = {}
	end
end

local function UpdateVars()
	if not GrOM_Vars.rolesByNameCache then
		GrOM_Vars.rolesByNameCache = {}
	end
	if not GrOM_Vars.classByNameCache then
		GrOM_Vars.classByNameCache = {}
	end
	if not GrOM_Vars.SavedRaidLayouts then
		GrOM_Vars.SavedRaidLayouts = {}
	end
	if not GrOM_Vars.exclude then
		GrOM_Vars.exclude = {false, false, false, false, false, false, false, false}
	end
	if not GrOM_Vars.autoThrottle then
		GrOM_Vars.autoThrottle = 9
	end
	if not GrOM_Vars.MVPs then
		GrOM_Vars.MVPs = {}
	end
	if not GrOM_Vars.restoreMethod then
		GrOM_Vars.restoreMethod = "dumb-separate"
	end
	--[[if type(GrOM_Vars.disableTalentRequest) == "nil" then
		GrOM_Vars.disableTalentRequest = true
	end]]
	if not GrOM_Vars.ezTemplates then
		GrOM_Vars.ezTemplates = {}
	end
	if not GrOM_Vars.pos then
		GrOM_Vars.pos = {500, 500}
	end
	if not GrOM_Vars.syncProfiles then
		GrOM_Vars.syncProfiles = {}
	end
	if not GrOM_Vars.syncSettings then
		GrOM_Vars.syncSettings = {}
	end
	if not GrOM_Vars.saveVersion then
		GrOM_Vars.saveVersion = curSaveVersion
	end
	if type(GrOM_Vars.onlyDoRaidMemberAddActionsIfLeader) ~= "boolean" then
		GrOM_Vars.onlyDoRaidMemberAddActionsIfLeader = true
	end
	if (not GrOM_Vars.oncePerRaid) or GetNumGroupMembers() < 1 then
		GrOM_Vars.oncePerRaid = {}
	end
	
	--need to do this better at some point
	GrOM_Vars.disableTalentRequest = true
	
	if not GrOM_Vars.saveVersion then GrOM_Vars.saveVersion = 0 end

--dealing with talents from version 1.x -- R is what the old var was called, i used this opportunity to fix the name :P
	if GrOM_Vars.RolesByNameCache then
		GrOM_Vars.RolesByNameCache = nil
		GrOM.PurgeTalents("2.x")
	end
	if GrOM_Vars.syncSettings["RolesByNameCache"] then
		GrOM_Vars.syncSettings["rolesByNameCache"] = true
		GrOM_Vars.syncSettings["RolesByNameCache"] = nil
	end
-- end dealing with talents from version 1.x

--saveVersion < 2: delete debugCache
	if GrOM_Vars.saveVersion < 2 then
		GrOM_Vars.debugCache = nil
	end
	
--saveVersion < 3: convert roles cache
	--if GrOM_Vars.saveVersion < 3 then
		for k, v in pairs(GrOM_Vars.rolesByNameCache) do
			GrOM_Vars.rolesByNameCache[k] = RolesTableToNum(v) or GrOM_Vars.rolesByNameCache[k]
		end
	--end
	
--saveVersion < 4: update default restore method
	if GrOM_Vars.saveVersion < 4 then
		if GrOM_Vars.restoreMethod == "dumb-merge" then
			GrOM_Vars.restoreMethod = "dumb-separate"
		end
	end

--end saveVersion checks

	GrOM_Vars.saveVersion = curSaveVersion

	UpdateGVars()
end

--set this to 0.xxx for betas
GrOM.Version = 3.0000 --this is obsolete now, but i'm keeping it in case i want to use it for something. it was for update checks.

GrOM.userTemplates = {}
GrOM.raidSize1 = 10
GrOM.raidSize2 = 20
GrOM.raidSize3 = 40
GrOM.talentNumCheckFailBackoffTime = 6
GrOM.maximumTalentNumCheckFailures = 6
GrOM.ArrangementFrameUpdateThrottle = 0.3
GrOM.ArrangementFrameBreakMaximum = 500
GrOM.TalentRequestDelayMinimum = 40.0
GrOM.TalentRequestDelayMaximum = 180.0
GrOM.resetErrorConditionThrottle = 2.0
GrOM.talentRequestTTL = 15 --time to wait before giving up on that person and moving on to the next

GrOM.ARRANGE_BREAK = 0

GrOM.InspectTainted = true
GrOM.SaveName = nil

GrOM.debug = {
	talentCollection = {
		reasons = {
			outdated = 0,
			addonConflict = 0,
			lag = 0,
			badClass = 0,
		},
		lastStackTrace = "",
		ClearReasons = function()
			local t = GrOM.debug.talentCollection.reasons
			foreach(t, function(k) t[k] = 0 end)
		end,
		GetReason = function()
			local num, name = 0, "unknown"
			local t = GrOM.debug.talentCollection.reasons
			foreach(t, function(k,v)
				if v > num then
					name = k
					num = v
				end
			end)
			local descr = {
				outdated = "The talent interpreter is outdated, download the latest version of GOM if there is a newer one.",
				addonConflict = "There was a conflict with another addon. For more details see /gom addonconflict",
				badClass = "UnitClass repeatedly returned an invalid result for other players. This could be due to lag or an outdated version of the addon.",
				lag = "Did not receive a response from the server within 1.8 seconds, so gave up.",
				unknown = "Unknown reason.",
			}
			local msg = descr[name] or name
			return msg
		end,
	},
}

local L_SetRaidSG = ArrangeProxy and ArrangeProxy.SetRaidSubgroup or SetRaidSubgroup
local L_SwapRaidSG = ArrangeProxy and ArrangeProxy.SwapRaidSubgroup or SwapRaidSubgroup
--local GetRaidRosterInfo = _G["GetRaidRosterInfo"]
local function L_InCombatLockdown()
	local x = InCombatLockdown()

	if ArrangeProxy and ArrangeProxy.Ready() then
		x = false
	end

	return x
end

function GrOM.TestLoaded()
	L_SetRaidSG = SetRaidSubgroup
	L_SwapRaidSG = SwapRaidSubgroup
	--GetRaidRosterInfo = _G["GetRaidRosterInfo"]
end

local loc = GrOM.Localization

local roleIndex = {
	["TANK"] = 1,
	["HEALER"] = 2,
	["MELEE_DPS"] = 3,
	["RANGE_DPS"] = 4,
	["DAMAGER"] = 4,
	["NONE"] = 4
}

local indexToRole = {"TANK", "HEALER", "MELEE_DPS", "RANGE_DPS"}

local specIndex = {
	["1:1"] = 3, -- warrior
	["1:2"] = 3,
	["1:3"] = 1,
	["2:1"] = 2, -- paladin
	["2:2"] = 1,
	["2:3"] = 3,
	["3:1"] = 4, -- hunter
	["3:2"] = 4,
	["3:3"] = 4,
	["4:1"] = 3, -- rogue
	["4:2"] = 3,
	["4:3"] = 3,
	["5:1"] = 2, -- priest
	["5:2"] = 2,
	["5:3"] = 4,
	["6:1"] = 1, -- deathknight
	["6:2"] = 3,
	["6:3"] = 3,
	["7:1"] = 4, -- shaman
	["7:2"] = 3,
	["7:3"] = 2,
	["8:1"] = 4, -- mage
	["8:2"] = 4,
	["8:3"] = 4,
	["9:1"] = 4, -- warlock
	["9:2"] = 4,
	["9:3"] = 4,
	["10:1"] = 1, -- monk
	["10:2"] = 2,
	["10:3"] = 3,
	["11:1"] = 4, -- druid
	["11:2"] = 3,
	["11:3"] = 2,
	["11:4"] = 1,
}
--[[{
	[62]  = 4,
	[63]  = 4,
	[64]  = 4,
	[65]  = 2,
	[66]  = 1,
	[70]  = 3,
	[71]  = 3,
	[72]  = 3,
	[73]  = 1,
	[102] = 4,
	[103] = 3,
	[104] = 1,
	[105] = 2,
	[250] = 1,
	[251] = 3,
	[252] = 3,
	[253] = 4,
	[254] = 4,
	[255] = 4,
	[256] = 2,
	[257] = 2,
	[258] = 4,
	[259] = 3,
	[260] = 3,
	[261] = 3,
	[262] = 4,
	[263] = 3,
	[264] = 2,
	[265] = 4,
	[266] = 4,
	[267] = 4,
	[268] = 1,
	[269] = 3,
	[270] = 2
}]]

--[[specIndex[myclass]

roleIndex]]

local currentRaidGroupIndexByName = {}
local currentRaidGroupRolesByIndex = {}

--list of subgroups by raid index
local currentRaidGroupPlacement = {}
local optimalRaidGroupPlacement = {}

--used for the "start over" button if an auto-arrange is forced to stop (someone leaves the raid etc)
local lastAction = {false, ""} -- [1] is true if the last action was a raid restore, and if so, [2] will be the name of the saved raid
local outdatedCheck = false
local delayedActionInProgress = false
local lastRaidSetup = {}
local groupFullErr = false
local resetErrorTimer = 0
local ignoredExcluded = false
local movementQueue = {}
local lockedIDs = {}
local lockedGroups = {}
local queuedSetsByGroup = {5,5,5,5,5,5,5,5}
local currentScanIsAuto = false
local currentExecutionOptimalPlacementByName = nil
local talentsOutdated = false
local lastTemplate = nil
local currentScanTalentNumCheckFailureCounter = 0
local raidInspectionIndex = 1

local function cout(msg)
	local outputFrame = GrOM.consoleFrame or DEFAULT_CHAT_FRAME or ChatFrame1
	if(outputFrame and not GrOM_Vars.Silent) then
		outputFrame:AddMessage(loc.outputprefix .. msg, 0.0, 1.0, 0.0, 1.0)
	end
end

local function dout(msg, verbose) --verbose i.e. log only
	local outputFrame = GrOM.consoleFrame or DEFAULT_CHAT_FRAME or ChatFrame1
	if outputFrame and GrOM_Vars.debugOutput and not verbose then
		outputFrame:AddMessage("GOM DEBUG: " .. msg, 1.0, 0.0, 0.0, 1.0)
	end

	if GrOM.saveDebugOutput then
		if not GrOM.debugCachingOn then
			GrOM.debugCachingOn = true
			GrOM_Vars.debugCache = {}
		end

		GrOM_Vars.debugCache[#GrOM_Vars.debugCache + 1] = msg
	end
end

local function eout(msg)
	local outputFrame = GrOM.consoleFrame or DEFAULT_CHAT_FRAME or ChatFrame1
	if outputFrame then
		outputFrame:AddMessage("GOM ERROR: " .. msg, 1.0, 0.0, 0.0, 1.0)
	end
end

local function ValidateCheckBoxes()
	if GrOM.guiUnloaded then return end
	GOMaticOverrideRemote:SetChecked(GrOM_Vars.LocalOverridesRemote)
	GOMaticSilence:SetChecked(GrOM_Vars.Silent)
	GOMaticSure:SetChecked(GrOM_Vars.AlwaysSure)
	GOMaticExcludeSaves:SetChecked(GrOM_Vars.excludeSaves)
	GOMaticContinuousScan:SetChecked(GrOM_Vars.enableContinuousScan)
	GOMaticSyncOut:SetChecked(GrOM_Vars.syncOut)
	GOMaticIgnoreDead:SetChecked(GrOM_Vars.ignoreDead)
	GOMaticIgnoreOffline:SetChecked(GrOM_Vars.ignoreOffline)
	GOMaticOnlyDoMemberAddActionsAsLeaderCheck:SetChecked(GrOM_Vars.onlyDoRaidMemberAddActionsIfLeader)
end

local function GetPVEorPVPUName(unit)
	local name, realm = UnitName(unit)

	if not name then
		return nil
	end

	if realm then
		name = name .. "-" .. realm
	end

	return name
end

--ty to Aquendyn for this function
local function GetCmd(msg)
	if msg then
 		local a,b,c=strfind(msg, "(%S+)");
 		if a then
 			return c, strsub(msg, b+2);
 		else
 			return "";
 		end
 	end
end

local function tremovebyval(tab, val)
	for k,v in pairs(tab) do
		if(v==val) then
			table.remove(tab, k)
			return true
		end
	end
	return false
end

local function BuildIndexByNameTable()
	if type(currentRaidGroupIndexByName) == "table" then
		wipe(currentRaidGroupIndexByName)
	end
	currentRaidGroupIndexByName = {}

	for i=1, 40 do
		currentRaidGroupIndexByName[GetRaidRosterInfo(i) or "-"]=i
	end
end

local function FindKnownPercent()
	local x = GetNumGroupMembers()

	if x < 2 then
		return 100
	end

	BuildIndexByNameTable()

	local y = 0

	for k, v in pairs(GrOM_Vars.rolesByNameCache) do
		if currentRaidGroupIndexByName[k] and k ~= UnitName("player") then
			y = y + 1
		end
	end	

	if y < 0 then
		y = 0
	end

	local kPer = floor((y + 1) / x * 100)

	dout(("Raid talents are %s%% known."):format(tostring(kPer)))

	return kPer
end

local PingReplies = {}

local function PingFrame_OnEvent(self, event, arg1, arg2, arg3, arg4)
	if arg3 == "WHISPER" then
		if arg1 == "GOMPINGR" then
			table.insert(PingReplies, arg4)
			if arg2 ~= GrOM.Version_String then
				cout(arg4 .. ": " .. arg2 .. "**")
			else
				cout(arg4 .. ": " .. arg2)
			end
		end
	end
end

local PingFrameDelay = 3
local PingFrameStartTime = 0

local function PingFrame_OnUpdate()
	if PingFrameStartTime + PingFrameDelay < time() then
		if GetNumGroupMembers() > 1 then
			for i=1, 40 do
				local n = (GetRaidRosterInfo(i))
				if n then
					if not tremovebyval(PingReplies, n) then
						cout(n .. ": " .. loc.notinstalled)
					end
				end
			end
		end
		delayedActionInProgress = false
		GrOM.UpdateButtons()
		GOMatic_PingFrame:UnregisterEvent("CHAT_MSG_ADDON")
		GOMatic_PingFrame:SetScript("OnEvent", nil)
		GOMatic_PingFrame:SetScript("OnUpdate", nil)
	end
end

local function CreatePingFrame()
	return
	--[[PingReplies = {UnitName("player")}

	PingFrameStartTime = time()

	delayedActionInProgress = true
	GrOM.UpdateButtons()
	local f = CreateFrame("Frame","GOMatic_PingFrame")
	f:SetScript("OnEvent", PingFrame_OnEvent)
	f:SetScript("OnUpdate", PingFrame_OnUpdate)
	f:RegisterEvent("CHAT_MSG_ADDON")
	f:Show() ]]
end

local function FindNamedRMInfo(nameMoveTo, idMoving)
	local playersPerGroup, destGroup, idMoveTo = {0,0,0,0,0,0,0,0}, nil, nil
	local numbered = nil
	
	nameMoveTo = tonumber(nameMoveTo) or nameMoveTo
	
	if type(nameMoveTo) == "number" then
		if nameMoveTo > 8 or nameMoveTo < 1 then return end
		destGroup = nameMoveTo
		numbered = nameMoveTo
	end
	
	if GetNumGroupMembers() > 1 then
		for i=1,40 do
			local cN,_,cG = GetRaidRosterInfo(i)
			if cG then
				playersPerGroup[cG] = playersPerGroup[cG] + 1
			end
			if (not numbered) and nameMoveTo == cN then	
				destGroup = cG
				idMoveTo = i
			end
		end
		
		if not destGroup then
			return false
		end
		
		if playersPerGroup[destGroup] > 4 then
			if numbered then idMoveTo = true end
			return idMoveTo, destGroup, numbered
		else
			return nil, destGroup, numbered
		end
	end	
end

local function FindMemberID(n)
	if GetNumGroupMembers() > 1 then
		for i=1, 40 do
			if n == GetRaidRosterInfo(i) then		
				return i
			end
		end
	end

	return false
end

local function CancelIfAuto()
	if currentScanIsAuto then
		GrOM.Cancel()
	end
end

function GrOM.DoAutoAutoArrange(n)
	local t = GrOM_Vars.autoAutoArrange
	if t and t[n] then
		--dout(("Reached raid size level %s and auto-auto-arrange is enabled...starting."):format(tostring(n)))
		CancelIfAuto()
		if delayedActionInProgress then
			dout("Not doing auto-auto-arrange because an action was already in progress.")
			return
		end
		
		lastAction = {false, ""}
		lastTemplate = GrOM_Vars.userTemplateToUse or "GrOM_DEFAULT_TEMPLATE"
		GrOM_Vars.userTemplateToUse = t[n]
		if GrOM_Vars.userTemplateToUse == "GrOM_DEFAULT_TEMPLATE" then GrOM_Vars.userTemplateToUse = nil end
		GrOM.StartArrange()		
	end
end

function GrOM.PurgeTalents(v)
	dout(loc.talentsupdated:format(v))
end

local function HandleWildcards(cmd)
	if not cmd then return end

	if cmd:find("!t") then
		return GetPVEorPVPUName("target")
	end
	if cmd:find("!p") then
		return UnitName("player")
	end
	if cmd:find("!f") then
		return GetPVEorPVPUName("focus")
	end
	
	return cmd
end

function GrOM.RSCommandHandler(msg)
	if L_InCombatLockdown() then
		return
	end

	local cmd, sc = GetCmd(msg)
	
	cmd = HandleWildcards(cmd)
	sc = HandleWildcards(sc)

	if not (cmd and sc) then
		return
	end

	currentRaidGroupIndexByName = {}
	BuildIndexByNameTable()

	local i1, i2 = currentRaidGroupIndexByName[cmd], currentRaidGroupIndexByName[sc]

	if i1 and i2 then
		L_SwapRaidSG(i1, i2)
	end
end

function GrOM.RGSCommandHandler(msg)
	if L_InCombatLockdown() then
		return
	end

	local cmd, sc = GetCmd(msg)

	if not (cmd and sc) then
		return
	end

	cmd = tonumber(cmd)
	sc = tonumber(sc)

	if not (cmd and sc) then
		return
	end

	if cmd == sc then
		return
	end

	if cmd > 8 or cmd < 1 or sc > 8 or sc < 1 then
		return
	end

	local g1, g2 = {}, {}

	for i = 1, 40 do
		local n,_,g = GetRaidRosterInfo(i)

		if n and g then
			if g == cmd then
				table.insert(g1, i)
			elseif g == sc then
				table.insert(g2, i)
			end
		end
	end

	for j = 1, 5 do
		if g1[j] and g2[j] then
			L_SwapRaidSG(g1[j], g2[j])
		elseif g1[j] then
			L_SetRaidSG(g1[j], sc)
		elseif g2[j] then
			L_SetRaidSG(g2[j], cmd)
		end
	end
end

function GrOM.RGMCommandHandler(msg)
	if L_InCombatLockdown() then
		return
	end

	local cmd, sc = GetCmd(msg)

	if not (cmd and sc) then
		return
	end

	cmd = tonumber(cmd)
	sc = tonumber(sc)

	if not (cmd and sc) then
		return
	end

	if cmd == sc then
		return
	end

	if cmd > 8 or cmd < 1 or sc > 8 or sc < 1 then
		return
	end
	
	local g1, g2 = {}, {}

	for i = 1, 40 do
		local n,_,g = GetRaidRosterInfo(i)

		if n and g then
			if g == cmd then
				table.insert(g1, i)
			elseif g == sc then
				table.insert(g2, i)
			end
		end
	end
	
	for j = 1, 5 do
		if g1[j] then
			L_SetRaidSG(g1[j], sc)
		end
	end
end

local function GetRandomIDFromGroup(sc, id)
	for i=1, 40 do
		if id ~= i then
			local _,_,g = GetRaidRosterInfo(i)
			if g == sc then
				return i
			end
		end
	end
end

local function GetFirstIDFromGroup(n)
	for i=1, 40 do
		local _,_,g = GetRaidRosterInfo(i)
		if g == n then
			return i
		end
	end
end

local function GetSCFromName(sc, idMoving)
	local force, id, numbered
	force, sc = sc:match("(%@?)(.+)")
	sc = HandleWildcards(sc)
	id, sc, numbered = FindNamedRMInfo(sc)

	if id and numbered and force and force == "@" then
		id = GetFirstIDFromGroup(numbered)
		L_SwapRaidSG(idMoving,id)
		return -1
	end
	
	if id and force and force == "@" then
		id = GetRandomIDFromGroup(sc, id)
		L_SwapRaidSG(idMoving,id)
		return -1
	end
	
	return sc
end

function GrOM.RMCommandHandler(msg)
	if L_InCombatLockdown() then
		return
	end	
	
	local cmd, sc = GetCmd(msg)
	
	cmd = HandleWildcards(cmd)

	sc = tonumber(sc) or sc

	BuildIndexByNameTable()
	
	local i = currentRaidGroupIndexByName[cmd]
	if not i then return end
	
	if type(sc) == "string" then
		sc = GetSCFromName(sc, i)
	end
	
	if not (cmd and sc) then
		return
	end

	if sc < 1 or sc > 8 then
		return
	end		

	L_SetRaidSG(i, sc)	
end

function GrOM.Ping()
	return--[[

	CancelIfAuto()

	if delayedActionInProgress then
		cout(loc.pleasewaiterr)
		return
	end

	CreatePingFrame()
	SendAddonMessage("GOMPING", tostring(GrOM.Version), "RAID")]]
end

function GrOM.Cancel()
	local somethingToCancel = delayedActionInProgress
	delayedActionInProgress = false
	GrOM.UpdateButtons()
	local x = currentScanIsAuto
	currentScanIsAuto = false

	if GOMatic_ArrangementFrame then
		GOMatic_ArrangementFrame:SetScript("OnUpdate", nil)
		GOMatic_ArrangementFrame:SetScript("OnEvent", nil)
	end
	if GOMatic_TalentRequestFrame then
		GOMatic_TalentRequestFrame:SetScript("OnEvent", nil)
		GOMatic_TalentRequestFrame:UnregisterEvent("CHAT_MSG_ADDON")
		GOMatic_TalentRequestFrame:UnregisterEvent("INSPECT_READY")
		GOMatic_TalentRequestFrame:SetScript("OnUpdate", nil)
	end

	if (not x) and somethingToCancel then
		cout(loc.cancelled)
	end
end

local function ReparentMe(self)
	local newP = GrOM_Vars.alwaysActive and UIParent or RaidFrame
	self:SetParent(newP)
end

function GrOM.SlashCommandHandler(msg)
	local cmd, sc = GetCmd(msg)

	if cmd and string.lower(cmd) == loc.activecmd then
		GrOM_Vars.alwaysActive = not GrOM_Vars.alwaysActive
		cout(GrOM_Vars.alwaysActive and loc.alwaysactiveon or loc.alwaysactiveoff)
		ReparentMe(GOMatic)
		if GrOM_Vars.ShowGUI then
			GOMatic:Show()
		end
		if (not GrOM_Vars.alwaysActive) and GetNumGroupMembers() < 2 then
			GOMatic:Hide()
		end
		return
	elseif GetNumGroupMembers() < 2 and (not GrOM_Vars.alwaysActive) then
		eout(loc.nopointerr)
		return
	end

	if cmd and string.lower(cmd) == loc.pingcmd then
		GrOM.Ping()
	elseif cmd and string.lower(cmd) == "nuke" then
		StaticPopup_Show("GOMatic_DO_NUKE")
	elseif cmd and string.lower(cmd) == "fading" then
		GrOM_Vars.disableFading = not GrOM_Vars.disableFading
		cout(loc.fadingtoggle .. tostring(not GrOM_Vars.disableFading))
	elseif cmd and string.lower(cmd) == "addonconflict" then
		message(GrOM.debug.talentCollection.lastStackTrace)
	--[[elseif cmd and string.lower(cmd) == "testmode" then
		GrOM.EnableTestMode()]]
	elseif cmd and string.lower(cmd) == "debug" then
		GrOM_Vars.debugOutput = not GrOM_Vars.debugOutput
		dout("GOM will output debugging info.")
	elseif cmd and string.lower(cmd) == loc.secondarycmd then
		GrOM_Vars.cacheSecondaryTalents = not GrOM_Vars.cacheSecondaryTalents
		cout(loc.secondaryswap .. tostring(GrOM_Vars.cacheSecondaryTalents))
	elseif cmd == "roles" then
		if sc == "" then
			sc = nil
		end
		GrOM.PrintRoles(sc)
	elseif cmd and string.lower(cmd) == loc.guicmd then
		GrOM_Vars.ShowGUI = not GrOM_Vars.ShowGUI

		if GrOM_Vars.ShowGUI then
			cout(loc.guishown)
			if GetNumGroupMembers() > 1 or GrOM_Vars.alwaysActive then
				GOMatic:Show()
				GrOM.UpdateButtons()
				if not (GrOM_Vars.alwaysActive or RaidFrame:IsVisible()) then
					GOMatic:Hide()
				end
			end
		else
			cout(loc.guihidden)
			GOMatic:Hide()
		end
	elseif cmd and string.lower(cmd) == loc.silentcmd then
		GrOM_Vars.Silent = not GrOM_Vars.Silent
		cout(loc.unsilenced)
	elseif cmd and string.lower(cmd) == loc.surecmd then
		GrOM_Vars.AlwaysSure = not GrOM_Vars.AlwaysSure
		cout(GrOM_Vars.AlwaysSure and loc.sureon or loc.sureoff)
	--[[elseif cmd and string.lower(cmd) == loc.talentscmd then
		GrOM_Vars.disableTalentRequest = not GrOM_Vars.disableTalentRequest
		cout(GrOM_Vars.disableTalentRequest and loc.talentsoff or loc.talentson)]]
	elseif cmd and string.lower(cmd) == loc.cancelcmd then
		GrOM.Cancel()
	elseif cmd and string.lower(cmd) == loc.savecmd then
		if delayedActionInProgress then
			cout(loc.pleasewaiterr)
			return
		end
		if sc and sc ~= "" then
			if GrOM_Vars.SavedRaidLayouts[sc] then
				GrOM.SaveName = sc
				StaticPopup_Show("GOMatic_DO_SAVE", sc)
			else
				GrOM.SaveRaid(sc)
			end
		else
			eout(loc.mustenternameerr)
		end
	elseif cmd and string.lower(cmd) == loc.restorecmd then
		CancelIfAuto()
		
		if delayedActionInProgress then
			cout(loc.pleasewaiterr)
			return
		end
		if sc then
			local n = GrOM_Vars.SavedRaidLayouts[sc]
			if n then
				lastAction = {true, sc}
				GrOM.RestoreRaid(n)
			else
				eout(loc.mustenternameerr)
				eout(loc.thesearegoodnames)
				foreach(GrOM_Vars.SavedRaidLayouts, function(k,v) eout(k) end)
			end
		else
			eout(loc.mustenternameerr)
			cout(loc.thesearegoodnames)
			foreach(GrOM_Vars.SavedRaidLayouts, function(k,v) cout(k) end)
		end
	elseif cmd and string.lower(cmd) == loc.autocmd then
		CancelIfAuto()
		
		if delayedActionInProgress then
			cout(loc.pleasewaiterr)
			return
		end
		lastAction = {false, ""}
		GrOM.StartArrange()
	else
		cout(loc.help)
	end

	ValidateCheckBoxes()
end

function GrOM.AutoClick()
	CancelIfAuto()

	if delayedActionInProgress then
		cout(loc.pleasewaiterr)
		return
	end
	lastAction = {false, ""}
	GrOM.StartArrange()
end

function GrOM.RolesToString(roles)
	if not roles then return end

	local msg = "{"

	for i=1, 3 do
		local rn = indexToRole[i]
		local x = (roles[i]) and rn.."=true, " or rn.."=false, "
		msg = msg .. x
	end
	local rn = indexToRole[4]
	local x = (roles[4]) and rn.."=true}" or rn.."=false}"
	msg = msg .. x

	return msg
end

local function GetMyRoles(u, isPrimary)
	if u then dout(u) else dout("xxxu") end

	if not u then u = "player" end

	local isInspect = not (UnitIsUnit(u,"player"))
	local talentGroup
	if isPrimary == true then
		talentGroup = 1
	elseif isPrimary == false then
		talentGroup = 2
	else
		talentGroup = GetActiveTalentGroup(isInspect)
	end
	
	if u == "raid0" then dout("x") return false end

	--[[local mySpec
	mySpec = GetInspectSpecialization(u)
	
	if not (mySpec and specIndex[mySpec]) then return false end]]
	local tabId = GetPrimaryTalentTree(isInspect,false,talentGroup)
	if not tabId then return false end
	local _, classId = UnitClassBase(u)
	local specKey = format("%d:%d",classId,tabId)
	if not specIndex[specKey] then return false end
	local roles = {false, false, false, false}
	--roles[specIndex[mySpec]] = true
	if specKey == "11:2" then -- feral
		local _, _, _, _, thickHide, maxRank = GetTalentInfo(2, 1 ,isInspect, talentGroup)
		if thickHide and thickHide > 0 then
			specKey = "11:4" -- tank
		end
	end
	roles[specIndex[specKey]] = true
	return roles
end

local function UpdateMyProfile()
	local myName = UnitName("player") .. "-" .. GetRealmName()

	if not GrOM_Vars.syncOut then
		GrOM_G_Vars.profiles[myName] = nil
		return
	end

	local p = {
		rolesByNameCache = GrOM_Vars.rolesByNameCache,
		SavedRaidLayouts = GrOM_Vars.SavedRaidLayouts,
		MVPs = GrOM_Vars.MVPs,
		ezTemplates = GrOM_Vars.ezTemplates,
		syncVersion = curSaveVersion
	}

	GrOM_G_Vars.profiles[myName] = p
end

local function DoSync(name, toSync)
	local syncInto = GrOM_Vars[name]
	local count = 0

	if not syncInto then
		return count
	end

	if type(toSync) ~= "table" then
		return count
	end

	if name == "ezTemplates" then
		if not GrOM.guiUnloaded then
			for i = 1, #toSync do
				if not GrOM.FindEZTemplate(toSync[i][1]) then
					GrOM_Vars.ezTemplates[#GrOM_Vars.ezTemplates + 1] = CopyTable(toSync[i])
					count = count + 1
				end
			end
		end
	elseif name == "MVPs" then
		if not GrOM.guiUnloaded then
			for i = 1, #toSync do
				if not GrOM.AddMVP(toSync[i]) then
					count = count + 1
				end
			end
		end
	else
		for k, v in pairs(toSync) do
			if not syncInto[k] then
				syncInto[k] = v
				count = count + 1
			end
		end
	end
	return count
end

local function SyncProfiles()
	local myName = UnitName("player") .. "-" .. GetRealmName()
	GrOM_G_Vars.profiles[myName] = nil
	local toSync = GrOM_Vars.syncProfiles
	local whatToSync = GrOM_Vars.syncSettings

	local count = 0
	for k1 in pairs(toSync) do
		local data = GrOM_G_Vars.profiles[k1]
		if data then
			if data.syncVersion and data.syncVersion == curSaveVersion then
				for k, v in pairs(whatToSync) do
					if v then
						if data[k] then
							count = count + DoSync(k, data[k])
						end
					end
				end
			end
		end
	end

	return count
end

local function UpdateScrollPanes(noSync)
	if GrOM.guiUnloaded then return end
	GrOM.UpdateMVPPane()
	GOMaticMVPScrollFrame:Hide()
	GrOM.UpdateSavesPane()
	GOMaticSavesScrollFrame:Hide()
	GrOM.UpdateEZTemplatePane()
	GOMaticEZTemplateScrollFrame:Hide()
	if not noSync then
		GrOM.UpdateSyncPane()
		GOMaticSyncScrollFrame:Hide()
	end
end

GrOM.SetTemplateAndAA = function(template)
	GrOM_Vars.userTemplateToUse = template
	
	local x, y = GrOM.GetCurrentTemplate()
	UIDropDownMenu_SetSelectedValue(GOMaticTemplateMenu, x)
	GOMaticTemplateMenuText:SetText(y)
	
	GrOM.AutoClick()
end

function GrOM.SyncNow()
	local x = SyncProfiles()

	cout(loc.synced:format(x))
	UpdateScrollPanes(true)
end

local function UpdateClassByNameTable()
	for i = 1, 40 do
		local n = GetPVEorPVPUName("raid"..i)
		if n then
			GrOM_Vars.classByNameCache[n] = select(2, UnitClass("raid"..i))
		end
	end
end

GrOM.myName = "GOM:"

function GrOM.OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		self:UnregisterEvent("VARIABLES_LOADED")
		if GetNumGroupMembers() < 2 or not GrOM_Vars.ShowGUI then
			self:Hide()
		end
		hooksecurefunc("ConvertToParty", function()
			GrOM_Vars.oncePerRaid = {}			
			currentRaidGroupRolesByIndex = {}
			currentRaidGroupPlacement = {}
			currentRaidGroupIndexByName = {}
		end)
		--[[hooksecurefunc("NotifyInspect", function()   --make sure that noone else calls notifyinspect between the time we do and receiving talents
			tempLastTrace = debugstack()
			GrOM.InspectTainted = true
		end)]]
		UpdateVars()
		SyncProfiles()
		if type(GrOM_G_Vars.loadScript) == "string" then
			dout("OnLoad script exists, running.")
			if not pcall(RunScript, GrOM_G_Vars.loadScript) then
				dout("OnLoad script generated an error.")
			end
		end
		ReparentMe(self)
		ValidateCheckBoxes()
		GrOM.UpdateButtons()
		if not GrOM.guiUnloaded then
			GOMaticThrottleSlider:SetValue(GrOM_Vars.autoThrottle)
			GrOM.InitializeScrollFrame(GOMaticMVPScrollFrame)
			GrOM.InitializeScrollFrame(GOMaticSavesScrollFrame)
			GrOM.InitializeScrollFrame(GOMaticEZTemplateScrollFrame)
			GrOM.InitializeScrollFrame(GOMaticSyncScrollFrame)
		end
		UpdateScrollPanes()
		--if GrOM_Vars.enableContinuousScan then
			GOMatic_Auto:SetScript("OnUpdate", GrOM.OnUpdate)
		--end
		if not GrOM.guiUnloaded then
			local overrideBlizPositioning = CreateFrame("Frame")
			local srsly = time()
			overrideBlizPositioning:SetScript("OnUpdate", function(self)
				if time() - srsly > 3 then
					--GOMaticMore:Hide()
					--GOMaticMore:Disable()
					DropDownList1.numButtons = 0
					UIDropDownMenu_Initialize(GOMaticDropDown, GOMaticDropdown_Initialize)
					GOMatic:ClearAllPoints()
					--local s = GOMaticAnchorFrame:GetEffectiveScale()
					GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", (GrOM_Vars.pos[1] or 500), (GrOM_Vars.pos[2] or 500))
					if GrOM_Vars.alwaysActive then
						if GrOM_Vars.ShowGUI then
							GOMatic:Show()
						end
					end
					self:SetScript("OnUpdate", nil)
				end
			end)
		end
		dout(GrOM.Version_String .. loc.loaded)
	elseif event == "PLAYER_REGEN_DISABLED" then
		GrOM.UpdateButtons(1)
	elseif event == "PLAYER_REGEN_ENABLED" then
		GrOM.UpdateButtons(0)
	elseif event == "ROLE_CHANGED_INFORM" then
		local cPl, cB, oR, nR = ...
		if cPl == cB then
			GrOM_Vars.rolesByNameCache[cPl] = nil
			GrOM.AutoScanNow()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		local myName = UnitName("player") .. "-" .. GetRealmName()
		if GrOM_G_Vars.profiles and GrOM_G_Vars.profiles[myName] then
 			wipe(GrOM_G_Vars.profiles[myName])
		end
		GrOM_G_Vars.profiles[myName] = nil
	elseif event == "PLAYER_LEAVING_WORLD" then
		do
			local ex = GrOM_Vars.expanded			
			UpdateMyProfile()
			GrOM.CloseExtrasPane(true)
			_,_,_,GrOM_Vars.pos[1], GrOM_Vars.pos[2] = self:GetPoint()
			GrOM_Vars.expanded = ex
		end
	elseif event == "RAID_ROSTER_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
		--SendAddonMessage("GOMVER", tostring(GrOM.Version), "RAID")
		if not GrOM.guiUnloaded then
			GOMaticTitleText2:SetText(loc.myName2:format(FindKnownPercent()))
		end
		if not InCombatLockdown() then
			UpdateClassByNameTable()
		end
		if not GrOM_Vars.alwaysActive then
			if GetNumGroupMembers() < 2 then
				self:Hide()
			else
				self:Show()
			end
		end
		if not GrOM_Vars.ShowGUI then
			self:Hide()
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local arg1 = ...
		local nameAdded = arg1:match(ERR_RAID_MEMBER_ADDED_S:format("(.+)"))
		if nameAdded then
			if GrOM_Vars.onlyDoRaidMemberAddActionsIfLeader and not UnitIsGroupLeader("player") then return end
		
			--Size-based auto-auto-arrange
			local n = GetNumGroupMembers()
			local already
			if n >= GrOM.raidSize1 then				
				already = GrOM_Vars.oncePerRaid.reached10
				GrOM_Vars.oncePerRaid.reached10 = true
				if n >= GrOM.raidSize2 then
					already = GrOM_Vars.oncePerRaid.reached25
					GrOM_Vars.oncePerRaid.reached25 = true
					if n >= GrOM.raidSize3 then
						already = GrOM_Vars.oncePerRaid.reached40
						GrOM_Vars.oncePerRaid.reached40 = true
						if not already then GrOM.DoAutoAutoArrange(3) return end
					else
						if not already then GrOM.DoAutoAutoArrange(2) return end
					end
				else
					if not already then GrOM.DoAutoAutoArrange(1) return end
				end
			end
			
			--Auto-place
			GrOM.DoAutoPlacement(nameAdded)			
		elseif arg1:match(ERR_RAID_YOU_LEFT) then
			GrOM_Vars.oncePerRaid = {}			
			currentRaidGroupRolesByIndex = {}
			currentRaidGroupPlacement = {}
			currentRaidGroupIndexByName = {}
		end			
	--[[elseif event == "CHAT_MSG_ADDON" then
		local arg1, arg2, arg3, arg4 = ...

		if arg3 == "RAID" then
			if arg1 == "GOMPING" then
				SendAddonMessage("GOMPINGR", GrOM.Version_String, "WHISPER", arg4)
			elseif arg1 == "GOMVER" then
				if tonumber(arg2) and tonumber(arg2) > GrOM.Version and GrOM.Version >= 1 then
					if not (outdatedCheck or InCombatLockdown() ) then
						StaticPopup_Show("GOMatic_OUTDATED")
						outdatedCheck = true
					end
				end
			elseif arg1 == "GOMTALENT" then
				local myRoles = GetMyRoles()
				if myRoles then
					SendAddonMessage("GOMTALENTR", GrOM.RolesToString(myRoles), "WHISPER", arg4)
				else
					cout(loc.talentserr)
				end
			end
		end]]
	end
end

function GrOM.PrintRoles(x)
	cout(GrOM.RolesToString(GetMyRoles(x)))
end

function GrOM.OnLoad(self)
	CreateFrame("Frame", "GOMatic_Auto")

	StaticPopupDialogs["GOMatic_DO_ARRANGE"] = {
		text = loc.doarrangedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.CreateArrangementFrame()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_ERROR_TOOMANYFAILEDMOVES"] = {
		text = loc.toomanyfailedmovesdialogtext,
		button1 = loc.buttonok,
		timeout = 30,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_DO_NUKE"] = {
		text = loc.donukedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.Cleanup()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_DO_SAVE"] = {
		text = loc.dosavedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.SaveRaid(GrOM.SaveName)
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_DO_RENAME"] = {
		text = loc.dosavedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.RenameSave(GrOM.SaveName, true)
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_DO_RENAME_EZTEMPLATE"] = {
		text = loc.dosavedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.RenameEZTemplate(GrOM.SaveName, true)
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_DO_CUSTOM_SAVE"] = {
		text = loc.dosavedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.SaveCustomRaid(true)
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_AUTO_ABORT"] = {
		text = loc.autoabortdialogtext,
		button1 = loc.buttonstartover,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.StartOver()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_DELETE_ALL_SAVES"] = {
		text = loc.deletealldialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.DeleteAllSavedRaids()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMATIC_CLEAR_MVP"] = {
		text = loc.deleteallmvpsdialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		OnAccept = function()
			GrOM.ClearMVPs()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_OUTDATED"] = {
		text = loc.addonoutdateddialogtext,
		button1 = loc.buttonok,
		timeout = 30,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMatic_NEW_SAVE"] = {
		text = loc.newsavedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		hasEditBox = 1,
		maxLetters = 15,
		OnShow = function(self)
			local editBox = self.editBox
			editBox:SetText("")
			editBox:SetFocus()
		end,
		OnAccept = function(self)
			local editBox = self.editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GOMaticDropdown_DoSaveMenuItem(nil, name)
		end,
		EditBoxOnEnterPressed = function(self)
			local editBox = self:GetParent().editBox -- same as just self?
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GOMaticDropdown_DoSaveMenuItem(nil, name)
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMATIC_RENAME_SAVE"] = {
		text = loc.renamesavedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		hasEditBox = 1,
		maxLetters = 15,
		OnShow = function(self)
			local editBox = self.editBox
			editBox:SetText("")
			editBox:SetFocus()
		end,
		OnAccept = function(self)
			local editBox = self.editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GrOM.RenameSave(name)
		end,
		EditBoxOnEnterPressed = function(self)
			local editBox = self:GetParent().editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GrOM.RenameSave(name)
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMATIC_RENAME_EZTEMPLATE"] = {
		text = loc.renameeztemplatedialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		hasEditBox = 1,
		maxLetters = 20,
		OnShow = function(self)
			local editBox = self.editBox
			editBox:SetText("")
			editBox:SetFocus()
		end,
		OnAccept = function(self)
			local editBox = self.editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GrOM.RenameEZTemplate(name)
		end,
		EditBoxOnEnterPressed = function(self)
			local editBox = self:GetParent().editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GrOM.RenameEZTemplate(name)
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	StaticPopupDialogs["GOMATIC_ADD_MVP"] = {
		text = loc.addmvpdialogtext,
		button1 = loc.buttonok,
		button2 = loc.buttoncancel,
		hasEditBox = 1,
		maxLetters = 20,
		OnShow = function(self)
			local editBox = self.editBox
			editBox:SetText(GetPVEorPVPUName("target") or "")
			editBox:SetFocus()
		end,
		OnAccept = function(self)
			local editBox = self.editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GrOM.AddMVP(name)
		end,
		EditBoxOnEnterPressed = function(self)
			local editBox = self:GetParent().editBox
			local name = editBox:GetText()
			name = string.gsub(name, " ", "")
			if not name or name == "" then
				cout(loc.mustenternameerr)
				return
			end
			GrOM.AddMVP(name)
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

	if not GrOM.guiUnloaded then
		GOMaticSave:SetText(loc.savebutton)
		GOMaticAuto:SetText(loc.autobutton)
		GOMaticHide:SetText(loc.hidebutton)
		GOMaticMore:SetText(loc.morebutton)
		GOMaticLess:SetText(loc.lessbutton)
		GOMaticPing:SetText(loc.pingbutton)
		GOMaticCancel:SetText(loc.buttoncancel)
		GOMaticAddMVP:SetText(loc.addmvpbutton)
		GOMaticRestore:SetText(loc.restorebutton)
		GOMaticSyncNow:SetText(loc.syncnowbutton)
		GOMaticSureText:SetText(loc.surebutton)
		GOMaticEditSave:SetText(loc.editsavebutton)
		GOMaticDeleteMVP:SetText(loc.delmvpbutton)
		GOMaticNukeCache:SetText(loc.nukebutton)
		GOMaticDemoteMVP:SetText(loc.demotemvpbutton)
		GOMaticTitleText:SetText(GrOM.myName)
		GOMaticPromoteMVP:SetText(loc.promotemvpbutton)
		GOMaticDeleteSave:SetText(loc.delsavebutton)
		GOMaticRenameSave:SetText(loc.renamesavebutton)
		GOMaticSaveCustom:SetText(loc.savebutton)
		GOMaticSyncOutText:SetText(loc.enablesyncout)
		GOMaticExcludeText:SetText(loc.excludetext)
		GOMaticSilenceText:SetText(loc.silencebutton)
		GOMaticNewBlankSave:SetText(loc.newblankbutton)
		GOMaticThrottleText:SetText(loc.throttletext:format(GrOM_Vars.autoThrottle))
		GOMaticTemplateText:SetText(loc.templatetext)
		GOMaticCancelCustom:SetText(loc.buttoncancel)
		GOMaticSyncPaneText:SetText(loc.syncpanetext)
		GOMaticMinLevelText:SetText(loc.ignoreleveltext)
		GOMaticAddEZTemplate:SetText(loc.addmvpbutton)		
		GOMaticDeleteAllMVPs:SetText(loc.dellallmvpbutton)
		GOMaticEditSavesText:SetText(loc.editsavestext)
		GOMaticEditEZTemplate:SetText(loc.editeztemplatebutton)
		GOMaticIgnoreDeadText:SetText(loc.ignoredeadbutton)
		GOMaticOnMemberAddText:SetText(loc.autoautotext)
		GOMaticOnMemberAddText2:SetText(loc.autoautotext2)
		GOMaticDeleteEZTemplate:SetText(loc.delsavebutton)
		GOMaticRenameEZTemplate:SetText(loc.renamesavebutton)
		GOMaticExcludeSavesText:SetText(loc.excludesavebutton)
		GOMaticIgnoreOfflineText:SetText(loc.ignoreofflinebutton)
		GOMaticRestoreMethodText:SetText(loc.restoremethodtext)
		GOMaticOverrideRemoteText:SetText(loc.overridebutton)
		GOMaticContinuousScanText:SetText(loc.continuousscanbutton)
		GOMaticEZCreator1CheckDescription:SetText(loc.creator1checkdesc:format(loc.roles.TANK))		
		GOMaticOnlyDoMemberAddActionsAsLeaderCheckText:SetText(loc.onlyasleaderbutton)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("VARIABLES_LOADED")
	--self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("ROLE_CHANGED_INFORM")

	SlashCmdList["GROUPOMATIC"] = GrOM.SlashCommandHandler
	SLASH_GROUPOMATIC1 = "/groupomatic"
	SLASH_GROUPOMATIC2 = "/gom"

	SlashCmdList["GROUPOMATIC_RAID_MOVE"] = GrOM.RMCommandHandler
	SLASH_GROUPOMATIC_RAID_MOVE1 = "/raidmove"
	SLASH_GROUPOMATIC_RAID_MOVE2 = "/rm"

	SlashCmdList["GROUPOMATIC_RAID_SWAP"] = GrOM.RSCommandHandler
	SLASH_GROUPOMATIC_RAID_SWAP1 = "/raidswap"
	SLASH_GROUPOMATIC_RAID_SWAP2 = "/rs"

	SlashCmdList["GROUPOMATIC_RAID_GROUP_SWAP"] = GrOM.RGSCommandHandler
	SLASH_GROUPOMATIC_RAID_GROUP_SWAP1 = "/raidgroupswap"
	SLASH_GROUPOMATIC_RAID_GROUP_SWAP2 = "/rgs"
	
	SlashCmdList["GROUPOMATIC_RAID_GROUP_MOVE"] = GrOM.RGMCommandHandler
	SLASH_GROUPOMATIC_RAID_GROUP_MOVE1 = "/raidgroupmove"
	SLASH_GROUPOMATIC_RAID_GROUP_MOVE2 = "/rgm"
end

local function GetAllRaidIDs()
	local allIDs = false
	local ignoreIDs = {}

	for i =1, #GrOM_Vars.MVPs do
		local mvp = strlower(GrOM_Vars.MVPs[i])
		for j = 1, 40 do
			local n,_,g = GetRaidRosterInfo(j)
			if n and g and strlower(n) == mvp then
				if not allIDs then
					allIDs = {[1]=j}
				else
					table.insert(allIDs, j)
				end
				table.insert(ignoreIDs, j)
			end
		end
	end

	local function FindIgnored(n)
		for q = 1, #ignoreIDs do
			if ignoreIDs[q] == n then
				return true
			end
		end

		return false
	end

	for i=1, 40 do
		if not FindIgnored(i) then
			local n,_,g = GetRaidRosterInfo(i)
			if n and g then
				if not allIDs then
					allIDs = {[1]=i}
				else
					table.insert(allIDs, i)
				end
			end
		end
	end

	return allIDs
end

local function FillInEmptyRoles(displayIfAnyWereEmpty) --if this is true DON'T display if any were empty
	if GrOM_Vars.disableTalentRequest then
		displayIfAnyWereEmpty = true
	end

	local wereEmpty = false

	for i=1, 40 do
		if not currentRaidGroupRolesByIndex[i] and UnitExists("raid"..i) then
			currentRaidGroupRolesByIndex[i] = {false, false, false, false}
			currentRaidGroupRolesByIndex[i][roleIndex[UnitGroupRolesAssigned("raid"..i)]] = true
			local _, cClass = UnitClass("raid"..i)
			if (currentRaidGroupRolesByIndex[i][roleIndex["RANGE_DPS"]]) then
				if (cClass == "ROGUE" or cClass == "MONK" or cClass == "DEATHKNIGHT" or cClass == "WARRIOR" or cClass == "PALADIN" or cClass == "DEMONHUNTER") then
					currentRaidGroupRolesByIndex[i][roleIndex["RANGE_DPS"]] = false
					currentRaidGroupRolesByIndex[i][roleIndex["MELEE_DPS"]] = true
				end
			end
			if GrOM_Vars.rolesByNameCache[GetPVEorPVPUName("raid"..i)] then
				currentRaidGroupRolesByIndex[i] = RolesNumToTable( (GrOM_Vars.rolesByNameCache[GetPVEorPVPUName("raid"..i)]) )
			end

			wereEmpty = true
		end
		--[[if currentRaidGroupRolesByIndex[i] and not currentRaidGroupRolesByIndex[i][13] then --add decurser type if it doesn't exist
			local _,cl = UnitClass("raid"..i)
			if cl then
				local pTab = defaultClassRoles[cl][13]
				if type(pTab) == "table" then
					currentRaidGroupRolesByIndex[i][13] = CopyTable(pTab)
				else
					currentRaidGroupRolesByIndex[i][13] = nil
				end
			end
		end]]
	end

	if wereEmpty and not displayIfAnyWereEmpty then
		dout(loc.filledinunknownroleswithdefaultsrunping)
	end
end

local function ArrangeManager()
	delayedActionInProgress = false
	GrOM.UpdateButtons()

	optimalRaidGroupPlacement = {}

	FillInEmptyRoles(true)

	ignoredExcluded = false
	local optimalSetup = GrOM.Arrange()

	if not optimalSetup then
		return true
	end

	local g = 1

	local group = optimalSetup[g]

	while group and group ~= {} do
		for i=1, 5 do
			if group[i] then
				optimalRaidGroupPlacement[group[i] ] = g
			end
		end
		g = g + 1
		group = optimalSetup[g]

	end

	GrOM.CreateArrangementFrame()
end

function GrOM.SetStartover(n)
	if type(n) == "string" then
		lastAction = {true, n}
	end
end

function GrOM.StartOver()
	if lastAction[1] then
		local n = GrOM_Vars.SavedRaidLayouts[lastAction[2]]
		if n then
			GrOM.RestoreRaid(n)
		end
	else
		GrOM.StartArrange()
	end
end

local function BuildCurrentPlacementTable()	
	currentRaidGroupPlacement = {}

	local ct, tt = {}, {}

	for i=1, 40 do
		local n,_,x = GetRaidRosterInfo(i)
		if not n then return end
		if x and x > 0 and x < 9 then
			currentRaidGroupPlacement[i] = x
			if ct[1] then
				for j=1, #ct do
					table.insert(tt, ct[j])
				end

				ct = {}
			end
		else
			currentRaidGroupPlacement[i] = nil
			table.insert(ct, i)
		end
	end

	local breaker = 10

	while breaker > 0 and tt[1] do
		breaker = breaker - 1

		local k = 0
		while k < #tt do
			k = k + 1

			local _,_,a = GetRaidRosterInfo(k)

			if a and a > 0 and a < 9 then
				currentRaidGroupPlacement[k] = a
				table.remove(tt, k)
				k = k - 1
			end
		end
	end

	if tt[1] then
		return -1
	end
end

function GrOM.DoAutoPlacement(name)
	if L_InCombatLockdown() then
		return
	end
	
	if not GrOM_Vars.autoPlacementSave then return end
	local raid = GrOM_Vars.SavedRaidLayouts[GrOM_Vars.autoPlacementSave]
	if not raid then return end
	
	BuildIndexByNameTable()
	BuildCurrentPlacementTable()	
	
	local i = currentRaidGroupIndexByName[name]
	if not i then return end
	
	local sg
	
	for rI = 1, 8 do --where should this player go?
		local rSg = raid[rI]
		if rSg then
			for rSI = 1, 5 do
				local cName = rSg[rSI]
				if cName then cName = cName:lower() end
				if cName == name:lower() then
					sg = rI
					break
				end
			end
		end
	end
	
	dout("Autoplacement tentative subgroup is: " .. (sg or "nil"))
	
	if sg then --is the group full?
		local counter = 0
		for rI = 1, 40 do
			if currentRaidGroupPlacement[rI] and currentRaidGroupPlacement[rI] == sg then
				if rI == i then --is the player already in the right group?
					return
				end
				counter = counter + 1
			end
		end
		if counter > 4 then
			sg = nil
		end
	end
	
	if not sg then --is the player not in the saved raid, or is the group they're saved to already full?
		local destGroup = 8
		
		while not sg do --find the highest numbered subgroup with a free slot
			if destGroup < 1 then return end
			
			sg = destGroup
			
			local counter = 0
			for rI = 1, 40 do
				if currentRaidGroupPlacement[rI] and currentRaidGroupPlacement[rI] == sg then
					counter = counter + 1
					if rI == i then --is the player already in the right group?
						return
					end
				end
			end
			if counter > 4 then
				sg = nil
			end
			
			destGroup = destGroup - 1
		end
	end

	dout("Final subgroup is: " .. sg .. ". Executing move...")

	L_SetRaidSG(i, sg)
end

local function FindFirstEmptyOptimalSlot()
	local slotNumbers = {0,0,0,0,0,0,0,0}

	for i = 1, 40 do
		if optimalRaidGroupPlacement[i] and optimalRaidGroupPlacement[i] < 9 and optimalRaidGroupPlacement[i] > 0 then
			slotNumbers[optimalRaidGroupPlacement[i] ] = slotNumbers[optimalRaidGroupPlacement[i] ] + 1
		end
	end

	for j = 1, 8 do
		if slotNumbers[j] < 5 and not GrOM_Vars.exclude[j] then
			return j
		end
	end

	for j = 1, 8 do
		if slotNumbers[j] < 5 then
			return j
		end
	end

	return false
end

local function RepairOptimalPlacementTable()
	for i = 1, 40 do
		if not currentRaidGroupPlacement[i]  then
			optimalRaidGroupPlacement[i] = false
		end

		if currentRaidGroupPlacement[i] and currentRaidGroupPlacement[i] < 9 and currentRaidGroupPlacement[i] > 0 then
			if (not optimalRaidGroupPlacement[i]) or (optimalRaidGroupPlacement[i] < 1 or optimalRaidGroupPlacement[i] > 8) then
				optimalRaidGroupPlacement[i] = FindFirstEmptyOptimalSlot()
				if not optimalRaidGroupPlacement[i] then
					GrOM.Cancel()
					dout(loc.memberaddederr .. "\nNote: This is impossible; if it happened, please tell me!")
					eout(loc.memberaddederr)
				end
			end
		end
	end
end

local function BuildTempOptimalTable()
	if not currentExecutionOptimalPlacementByName then currentExecutionOptimalPlacementByName = {} end
	
	local c, o = currentExecutionOptimalPlacementByName, optimalRaidGroupPlacement

	for i = 1, 40 do
			local name = GetRaidRosterInfo(i)
			if name then
					c[name] = o[i]
			end
	end
end

function GrOM.CreateArrangementFrame()
	groupFullErr = false
	lastRaidSetup = {}
	resetErrorTimer = 0
	BuildCurrentPlacementTable()
	BuildTempOptimalTable()

	GOMatic_ArrangementFrameLastUpdate = GetTime()
	GrOM.ArrangementFrameBreakCounter = 0

	delayedActionInProgress = true
	GrOM.UpdateButtons()
	local f = GOMatic_ArrangementFrame or CreateFrame("Frame","GOMatic_ArrangementFrame")
	f:SetScript("OnEvent", GOMatic_ArrangementFrame_OnEvent)
	f:SetScript("OnUpdate", GOMatic_ArrangementFrame_OnUpdate )
	f:RegisterEvent("CHAT_MSG_SYSTEM")
	f:Show()
end

local function IsValidSpec(spec)
	if type(spec) ~= "table" then
		return false
	end
	
	for i=1, 4 do
		if type(spec[i])~= "boolean" then
			return false
		end
	end

	return spec[roleIndex["TANK"]] or spec[roleIndex["HEALER"]] or spec[roleIndex["MELEE_DPS"]] or spec[roleIndex["RANGE_DPS"]]
end

local function PlayerRespec(s1, s2)
	return nil
end

local function GetNumAssignedMembers(optimalSetup, countExcluded)
	local num = 0

	for i = 1, 8 do
		if countExcluded or (not GrOM_Vars.exclude[i]) then
			num = num + #optimalSetup[i]
		end
	end

	return num
end

local function GetMaxGroups(unassignedMembers, optimalSetup)
	local num, count = 0, #unassignedMembers + GetNumAssignedMembers(optimalSetup, false)

	for i = 1, 8 do
		if not GrOM_Vars.exclude[i] then
			count = count - 5
			if count < 1 then
				return i
			end
		end
	end

	return 8
end

--[[local function GetMaxGroups(unassignedMembers)
	local x = (GetNumGroupMembers() + FindNumExcludedEmptySpaces(unassignedMembers)) / 5
	return math.ceil(x)
end]]

function GrOM.RemoveFromCache(n)
	GrOM_Vars.rolesByNameCache[n] = nil
end

local doneInspecting = false

local function L_CanInspectUnit(u)
	local can = (not UnitIsDead("player") ) and UnitExists(u) and UnitInRange(u)
	
	local n = UnitName(u) or "na"	

	if not can then
		dout(("Can't scan %s because that player is too far away, or is the local player."):format(n), true)
	else
		dout(("Scanning %s."):format(n), true)
	end

	return can
end

function GrOM.TalentRequest_OnEvent(self, event, ...)
	--[[if event == "CHAT_MSG_ADDON" then --leaving this in for gomtest, but it should be moved to its own function
		local arg1, arg2, arg3, arg4 = ...
		if arg3 == "WHISPER" and arg1 == "GOMTALENTR" then
			GrOM.SpecRecieved = {}
			RunScript("GrOM.SpecRecieved = " .. arg2)
			local spec = GrOM.SpecRecieved

			if not IsValidSpec(spec) then
				return
			end

			if currentRaidGroupRolesByIndex[currentRaidGroupIndexByName[arg4] ] then
				return
			end

			currentRaidGroupRolesByIndex[currentRaidGroupIndexByName[arg4] ] = spec

			if GrOM_Vars.rolesByNameCache[arg4] then
				local respec = PlayerRespec(RolesNumToTable(GrOM_Vars.rolesByNameCache[arg4]), spec)
				if respec then
					if not currentScanIsAuto then
						cout(string.format(respec, arg4))
					end
				end
			end
			GrOM_Vars.rolesByNameCache[arg4] = RolesTableToNum(spec)
		end
	else]]if event == "INSPECT_READY" then
		if GrOM_Vars.LocalOverridesRemote and (not currentScanIsAuto) then
			return
		end
		
		local arg1 = ...

		if GrOM.lastInspectGUID ~= arg1 then
			return
		end
		
		local u = "raid" .. raidInspectionIndex
		if GrOM.InspectTainted then

			GrOM.debug.talentCollection.lastStackTrace = ""
			GrOM.debug.talentCollection.reasons.addonConflict = GrOM.debug.talentCollection.reasons.addonConflict + 1

			if L_CanInspectUnit(u) then
				NotifyInspect(u)
				GrOM.inspectSent = GetTime()
			else
				while raidInspectionIndex < 40 do
					raidInspectionIndex = raidInspectionIndex + 1
					u = "raid" .. raidInspectionIndex

					if L_CanInspectUnit(u) then
						GOMatic_TalentRequestFrame:RegisterEvent("INSPECT_READY")
						NotifyInspect(u)
						GrOM.inspectSent = GetTime()
						GrOM.InspectTainted = false
						return
					end
				end
			end

			GrOM.InspectTainted = false
			return
		end

		GOMatic_TalentRequestFrame:UnregisterEvent("INSPECT_READY")

		if (not currentScanIsAuto) and GetTime() - GrOM.TalentRequestStartTime > 10 then
			if raidInspectionIndex == floor(GetNumGroupMembers() / 4) then
				dout("25%")
			elseif raidInspectionIndex == floor(GetNumGroupMembers() / 2) then
				dout("50%")
			elseif raidInspectionIndex == floor(GetNumGroupMembers() / 1.5) then
				dout("75%")
			end
		end

		local isPrimary = GetActiveTalentGroup(not (UnitIsUnit(u,"player"))) == 1
		local spec = GetMyRoles(u,isPrimary)
		if spec == "ERR_BACKOFF" then return end
		if spec == "ERR_BADCLASS" then
			GrOM.debug.talentCollection.reasons.badClass = GrOM.debug.talentCollection.reasons.badClass + 1
			return
		end
		local name = GetPVEorPVPUName(u)		

		if spec and IsValidSpec(spec) then
			if currentRaidGroupIndexByName[name] then
				currentRaidGroupRolesByIndex[currentRaidGroupIndexByName[name] ] = spec

				if isPrimary or GrOM_Vars.cacheSecondaryTalents then
					GrOM_Vars.rolesByNameCache[name] = RolesTableToNum(spec)
				end
			end
		end

		raidInspectionIndex = raidInspectionIndex + 1

		if raidInspectionIndex == 41 then
			raidInspectionIndex = 0
			doneInspecting = true
			return
		end

		u = "raid" .. raidInspectionIndex

		if L_CanInspectUnit(u) then
			GOMatic_TalentRequestFrame:RegisterEvent("INSPECT_READY")
			NotifyInspect(u)
			GrOM.lastInspectGUID = UnitGUID(u)
			GrOM.inspectSent = GetTime()
			GrOM.InspectTainted = false
		elseif raidInspectionIndex < 40 then
			while raidInspectionIndex < 40 and raidInspectionIndex > 0 do
				raidInspectionIndex = raidInspectionIndex + 1
				u = "raid" .. raidInspectionIndex

				if L_CanInspectUnit(u) then
					GOMatic_TalentRequestFrame:RegisterEvent("INSPECT_READY")
					NotifyInspect(u)
					GrOM.lastInspectGUID = UnitGUID(u)
					GrOM.inspectSent = GetTime()
					GrOM.InspectTainted = false
					return
				end
			end

			raidInspectionIndex = 0
			doneInspecting = true
			return
		end
	end
end

local function TalentRequest_OnUpdate()
	if GrOM.inspectSent + GrOM.talentRequestTTL < GetTime() then
		if raidInspectionIndex < 40 then
			GrOM.debug.talentCollection.reasons.lag = GrOM.debug.talentCollection.reasons.lag + 1

			while raidInspectionIndex < 40 and raidInspectionIndex > 0 do
				raidInspectionIndex = raidInspectionIndex + 1
				local u = "raid" .. raidInspectionIndex
				if L_CanInspectUnit(u) then
					GOMatic_TalentRequestFrame:RegisterEvent("INSPECT_READY")
					NotifyInspect(u)
					GrOM.lastInspectGUID = UnitGUID(u)
					GrOM.InspectTainted = false
					GrOM.inspectSent = GetTime()
					return
				end
			end
			raidInspectionIndex = 0
			doneInspecting = true
		end
	end

	if (not currentScanIsAuto) or GrOM.TalentRequestStartTime + GrOM.TalentRequestDelayMinimum < GetTime()--[[ or GrOM_Vars.userTemplateToUse == "AB_EOTS_AUTO_AKRYN"]] then
		local debugReason = GrOM.debug.talentCollection.GetReason()
		dout(("A talent scan failed to scan all members. The scan was at UID %s when it was aborted."):format(tostring(raidInspectionIndex)))
		dout("The reason for the failure might be: " .. debugReason)
		if GrOM.debugCachingOn then
			GrOM_Vars.debugCache[#GrOM_Vars.debugCache + 1] = GrOM.debug.talentCollection.lastStackTrace or "nothing"
		end

		local known = loc.myName2:format(FindKnownPercent())
		if not GrOM.guiUnloaded then
			GOMaticTitleText2:SetText(known)
		end

		if not currentScanIsAuto then
			if not ArrangeManager() then
				dout(loc.talentsfound:format(known))
			else
				dout("Failure in GrOM.Arrange, fatal.")
			end
		else
			delayedActionInProgress = false
			GrOM.UpdateButtons()
		end
		GOMatic_TalentRequestFrame:SetScript("OnEvent", nil)
		GOMatic_TalentRequestFrame:UnregisterEvent("CHAT_MSG_ADDON")
		GOMatic_TalentRequestFrame:UnregisterEvent("INSPECT_READY")
		GOMatic_TalentRequestFrame:SetScript("OnUpdate", nil)

		currentScanIsAuto = false
	end
end

local function CreateTalentRequestFrame()
	dout("A talent scan started.")
	GrOM.debug.talentCollection.ClearReasons()
	GrOM.inspectSent = GetTime()
	raidInspectionIndex = 1
	doneInspecting = false
	currentScanTalentNumCheckFailureCounter = 0
	GrOM.TalentRequestStartTime = GetTime()

	delayedActionInProgress = true
	GrOM.UpdateButtons()
	local f = GOMatic_TalentRequestFrame or CreateFrame("Frame","GOMatic_TalentRequestFrame")
	f:SetScript("OnUpdate", TalentRequest_OnUpdate)
	f:SetScript("OnEvent", GrOM.TalentRequest_OnEvent)
	--f:RegisterEvent("CHAT_MSG_ADDON")
	f:Show()
	--if not GrOM_Vars.disableTalentRequest then
		--SendAddonMessage("GOMTALENT", tostring(GrOM.Version), "RAID")
	--end

	
	f:RegisterEvent("INSPECT_READY")
	local u = ""
	for i=1, 40 do
		u = "raid" .. i
		if L_CanInspectUnit(u) then
			raidInspectionIndex = i
			GOMatic_TalentRequestFrame:RegisterEvent("INSPECT_READY")
			NotifyInspect(u)
			GrOM.lastInspectGUID = UnitGUID(u)
			GrOM.inspectSent = GetTime()
			GrOM.InspectTainted = false
			return
		end
	end
	raidInspectionIndex = 0
	doneInspecting = true
end

local function BuildRolesByIndexTable()
	for i=1, 40 do
		currentRaidGroupRolesByIndex[i] = false
	end
end

local function FindWorkingGroup(optimalSetup, unassignedMembers)
	local group = -1

	if GetNumGroupMembers() == 0 then
		return -1
	end

	local maxG = GetMaxGroups(unassignedMembers, optimalSetup)

	if maxG > 8 or maxG < 1 then
		return -2
	end

	for i=1, maxG do
		if (not optimalSetup[i][1]) then
			if not GrOM_Vars.exclude[i] then
				group = i
				break
			end
		end
	end

	if group == -1 then
		for i=1, 8 do
			if optimalSetup[i][1] then
				if #optimalSetup[i] < 5 then
					if not GrOM_Vars.exclude[i] then
						group = i
						break
					end
				end
			end
		end
	end

	return group
end

local elapsedT = 0
local autoScanThrottle = 300

function GrOM.AutoScanNow()
	elapsedT = 299
end

function GrOM.OnUpdate(self, elapsed)
	elapsedT = elapsedT + elapsed

	if elapsedT > autoScanThrottle and (not InCombatLockdown()) then
		elapsedT = 0

		if (not delayedActionInProgress) and GetNumGroupMembers() > 1 then
			currentScanIsAuto = true
			BuildIndexByNameTable()
			BuildRolesByIndexTable()
			CreateTalentRequestFrame()
		end
	end
end

function GrOM.StartArrange()
	if (not (UnitIsGroupLeader("player") or UnitIsRaidOfficer("player")) ) or GetNumGroupMembers() < 1 then
		eout(loc.notraidleadererror)
		return
	end

	GrOM.ARRANGE_BREAK = 0

	BuildIndexByNameTable()
	BuildRolesByIndexTable()

	if not (GrOM_Vars.userTemplateToUse == "AB_EOTS_AUTO_AKRYN") then
		dout(loc.requestingtalents)
	end

	CreateTalentRequestFrame()
end

--thanks to Mikk for this
local function tcount(tab)
	local n=0

	for _ in pairs(tab) do
		n=n+1
	end

	return n
end


local function IsGroupFull(group)
	local n = 0

	for i=1, 40 do
		if currentRaidGroupPlacement[i] and currentRaidGroupPlacement[i] == group then
			n = n + 1
		end
	end

	return n > 4
end

local function IDIsLocked(i)
	for k = 1, #lockedIDs do
		if lockedIDs[k] == i then
			return true
		end
	end

	return false
end

local function groupIsLocked(g)
	for k = 1, #lockedGroups do
		if lockedGroups[k] == g then
			return true
		end
	end

	return false
end

local function FindIDToMoveToGroup(group, inGroup, requireInGroup)
	local setGroup = false

	if inGroup then
		if inGroup < 1 or inGroup > 8 then
			if inGroup == -17 then
				inGroup = nil
				setGroup = true
			else
				return nil
			end
		end
	end

	local match = nil

	for i=1, 40 do
		if not IDIsLocked(i) then
			local currentGroup = currentRaidGroupPlacement[i]
			local destGroup = optimalRaidGroupPlacement[i]

			if not (setGroup and groupIsLocked(destGroup)) then
				if currentGroup and currentGroup > 0 and currentGroup < 9 and destGroup and destGroup ~= currentGroup and destGroup > 0 and destGroup < 9 and destGroup == group then
					if inGroup then
						if currentGroup == inGroup then
							return i
						else
							match = i
						end
					else
						return i
					end
				end
			end
		end
	end

	if requireInGroup then
		return false
	end

	return match
end

local function FindEmptySlot()
	for i=1, 8 do
		if not IsGroupFull(i) then
			local x = FindIDToMoveToGroup(i, -17)
			if x then
				return i, x
			end
		end
	end

	return -1, false
end

local function ValidateTemplate(template)

	if type(template) ~= "table" then
		return false
	end

	if #template ~= 3 then
		return false
	end

	if type(template[1]) ~= "string" then
		return false
	end

	if template[1] == "" then
		return false
	end

	if type(template[2]) ~= "table" then
		return false
	end

	if type(template[3]) ~= "table" then
		return false
	end

	local fail = false

	foreachi(template[2], function(i,v) if not ( (type(v)=="string") or (type(v)=="table") ) then fail = true end end)
	foreachi(template[3], function(i,v) if not ( (type(v)=="string") or (type(v)=="table") ) then fail = true end end)

	return not fail
end

local function ValidateGroups(...)
	local OKGroups = {}

	for i = 1, select("#", ...) do
		table.insert(OKGroups, tonumber(select(i, ...)))
	end

	if #OKGroups < 1 or #OKGroups > 8 then
		return false
	end

	for i = 1, #OKGroups do
		local x = OKGroups[i]

		if x then
			if (not x) or x < 1 or x > 8 then
				return false
			end
		end
	end

	return OKGroups
end

local function myTFind(tab, i)
	for j = 1, #tab do
		if tab[j] == i then
			return true
		end
	end

	return false
end

--class, prefSpec, requirePref, ignoreSpec, loopWhile
local function ValidateTemplateTable(t)
	if type(t) ~= "table" then
		return false
	end

	if t[1] then
		if type(t[1]) ~= "string" then
			return false
		end

		--[[if not defaultClassRoles[t[1] ] then
			return false
		end]]
	end

	if not t[2] then
		return false
	end

	if type(t[2]) ~= "string" then
		return false
	end

	if not roleIndex[t[2] ]  then
		return false
	end

	if t[4] and (not roleIndex[t[4] ] ) then
		return false
	end

	return true
end

function GrOM.DisplayCurrAndDest()
	for i=1, 40 do
		local currentGroup = currentRaidGroupPlacement[i]
		local destGroup = optimalRaidGroupPlacement[i]
		local msg = ""
		if currentGroup then msg = currentGroup end
		if destGroup then msg = msg .. "     " .. destGroup end

		eout(msg)
	end
end

function GrOM.MinLevelInputChanged(self)
	local x = tonumber(self:GetText())
	if x and x < 1 then x = 1 self:SetText("1") end
	if x and x > 256 then x = 256  self:SetText("256") end
	GrOM_Vars.ignoreBelowLevel = x
end

local function FindUnmovedID(ignoreGroup)
	local raidIDToMove, currentGroup, destGroup = nil, nil, nil
	local retCurr, retDest = nil, nil

	local i = 41
	while i > 1 do
		i = i - 1
		if not IDIsLocked(i) then
			currentGroup = currentRaidGroupPlacement[i]
			destGroup = optimalRaidGroupPlacement[i]


			if currentGroup and currentGroup > 0 and currentGroup < 9 and (not (ignoreGroup and currentGroup == ignoreGroup)) and destGroup and destGroup ~= currentGroup and destGroup > 0 and destGroup < 9 then
				raidIDToMove = i
				retCurr = currentGroup
				retDest = destGroup
				if FindIDToMoveToGroup(currentGroup, destGroup, true) then
					return raidIDToMove, retCurr, retDest
				end
			end
		end
	end

	return raidIDToMove, retCurr, retDest
end

local function MatchDecurser(testMe)
	for _,v in pairs(currentDecurserMeanings) do
		for _,v2 in pairs(testMe) do
			if v == v2 then
				return true
			end
		end
	end
end

--return 41 if a complete match, raid id if a match except for spec AND requirePref is false, or false if not a good match
local function DoesIDMatchClassAndSpec(ID, class, prefSpec, requirePref, ignoreSpec)
	if type(currentRaidGroupRolesByIndex[ID]) ~= "table" or not IsValidSpec(currentRaidGroupRolesByIndex[ID]) then
		dout("Bad talents for " .. ID)
		return false
	end

	local realSpec, realClass = currentRaidGroupRolesByIndex[ID], select(2, UnitClass("raid"..ID))

	local doesMatch = 41

	if class and realClass ~= class then
		return false
	end

	if not realSpec[prefSpec] then
		if requirePref then
			return false
		end

		doesMatch = ID
	end

	if ignoreSpec and realSpec[ignoreSpec] then
		return false
	end

	return doesMatch
end

local function FindInGroup(group, spec)
	for i = 1, #group do
		if currentRaidGroupRolesByIndex[group[i] ][roleIndex[spec] ] then
			return true
		end
	end

	return false
end

local function FindNonNA(unassignedMembers, zonesByIndex)
	for _,v in pairs(unassignedMembers) do
		if zonesByIndex[v] ~= "na" then
			return true
		end
	end
	return false
end

local function PushExtrasToLower(unassignedMembers, optimalSetup)
	local optimalSetup = optimalSetup or {{},{},{},{},{},{},{},{}}

	local wGroup = 8

	while wGroup > 0 do
		if #optimalSetup[wGroup] > 4 then
			wGroup = wGroup - 1
		else
			local x = table.remove(unassignedMembers)
			if x then
				table.insert(optimalSetup[wGroup], x)
			else
				break
			end
		end
	end

	return unassignedMembers, optimalSetup
end

local function AutoSplit(unassignedMembers, optimalSetup, role)
	local optimalSetup = optimalSetup or {{},{},{},{},{},{},{},{}}
	local unassignedMembers = unassignedMembers or {}
	role = role or 1
	
	local maxG = GetMaxGroups(unassignedMembers, optimalSetup)
	if (maxG % 2 ~= 0) then
		maxG = maxG + 1
	end
	
	local totalWithMyRole = 0
	for i = 1, 40 do
		if type(currentRaidGroupRolesByIndex[i]) == "table" and currentRaidGroupRolesByIndex[i][role] then
			totalWithMyRole = totalWithMyRole + 1
		end
	end
	local myRolePerSide = totalWithMyRole / 2
	
	local start = 1
	local cap = myRolePerSide
	for unSearch = 1, #unassignedMembers do
		if cap < 1 then
			break
		end
		if type(currentRaidGroupRolesByIndex[unassignedMembers[unSearch]]) == "table" and currentRaidGroupRolesByIndex[unassignedMembers[unSearch]][role] then
			for optSearch = start, maxG, 2 do
				if (#optimalSetup[optSearch] < 5) then
					table.insert(optimalSetup[optSearch], table.remove(unassignedMembers, unSearch))
					cap = cap - 1
					break
				end
			end
		end
	end
	
	cap = (totalWithMyRole - myRolePerSide) + cap
	start = 2
	
	for unSearch = 1, #unassignedMembers do
		if cap < 1 then
			break
		end
		if type(currentRaidGroupRolesByIndex[unassignedMembers[unSearch]]) == "table" and currentRaidGroupRolesByIndex[unassignedMembers[unSearch]][role] then
			for optSearch = start, maxG, 2 do
				if (#optimalSetup[optSearch] < 5) then
					table.insert(optimalSetup[optSearch], table.remove(unassignedMembers, unSearch))
					cap = cap - 1
					break
				end
			end
		end
	end
	
	if role == roleIndex.RANGE_DPS then
		dout("-range/splitA")
		dout(#optimalSetup[maxG])
		dout(#optimalSetup[maxG-1])
		dout(maxG)
		while (#optimalSetup[maxG] + 1 < #optimalSetup[maxG-1]) do
			dout("-range/splitB")
			for mvSearch = 1, #optimalSetup[maxG-1] do
				if type(currentRaidGroupRolesByIndex[optimalSetup[maxG-1][mvSearch]]) == "table" and currentRaidGroupRolesByIndex[optimalSetup[maxG-1][mvSearch]][roleIndex.MELEE_DPS] or currentRaidGroupRolesByIndex[optimalSetup[maxG-1][mvSearch]][roleIndex.RANGE_DPS] then
					dout("-range/splitC")
					table.insert(optimalSetup[maxG], table.remove(optimalSetup[maxG-1], mvSearch))
					break
				end
			end
		end
	end
	
	return unassignedMembers, optimalSetup
end

local function ApplySeparationPreferences(unassignedMembers)
	local toPush = {}

	local i = 1
	while i <= #unassignedMembers do
		if unassignedMembers[i] then
			local _, _, _, level, _, _, _, online, dead = GetRaidRosterInfo(unassignedMembers[i])
			if (GrOM_Vars.ignoreBelowLevel and GrOM_Vars.ignoreBelowLevel > level) or (GrOM_Vars.ignoreOffline and (not online)) or (GrOM_Vars.ignoreDead and dead) then
				local q = table.remove(unassignedMembers, i)
				i = i - 1
				if q then
					table.insert(toPush, q)
				end
			end
		end
		i = i + 1
	end
	return unassignedMembers, toPush
end

local function DynamicBGArrange(unassignedMembers)
	local realZone = GetRealZoneText()

	--[[if loc.arathi and loc.eots and (realZone ~= loc.arathi and realZone ~= loc.eots) then
		return false
	end]]

	local optimalSetup = {{},{},{},{},{},{},{},{}}
	local zone = nil

	local zonesByIndex = {}

	for i = 1, #unassignedMembers do
		if UnitIsUnit("raid" .. unassignedMembers[i], "player") then
			zone = GetMinimapZoneText()
		else
			_,_,_,_,_,_,zone = GetRaidRosterInfo(unassignedMembers[i])
		end

		if not zone or zone == "Offline" then
			zone = "na"
		end

		zonesByIndex[unassignedMembers[i] ] = zone
	end

	local wGroup = 1
	while FindNonNA(unassignedMembers, zonesByIndex) do
		local x = 0
		while x < #unassignedMembers do
			x = x + 1
			local cZone = zonesByIndex[unassignedMembers[x] ]
			if cZone ~= "na" then
				while x <= #unassignedMembers do
					if zonesByIndex[unassignedMembers[x] ] == cZone then
						if #optimalSetup[wGroup] > 4 then
							wGroup = wGroup + 1
							if wGroup > 8 then --i don't think this is possible if you're actually in ab/eots so i'm just going to make a really simple failsafe
								for a = 1, 8 do
									if #optimalSetup[a] < 5 then
										wGroup = a
									end
								end
							end
						end

						table.insert(optimalSetup[wGroup], table.remove(unassignedMembers, x))
						x = x - 1
					end

					x = x + 1
				end
			end
		end

		wGroup = wGroup + 1

		if wGroup > 8 then
			for a = 1, 8 do
				if #optimalSetup[a] < 5 then
					wGroup = a
				end
			end
		end
	end

	for a = 1, 8 do
		if #optimalSetup[a] < 5 then
			wGroup = a
		end
	end

	while #unassignedMembers > 0 do
		if #optimalSetup[wGroup] > 4 then
			for a = 1, 8 do
				if #optimalSetup[a] < 5 then
					wGroup = a
				end
			end
		end

		table.insert(optimalSetup[wGroup], table.remove(unassignedMembers))
	end

	return unassignedMembers, optimalSetup
end

local function RemoveIndex(optimalSetup, index)
	for i = 1, 8 do
		local j = 1
		while j <= #optimalSetup[i] do
			local x = optimalSetup[i][j]
			if x and x == index then
				table.remove(optimalSetup[i], j)
				j = j - 1
			end
			j = j + 1
		end
	end

	return optimalSetup
end

local function IgnoreExcludedGroups(optimalSetup, unassignedMembers)
	if ignoredExcluded then
		return optimalSetup, unassignedMembers
	end

	ignoredExcluded = true

	for i = 1, 8 do
		if GrOM_Vars.exclude[i] then
			for k = 1, #optimalSetup[i] do
				table.insert(unassignedMembers,	optimalSetup[i][k])
			end
			optimalSetup[i] = {}
			for j = 1, 40 do
				local n,_,g = GetRaidRosterInfo(j)
				if n and g and g == i then
					optimalSetup = RemoveIndex(optimalSetup, j)
					table.insert(optimalSetup[i], j)
				end
			end
		end
	end

	local b = 1
	while b <= #unassignedMembers do
		local name,_,group = GetRaidRosterInfo(unassignedMembers[b])
		if name and group then
			if GrOM_Vars.exclude[group] then
				table.remove(unassignedMembers, b)
				b = b - 1
			end
		end
		b = b + 1
	end

	return optimalSetup, unassignedMembers
end

local function IsGroupLimitMet(limit, group)  --[1] = class, [2] = ROLE, [3] = number, [4] = enforce, [5] = operator (& or @)
	local count = 0

	for i = 1, #group do
		local matchClass, matchSpec = false, false

		if limit[2] and currentRaidGroupRolesByIndex[group[i] ][roleIndex[limit[2] ] ] then
			matchSpec = true
		end

		if limit[1] and select(2, UnitClass("raid"..group[i])) == limit[1] then
			matchClass = true
		end

		if limit[1] and limit[2] then
			if matchSpec and matchClass then
				count = count + 1
			elseif limit[5] == "@" then
				if matchSpec or matchClass then
					count = count + 1
				end
			end
		elseif limit[1] then
			if matchClass then
				count = count + 1
			end
		else
			if matchSpec then
				count = count + 1
			end
		end
	end

	if count >= limit[3] then
		return true
	end

	return false
end

local function ValidateLimits(...)
	local limit
	local maxN = select("#", ...)
	local limitT = {}

	if maxN < 1 then
		return false
	end

	for i = 1, maxN do
		limit = select(i, ...)
		if type(limit) ~= "string" then
			return false
		end

		local _,_,enforce, number, class, operator, spec = limit:find("^(%+?)(%d+)([^%-]+)([@&])([^%-]+)$")

		if not (class and spec and number) then
			return false
		end

		number = tonumber(number)

		if not number then
			return false
		end

		if class == "*" and spec == "*" then
			return false
		end

		local limTE = {}

		if class == "*" then
			limTE[1] = false
		else
			if not defaultClassRoles[class] then
				return false
			else
				limTE[1] = class
			end
		end

		if spec == "*" then
			limTE[2] = false
		else
			if not roleIndex[spec] then
				return false
			else
				limTE[2] = spec
			end
		end

		if number < 0 or number > 5 then
			return false
		end

		limTE[3] = number
		limTE[4] = (enforce ~= "")
		limTE[5] = operator
		table.insert(limitT, limTE)
	end

	return limitT
end

--/print GrOM.TestValidateLimits("+1SHAMAN@*,+1PALADIN@*,+1PRIEST&MANA_BATTERY")
--/print GrOM.TestValidateLimits("1PRIEST&MANA_BATTERY")
--[[function GrOM.TestValidateLimits(x)
	return ValidateLimits(strsplit(",", x))
end]]

local function ValidateDecurseWhich(...)
	local dwT = {}
	local maxD = select("#", ...)

	if maxD == 1 and ... == "any" then
		return {"DISEASE","POISON","MAGIC","CURSE"}
	end

	for i = 1, maxD do
		local dwTE = select(i, ...)
		local fail = true
		for _,v in pairs(currentDecurserMeanings) do
			if v == dwTE then
				table.insert(dwT, dwTE)
				fail = false
				break
			end
		end
		if fail then return false end
	end

	return dwT
end

local function FindLineNumber(sc, tc, template)
	if not sc then
		return false
	end

	local n = tonumber(sc)

	if n and n > tc then
		return n
	end

	for i = tc, #template do
		local q = template[i]
		if q and type(q) == "string" then
			local anchor = q:match("anchor (.+)")
			if anchor then
				if anchor == sc then
					return i
				end
			end
		end
	end
end

local defaultTemplate = {
	{
		[1] = {nil, "TANK", true, nil, true},
		[2] = {nil, "MELEE_DPS", true, nil, true},
		[3] = {nil, "HEALER", false, nil, true}
	},
	{
		[1] = {nil, "RANGE_DPS", false, nil, true}
	}
}

function GrOM.Arrange(optimalSetup, unassignedMembers)
	GrOM.ARRANGE_BREAK = GrOM.ARRANGE_BREAK + 1
	local topLevel = GrOM.ARRANGE_BREAK == 1

	if GrOM.ARRANGE_BREAK and GrOM.ARRANGE_BREAK > 100 then
		eout("Bad user template: Infinite loop terminated. Please select another template or use the default.")
		return false
	end
	
	local optimalSetup = optimalSetup or {{},{},{},{},{},{},{},{}}

	local unassignedMembers = unassignedMembers or GetAllRaidIDs()

	optimalSetup, unassignedMembers = IgnoreExcludedGroups(optimalSetup, unassignedMembers)

	if topLevel then
		unassignedMembers, topLevel = ApplySeparationPreferences(unassignedMembers)
	end

	if #unassignedMembers < 1 and topLevel then
		_, optimalSetup = PushExtrasToLower(topLevel, optimalSetup)
		return optimalSetup
	end

	local x = FindWorkingGroup(optimalSetup, unassignedMembers)

	local currPass = floor(GrOM.ARRANGE_BREAK / GetMaxGroups(unassignedMembers, optimalSetup) )  --this is really ugly

	if x == -2 then
		dout("bad maxgroups")
		return false
	end

	if x == -1 or (not unassignedMembers[1]) then
		return optimalSetup
	end

	local group = optimalSetup[x]
	local match = false
	local class, prefSpec, requirePref, ignoreSpec, loopWhile = nil, nil, false, nil, nil
	local lastMatch, lastIndex = -1, -1
	local limits = nil  --[1] = class, [2] = ROLE, [3] = number, [4] = enforce, [5] = operator (& or @)
	local minPass = 0

	local function IsLimitedUnit(lid)
		if not limits then
			return false
		end

		local retVal = "."

		for il1 = 1, #limits do
			local l1t = limits[il1]
			if l1t[1] and l1t[2] then
				if (currentRaidGroupRolesByIndex[lid][roleIndex[l1t[2] ] ] and select(2, UnitClass("raid"..lid)) == l1t[1]) or (l1t[5] == "@" and (currentRaidGroupRolesByIndex[lid][roleIndex[l1t[2] ] ] or select(2, UnitClass("raid"..lid)) == l1t[1]) ) then
					if IsGroupLimitMet(l1t, group) then
						if not l1t[4] then
							if retVal ~= "deny" then
								retVal = "permit"
							end
						else
							retVal = "deny"
						end
					end
				end
			elseif l1t[1] then
				if select(2, UnitClass("raid"..lid)) == l1t[1] then
					if IsGroupLimitMet(l1t, group) then
						if not l1t[4] then
							if retVal ~= "deny" then
								retVal = "permit"
							end
						else
							retVal = "deny"
						end
					end
				end
			else
				if currentRaidGroupRolesByIndex[lid][roleIndex[l1t[2] ] ] then
					if IsGroupLimitMet(l1t, group) then
						if not l1t[4] then
							if retVal ~= "deny" then
								retVal = "permit"
							end
						else
							retVal = "deny"
						end
					end
				end
			end
		end

		if retVal == "." then
			return false
		end

		return retVal
	end

	local lastMatchIsLimited = false

	local function HandleMatchup(i, v)
		if i == 1 then
			lastMatchIsLimited = false
			lastMatch = -1
			match = false
		end

		if not v then
			match = false
			return
		end

		local isMatch = DoesIDMatchClassAndSpec(v, class, prefSpec, requirePref, ignoreSpec)

		if isMatch then
			local isLimitedHow = IsLimitedUnit(v)
			if limits and isLimitedHow then
				if isLimitedHow == "permit" then
					if lastMatch == -1 then
						lastMatch = v
						lastIndex = i
						lastMatchIsLimited = true
					end
				end
			else
				if isMatch == 41 then
					match = true
					table.remove(unassignedMembers, i)
					table.insert(group, v)
					return true
				elseif lastMatch == -1 or lastMatchIsLimited then
					lastMatch = v
					lastIndex = i
					lastMatchIsLimited = false
				end
			end
		end

		if i == #unassignedMembers and (not match) and lastMatch > 0 then
			match = true
			table.remove(unassignedMembers, lastIndex)
			table.insert(group, lastMatch)
			return true
		end

		--this shouldn't ever happen
		if i == #unassignedMembers and match then
			match = false
		end
	end

	local function myForeachi(tab, func)
		if #tab == 0 then
			match = false
		end
		for k, v in pairs(tab) do
			if func(k,v) then return end
		end
	end

	local template = {}

	--if a template is selected, and it's valid, use it
	local OKGroups = nil
	if GrOM_Vars.userTemplateToUse then
		if type(GrOM_Vars.userTemplateToUse) == "string" then
			if not ( GrOM.userTemplates[GrOM_Vars.userTemplateToUse ] and ValidateTemplate(GrOM.userTemplates[GrOM_Vars.userTemplateToUse ]) ) then
				eout("Auto-arrange template has errors or does not exist. Please select another template or use the default.")
				return false
			end

			if not group[1] then
				template = GrOM.userTemplates[GrOM_Vars.userTemplateToUse ][2]
			else
				template = GrOM.userTemplates[GrOM_Vars.userTemplateToUse ][3]
			end

			if currPass > 2 then
				template = GrOM.userTemplates[GrOM_Vars.userTemplateToUse ][3]
			end
		else
			if not ( GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse ] and ValidateTemplate(GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse ]) ) then
				eout("Auto-arrange template has errors or does not exist. Please select another template or use the default.")
				return false
			end

			if not group[1] then
				template = GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse ][2]
			else
				template = GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse ][3]
			end

			if currPass > 2 then
				template = GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse ][3]
			end
		end
	--otherwise use the default
	else
		if not group[1] then
			template = defaultTemplate[1]
		else
			template = defaultTemplate[2]
		end

		if currPass > 2 then
			template = defaultTemplate[2]
		end
	end

	local tc = 0
	while tc < #template and tcount(group) < 5 do
		tc = tc + 1

		if type(template[tc]) == "string" then
			if template[tc] == "allgroups" then
				OKGroups = nil
			elseif template[tc] == "anypass" then
				minPass = 0
			end

			if ((not OKGroups) or myTFind(OKGroups, x)) and (currPass >= minPass) then
				local cmd, sc = GetCmd(template[tc])
				if cmd and sc then
					if cmd == "fail" and not match then
						sc = FindLineNumber(sc, tc, template)
						if sc and sc > tc then
							tc = sc - 1
						else
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: fail anchorName | # (# must be > the current index)")
							return false
						end
					elseif cmd == "success" and match then
						sc = FindLineNumber(sc, tc, template)
						if sc and sc > tc then
							tc = sc - 1
						else
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: fail anchorName | # (# must be > the current index)")
							return false
						end
					elseif cmd == "pushextras" then
						unassignedMembers, optimalSetup = PushExtrasToLower(unassignedMembers, optimalSetup)
						return optimalSetup
					elseif cmd == "autosplit_tank" then
						unassignedMembers, optimalSetup = AutoSplit(unassignedMembers, optimalSetup, roleIndex["TANK"])
					elseif cmd == "autosplit_melee" then
						unassignedMembers, optimalSetup = AutoSplit(unassignedMembers, optimalSetup, roleIndex["MELEE_DPS"])
					elseif cmd == "autosplit_range" then
						unassignedMembers, optimalSetup = AutoSplit(unassignedMembers, optimalSetup, roleIndex["RANGE_DPS"])
					elseif cmd == "autosplit_healer" then
						unassignedMembers, optimalSetup = AutoSplit(unassignedMembers, optimalSetup, roleIndex["HEALER"])
					elseif cmd == "dynbg" then
						unassignedMembers, optimalSetup = DynamicBGArrange(unassignedMembers)
						if not optimalSetup then
							cout(loc.badlocationerr)
							return false
						else
							return optimalSetup
						end
					elseif cmd == "go" then
						sc = FindLineNumber(sc, tc, template)
						if sc and sc > tc then
							tc = sc - 1
						else
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: go anchorName | # (# must be > the current index)")
							return false
						end
					elseif cmd == "pass" then
						sc = tonumber(sc)
						if sc and sc > 0 then
							minPass = sc
						else
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: pass # (# must be > 0")
							return false
						end
					elseif cmd == "limit" then
						limits = ValidateLimits(strsplit(",", sc))
						if not limits then
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: limit \<limitations\>\nSee templates.lua for limitations syntax.")
							return false
						end
					elseif cmd == "nolimit" then
						limits = nil
					elseif cmd == "decursewhich" then
						local whichDecurse = ValidateDecurseWhich(strsplit(",", sc))
						if not whichDecurse then
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: decursewhich any | TYPE\[,TYPE\[,TYPE\[,TYPE\]\]\]")
							return false
						end
						currentDecurserMeanings = CopyTable(whichDecurse)
					elseif cmd == "group" then
						OKGroups = ValidateGroups(strsplit(",", sc))
						if not OKGroups then
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: group #\[,#\[,#\[,#\[,#\[,#\[,#\[,#\]\]\]\]\]\]\]")
							return false
						end
					elseif cmd == "spec" then
						local n,g = sc:match("(.+) (.+)")

						g = FindLineNumber(g, tc, template)

						if g and g > tc and n and roleIndex[n] then
							if FindInGroup(group, n) then
								tc = g - 1
							end
						else
							eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: spec ROLE anchorName|# (# must be > the current index)")
							return false
						end
					elseif cmd == "end" then
						tc = #template
					end
				end
			end
		elseif type(template[tc]) == "table" then
			if not ValidateTemplateTable(template[tc]) then
				eout("Bad user template. Please select another template or use the default. Aborting. Error at index " .. tc .. ". Usage: {class\|nil, prefSpec, requirePref?\[, ignoreSpec\|nil\[, loop?\]\]}")
				return false
			end
			if ((not OKGroups) or myTFind(OKGroups, x)) and (currPass >= minPass) then
				class, prefSpec, requirePref, ignoreSpec, loopWhile = template[tc][1], template[tc][2], template[tc][3], template[tc][4], template[tc][5]
				if prefSpec then
					prefSpec = roleIndex[prefSpec]
				end
				if ignoreSpec then
					ignoreSpec = roleIndex[ignoreSpec]
				end
				myForeachi(unassignedMembers, HandleMatchup)
				while loopWhile and tcount(group) < 5 and match do
					myForeachi(unassignedMembers, HandleMatchup)
				end
			end
		end
	end

	--optimalSetup[x] = group --(shouldn't need to do this)
	if topLevel then
		optimalSetup = GrOM.Arrange(optimalSetup, unassignedMembers)
		if not optimalSetup then return end
		_, optimalSetup = PushExtrasToLower(topLevel, optimalSetup)
		return optimalSetup
	else
		return GrOM.Arrange(optimalSetup, unassignedMembers)
	end
end

local function UMfind(t, n)
	for i = 1, #t do
		for j = 1, #t[i] do
			if t[i][j] == n then
				return true
			end
		end
	end
end

--return the index in unassignedMembers that corrisponds to a member with the same roles as find/class as byClass, which is not in restoreState
local function FindSimilarExtantMember(restoreState, unassignedMembers, find, byClass)
	if not (find or byClass) then
		return false
	end

	for i = 1, #unassignedMembers do		
		if not UMfind(restoreState, GetPVEorPVPUName("raid"..unassignedMembers[i])) then --if the person is not in the restore
			local matchS = true
			if byClass then
				if (not GrOM_Vars.classByNameCache[byClass]) or GrOM_Vars.classByNameCache[byClass] ~= select(2, UnitClass("raid"..unassignedMembers[i]) ) then
					matchS = false
				end
			else
				local a = currentRaidGroupRolesByIndex[unassignedMembers[i] ]
				for j = 1, 12 do
					if a[j] ~= find[j] then
						matchS = false
						break
					end
				end
			end
			
			if matchS then
				return i
			end
		end
	end

	return false
end

function GrOM.RestoreRaid(restoreState)
	if GetNumGroupMembers() < 2 then
		return
	end

	if GrOM_Vars.userTemplateToUse == "AB_EOTS_AUTO_AKRYN" then
		lastTemplate = GrOM_Vars.userTemplateToUse
		GrOM_Vars.userTemplateToUse = nil
	end

	GrOM.ARRANGE_BREAK = 0

	local _,_,rModeA, rModeB = GrOM.GetCurrentRestoreMethod()
	local rModeC = false
	
	rModeC = (rModeA == "armchair")
	rModeA = (rModeA == "smart")
	rModeB = (rModeB == "separate")
	
	resetErrorTimer = 0
	groupFullErr = false
	if optimalRaidGroupPlacement then wipe(optimalRaidGroupPlacement) end
	optimalRaidGroupPlacement = {}

	BuildRolesByIndexTable()
	BuildIndexByNameTable()

	FillInEmptyRoles(1)

	local optimalSetup, unassignedMembers = {{},{},{},{},{},{},{},{}}, GetAllRaidIDs()

	local i, j, k = 0, 0, 0

	if rModeA or rModeC then
		for rmac = 1, 8 do
			local rmav = restoreState[rmac]
			if rmav then
				for rmacb = 1, #rmav do			
					if not currentRaidGroupIndexByName[rmav[rmacb] ] then  --if this person isn't in the raid
						local byClass = nil
						if rModeC then
							byClass = rmav[rmacb]
						end						
						local rmanew = FindSimilarExtantMember(restoreState, unassignedMembers, RolesNumToTable(GrOM_Vars.rolesByNameCache[rmav[rmacb] ]), byClass)
						if rmanew then
							table.insert(optimalSetup[rmac], table.remove(unassignedMembers, rmanew))
						end
					end
				end
			end
		end
	end

	while i < #unassignedMembers do
		i = i + 1
		j=0
		while j < 8 do
			j = j + 1
			k=0
			local z = restoreState[j]
			if not z then
				break
			end
			while k < #z do
				k = k + 1

				local y = z[k]
				if y and currentRaidGroupIndexByName[y] and (unassignedMembers[i] == currentRaidGroupIndexByName[y]) then
					table.insert(optimalSetup[j], table.remove(unassignedMembers, i))
					i = i - 1
					j, k = 9, 6
				end
			end
		end
	end

	if rModeB and #unassignedMembers > 0 then
		i = 0
		while i < #unassignedMembers do
			i = i + 1
			for j=8, 1, -1 do
				if #optimalSetup[j] < 5 then
					table.insert(optimalSetup[j], table.remove(unassignedMembers, i))
					i = i - 1
					break
				end
			end
		end
	end

	ignoredExcluded = false

	optimalSetup = GrOM.Arrange(optimalSetup, unassignedMembers)

	if not optimalSetup then
		return
	end

	local g = 1

	local group = optimalSetup[g]

	while group and group ~= {} do
		for i=1, 5 do
			if group[i] then
				optimalRaidGroupPlacement[group[i]] = g
			end
		end
		g = g + 1
		group = optimalSetup[g]
	end

	GrOM.CreateArrangementFrame()
end

function GrOM.SaveRaid(name)
	GrOM.SaveName = nil

	local raid = {{},{},{},{},{},{},{},{}}

	for i=1, 40 do
		local n, _, g = GetRaidRosterInfo(i)
		if n and not (GrOM_Vars.excludeSaves and GrOM_Vars.exclude[g]) then
			table.insert(raid[g], n)
		end
	end

	GrOM_Vars.SavedRaidLayouts[name] = raid

	GrOM.UpdateButtons()
	GrOM.UpdateSavesPane()

	cout(string.format(loc.raidsaved, name))
end

function GrOM.DeleteAllSavedRaids()
	GrOM_Vars.SavedRaidLayouts = {}

	GrOM.UpdateButtons()
	GrOM.UpdateSavesPane()

	cout(loc.deletedall)
end

local raidNamesByIndex = {}
local lastRaidIndexSetup = {}

local function BuildNamesByIndexTable(ret)
	local t = ret and {} or raidNamesByIndex
	
	for i = 1, 40 do
		t[i] = GetRaidRosterInfo(i)
	end

	return t
end

local function CheckForIndexMove()
	local x, y = lastRaidIndexSetup, currentRaidGroupPlacement

	if not (x and y) then return true end
	
	for i = 1, #y do
		if x[i] ~= y[i] then
			return true
		end
	end

	return false
end

local function CheckForMove()
	BuildNamesByIndexTable()

	local x, y = lastRaidSetup, raidNamesByIndex

	if not (x and y) then return true end
	
	for i = 1, #y do
		if x[i] ~= y[i] then
			return true
		end
	end

	return false
end

local function GrOM_SetRaidSubgroup(i, g)
	table.insert(movementQueue, {"set", i, g})
	table.insert(lockedIDs, i)
	currentRaidGroupPlacement[i] = g --hopefully we don't need to check if this group is full here
	queuedSetsByGroup[g] = queuedSetsByGroup[g] - 1
	if queuedSetsByGroup[g] < 1 then
		table.insert(lockedGroups, g)
	end
end

local function GrOM_SwapRaidSubgroup(i1, i2)
	table.insert(movementQueue, {"swap", i1, i2})
	table.insert(lockedIDs, i1)
	table.insert(lockedIDs, i2)
	local x = currentRaidGroupPlacement[i1]
	currentRaidGroupPlacement[i1] = currentRaidGroupPlacement[i2]
	currentRaidGroupPlacement[i2] = x
end

local currentExecutionPlacementGoal = nil

local function EnsureIndexFidelity()
	BuildNamesByIndexTable()

	local rn, ot, otn = raidNamesByIndex, optimalRaidGroupPlacement, currentExecutionOptimalPlacementByName

	for i=1, 40 do
		ot[i] = rn[i] and otn[rn[i]] or false
	end
end

local function ExecuteQueuedMoves()
	lockedIDs = {}
	lockedGroups = {}
	queuedSetsByGroup = {5,5,5,5,5,5,5,5}
	currentExecutionPlacementGoal = CopyTable(currentRaidGroupPlacement)
	BuildCurrentPlacementTable()	

	if #movementQueue < 1 then
		return false
	end

	while #movementQueue > 0 do
		local move = table.remove(movementQueue)
		if move[1] == "set" then
			L_SetRaidSG(move[2], move[3])
		else
			L_SwapRaidSG(move[2], move[3])
		end
	end

	return true
end

local function BuildQueuedSetsTable() --this table represents the number of times we can queue a SetRaidSubgroup call for each group
	queuedSetsByGroup = {5,5,5,5,5,5,5,5}

	for i = 1, 40 do
		if currentRaidGroupPlacement[i] then
			local x = currentRaidGroupPlacement[i]

			if x > 0 and x < 9 then
				queuedSetsByGroup[x] = queuedSetsByGroup[x] - 1

				if queuedSetsByGroup[x] < 1 then
					table.insert(lockedGroups, x)
				end
			end
		end
	end
end

--[[local function RaidIsAtGoalState()
	local x = currentExecutionPlacementGoal
	local y = currentRaidGroupPlacement

	if not x then return true end

        if #x ~= #y then
                return false
        end

        for i = 1, #y do
                if not x[i] or x[i] ~= y[i] then
                        return false
                end
        end

        return true
end]]

local function DoArrangement()
	if L_InCombatLockdown() then
		GrOM.Cancel()
		dout(loc.combaterr)
		cout(loc.combaterr)
	end

	if resetErrorTimer + GrOM.resetErrorConditionThrottle < GetTime() then
		resetErrorTimer = GetTime()
		groupFullErr = false
		lastRaidSetup = nil
		--currentExecutionPlacementGoal = nil
		movementQueue = {}
		lockedIDs = {}
		lockedGroups = {}
		queuedSetsByGroup = {5,5,5,5,5,5,5,5}
	end

	if GrOM.ArrangementFrameBreakCounter > GrOM.ArrangementFrameBreakMaximum then
		if not groupFullErr then
			StaticPopup_Show("GOMatic_ERROR_TOOMANYFAILEDMOVES")
		end
		delayedActionInProgress = false
		GrOM.UpdateButtons()
		GOMatic_ArrangementFrame:SetScript("OnUpdate", nil)
		GOMatic_ArrangementFrame:SetScript("OnEvent", nil)
	end

	GOMatic_ArrangementFrameLastUpdate = GetTime()

	if not movementQueue[1] then
		if BuildCurrentPlacementTable() then
			return false
		end
		if not (CheckForMove() or CheckForIndexMove()) then
			return false
		end
		lastRaidIndexSetup = CopyTable(currentRaidGroupPlacement)
	end

	EnsureIndexFidelity()
	lastRaidSetup = CopyTable(raidNamesByIndex)
	BuildQueuedSetsTable()
	RepairOptimalPlacementTable()

	if #movementQueue >= GrOM_Vars.autoThrottle then
		return ExecuteQueuedMoves()
	end

	local emptySlot, raidIDToMove = FindEmptySlot()

	if raidIDToMove and (emptySlot > 0) and (emptySlot < 9) and (not groupFullErr) then
		GrOM_SetRaidSubgroup(raidIDToMove, emptySlot)
		return DoArrangement()
	end

	local raidIDToMove, currentGroup, destGroup = FindUnmovedID()

	if not raidIDToMove then
		return ExecuteQueuedMoves()
	end

	local raidIDToMoveB = FindIDToMoveToGroup(currentGroup, destGroup)

	if raidIDToMoveB then
		GrOM_SwapRaidSubgroup(raidIDToMove, raidIDToMoveB)
	else
		raidIDToMoveB = FindUnmovedID(currentGroup)
		if not raidIDToMoveB then
			return ExecuteQueuedMoves()
		end

		GrOM_SwapRaidSubgroup(raidIDToMove, raidIDToMoveB)
	end

	return DoArrangement()
end

function GrOM.RaidIsArranged()
	local isArranged = true

	if FindUnmovedID() then
		isArranged = false
	end

	if isArranged then
		cout(loc.arrangedone)
	end

	return isArranged
end

function GOMatic_ArrangementFrame_OnEvent(self, event, arg1)
	if arg1:find(ERR_RAID_MEMBER_REMOVED_S:format("(.+)")) or arg1:match(ERR_RAID_YOU_LEFT) then
		StaticPopup_Show("GOMatic_AUTO_ABORT")
		delayedActionInProgress = false
		GrOM.UpdateButtons()
		self:SetScript("OnUpdate", nil)
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", nil)
	end
end

function GOMatic_ArrangementFrame_OnUpdate(self)
	if (GrOM.ArrangementFrameUpdateThrottle + GOMatic_ArrangementFrameLastUpdate < GetTime()) then
		if GrOM.RaidIsArranged() then
			if lastTemplate then
				if lastTemplate == "GrOM_DEFAULT_TEMPLATE" then
					GrOM_Vars.userTemplateToUse = nil
				else
					GrOM_Vars.userTemplateToUse = lastTemplate
				end
				lastTemplate = nil
			end

			delayedActionInProgress = false
			GrOM.UpdateButtons()
			self:SetScript("OnUpdate", nil)
			self:UnregisterEvent("CHAT_MSG_SYSTEM")
			self:SetScript("OnEvent", nil)
			pcall(GrOM.WipeTables)
			return
		end

		if not (UnitIsGroupLeader("player") or UnitIsRaidOfficer("player")) then
			dout("Abort due to player demotion.")
			delayedActionInProgress = false
			GrOM.UpdateButtons()
			self:SetScript("OnUpdate", nil)
			self:UnregisterEvent("CHAT_MSG_SYSTEM")
			self:SetScript("OnEvent", nil)
			return
		end

		lockedIDs = {}
		lockedGroups = {}
		movementQueue = {}		
		queuedSetsByGroup = {5,5,5,5,5,5,5,5}

		local x = (DoArrangement()) and 0 or 1
		if x == 0 then
			currentExecutionPlacementGoal = nil
		end
		GrOM.ArrangementFrameBreakCounter = GrOM.ArrangementFrameBreakCounter + x
	end
end

function GrOM.WipeTables()
	wipe(optimalRaidGroupPlacement)
	wipe(raidNamesByIndex)
	wipe(lastRaidIndexSetup)
	wipe(lockedIDs)
	wipe(lockedGroups)
	wipe(queuedSetsByGroup)
	wipe(currentExecutionPlacementGoal)
	wipe(currentRaidGroupPlacement)
	wipe(movementQueue)
	wipe(currentRaidGroupIndexByName)
	wipe(lastRaidSetup)
	wipe(currentExecutionOptimalPlacementByName)
	if not InCombatLockdown() then
		collectgarbage()
	end
end

------------------------------------------------------------------------------
--GUI
------------------------------------------------------------------------------

function GrOM.LoadGUIFunctions()
	GrOM.RestoreVsSave = true

	function GrOM.ShowRestoreMenu()
		CancelIfAuto()

		if delayedActionInProgress then
			cout(loc.pleasewaiterr)
			return
		end

		GrOM.RestoreVsSave = true
		ToggleDropDownMenu(1, nil, GOMaticDropDown, "GOMaticRestore", 70, 0)
	end

	function GrOM.ShowSaveMenu()
		GrOM.RestoreVsSave = false
		ToggleDropDownMenu(1, nil, GOMaticDropDown, "GOMaticSave", 70, 0)
	end

	function GrOM.AddSaveOrRestoreMenuItem(k)
		local info = UIDropDownMenu_CreateInfo()

		info.text = k

		if not GrOM.RestoreVsSave then
			info.func = function(self, arg1, arg2) GOMaticDropdown_DoSaveMenuItem(arg1, arg2) end
			info.arg1 = nil
			info.arg2 = k
		else
			info.func = GOMaticDropdown_DoRestoreMenuItem
			info.arg1 = k
		end

		UIDropDownMenu_AddButton(info)
	end

	function GrOM.GetCurrentTemplate()
		if not GrOM_Vars.userTemplateToUse then
			return loc.defaultname, loc.defaultname
		end

		local name = nil

		if type(GrOM_Vars.userTemplateToUse) == "string" then
			name = GrOM.userTemplates[GrOM_Vars.userTemplateToUse]
		else
			name = GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse]
		end

		if name and type(name) == "table" then
			name = name[1]
			local full = name

			if name and type(name) == "string" then
				if name:len() > 34 then
					name = name:sub(1, 32) .. "..."
				end

				return full, name
			end
		end

		GrOM_Vars.userTemplateToUse = nil
		return GrOM.GetCurrentTemplate()
	end

	local currentExtras = "none"

	function GrOM.GetCurrentExtrasPane()
		local name, shortname, default = nil, nil, nil

		if currentExtras == "none" then
			name = loc.extrasmenuitem
			default = true
		elseif currentExtras == "exclude" then
			name = loc.excludemenuitem
		elseif currentExtras == "throttle" then
			name = loc.throttlemenuitem
		elseif currentExtras == "ignore" then
			name = loc.ignoremenuitem
		elseif currentExtras == "MVPs" then
			name = loc.mvpsmenuitem
		elseif currentExtras == "sync" then
			name = loc.syncmenuitem
		elseif currentExtras == "onmemberadd" then
			name = loc.memberaddmenuitem
		elseif currentExtras == "saves" or currentExtras == "saves2" then
			name = loc.savesmenuitem
		elseif currentExtras == "eztemplate" or currentExtras == "eztemplate2" then
			name = loc.eztemplatesname
		end

		if not name then return "???","???",false end

		if name:len() > 13 then
			shortname = name:sub(1, 13) .. "..."
		else
			shortname = name
		end

		return name, shortname, default
	end

	--[[
	function GrOM.GetEnglishSpec(locSpec)
		local engSpec
	
		if not engSpec then
			return locSpec
		end

		return engSpec
	end

	function GrOM.GetEnglishClass(locClass)
		local engClass

		if not engClass then
			return locClass
		end

		return engClass
	end]]

	function GOMaticDropdown_DoTemplateMenuItem(self, key)
		local template = nil

		if type(key) == "string" then
			template = GrOM.userTemplates[key]
		else
			template = GrOM_Vars.ezTemplates[key]
		end

		if template and ValidateTemplate(template) then
			GrOM_Vars.userTemplateToUse = key
		else
			GrOM_Vars.userTemplateToUse = nil
		end

		local x, y = GrOM.GetCurrentTemplate()

		UIDropDownMenu_SetSelectedValue(GOMaticTemplateMenu, x)
		GOMaticTemplateMenuText:SetText(y)
	end

	function GrOM.AddEZTemplateMenuItem(ix, template)
		local info = UIDropDownMenu_CreateInfo()

		local n = "???"

		if type(template) == "table" then
			if template[1] and type(template[1]) == "string" then
				n = template[1]
			end
		end

		info.text = n
		info.func = GOMaticDropdown_DoTemplateMenuItem
		info.arg1 = ix
		UIDropDownMenu_AddButton(info)
	end

	function GrOM.AddTemplateMenuItem(key, template)
		local info = UIDropDownMenu_CreateInfo()

		local n = "???"

		if type(template) == "table" then
			if template[1] and type(template[1]) == "string" then
				n = template[1]
			end
		end

		info.text = n
		info.func = GOMaticDropdown_DoTemplateMenuItem
		info.arg1 = key
		UIDropDownMenu_AddButton(info)
	end

	GrOM.LastMenuClicked = nil

	local function EZTemplateMenuButtonOnClick(self, x, y)
		UIDropDownMenu_SetSelectedValue(GrOM.LastMenuClicked, x)
		if x:len() > 15 then
			x = x:sub(1, 13).."..."
			_G[GrOM.LastMenuClicked:GetName().."Text"]:SetText(x)
		end
		GrOM.LastMenuClicked.myVal = y
	end

	function GrOM.SpecDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		--any
		info.text = loc.any
		info.func = EZTemplateMenuButtonOnClick
		info.arg1 = loc.any
		info.arg2 = loc.any
		UIDropDownMenu_AddButton(info)

		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		for k in pairs(roleIndex) do
			if k ~= "MAIN_TANK" then
				info = UIDropDownMenu_CreateInfo()
				info.text = loc.roles[k]
				info.func = EZTemplateMenuButtonOnClick
				info.arg1 = loc.roles[k]
				info.arg2 = k
				UIDropDownMenu_AddButton(info)
			end
		end
	end

	function GrOM.PrefSpecDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		for k in pairs(roleIndex) do
			if (k ~= "DAMAGER") and (k ~= "NONE") then
				info = UIDropDownMenu_CreateInfo()
				info.text = loc.roles[k]
				info.func = EZTemplateMenuButtonOnClick
				info.arg1 = loc.roles[k]
				info.arg2 = k
				UIDropDownMenu_AddButton(info)
			end
		end
	end

	function GrOM.IgnoreSpecDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		--none
		info.text = loc.none
		info.func = EZTemplateMenuButtonOnClick
		info.arg1 = loc.none
		info.arg2 = loc.none
		UIDropDownMenu_AddButton(info)

		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		for k in pairs(roleIndex) do
			if k ~= "MAIN_TANK" then
				info = UIDropDownMenu_CreateInfo()
				info.text = loc.roles[k]
				info.func = EZTemplateMenuButtonOnClick
				info.arg1 = loc.roles[k]
				info.arg2 = k
				UIDropDownMenu_AddButton(info)
			end
		end
	end

	function GrOM.ClassDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		--any
		info.text = loc.any
		info.func = EZTemplateMenuButtonOnClick
		info.arg1 = loc.any
		info.arg2 = loc.any
		UIDropDownMenu_AddButton(info)

		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		for k in pairs(FillLocalizedClassList(loc.classes)) do
			info = UIDropDownMenu_CreateInfo()
			info.text = loc.classes[k]
			info.func = EZTemplateMenuButtonOnClick
			info.arg1 = loc.classes[k]
			info.arg2 = k
			UIDropDownMenu_AddButton(info)
		end
	end

	function GrOM.GetCurrentAutoPlace()
		local name = GrOM_Vars.autoPlacementSave

		if not name then
			return loc.none, loc.none
		end

		if type(name) == "string" then
			local full = name

			if name:len() > 18 then
				name = name:sub(1, 16) .. "..."
			end

			return full, name
		end

		GrOM_Vars.autoPlacementSave = nil
		return GrOM.GetCurrentAutoPlace()
	end

	function GrOM.GetCurrentAutoAuto(n)
		if not (GrOM_Vars.autoAutoArrange and GrOM_Vars.autoAutoArrange[n]) then
			return loc.none, loc.none
		end

		local name = nil

		if type(GrOM_Vars.autoAutoArrange[n]) == "string" then
			if GrOM_Vars.autoAutoArrange[n] == "GrOM_DEFAULT_TEMPLATE" then
				return loc.defaultname, loc.defaultname
			end
			name = GrOM.userTemplates[GrOM_Vars.autoAutoArrange[n]]
		else
			name = GrOM_Vars.ezTemplates[GrOM_Vars.autoAutoArrange[n]]
		end

		if name and type(name) == "table" then
			name = name[1]
			local full = name

			if name and type(name) == "string" then
				if name:len() > 18 then
					name = name:sub(1, 16) .. "..."
				end

				return full, name
			end
		end

		GrOM_Vars.autoAutoArrange[n] = nil
		return loc.none, loc.none
	end

	local function SetAutoPlaceOption(self, n)	
		GrOM_Vars.autoPlacementSave = n
	
		UIDropDownMenu_SetSelectedValue(GOMaticAutoPlaceMenu, GrOM.GetCurrentAutoPlace())
		GOMaticAutoPlaceMenuText:SetText(select(2,GrOM.GetCurrentAutoPlace()))
	end

	local function SetAutoAutoOption(self, num, n)
		if not GrOM_Vars.autoAutoArrange then
			GrOM_Vars.autoAutoArrange = {}
		end
	
		GrOM_Vars.autoAutoArrange[num] = n
		UIDropDownMenu_SetSelectedValue(_G["GOMaticAutoAutoMenu" .. tostring(num)], GrOM.GetCurrentAutoAuto(num))
		_G["GOMaticAutoAutoMenu" .. tostring(num) .. "Text"]:SetText(select(2,GrOM.GetCurrentAutoAuto(num)))
	end

	function GrOM.AutoPlaceMenu_Initialize()
		local info
	
		--none
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.none
		info.func = SetAutoPlaceOption
		info.arg1 = nil
		UIDropDownMenu_AddButton(info)
	
		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

	
		foreach(GrOM_Vars.SavedRaidLayouts, function(k, v)
			info = UIDropDownMenu_CreateInfo()
			info.text = k
			info.func = SetAutoPlaceOption
			info.arg1 = k
			UIDropDownMenu_AddButton(info)
		end)
	end

	local function AutoAutoMenu_Initialize(n)
		local info = UIDropDownMenu_CreateInfo()

		--none
		info.text = loc.none
		info.func = SetAutoAutoOption
		info.arg1 = n
		info.arg2 = nil
		UIDropDownMenu_AddButton(info)
	
		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		--default
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.defaultname
		info.func = SetAutoAutoOption
		info.arg1 = n
		info.arg2 = "GrOM_DEFAULT_TEMPLATE"
		UIDropDownMenu_AddButton(info)

		foreach(GrOM.userTemplates, function(k,v)
			info = UIDropDownMenu_CreateInfo()
			info.text = v[1] or "Unknown"
			info.func = SetAutoAutoOption
			info.arg1 = n
			info.arg2 = k
			UIDropDownMenu_AddButton(info)
		end)

		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		--ez templates
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.eztemplatesname..":"
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		foreachi(GrOM_Vars.ezTemplates, function(k,v)
			info = UIDropDownMenu_CreateInfo()
			info.text = v[1] or "Unknown"
			info.func = SetAutoAutoOption
			info.arg1 = n
			info.arg2 = k
			UIDropDownMenu_AddButton(info)
		end)
	end

	function GrOM.AutoAutoMenu1_Initialize()
		AutoAutoMenu_Initialize(1)
	end

	function GrOM.AutoAutoMenu2_Initialize()
		AutoAutoMenu_Initialize(2)
	end

	function GrOM.AutoAutoMenu3_Initialize()
		AutoAutoMenu_Initialize(3)
	end

	function GOMaticRestoreMethodDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		--Dumb - Merge (default)
		info.text = loc.restoremethodpattern:format(loc["dumb"],loc["merge"]) .. loc.defaultmethod
		info.func = GrOM.SetRestoreMode
		info.arg1 = "dumb"
		info.arg2 = "merge"
		UIDropDownMenu_AddButton(info)

		--Dumb - Separate
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.restoremethodpattern:format(loc["dumb"],loc["separate"])
		info.func = GrOM.SetRestoreMode
		info.arg1 = "dumb"
		info.arg2 = "separate"
		UIDropDownMenu_AddButton(info)

		--Smart - Merge
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.restoremethodpattern:format(loc["smart"],loc["merge"])
		info.func = GrOM.SetRestoreMode
		info.arg1 = "smart"
		info.arg2 = "merge"
		UIDropDownMenu_AddButton(info)

		--Smart - Separate
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.restoremethodpattern:format(loc["smart"],loc["separate"])
		info.func = GrOM.SetRestoreMode
		info.arg1 = "smart"
		info.arg2 = "separate"
		UIDropDownMenu_AddButton(info)
	
		--Armchair - Merge
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.restoremethodpattern:format(loc["armchair"],loc["merge"])
		info.func = GrOM.SetRestoreMode
		info.arg1 = "armchair"
		info.arg2 = "merge"
		UIDropDownMenu_AddButton(info)

		--Armchair - Separate
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.restoremethodpattern:format(loc["armchair"],loc["separate"])
		info.func = GrOM.SetRestoreMode
		info.arg1 = "armchair"
		info.arg2 = "separate"
		UIDropDownMenu_AddButton(info)
	end

	function GrOM.SetRestoreMode(self, mode1, mode2)
		if type(self) == "string" then
			mode2 = mode1
			mode1 = self
		end
		GrOM_Vars.restoreMethod = mode1.."-"..mode2
		UIDropDownMenu_SetSelectedValue(GOMaticRestoreMethodMenu, GrOM.GetCurrentRestoreMethod())
		GOMaticRestoreMethodMenuText:SetText(select(2,GrOM.GetCurrentRestoreMethod()))
	end

	function GrOM.GetCurrentRestoreMethod()
		local a, b = loc[GrOM_Vars.restoreMethod:match("^([^%-]+)-")], loc[GrOM_Vars.restoreMethod:match("-([^%-]+)")]
		local name = loc.restoremethodpattern:format(a,b)

		local short = name
		if name:len() > 15 then
			short = name:sub(1, 15) .. "..."
		end

		if GrOM_Vars.restoreMethod == "dumb-separate" then
			name = name .. loc.defaultmethod
		end

		return name, short, GrOM_Vars.restoreMethod:match("^([^%-]+)-"), GrOM_Vars.restoreMethod:match("-([^%-]+)")
	end

	function GrOM.TrueCloseExtrasPane()
		GrOM.CloseExtrasPane(true)
	end

	function GOMaticExtrasDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		--nothing/default
		if select(3, GrOM.GetCurrentExtrasPane()) then
			info.text = loc.extrasmenuitem
		else
			info.text = loc.closemenuitem
		end
		info.func = GrOM.TrueCloseExtrasPane
		UIDropDownMenu_AddButton(info)

		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		--excludes
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.excludemenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "exclude"
		UIDropDownMenu_AddButton(info)
--[[
		--arrangement throttle
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.throttlemenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "throttle"
		UIDropDownMenu_AddButton(info)
]]
		--ignore dead/offline/lowbies
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.ignoremenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "ignore"
		UIDropDownMenu_AddButton(info)
--[[
		--MVPs
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.mvpsmenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "MVPs"
		UIDropDownMenu_AddButton(info)
]]
		--Saves
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.savesmenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "saves"
		UIDropDownMenu_AddButton(info)
--[[
		--MemberAdd
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.memberaddmenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "onmemberadd"
		UIDropDownMenu_AddButton(info)	
]]
		--EZ Templates
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.eztemplatesname
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "eztemplate"
		UIDropDownMenu_AddButton(info)
--[[
		--Sync
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.syncmenuitem
		info.func = GrOM.OpenExtrasPane
		info.arg1 = "sync"
		UIDropDownMenu_AddButton(info)
]]
	end

	function GOMaticTemplateDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		info.text = loc.defaultname
		info.func = GOMaticDropdown_DoTemplateMenuItem
		info.arg1 = nil
		UIDropDownMenu_AddButton(info)

		foreach(GrOM.userTemplates, GrOM.AddTemplateMenuItem)

		--blank
		info = UIDropDownMenu_CreateInfo()
		info.text = "   "
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		--ez templates
		info = UIDropDownMenu_CreateInfo()
		info.text = loc.eztemplatesname..":"
		info.isTitle = 1
		UIDropDownMenu_AddButton(info)

		foreachi(GrOM_Vars.ezTemplates, GrOM.AddEZTemplateMenuItem)
	end

	function GOMaticDropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()

		if not GrOM.RestoreVsSave then
			info.text = loc.newmenuitem
			info.func = function(self, arg1, arg2) GOMaticDropdown_DoSaveMenuItem(arg1, arg2) end
			info.arg1 = true
			UIDropDownMenu_AddButton(info)

			info = UIDropDownMenu_CreateInfo()
			info.text = "   "
			info.isTitle = 1
			UIDropDownMenu_AddButton(info)
		end

		foreach(GrOM_Vars.SavedRaidLayouts, GrOM.AddSaveOrRestoreMenuItem)

		if GrOM.RestoreVsSave then
			info = UIDropDownMenu_CreateInfo()
			info.text = "   "
			info.isTitle = 1
			UIDropDownMenu_AddButton(info)

			info = UIDropDownMenu_CreateInfo()
			info.text = loc.deleteallmenuitem
			info.func = function(self, arg1) StaticPopup_Show(arg1) end
			info.arg1 = "GOMatic_DELETE_ALL_SAVES"
			UIDropDownMenu_AddButton(info)
		end
	end

	function GOMaticDropdown_DoSaveMenuItem(isNew, sc)
		if isNew then
			StaticPopup_Show("GOMatic_NEW_SAVE")
			return
		end
		if sc then
			if GrOM_Vars.SavedRaidLayouts[sc] then
				GrOM.SaveName = sc
				StaticPopup_Show("GOMatic_DO_SAVE", sc)
			else
				GrOM.SaveRaid(sc)
			end
		end
	end

	function GOMaticDropdown_DoRestoreMenuItem(self, sc)
		if sc then
			local n = GrOM_Vars.SavedRaidLayouts[sc]
			if n then
				lastAction = {true, sc}
				GrOM.RestoreRaid(n)
			end
		end
	end

	function GrOM.UpdateButtons(combat)
		if GrOM.guiUnloaded then return end
		CloseMenus()

		local x = InCombatLockdown()
		if combat then
			if combat == 1 then
				x = true
			elseif combat == 0 then
				x = false
			end
		end

		if ArrangeProxy and ArrangeProxy.Ready() then
			x = false
		end

		if x then
			if delayedActionInProgress then
				GOMaticAuto:Disable()
				GOMaticPing:Disable()
				GOMaticRestore:Disable()
				GOMaticCancel:Disable()
			else
				GOMaticAuto:Disable()
				GOMaticPing:Enable()
				GOMaticRestore:Disable()
				GOMaticCancel:Disable()
			end
		else
			if delayedActionInProgress and (not currentScanIsAuto) then
				GOMaticAuto:Disable()
				GOMaticPing:Disable()
				GOMaticRestore:Disable()
				GOMaticCancel:Enable()
			else
				GOMaticAuto:Enable()
				GOMaticPing:Enable()

				if tcount(GrOM_Vars.SavedRaidLayouts) > 0 then
					GOMaticRestore:Enable()
				else
					GOMaticRestore:Disable()
				end

				GOMaticCancel:Disable()
			end
		end
	end

	function GrOM.UpdateAutoThrottle(value)
		GrOM_Vars.autoThrottle = value
		GOMaticThrottleText:SetText(loc.throttletext:format(GrOM_Vars.autoThrottle))
	end

	local checkBoxes = {}

	local function CreateExcludeCheck(num)
		if checkBoxes["box" .. num] then
			return false
		end

		local f = CreateFrame("CheckButton", "GOMaticExcludeCheck" .. num, GOMatic, "OptionsCheckButtonTemplate")
		f:SetScript("OnClick", function(self)
			GrOM_Vars.exclude[num] = self:GetChecked()
			for i = 1, 8 do
				if i < num then
					GrOM_Vars.exclude[i] = false
					_G["GOMaticExcludeCheck"..i]:SetChecked(false)
				elseif i > num and self:GetChecked() then
					GrOM_Vars.exclude[i] = true
					_G["GOMaticExcludeCheck"..i]:SetChecked(true)
				end
			end
		end)
		f:SetScript("OnShow", function(self) self:SetChecked(GrOM_Vars.exclude[num]) GrOM.UIFrameFadeIn(self, .3, 0, 1) end)
		f:Hide()
		local textField = _G[f:GetName() .. "Text"]
		--textField:ClearAllPoints()
		--textField:SetPoint("BOTTOMLEFT", f, "TOPLEFT")
		textField:SetText(loc.grouplabel .. num)
		f:SetChecked(GrOM_Vars.exclude[num])
		f:SetHitRectInsets(0, -40, 0, 0)
		f:SetFrameLevel(GOMatic:GetFrameLevel()+1)
		f:Hide()

		return f
	end

	local function ExcludeHide(resize)
		for i = 1, 8 do
			checkBoxes["box" .. i]:Hide()
		end

		GOMaticExcludeText:Hide()
		GOMaticExcludeSaves:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + 90)
		end

		return 90
	end

	local function ExcludeShow(yOffset)
		checkBoxes["box1"] = CreateExcludeCheck(1) or checkBoxes["box1"]
		checkBoxes["box1"]:Show()
		checkBoxes["box1"]:ClearAllPoints()
		checkBoxes["box1"]:SetPoint("TOPLEFT", "GOMaticHide", "BOTTOMLEFT", 0, -30)

		for i = 2, 8 do
			checkBoxes["box" .. i] = CreateExcludeCheck(i) or checkBoxes["box" .. i]
			checkBoxes["box" .. i]:Show()
			checkBoxes["box" .. i]:ClearAllPoints()
			if i == 5 then
				checkBoxes["box5"]:SetPoint("TOP", checkBoxes["box1"], "BOTTOM", 0, -3)
			else
				checkBoxes["box" .. i]:SetPoint("LEFT", checkBoxes["box" .. i - 1], "RIGHT", 65, 0)
			end
		end

		GOMaticExcludeText:Show()
		GrOM.UIFrameFadeIn(GOMaticExcludeText, .3, 0, 1)
		GOMaticExcludeSaves:Show()

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(256)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - 90 + yOffset)
	end

	local function ThrottleShow(yOffset)
		GOMaticThrottleSlider:Show()
		GOMaticThrottleText:Show()
		GrOM.UIFrameFadeIn(GOMaticThrottleText, .3, 0, 1)

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(226)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - 60 + yOffset)
	end

	local function ThrottleHide(resize)
		GOMaticThrottleSlider:Hide()
		GOMaticThrottleText:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + 60)
		end

		return 60
	end

	local function SavesShow(yOffset)
		local h = 220

		GOMaticSavesScrollFrame:Show()
		GOMaticDeleteSave:Show()
		GOMaticRenameSave:Show()
		GOMaticRestoreMethodMenu:Show()
		GOMaticRestoreMethodText:Show()
		GrOM.UIFrameFadeIn(GOMaticRestoreMethodText, .3, 0, 1)
		GOMaticEditSave:Show()
		GOMaticNewBlankSave:Show()

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function SavesHide(resize)
		local h = 220

		GOMaticSavesScrollFrame:Hide()
		GOMaticDeleteSave:Hide()
		GOMaticRenameSave:Hide()
		GOMaticRestoreMethodMenu:Hide()
		GOMaticRestoreMethodText:Hide()
		GOMaticEditSave:Hide()
		GOMaticNewBlankSave:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local function IgnoreShow(yOffset)
		local h = 90

		GOMaticIgnoreDead:Show()
		GOMaticIgnoreOffline:Show()
		GOMaticIgnoreBelowLevel:Show()
		GOMaticMinLevelText:Show()
		GrOM.UIFrameFadeIn(GOMaticMinLevelText, .3, 0, 1)

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function IgnoreHide(resize)
		local h = 90

		GOMaticIgnoreDead:Hide()
		GOMaticIgnoreOffline:Hide()
		GOMaticIgnoreBelowLevel:Hide()
		GOMaticMinLevelText:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local function EZTemplateShow(yOffset)
		local h = 220

		GOMaticEZTemplateScrollFrame:Show()
		GOMaticAddEZTemplate:Show()
		GOMaticDeleteEZTemplate:Show()
		GOMaticRenameEZTemplate:Show()
		GOMaticEditEZTemplate:Show()

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function EZTemplateHide(resize)
		local h = 220

		GOMaticEZTemplateScrollFrame:Hide()
		GOMaticAddEZTemplate:Hide()
		GOMaticDeleteEZTemplate:Hide()
		GOMaticRenameEZTemplate:Hide()
		GOMaticEditEZTemplate:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local function HideCreatorFrames(...)
		for i = 1, select("#", ...) do
			select(i, ...):Hide()
		end
	end

	local function EZTemplate2Show(yOffset)
		local h = 550

		HideCreatorFrames(GOMaticEZCreator:GetChildren())
		GOMaticEZCreator:Show()
		GOMaticEZCreatorNameBox:Show()
		GOMaticEZCreatorTitle:Show()
		GrOM.UIFrameFadeIn(GOMaticEZCreatorTitle, .3, 0, 1)
		GOMaticEZCreatorNextButton:Show()
		GOMaticEZCreatorMergeOption:Show()
		GOMaticEZCreatorSeparateOption:Show()

		for i = 1, 4 do
			--_G["GOMaticEZCreatorDecurse"..i]:Show()
			_G["GOMaticEZCreatorDecurse"..i.."Text"]:SetText(loc.decurseMap[i][2])
		end

		if GrOM.editingEZT then
			local curParse = GrOM_Vars.ezTemplates[GrOM.editingEZT][2][1]
			if type(curParse) == "string" then
				local decursers = curParse:match("decursewhich (.+)")
				if decursers then
					decursers = ValidateDecurseWhich(strsplit(",", decursers))
					for i=1, 4 do
						_G["GOMaticEZCreatorDecurse"..i]:SetChecked(false)
					end
					for _, v in pairs(decursers) do
						for i, v2 in pairs(loc.decurseMap) do
							if v2[1] == v then
								_G["GOMaticEZCreatorDecurse"..i]:SetChecked(true)
								break
							end
						end
					end
				end
			end
			curParse = GrOM_Vars.ezTemplates[GrOM.editingEZT][3][1]
			if type(curParse) == "string" and curParse == "pushextras" then
				GOMaticEZCreatorMergeOption:SetChecked(false)
				GOMaticEZCreatorSeparateOption:SetChecked(true)
			else
				GOMaticEZCreatorMergeOption:SetChecked(true)
				GOMaticEZCreatorSeparateOption:SetChecked(false)
			end
			GOMaticEZCreatorNameBox:SetText(GrOM.FindEZTCloneName())
		else
			GOMaticEZCreatorNameBox:SetText("")
			GOMaticEZCreatorMergeOption:SetChecked(true)
			GOMaticEZCreatorSeparateOption:SetChecked(false)
		end

		GOMaticEZCreator1CheckDescription:Hide()
		--GrOM.UIFrameFadeIn(GOMaticEZCreator1CheckDescription, .3, 0, 1)
		GOMaticEZCreatorTitle:SetText(loc.creatortitle1)
		GOMaticEZCreatorMergeOptionText:SetText(loc.mergeusingdefault)
		GOMaticEZCreatorSeparateOptionText:SetText(loc.separateextras)
		GOMaticEZCreatorNextButton:SetText(loc.nextbutton)

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function EZTemplate2Hide(resize)
		local h = 550

		GOMaticEZCreator:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local customRaidEditBoxes = nil

	local function HideCustomRaidSaveInputBoxes()
		for i = 1, 40 do
			local f = customRaidEditBoxes[i]

			if f then
				f:Hide()
			end
		end
	end

	local function Saves2Show(yOffset)
		local h = 460

		GOMaticEditSaveNameInputBox:Show()
		GOMaticSaveCustom:Show()
		GOMaticCancelCustom:Show()
		GOMaticEditSavesText:Show()
		GrOM.UIFrameFadeIn(GOMaticEditSavesText, .3, 0, 1)

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function Saves2Hide(resize)
		local h = 460

		GOMaticEditSaveNameInputBox:Hide()
		GOMaticSaveCustom:Hide()
		GOMaticCancelCustom:Hide()
		GOMaticEditSavesText:Hide()

		HideCustomRaidSaveInputBoxes()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local function SyncShow(yOffset)
		local h = 220

		GOMaticUpdateChecksParent:Show()
		GOMaticSyncPaneText:Show()
		GrOM.UIFrameFadeIn(GOMaticSyncPaneText, .3, 0, 1)
		GOMaticSyncOut:Show()
		GOMaticSyncNow:Show()
		GOMaticSyncScrollFrame:Show()

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function SyncHide(resize)
		local h = 220

		GOMaticUpdateChecksParent:Hide()
		GOMaticSyncPaneText:Hide()
		GOMaticSyncOut:Hide()
		GOMaticSyncNow:Hide()
		GOMaticSyncScrollFrame:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local function MemberAddShow(yOffset)
		local h = 220
	
		GOMaticAutoPlaceMenu:Show()
		GOMaticAutoAutoMenu1:Show()
		GOMaticAutoAutoMenu2:Show()
		GOMaticAutoAutoMenu3:Show()
		GOMaticOnlyDoMemberAddActionsAsLeaderCheck:Show()
		GOMaticOnMemberAddText:Show()
		GrOM.UIFrameFadeIn(GOMaticOnMemberAddText, .3, 0, 1)
		GOMaticOnMemberAddText2:Show()
		GrOM.UIFrameFadeIn(GOMaticOnMemberAddText2, .3, 0, 1)

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function MemberAddHide(resize)
		local h = 220

		GOMaticAutoPlaceMenu:Hide()
		GOMaticAutoAutoMenu1:Hide()
		GOMaticAutoAutoMenu2:Hide()
		GOMaticAutoAutoMenu3:Hide()
		GOMaticOnlyDoMemberAddActionsAsLeaderCheck:Hide()
		GOMaticOnMemberAddText:Hide()
		GOMaticOnMemberAddText2:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	local function MVPsShow(yOffset)
		local h = 220

		GOMaticMVPScrollFrame:Show()
		GOMaticAddMVP:Show()
		GOMaticDeleteMVP:Show()
		GOMaticDeleteAllMVPs:Show()
		GOMaticDemoteMVP:Show()
		GOMaticPromoteMVP:Show()

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()
		GOMatic:SetHeight(166+h)
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y - h + yOffset)
	end

	local function MVPsHide(resize)
		local h = 220

		GOMaticMVPScrollFrame:Hide()
		GOMaticAddMVP:Hide()
		GOMaticDeleteMVP:Hide()
		GOMaticDeleteAllMVPs:Hide()
		GOMaticDemoteMVP:Hide()
		GOMaticPromoteMVP:Hide()

		if resize then
			local _,_,_,x, y = GOMatic:GetPoint()
			GOMatic:ClearAllPoints()
			GOMatic:SetHeight(166)
			--local s = GOMaticAnchorFrame:GetEffectiveScale()
			--x = x / s
			--y = y / s
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + h)
		end

		return h
	end

	function GrOM.CloseExtrasPane(updatePos)
		local yOffset = 0

		if currentExtras ~= "none" then
			if currentExtras == "exclude" then
				yOffset = ExcludeHide(updatePos)
			elseif currentExtras == "throttle" then
				yOffset = ThrottleHide(updatePos)
			elseif currentExtras == "ignore" then
				yOffset = IgnoreHide(updatePos)
			elseif currentExtras == "MVPs" then
				yOffset = MVPsHide(updatePos)
			elseif currentExtras == "saves" then
				yOffset = SavesHide(updatePos)
			elseif currentExtras == "saves2" then
				yOffset = Saves2Hide(updatePos)
			elseif currentExtras == "onmemberadd" then
				yOffset = MemberAddHide(updatePos)
			elseif currentExtras == "sync" then
				yOffset = SyncHide(updatePos)
			elseif currentExtras == "eztemplate" then
				yOffset = EZTemplateHide(updatePos)
			elseif currentExtras == "eztemplate2" then
				yOffset = EZTemplate2Hide(updatePos)
			end
		end

		currentExtras = "none"

		local x, y = GrOM.GetCurrentExtrasPane()

		UIDropDownMenu_SetSelectedValue(GOMaticExtrasMenu, x)
		GOMaticExtrasMenuText:SetText(y)

		return yOffset
	end

	function GrOM.OpenExtrasPane(self, name)
		if type(self) == "string" then
			name = self
		end

		if currentExtras == name then
			return
		end

		local yOffset = GrOM.CloseExtrasPane()

		if name == "exclude" then
			ExcludeShow(yOffset)
		elseif name == "throttle" then
			ThrottleShow(yOffset)
		elseif name == "ignore" then
			IgnoreShow(yOffset)
		elseif name == "MVPs" then
			MVPsShow(yOffset)
		elseif name == "saves" then
			SavesShow(yOffset)
		elseif name == "onmemberadd" then
			MemberAddShow(yOffset)
		elseif name == "sync" then
			SyncShow(yOffset)
		elseif name == "saves2" then
			Saves2Show(yOffset)
		elseif name == "eztemplate" then
			EZTemplateShow(yOffset)
		elseif name == "eztemplate2" then
			EZTemplate2Show(yOffset)
		end

		currentExtras = name
		local x, y = GrOM.GetCurrentExtrasPane()

		UIDropDownMenu_SetSelectedValue(GOMaticExtrasMenu, x)
		GOMaticExtrasMenuText:SetText(y)
	end

	local alreadyMoved = true

	function GrOM.MoreClick(showing)
		if showing and alreadyMoved then
			return
		end

		GOMaticMore:Hide()

		--GOMaticTitleText2:SetText(loc.myName2:format(FindKnownPercent()))
		--GOMaticTitleText2:Show()
		--GrOM.UIFrameFadeIn(GOMaticTitleText2, .3, 0, 1)	

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()

		GrOM_Vars.expanded = true
		GOMaticLess:Show()
		GOMaticSplit:Show()
		GOMaticGroupRoles:Show()
		GOMaticGroupClasses:Show()
		--GOMaticNukeCache:Show()
		--GOMaticSure:Show()
		GOMaticCancel:Show()
		GOMaticTemplateMenu:Show()
		GOMaticTemplateText:Show()
		GrOM.UIFrameFadeIn(GOMaticTemplateText, .3, 0, 1)
		GOMaticExtrasMenu:Show()
		--GOMaticContinuousScan:Show()

		GOMatic:SetWidth(400)

		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s

		if showing then
			alreadyMoved = true
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x-167, y)
		else
			GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y)
		end
	end

	function GrOM.LessClick()
		GOMaticMore:Show()

		local _,_,_,x, y = GOMatic:GetPoint()
		GOMatic:ClearAllPoints()

		GrOM_Vars.expanded = false
		GOMaticTitleText2:Hide()
		GOMaticLess:Hide()
		GOMaticPing:Hide()
		GOMaticOverrideRemote:Hide()
		GOMaticSilence:Hide()
		GOMaticNukeCache:Hide()
		GOMaticSure:Hide()
		GOMaticCancel:Hide()
		GOMaticTemplateMenu:Hide()
		GOMaticTemplateText:Hide()
		GOMaticExtrasMenu:Hide()
		GOMaticContinuousScan:Hide()
		GOMaticSplit:Hide()
		GOMaticGroupRoles:Hide()
		GOMaticGroupClasses:Hide()

		GOMatic:SetWidth(67)
		GOMatic:SetHeight(166)
	
		--local s = GOMaticAnchorFrame:GetEffectiveScale()
		--x = x / s
		--y = y / s
		GOMatic:SetPoint("BOTTOMLEFT", "GOMaticAnchorFrame", "BOTTOMLEFT", x, y + GrOM.CloseExtrasPane())
	end

	function GrOM.OnCheckBoxClick(self)
		if self:GetName() == self:GetParent():GetName() .. "OverrideRemote" then
			GrOM_Vars.LocalOverridesRemote = not GrOM_Vars.LocalOverridesRemote
			cout(GrOM_Vars.LocalOverridesRemote and loc.overrideon or loc.overrideoff)
		elseif self:GetName() == self:GetParent():GetName() .. "Silence" then
			GrOM_Vars.Silent = not GrOM_Vars.Silent
			cout(loc.unsilenced)
		elseif self:GetName() == self:GetParent():GetName() .. "Sure" then
			GrOM_Vars.AlwaysSure = not GrOM_Vars.AlwaysSure
			cout(GrOM_Vars.AlwaysSure and loc.sureon or loc.sureoff)
		elseif self:GetName() == self:GetParent():GetName() .. "SyncOut" then
			GrOM_Vars.syncOut = self:GetChecked()
		elseif self:GetName() == self:GetParent():GetName() .. "IgnoreDead" then
			GrOM_Vars.ignoreDead = self:GetChecked()
		elseif self:GetName() == self:GetParent():GetName() .. "IgnoreOffline" then
			GrOM_Vars.ignoreOffline = self:GetChecked()
		elseif self:GetName() == self:GetParent():GetName() .. "OnlyDoMemberAddActionsAsLeaderCheck" then
			GrOM_Vars.onlyDoRaidMemberAddActionsIfLeader = not GrOM_Vars.onlyDoRaidMemberAddActionsIfLeader	
		elseif self:GetName() == self:GetParent():GetName() .. "ExcludeSaves" then
			GrOM_Vars.excludeSaves = not GrOM_Vars.excludeSaves
		elseif self:GetName() == self:GetParent():GetName() .. "ContinuousScan" then
			GrOM_Vars.enableContinuousScan = not GrOM_Vars.enableContinuousScan
			if GrOM_Vars.enableContinuousScan then
				GOMatic_Auto:SetScript("OnUpdate", GrOM.OnUpdate)
			else
				GOMatic_Auto:SetScript("OnUpdate", nil)
			end
		end
	end

	local selectedSave = nil

	local function FindSave(name)
		local i = 0

		for k,_ in pairs(GrOM_Vars.SavedRaidLayouts) do
			i = i + 1
			if k == name then
				return i
			end
		end

		return false
	end

	local function CustomEditTextChanged(self)
		_G[self:GetName().."ClassText"]:SetText("")
		local text = self:GetText()
		if not text then return end
	
		local class = GrOM_Vars.classByNameCache[text]	
		if not class then
			class = "???"
		end
	
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		if not color then color = GRAY_FONT_COLOR end
		local r, g, b = color.r, color.g, color.b

		local classText = loc.classes[class] or class
		classText = ("|c00%.2x%.2x%.2x%s|r"):format(
			math.floor(r * 255),
			math.floor(g * 255),
			math.floor(b * 255),
			classText)
	
		_G[self:GetName().."ClassText"]:SetText(classText)
	end

	local function CustomEditTabPress(self)
		local inx = self.num + (IsShiftKeyDown() and -1 or 1)

		if inx < 1 then
			inx = 40
		elseif inx > 40 then
			inx = 1
		end

		local tabTo = customRaidEditBoxes[inx]

		tabTo:SetFocus()
	end

	local function BuildCustomEditBoxes()
		customRaidEditBoxes = {}
	
		for i = 1, 40 do
			local f = CreateFrame("EditBox", "GOMaticCustomRaidEditBox" .. i, GOMatic, "GOMaticCustomRaidEditBoxTemplate")		
			f:SetWidth(100)
			f:SetHeight(16)
			f:SetAutoFocus(false)
			f:SetScript("OnTabPressed", CustomEditTabPress)
			f:SetScript("OnTextChanged", CustomEditTextChanged)
			f:SetScript("OnTextSet", CustomEditTextChanged)
			f.num = i
			f:ClearAllPoints()
			if i > 1 then
				f:SetPoint("TOPLEFT", "GOMaticCustomRaidEditBox" .. i - 1, "BOTTOMLEFT", 0, -2)
				if i == 6 or i == 16 or i == 26 or i == 36 then
					f:SetPoint("TOPLEFT", "GOMaticCustomRaidEditBox" .. i - 5, "TOPRIGHT", 90, 0)
				end
				if i == 11 or i == 21 or i == 31 then
					f:SetPoint("TOPLEFT", "GOMaticCustomRaidEditBox" .. i - 6, "BOTTOMLEFT", 0, -8)
				end
			else
				f:SetPoint("TOPLEFT", GOMaticSaveCustom, "BOTTOMLEFT", -30, -10)
			end
			f:SetFrameLevel(GOMatic:GetFrameLevel() + 1)	
			f:SetScript("OnShow", function(self)GrOM.UIFrameFadeIn(self, .3, 0, 1)end)
			f:Hide()
			customRaidEditBoxes[i] = f
		end
	end

	function GrOM.SaveCustomRaid(override)
		local save = {{},{},{},{},{},{},{},{}}

		local name = GOMaticEditSaveNameInputBox:GetText()	

		if not name or name:match("^%s*$") then
			local reason = loc.mustenternameerr
			message(loc.badcustomraidinputerr:format(reason))
			return false
		end

		for i = 1, 8 do
			for j = 1, 5 do
				local ix = (i - 1) * 5 + j
				local inBox = customRaidEditBoxes[ix]
				local text = inBox:GetText()
				local textB = text:match("|c%d+(.*)|r")
				if textB then
					text = textB
				end
				text = text:match("^([^%s%p%c%d][^%s%p%c]*-?[^%c]*)$")
				if not text then
					text = inBox:GetText():match("^(%s*)$")
				end

				if text then
					text = text:gsub(" ","")
					if text ~= "" then
						table.insert(save[i], text)
					end
				else
					local reason = text or i .. ", " .. j
					message(loc.badcustomraidinputerr:format(reason))
					return false
				end
			end
		end

		if GrOM_Vars.SavedRaidLayouts[name] and (not override) then
			StaticPopup_Show("GOMatic_DO_CUSTOM_SAVE", name)
			return false
		end

		GrOM_Vars.SavedRaidLayouts[name] = save

		GrOM.OpenExtrasPane("saves")

		GrOM.UpdateSavesPane()
		return true
	end

	function GrOM.EditSave(blank)
		local name = selectedSave

		local save = nil

		if name then
			save = GrOM_Vars.SavedRaidLayouts[selectedSave]
		else
			name = ""
		end

		if blank then
			name = ""
		end

		GrOM.OpenExtrasPane("saves2")

		GOMaticEditSaveNameInputBox:SetFocus()
		GOMaticEditSaveNameInputBox:SetText(name)

		if not customRaidEditBoxes then
			BuildCustomEditBoxes()
		end

		for i = 1, 8 do
			for j = 1, 5 do
				local ix = (i - 1) * 5 + j
				local inBox = customRaidEditBoxes[ix]
				local text = nil

				if save then
					text = save[i][j] or ""
				end

				if blank then
					text = ""
				end

				inBox:SetText(text)
				inBox:Show()
			end
		end
	end

	function GrOM.RenameSave(name, overWrite)
		if selectedSave == name then
			return
		end

		if (not overWrite) and FindSave(name) then
			GrOM.SaveName = name
			StaticPopup_Show("GOMatic_DO_RENAME", name)
			return
		end

		if (not selectedSave) or (not GrOM_Vars.SavedRaidLayouts[selectedSave]) then
			return
		end

		GrOM_Vars.SavedRaidLayouts[name] = CopyTable(GrOM_Vars.SavedRaidLayouts[selectedSave])
		GrOM_Vars.SavedRaidLayouts[selectedSave] = nil

		selectedSave = name

		GrOM.UpdateSavesPane()
	end

	function GrOM.DeleteSave()
		GrOM_Vars.SavedRaidLayouts[selectedSave] = nil

		GrOM.UpdateSavesPane()
	end

	local function GetFirstSave()
		for k in pairs(GrOM_Vars.SavedRaidLayouts) do
			return k
		end
	end

	local function UpdateSaveButtons()
		if GetFirstSave() then
			GOMaticRenameSave:Enable()
			GOMaticDeleteSave:Enable()
			GOMaticEditSave:Enable()
		else
			GOMaticRenameSave:Disable()
			GOMaticDeleteSave:Disable()
			GOMaticEditSave:Disable()
		end
	end

	function GrOM.UpdateSavesPane()
		if GrOM.guiUnloaded then return end
		if not (selectedSave and FindSave(selectedSave)) then
			selectedSave = GetFirstSave()
		end

		local i = FindSave(selectedSave)
		local offset = GOMaticSavesScrollFrame.offset
		local h, maxButtons = GrOM.GetScrollFrameButtonStats(GOMaticSavesScrollFrame:GetHeight())

		if i then
			--if the selected unit is off-screen, scroll to it
			if i - 1 < offset then
				offset = i - 1
			elseif i > (offset + maxButtons) then
				offset = i - maxButtons
				if offset < 1 then
					offset = 1
				end
			end
		end

		offset = offset * h

		GrOM.FauxScrollFrame_OnVerticalScroll(GOMaticSavesScrollFrame, offset, h, GrOM.ScrollFrameUpdate)

		GrOM.UpdateButtons()

		if currentExtras ~= "saves" then
			GOMaticSavesScrollFrame:Hide()
		end
	end

	local selectedMVP = nil

	local function FindMVP(name)
		if not name then
			return false
		end

		name = strlower(name)

		for i = 1, #GrOM_Vars.MVPs do
			if strlower(GrOM_Vars.MVPs[i]) == name then
				return i
			end
		end

		return false
	end

	local function UpdateMVPButtons()
		local i = FindMVP(selectedMVP)

		if not i then
			GOMaticDeleteMVP:Disable()
			GOMaticDeleteAllMVPs:Disable()
			GOMaticDemoteMVP:Disable()
			GOMaticPromoteMVP:Disable()
		else
			GOMaticDeleteMVP:Enable()
			GOMaticDeleteAllMVPs:Enable()
			if i == #GrOM_Vars.MVPs then
				GOMaticDemoteMVP:Disable()
			else
				GOMaticDemoteMVP:Enable()
			end

			if i == 1 then
				GOMaticPromoteMVP:Disable()
			else
				GOMaticPromoteMVP:Enable()
			end
		end
	end

	function GrOM.UpdateMVPPane()
	    if not selectedMVP then
		selectedMVP = GrOM_Vars.MVPs[1]
	    end

	    local i = FindMVP(selectedMVP)
	    local offset = GOMaticMVPScrollFrame.offset
	    local h, maxButtons = GrOM.GetScrollFrameButtonStats(GOMaticMVPScrollFrame:GetHeight())
	    --local h, maxButtons = 16, 5

	    --offset = floor((offset / h) + 0.5)
	    if i then
		--if the selected unit is off-screen, scroll to it
		if i - 1 < offset then
		    offset = i - 1
		elseif i > (offset + maxButtons) then
		    offset = i - maxButtons
		    if offset < 1 then
		        offset = 1
		    end
		end
	    end

	    offset = offset * h

	    GrOM.FauxScrollFrame_OnVerticalScroll(GOMaticMVPScrollFrame, offset, h, GrOM.ScrollFrameUpdate)
	end

	function GrOM.AddMVP(name)
		local fail = true

		if not FindMVP(name) then
			GrOM_Vars.MVPs[#GrOM_Vars.MVPs + 1] = name
			fail = false
		end

		selectedMVP = name
		GrOM.UpdateMVPPane()
		return fail
	end

	function GrOM.DeleteMVP()
		local i = FindMVP(selectedMVP)

		if i then
			table.remove(GrOM_Vars.MVPs, i)
		end

		selectedMVP = nil
		GrOM.UpdateMVPPane()
	end

	function GrOM.ClearMVPs()
		GrOM_Vars.MVPs = {}

		selectedMVP = nil
		GrOM.UpdateMVPPane()
	end

	function GrOM.DemoteMVP()
		local i = FindMVP(selectedMVP)

		if i then
			local mvp = table.remove(GrOM_Vars.MVPs, i)

			if GrOM_Vars.MVPs[i+1] then
				table.insert(GrOM_Vars.MVPs, i+1, mvp)
			else
				table.insert(GrOM_Vars.MVPs, mvp)
			end
		end

		GrOM.UpdateMVPPane()
	end

	function GrOM.PromoteMVP()
		local i = FindMVP(selectedMVP)

		if i then
			local mvp = table.remove(GrOM_Vars.MVPs, i)

			if GrOM_Vars.MVPs[i-1] then
				table.insert(GrOM_Vars.MVPs, i-1, mvp)
			else
				table.insert(GrOM_Vars.MVPs, mvp)
			end
		end

		GrOM.UpdateMVPPane()
	end

	function GrOM.UpdateSyncPane()
		local last = nil
		CreateFrame("Frame", "GOMaticUpdateChecksParent", GOMatic)
		GOMaticUpdateChecksParent:Hide()
		GOMaticUpdateChecksParent:SetScript("OnShow", function(self)GrOM.UIFrameFadeIn(self, .3, 0, 1)end)
		for k, v in pairs(loc.syncMap) do
			local f = CreateFrame("CheckButton", "GOMaticSync" .. k, GOMaticUpdateChecksParent, "OptionsCheckButtonTemplate")
			f:ClearAllPoints()
			if last then
				f:SetPoint("TOPLEFT", last, "TOPRIGHT", 65, 0)
			else
				f:SetPoint("TOPLEFT", GOMaticSyncOut, "BOTTOMLEFT", 0, -15)
			end
			last = f
			_G[f:GetName() .. "Text"]:SetText(k)
			f:SetHitRectInsets(0, -40, 0, 0)
			f:SetChecked(GrOM_Vars.syncSettings[v])
			f.settingName = v
			f:SetScript("OnClick", function(self) GrOM_Vars.syncSettings[self.settingName] = self:GetChecked() end)
		end
	end

	local selectedEZTemplate = nil

	local function FindEZTemplate(name)
		if not name then
			return false
		end

		for i = 1, #GrOM_Vars.ezTemplates do
			if GrOM_Vars.ezTemplates[i][1] == name then
				return i
			end
		end

		return false
	end

	function GrOM.FindEZTCloneName()
		local n = selectedEZTemplate

		if not n then
			return ""
		end

		local i = 2
		local nr = n .. i

		while FindEZTemplate(nr) do
			i = i + 1
			nr = n .. i
		end

		return nr
	end

	function GrOM.FindEZTemplate(name)
		return FindEZTemplate(name)
	end


	local workingTemplate = {"", {}, {}}
	local workingLimits = {1}
	local workingRules = {1}
	local creatorPanel = 0

	local function DrawLimitsPane()
		local prLn = nil
		local genLn = "GOMaticEZCreatorLimitsLine"
		local maxLn = #workingLimits

		for i=1, maxLn do
			local cLn = workingLimits[i]
			local f = _G[genLn..cLn]
			f:Show()
			f:ClearAllPoints()
			if prLn then
				f:SetPoint("TOPLEFT", prLn, "BOTTOMLEFT", 0, -10)
			else
				f:SetPoint("TOPLEFT", GOMaticEZCreatorTitle, "BOTTOMLEFT", 0, -5)
			end
			_G[genLn..cLn.."MinusButton"]:Enable()
			prLn = f
		end

		--[[if maxLn == 1 then
			_G[genLn..workingLimits[1].."MinusButton"]:Disable()
		end]]

		GOMaticEZCreatorPlusButton:Show()
		GOMaticEZCreatorPlusButton:ClearAllPoints()
		if prLn then
			GOMaticEZCreatorPlusButton:SetPoint("TOPLEFT", prLn, "TOPRIGHT", 10, 0)
		else
			GOMaticEZCreatorPlusButton:SetPoint("TOPLEFT", GOMaticEZCreatorTitle, "BOTTOMLEFT", 20, -5)
		end
	end

	local function DrawRulesPane()
		local prLn = nil
		local genLn = "GOMaticEZCreatorRulesLine"
		local maxLn = #workingRules

		for i=1, maxLn do
			local cLn = workingRules[i]
			local f = _G[genLn..cLn]
			f:Show()
			f:ClearAllPoints()
			if prLn then
				f:SetPoint("TOPLEFT", prLn, "BOTTOMLEFT", 0, -10)
			else
				f:SetPoint("TOPLEFT", GOMaticEZCreatorTitle, "BOTTOMLEFT", 0, -5)
			end
			_G[genLn..cLn.."MinusButton"]:Enable()
			prLn = f
		end

		if maxLn == 1 then
			_G[genLn..workingRules[1].."MinusButton"]:Disable()
		end

		GOMaticEZCreatorPlusButton:Show()
		GOMaticEZCreatorPlusButton:ClearAllPoints()
		if prLn then
			GOMaticEZCreatorPlusButton:SetPoint("TOPLEFT", prLn, "TOPRIGHT", 10, -30)
		else
			GOMaticEZCreatorPlusButton:SetPoint("TOPLEFT", GOMaticEZCreatorTitle, "BOTTOMLEFT", 20, -5)
		end
	end

	function GrOM.RemoveLimitsLine(num)
		for i = 1, #workingLimits do
			if workingLimits[i] == num then
				table.remove(workingLimits, i)
				_G["GOMaticEZCreatorLimitsLine" .. num]:Hide()
			end
		end

		DrawLimitsPane()
	end

	function GrOM.RemoveRulesLine(num)
		for i = 1, #workingRules do
			if workingRules[i] == num then
				table.remove(workingRules, i)
				_G["GOMaticEZCreatorRulesLine" .. num]:Hide()
			end
		end

		DrawRulesPane()
	end

	function GrOM.AddLimitsLine()
		local l, it = nil, 0

		while not l do
			it = it + 1
			local fail = false
			for i = 1, #workingLimits do
				if workingLimits[i] == it then
					fail = true
					break
				end
			end
			if not fail then
				l = it
			end
		end

		workingLimits[#workingLimits + 1] = it

		if not _G["GOMaticEZCreatorLimitsLine" .. it] then
			CreateFrame("Frame", "GOMaticEZCreatorLimitsLine" .. it, GOMaticEZCreator, "GOMaticEZCreatorLimitsLineTemplate")
		end

		local f = "GOMaticEZCreatorLimitsLine" .. it
		_G[f .. "NumberBox"]:SetText("1")
		_G[f .. "NumberBox"]:SetCursorPosition(0)
		UIDropDownMenu_SetSelectedValue(_G[f.."ClassMenu"],GrOM.Localization.any)
		_G[f.."ClassMenu"].myVal = loc.any
		UIDropDownMenu_SetSelectedValue(_G[f.."SpecMenu"],GrOM.Localization.any)
		_G[f.."SpecMenu"].myVal = loc.any
		_G[f]:Raise()
		_G[f]:Hide()

		DrawLimitsPane()
	end

	function GrOM.AddRulesLine()
		local l, it = nil, 0

		while not l do
			it = it + 1
			local fail = false
			for i = 1, #workingRules do
				if workingRules[i] == it then
					fail = true
					break
				end
			end
			if not fail then
				l = it
			end
		end

		workingRules[#workingRules + 1] = it

		if not _G["GOMaticEZCreatorRulesLine" .. it] then
			CreateFrame("Frame", "GOMaticEZCreatorRulesLine" .. it, GOMaticEZCreator, "GOMaticEZCreatorRulesLineTemplate")
		end

		local f = "GOMaticEZCreatorRulesLine" .. it
		UIDropDownMenu_SetSelectedValue(_G[f.."ClassMenu"],GrOM.Localization.any)
		_G[f.."ClassMenu"].myVal = loc.any
		UIDropDownMenu_SetSelectedValue(_G[f.."SpecMenu"], loc.roles.TANK)
		_G[f.."SpecMenu"].myVal = "TANK"
		UIDropDownMenu_SetSelectedValue(_G[f.."IgnoreSpecMenu"],GrOM.Localization.none)
		_G[f.."IgnoreSpecMenu"].myVal = loc.none
		_G[f.."RequireSpec"]:SetChecked(false)
		_G[f.."Loop"]:SetChecked(false)
		_G[f.."RequireSpecText"]:SetText(loc.requirespec)
		_G[f.."LoopText"]:SetText(loc.loop)
		_G[f]:Raise()

		DrawRulesPane()
	end

	function GrOM.AddLimitsOrRulesLine()
		if creatorPanel / 2 == floor(creatorPanel / 2) then
			GrOM.AddLimitsLine()
		else
			GrOM.AddRulesLine()
		end
	end

	
	
	function GrOM.AdvanceEZCreator()
		GrOM.UIFrameFadeIn(GOMaticEZCreatorTitle, .3, 0, 1)
		if creatorPanel == 1 then
			local name = GOMaticEZCreatorNameBox:GetText()
			if name then
				name = name:gsub(" ", "")
			end
			if not name or name == "" then
				message(loc.mustenternameerr)
				return
			end

			if FindEZTemplate(name) then
				message(loc.deletefirst)
				return
			end

			GOMaticEZCreator1CheckDescription:Hide()

			workingTemplate[1] = name

			if GOMaticEZCreatorMergeOption:GetChecked() then
				workingTemplate[3] = defaultTemplate[2]
			else
				workingTemplate[3] = {"pushextras"}
			end

			local decOpt = "decursewhich "
			local any = false
			for i = 1, 4 do
				if _G["GOMaticEZCreatorDecurse"..i]:GetChecked() then
					if any then
						decOpt = decOpt .. ","
					end
					any = true
					decOpt = decOpt .. loc.decurseMap[i][1]
				end
			end
			if not any then
				decOpt = "decursewhich any"
			end
			workingTemplate[2][#workingTemplate[2] + 1] = decOpt
		else
			if creatorPanel / 2 == floor(creatorPanel / 2) then
				for i = 1, #workingLimits do
					local cL = "GOMaticEZCreatorLimitsLine"..workingLimits[i]
					local cClass = _G[cL .. "ClassMenu"].myVal
					local cSpec = _G[cL .. "SpecMenu"].myVal
					if not (cClass or cSpec) or (cClass == loc.any and cSpec == loc.any) then
						message(loc.noclassorspec)
						return
					end
				end

				local t2 = workingTemplate[2]
				t2[#t2 + 1] = "allgroups"
				t2[#t2 + 1] = "group " .. creatorPanel / 2

				local wLim = ""

				for i = 1, #workingLimits do
					local cL = "GOMaticEZCreatorLimitsLine"..workingLimits[i]
					wLim = wLim .. "+"
					local cNum = tonumber(_G[cL .. "NumberBox"]:GetText())
					if cNum then
						cNum = floor(cNum)
						if cNum > 5 then
							cNum = 5
						elseif cNum < 0 then
							cNum = 0
						end
					else
						cNum = 1
					end
					wLim = wLim .. cNum
					local cClass = _G[cL .. "ClassMenu"].myVal
					if not cClass or cClass == loc.any then
						cClass = "*"
					end
					wLim = wLim .. cClass .. "&"
					local cSpec = _G[cL .. "SpecMenu"].myVal
					if not cSpec or cSpec == loc.any then
						cSpec = "*"
					end
					wLim = wLim .. cSpec
					if i < #workingLimits then
						wLim = wLim .. ","
					end
				end
				if wLim ~= "" then
					t2[#t2 + 1] = "limit " .. wLim
				end
			else
				local t2 = workingTemplate[2]

				for i = 1, #workingRules do
					local wRul = {}

					local cR = "GOMaticEZCreatorRulesLine"..workingRules[i]

					local cClass = _G[cR .. "ClassMenu"].myVal
					if not cClass or cClass == loc.any then
						cClass = nil
					end
					wRul[1] = cClass

					local cSpec = _G[cR .. "SpecMenu"].myVal
					wRul[2] = cSpec

					local reqP = _G[cR .. "RequireSpec"]:GetChecked()
					wRul[3] = reqP

					local cISpec = _G[cR .. "IgnoreSpecMenu"].myVal
					if not cISpec or cISpec == loc.none then
						cISpec = nil
					end
					wRul[4] = cISpec

					local dLoop = _G[cR .. "Loop"]:GetChecked()
					wRul[5] = dLoop

					t2[#t2 + 1] = wRul
				end

				t2[#t2 + 1] = "end"
			end
		end

		HideCreatorFrames(GOMaticEZCreator:GetChildren())
		GOMaticEZCreatorNextButton:Show()

		if creatorPanel / 2 == floor(creatorPanel / 2) then
			local parseDone = false
			if GrOM.editingEZT then --GrOM.editingEZTIndex	GrOM.editingEZT
				workingRules = {}
				local curParse = GrOM_Vars.ezTemplates[GrOM.editingEZT][2][GrOM.editingEZTIndex]
				while curParse and (type(curParse)=="table" or (type(curParse)=="string" and curParse~="allgroups")) do
					if type(curParse) == "table" then
						if not ValidateTemplateTable(curParse) then
							eout("Error editing EZ Template: Malformed rules table found, template may have been edited manually?")
							GrOM.OpenExtrasPane("eztemplate")
							return
						end

						parseDone = true
						GrOM.AddRulesLine()
						DrawRulesPane()
						local nWRul = workingRules[#workingRules]
						local nName = "GOMaticEZCreatorRulesLine" .. nWRul

						UIDropDownMenu_SetSelectedValue(_G[nName.."ClassMenu"], curParse[1] and loc.classes[curParse[1] ] or loc.any)
						_G[nName.."ClassMenu"].myVal = curParse[1] or loc.any
						UIDropDownMenu_SetSelectedValue(_G[nName.."SpecMenu"], loc.roles[curParse[2] ])
						_G[nName.."SpecMenu"].myVal = curParse[2]
						UIDropDownMenu_SetSelectedValue(_G[nName.."IgnoreSpecMenu"], curParse[4] and loc.roles[curParse[4] ] or loc.none)
						_G[nName.."IgnoreSpecMenu"].myVal = curParse[4] or loc.none
						_G[nName.."RequireSpec"]:SetChecked(curParse[3])
						_G[nName.."Loop"]:SetChecked(curParse[5])
					end
					GrOM.editingEZTIndex = GrOM.editingEZTIndex + 1
					curParse = GrOM_Vars.ezTemplates[GrOM.editingEZT][2][GrOM.editingEZTIndex]
				end
				GOMaticEZCreatorTitle:SetText(loc.creatortitle3:format(creatorPanel / 2))
			end
			if not parseDone then
				workingRules = {1}
				if not GOMaticEZCreatorRulesLine1 then
					CreateFrame("Frame", "GOMaticEZCreatorRulesLine1", GOMaticEZCreator, "GOMaticEZCreatorRulesLineTemplate")
				end
				GOMaticEZCreatorRulesLine1:Show()

				GOMaticEZCreatorTitle:SetText(loc.creatortitle3:format(creatorPanel / 2))
				DrawRulesPane()
				UIDropDownMenu_SetSelectedValue(GOMaticEZCreatorRulesLine1ClassMenu,GrOM.Localization.any)
				GOMaticEZCreatorRulesLine1ClassMenu.myVal = loc.any
				UIDropDownMenu_SetSelectedValue(GOMaticEZCreatorRulesLine1SpecMenu, loc.roles.TANK)
				GOMaticEZCreatorRulesLine1SpecMenu.myVal = "TANK"
				UIDropDownMenu_SetSelectedValue(GOMaticEZCreatorRulesLine1IgnoreSpecMenu, GrOM.Localization.none)
				GOMaticEZCreatorRulesLine1IgnoreSpecMenu.myVal = loc.none
				GOMaticEZCreatorRulesLine1RequireSpec:SetChecked(false)
				GOMaticEZCreatorRulesLine1Loop:SetChecked(false)
				GOMaticEZCreatorRulesLine1RequireSpecText:SetText(loc.requirespec)
				GOMaticEZCreatorRulesLine1LoopText:SetText(loc.loop)
			end
		else
			local parseDone = false
			if GrOM.editingEZT then --GrOM.editingEZTIndex	GrOM.editingEZT
				workingLimits = {}
				local curParse = GrOM_Vars.ezTemplates[GrOM.editingEZT][2][GrOM.editingEZTIndex]
				while type(curParse)=="string" do
					--[[if curParse == "allgroups" then
						eout("Error editing EZ Template: No rules data found, template may have been edited manually?")
						GrOM.OpenExtrasPane("eztemplate")
						return
					end]]

					local limits = curParse:match("limit (.+)")
					if limits then
						limits = ValidateLimits(strsplit(",", limits))
						if not limits then
							eout("Error editing EZ Template: Malformed limits line found, template may have been edited manually?")
							GrOM.OpenExtrasPane("eztemplate")
							return
						end

						for i = 1, #limits do
							parseDone = true
							GrOM.AddLimitsLine()
							DrawLimitsPane()
							local nWLim = workingLimits[#workingLimits]
							local nName = "GOMaticEZCreatorLimitsLine" .. nWLim

							--class, spec, number (other two are constant for EZ Templates)
							_G[nName.."NumberBox"]:SetText(limits[i][3])
							UIDropDownMenu_SetSelectedValue(_G[nName.."ClassMenu"], limits[i][1] and loc.classes[limits[i][1] ] or loc.any)
							_G[nName.."ClassMenu"].myVal = limits[i][1] or loc.any
							UIDropDownMenu_SetSelectedValue(_G[nName.."SpecMenu"], limits[i][2] and loc.roles[limits[i][2] ] or loc.any)
							_G[nName.."SpecMenu"].myVal = limits[i][2] or loc.any
						end
					end

					GrOM.editingEZTIndex = GrOM.editingEZTIndex + 1
					curParse = GrOM_Vars.ezTemplates[GrOM.editingEZT][2][GrOM.editingEZTIndex]
				end
				GrOM.editingEZTIndex = GrOM.editingEZTIndex - 1

				GOMaticEZCreatorTitle:SetText(loc.creatortitle2:format((creatorPanel + 1) / 2))
			end
			if not parseDone then
				workingLimits = {}
				if not GOMaticEZCreatorLimitsLine1 then
					CreateFrame("Frame", "GOMaticEZCreatorLimitsLine1", GOMaticEZCreator, "GOMaticEZCreatorLimitsLineTemplate")
				end

				GOMaticEZCreatorTitle:SetText(loc.creatortitle2:format((creatorPanel + 1) / 2))
				DrawLimitsPane()
				GOMaticEZCreatorLimitsLine1NumberBox:SetText("1")
				UIDropDownMenu_SetSelectedValue(GOMaticEZCreatorLimitsLine1ClassMenu,GrOM.Localization.any)
				GOMaticEZCreatorLimitsLine1ClassMenu.myVal = loc.any
				UIDropDownMenu_SetSelectedValue(GOMaticEZCreatorLimitsLine1SpecMenu,GrOM.Localization.any)
				GOMaticEZCreatorLimitsLine1SpecMenu.myVal = loc.any
			end
		end

		creatorPanel = creatorPanel + 1
		if creatorPanel > 17 then
			HideCreatorFrames(GOMaticEZCreator:GetChildren())
			GrOM.OpenExtrasPane("eztemplate")
			GrOM_Vars.ezTemplates[#GrOM_Vars.ezTemplates + 1] = CopyTable(workingTemplate)
			GrOM.UpdateEZTemplatePane()
		end
	end

	function GrOM.NewEZTemplate(edit)
		GrOM.editingEZT = nil
		if edit then
			GrOM.editingEZT = FindEZTemplate(selectedEZTemplate)
			GrOM.editingEZTIndex = 1
		end
		creatorPanel = 1
		workingTemplate = {"", {}, {}}

		GrOM.OpenExtrasPane("eztemplate2")
	end

	function GrOM.RenameEZTemplate(name, overWrite)
		local dx = FindEZTemplate(name)

		local pN

		if type(GrOM_Vars.userTemplateToUse) == "number" then
			pN = GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse][1]
		end

		if (not overWrite) and dx then
			GrOM.SaveName = name
			StaticPopup_Show("GOMatic_DO_RENAME_EZTEMPLATE", name)
			return
		end

		local ix = nil

		if selectedEZTemplate then
			ix = FindEZTemplate(selectedEZTemplate)
		end

		if (not selectedEZTemplate) or (not ix) or (not GrOM_Vars.ezTemplates[ix]) then
			if GrOM_Vars.ezTemplates[1] then
				selectedEZTemplate = GrOM_Vars.ezTemplates[1][1]
				GrOM.UpdateEZTemplatePane()
			end
			return
		end

		local resetSelected = false

		if dx then
			local tempToRename = GrOM_Vars.ezTemplates[ix]
			resetSelected = GrOM.DeleteEZTemplate(name)
			tempToRename[1] = name
		else
			GrOM_Vars.ezTemplates[ix][1] = name
		end

		if (not resetSelected) and pN then
			GrOM_Vars.userTemplateToUse = FindEZTemplate(pN)
		end

		local x, y = GrOM.GetCurrentTemplate()
		UIDropDownMenu_SetSelectedValue(GOMaticTemplateMenu, x)
		GOMaticTemplateMenuText:SetText(y)

		selectedEZTemplate = name

		GrOM.UpdateEZTemplatePane()
	end

	function GrOM.DeleteEZTemplate(name)
		if not name then
			name = selectedEZTemplate
		end

		local resetSelected = false

		local ix = FindEZTemplate(name)

		if not ix then
			return
		end

		local pN

		if type(GrOM_Vars.userTemplateToUse) == "number" then
			pN = GrOM_Vars.ezTemplates[GrOM_Vars.userTemplateToUse][1]
		end

		table.remove(GrOM_Vars.ezTemplates, ix)

		if GrOM_Vars.userTemplateToUse == ix then
			GrOM_Vars.userTemplateToUse = nil
			resetSelected = true
		elseif pN then
			GrOM_Vars.userTemplateToUse = FindEZTemplate(pN)
		end

		local x, y = GrOM.GetCurrentTemplate()
		UIDropDownMenu_SetSelectedValue(GOMaticTemplateMenu, x)
		GOMaticTemplateMenuText:SetText(y)

		GrOM.UpdateEZTemplatePane()

		return resetSelected
	end

	local function UpdateEZTemplateButtons()
		if #GrOM_Vars.ezTemplates > 0 then
			GOMaticAddEZTemplate:Enable()
			GOMaticDeleteEZTemplate:Enable()
			GOMaticRenameEZTemplate:Enable()
			GOMaticEditEZTemplate:Enable()
		else
			GOMaticAddEZTemplate:Enable()
			GOMaticDeleteEZTemplate:Disable()
			GOMaticRenameEZTemplate:Disable()
			GOMaticEditEZTemplate:Disable()
		end
	end

	function GrOM.UpdateEZTemplatePane()
		if not (selectedEZTemplate and FindEZTemplate(selectedEZTemplate)) then
			if GrOM_Vars.ezTemplates[1] then
				selectedEZTemplate = GrOM_Vars.ezTemplates[1][1]
			else
				selectedEZTemplate = nil
			end
		end

		local i = FindEZTemplate(selectedEZTemplate)
		local offset = GOMaticEZTemplateScrollFrame.offset
		local h, maxButtons = GrOM.GetScrollFrameButtonStats(GOMaticEZTemplateScrollFrame:GetHeight())

		if i then
			--if the selected unit is off-screen, scroll to it
			if i - 1 < offset then
			    offset = i - 1
			elseif i > (offset + maxButtons) then
			    offset = i - maxButtons
			    if offset < 1 then
				offset = 1
			    end
			end
		end

		offset = offset * h

		GrOM.FauxScrollFrame_OnVerticalScroll(GOMaticEZTemplateScrollFrame, offset, h, GrOM.ScrollFrameUpdate)

		if currentExtras ~= "eztemplate" then
			GOMaticEZTemplateScrollFrame:Hide()
		end
	end

	function GrOM.AddOrRemoveSync(self)
		local checked = self:GetChecked()
		local pName = _G[self:GetParent():GetName() .. "DataLabel"]:GetText()

		GrOM_Vars.syncProfiles[pName] = checked
	end

	local function PopulateScrollList(name)
		local list = {}

		if name == "GOMaticMVPScrollFrame" then
			list = CopyTable(GrOM_Vars.MVPs) --check if we need to copy it
		elseif name == "GOMaticSyncScrollFrame" then
			local i = 0
			foreach(GrOM_G_Vars.profiles, function(k) i=i+1 list[i]=k end)
		elseif name == "GOMaticEZTemplateScrollFrame" then
			for i=1, #GrOM_Vars.ezTemplates do
				list[i] = GrOM_Vars.ezTemplates[i][1]
			end
		elseif name == "GOMaticSavesScrollFrame" then
			local i = 0
			for k,_ in pairs(GrOM_Vars.SavedRaidLayouts) do
				i = i + 1
				list[i] = k
			end
		end

		return list
	end

	function GrOM.GetScrollFrameButtonStats(h)
		local n = math.floor(h / 16)
		local bh = math.floor((h-(16*n))/n) + 16

		return bh, n
	end

	function GrOM.ScrollFrameUpdate(self)
		local name = self:GetName()
		local list = PopulateScrollList(name)

		local buttonHeight, numButtons = GrOM.GetScrollFrameButtonStats(self:GetHeight())
		--local buttonHeight, numButtons = 16, 5

		local offset = self.offset

		local myFullName = UnitName("player") .. "-" .. GetRealmName()

		for i = 1, numButtons do
			local buttonText = list[i + offset] or "<???>"
			_G[name..i.."DataLabel"]:SetText(buttonText)
			if name == "GOMaticMVPScrollFrame" then
				if buttonText and selectedMVP and strlower(buttonText) == strlower(selectedMVP) then
					_G[name..i]:LockHighlight()
				else
					_G[name..i]:UnlockHighlight()
				end
			end
			if name == "GOMaticSavesScrollFrame" then
				if buttonText == selectedSave then
					_G[name..i]:LockHighlight()
				else
					_G[name..i]:UnlockHighlight()
				end
			end
			if name == "GOMaticEZTemplateScrollFrame" then
				if buttonText == selectedEZTemplate then
					_G[name..i]:LockHighlight()
				else
					_G[name..i]:UnlockHighlight()
				end
			end
			if name == "GOMaticSyncScrollFrame" then
				if _G[name..i.."DataLabel"]:GetText() == myFullName then
					_G[name..i.."Check"]:Disable()
				else
					_G[name..i.."Check"]:Enable()
				end
				_G[name..i.."Check"]:SetChecked(GrOM_Vars.syncProfiles[buttonText])
			end

			if i + offset > #list then
				_G[name..i]:Hide()
			else
				_G[name..i]:Show()
			end
		end

		if name == "GOMaticMVPScrollFrame" then
			UpdateMVPButtons()
		end

		if name == "GOMaticSavesScrollFrame" then
			UpdateSaveButtons()
		end

		if name == "GOMaticEZTemplateScrollFrame" then
			UpdateEZTemplateButtons()
		end

		local maxValues = #list
		if numButtons >= maxValues then
			maxValues = numButtons + 1
		end

		FauxScrollFrame_Update(self, maxValues, numButtons, buttonHeight)
	end

	function GrOM.CreateScrollFrameButton(buttonWidth, buttonHeight, parent, anchorTo, b)
		local template = "GOMaticScrollFrameButtonTemplate"
		if parent:GetName() == "GOMaticSyncScrollFrame" then
			template = "GOMaticScrollFrameCheckButtonTemplate"
		end
		local f = CreateFrame("BUTTON", parent:GetName()..b, parent, template)
		f:SetScript("OnLoad", function(self) _G[self:GetName().."DataLabel"]:SetText("test**") end)
		local relPoint = (anchorTo == parent:GetName()) and "TOPLEFT" or "BOTTOMLEFT"
		f:SetWidth(buttonWidth)
		f:SetHeight(buttonHeight)
		f:ClearAllPoints()
		f:SetPoint("TOPLEFT", anchorTo, relPoint)
		f.parentName = parent:GetName()
		f.buttonNumber = b
		f:SetScript("OnClick", function(self) GrOM.ScrollFrameButtonClick(self.parentName, self.buttonNumber, _G[self:GetName().."DataLabel"]:GetText()) end)

		return f
	end

	function GrOM.ScrollFrameButtonClick(parentName, buttonNumber, text)
		if parentName == "GOMaticMVPScrollFrame" then
			if selectedMVP ~= text then
				selectedMVP = text
				GrOM.UpdateMVPPane()
			end
		elseif parentName == "GOMaticSavesScrollFrame" then
			if selectedSave ~= text then
				selectedSave = text
				GrOM.UpdateSavesPane()
			end
		elseif parentName == "GOMaticEZTemplateScrollFrame" then
			if selectedEZTemplate ~= text then
				selectedEZTemplate = text
				GrOM.UpdateEZTemplatePane()
			end
		end
	end

	function GrOM.InitializeScrollFrame(self)
		local buttonHeight, numButtons = GrOM.GetScrollFrameButtonStats(self:GetHeight())
		--local buttonHeight, numButtons = 16, 5
		local buttonWidth = self:GetWidth()

		self.offset = 0

		local b = self:GetName()

		for i = 1, numButtons do
			b = GrOM.CreateScrollFrameButton(buttonWidth, buttonHeight, self, b, i)
		end

		GrOM.ScrollFrameUpdate(self)
	end

	function GrOM.FauxScrollFrame_OnVerticalScroll(self, offset, itemHeight, updateFunction)
		local scrollbar = _G[self:GetName().."ScrollBar"]
		scrollbar:SetValue(offset)
		self.offset = floor((offset / itemHeight) + 0.5)
		updateFunction(self)
	end

	function GrOM.UIFrameFadeIn(...)
		if not GrOM_Vars.disableFading then
			UIFrameFadeIn(...)
		end
	end
	
	GrOM.LoadGUIFunctions = nil
end
