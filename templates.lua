GrOM.userTemplates["Split"] = {
	"Split groups",

	{
		[1] = "autosplit_tank",
		[2] = "autosplit_healer",
		[3] = "autosplit_melee",
		[4] = "autosplit_range"
	},
	{
		[1] = {nil, "RANGE_DPS", false, nil, true}
	}
}


GrOM.userTemplates["Split_no_tanks"] = {
	"Split groups, except tanks",

	{
		[1] = {nil, "TANK", true, nil, true},
		[2] = "autosplit_healer",
		[3] = "autosplit_melee",
		[4] = "autosplit_range"
	},
	{
		[1] = {nil, "RANGE_DPS", false, nil, true}
	}
}

GrOM.userTemplates["Healers_first"] = {
	"Healers first",

	{
		[1] = {nil, "HEALER", true, nil, true}
	},
	{
		[1] = {nil, "MELEE_DPS", true, nil, true},
		[2] = {nil, "TANK", true, nil, true},
		[3] = {nil, "RANGE_DPS", false, nil, true}
	}
}

GrOM.userTemplates["Group_by_class"] = {
	"Group by class",

	{
		[1] = {"WARRIOR", "MELEE_DPS", false, nil, true},
		[2] = "success END",
		[3] = {"ROGUE", "MELEE_DPS", false, nil, true},
		[4] = "success END",
		[5] = {"PALADIN", "MELEE_DPS", false, nil, true},
		[6] = "success END",
		[7] = {"DEATHKNIGHT", "MELEE_DPS", false, nil, true},
		[8] = "success END",
		[9] = {"MONK", "MELEE_DPS", false, nil, true},
		[10] = "success END",
		[11] = {"HUNTER", "MELEE_DPS", false, nil, true},
		[12] = "success END",
		[13] = {"SHAMAN", "MELEE_DPS", false, nil, true},
		[14] = "success END",
		[15] = {"MAGE", "MELEE_DPS", false, nil, true},
		[16] = "success END",
		[17] = {"WARLOCK", "MELEE_DPS", false, nil, true},
		[18] = "success END",
		[19] = {"DRUID", "MELEE_DPS", false, nil, true},
		[20] = "success END",
		[21] = {"DEMONHUNTER", "MELEE_DPS", false, nil, true},
		[22] = "anchor END"
	},
	{
		[1] = {"WARRIOR", "MELEE_DPS", false, nil, true},
		[2] = "success END",
		[3] = {"ROGUE", "MELEE_DPS", false, nil, true},
		[4] = "success END",
		[5] = {"PALADIN", "MELEE_DPS", false, nil, true},
		[6] = "success END",
		[7] = {"DEATHKNIGHT", "MELEE_DPS", false, nil, true},
		[8] = "success END",
		[9] = {"MONK", "MELEE_DPS", false, nil, true},
		[10] = "success END",
		[11] = {"HUNTER", "MELEE_DPS", false, nil, true},
		[12] = "success END",
		[13] = {"SHAMAN", "MELEE_DPS", false, nil, true},
		[14] = "success END",
		[15] = {"MAGE", "MELEE_DPS", false, nil, true},
		[16] = "success END",
		[17] = {"WARLOCK", "MELEE_DPS", false, nil, true},
		[18] = "success END",
		[19] = {"DRUID", "MELEE_DPS", false, nil, true},
		[20] = "success END",
		[21] = {"DEMONHUNTER", "MELEE_DPS", false, nil, true},
		[22] = "anchor END",
		[23] = "pass 3",
		[24] = {nil, "RANGE_DPS", false, nil, true},
		[25] = "anypass"
	}
}

GrOM.userTemplates["By_location_BGs"] = {
	"Group by map location",

	{
		[1] = "dynbg"
	},
	{
		[1] = {nil, "RANGE_DPS", false, nil, true}
	}
}
