AddCSLuaFile()

SWEP.PrintName = "Courser Scrub Voicelines"
SWEP.Category = "Voicelines"
SWEP.Author = "Keith"
SWEP.Purpose = "Project fear"
SWEP.Instructions = "Primary: 7 Minutes // Secondary: 10 Minutes (+Music) // Reload: Passives"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/v_hands.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_grenade.mdl" )
SWEP.ViewModelFOV = 75
SWEP.DrawCrosshair 	= true
SWEP.UseHands = true
SWEP.ShowWorldModel = false
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.VoiceCooldown = 0
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true

// Scuffed voiceline script for Courser events //

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_USE) then
		self.Owner:EmitSound("courser/courser_voiceline_end1.ogg")
		self.Owner:ChatPrint("Playtime over . . .")
		return
	end
	if self.PrimaryConfirmation then
		self.Owner:EmitSound("courser/courser_voiceline_start_1.ogg")
		self.Owner:ChatPrint("7 Minutes . . .")
		return
	end
	self.PrimaryConfirmation = true
	self.Owner:ChatPrint("7 Minutes . . .")
end

function SWEP:SecondaryAttack()
	if self.Owner:KeyDown(IN_USE) && SERVER then
		self.Owner:ChatPrint("[ Spawning Music Entity ]")

		local musicEmitter = ents.Create("prop_physics")
		musicEmitter:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		musicEmitter:SetPos(self.Owner:GetEyeTrace().HitPos)
		musicEmitter:SetCollisionGroup(COLLISION_GROUP_NONE)
		musicEmitter:SetNoDraw(true)
		musicEmitter:DrawShadow(false)
		musicEmitter:SetMoveType(MOVETYPE_NONE)
		musicEmitter:Spawn()
		musicEmitter:EmitSound("courser/music/institute_hunt.ogg", 125, 100, 100, CHAN_REPLACE)

		local musicEmitterPhysics = musicEmitter:GetPhysicsObject()
		musicEmitterPhysics:EnableMotion(false)

		timer.Simple(300, function()
			if IsValid(musicEmitter) then
				musicEmitter:Remove()
			end
		end)
		return
	end

	if self.SecondaryConfirmation then
		self.Owner:EmitSound("courser/courser_voiceline_start_2.ogg")
	end
	self.Owner:ChatPrint("10 Minutes . . .")
	self.SecondaryConfirmation = true
end

function SWEP:Reload()
	if self.Owner:KeyPressed(IN_USE) then
		self.Owner:EmitSound("courser/courser_voiceline_2.ogg")
		self.Owner:ChatPrint("I tire . . .")
	elseif self.Owner:KeyPressed(IN_WALK) then
		self.Owner:EmitSound("courser/courser_voiceline_5.ogg")
		self.Owner:ChatPrint("My precious time . . .")
	elseif self.Owner:KeyPressed(IN_ZOOM) then
		self.Owner:EmitSound("courser/courser_voiceline_7.ogg")
		self.Owner:ChatPrint("The inevitable . . .")
	end
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
	self.Owner:ChatPrint("- PRIMARY [LMB]: 7 MINUTES")
	self.Owner:ChatPrint("- PRIMARY [LMB] + E: Playtime over . . .")
	self.Owner:ChatPrint("- SECONDARY [RMB]: 10 MINUTES")
	self.Owner:ChatPrint("- SECONDARY [RMB] + E: MUSIC EMITTER")
	self.Owner:ChatPrint("- R + E: I tire . . .")
	self.Owner:ChatPrint("- R + ALT: My precious time . . .")
	self.Owner:ChatPrint("- R + ZOOM: The inevitable . . .")
end

