
AddCSLuaFile()

SWEP.PrintName				= "Ghost Injector"
SWEP.Author				= "Claymore Gaming"
SWEP.Instructions			= "Inject a victim with this to transform them into an abomination."
SWEP.Category				= "Claymore Gaming"

SWEP.Slot				= 3

SWEP.SlotPos				= 3

SWEP.AdminSpawnable                     = true
SWEP.Spawnable                     = true
SWEP.AdminOnly = true

SWEP.ViewModel			= "models/weapons/c_m9.mdl"
SWEP.WorldModel			= "models/weapons/w_m9.mdl"
SWEP.ViewModelFOV			= 63
SWEP.UseHands				= true

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "ar2"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo		= "smg154353454"

SWEP.DrawAmmo			= true

	function SWEP:PrimaryAttack()
	    if SERVER and self.Owner:IsPlayer() then
	        local ply = self.Owner:GetEyeTrace().Entity
					if ply:GetPos():Distance(self.Owner:GetPos())  > 100 then return end
					if not ply:IsPlayer() then return end

                if SERVER then
									ply:EmitSound("physics/flesh/flesh_squishy_impact_hard2.wav")
				 ply:SetColor( Color(255,143,143) )
				 timer.Simple(10, function()
         ply:setRagdolled(true, 3)
	       ply:ChatPrint("You feel strange...")
				 ply:ChatPrint("You cannot control your body...")
			 end)
				timer.Simple(25, function()
	        if ply:GetClass() == "pill_ent_phys" then
	            ply:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav")
	            ply = ply:GetPillUser()
							ply:ChatPrint("☣ You are Infected with the Ghost Pathogen ☣")
							ply:ChatPrint("- Equip the infection to begin spreading it")
							ply:ChatPrint("- Right click to transform into a Ghost")
	        elseif not ply:IsPlayer() then
	            return
	        end

	        ply:Give("weapon_infect_ghost", false)
					ply:SetColor( Color(255,255,255) )
					ply:ChatPrint("You are fully Infected")
	        self.Owner:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav")
	    end)
		end


function SWEP:SecondaryAttack()
if SERVER then
end
end
function SWEP:Reload()
end
function SWEP:Think()
if SERVER then
end
end
function SWEP:OnDrop()
self:Remove()
end
function SWEP:Deploy()
self:SendWeaponAnim(ACT_VM_DRAW)
end
function SWEP:OwnerChanged()
if SERVER then
end
end
function SWEP:Holster()
if SERVER and self:GetOwner():IsValid() and self:GetOwner():Health() > 0 then
return true end end
function SWEP:OnRemove()return true end
end
end
