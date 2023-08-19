
if SERVER then
	util.AddNetworkString("CopyColorToRagdoll")
end

if CLIENT then
	net.Receive( "CopyColorToRagdoll", function( len )

		local rag = net.ReadEntity()
		local clr = net.ReadVector()
		
		rag.GetPlayerColor = function() return clr end
		
	end)
end

hook.Add( "SetupMove", "HeatmanMove", function( ply, mv, cmd )
	local wep = ply:GetActiveWeapon()
	
	if wep.Base == "hmc_base" then
		if wep:GetClass() == "hmc_fiberwire" and wep:GetRagDrag() > CurTime() and IsValid(wep:GetRagdoll()) and wep:GetRagdoll() != nil then
			
			mv:SetMaxClientSpeed( ply:GetWalkSpeed()/4 )
			mv:SetSideSpeed(0)
			
			mv:SetButtons( bit.band( cmd:GetButtons(), bit.bnot( IN_JUMP + IN_DUCK ) ) )

		end
	end
	
end )

hook.Add("ScalePlayerDamage", "ScalePlayerDamage_HMC", function(Ent, hitgroup, Info)
	local Attacker = Info:GetAttacker()
	if IsValid(Attacker) and Attacker:IsPlayer() and IsValid(Attacker:GetActiveWeapon()) and Attacker:GetActiveWeapon().Base == "hmc_base" then
		if ( hitgroup == HITGROUP_HEAD ) then
			Info:ScaleDamage( 1000 )
		end
	end
end
)
hook.Add("ScaleNPCDamage", "ScaleNPCDamage_HMC", function(Ent, hitgroup, Info)
	local Attacker = Info:GetAttacker()
	if IsValid(Attacker) and Attacker:IsPlayer() and IsValid(Attacker:GetActiveWeapon()) and Attacker:GetActiveWeapon().Base == "hmc_base" then
		if ( hitgroup == HITGROUP_HEAD ) then
			Info:ScaleDamage( 1000 )
		end
	end 
end)
