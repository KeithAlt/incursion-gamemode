if SERVER then
  AddCSLuaFile( "shared.lua" )
end



if (CLIENT) then
SWEP.PrintName = "Old Glory Banner"
SWEP.Category = "Claymore Gaming"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Claymore Gaming"
end

SWEP.HoldType			= "slam"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay = 1.1
SWEP.Primary.Ammo       = "none"

SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/props_lab/huladoll.mdl"
SWEP.ViewModel = ""
SWEP.BuffExpireTime = 120 // In seconds


function SWEP:Deploy()
	if SERVER then
		if IsValid(self.ent) then return end
		self:SetNoDraw(true)
		self.ent = ents.Create("prop_physics")
			self.ent:SetModel("models/Halokiller38/fallout/weapons/Melee/eagleflagpoll.mdl")
			self.ent:SetModelScale(self.ent:GetModelScale() * 1.25, 1)
			self.ent:SetPos(self.Owner:GetPos() + Vector(1,0,25) + (self.Owner:GetForward()*17))
			self.ent:SetAngles(Angle(0,self.Owner:EyeAngles().y,self.Owner:EyeAngles().r))
			self.ent:SetParent(self.Owner)
			self.ent:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
			self.ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
			self.ent:Spawn()
			self.ent:Activate()
	end
	return true
end

function SWEP:PrimaryAttack()
	if self.PrimaryCooldown and (CurTime() < self.PrimaryCooldown) then return end
	self:EmitSound("old_glory/old_glory_sfx_" .. math.random(1,3) .. ".ogg", 100)
	self.PrimaryCooldown = CurTime() + 13
end

function SWEP:SecondaryAttack()
	if SERVER then
		if self.SecondaryCooldown and (CurTime() < self.SecondaryCooldown) then

			if self.SecondaryNotifCooldown and (CurTime() > self.SecondaryNotifCooldown) and IsValid(self.Owner) then
				self.Owner:falloutNotify("☒ Your call to arms is on cooldown [" .. math.Round(self.SecondaryCooldown - CurTime()) .. "]", "ui/notify.mp3")
				self.SecondaryNotifCooldown = CurTime() + 2
			end

			self.SecondaryNotifCooldown = self.SecondaryNotifCooldown or CurTime()
			return
		end

		self.SecondaryCooldown = CurTime() + 30
		local ply = self.Owner

		if SERVER then
			ply:EmitSound("old_glory/old_glory_" .. math.random(1,3) .. ".ogg", 150)
		end

		for index, nearPly in pairs(ents.FindInSphere(ply:GetPos(), 800)) do
			if nearPly:IsPlayer() and nearPly:Alive() and !nearPly:GetNoDraw() and !nearPly.BannerBuffActive then

				local buffStats = {"S", "P", "E", "A"}
				local buff = buffStats[math.random(1,4)]

				if buff == "A" then
					nearPly:AddSpeed(15, self.BuffExpireTime)
				else
					nearPly:BuffStat(buff, 5, self.BuffExpireTime)
					nearPly:AddDR(5, self.BuffExpireTime)
				end

				nearPly:falloutNotify("➲ You've received a +5 " .. buff .. " & DR buff", "shelter/sfx/collect_stimpack.ogg")
				nearPly:ScreenFade(SCREENFADE.IN, Color(255,0,0, 50), 0.3, 0)
				nearPly.BannerBuffActive = true

				local target = nearPly

				timer.Simple(0, function()
					ParticleEffectAttach("mr_magicball_01a", PATTACH_POINT_FOLLOW, nearPly, 0)
				end)

				timer.Simple(5, function()
					if IsValid(target) then
						target:StopParticles()
					end
				end)

				timer.Simple(self.BuffExpireTime, function()
					if IsValid(target) and target.BannerBuffActive then
						target.BannerBuffActive = nil
					end
				end)

			end
		end
	end
end

function SWEP:Holster()
	if SERVER then
		if not IsValid(self.ent) then return end
		self.ent:Remove()
	end
	return true
end

function SWEP:OnDrop()
	if SERVER then
		self:SetColor(Color(255,255,255,255))
		if not IsValid(self.ent) then return end
		self.ent:Remove()
	end
end

function SWEP:OnRemove()
	if SERVER then
		self:SetColor(Color(255,255,255,255))
		if not IsValid(self.ent) then return end
		self.ent:Remove()
	end
end
