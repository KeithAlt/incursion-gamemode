--TNT
--By Teta_Bonita

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

--local Model = "models/weapons/w_c4_planted.mdl" --Alternate model
local Model = "models/dav0r/tnt/tnt.mdl"


function ENT:SpawnFunction(ply, tr)

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal*16
	local ent = ents.Create("sent_tnt")
	ent:SetPos(SpawnPos)
	ent:SetVar("Owner",ply)
	ent:Spawn()
	ent:Activate()
	return ent

end



function ENT:Initialize()

	self.Entity:SetModel(Model)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Position = Vector()
	self.Activated = false
	self.Exploding = false
	self.IsTNT = true
	self.Integrity = 20
	
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self.Entity, {"Detonate!"}) end


end

function ENT:ChainReaction(lastpower)

if not self.Exploding then return end

local BoomPower = 1

	for key,found in pairs(ents.FindInSphere(self.Position,200*(lastpower^0.74))) do
		if found:GetVar("IsTNT",false) and found ~= self.Entity then
			found:SetVar("Activated",true)
			found:SetVar("Exploding",false)
			found:Remove()
			BoomPower = BoomPower + 1
		end
	end

	if BoomPower <= lastpower then
		self:Detonate(BoomPower)
	else
		self:ChainReaction(BoomPower)
	end
	
end

function ENT:Detonate(power)

	if not self.Exploding or not self.Entity then return end

	local Boom = ents.Create("sent_explosion_scaleable")
	Boom:SetPos(self.Position)
	Boom:SetVar("Owner",self.Owner)
	Boom:SetVar("Scale",power)
	Boom:SetAngles(self.Entity:GetAngles())
	Boom:Spawn()
	
	self.Entity:Remove()


end


function ENT:PhysicsCollide(data, physobj)


end


function ENT:OnTakeDamage(dmginfo)

if self.Activated then return end

	self.Integrity = self.Integrity - dmginfo:GetDamage()
		if self.Integrity <= 0 then
			self.Activated = true
			self.Exploding = true
			self.Owner = dmginfo:GetAttacker()
			self.Position = self.Entity:GetPos()
			self:ChainReaction(1)
		end

	self.Entity:TakePhysicsDamage(dmginfo)
	
end

function ENT:TriggerInput(iname, value)
	if (iname == "Detonate!") then
		if value == 1 then
			if self.Activated then return end
			self.Activated = true
			self.Exploding = true
			self.Position = self.Entity:GetPos()
			self:ChainReaction(1)
		end
	end
end

function ENT:Use(activator, caller)

end

function ENT:Think()

end

function ENT:OnRemove()
    if WireLib then Wire_Remove(self.Entity) end
end

function ENT:OnRestore()
    if WireLib then Wire_Restored(self.Entity) end
end

function ENT:BuildDupeInfo()
    if WireLib then
		return WireLib.BuildDupeInfo(self.Entity)
	end
	return {}
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
    if WireLib then WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID ) end
end

function ENT:PreEntityCopy()
    //build the DupeInfo table and save it as an entity mod
    local DupeInfo = self:BuildDupeInfo()
    if(DupeInfo) then
        duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
    end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
    //apply the DupeInfo
    if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
        Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end
end




