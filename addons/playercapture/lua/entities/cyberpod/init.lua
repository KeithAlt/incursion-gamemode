AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
  
    self:SetModel("models/cyberpod/cyberpod.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if(phys:IsValid()) then
    	
    	phys:Wake()
     
   end
   

end

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 
	local object = ents.Create("prop_physics") 
    object:SetModel("models/cyberpod/cyberpod.mdl") 
    object:SetPos(tr.HitPos)  
    object:Spawn()
    object:Activate()
    object:SetMoveType(MOVETYPE_VPHYSICS)
	object:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local hidden = ents.Create("prop_vehicle_prisoner_pod") 
    hidden:SetModel("models/vehicles/prisoner_pod_inner.mdl") 
    hidden:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
    hidden:SetPos(object:GetPos()+Vector(4,0,8)) 
    hidden:Spawn()
    hidden:Activate()
	hidden:SetParent(object)
    hidden:SetCollisionGroup(COLLISION_GROUP_NONE)
	hidden:SetNoDraw(true)
	return object
end