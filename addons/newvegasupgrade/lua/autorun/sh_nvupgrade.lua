if game.GetMap() != "rp_newvegas_urfim" then return end

if SERVER then

	local function fixPillTeleport() -- Fixes trigger_teleport triggers on physics type pills
		MapLua = ents.Create( "lua_run" )
		MapLua:SetName( "triggerhook" )
		MapLua:Spawn()

		for k, v in pairs( ents.FindByClass( "trigger_teleport" ) ) do
			v:Fire( "AddOutput", "OnStartTouch triggerhook:RunPassedCode:hook.Run( 'OnTeleport' ):0:-1" )
		end
	end

	hook.Add( "InitPostEntity", "pill_tp_fix", fixPillTeleport )
	hook.Add( "PostCleanupMap", "pill_tp_fix", fixPillTeleport )
	hook.Add( "OnTeleport", "NV_Teleport_Fix", function()
		local activator = ACTIVATOR

		if pk_pills and IsValid(pk_pills.getMappedEnt(activator)) and (!activator.tp_coolDown or activator.tp_coolDown < CurTime()) then
			activator.tp_coolDown = CurTime() + 3

			for i = 1, 5 do -- I tried a fuckton of alternatives, if you got a better idea: DO IT
				timer.Simple(0.01*i, function()
					pk_pills.getMappedEnt(activator):SetPos(activator:GetPos())
				end)
			end
		end
	end)

	--[[
		Missing gates fix
	]]
	local doorTable = {
		["*39"]  = Angle(0, 180, 0),
		["*40"]  = Angle(0, 0, 0),
		["*353"] = Angle(0, 180, 0),
		["*354"] = Angle(0, 0, 0),
		["*380"] = Angle(0, 90, 0),
		["*381"] = Angle(0, -90, 0),
		["*384"] = Angle(0, -90, 0),
		["*385"] = Angle(0, 90, 0)
	}

	local function doorfix()
		for i, v in ipairs(ents.FindByClass("func_door_rotating")) do
			if !v:GetModel() then continue end
			if !doorTable[v:GetModel()] then continue end
    		local doorModel = ents.Create("prop_physics")
			doorModel:SetModel("models/optinvfallout/fence22gate.mdl")
			doorModel:SetPos(Vector(0, 0, -70))
			doorModel:SetAngles(doorTable[v:GetModel()])
    		doorModel:SetMoveParent(v)
    		doorModel:Spawn()
		end
	end

	hook.Add("InitPostEntity", "spawndoors", doorfix)
	hook.Add("PostCleanupMap", "spawndoors", doorfix)

	--[[
		Vault door fix
	]]
	local cachedDoor = NULL
	local openDuration = 0
	local closeDuration = 0

	local function GetVaultDoor()
		if !IsValid(cachedDoor) then
			-- The vault door entity is the only entity with this model and class
			for i, ent in ipairs(ents.FindByModel("models/fallout/dungeons/vault/roomu/vgeardoor01.mdl")) do
				if ent:GetClass() == "prop_dynamic" then
					cachedDoor = ent
					openDuration = ent:SequenceDuration(ent:LookupSequence("open"))
					closeDuration = ent:SequenceDuration(ent:LookupSequence("close"))
					break
				end
			end
		end

		return cachedDoor
	end

	hook.Add("AcceptInput", "VaultPanelFix", function(ent, name, activator, caller, data)
		-- *176 and *177 is the models for the two panels used to activate the door
    	if IsValid(activator) and activator:IsPlayer() and (ent:GetModel() == "*176" or ent:GetModel() == "*177") then
			local vaultDoor = GetVaultDoor()

			local time = CurTime()
			if (vaultDoor.LastOpen and time - vaultDoor.LastOpen < openDuration) or (vaultDoor.LastClose and time - vaultDoor.LastClose < closeDuration) then return end

        	ent:EmitSound("buttons/button1.wav")

			if !vaultDoor.IsOpen then
				vaultDoor:Fire("FireUser1")
				vaultDoor.IsOpen = true
				vaultDoor.LastOpen = CurTime()
			else
				vaultDoor:Fire("FireUser2")
				vaultDoor.IsOpen = false
				vaultDoor.LastClose = CurTime()
			end
    	end
	end)

	--[[
		Strip visual upgrades
	]]
	local modelReplacements = {
		["models/thespireroleplay/casinos/nv_thetops_part1.mdl"] = {
			mdl = "models/fallout/architecture/strip/the_tops_main_neon.mdl",
			pos = {
				Up = 180,
				Forward = 90
			},
			scale  = 1.05,
			extras = {
				{
					mdl = "models/fallout/architecture/strip/tops_door1.mdl",
					pos = Vector(7029, -2800, 8950),
					ang = Angle(0, -90, 0),
					scale = 1.055
				},
				{
					mdl = "models/fallout/architecture/strip/tops_door1.mdl",
					pos = Vector(7020, -2800, 8950),
					ang = Angle(0, 90, 0),
					scale = 1.055
				}
			}
		},
		["models/thespireroleplay/casinos/nv_garmorrah.mdl"] = {
			mdl = "models/fallout/architecture/strip/gammorah_build.mdl",
			scale = 32/30 -- 1.0666...
		}
	}

	local modelRemovals = {
		"*409", -- The orange quads behind the Gomorrah signs
		"*435", -- The white lines around the tops
		"*436" -- The white lines around the tops
	}

	local function MapUpgrade()
		for old, new in pairs(modelReplacements) do
			for i, ent in ipairs(ents.FindByModel(old)) do
				ent:SetModel(new.mdl)
				ent:SetModelScale(new.scale or 1)

				if new.pos then
					for dir, amt in pairs(new.pos) do
						local getFunc = ent["Get" .. dir]
						if !getFunc then return end

						ent:SetPos(ent:GetPos() + (getFunc(ent) * amt))
					end
				end

				if new.extras then
					for _, extra in ipairs(new.extras) do
						local newEnt = ents.Create("prop_physics")
						newEnt:SetModel(extra.mdl)
						newEnt:SetPos(extra.pos or ent:GetPos())
						newEnt:SetAngles(extra.ang or ent:GetAngles())
						newEnt:SetModelScale(extra.scale or new.scale)
						newEnt:Spawn()

						local physObj = newEnt:GetPhysicsObject()
						if IsValid(physObj) then
							physObj:EnableMotion(false)
						end
					end
				end
			end
		end

		for i, mdl in ipairs(modelRemovals) do
			for _, ent in ipairs(ents.FindByModel(mdl)) do
				ent:Remove()
			end
		end
	end

	hook.Add("InitPostEntity", "NewvegasModelUpgrade", MapUpgrade)
	hook.Add("PostCleanupMap", "NewvegasModelUpgrade", MapUpgrade)
end

if CLIENT then
	local renderDist = 5500
	local renderDistSqr = renderDist ^ 2

	local quadReplacements = {
		{ -- Replacing the now missing quad behind one of the Gomorrah signs
			Vector(1362, -3448, 9690),
			Vector(1007, -3039, 9690),
			Vector(1007, -3039, 9580),
			Vector(1362, -3448, 9580),
			Color(255, 75, 0, 255)
		}
	}

	hook.Add("PostDrawOpaqueRenderables", "NewvegasQuadReplacements", function()
		render.SetColorMaterial()
		for i, quad in ipairs(quadReplacements) do
			if LocalPlayer():GetPos():DistToSqr(quad[1]) < renderDistSqr then
				render.DrawQuad(unpack(quad))
			end
		end
	end)
end
