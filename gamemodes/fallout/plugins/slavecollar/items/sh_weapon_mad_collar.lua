ITEM.name = "Slaveboy 2000"
ITEM.desc = "Controller used to, well, control slaves."
ITEM.model = "models/Items/battery.mdl"
ITEM.category = "Slavery"

ITEM.functions.activate = {
	name = "Activate",
	tip = "Activate the control panel of this device.",
	icon = "icon16/application_view_tile.png",
	onRun = function(item)
		net.Start("nutSlaveboyControlPanel")
		net.Send(item.player)

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity)
	end
}