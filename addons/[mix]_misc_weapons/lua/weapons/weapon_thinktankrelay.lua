if SERVER then
	concommand.Add("ttrelay_settppoint",function(ply) -- Set the primary teleport destination
		if !IsValid(ply) or !ply:IsSuperAdmin() then return end

		if !file.Exists("relay", "DATA") then
			ErrorNoHalt("No 'relay' directory exists ; generating")
			file.CreateDir("relay")
		end


		local tppoints = file.Read("relay/ttrelay.txt","DATA")
		if !tppoints or string.len(tppoints) <= 0 then tppoints = "" end
		local tpTable = util.JSONToTable(tppoints)
		if !tpTable then tpTable = {} end

		tpTable[game.GetMap()] = ply:GetPos()
		file.Write("relay/ttrelay.txt",util.TableToJSON(tpTable))

		ply:ChatPrint("[NOTICE] You've set the relay point to your current position")
	end)

	concommand.Add("ttrelay_setexit",function(ply)	-- Set the exit destination
		if !IsValid(ply) or !ply:IsSuperAdmin() then return end

		if !file.Exists("relay", "DATA") then
			ErrorNoHalt("No 'relay' directory exists ; generating")
			file.CreateDir("relay")
		end


		local tppoints = file.Read("relay/ttexit.txt","DATA")
		if !tppoints or string.len(tppoints) <= 0 then tppoints = "" end
		local tpTable = util.JSONToTable(tppoints)
		if !tpTable then tpTable = {} end

		tpTable[game.GetMap()] = ply:GetPos()
		file.Write("relay/ttexit.txt",util.TableToJSON(tpTable))

		ply:ChatPrint("[NOTICE] You've set the exit point to your current position")
	end)
end

AddCSLuaFile()

SWEP.Author 		= "Claymore Gaming"
SWEP.Purpose		= "Teleportation Utility Equipment"
SWEP.Category	    = "Claymore Gaming"
SWEP.Instructions	= "· [LMB] Teleport Victim\n· [RMB] Teleport Self\n· [R] Teleport Wasteland"

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false

SWEP.PrintName		= "Think Tank Relay"
SWEP.Slot			= 0
SWEP.SlotPos		= 0
SWEP.HoldType		= "normal"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.AttackDelay	= 8
SWEP.ISSCP 			= true
SWEP.droppable		= false
SWEP.NextAttackW	= 0
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true

function SWEP:Equip()
	if IsFirstTimePredicted() then
		jlib.Announce(self.Owner, Color(255,0,0), "\n[REMINDER] ", Color(255,155,155), "If you are under FearRP you cannot teleport to escape!")
	end
end

function SWEP:DrawWorldModel()
end

function SWEP:GetRelayPosition()
	local fl = file.Read("relay/ttrelay.txt","DATA") or false

	if not fl or string.len(fl) <= 0 then
		error("Attempted to use relay SWEP with no configured destination")
		return
	end

	local tpTable = util.JSONToTable(fl)
	if not tpTable then return end
	if not tpTable[game.GetMap()] then return end

	return tpTable[game.GetMap()]
end

function SWEP:GetExitPosition()
	local fl = file.Read("relay/ttexit.txt","DATA") or false

	if not fl or string.len(fl) <= 0 then
		error("Attempted to use relay SWEP with no configured destination")
		return
	end

	local tpTable = util.JSONToTable(fl)
	if not tpTable then return end
	if not tpTable[game.GetMap()] then return end

	return tpTable[game.GetMap()]
end

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end

	if SERVER then
		jlib.Announce(self.Owner, Color(255, 150, 0), "\nTeleporting to wasteland...")
	end

	self.NextAttackW = CurTime() + self.AttackDelay
	local TeleportTime = 3.5

	ParticleEffectAttach( "mr_fx_beamelectric_arcc1", 1, self, 1 )
	self:EmitSound("npc/scanner/scanner_electric2.wav")
	self.Owner:EmitSound("ambient/levels/labs/teleport_weird_voices1.wav")

	timer.Simple(2.9, function()
		self:StopParticles()
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	end)

	timer.Simple(3, function()
		ParticleEffectAttach( "mr_b_fx_1_core", 1, self, 1 )
		ParticleEffect("mr_b_fx_1_core", self:GetPos(), self:GetAngles(), self)
	end)

	timer.Simple(TeleportTime, function()
		self:StopParticles()
	end)

	if SERVER then
		if !IsValid(self.Owner) and self.Owner:Alive() == false then return end
		local user = self.Owner

		timer.Simple(3.5, function()
			self.Owner:EmitSound("ambient/machines/teleport3.wav")
		end)


		timer.Simple(TeleportTime, function()
		if !IsValid(self) or !IsValid(self.Owner) or self.Owner:Alive() == false then return end
			local tppos = self:GetExitPosition()
			if !tppos then return end
			user:SetPos(tppos)
			self.Owner:ScreenFade(SCREENFADE.IN, Color(255, 155, 155, 255), 1.5, 0.5)
			user:falloutNotify("[!] You have teleported home", "ui/notify.mp3")
		end)
	end
end

function SWEP:HUDShouldDraw( element )
	local hide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true,
	}
	if hide[element] then return false end
	return true
end

function SWEP:SecondaryAttack()
if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay
	local TeleportTime = 3.5

	if SERVER then
		jlib.Announce(self.Owner, Color(255, 150, 0), "\nTeleporting to homebase...")
	end

	ParticleEffectAttach( "mr_fx_beamelectric_arcc1", 1, self, 1 )
	self:EmitSound("npc/scanner/scanner_electric2.wav")
	self.Owner:EmitSound("ambient/levels/labs/teleport_weird_voices1.wav")

	timer.Simple(2.9, function()
		self:StopParticles()
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	end)

	timer.Simple(3, function()
		ParticleEffectAttach( "mr_b_fx_1_core", 1, self, 1 )
		ParticleEffect("mr_b_fx_1_core", self:GetPos(), self:GetAngles(), self)
	end)

	timer.Simple(TeleportTime, function()
		self:StopParticles()
	end)

	if SERVER then
		if !IsValid(self.Owner) and self.Owner:Alive() == false then return end
		local user = self.Owner

		timer.Simple(3.5, function()
			self.Owner:EmitSound("ambient/machines/teleport3.wav")
		end)


		timer.Simple(TeleportTime, function()
		if !IsValid(self) or !IsValid(self.Owner) or self.Owner:Alive() == false then return end
			local tppos = self:GetRelayPosition()
			if !tppos then return end

			self.Owner:ScreenFade(SCREENFADE.IN, Color(100, 0, 0, 255), 1.5, 0.5)
			user:SetPos(tppos)
			user:falloutNotify("[!] You have teleported to the wasteland", "ui/notify.mp3")
		end)
	end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay
	ParticleEffectAttach( "mr_fx_beamelectric_arcc1", 1, self, 1 )
	self:EmitSound("npc/scanner/scanner_electric2.wav")
	self.Owner:EmitSound("ambient/levels/labs/teleport_weird_voices1.wav")

	if SERVER then
		jlib.Announce(self.Owner, Color(255, 150, 0), "\nAttempting to abduct...")
	end

	timer.Simple(2.9, function()
		self:StopParticles()
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	end)

	timer.Simple(3, function()
		if !IsValid(self.Owner:GetEyeTrace().Entity) then return end
		ParticleEffectAttach( "mr_b_fx_1_core", 1, self, 1 )
		ParticleEffect("mr_b_fx_1_core", self:GetPos(), self:GetAngles(), self)
	end)

	timer.Simple(5, function()
		self:StopParticles()
	end)

	timer.Simple(5, function()
		if SERVER then
			local ent = self.Owner:GetEyeTrace().Entity

			if not (ent:GetPos():Distance(self.Owner:GetPos()) < 150) then
				self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
				self.Owner:falloutNotify("[!] You are not close enough to your target!", "ui/notify.mp3")
		 		return
			end

			if not ent:IsPlayer() then return end
			local weapon = ent:GetActiveWeapon()
			if weapon and weapon.ISSCP then return end

			self.Owner:ScreenFade(SCREENFADE.IN, Color(255, 155, 155, 255), 1.5, 0.5)
			ent:ScreenFade(SCREENFADE.IN, Color(255, 155, 155, 255), 1.5, 0.5)

			local tppos = self:GetRelayPosition()
			if not tppos then return end
			ent:falloutNotify("You have been teleported!", "notify.mp3")
			ent:SetPos(tppos)
			self.Owner:SetPos(tppos)
		end
	end)
end
