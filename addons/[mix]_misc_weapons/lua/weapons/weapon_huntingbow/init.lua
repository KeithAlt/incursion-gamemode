AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

function SWEP:OnRemove()

end

function SWEP:Equip(new_owner)

end

function SWEP:EquipAmmo(new_owner)

end

function SWEP:OnDrop()

end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:GetCapabilities()
	return CAP_WEAPON_RANGE_ATTACK1
end

function SWEP:NPCShoot_Secondary(shoot_pos, shoot_dir)
	self:SecondaryAttack()
end

function SWEP:NPCShoot_Primary(shoot_pos, shoot_dir)
	self:PrimaryAttack()
end