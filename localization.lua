GrOM = {}

GrOM.Localization = {
	talentsupdated = "Group O Matic has updated its settings file from WoW %s. All stored player specs are assumed to be outdated and have been reset.",
	loaded = " loaded. /groupomatic or /gom for help.",
	outputprefix = "<Group O Matic> ",
	requestingtalents = "Determining raid talents...",
	filledinunknownroleswithdefaultsrunping = "One or more players did not respond to the talent request, and were also out of range to inspect. Their talents have been filled in with their last known talents or defaults based on their class. You can run /gom ping to see who has Group O Matic installed.",
	cancelled = "Auto-arrange cancelled.",
	arrangedone = "Auto-arrange completed.",

	--Make sure to change this if you change the commands
	help = "/groupomatic or /gom active \| auto \| cancel \| save \| restore \| secondarytalents \| sure \| silent \| gui\n/raidswap or /rs name1 name2\n/raidmove or /rm name #\n/rs and /rm can take some other arguments, see the wowi page.",

	--Followed by a list of available raids to restore
	thesearegoodnames = "Your saved raids:",

	--%s is the name of the raid \" is a "
	raidsaved = "Current raid saved as \"%s\"",

	--Followed by one of the specs, i.e. "Jim has respecced since the last talent request and is now a tank."
	playerhasrespecced = "%s has respecced since the last talent request and is now ",

	notinstalled = "No reply.",
	sureon = "Group arrangement confirmation disabled.",
	sureoff = "Group arrangement confirmation enabled.",
	guishown = "GUI enabled.",
	guihidden = "GUI disabled.",
	overrideon = "GOM will not try to inspect nearby raid members' talents directly.",
	overrideoff = "GOM will try to inspect nearby raid members' talents directly.",
	unsilenced	= "Console output enabled.",
	deletedall = "All saved raids have been deleted.",
	talentson = "Remote talent request enabled.",
	talentsoff = "Remote talent request disabled.",
	alwaysactiveon = "GOM is now always active.",
	alwaysactiveoff = "GOM is now active only in a raid.",
	secondaryswap = "Talent scan caching secondary talents: ",
	fadingtoggle = "Fade effects: ",
	talentsfound = "Talent collection done: %s",

	--Used to label the group exclusions checkboxes, i.e. "Group 2"
	grouplabel = "Group ",

	myName2 = " (Raid talents: %d%% known.)",
	myName3 = " TALENT INTERPRETER OUTDATED",

	--Name of the default auto-arrange template
	defaultname = "Group melee/tanks (default)",

	eztemplatesname = "Custom Templates",

	syncpanetext = "Auto-sync the following settings from the selected characters below:",
	templatetext = "Auto-Arrange Template:",
	excludetext = "Don't modify these groups:",
	throttletext = "Make %d move(s) at a time. (10 or more can D/C you!)",
	restoremethodtext = "Restore Method:",
	ignoreleveltext = "Separate players below level:",
	editsavestext = "Player names must be exact and are Case-Sensitive!",

	enablesyncout = "Allow sync to others from this character.",
	savebutton = "Save",
	restorebutton = "Restore",
	autobutton = "Auto",
	hidebutton = "Hide",
	morebutton = "More>>",
	lessbutton = "<<Less",
	pingbutton = "Ping",
	ignoredeadbutton = "Separate dead.",
	ignoreofflinebutton = "Separate offline.",
	overridebutton = "Don't pre-scan.",
	silencebutton = "Silence console output.",
	surebutton = "Always sure.",
	excludebutton = "Exclusions",
	excludesavebutton = "Also exclude from saves.",
	continuousscanbutton = "Continuous scan.",
	editsavebutton = "Edit Save",
	newblankbutton = "New Blank",
	syncnowbutton = "Sync Now",
	editeztemplatebutton = "Edit a Copy",
	nukebutton = "Clear Cache",

	--Remove a saved raid
	delsavebutton = "Delete",

	--Rename a saved raid
	renamesavebutton = "Rename",

	--Add/Remove an MVP
	addmvpbutton = "Add",
	delmvpbutton = "Remove",

	--Delete all MVPs
	dellallmvpbutton = "Remove All",

	--Move an MVP down/up in the list
	demotemvpbutton = "Move Down",
	promotemvpbutton = "Move Up",

	--These are preceeded by playerhasrespecced, i.e. "Tom has respecced since the last talent request and is now a healer."
	specdps = "DPS.",
	spechealer = "a healer.",
	spectank = "a tank.",

	doarrangedialogtext = "||Group O Matic||\n\nReady to move raid groups. Are you sure?",
	toomanyfailedmovesdialogtext = "||Group O Matic||\n\nCritical Error arranging groups: Too many attempted moves have failed.\nThe raid arrangement was not completed. Aborting.",

	--Confirmation for overwriting a saved raid
	dosavedialogtext = "||Group O Matic||\n\nAre you sure you want to overwrite %s?",

	autoabortdialogtext = "||Group O Matic||\n\nAuto-arrange cancelled because someone left the raid. Do you want to try again?",
	addonoutdateddialogtext = "||Group O Matic||\n\nYour copy of Group O Matic is outdated, please think about updating.",
	newsavedialogtext = "||Group O Matic||\n\nPlease enter a name for this raid layout:",
	deletealldialogtext = "||Group O Matic||\n\nAre you sure you want to delete all of your saved raids?",
	addmvpdialogtext = "||Group O Matic||\n\nPlease enter the name to add:",
	deleteallmvpsdialogtext = "||Group O Matic||\n\nAre you sure you want to remove all MVPs?",
	renamesavedialogtext = "||Group O Matic||\n\nPlease enter a new name for this raid layout:",
	renameeztemplatedialogtext = "||Group O Matic||\n\nPlease enter a new name for this Auto-arrange Template:",
	donukedialogtext = "||Group O Matic||\n\nThis will delete all saved talents (for this character) and sync data (for all characters on this account), and reload your UI. Do you want to continue?",

	buttonok = "OK",
	buttoncancel = "Cancel",
	buttonstartover = "Start Over",


	--Commands that you can pass to /gom    These must be 1 word, no spaces. If you localize the commands remember to update "help" above
	autocmd = "auto",
	restorecmd = "restore",
	pingcmd = "ping",
	savecmd = "save",
	cancelcmd = "cancel",
	surecmd = "sure",
	guicmd = "gui",
	silentcmd = "silent",
	talentscmd = "talents",
	activecmd = "active",
	secondarycmd = "secondarytalents",

	arathi = "Arathi Basin",
	eots = "Eye of the Storm",

	--Create a new raid save
	newmenuitem = "New...",

	--Delete all saved raids
	deleteallmenuitem = "Delete All...",

	--Hide the current extras pane (group exclusions, MVPs, etc)
	closemenuitem = "~~Hide Settings~~",

	--Label for the extras menu when there is nothing selected (the panel is closed)
	extrasmenuitem = "Settings",

	excludemenuitem = "Exclude Groups",
	throttlemenuitem = "Arrangement Speed Throttle",
	mvpsmenuitem = "MVPs",
	savesmenuitem = "Manage Saved Raids / Change Restore Method",
	syncmenuitem = "Sync between characters",
	ignoremenuitem = "Dead/Offline/Low-Level",

	--Restore methods -- only change the second part!
	["dumb"] = "Match by name only",
	["smart"] = "Match by name, then by roles",
	["armchair"] = "Match by name, then by class",
	["merge"] = "Auto-arrange unmatched players",
	["separate"] = "Separate out unmatched players",

	--This defines how to display the two methods...the two %s are where the first/second part of the restore method goes in the menu.
	restoremethodpattern = "%s |||| %s",

	defaultmethod = " (default)",

	autotip1 = "Auto-Arrange",
	autotip2 = "Automatically arrange the current raid based on class and spec.",
	restoretip1 = "Restore Raid",
	restoretip2 = "Restores a raid arrangement - or the closest possible - that you have previously saved.",
	savetip1 = "Save Raid",
	savetip2 = "Saves the current raid arrangement to restore later.",
	hidetip1 = "Hide this window",
	hidetip2 = "You can show the window again with\n/gom gui",
	pingtip1 = "Ping",
	pingtip2 = "Check the version of GOM being run by current raid members.",
	overrideremotetip1 = "Disable Talent Inspection",
	overrideremotetip2 = "If this is checked, GOM will not try to gather talent data by inspecting nearby raid members. Checking this may speed up the talent collection process before an auto-arrange. If you check this, you may want to also check \"Continuous Scan\"",
	silencetip1 = "Silence Console Output",
	silencetip2 = "GOM will not print anything to the chat frame if this is checked.",
	suretip1 = "Always Sure",
	suretip2 = "GOM will not prompt you to confirm before beginning an auto-arrange if this is checked.",
	excludetip1 = "Exclude Groups",
	excludetip2 = "Lets you exclude specific groups from being restored/saved/auto-arranged (Note: The AB/EotS template ignores this).",
	excludesavetip1 = "Exclude from saves",
	excludesavetip2 = "If this is checked, these groups will be ignored when saving a raid arrangement.",
	demotemvptip1 = "Move MVP Down",
	demotemvptip2 = "Lower MVPs are valued less than higher MVPs with the same roles, but are still valued more than non-MVPs.",
	promotemvptip1 = "Move MVP Up",
	promotemvptip2 = "Lower MVPs are valued less than higher MVPs with the same roles, but are still valued more than non-MVPs.",
	continuousscantip1 = "Continuous Scan",
	continuousscantip2 = "If this is checked, GOM will scan the talents of nearby raid members automatically every 5 minutes while not in combat.",

	--start ez creator
	
	--class/spec
	classes = {
		WARRIOR = "Warrior",
		ROGUE = "Rogue",
		DEATHKNIGHT = "Death Knight",
		MAGE = "Mage",
		PRIEST = "Priest",
		DRUID = "Druid",
		PALADIN = "Paladin",
		SHAMAN = "Shaman",
		WARLOCK = "Warlock",
		HUNTER = "Hunter"
	},
	roles = {
		TANK = "Tank",
		HEALER = "Healer",
		MELEE_DPS = "Melee DPS",
		RANGE_DPS = "Range DPS",
	},
	--end class/spec
	
	creatortitle1 = "Auto-arrange Template Creator, Enter a name:",
	creatortitle2 = "Group %d Limitations. Limit group to at most:",
	creatortitle3 = "Group %d Rules. Try to add members to the group in this order:\n\n              Class          Preferred Spec",
	creator1checkdesc = "For this template, \"%s\" means:",
	nextbutton = "Next >",
	mergeusingdefault = "Merge extras using the default template.",
	separateextras = "Push extras into the lower groups.",

	any = "Any...",
	none = "None...",
	requirespec = "Require spec", --i.e. require a character to have the role selected for Preferred Spec for it to be considered a match
	loop = "Repeat", --causes this line to repeat as many times as it can

	noclassorspec = "You must specify a class and/or spec for each limitation.",
	deletefirst = "If you want to use that name, delete or rename the existing EZ Template first.",

	--end ez creator
	
	--start member add stuff
	memberaddmenuitem = "Automatic actions during raid invites",
	onlyasleaderbutton = "Only perform these actions if you are the raid leader.",
	autoautotext = "(On full subgroup or not found, auto-place will push to lower groups).",
	autoautotext2 = "Auto-arrange when size first hits:           Auto-place invitees using:",
	--end member add stuff

	synced = "Sync done, %d items added.",

	--sync mapping, localize the stuff in []s, leave the second part the way it is
	syncMap = {
		["Specs"] = "rolesByNameCache",
		["Saves"] = "SavedRaidLayouts",
		["MVPs"] = "MVPs",
		["Auto Templ."] = "ezTemplates"
	},
	
	--decurse mapping, only change the last part of each
	decurseMap = {
		{"POISON", "Poison"},
		{"DISEASE", "Disease"},
		{"CURSE", "Curse"},
		{"MAGIC", "Magic"}
	},

	notraidleadererror = "You must be the raid leader or an assistant.",
	mustenternameerr = "You must enter a name.",
	nopointerr = "GOM is disabled because you are not in a raid (try /gom active).",
	arrangefailederr = "Critical error finding optimal group arrangement, auto-arrange cancelled.",
	memberaddederr = "Auto-arrange cancelled because a member was added to the raid that GOM cannot find a place for. Please try again.",
	pleasewaiterr = "Please wait until the previous action has finished.",
	inspecttalentserr = "Error reading %s's talents, the number of talents does not match the number expected. This addon is probably outdated. The auto-arrange will use default talents for this player instead.",
	combaterr = "Auto-arrange cancelled because you cannot automatically arrange groups in combat.",
	badlocationerr = "You must be in AB or EotS to use this template.",
	resettemplateerr = "The auto-arrange template has been set to the default, because you can't use the dynamic AB/EotS template for raid restores.",
	badcustomraidinputerr = "One or more input values is invalid.  %s",
	talentserr = "There was a problem reading your talents. If you have the latest version, please report this error at GOM's wowinterface page and let me know your class."
}

--Simplified Chinese localization by StarAngel
--简体中文版:冷血凝月
if GetLocale() == "zhCN" then
	GrOM.Localization = {
		talentsupdated = "Group O Matic has updated its settings file from WoW %s. All stored player specs are assumed to be outdated and have been reset.", --needs updating
		loaded = " 加载成功输入 /groupomatic 或 /gom 查看帮助.",
		outputprefix = "<Group O Matic> ",
		requestingtalents = "决定团队天赋...",
		filledinunknownroleswithdefaultsrunping = "一个或者多个玩家对查看对方天赋的请求没有回应, 可能是因为在有效距离之外. 他们的天赋会被填充为最近一个知道天赋的玩家的天赋或者基于他们的职业填充。你可以输入/gom ping来查看那些人装了Group O Matic。",
		cancelled = "自动分配取消.",
		arrangedone = "自动分配完成.",
		help = "/groupomatic 或 /gom active \| auto \| cancel \| save \| restore \| secondarytalents \| sure \| silent \| gui\n/raidswap 或 /rs 名字1 名字2\n/raidmove 或 /rm 名字 #",
		thesearegoodnames = "你保存了团队配置:",
		raidsaved = "当前的团队配置被保存为 \"%s\"",
		playerhasrespecced = "%s 被填充为最近一个请求得到的天赋了。",
		notinstalled = "未安装.",
		sureon = "设置团队分配 确认 关闭.",
		sureoff = "设置团队分配 确认 启用.",
		guishown = "GUI设置界面(图形设置界面) 启用.",
		guihidden = "GUI设置界面(图形设置界面) 关闭.",
		overrideon = "GOM不会直接去尝试查看附近的团队成员天赋.",
		overrideoff = "GOM会直接去尝试查看附近的团队成员天赋.",
		unsilenced	= "控制台输出启用.",
		deletedall = "所有保存的团队配置将被删除.",
		talentson = "远程天赋请求启用.",
		talentsoff = "远程天赋请求关闭.",
		grouplabel = "小队",
		alwaysactiveon = "GOM现在总是被处于激活状态.", 
		alwaysactiveoff = "GOM现在只在团队中时激活.",
		secondaryswap = "Talent scan caching secondary talents: ",  --needs updating
		fadingtoggle = "Fade effects: ",  --needs updating
		talentsfound = "Talent collection done. Setting up the raid according to the selected template.",  --needs updating
		
		myName2 = " (团队天赋: %d%% 已知晓.)",
		myName3 = " TALENT INTERPRETER OUTDATED",  --needs updating

		defaultname = "默认",

		eztemplatesname = "简单模板",

		syncpanetext = "自动同步来自于已选择的角色的如下设置:",
		templatetext = "自动分配 模板:",
		excludetext = "请不要改变这些小队:",
		throttletext = "同一时间内移动%d个玩家.(超过10个能让你断线!)",
		restoremethodtext = "恢复方式:", 
		ignoreleveltext = "Separate players below level:", --needs updating
		editsavestext = "玩家名字必须精确区分大小写!", 
		newblankbutton = "新的空栏",

		enablesyncout = "允许别人同步该角色.",
		savebutton = "保存",
		restorebutton = "恢复",
		autobutton = "自动",
		hidebutton = "隐藏",
		morebutton = "详细>>",
		lessbutton = "<<精简",
		pingbutton = "版本检查",
		ignoredeadbutton = "Separate dead.",  --needs updating
		ignoreofflinebutton = "Separate offline.",  --needs updating
		overridebutton = "关闭直接天赋查看.",
		silencebutton = "静默控制台输出.",
		surebutton = "自动确定.",
		excludebutton = "例外",
		excludesavebutton = "同时例外保存.",
		addmvpbutton = "增加",
		delmvpbutton = "移除",
		dellallmvpbutton = "移除所有",
		demotemvpbutton = "往下移",
		promotemvpbutton = "往上移",
		delsavebutton = "移除",
		renamesavebutton = "重命名", 
		continuousscanbutton = "继续扫描.", 
		editsavebutton = "编辑保存", 		
		syncnowbutton = "现在开始同步",
		editeztemplatebutton = "编辑一份拷贝",
		nukebutton = "Clear Cache",

		specdps = "DPS.",
		spechealer = "一位治疗.",
		spectank = "一位坦克.",

		doarrangedialogtext = "||Group O Matic||\n\n准备开始分配队伍. 你确定吗？",
		toomanyfailedmovesdialogtext = "||Group O Matic||\n\n临界错误 分配队伍: 太多次请求改变队伍失败了.\n团队分配没有完成. 中断.",
		dosavedialogtext = "||Group O Matic||\n\n你确定要覆盖 %s?",
		autoabortdialogtext = "||Group O Matic||\n\n有些人离开了团队所以要重新分配队伍. 你同意再分配一次吗?",
		addonoutdateddialogtext = "||Group O Matic||\n\n你的 Group O Matic 是过时的, 请考虑更新.",
		newsavedialogtext = "||Group O Matic||\n\n请输入一个团队布局的名称:",
		deletealldialogtext = "||Group O Matic||\n\n你确定要删除所有的团队分配配置?",
		addmvpdialogtext = "||Group O Matic||\n\n请输入欲添加的名字:",
		deleteallmvpsdialogtext = "||Group O Matic||\n\n你确定要移除所有的MVP吗?",
		renamesavedialogtext = "||Group O Matic||\n\n请输入一个团队布局的名称:",
		renameeztemplatedialogtext = "||Group O Matic||\n\n请输入一个新的名字保存 EZ 模板:",
		donukedialogtext = "||Group O Matic||\n\nThis will delete all saved talents and sync data, and reload your UI. Do you want to continue?", --needs updating

		buttonok = "确定",
		buttoncancel = "取消",
		buttonstartover = "开始分配",

		autocmd = "auto",
		restorecmd = "restore",
		pingcmd = "ping",
		savecmd = "save",
		cancelcmd = "cancel",
		surecmd = "sure",
		guicmd = "gui",
		silentcmd = "silent",
		talentscmd = "talents",
		activecmd = "active",
		secondarycmd = "secondarytalents",

		arathi = "阿拉希盆地",
		eots = "风暴之眼",

		newmenuitem = "新的配置...",
		deleteallmenuitem = "删除所有...",
		closemenuitem = "~~隐藏例外~~",
		extrasmenuitem = "例外",
		excludemenuitem = "例外队伍..",
		throttlemenuitem = "加速分配队伍的速度...",
		mvpsmenuitem = "MVPs",
		savesmenuitem = "管理保存/恢复选项",
		syncmenuitem = "与其他角色同步",
		ignoremenuitem = "Dead/Offline/Low-Level",  --needs updating

		["dumb"] = "傻瓜式",
		["smart"] = "精确的", 
		["armchair"] = "Armchair",
		["merge"] = "合并", 
		["separate"] = "分离", 
		restoremethodpattern = "%s - %s",
		defaultmethod = " (默认)",

		--start ez creator
		
		--class/spec
		classes = { --needs checking...i just used google translate for these (-akryn)
			WARRIOR = "战士",
			ROGUE = "浪客",
			DEATHKNIGHT = "死亡骑士",
			MAGE = "法师",
			PRIEST = "牧师",
			DRUID = "德鲁伊",
			PALADIN = "帕拉丁",
			SHAMAN = "萨满",
			WARLOCK = "术士",
			HUNTER = "猎人"
		},
		roles = { --needs checking...i just used google translate for these (-akryn)
			MEAT_SHIELD = "Party damage reducer", --needs updating
			TANK = "一位坦克",
			TANK_BUFFER = "人谁降低的程度受伤",
			HEALER = "一位治疗",
			MANA_BATTERY = "一位消息人士的MP",
			HEAL_BUFFER = "帮手为医士",
			MELEE_BUFFER = "帮手的剑用户",
			RANGE_BUFFER = "帮手的弓用户",
			SPELL_BUFFER = "帮手魔法用户",
			MELEE_DPS = "剑用户",
			RANGE_DPS = "弓用户",
			SPELL_DPS = "神奇的用户",
			DECURSER = "地位疾病除尘器"
		},
		--end class/spec
		
		creatortitle1 = "EZ 模板创建者,请输入名字:",
		creatortitle2 = "队伍 %d 限制. 限制队伍最多:",
		creatortitle3 = "队伍 %d 规则. 尝试增加小队成员按此要求:\n\n              职业          首选天赋   忽略天赋",
		creator1checkdesc = "对于这个模板来说, \"%s\" 意思是:",
		nextbutton = "下一步 >",
		mergeusingdefault = "使用默认模版合并其他未填项.",
		separateextras = "将未填项移到较低等级的小队.",
		
		any = "任意...",	
		none = "没有...",
		requirespec = "请求 首选天赋", --does this make sense?
		loop = "重复",
		
		noclassorspec = "你必须指定一个职业或者天赋的每个限制条件.",
		deletefirst = "如果你想用这个名字，请先删除已经存在的EZ模板.",
			
		--end ez creator
		
		--start member add stuff
		memberaddmenuitem = "Automatic actions during raid invites", --needs updating
		onlyasleaderbutton = "Only perform these actions if you are the raid leader.", --needs updating
		autoautotext = "(On full subgroup or not found, auto-place will push to lower groups).", --needs updating
		autoautotext2 = "Auto-arrange when size first hits:           Auto-place invitees using:", --needs updating
		--end member add stuff

		synced = "同步完成, 增加了 %d 项.",
		
		syncMap = {
			["缓存角色姓名"] = "rolesByNameCache",
			["保存团队布局"] = "SavedRaidLayouts",
			["MVPs"] = "MVPs",
			["简单模板"] = "ezTemplates"
		},
		
		decurseMap = {
			{"POISON", "毒药"},
			{"DISEASE", "疾病"},
			{"CURSE", "诅咒"},
			{"MAGIC", "魔法"}
		},

		autotip1 = "自动分配",
		autotip2 = "基于职业和特殊设置自动分配团队.",
		restoretip1 = "恢复团队分配设置",
		restoretip2 = "恢复一个团队分配设置 - 或者如果可能则恢复你最近一次配置.",
		savetip1 = "保存团队分配配置",
		savetip2 = "保存当前团队分配配置为了以后的恢复工作.",
		hidetip1 = "隐藏本窗口",
		hidetip2 = "你可以用\n/gom gui 命令再次显示窗口",
		pingtip1 = "版本检查",
		pingtip2 = "检查当前团队中安装有GOM的版本.",
		overrideremotetip1 = "关闭天赋查看",
		overrideremotetip2 = "如果被勾选，GOM不会再尝试去直接观察附近的团队成员收集天赋数据。检查能使自动分配队伍之前的天赋收集工作更快.",
		silencetip1 = "静默控制台输出",
		silencetip2 = "GOM不会在聊天窗口显示任何校验消息.",
		suretip1 = "总是确定",
		suretip2 = "GOM 不会在开始自动分配之前提示你去确认检查信息.",
		excludetip1 = "排除队伍",
		excludetip2 = "让你能够例外一些特别的队伍来恢复/储存/自动分配(注意:阿拉希盆地/风暴之眼模板会忽略排除)",
		excludesavetip1 = "从保存的例外",
		excludesavetip2 = "如果被勾选,当保存团队分配配置的时候这些队伍会被忽略.",
		demotemvptip1 = "将MVP往下移",
		demotemvptip2 = "在同样角色前提下(治疗,DPS,坦克)，低级别的MVP会被赋予比高级别低的值，但是仍然比不是MVP的要高.",
		promotemvptip1 = "将MVP往上移",
		promotemvptip2 = "在同样角色前提下(治疗,DPS,坦克)，低级别的MVP会被赋予比高级别低的值，但是仍然比不是MVP的要高.",
		continuousscantip1 = "继续扫描",
		continuousscantip2 = "当被勾选时,GOM会自动的在非战斗状态时每隔5分钟扫描附近队友的天赋.", 

		notraidleadererror = "你不是团队的领导者.",
		mustenternameerr = "你必须输入一个名字.",
		nopointerr = "GOM 关闭了，因为你不在团队里.",
		arrangefailederr = "临界错误 当查找最佳团队配置时, 自动分配被启动了",
		memberaddederr = "自动分配启动了因为加入了一位新成员,GOM找不到合适的地方去安置他. 请重试.",
		pleasewaiterr = "在前一次操作完成前请等待.",
		inspecttalentserr = "读取%s的天赋出错,获得的天赋个数与预期的不一样。这个插件可能已经过时了。自动分配会用默认的天赋作为该玩家的天赋。",
		combaterr = "自动分配启动了因为你不能在战斗状态分配队伍.",
		badlocationerr = "你必须在 阿拉希盆地 或 暴风之眼 中使用此模板.",
		resettemplateerr = "该自动分配模板被设置为默认设置,因为你不能在动态的 阿拉希盆地 或 暴风之眼 使用该模板来恢复团队配置.",
		badcustomraidinputerr = "一个或者多个输入参数无效.  %s", 
		talentserr = "读取你的天赋的时候产生了一些问题，如果你有最新的版本，请提交错误报告到GOM的故障中心 或者wowinterface网页来让我知道你的职业。"
	}
end

--if GetLocale() ~= "enUS" and GetLocale() ~= "zhCN" then
	GrOM.Localization.arathi = nil
	GrOM.Localization.eots = nil
--end

--add other locales
if GetLocale() == "????" then
	GrOM.Localization = {

	}
end
