PLUGIN.name = "Daily Rewards"
PLUGIN.author = "Vex"
PLUGIN.desc = "A plugin for daily rewards."

nut.rewards = {
  [1]  = {type = 1, item = "doctorbag"},
  [2]  = {type = 2, amount = 75},
  [3]  = {type = 2, amount = 75},
  [4]  = {type = 1, item = "radx"},
  [5]  = {type = 2, amount = 100},
  [6]  = {type = 2, amount = 100},
  [7]  = {type = 1, item = "stimpack"},
	[8]  = {type = 1, item = "stimpack"},
	[9]  = {type = 1, item = "stimpack"},
  [10] = {type = 2, amount = 125},
  [11] = {type = 2, amount = 125},
	[12] = {type = 2, amount = 125},
  --[12] = {type = 1, item = "flash"}, -- Invalid
  [13] = {type = 2, amount = 150},
  [14] = {type = 2, amount = 150},
  [15] = {type = 1, item = "book"},
  [16] = {type = 2, amount = 200},
  [17] = {type = 2, amount = 200},
  [18] = {type = 1, item = "electronics"},
  [19] = {type = 2, amount = 250},
  [20] = {type = 2, amount = 250},
  [21] = {type = 1, item = "powder"},
  [22] = {type = 2, amount = 300},
  [23] = {type = 2, amount = 300},
  [24] = {type = 1, item = "doctorbag"},
  [25] = {type = 2, amount = 500},
  [26] = {type = 2, amount = 500},
  --[27] = {type = 1, item = "nuclear_material"}, -- Invalid
	[27] = {type = 1, item = "doctorbag"},
  [28] = {type = 2, amount = 700},
  [29] = {type = 2, amount = 700},
  [30] = {type = 1, item = "doctorbag"},
  [31] = {type = 2, amount = 1000},
}

nut.util.include("cl_plugin.lua")
nut.util.include("sv_plugin.lua")

nut.command.add("rewards", {
	syntax = "",
	onRun = function(client, arguments)
		if (SERVER) then
			netstream.Start(client, "dailyRewardsUI")
		end;
	end;
})
