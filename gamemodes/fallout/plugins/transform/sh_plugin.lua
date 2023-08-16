local PLUGIN = PLUGIN

PLUGIN.name = "Transformative Items"
PLUGIN.author = "Chancer"
PLUGIN.desc = "Items that transform you."

function PLUGIN:transformStart(client, item)
	--if(client.transforming) then return end --don't want people to stack these
	client.transforming = true

	local npc = item.npc
	local scale = item.tscale
	local duration = item.duration
	local color = item.tcolor
	local material = item.tmaterial 
	
	--so we don't accidentally break something  else
	local tempScale = client:GetModelScale()
	local tempColor = client:GetColor()
	local tempMat = client:GetMaterial()
	
	client:Freeze(true)
	client:SetModelScale(scale, duration)
	client:SetColor(color)
	client:SetMaterial(material)
	
	if(item.sound) then
		client:EmitSound(item.sound)
	end
	
	--function that's run before transformation ends
	if(item.preTransform) then
		item:preTransform(client)
	end
	
	timer.Simple(duration, function()
		if(IsValid(client)) then
			timer.Simple(1.5, function()
				if(client:Alive()) then
					client.transforming = nil
		
					client:Freeze(false)
					
					--reset
					client:SetModelScale(tempScale)
					client:SetColor(tempColor) 
					client:SetMaterial(tempMat)
				
					local entity = ents.Create(npc)
					entity:SetPos(client:GetPos())
					entity.transformedPlayer = client
					entity:Spawn()
					
					PLUGIN:npcPossess(client, entity)
					
					--function that's run right after the transformation finishes
					if(item.postTransform) then
						item:postTransform(client)
					end
				end
			end)
		end
	end)
end

function PLUGIN:transformEnd(client)	
	if(client and IsValid(client)) then
		client:Freeze(false)
		client:Kill()
		client:Spawn()
	end
end

--requires VJ base, just uses VJ base possessing thing
function PLUGIN:npcPossess(client, entity)
	local SpawnControllerObject = ents.Create("obj_vj_npccontroller")
	SpawnControllerObject.TheController = client
	SpawnControllerObject:SetControlledNPC(entity)
	SpawnControllerObject:Spawn()
	//SpawnControllerObject:Activate()
	SpawnControllerObject:StartControlling()
end

function PLUGIN:OnNPCKilled(entity, attacker, inflictor)
	local client = entity.transformedPlayer
	
	timer.Simple(0, function()
		PLUGIN:transformEnd(client)
	end)
end