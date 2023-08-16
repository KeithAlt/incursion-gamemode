--[[-------------------------------------------------------
InvTrash by jonjo/yobson

To prevent degends leaving their trash all over the place
---------------------------------------------------------]]

InvTrash = InvTrash or {}
InvTrash.Config = InvTrash.Config or {}
InvTrash.Print = jlib.GetPrintFunction("[InvTrash]")
InvTrash.Author = "jonjo"

AddCSLuaFile("invtrash_config.lua")
include("invtrash_config.lua")

function InvTrash.Init()
	nut.item.registerInv("invtrash", InvTrash.Config.SizeW, InvTrash.Config.SizeH, false)
end
hook.Add("InitPostEntity", "InvTrashInit", InvTrash.Init)

function InvTrash.Notify(msg, ply)
	if SERVER then
		ply:falloutNotify(msg, InvTrash.Config.NotifSound)
	else
		nut.fallout.notify(msg, InvTrash.Config.NotifSound)
	end
end

-- Run CanTrash hook inside CanItemBeTransfered
hook.Add("CanItemBeTransfered", "CanTrash", function(item, oldInv, newInv)
	local targetChar = nut.char.loaded[newInv.owner]

	if targetChar and targetChar:getData("trashInvID") == newInv.id then
		return hook.Run("CanTrash", targetChar:getPlayer())
	end
end)

-- Combat check
hook.Add("CanTrash", "NoCombat", function(ply)
	if ply:IsInCombat(InvTrash.Config.CombatTime) then
		InvTrash.Notify("You cannot use your trash while in combat", ply)
		return false
	end
end)

-- Alive check
hook.Add("CanTrash", "NoDead", function(ply)
	if !ply:Alive() then
		InvTrash.Notify("You cannot use your trash while dead", ply)
		return false
	end
end)

-- Restrained check
hook.Add("CanTrash", "NoRestrain", function(ply)
	if ply:getNetVar("restricted") or ply:IsHandcuffed() then
		InvTrash.Notify("You cannot use your trash while restrained", ply)
		return false
	end
end)
