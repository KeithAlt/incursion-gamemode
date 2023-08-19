
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local isarmed = 0
local caninuke = 1
local canbeeb = 1
util.PrecacheSound( "ambient/explosions/explode_3.wav" )
util.PrecacheSound( "ambient/explosions/explode_5.wav" )

function ENT:Initialize() 
self.Entity:SetModel( "models/props_c17/BriefCase001a.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )     
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   
self.Entity:SetSolid( SOLID_VPHYSICS )               
local phys = self.Entity:GetPhysicsObject()  
if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self.Entity, { "Detonate!", "Arm"}) end	
if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Armed"}) end
if (phys:IsValid()) then  		
phys:Wake()  	
end 
 
end   

function ENT:TriggerInput(iname, value) --wire inputs
	if (iname == "Detonate!") then
		if value == 1 then
		    if self.isarmed == 1 then
			    self:MakeNuke()
			end
		end
	end
	if (iname == "Arm") then
		if value == 1 then
		    self.isarmed = 1
		end
		if value == 0 then
		    self.isarmed = 0
		end
	end
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "briefcase_sent_he_missile" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:PhysicsCollide( data, physobj )
    if ( self.isarmed == 1 ) then
	    if data.Speed > 600 and data.DeltaTime > 0.15 then -- if it hits an object at over 600 speed
            self:MakeNuke()
		end
    end
end	

function ENT:OnTakeDamage(dmginfo)
self.Entity:TakePhysicsDamage( dmginfo )
end 

function ENT:Think()
	if ( self.isarmed == 1 ) then
	    self:SetOverlayText( " ARMED " )
	else
	    self:SetOverlayText( " Unarmed " )
	end
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Armed", self.isarmed) end
end

--function ENT:Kaboom()
--    if self.isarmed == 1 then
--	    if self.caninuke == 1 then
--		    self:MakeNuke()
--	        self.Entity:Remove()
--		end
--	end
--end	

function ENT:OnRemove()
	self.caninuke = 0
	if WireLib then Wire_Remove(self.Entity) end
end

function ENT:OnRestore()
    if WireLib then Wire_Restored(self.Entity) end
end

function ENT:BuildDupeInfo()
    if WireLib then return WireLib.BuildDupeInfo(self.Entity) end
	return {}
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
    if WireLib then WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID ) end
end

function ENT:PreEntityCopy()
    --build the DupeInfo table and save it as an entity mod
    local DupeInfo = self:BuildDupeInfo()
    if(DupeInfo) then
        duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
    end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
    --apply the DupeInfo
    if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
        Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end
end

function ENT:MakeNuke() --Make ze nuke!
if caninuke == 1 then
local effectdata = EffectData()
effectdata:SetStart(self.Entity:GetPos())
effectdata:SetOrigin(self.Entity:GetPos())
effectdata:SetScale(30)
util.Effect("HelicopterMegaBomb", effectdata)
util.Effect("Explosion", effectdata)
util.Effect("cball_explode", effectdata)
self.Entity:EmitSound("ambient/explosions/explode_5.wav")
util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 512, 150)
self.Entity:Remove()
end
end
function ENT:Use()
    self.isarmed = 1
end	