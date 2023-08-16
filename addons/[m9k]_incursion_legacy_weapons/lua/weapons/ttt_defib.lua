
AddCSLuaFile()

SWEP.PrintName = "Defibrillator"
SWEP.Author = "Dilusi0nz"
SWEP.Purpose = "Defibrillate people with left click, charge with right click."

SWEP.Base = "weapon_tttbase"
SWEP.Slot = 2
SWEP.SlotPos = 3

SWEP.Spawnable = false

SWEP.ViewModel = Model( "models/weapons/c_medkit.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_medkit.mdl" )
SWEP.ViewModelFOV = 80

//TTT shit
SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_DETECTIVE }
SWEP.AllowDrop = false
SWEP.InLoadoutFor = nil
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.LimitedStock = true
-- Path to the icon material
SWEP.Icon = "materials/vgui/ttt/icon_defibgang.png"

-- Text shown in the equip menu
SWEP.EquipMenuData = {
  type = "Defibrillator",
  desc = "Defibrillate whoever you want."
}

SWEP.beenUsed = 0

SWEP.UseHands = true

SWEP.Category = "Dilusi0nz SWEPs"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.isCharged = 0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local HealSound = Sound( "HealthKit.Touch" )
local DenySound = Sound( "WallHealth.Deny" )

if SERVER then
	CVAR_DEFIB_TIME = CreateConVar( "defib_defibtime", "5", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Amount of time using the defib on a body should take, in seconds." );
	CVAR_DEFIB_WAKE = CreateConVar( "defib_wake", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "1 to enable the wake-up animation on respawn, 0 to disable." );
	CVAR_DEFIB_HEALTH = CreateConVar( "defib_health", "50", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "The amount of health the defibrillated player should spawn with." );
	CVAR_DEFIB_DAMAGE = CreateConVar( "defib_damage", "25", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Amount of damage the defib should do if used on players." );
	CVAR_DEFIB_DELAY = CreateConVar( "defib_delay", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Delay between being able to re-charge the defibrillator." );
	resource.AddFile("materials/vgui/ttt/icon_defibgang.png")
end

function SWEP:Initialize()

	self:SetHoldType( "slam" )
	if ( CLIENT ) then return end
end

function SWEP:PrimaryAttack()

	if ( CLIENT ) then return end

	if (self.isCharged != 1) then self.Owner:PrintMessage(HUD_PRINTCENTER,"Defibrillator is not charged, press right click!") return end

	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( true )
	end

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64,
		filter = self.Owner
	} )
	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( false )
	end

	local ent = tr.Entity -- Entity looked at
	//self.Owner:PrintMessage(HUD_PRINTTALK, tostring(ent:GetClass()))
	if( ent != nil and ent:IsValid() and ent:GetClass() == "prop_ragdoll" ) then

		--Respawn
		if ( ent.Ply == NULL ) then return end

		self.Owner:EmitSound("items/smallmedkit1.wav", 100,100)

		defibTimer = GetConVarNumber("defib_defibtime")

		if self.beenUsed == 1 then self.Owner:PrintMessage(HUD_PRINTCENTER,"You have already used the defib!") return end

		// If defib time
		if defibTimer > 0 then
			timeLeft = defibTimer

			//Run timer once every second
			timer.Create("defibWait", 1, defibTimer, function()
				self.Owner:EmitSound("items/smallmedkit1.wav", 100,100)
				//Check once every second while waiting to see if still looking at body
				local tr = util.TraceLine( {
					start = self.Owner:GetShootPos(),
					endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64,
					filter = self.Owner
				} )

				if tr.Entity == nil or tr.Entity == NULL then
					
					self.Owner:PrintMessage(HUD_PRINTTALK,"You failed the defibrillation!")
					timer.Remove("defibWait")
				else
					timeLeft = timeLeft - 1
					self.Owner:PrintMessage(HUD_PRINTTALK,"Time left: "..tostring(timeLeft))
				end

				if timeLeft == 0 then
					respawnPlayer(ent.Ply, ent, self)
				end
			end)

		else
			respawnPlayer(ent.Ply, ent, self)
		end
	end
	if ent:IsPlayer() and GetConVarNumber("defib_damage") > 0 then
		ent:SetHealth(ent:Health() - GetConVarNumber("defib_damage"))
		self.Owner:EmitSound("npc/combine_soldier/pain1.wav", 100,100)
		self.isCharged = 0
		self.beenUsed = 1
		if ent:Health() <= 0 then
			ent:Kill()
		end
	end
end

function respawnPlayer(deadGuy, ent, self)
		deadGuy = ent.Ply
		deadGuy:SpawnForRound(true)
		deadGuy:SetHealth(GetConVarNumber("defib_health"))
		deadGuy:SetPos(deadGuy.defibRagdoll:GetPos() + Vector(0,0,20))
	
		if GetConVarNumber("defib_wake") == 1 then deadGuy:ScreenFade( SCREENFADE.IN, Color( 0,0,0, 255 ), 0.5, 0.5 ) end
		
		ent:Remove()

		self.beenUsed = 1
		self.isCharged = 0
		self.Owner:PrintMessage(HUD_PRINTCENTER,"Defibrillator charge used!")
end

function SWEP:SecondaryAttack()

	if (CLIENT) then return end
	if self.beenUsed == 1 then self.Owner:PrintMessage(HUD_PRINTCENTER,"You have already used the defib!") return end
	if (self.isCharged == 0) then

		self.isCharged = 1
		self.Owner:EmitSound("items/suitchargeno1.wav", 100, 100)
		self.Owner:PrintMessage(HUD_PRINTCENTER,"Defibrillator now charged!")

	end

end

function SWEP:OnRemove()

	timer.Stop( "medkit_ammo" .. self:EntIndex() )
	timer.Stop( "weapon_idle" .. self:EntIndex() )

end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

	return true

end

function SWEP:CustomAmmoDisplay()

	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:Clip1()

	return self.AmmoDisplay

end

-- Spawn ragdoll on player on death
hook.Add( "PlayerDeath", "replaceDeathShit", function( victim, inflictor, attacker)
	if gmod.GetGamemode().Name == "Trouble in Terrorist Town" then return end
	if (victim.preDeathWeapons != NULL) then victim.preDeathWeps = NULL end
	//if( CLIENT ) then return end
	if (!(victim:IsPlayer())) then return end
	local deathRagdoll = ents.Create( "prop_ragdoll" )

	if ( !IsValid( deathRagdoll ) ) then return end // Check whether we successfully made an entity, if not - bail
	deathRagdoll:SetPos( Vector( victim:GetPos() ) )

	deathRagdoll:SetModel( victim:GetModel() )
	deathRagdoll.Ply = victim
	deathRagdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON )
	deathRagdoll:Spawn()

	victim.defibRagdoll = deathRagdoll

	local plyvel = victim:GetVelocity()

	for i = 1, deathRagdoll:GetPhysicsObjectCount() do
		local bone = deathRagdoll:GetPhysicsObjectNum(i)
		
		if bone and bone.IsValid and bone:IsValid() then
			local bonepos, boneang = victim:GetBonePosition(deathRagdoll:TranslatePhysBoneToBone(i))
			
			bone:SetPos(bonepos)
			bone:SetAngles(boneang)
			bone:SetVelocity(plyvel)
		end
	end

	--Remove normal ragdoll
	timer.Simple(0.01, function()
		if(victim:GetRagdollEntity() != nil and	victim:GetRagdollEntity():IsValid()) then
			victim:GetRagdollEntity():Remove()
		end
	end )

	victim.WepTbl = {}
	-- Get weapons and store them
	for k,v in pairs(victim:GetWeapons()) do
		victim.WepTbl[table.Count(victim.WepTbl) + 1] = v:GetClass()
	end
end)

//TTT corpse
hook.Add("TTTOnCorpseCreated", "tttCorpseInfo", function(corpse, ply)

	//Not sure if weapons work using this method, needs testing
	ply.defibRagdoll = corpse 
	corpse.Ply = ply


end)



hook.Add ( "PlayerSpawn", "onSpawn", function( player )

	if (player.defibRagdoll == NULL or player.defibRagdoll == nil) then return end
	
	player.defibRagdoll:Remove()

end)

hook.Add( "PlayerDisconnected", "onDC", function( ply )

	if (ply.defibRagdoll == NULL or ply.defibRagdoll == nil) then return end

	ply.defibRagdoll:Remove()
	ply.preDeathWeps = NULL

end)

