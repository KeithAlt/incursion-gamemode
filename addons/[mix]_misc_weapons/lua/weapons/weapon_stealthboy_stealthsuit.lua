AddCSLuaFile()

hook.Add("PlayerFootstep", "Stealth_Boy_Active", function( ply) -- This hook applies to all stealth boys
	if ply:GetNWBool("StealthCamo") == true && (!ply.activePFX or CurTime() > ply.activePFX) && ply:KeyDown(IN_SPEED) then
		ParticleEffectAttach( "mr_electric_1", PATTACH_POINT_FOLLOW, ply, 5 )
		ply:EmitSound("weapons/physcannon/superphys_small_zap" .. math.random(4) .. ".wav", 32)
		ply.activePFX = CurTime() + 5

		timer.Simple(1, function()
			if IsValid(ply) then
				ply:StopParticles()
			end
		end)
	end
end)

SWEP.PrintName = "Stealth Boy (Stealth Suit)"
SWEP.Instructions = "Primary attack: toggle camo"
SWEP.WorldModel = ""
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.UseHands = false
SWEP.Category = "Claymore Gaming"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 60
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true

if CLIENT then
	matproxy.Add{
		name = "PlayerCloak",
		init = function() end,
		bind = function(self, mat, ent)
			if not IsValid(ent) or not ent.CloakFactor then return end
			mat:SetFloat("$cloakfactor", ent.CloakFactor)
		end
	}
end

function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
	hook.Add("PreDrawPlayerHands", self, self.PreDrawPlayerHands)
	hook.Add("PostDrawPlayerHands", self, self.PostDrawPlayerHands)
end

function SWEP:IsCloaked()
	return self.Owner:GetNWBool("StealthCamo", false)
end

function SWEP:Cloak(pl)
	ParticleEffectAttach("mr_cop_anomaly_electra_a", 1, self, 1)
	self:EmitSound("fallout/obj_stealthboy_activate_01.wav")
	self.Owner:SetNWBool("StealthCamo", true)
	self.Owner:DrawShadow(false)

	if SERVER then
		self.Owner:SetNoTarget(true)
	end

	timer.Simple(0.2, function()
		if not IsValid(self) or not IsValid(self.Owner) then return end
		self:StopParticles()
		self.Owner:SetNoDraw(true)
	end)

	if CLIENT and not self.Deployed then
		chat.AddText(Color(255, 0, 0), "[ ! ]  ", Color(255, 255, 255), "If someone is able to see your ", Color(255, 100, 100), "Character Description ", Color(255, 255, 255), "then they are close enough to touch you! This is ", Color(255, 100, 100), "NOT ", Color(255, 255, 255), "Meta-Game!")
	end

	self.Deployed = true
end

function SWEP:Uncloak(pl)
	ParticleEffectAttach("mr_fx_beamelectric_arcc1", 1, self, 1)
	self:EmitSound("fallout/obj_stealthboy_activate_02.wav")
	self.Owner:SetNWBool("StealthCamo", false)
	self.Owner:DrawShadow(true)

	if SERVER then
		self.Owner:SetNoTarget(false)
	end

	ParticleEffectAttach("mr_fx_beamelectric_arcc1", 1, self, 1)

	timer.Simple(0.2, function()
		if not IsValid(self) or not IsValid(self.Owner) then return end
		self:StopParticles()
		self.Owner:SetNoDraw(false)
	end)
end

hook.Add("OnPlayerChangedTeam", "PURGE::UNCLOAK", function(_p)
	if (_p:GetNWBool("StealthCamo", true)) then
		_p:SetNWBool("StealthCamo", false)
		_p:SetNoDraw(false)
	end
end)

hook.Add("PlayerDeath", "PURGE::UNCLOAK", function(_p)
	if (_p:GetNWBool("StealthCamo", true)) then
		_p:SetNWBool("StealthCamo", false)
		_p:SetNoDraw(false)

		if SERVER then
			_p:SetNoTarget(false)
		end
	end
end)

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)

	if self:IsCloaked() and self:Clip1() > 0 then
		self:Uncloak()
	else
		self:Cloak()
	end

	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if self.NextTick and self.NextTick > CurTime() then return end

	if SERVER then
		if self:IsCloaked() then
			self:SetClip1(math.Clamp(self:Clip1() - 1, 0, self:GetMaxClip1()))
		else
			self:SetClip1(math.Clamp(self:Clip1() + 1, 0, self:GetMaxClip1()))
		end
	end

	if self:IsCloaked() and self:Clip1() <= 0 then
		self:Uncloak()
	end

	self.NextTick = CurTime() + 1
end

function SWEP:Holster()
	return not self:IsCloaked()
end

if SERVER then
	local Materials = {}

	function SWEP:PrepareMaterial(mat)
		local shader = "VertexLitGeneric"
		local data = file.Read("materials/" .. mat .. ".vmt", "GAME") or ""
		local params = util.KeyValuesToTable(data) or {}
		params.Proxies = params.proxies or {}
		params["$cloakpassenabled"] = 1
		params["$cloakfactor"] = 0
		params.Proxies["PlayerCloak"] = {}
		Materials[mat] = CreateMaterial(mat .. "_c", shader, params)
	end

	function SWEP:CloakThink()
		if not self.Owner.CloakFactor then
			self.Owner.CloakFactor = 0
		end

		self.Owner.CloakFactor = math.Approach(self.Owner.CloakFactor, self:IsCloaked(self.Owner) and 1 or 0, FrameTime())
	end

	function SWEP:PrePlayerDraw(pl)
		if pl ~= self.Owner then return end
		self:CloakThink()

		if self.Owner.CloakFactor <= 0 then return end
		if self.Owner.CloakFactor >= 1 then return true end

		render.UpdateRefractTexture()

		for k, v in ipairs(self.Owner:GetMaterials()) do
			if Materials[v] == nil then
				self:PrepareMaterial(v)
			elseif Materials[v] == false then
				return
			end

			render.MaterialOverrideByIndex(k - 1, Materials[v])
		end
	end

	function SWEP:PostPlayerDraw(pl)
		if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end
		render.MaterialOverrideByIndex()
	end

	function SWEP:PreDrawPlayerHands(hands, vm, pl)
		if pl ~= self.Owner then return end
		self:CloakThink()
		if self.Owner.CloakFactor <= 0 then return end
		render.SetBlend(1 - self.Owner.CloakFactor)
	end

	function SWEP:PostDrawPlayerHands(hands, vm, pl)
		if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end
		render.SetBlend(1)
	end

	function SWEP:CustomAmmoDisplay()
		self.AmmoDisplay = self.AmmoDisplay or {}
		self.AmmoDisplay.Draw = true
		self.AmmoDisplay.PrimaryClip = self:Clip1()

		return self.AmmoDisplay
	end
end
