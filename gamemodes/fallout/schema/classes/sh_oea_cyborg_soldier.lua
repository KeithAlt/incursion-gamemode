CLASS.name = "OEA - Cyborg Soldier"
CLASS.faction = FACTION_TABLEOFCAPTAINS
CLASS.noHunger = true -- Immune to hunger/thirst
CLASS.fearImmune = true -- Unique class stat
CLASS.isDefault = false
CLASS.Color = Color(0, 8, 134)

if SERVER then
	function CLASS:onSpawn(ply) -- Custom spawn loadout of 'Cybog' class
		timer.Simple(0.5, function() -- Added because of default faction HP conflict issue
			if !IsValid(ply) then return end
			ply:falloutNotify("You feel your processing unit activate . . .", "npc/scanner/scanner_scan" .. math.random(1,5) .. ".wav")
			ply:SetMaxHealth(700)
			ply:SetHealth(700)
			ply:SetJumpPower(300)
			-- The two chatprints() below are done because fitting it all into one does not work
			ply:ChatPrint("[ INFORMATION ]\n- You can be hacked\n- You do not feel FearRP \n- You can only wear OEA Cyborg implant armor \n- You can jump x3 higher than the average man")
			ply:ChatPrint("- Your robotic body provides you with 9x the vitality of a man\n- You cannot wear armor that isn't labeled for cyborgs")
		end)
	end
end

CLASS_OEA_CYBORG_SOLDIER = CLASS.index
