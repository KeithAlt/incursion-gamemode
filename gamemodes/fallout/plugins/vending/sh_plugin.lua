PLUGIN.name = "Vending"
PLUGIN.author = "Vex"
PLUGIN.description = "..."

local machines = {
	"nut_nukamachine",
	"nut_nukamachineclassic",
	"nut_vimmachine",
	"nut_sunsetamachine",
	"nut_sarsaparillamachine",
	"nut_milkmachine",
}

if SERVER then
	function PLUGIN:InitializedPlugins()
		timer.Create("nutVendingRefill", 300, 0, function()
			for _, y in pairs(machines) do
				for _, v in pairs(ents.FindByClass(y)) do
					v:Refill(1)
				end
			end
		end)
	end
end
