--This addon is not to be reupload or modified for public use without prior permission from Luria.
AddCSLuaFile()

SWEP.PrintName = "Institute Teleporter"
SWEP.Category = "Other"
SWEP.Author = "Luria"
SWEP.Purpose = "To teleport far distances"
SWEP.Instructions = "LM - Teleport to your crosshair\nRM - Teleport to preset position\nRELOAD - Set position for RM\nUSE + LM - Toggle Ruby Noise"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/v_hands.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_grenade.mdl" )
SWEP.ViewModelFOV = 75
SWEP.DrawCrosshair 	= true
SWEP.UseHands = true
SWEP.ShowWorldModel = false
SWEP.AdminOnly = false

if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "" )
SWEP.BounceWeaponIcon = false
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false

SWEP.BobScale = 0.75
SWEP.SwayScale = 1.25
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true

function SWEP:DrawHUD()

	if self.Owner:ShouldDrawLocalPlayer() == true then return end

	local x = ScrW() / 2.0 - 1
	local y = ScrH() / 2.0
	local scale = 0.275

	surface.SetDrawColor( 255, 0, 255, 255 )

	local gap = 40 * scale
	local length = gap + 21 * scale

	surface.DrawLine( x - gap - 6, y - 10, x, y - length - 3 )
	surface.DrawLine( x - gap - 6, y - 10, x - gap - 6, y + 10 )
	//surface.DrawLine( x - gap - 10, y + 10, x, y + length + 10 )
	surface.DrawLine( x, y - length - 3, x + gap + 6, y - 10 )
	surface.DrawLine( x + gap + 6, y - 10, x + gap + 6, y + 10 )
	//surface.DrawLine( x + gap + 10, y + 10, x, y + length + 10 )

	surface.DrawLine( x - gap - 6, y + 10, x, y - length + 37 )
	surface.DrawLine( x, y - length + 37, x + gap + 6, y + 10 )

end

function SWEP:Reload()

	if self.reloading == true then return end
	if self.teleporting == true then return end

	self.reloading = true

	timer.Create( "Reload_Cooldown" .. self.Owner:SteamID() .. "\n", 1, 1, function()
	self.reloading = false
	end)

	self.teleport_position = self.Owner:GetPos()

	if SERVER then
	self.Weapon:EmitSound( "tools/ifm/beep.wav" )
	self.Owner:ChatPrint( "Position set!" ) end

end

function SWEP:PreDrawViewModel( vm, wep, ply )

	vm:SetMaterial( "engine/occlusionproxy" )

end
function SWEP:Deploy()

	self.reloading = false
	self.noise_disabled = false
	self.teleporting = false

	local vm = self.Owner:GetViewModel()

	vm:SetPlaybackRate( 1 )

	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )


	self.TeleportSound = {
		Sound("Sonic_Mania/Attack1_L.wav"),
		Sound("Sonic_Mania/Attack1_R.wav"),
		Sound("Sonic_Mania/Attack2_L.wav"),
		Sound("Sonic_Mania/Attack2_R.wav"),
		Sound("Sonic_Mania/Attack3_L.wav"),
		Sound("Sonic_Mania/Attack3_R.wav"),
		Sound("Sonic_Mania/Attack4_L.wav"),
		Sound("Sonic_Mania/Attack4_R.wav"),
		Sound("Sonic_Mania/Attack5_L.wav"),
		Sound("Sonic_Mania/Attack6_R.wav"),
		Sound("Sonic_Mania/Attack6_L.wav") }
	return true

end

function SWEP:PostDrawViewModel()

	self:DrawEffects()

end

function SWEP:DrawEffects()

	if !IsValid(self.Owner) then
	local RubyLight = DynamicLight( self:EntIndex() )
	if ( RubyLight ) then
		RubyLight.Pos = self:GetPos()
		RubyLight.r = 220
		RubyLight.g = 0
		RubyLight.b = 255
		RubyLight.Brightness = 2
		RubyLight.Size = 50
		RubyLight.Decay = 0
		RubyLight.DieTime = CurTime() + 0.1
	end
	else
	local RubyLight = DynamicLight( self:EntIndex() )
	if ( RubyLight ) then
		RubyLight.Pos = self.Owner:EyePos()
		RubyLight.r = 220
		RubyLight.g = 0
		RubyLight.b = 255
		RubyLight.Brightness = 2
		RubyLight.Size = 50
		RubyLight.Decay = 0
		RubyLight.DieTime = CurTime() + 0.1
	end
	end

end

function SWEP:PropRise()
-- Use self:GetOwner() instead of self.Owner!
local tENTs = ents.FindInSphere(self:GetOwner():GetPos(), 800)


if SERVER then
for i = 1, #tENTs do
	local pENT = tENTs[i]

	if (pENT:IsPlayer()) and (pENT != self.Owner) then
		pENT:SetVelocity( Vector( 0, 0, 260 ) )
		pENT:SetGravity( 0.3 )
		timer.Simple( 3, function() pENT:SetGravity( 1 ) end )
		end

	if (pENT:GetClass() == "prop_physics") or (pENT:GetClass() == "prop_ragdoll") or (pENT:GetClass() == "prop_physics_multiplayer") then


		local bones = pENT:GetPhysicsObjectCount()

		for  i=0, bones-1 do

			local phys = pENT:GetPhysicsObjectNum( i )
			if ( IsValid( phys ) ) then
				phys:EnableGravity( false )
				phys:SetVelocity( Vector( 0, 0, 5 ) * 2)
				timer.Simple( 3, function() if !IsValid(phys) then return end phys:EnableGravity( true ) end )
			end
		end
	end
end

end

end


function SWEP:Transform()
-- Use self:GetOwner() instead of self.Owner!
local tENTs = ents.FindInSphere(self:GetOwner():GetPos(), 800)


if SERVER then
for i = 1, #tENTs do
	local pENT = tENTs[i]

	if (pENT:GetClass() == "npc_headcrab") then
	HeadcrabType = math.random(1,2)
	if HeadcrabType == 1 then
		Headcrab = ents.Create("npc_headcrab_black")
		undo.Create( "Poison Headcrab" )
		undo.AddEntity( Headcrab )
		undo.SetPlayer( self.Owner )
		undo.Finish()
		else
		Headcrab = ents.Create("npc_headcrab_fast")
		undo.Create( "Fast Headcrab" )
		undo.AddEntity( Headcrab )
		undo.SetPlayer( self.Owner )
		undo.Finish()
		end

		-- Hit the entity limit
		if (not Headcrab:IsValid()) then
			break
		end

		Headcrab:SetPos(pENT:GetPos() )
		Headcrab:SetAngles(pENT:GetAngles() )

		Headcrab:Spawn()
		pENT:Remove()
	end

	if (pENT:GetClass() == "npc_zombie") then
	ZombieType = math.random(1,2)
	if ZombieType == 1 then
		Zombie = ents.Create("npc_poisonzombie")
		undo.Create( "Poison Zombie" )
		undo.AddEntity( Zombie )
		undo.SetPlayer( self.Owner )
		undo.Finish()
		else
		Zombie = ents.Create("npc_fastzombie")
		undo.Create( "Fast Zombie" )
		undo.AddEntity( Zombie )
		undo.SetPlayer( self.Owner )
		undo.Finish()
		end

		-- Hit the entity limit
		if (not Zombie:IsValid()) then
			break
		end

		Zombie:SetPos(pENT:GetPos() )
		Zombie:SetAngles(pENT:GetAngles() )

		Zombie:Spawn()
		pENT:Remove()
	end

	if (pENT:GetClass() == "npc_zombie_torso") then
		Zombie = ents.Create("npc_zombie")

		-- Hit the entity limit
		if (not Zombie:IsValid()) then
			break
		end

		Zombie:SetPos(pENT:GetPos() )
		Zombie:SetAngles(pENT:GetAngles() )

		undo.Create( "Zombie" )
		undo.AddEntity( Zombie )
		undo.SetPlayer( self.Owner )
		undo.Finish()

		Zombie:Spawn()
		pENT:Remove()
	end

	if (pENT:GetClass() == "npc_fastzombie_torso") then
		Zombie = ents.Create("npc_fastzombie")

		-- Hit the entity limit
		if (not Zombie:IsValid()) then
			break
		end

		Zombie:SetPos(pENT:GetPos() )
		Zombie:SetAngles(pENT:GetAngles() )

		undo.Create( "Fast Zombie" )
		undo.AddEntity( Zombie )
		undo.SetPlayer( self.Owner )
		undo.Finish()

		Zombie:Spawn()
		pENT:Remove()
	end

	if (pENT:GetClass() == "npc_stalker") then
		Citizen = ents.Create("npc_citizen")

		-- Hit the entity limit
		if (not Citizen:IsValid()) then
			break
		end

		Citizen:SetPos(pENT:GetPos() )
		Citizen:SetAngles(pENT:GetAngles() )

		undo.Create( "Citizen" )
		undo.AddEntity( Citizen )
		undo.SetPlayer( self.Owner )
		undo.Finish()

		Citizen:Spawn()
		pENT:Remove()
	end

	if ( IsMounted( "ep2" ) ) then
	if (pENT:GetClass() == "npc_antlionguard") then
		pENT:SetMaterial("Models/antlion_guard/antlionGuard2")
		pENT:SetKeyValue( "cavernbreed", 1 )
		pENT:SetKeyValue( "incavern", 1 )
	end
	if (pENT:GetClass() == "npc_antlion") then
		Antlion = ents.Create("npc_antlion_worker")

		-- Hit the entity limit
		if (not Antlion:IsValid()) then
			break
		end

		Antlion:SetPos(pENT:GetPos() )
		Antlion:SetAngles(pENT:GetAngles() )

		undo.Create( "Antlion Worker" )
		undo.AddEntity( Antlion )
		undo.SetPlayer( self.Owner )
		undo.Finish()

		Antlion:Spawn()
		pENT:Remove()
	end
	if (pENT:GetClass() == "npc_zombine") then
		Combine = ents.Create("npc_combine_s")
		Combine:SetModel("models/combine_soldier.mdl")

		-- Hit the entity limit

		pENT:Remove()
	end
	end

	if (pENT:GetClass() == "npc_vortigaunt") then
		if pENT:GetModel() == ("models/vortigaunt_slave.mdl") then
		pENT:SetModel("models/vortigaunt.mdl") else
		if ( IsMounted( "ep2" ) ) then
		if pENT:GetModel() == ("models/vortigaunt.mdl") then
		pENT:SetModel("models/vortigaunt_doctor.mdl") end end end
	end
end

end

end

function SWEP:Teleport()

	if SERVER then
	self.Owner:EmitSound("Sonic_Mania/RedCube_L.wav") end

	local vm = self.Owner:GetViewModel()
	local effectdata = EffectData()
	effectdata:SetOrigin( vm:GetPos() + vm:GetForward() * 400 + vm:GetUp() * -100)
	util.Effect( "vm_distort", effectdata )
	self.Owner:Freeze( true )

	if SERVER then -- PARTICLE EFFECT EVENTS (By Keith)
		timer.Simple(2.8, function()
			ParticleEffect("nr_warp_engine_exhaust", vm:GetPos(), Angle(-90), self)
		end)

		timer.Simple(2.8, function()
			ParticleEffect("mr_skybox_galaxy1", vm:GetPos(), Angle(-90), self)
		end)

		timer.Simple(2.8, function()
			ParticleEffect("mr_energybeam_1", vm:GetPos(), Angle(-90), self)
		end)

		timer.Simple(2.6, function()
			ParticleEffect("mr_cop_anomaly_electra_a", vm:GetPos(), self:GetAngles(), self)
		end)

		timer.Simple(2.6, function()
			if self.Owner:GetNoDraw() == true then return end
			ParticleEffectAttach("super_shlrd",PATTACH_POINT_FOLLOW,self.Owner,0)
		end)

		timer.Simple(2.8, function()
			ParticleEffect("weapon_combine_ion_cannon_explosion", vm:GetPos(), self:GetAngles(), self)
			self.Owner:EmitSound("npc/scanner/cbot_energyexplosion1.wav")
			util.ScreenShake(self.Owner:GetPos(), 500, 500, 2, 800)
		end)

		timer.Simple(3.1, function()
			self:StopParticles()
		end)

		timer.Simple(3.2, function()
			ParticleEffect("mr_cop_anomaly_electra_a", vm:GetPos(), Angle(-90), self)
		end)

		timer.Simple(6, function()
			self:StopParticles()
			self.Owner:StopParticles()
		end)
	end

	self.Owner:SetFOV( 100, 2.9 )
	self.teleport_gotopos = (self.Owner:GetEyeTrace().HitPos)
		ply = self.Owner
		pos = ply:GetPos()
		tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos
		tracedata.filter = ply
		tracedata.mins = ply:OBBMins()
		tracedata.maxs = ply:OBBMaxs()
		trace = util.TraceHull( tracedata )

		if (trace.Entity:IsWorld() or trace.Entity:IsValid()) then return end

		shake_intensity = 1
		util.ScreenShake( Vector( 0, 0, 0 ), shake_intensity, shake_intensity, 1, 5000 )
		timer.Create( "Increase_Screen_Shake_" .. self.Owner:SteamID() .. "\n", 0.5, 3, function()
			util.ScreenShake( Vector( 0, 0, 0 ), shake_intensity + 3, shake_intensity + 3, 4, 5000 )
		end)

		timer.Create( "Open_Portal_Effect_" .. self.Owner:SteamID() .. "\n", 2.3, 1, function()
		if !IsValid(self) then return end
		local effectdata = EffectData()
		effectdata:SetOrigin( self.teleport_gotopos )
		util.Effect( "teleport_open", effectdata )
		end)

		timer.Create( "Teleport_Zoom_In_" .. self.Owner:SteamID() .. "\n", 2.9, 1, function()
			if !IsValid(self) then return end
			self.Owner:SetFOV( 60, 0.2 )
		end)

		timer.Create( ( "Teleport_Arrive_" .. self.Owner:SteamID() .. "\n"), 3, 1, function()
			if !IsValid(self) then return end
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "admire" ) )
			vm:SetPlaybackRate( 2.3 )
			self.Owner:SetGravity( 0.09 )
			timer.Create( "Fix_Gravity", 2, 1, function()
			if !IsValid(self) then return end
			self.Owner:SetGravity( 0 )
			end)

			self.Owner:SetFOV( 90, 0.7 )
			self.Owner:Freeze( false )
			end)

end

function SWEP:IdleSound()
end


function SWEP:PrimaryAttack()

	if ( IsFirstTimePredicted() ) then
	if self.Owner:KeyDown(IN_USE) then
	self:IdleSound()
	return end

	--if(self.Owner:GetEyeTrace().HitSky) then return end

	self:PropRise()
	self:Teleport()
	if SERVER then

	timer.Create( "Teleport_Arrive_" .. self.Owner:SteamID() .. "\n", 3, 1, function()
		if !IsValid(self) then return end
		self:Transform()
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "admire" ) )
		vm:SetPlaybackRate( 2.3 )
		self.Owner:SetGravity( 0.09 )
		timer.Create( "Fix_Gravity_" .. self.Owner:SteamID() .. "\n", 2, 1, function()
		if !IsValid(self) then return end
		self.Owner:SetGravity( 0 )
		end)

		self.Owner:SetFOV( 90, 0.7 )
		self.Owner:Freeze( false )
			if SERVER then
				self.Owner:EmitSound(self.TeleportSound[math.random(#self.TeleportSound)]) end
				local tENTs = ents.FindInSphere(self:GetOwner():GetPos(), 800)
				if SERVER then
				for i = 1, #tENTs do
				local pENT = tENTs[i]
				if (pENT:IsPlayer()) then
				pENT:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.7, 0 ) end
				end
				end

				--self.Owner:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.7, 0 )

				self.Owner:SetPos(self.teleport_gotopos)
				ply = self.Owner
				local pos = ply:GetPos()
				local tracedata = {}
				tracedata.start = pos
				tracedata.endpos = pos
				tracedata.filter = ply
				tracedata.mins = ply:OBBMins()
				tracedata.maxs = ply:OBBMaxs()
				local trace = util.TraceHull( tracedata )

				if SERVER then
				if self.Owner:IsInWorld() == true then
				local tr = self.Owner:GetEyeTrace()
					self.Owner:SetPos(self.Owner:GetPos() - (tr.Normal*(self.Owner:BoundingRadius()*2.2)))
				end
				end
				local effectdata = EffectData()
				effectdata:SetOrigin( self.Owner:GetPos() )
				util.Effect( "warp", effectdata )

	 end )

	 self:SetNextPrimaryFire( CurTime() + 5 )
	 self:SetNextSecondaryFire( CurTime() + 5 )
	end
	end

end

function SWEP:SecondaryAttack()

	if ( IsFirstTimePredicted() ) then
		if self.teleport_position == nil then
		if SERVER then
		self.Weapon:EmitSound( "tools/ifm/beep.wav" )
		self.Owner:ChatPrint( "Set a position first by pressing the reload key!" ) end
		self:SetNextPrimaryFire( CurTime() + 1 )
		self:SetNextSecondaryFire( CurTime() + 1 )
		return end

	self:PropRise()
	self:Teleport()

	timer.Create( "Open_Portal_Effect_" .. self.Owner:SteamID() .. "\n", 0, 1, function()
	local effectdata = EffectData()
	effectdata:SetOrigin( self.teleport_position )
	util.Effect( "warp_open", effectdata )

	timer.Create( "Close_Portal_" .. self.Owner:SteamID() .. "\n", 3.8, 1, function()
	if !IsValid(self) then return end
	local effectdata = EffectData()
	effectdata:SetOrigin( self.teleport_position )
	util.Effect( "warp_close", effectdata )
	end)
	end)

	timer.Create( "Teleport_Arrive_" .. self.Owner:SteamID() .. "\n", 3.1, 1, function()
	if !IsValid(self) then return end
		self:Transform()
		if !IsValid(self) then return end
		self.teleporting = false
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "admire" ) )
		vm:SetPlaybackRate( 2.3 )
		self.Owner:SetGravity( 0.09 )
		timer.Create( "Fix_Gravity_" .. self.Owner:SteamID() .. "\n", 2, 1, function()
		if !IsValid(self) then return end
		self.Owner:SetGravity( 0 )
		end)
		self.Owner:SetFOV( 90, 0.7 )
		local effectdata = EffectData()
		self.Owner:Freeze( false )
			if SERVER then
				self.Owner:EmitSound(self.TeleportSound[math.random(#self.TeleportSound)]) end
				local tENTs = ents.FindInSphere(self:GetOwner():GetPos(), 800)
				if SERVER then
				for i = 1, #tENTs do
				local pENT = tENTs[i]
				if (pENT:IsPlayer()) then
				pENT:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.7, 0 ) end
				end
				end
			self.Owner:SetPos(self.teleport_position)
	 end )

	 self:SetNextPrimaryFire( CurTime() + 5 )
	 self:SetNextSecondaryFire( CurTime() + 8 )
	end

end

function SWEP:Precache()

	--Models
	util.PrecacheModel( "models/luria/sonic_mania/phantom_ruby.mdl" )
	util.PrecacheModel( "models/weapons/v_hands.mdl" )
	util.PrecacheModel( "models/weapons/w_grenade.mdl" )
	--Sounds
 	util.PrecacheSound( "Sonic_Mania/Attack1_L.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack1_R.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack2_L.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack2_R.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack3_L.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack3_R.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack4_L.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack4_R.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack5_L.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack5_R.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack6_L.wav" )
	util.PrecacheSound( "Sonic_Mania/Attack6_R.wav" )

end

function SWEP:Think()

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()

end

function SWEP:OnDrop()

	self:Remove()

end

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01"] = { scale = Vector(1, 1, 1), pos = Vector(-0.15, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-7.5, 6.228, 2.8), angle = Angle(20.996, 15.548, 0) },
	["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-8.505, 6.228, -4.327), angle = Angle(-20.997, 15.548, -7) }
}

SWEP.VElements = {
	["Ruby_Glow"] = { type = "Sprite", sprite = "effects/ruby_glow", bone = "ValveBiped.Bip01", rel = "", pos = Vector(0, -24.1, 1.2), size = { x = 10, y = 10 }, color = Color(0, 186, 248, 100), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["Phantom_Ruby"] = { type = "Model", model = "", bone = "ValveBiped.Bip01", rel = "", pos = Vector(0, -21.353, 0), angle = Angle(111.039, 90, -180), size = Vector(0.73, 0.73, 0.73), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["Phantom_Ruby"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 3.111, -5.784), angle = Angle(-4.373, 1.56, -1.26), size = Vector(0.829, 0.829, 0.829), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378


	DESCRIPTION:
		This script is meant for experienced scripters
		that KNOW WHAT THEY ARE DOING. Don't come to me
		with basic Lua questions.

		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here
	self:SetHoldType("passive")

	if CLIENT then

		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels

		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)

				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")
				end
			end
		end

	end

end

function SWEP:Holster()

	if IsValid(self.Owner) then
	self.Owner:Freeze( false )
	self.Owner:StopSound("Ruby_Presence" .. self.Owner:SteamID() .. "\n")
	self.Owner:StopSound("Ruby_Presence", 75, 100, 1, CHAN_AUTO )
	timer.Destroy("Replay_Idle_Noise" .. self.Owner:SteamID() .. "\n")
	self.Owner:SetGravity( 0 )
	end

	if !IsValid(self) then return end


	if ( IsValid( self.Owner ) && CLIENT && self.Owner:IsPlayer() ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then vm:SetMaterial( "" ) end
	end

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()

		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		--self:DrawModel()
		self:DrawEffects()

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.

	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

end

