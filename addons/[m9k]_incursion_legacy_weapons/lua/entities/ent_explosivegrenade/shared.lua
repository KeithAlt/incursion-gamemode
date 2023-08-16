ENT.Type = "anim"
ENT.PrintName		= "EXPLOSIVE GRENADE"
ENT.Author			= "WORSHIPPER"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

/*---------------------------------------------------------
OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()
end

/*---------------------------------------------------------
PhysicsUpdate
---------------------------------------------------------*/
function ENT:PhysicsUpdate()
end

/*---------------------------------------------------------
PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data,phys)
	if data.Speed > 150 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end

	local impulse = -data.Speed * data.HitNormal * .2 + (data.OurOldVelocity * - 1)
	phys:ApplyForceCenter(impulse)
end
