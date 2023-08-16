if SERVER then
	resource.AddFile("sound/400hz.wav")
end
AddCSLuaFile()

SWEP.PrintName = "Medkit"
SWEP.Author = "jonjo"
SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.Instructions = "Primary Fire: Heal target\nSecondary Fire: Heal yourself"

SWEP.Spawnable = true
SWEP.Category = "Claymore Gaming"

SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.UseHands = true

SWEP.Primary.Delay = 0.5
SWEP.Secondary.Delay = 0.9

SWEP.Primary.Automatic  = true
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

SWEP.Range = 50
SWEP.RangeSquared = SWEP.Range ^ 2

SWEP.BarWidth = 400
SWEP.BarHeight = 40

function SWEP:Initialize()
    self.Sound = CreateSound(self, "400hz.wav")
end

function SWEP:GetHealRate()
	return (self:GetOwner():getSpecial("I") / 10) + 1
end

function SWEP:Deploy()
	if SERVER then
		self:GetOwner():ChatPrint("[INFO] Your intelligence gives you a +" .. self:GetHealRate() .. " HP increased heal rate.")
		self:GetOwner():ChatPrint("Recently damaged targets receive less healing.")
	end
end

function SWEP:Think()
	if IsValid(self.Target) and !self:IsHealingAny() then
		if self.Sound and self.Sound:IsPlaying() then
			self.Sound:FadeOut(0.1)
		end

		self.Target = nil
	end
end

function SWEP:Heal(ply)
	if IsValid(ply) and ply:IsPlayer() and ply:Health() < ply:GetMaxHealth() and ply:GetPos():DistToSqr(self:GetOwner():GetPos()) < self.RangeSquared then
		self.Target = ply
		
		local healing = self:GetHealRate() --base heal rate

		--modifies heal rate
		if(ply.lastDamageTaken and (ply.lastDamageTaken + 10) > CurTime()) then
			healing = healing * 0.50 --reduce to 25%
		end
		
		ply:SetHealth(ply:Health() + healing)

		self:HealSound(ply)
    end
end

function SWEP:HealSound(ply)
	if !self.Sound then
		self.Sound = CreateSound(self, "400hz.wav")
	end

	local pitchPercent = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)

	if !self.Sound:IsPlaying() then
		self.Sound:Play()
	end

	self.Sound:ChangePitch(65 * pitchPercent)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self:GetOwner():LagCompensation(true)
	local ent = self:GetOwner():GetEyeTrace().Entity
    self:GetOwner():LagCompensation(false)

	self:Heal(ent)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    self:Heal(self:GetOwner())
end

function SWEP:DrawHUD()
	if IsValid(self.Target) then
		local progress = self.Target:Health() / self.Target:GetMaxHealth()
		jlib.DrawProgressBar((ScrW() / 2) - (self.BarWidth / 2), ScrH() - 100, self.BarWidth, self.BarHeight, progress, "Healing", true, Color(20, 255, 20, 255))
	end
end

function SWEP:IsHealingAny()
	return IsValid(self.Target) and self.Target:Health() < self.Target:GetMaxHealth() and (self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():KeyDown(IN_ATTACK2)) and (self:GetOwner() == self.Target or (self:GetOwner():GetEyeTrace().Entity == self.Target and self.Target:GetPos():DistToSqr(self:GetOwner():GetPos()) < self.RangeSquared))
end

function SWEP:IsHealingOther()
	return self:GetHealingAny() and self.Target != self:GetOwner()
end

function SWEP:IsHealingSelf()
	return self:GetHealingAny() and self.Target == self:GetOwner()
end

--when a player takes damage, mark the player so that the swep can tell they have taken damage recently
hook.Add("EntityTakeDamage", "hotmedkitHealingReduction", function(target, dmg)
	if(IsValid(target) and target:IsPlayer()) then
		target.lastDamageTaken = CurTime() --variable that reepresents when the player last took damage.
	end
end)