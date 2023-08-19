local categories = {
	["test"] = {
		["beans1"] = {
					 ["name"] = "Double Beans!",
					 ["model"] = nil,
					 ["materials"] = {["beans"] = 1},
					 ["results"] = {["beans"] = 2},
					 ["blueprint"] = nil,
					 ["kit"] = nil,
					 ["xp"] = 0,
					 ["intelligence"] = 0,
					},
		["beans2"] = {
					 ["name"] = "Triple Beans!",
					 ["model"] = nil,
					 ["materials"] = {["beans"] = 1},
					 ["results"] = {["beans"] = 3},
					 ["blueprint"] = nil,
					 ["kit"] = nil,
					 ["xp"] = 0,
					 ["intelligence"] = 0,
					},
	}
}

for i, v in pairs(categories) do
	for x, y in pairs(v) do
		nut.crafting.addRecipe(i, x, y)
	end;
end;