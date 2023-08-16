ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Tier 3 Crate"
ENT.Category		= "Melee Arts 2"

ENT.Spawnable		= false
ENT.AdminOnly = false
ENT.DoNotDuplicate = true

MA2loot3 = { "meleearts_gun","meleearts_bludgeon_sledgehammer","meleearts_axe_battleaxe","meleearts_blade_katana","meleearts_spear_trident" }
if SERVER then

	AddCSLuaFile("shared.lua")

	function ENT:Initialize()

		self.Entity:SetModel("models/models/danguyen/hard case c.mdl")
		self.Entity:SetColor(Color(255,255,255,255))
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		--self.Entity:SetModelScale(1.2)
		--self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self.Entity:SetSkin(2)
		self.Entity:SetNWBool("open",false)
		self.Entity:SetNWBool("grab",false)
		self.Entity:SetNWBool("empty",false)
		self.Entity:SetNWString("meleeloot",table.Random( MA2loot3 ))
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		self:Think()
	end
	 function ENT:Think()
		return true
	end
	function ENT:Use(activator, caller)
		if (activator:IsPlayer()) then
			if self.Entity:GetNWBool("open")==false then
				print(self.Entity:GetNWString( "meleeloot" ))
				self.Entity:SetBodygroup(1,1)
				self.Entity:EmitSound("items/ammocrate_open.wav")
				self.Entity:SetNWBool("open",true)
				timer.Simple(1, function()
					if IsValid(self.Entity) then
						self.Entity:SetNWBool("grab",true)
					end
				end)
			elseif self.Entity:GetNWBool("grab")==true and self.Entity:GetNWBool("empty")==false then
				activator:Give(self.Entity:GetNWString( "meleeloot" ))
				self.Entity:SetNWBool("empty",true)
				activator:EmitSound("items/itempickup.wav")
			end
		end
	end

end

if CLIENT then
	function ENT:Initialize()
	timer.Simple(0.2, function()
		if self.Entity:GetNWString( "meleeloot" )=="meleearts_gun" then
			self.xmodel = ClientsideModel("models/models/danguyen/handgun.mdl")
			self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 6 ))
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Right(), 0)
			ang:RotateAroundAxis(ang:Up(), 90)
			ang:RotateAroundAxis(ang:Forward(), 90)
			self.xmodel:SetParent( self )
			self.xmodel:SetAngles( ang )
			self.xmodel:SetModelScale( 1,0 )
		end
		if self.Entity:GetNWString( "meleeloot" )=="meleearts_bludgeon_sledgehammer" then
			self.xmodel = ClientsideModel("models/models/danguyen/w_me_sledge.mdl")
			self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 6 ))
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Right(), 0)
			ang:RotateAroundAxis(ang:Up(), 0)
			ang:RotateAroundAxis(ang:Forward(), 90)
			self.xmodel:SetParent( self )
			self.xmodel:SetAngles( ang )
			self.xmodel:SetModelScale( 0.9,0 )
		end
		if self.Entity:GetNWString( "meleeloot" )=="meleearts_axe_battleaxe" then
			self.xmodel = ClientsideModel("models/models/danguyen/grognakaxe.mdl")
			self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 6 ))
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), 0)
			ang:RotateAroundAxis(ang:Forward(), 90)
			self.xmodel:SetParent( self )
			self.xmodel:SetAngles( ang )
			self.xmodel:SetModelScale( 0.5,0 )
		end
		if self.Entity:GetNWString( "meleeloot" )=="meleearts_blade_katana" then
			self.xmodel = ClientsideModel("models/models/danguyen/hattori.mdl")
			self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 6 ))
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), 0)
			ang:RotateAroundAxis(ang:Forward(), 90)
			self.xmodel:SetParent( self )
			self.xmodel:SetAngles( ang )
			self.xmodel:SetModelScale( 0.65,0 )
		end
		if self.Entity:GetNWString( "meleeloot" )=="meleearts_spear_trident" then
			self.xmodel = ClientsideModel("models/models/danguyen/channeler's_trident.mdl")
			self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 6 ))
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Right(), 0)
			ang:RotateAroundAxis(ang:Up(), 170)
			ang:RotateAroundAxis(ang:Forward(), 0)
			self.xmodel:SetParent( self )
			self.xmodel:SetAngles( ang )
			self.xmodel:SetModelScale( 0.25,0 )
		end
	end)
	end
	function ENT:Think()
		if self.Entity:GetNWBool("empty")==true then
			self.xmodel:Remove()
		end
	end
	
	function ENT:OnRemove()
		self.xmodel:Remove()
	end
end

print("lootbox works")