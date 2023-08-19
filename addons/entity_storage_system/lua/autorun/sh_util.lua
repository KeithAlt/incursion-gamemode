if SERVER then
	include("autorun/server/sv_storage.lua")
end

hook.Add("InitPostEntity", "VaultStorageLoad", function()
	MsgC(Color(0,0,255), "[VAULT] ", Color(255,255,255), "Initializing entity vault system\n")

	-- Enter the vault
	nut.command.add("vault_enter", {
	 	adminOnly = true,
	 	onRun = function(ply, arguments)
			jlib.RequestBool("Enter entity vault?", function(bool)
				if !bool then return end

				local vaultPos = entityVault.getRoomPos()

				if !vaultPos then
					ply:notify("No vault to teleport to!")
					return
				end

				ply.prevPos = ply:GetPos()
				ply:SetPos(vaultPos)
				ply:notify("Teleporting to vault")

				jlib.Announce(ply,
					Color(255,255,0), "[VAULT] ", Color(255,234,103), "Information:",
					Color(255,255,255), "\n· Enter '/vault_deploy' to deploy an entity to the world" ..
					"\n· Enter '/vault_return' to return to the world by yourself"
				)

			end, ply, "Yes", "No")
	 	end
	})

	-- Return to the world from the vault
	nut.command.add("vault_return", {
	 	adminOnly = true,
	 	onRun = function(ply, arguments)
			jlib.RequestBool("Return to world?", function(bool)
				if !bool then return end

				if !ply.prevPos then
					ply:notify("No previous location to teleport to!")
					return
				end

				ply:SetPos(ply.prevPos)
				ply.prevPos = nil
				ply:notify("Teleporting to world")

			end, ply, "Yes", "No")
	 	end
	})

	-- Save the position of the storage room
	nut.command.add("vault_savepos", {
	 	adminOnly = true,
	 	onRun = function(ply, arguments)
			if !ply:IsSuperAdmin() then
				ply:notify("You are not a super admin!")
				return
			end

			jlib.RequestBool("Save vault room position?", function(bool)
				if !bool then return end
				entityVault.setRoomPos(ply:GetPos())
				ply:notify("Vault room destination saved")
			end, ply, "Yes", "No")
	 	end
	})

	-- Store an entity in the storage
	nut.command.add("vault_store", {
	 	adminOnly = true,
	 	syntax = "<Entity>",
	 	onRun = function(ply, arguments)
			local entity = ply:GetEyeTrace().Entity

			if !IsValid(entity) or entity:IsPlayer() then
				ply:notify("Invalid entity to save")
				return
			end

			jlib.RequestBool("Store entity in your view?", function(bool)
				if !bool then return end

				local vaultPos = entityVault.getRoomPos()

				entity:GetPhysicsObject():EnableMotion(false)
				entity:SetPos(vaultPos + Vector(15,0,150))

				ply.prevPos = ply:GetPos()

				ply:SetPos(vaultPos + Vector(100,0,5))
				ply:notify("Storing entity in vault")

				jlib.Announce(ply,
					Color(255,255,0), "[VAULT] ", Color(255,234,103), "Information:",
					Color(255,255,255), "\n· Make sure to place the entity appropriately in the vault & save it if needed!" ..
					"\n· Enter '/vault_return' to return to the world"
				)

			end, ply, "Yes", "No")
	 	end
	})

	-- Return entity to the world
	nut.command.add("vault_deploy", {
	 	adminOnly = true,
	 	syntax = "<Entity>",
		onRun = function(ply, arguments)
			local entity = ply:GetEyeTrace().Entity

			if !IsValid(entity) or entity:IsPlayer() then
				ply:notify("Invalid entity to deploy")
				return
			end

			if !ply.prevPos then
				ply:notify("No previous location to deploy to")

				jlib.Announce(ply,
					Color(255,255,0), "[VAULT] ", Color(255,234,103), "Information:",
					Color(255,255,255), "\n· If you'd like to deploy an entity, go to the location you want to bring it and enter '/vault_enter' then '/vault_deploy' on the entity"
				)

				return
			end

			jlib.RequestBool("Deploy entity in your view?", function(bool)
				if !bool then return end

				entity:GetPhysicsObject():EnableMotion(false)
				entity:SetPos(ply.prevPos + Vector(0,0,50))
				ply:SetPos(ply.prevPos + Vector(100,0,0))

				ply.prevPos = nil
				ply:notify("Deploying entity to world")
			end, ply, "Yes", "No")
		end
	})

	MsgC(Color(0,0,255), "[VAULT] ", Color(255,255,255), "Successfully initialized entity vault system\n")
end)
