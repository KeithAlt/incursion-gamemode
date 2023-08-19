local notif = "You can't transfer a backpack that has items inside of it."

hook.Add("CanItemBeTransfered", "ArmorSmithImplant", function(item, oldInv, newInv)
    if item.isBag and oldInv != newInv and item.getInv and item:getInv() and table.Count(item:getInv():getItems()) > 0 then
		local char = nut.char.loaded[oldInv.owner]
		if SERVER and char and char:getPlayer() then
			char:getPlayer():notify(notif)
		elseif CLIENT then
			nut.util.notify(notif)
		end
		return false
    end
end)
