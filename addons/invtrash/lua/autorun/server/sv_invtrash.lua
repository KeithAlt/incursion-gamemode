util.AddNetworkString("InvTrashEmpty")
util.AddNetworkString("InvTrashDump")

-- Create/restore trash invs on character load
function InvTrash.GetTrashInv(ply, callback)
	local char = ply:getChar()

	if !char then
		callback()
		return "No char"
	end

	local trashInvID = char:getData("trashInvID")

	if isnumber(trashInvID) and trashInvID < 0 then
		InvTrash.Print("Attempt to get trash inv for " .. ply:SteamIDName() .. " failed: trash inv is being created.")
		callback()
		return "Trash inv is being created"
	end

	if trashInvID then
		InvTrash.Print("Restoring trash inv for " .. ply:SteamIDName() .. " inventory #" .. trashInvID)
		nut.item.restoreInv(trashInvID, InvTrash.Config.SizeW, InvTrash.Config.SizeH, function(inv)
			inv:sync(ply)
			inv.owner = char:getID()

			if isfunction(callback) then
				callback(inv)
			end
		end)
		return "Restoring inv"
	else
		InvTrash.Print("Creating trash inv for " .. ply:SteamIDName())
		char:setData("trashInvID", -1) -- Marked as pending

		nut.item.newInv(char:getID(), "invtrash", function(inv)
			InvTrash.Print("Created trash inv for " .. ply:SteamIDName() .. " inventory #" .. inv:getID())
			char:setData("trashInvID", inv:getID())
			inv.owner = char:getID()

			if isfunction(callback) then
				callback(inv)
			end
		end)
		return "Creating new inv"
	end
end

hook.Add("PlayerLoadedChar", "InvTrashCreate", function(ply, char)
	InvTrash.GetTrashInv(ply)
end)

-- Sound funcs
function InvTrash.GetTrashSound()
	return "ui/craft" .. math.random(1, 2) .. ".mp3"
end

-- Log funcs
function InvTrash.Log(msg)
	InvTrash.Print(msg)
	DiscordEmbed(msg, "🗑️ Trash Log 🗑️", Color(255, 1, 82), "Admin")
end

-- Erase all items in the player's trash inv
net.Receive("InvTrashEmpty", function(len, ply)
	local canTrash = hook.Run("CanTrash", ply)

	if canTrash == false then
		return
	end

	local invID = net.ReadUInt(32)
	local inv = nut.item.inventories[invID]
	local char = ply:getChar()

	if inv and char and inv.owner == char:getID() then
		local count = 0
		for _, item in pairs(inv:getItems()) do
			local shouldRemove = hook.Run("ShouldTrashItem", item, ply, char, inv)

			if shouldRemove == false then
				InvTrash.Print("Skipping removal of " .. item.uniqueID)
			else
				InvTrash.Print("Removing " .. item.uniqueID)

				if item.uniqueID != "keycard" then
					count = count + 1
				end

				item:remove()
			end
		end

		nut.leveling.giveXP(ply, count * 1) -- Give the player EXP because they're fat
		InvTrash.Log(ply:SteamIDName() .. " has emptied their trash inv and deleted " .. count .. " items")
	else
		InvTrash.Notify("Inventory doesn't exist or you don't own it", ply)
		InvTrash.Print(ply:SteamIDName() .. " failed to empty trash inv: " .. InvTrash.GetTrashInv(ply))
	end

	ply:EmitSound(InvTrash.GetTrashSound())
end)

-- Returns the items to the player's inventory
net.Receive("InvTrashDump", function(len, ply)
	local invID = net.ReadUInt(32)
	local inv = nut.item.inventories[invID]
	local char = ply:getChar()

	if inv and char and inv.owner == char:getID() then
		local charInv = char:getInv()

		local count = 0
		for _, item in pairs(inv:getItems()) do
			local transfer = item:transfer(charInv:getID()) -- Tries to transfer the item into the player's inventory
			if !transfer then -- If it fails to transfer, drops it on the ground instead
				item:transfer()
			end

			InvTrash.Print("Returning " .. item.uniqueID)
			count = count + 1
		end

		InvTrash.Log(ply:SteamIDName() .. " has returned their trash inv and returned " .. count .. " items")
	else
		InvTrash.Notify("Inventory doesn't exist or you don't own it", ply)
		InvTrash.Print(ply:SteamIDName() .. " failed to return trash inv: " .. InvTrash.GetTrashInv(ply))
	end

	-- ply:EmitSound(InvTrash.GetTrashSound())
end)

-- Emit sound & log on item moved to trash
hook.Add("CanItemBeTransfered", "TrashLog", function(item, oldInv, newInv)
	local targetChar = nut.char.loaded[newInv.owner]

	if targetChar and targetChar:getData("trashInvID") == newInv.id then
		local ply = targetChar:getPlayer()
		if IsValid(ply) then
			ply:EmitSound(InvTrash.GetTrashSound())
			InvTrash.Log(ply:SteamIDName() .. " moved " .. item.name:lower() .. " to their trash")
		end
	end
end)

-- Equipped check
hook.Add("ShouldTrashItem", "NoEquipped", function(item, ply)
	if item:getData("equipped", false) then
		InvTrash.Notify("Cannot trash " .. item.name:lower() .. " because it is currently equipped", ply)
		return false
	end
end)
