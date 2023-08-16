local FLASH_INTENSITY = 2250; --the higher the number, the longer the flash will be whitening your screen

AddCSLuaFile("shared.lua")
include("shared.lua")

local function simplifyangle(angle)
	while(angle>=180) do
		angle = angle - 360;
	end
	while(angle <= -180) do
		angle = angle + 360;
	end
	return angle;
end

function ENT:Explode()
	self.Entity:EmitSound(Sound("weapons/flashbang/flashbang_explode"..math.random(1,2)..".wav"));
	for _,pl in pairs(player.GetAll()) do
		if pl:IsPlayer() then
			local ang = (self.Entity:GetPos() - pl:GetShootPos()):GetNormalized():Angle()
			local tracedata = {};
			tracedata.start = pl:GetShootPos();
			tracedata.endpos = self.Entity:GetPos();
			tracedata.filter = pl;
			local traceRes = pl:GetEyeTrace()
			local tr = util.TraceLine(tracedata);

			local pitch = simplifyangle(ang.p - pl:EyeAngles().p);
			local yaw = simplifyangle(ang.y - pl:EyeAngles().y);
			local dist = pl:GetShootPos():Distance( self.Entity:GetPos() )
			local endtime = FLASH_INTENSITY/dist;

			if traceRes.HitWorld and !tr.HitWorld then
				local endtime = FLASH_INTENSITY/dist;
				if (endtime > 6) then
					endtime = 6;
				elseif(endtime < 0.4) then
					endtime = 0.4;
				end
				simpendtime = math.floor(endtime);
				tenthendtime = math.floor((endtime-simpendtime)*10);
				if (  pitch > -45 && pitch < 45 && yaw > -45 && yaw < 45 ) || (pl:GetEyeTrace().Entity && pl:GetEyeTrace().Entity == self.Entity )then --in FOV
					//pl:PrintMessage(HUD_PRINTTALK, "In FOV");
				else
					//pl:PrintMessage(HUD_PRINTTALK, "Not in FOV");
					endtime = endtime/2;
				end
				if (pl:GetNetworkedFloat("RCS_flashed_time") > CurTime()) then --if you're already flashed
					pl:SetNetworkedFloat("RCS_flashed_time", endtime+pl:GetNetworkedFloat("RCS_flashed_time")+CurTime()-pl:GetNetworkedFloat("RCS_flashed_time_start")); --add more to it
				else --not flashed
					pl:SetNetworkedFloat("RCS_flashed_time", endtime+CurTime());
				end
				pl:SetNetworkedFloat("RCS_flashed_time_start", CurTime());
			end
		end
	end
	for _, npcs in pairs( ents.GetAll() ) do
		if ( npcs:IsNPC() and npcs:IsValid() ) then
			if (self.Entity:GetPos():Distance(npcs:GetPos()) <= 500) then
				timer.Simple(0.01, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.05, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.7, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.8, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(0.9, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.7, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.8, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(1.9, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.7, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.8, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(2.9, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.7, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.8, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(3.9, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.7, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.8, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(4.9, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.3, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.4, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.5, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.7, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.8, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(5.9, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(6, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(6.1, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
				timer.Simple(6.2, function()
					if npcs:IsValid() then
						npcs:SetEnemy( npcs, true )
						npcs:SetTarget( npcs )
					end
				end)
			end
		end
	end
	self.Entity:Remove();
end

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	timer.Simple(2,
	function()
		if self.Entity then self:Explode() end
	end )
end

function ENT:Think()
end

function ENT:SetDetonateTimer(length)
   self:SetDetonateExact( CurTime() + length )
end

function ENT:SetDetonateExact()
end

function ENT:OnTakeDamage()
	self:Explode()
end

function ENT:SetThrower()
end

function ENT:Use()
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch()
end