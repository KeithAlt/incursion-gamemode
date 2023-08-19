




AddCSLuaFile()









SWEP.PrintName = "Defibrillator"




SWEP.Author = "Dilusi0nz"




SWEP.Purpose = "Defibrillate people with left click, charge with right click."









SWEP.Slot = 2




SWEP.SlotPos = 3









SWEP.Spawnable = true









SWEP.ViewModel = Model( "models/weapons/c_medkit.mdl" )




SWEP.WorldModel = Model( "models/weapons/w_medkit.mdl" )




SWEP.ViewModelFOV = 80









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









SWEP.UsageDelay = 1









local HealSound = Sound( "HealthKit.Touch" )




local DenySound = Sound( "WallHealth.Deny" )









if SERVER then




	CVAR_DEFIB_TIME = CreateConVar( "defib_defibtime", "6", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Amount of time using the defib on a body should take, in seconds." );




	CVAR_DEFIB_WAKE = CreateConVar( "defib_wake", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "1 to enable the wake-up animation on respawn, 0 to disable." );




	CVAR_DEFIB_HEALTH = CreateConVar( "defib_health", "50", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "The amount of health the defibrillated player should spawn with." );




	CVAR_DEFIB_DAMAGE = CreateConVar( "defib_damage", "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Amount of damage the defib should do if used on players." );




	CVAR_DEFIB_DELAY = CreateConVar( "defib_delay", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Delay between being able to re-charge the defibrillator." );




end





function SWEP:Deploy()
	if SERVER then
		self.Owner:ChatPrint("✚ Your Intelligence gives you a " .. (self.Owner:getSpecial("I") / 10) .. " second decrease in revive time")
	end
end





function SWEP:Initialize()



	self:SetHoldType( "slam" )




	if ( CLIENT ) then return end




end


function SWEP:PrimaryAttack()









	if ( CLIENT ) then return end









	if ( self.Owner:IsPlayer() ) then




		self.Owner:LagCompensation( true )




	end









	local tr = util.TraceLine( {




		start = self.Owner:GetShootPos(),




	endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,




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









		// If defib time




		if defibTimer > 0 then
			timeLeft = defibTimer - (self.Owner:getSpecial("I") / 10)

			//Run timer once every second
			timer.Create("defibWait", 1, timeLeft + 1, function()

				self.Owner:EmitSound("items/smallmedkit1.wav", 50,90)

				ent:EmitSound("ui/stim.wav")
				//Check once every second while waiting to see if still looking at body

				local tr = util.TraceLine( {
					start = self.Owner:GetShootPos(),
					endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
					filter = self.Owner
				} )

				if tr.Entity == nil or tr.Entity == NULL then
					self.Owner:falloutNotify("[ ! ] The defibrilation failed!", "ui/notify.mp3")
					timer.Remove("defibWait")
				else
					timeLeft = math.Clamp(timeLeft - 1, 0, 10)
					self.Owner:PrintMessage(HUD_PRINTTALK,"Time left: ".. tostring(timeLeft))

					local effectData = EffectData()
					effectData:SetOrigin(ent:GetPos())
					util.Effect("VortDispel", effectData)
				end

				if timeLeft <= 0 then
					respawnPlayer(ent.Ply, ent, self)
					timer.Remove("defibwait")
				end




			end)





		else




			respawnPlayer(ent.Ply, ent, self)




		end




	end




	if ent:IsPlayer() and ent:Alive() and !self.defibNotificationCooldown then




		self.Owner:falloutNotify("You cannot defibrillate the living!", "ui/notify.mp3")
		self.defibNotificationCooldown = true

		timer.Simple(5, function()
			self.defibNotificationCooldown = nil
		end)
	end




end










function respawnPlayer(deadGuy, ent, self)




		deadGuy = ent.Ply









		deadGuy:UnSpectate()




		deadGuy:Spawn()
		deadGuy:SetPos(ent:GetPos())
		deadGuy:falloutNotify("✚ You have been revived!", "ui/goodkarma.ogg")
		self.Owner:falloutNotify("✚ Your defibrilation was a success!", "ui/goodkarma.ogg")

		local effectData = EffectData()
		effectData:SetOrigin(deadGuy:GetPos())
		util.Effect("VortDispel", effectData)





		deadGuy:SetHealth(GetConVarNumber("defib_health"))




		deadGuy:SetPos(deadGuy.defibRagdoll:GetPos() + Vector(0,0,20))




		if GetConVarNumber("defib_wake") == 1 then deadGuy:ScreenFade( SCREENFADE.IN, Color( 0,0,0, 255 ), 0.5, 0.5 ) end




		-- Give weps back




		if not deadGuy.WepTbl == NULL then









			table.ForEach( deadGuy.WepTbl , function ( k, v )









				deadGuy:Give(deadGuy.WepTbl[k])









			end)




			deadGuy.WepTbl = NULL




		end














		ent:Remove()




end









function SWEP:SecondaryAttack()



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




	deathRagdoll:SetSkin( victim:GetSkin() )









	//for k, v in pairs(victim:GetBodyGroups()) do









	//	if not isnumber(v) then return end









	//	if victim:GetBodygroup(v) != nil then









	//		deathRagdoll:SetBodygroup(v,victim:GetBodyGroup(v))




//




	//	end




	//end









	deathRagdoll.Ply = victim




	deathRagdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON )




	deathRagdoll:Spawn()









	victim.defibRagdoll = deathRagdoll




	//victim:Spectate(OBS_MODE_CHASE)




	victim:EmitSound("HL1\fvox\flatline.wav", 100, 100)




	victim:ScreenFade( SCREENFADE.IN, Color( 200,0,0, 70 ), 3, 15 )




	//victim:SpectateEntity(deathRagdoll)









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









	player:UnSpectate()




	player.defibRagdoll:Remove()









end)









hook.Add( "PlayerDisconnected", "onDC", function( ply )









	if (ply.defibRagdoll == NULL or ply.defibRagdoll == nil) then return end









	player:UnSpectate()




	ply.defibRagdoll:Remove()




	ply.preDeathWeps = NULL









end)
