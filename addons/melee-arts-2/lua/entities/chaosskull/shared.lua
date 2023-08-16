ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Chaos Skull"
ENT.Category		= "Melee Arts 2"

ENT.Spawnable		= true
ENT.AdminOnly = false
ENT.DoNotDuplicate = true

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:Initialize()

	local model = ("models/props_c17/FurnitureDrawer003a.mdl")
	
	self.Entity:SetModel(model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Entity:SetMaterial("models/props_wasteland/quarryobjects01")
	self.Entity:SetModelScale(1)
	self.Entity:SetColor(Color(255,230,230))
	self.Entity:SetNoDraw(false)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	
	sound.Add( {
		name = "spookyshit",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = { 95, 110 },
		sound = "ambient/levels/citadel/citadel_ambient_voices1.wav"
	} )
	
	sound.Add( {
		name = "rumble",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = { 95, 110 },
		sound = "ambient/atmosphere/city_rumble_loop1.wav"
	} )
	
	sound.Add( {
		name = "spook",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = 30,
		sound = "ambient/atmosphere/city_rumble_loop1.wav"
	} )
	
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		self.Entity:SetPos(self:GetPos()+ Vector(0,0,25))
		phys:Wake()
		phys:SetMass(10000000)
	end
	self.Entity:SetUseType(SIMPLE_USE)
  self:Think()
end


function ENT:Think()
	if self.Entity:GetNWBool("MASmoke")==true then
		local effectdata = EffectData() 
		effectdata:SetOrigin( self:GetPos() + Vector( 0, 0, 27 ) ) 
		effectdata:SetNormal( self:GetPos():GetNormal() ) 
		effectdata:SetEntity( self ) 
		util.Effect( "darkenergyshit", effectdata )
	end
	if self.Entity:GetNWBool("MASmoke2")==true then
		util.ScreenShake( self:GetPos(), 5, 5, 1, 500 )
		local effectdata = EffectData() 
		effectdata:SetOrigin( self:GetPos() + Vector( 0, 0, 27 ) ) 
		effectdata:SetNormal( self:GetPos():GetNormal() ) 
		effectdata:SetEntity( self ) 
		util.Effect( "darkenergyglow", effectdata )
	end
	if self.Entity:GetNWBool("MASmoke3")==true then
		local effectdata = EffectData() 
		effectdata:SetOrigin( self:GetPos() + Vector( 0, 0, 27 ) ) 
		effectdata:SetNormal( self:GetPos():GetNormal() ) 
		effectdata:SetEntity( self ) 
		util.Effect( "darkenergybigaura", effectdata )
	end
end


function ENT:Use(activator, caller)

	
	if (activator:IsPlayer()) and self.Entity:GetNWBool("debounce")==false then
		self.Entity:SetNWBool("debounce",true)
		self:Explode()
		end
	end
end

function ENT:Explode()
	local position = self:GetPos()
	local normal = position:GetNormal()
	self.Entity:EmitSound("npc/combine_gunship/ping_search.wav", 90)
	--self.Entity:EmitSound("ambient/atmosphere/terrain_rumble1.wav", 90)
	self.Entity:EmitSound("spookyshit")
	self.Entity:SetNWBool("MASmoke",true)
	timer.Simple( 4,function()
		if IsValid(self.Entity) then
			self.Entity:EmitSound("rumble")
			self.Entity:SetNWBool("MASmoke2",true)
			timer.Simple( 3,function()
				if IsValid(self.Entity) then
				self.Entity:SetNWBool("MASmoke3",true)
					timer.Simple( 4,function()
						if IsValid(self.Entity) then
							self.Entity:StopSound( "spookyshit" )
							self.Entity:StopSound( "rumble" )
							self.Entity:SetNWBool("MASmoke",false)
							self.Entity:SetNWBool("MASmoke2",false)
							self.Entity:SetNWBool("MASmoke3",false)
							self.Entity:SetNWBool("debounce",false)
							
							local ent = ents.Create("npc_combine_s")
							ent:SetPos(position + Vector( 0, 0, 0 ) )
							ent:Spawn()
							ent:SetNPCState(NPC_STATE_ALERT)
							ent:SetHealth(500)
							ent:Give("npc_cultblade")
							ent:EmitSound("npc/combine_gunship/ping_patrol.wav")
							ent:EmitSound("ambient/atmosphere/city_skybeam1.wav", 90)
							ent:EmitSound("ambient/levels/citadel/strange_talk1.wav", 90)
							ent:EmitSound("spook")
							ent:SetModel("models/models/danguyen/samuraiwarrior.mdl")
							ent:SetColor( Color( 0, 0, 0, 255 ) )
							ent:SetBodygroup(1,3)
							ent:SetNWBool("MABoss",true)
							--ent:SetMaterial("models/props_wasteland/tugboat01")
							self.Entity:Remove()
						end
					end)
				end
			end)
		end
	end)
end

if CLIENT then
	function ENT:Initialize()
		self.xmodel = ClientsideModel("models/Gibs/HGIBS.mdl")
		self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 25 ))
		self.xmodel:SetColor(Color(204,146,146))
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Right(), 0)
		ang:RotateAroundAxis(ang:Up(), 0)
		ang:RotateAroundAxis(ang:Forward(), 0)
		self.xmodel:SetParent( self )
		self.xmodel:SetAngles( ang )
		self.xmodel:SetModelScale( 1,0 )
	end

	function ENT:OnRemove()
		self.xmodel:Remove()
	end
end