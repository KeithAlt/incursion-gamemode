if SERVER then AddCSLuaFile() end

MAWoundage = {}
MAWoundage.Effects = {
	["cripple"] = {
		["string"] = "Cripple",
		["function"] =
			function(target, attacker, effect, chance)
				if target:IsPlayer() then
					local w = math.random(1)
					w = math.random(1,chance)
					if w == 1 then
						local wep = target:GetActiveWeapon()
						wepCheck = string.find( wep:GetClass(), "meleearts" )
						if wepCheck then
							if wep:GetClass()=="meleearts_bludgeon_fists" or wep.CanThrow==false then return end
							target:PrintMessage(HUD_PRINTCENTER,"You've been disarmed!")
							local ent = ents.Create("meleeartsthrowable")
							ent:SetModel(wep.ThrowModel)
							ent:SetAngles(target:GetAimVector():Angle())
							ent:SetOwner(target)
							ent:SetNWInt( 'throwdamage', 0 )
							ent:SetNWInt( 'weaponname', wep.WepName )
							ent:SetNWInt( 'impact1sound', wep.Impact1Sound )
							ent:SetNWInt( 'impact2sound', wep.Impact2Sound )
							ent:SetNWInt( 'hit1Sound', wep.Impact1Sound )
							ent:SetNWInt( 'hit2Sound', wep.Impact2Sound )
							ent:SetNWInt( 'hit3Sound', wep.Impact1Sound )
							ent:SetPos(target:GetPos() + Vector(0,0,20))
							ent:Spawn()
							ent:Activate()
							ent:GetPhysicsObject():ApplyForceCenter(attacker:GetAimVector() * 300)
							if target:IsValid() then
								target:StripWeapon(wep.WepName)
								target:EmitSound("physics/metal/weapon_impact_hard3.wav")
								if target:HasWeapon( "meleearts_bludgeon_fists" ) then
									target:SelectWeapon( "meleearts_bludgeon_fists" )
								end
							end
						end
					end
				end
			end
		},
	["expose"] = {
		["string"] = "Expose",
		["function"] =
			function(target, attacker, effect, level)
				if target:IsPlayer() then
					target:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 128 ), 0.5, 0 )
				end
				target:SetNWBool("MAExpose",true)
				target:SetNWInt( 'exposelevel', level )
			end
		},
	["bleed"] = {
		["string"] = "Bleed",
		["function"] =
			function(target, attacker, effect, duration, damage)
				--if !(target:IsPlayer() or target:IsNPC()) then return false end
				randomInt = math.random( 1, 500 )
				if target:IsPlayer() then
					target:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0, 128 ), 0.3, 0 )
				end
				target:SetNWInt("bleedTime",randomInt)
				timer.Create("bleedTime"..randomInt, 1,duration, function()
					if IsValid(target) and target:Health()>1 then
						local d = DamageInfo()
						d:SetDamage( damage )
						if IsValid(attacker) then
							if attacker:IsPlayer() then
								d:SetAttacker( attacker )
							end
						end
						d:SetDamageType( 65536 )
						target:TakeDamageInfo(d)
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then  
							local effectdata = EffectData() 
							local blood = target:GetBloodColor()
							effectdata:SetColor(blood)
							effectdata:SetOrigin( target:GetPos() + Vector(0,0,30) ) 
							effectdata:SetNormal( target:GetPos():GetNormal() ) 
							effectdata:SetEntity( target ) 
							if target:GetBloodColor()==0 then
								util.Effect( "bleedingsplat", effectdata )
							else
								util.Effect( "bleedingyellow", effectdata )
							end
						end
					else
						if IsValid(target) then
							target:SetHealth(1)
						end
					end
				end)
			end 
		},
}

function MAWoundage:AddStatus(target, attacker, type, a, b, c)
	if target:IsPlayer() or target:IsNPC() then
		MAWoundage.Effects[type]["function"](target, attacker, c, a, b)
	end
end