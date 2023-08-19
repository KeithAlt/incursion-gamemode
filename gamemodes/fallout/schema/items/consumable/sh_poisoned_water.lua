ITEM.name = "Purified Water" -- Concealed poison
ITEM.category = "Consumable"
ITEM.desc = "A bottle of purified water ."
ITEM.model = "models/mosi/fallout4/props/drink/water.mdl"
ITEM.price = 100

ITEM.functions.Use = {
	onRun = function(item)
		local ply = item.player

		ply:EmitSound("ui/drink.wav")
		ply:falloutNotify("✚ The cold beverage refreshes & energizes you!", "ui/notify.mp3")
		ply:AddThirst(35)

		timer.Simple(60, function()
		if ply.poisoned then return end
			ply:falloutNotify("✚ You've been poisoned", "fx/fx_poison_stinger.mp3")
			ply:ScreenFade(SCREENFADE.OUT, Color(255,255,255), 2, 3)
			ply:EmitSound("npc/barnacle/barnacle_digesting2.wav")
			ParticleEffectAttach( "mr_acid_trail", PATTACH_POINT_FOLLOW, ply, 3)
			ply.poisoned = true

			timer.Simple(2, function()
				if IsValid(ply) then
					ply:EmitSound("fx/fx_flinder_body_head03.wav")
					ply:ConCommand("say /it The man lies on the ground, suffocated from a strange acidic liquid . . .")
					ply:StopParticles()
					ply.poisoned = nil

					if ply:Alive() then
						ply:Kill()
					end

				end
			end)

		end)
	end
}
