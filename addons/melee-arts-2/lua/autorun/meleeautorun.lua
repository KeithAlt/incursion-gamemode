--[[----------------Welcome to MELEE ART 2's code!----------------------------------------------------------
          __
     w  c(..)o   (
      \__(-)    __)   Version (idk i dont even change this)
          /\   (
         /(_)___)
         w /|
          | \
          m  m  do whatever with my code, just give me credit. this is a hobby ting.
--]]-----------------------------------------------------------------------------------------------------------------

CreateConVar( 		"ma2_startwithfists", "0", FCVAR_ARCHIVE, "Sets if the player starts with fists. Default disabled" )
CreateConVar( 		"ma2_togglethrowing", "1", FCVAR_ARCHIVE, "Sets if the player can throw weapons. Default enabled" )
CreateConVar( 		"ma2_togglechargeui", "1", FCVAR_ARCHIVE, "Sets if the player sees the Charge damage numbers. Default enabled" )
CreateConVar( 		"ma2_togglecrosshair", "0", FCVAR_ARCHIVE, "Sets if the player sees the crosshair. Default disabled" )
CreateConVar( 		"ma2_damagemultiplier", "1", FCVAR_ARCHIVE, "Sets the damage multiplier for all melee weapons. Default is 1" )

CreateConVar( 		"ma2_combatantmaxtier", "4", FCVAR_ARCHIVE, "Sets the maximum tier a combatant can be. Default is 4" )

function MA2Settings( Panel )
	Panel:Help( "Welcome to Melee Arts 2 Options!" )
	
	Panel:Help( " " )
	Panel:ControlHelp( "Weapons" )
    Panel:CheckBox( "Start with fists", "ma2_startwithfists")
	Panel:CheckBox( "Toggle Weapon Throwing", "ma2_togglethrowing")	
	Panel:CheckBox( "Toggle Crosshair", "ma2_togglecrosshair")
	Panel:CheckBox( "Toggle Charge UI", "ma2_togglechargeui")	
	Panel:Help( "NOTE: It is reccomended to keep this enabled, unless you're doing something cinematic" )
	Panel:NumSlider( "Damage Multiplier", "ma2_damagemultiplier", 0.5, 5,1)
	
	Panel:Help( " " )
	Panel:ControlHelp( "Combatants" )
	Panel:NumSlider( "Maximum Tier", "ma2_combatantmaxtier", 1, 4,0)
end

function MeleeArt2Menu()
	spawnmenu.AddToolMenuOption( "Options",
	"Melee Arts 2",
	"meleearts2menu",
	"Settings",
	"custom_doitplease",
	"", -- Resource File( Probably shouldn't use )
	MA2Settings )
end

hook.Add( "PopulateToolMenu", "MeleeArts2MenuYe", MeleeArt2Menu )

function Exposed( target, dmginfo )
	if (  target:GetNWBool("MAExpose") == true and target:GetNWInt( 'exposelevel' )!=0 ) then
		target:EmitSound("npc/zombie/claw_strike3.wav")
		if target:GetNWInt( 'exposelevel' )==1 then
			dmginfo:ScaleDamage(1.25)
			target:SetNWBool("MAExpose",false)
			target:SetNWInt( 'exposelevel', 0 )
		elseif target:GetNWInt( 'exposelevel' )==2 then
			dmginfo:ScaleDamage(1.3)
			target:SetNWBool("MAExpose",false)
			target:SetNWInt( 'exposelevel', 0 )
		elseif target:GetNWInt( 'exposelevel' )==3 then
			dmginfo:ScaleDamage(1.4)
			target:SetNWBool("MAExpose",false)
			target:SetNWInt( 'exposelevel', 0 )
		elseif target:GetNWInt( 'exposelevel' )==4 then
			dmginfo:ScaleDamage(1.45)
			target:SetNWBool("MAExpose",false)
			target:SetNWInt( 'exposelevel', 0 )
		elseif target:GetNWInt( 'exposelevel' )==5 then
			dmginfo:ScaleDamage(1.55)
			target:SetNWBool("MAExpose",false)
			target:SetNWInt( 'exposelevel', 0 )
		elseif target:GetNWInt( 'exposelevel' )==6 then
			dmginfo:ScaleDamage(2)
			target:SetNWBool("MAExpose",false)
			target:SetNWInt( 'exposelevel', 0 )
		end
	end
end
hook.Add("EntityTakeDamage", "ExposeMA",  Exposed )

function Guarding( target, dmginfo )
	if (  target:IsPlayer() and target:GetNWBool("MAGuardening") == true and target:Alive()  ) then
		if ( dmginfo:IsDamageType(4) or dmginfo:IsDamageType(128) ) then
			local wep = target:GetActiveWeapon()
			--target:SetNWInt( 'MeleeArts2Stamina', math.floor(target:GetNWInt( 'MeleeArts2Stamina' )-wep.BlockStamina) )
			local w = math.random(1)
			w = math.random(1,2)
			if w == 1 then  
				target:EmitSound(wep.Impact1Sound)
			elseif w == 2 then
				target:EmitSound(wep.Impact2Sound)
			end
			dmginfo:ScaleDamage(0.1)
		elseif (dmginfo:IsDamageType(1)) then
			local wep = dmginfo:GetAttacker():GetActiveWeapon()
			target:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
			target:EmitSound("pierce.mp3")
			if wep.Strength==1 then
				dmginfo:ScaleDamage(0.15)
			elseif wep.Strength==2 then
				dmginfo:ScaleDamage(0.2)
			elseif wep.Strength==3 then
				dmginfo:ScaleDamage(0.25)
			elseif wep.Strength==4 then
				dmginfo:ScaleDamage(0.3)
			elseif wep.Strength==5 then
				dmginfo:ScaleDamage(0.45)
			elseif wep.Strength==6 then
				dmginfo:ScaleDamage(0.5)
			end
		end
	end
end
hook.Add("EntityTakeDamage", "GuardeningMA",  Guarding )

function MADMGMultiplier( target, dmginfo )
	if IsValid(dmginfo:GetAttacker()) then
		if dmginfo:GetAttacker():IsPlayer() then
			local attacker = dmginfo:GetAttacker()
			local wep = attacker:GetActiveWeapon()
			if IsValid(wep) then
				wepCheck = string.find( wep:GetClass(), "meleearts" )
				if wepCheck then
					dmginfo:ScaleDamage(GetConVarNumber("ma2_damagemultiplier"))
				end
			end
		end
	end
end
hook.Add("EntityTakeDamage", "MultiplierMA",  MADMGMultiplier )

function ShieldGuarding( target, dmginfo )
	if (  target:IsPlayer() and target:GetNWBool("MeleeArtShieldening") == true and target:Alive()  ) then
		if ( dmginfo:IsDamageType(4) or dmginfo:IsDamageType(128) ) then
			local wep = target:GetActiveWeapon()
			--target:SetNWInt( 'MeleeArts2Stamina', math.floor(target:GetNWInt( 'MeleeArts2Stamina' )-wep.BlockStamina) )
			target:EmitSound(wep.Impact1Sound)
			wep.ShieldHealth=wep.ShieldHealth-dmginfo:GetDamage()/1.5
			wep:SetClip1(wep.ShieldHealth)
			print(wep.ShieldHealth)
			if wep.ShieldHealth<=0 then
				target:SetNWBool("MeleeArtShieldening",false)
				if target:IsValid() then
					target:StripWeapon(wep.WepName)
					target:EmitSound("physics/wood/wood_box_break1.wav")
					if target:HasWeapon( "meleearts_bludgeon_fists" ) then
						target:SelectWeapon( "meleearts_bludgeon_fists" )
					end
				end
			else
				dmginfo:ScaleDamage(0)
			end
		elseif ( dmginfo:IsDamageType(1)) then
			local wep = target:GetActiveWeapon()
			--target:SetNWInt( 'MeleeArts2Stamina', math.floor(target:GetNWInt( 'MeleeArts2Stamina' )-wep.BlockStamina) )
			target:EmitSound(wep.Impact1Sound)
			target:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
			target:EmitSound("weapons/crossbow/bolt_skewer1.wav")
			wep.ShieldHealth=wep.ShieldHealth-dmginfo:GetDamage()
			wep:SetClip1(wep.ShieldHealth)
			print(wep.ShieldHealth)
			if wep.ShieldHealth<=0 then
				target:SetNWBool("MeleeArtShieldening",false)
				if target:IsValid() then
					target:StripWeapon(wep.WepName)
					target:EmitSound("physics/wood/wood_box_break1.wav")
					if target:HasWeapon( "meleearts_bludgeon_fists" ) then
						target:SelectWeapon( "meleearts_bludgeon_fists" )
					end
				end
			else
				dmginfo:ScaleDamage(0.3)
			end
		elseif ( dmginfo:IsDamageType(2) ) then
			local wep = target:GetActiveWeapon()
			--target:SetNWInt( 'MeleeArts2Stamina', math.floor(target:GetNWInt( 'MeleeArts2Stamina' )-wep.BlockStamina) )
			target:EmitSound("physics/wood/wood_box_impact_bullet4.wav")
			target:EmitSound(wep.Impact1Sound)
			wep.ShieldHealth=wep.ShieldHealth-dmginfo:GetDamage()
			wep:SetClip1(wep.ShieldHealth)
			print(wep.ShieldHealth)
			if wep.ShieldHealth<=0 then
				target:SetNWBool("MeleeArtShieldening",false)
				if target:IsValid() then
					target:StripWeapon(wep.WepName)
					target:EmitSound("physics/wood/wood_box_break1.wav")
					if target:HasWeapon( "meleearts_bludgeon_fists" ) then
						target:SelectWeapon( "meleearts_bludgeon_fists" )
					end
				end
			else
				dmginfo:ScaleDamage(0.25)
			end
		end
	end
end
hook.Add("EntityTakeDamage", "ShieldGuardeningMA",  ShieldGuarding )

function Parry( target, dmginfo )
	if (  target:IsPlayer() and target:GetNWBool("MAParryFrame") == true and target:Alive()  ) then
		if ( dmginfo:IsDamageType(4) or dmginfo:IsDamageType(128) or dmginfo:IsDamageType(1) ) then
			local wep = target:GetActiveWeapon()
			--target:SetNWInt( 'MeleeArts2Stamina', math.floor(target:GetNWInt( 'MeleeArts2Stamina' )-wep.BlockStamina) )
			target:EmitSound("physics/metal/metal_grate_impact_hard3.wav")
			wep.Charge=wep.DmgMax
			
			dmginfo:ScaleDamage(0)
		end
	end
end
hook.Add("EntityTakeDamage", "ParryingMA",  Parry )

function RobertoDie( victim, inflictor, attacker )
	if SERVER and victim:GetNWBool("MeleeArtArmoredWarrior") == true then
		victim:EmitSound("roberto.mp3")
		victim:SetModelScale(1)
		victim:SetNWBool("MeleeArtArmoredWarrior",false)
	end
end
hook.Add("PlayerDeath", "RobertoMA",  RobertoDie )

function RobertoWalk( ply, pos, foot, sound, volume, rf )
	if (ply:GetNWBool("MeleeArtArmoredWarrior") == true) then
		local i = math.random(1)
		i = math.random(1,6)
		if i == 1 then
			ply:EmitSound( "npc/metropolice/gear1.wav" ) 
			elseif i == 2 then
			ply:EmitSound( "npc/metropolice/gear2.wav" ) 
			elseif i == 3 then
			ply:EmitSound( "npc/metropolice/gear3.wav" ) 
			elseif i == 4 then
			ply:EmitSound( "npc/metropolice/gear4.wav" ) 
			elseif i == 5 then
			ply:EmitSound( "npc/metropolice/gear5.wav" ) 
			elseif i == 6 then
			ply:EmitSound( "npc/metropolice/gear6.wav" ) 
		end
		return true -- Don't allow default footsteps
	end
end

hook.Add("PlayerFootstep", "Robert2MA",  RobertoWalk )

function RobertoDMG( target, dmginfo )
	if (  target:IsPlayer() and target:GetNWBool("MeleeArtArmoredWarrior") == true and target:Alive()  ) then
		if ( dmginfo:IsDamageType(4) or dmginfo:IsDamageType(128) or dmginfo:IsDamageType(1) ) then
			dmginfo:ScaleDamage(0)
			local shiftstraight = dmginfo:GetAttacker():GetAngles():Forward()*200
			target:SetVelocity(shiftstraight)
			if target:GetNWBool("MeleeArtStunned") == true then
				local shiftstraight2 = dmginfo:GetAttacker():GetAngles():Forward()*1000
				shiftstraight2.z = 0
				target:SetVelocity(shiftstraight2)
			end
		elseif ( dmginfo:IsDamageType(2) or dmginfo:IsDamageType(64) or dmginfo:IsDamageType(8) ) then
			dmginfo:ScaleDamage(0.05)
		elseif ( dmginfo:IsFallDamage() ) then
			dmginfo:ScaleDamage(10)	
		end
	end
end
hook.Add("EntityTakeDamage", "Robert3MA",  RobertoDMG )

function GunDumbass( target, dmginfo )
	if (  target:IsPlayer() and target:GetActiveWeapon():IsValid() and target:Alive()  ) then
		if (dmginfo:GetDamage()>=10) then
			if ( target:GetActiveWeapon():GetClass() == "meleearts_gun" and dmginfo:IsDamageType(4) or target:GetActiveWeapon():GetClass() == "meleearts_gun" and dmginfo:IsDamageType(128) ) then
				local ent = ents.Create("meleeartsthrowable")
				ent:SetModel("models/models/danguyen/handgun.mdl")
				ent:SetAngles(target:GetAimVector():Angle())
				ent:SetOwner(target)
				ent:SetNWInt( 'throwdamage', 0 )
				ent:SetNWInt( 'weaponname', "meleearts_gun" )
				ent:SetNWInt( 'impact1sound', "physics/metal/weapon_impact_hard1.wav" )
				ent:SetNWInt( 'impact2sound', "physics/metal/weapon_impact_hard2.wav" )
				ent:SetNWInt( 'hit1Sound', "physics/metal/weapon_impact_hard1.wav" )
				ent:SetNWInt( 'hit2Sound', "physics/metal/weapon_impact_hard1.wav" )
				ent:SetNWInt( 'hit3Sound', "physics/metal/weapon_impact_hard1.wav" )
				ent:SetNWInt( 'gunammo', target:GetActiveWeapon():Clip1() )
				ent:SetPos(target:GetPos() + Vector(0,0,20))
				ent:Spawn()
				ent:Activate()
				ent:GetPhysicsObject():ApplyForceCenter(target:GetAimVector() * -300)
				if target:IsValid() then
					target:StripWeapon("meleearts_gun")
					target:EmitSound("physics/metal/weapon_impact_hard3.wav")
					if target:HasWeapon( "meleearts_bludgeon_fists" ) then
						target:SelectWeapon( "meleearts_bludgeon_fists" )
					end
				end
			end
			
		end
	end
end
hook.Add("EntityTakeDamage", "GunDummyMA",  GunDumbass )

function Shoving( target, dmginfo )
	if (  target:IsPlayer() and target:GetNWBool("MeleeArtShoving") == true and target:Alive()  ) then
		if ( dmginfo:IsDamageType(4) or dmginfo:IsDamageType(128) or dmginfo:IsDamageType(1) ) then
			local wep = target:GetActiveWeapon()
			dmginfo:ScaleDamage(1.5)
		end
	end
end
hook.Add("EntityTakeDamage", "ShovingMA",  Shoving )

function DeathArts( ply )
	ply:SetNWBool("MAExpose",false)
	ply:SetNWInt( 'exposelevel', 0 )
	timer.Stop("bleedTime"..ply:GetNWInt("bleedTime"))
end
hook.Add("PlayerDeath", "DeathArtsMA",  DeathArts )

function Stunned( target, dmginfo )
	if (  target:IsPlayer() and target:GetNWBool("MeleeArtStunned") == true and target:Alive()  ) then
		if not dmginfo:IsDamageType(65536) then
			local wep = target:GetActiveWeapon()
			wep.NextStun = 0
		end
	end
end
hook.Add("EntityTakeDamage", "StunnedMA",  Stunned )
	
function NPCTest( npc, attacker, inflictor )
	if npc:GetNWBool("MABoss")==true and npc:GetActiveWeapon():IsValid() then
		if npc:GetActiveWeapon():GetClass() == "npc_cultblade" then
			local ent = ents.Create("chaosbladedrop")      
			ent:SetPos(npc:GetPos() + Vector(0,0,60))
			ent:Spawn()
			ent:Activate()
			local ent = ents.Create("chaos_hat")      
			ent:SetPos(npc:GetPos() + Vector(0,0,40))
			ent:Spawn()
			ent:Activate()
			local effectdata = EffectData() 
			effectdata:SetOrigin( npc:GetPos() + Vector( 0, 0, 40 ) ) 
			effectdata:SetNormal( npc:GetPos():GetNormal() ) 
			effectdata:SetEntity( npc ) 
			util.Effect( "darkenergyshit", effectdata )
			util.Effect( "darkenergyglow", effectdata )
			util.Effect( "darkenergybigaura", effectdata )
			npc:StopSound("spook")
			npc:SetModel("models/player/skeleton.mdl")
			npc:EmitSound("npc/combine_gunship/ping_patrol.wav")
		end
	end
end
hook.Add("OnNPCKilled", "NPCTestMA",  NPCTest )	

function BossBullet( target, dmginfo )
	if (  target:IsNPC() and target:GetNWBool("MABoss")==true and target:GetActiveWeapon():IsValid() ) then
		if ( !dmginfo:IsDamageType(4) and !dmginfo:IsDamageType(128) and !dmginfo:IsDamageType(1) and !dmginfo:IsDamageType(65536)) then
			dmginfo:ScaleDamage(0)
		end
	end
end
hook.Add("EntityTakeDamage", "BossBulletMA",  BossBullet )

function BossGuarding( target, dmginfo )
	if (  target:IsNPC() and target:GetNWBool("MAGuardening") == true and target:IsValid()  ) then
		if ( dmginfo:IsDamageType(4) or dmginfo:IsDamageType(128) ) then
			local wep = target:GetActiveWeapon()
			target:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
			dmginfo:ScaleDamage(0.3)
		elseif (dmginfo:IsDamageType(1)) then
			local wep = dmginfo:GetAttacker():GetActiveWeapon()
			target:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
			target:EmitSound("pierce.mp3")
			if wep.Strength==1 then
				dmginfo:ScaleDamage(0.25)
			elseif wep.Strength==2 then
				dmginfo:ScaleDamage(0.3)
			elseif wep.Strength==3 then
				dmginfo:ScaleDamage(0.35)
			elseif wep.Strength==4 then
				dmginfo:ScaleDamage(0.4)
			elseif wep.Strength==5 then
				dmginfo:ScaleDamage(0.45)
			elseif wep.Strength==6 then
				dmginfo:ScaleDamage(0.5)
			end
		end
	end
end
hook.Add("EntityTakeDamage", "BossGuardeningMA",  BossGuarding )

function GiveFists(ply)
	if ply:IsPlayer() and GetConVarNumber( "ma2_startwithfists" ) == 1 then
		ply:Give("meleearts_bludgeon_fists")
	end
end
hook.Add("PlayerSpawn", "GiveFistsMA", GiveFists)

function MASetSpawnInt(ply)	
	ply:SetNWInt( 'exposelevel', 0 )
end
hook.Add("PlayerSpawn", "SetSpawnIntMA", MASetSpawnInt)

	
print("Melee Arts 2 is workin... somewhat!?")
	
	

	

