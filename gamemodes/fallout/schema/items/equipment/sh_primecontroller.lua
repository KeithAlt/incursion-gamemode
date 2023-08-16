ITEM.name = "Liberty Prime Deployment Controller"
ITEM.model = "models/sd_fallout4/terminal1.mdl"
ITEM.desc = "WARNING: This item has use-rules! | This item can only be used once per-day by the Brotherhood of Steel | Liberty Prime can be used in all forms of hostiltiies except for wars or conquests | No more than one Liberty Prime can be deployed at once | This item allows you to become Democracy itself | Liberty Prime is OPTIONAL KOS, but cannot attack without being attacked first"

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		local ply = item.player
		local data = {}
			data.filter = ply

			for primeIndex, primeEnt in pairs(ents.FindByClass("npc_vj_fo3bhs_libertyprime")) do
				if IsValid(primeEnt) then
					primeEnt:Remove()
				end
			end

			ply:falloutNotify("Preparing Liberty Prime...", "shelter/sfx/emergency_fail.ogg")
			jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "You will spawn as Liberty Prime in 9 seconds", Color(255,255,255), "\n· Go some where wide & open")

			jlib.AlertStaff(jlib.SteamIDName(ply) .. " has used the Liberty Prime deployment & controller item") -- Staff logging

			timer.Simple(9, function()
				if IsValid(ply) then
					ply:SetNoDraw(true)
					ply:SetPos(ply:GetPos() + Vector(0,0,50)) -- Stuck/death prevention
					pk_pills.apply(ply, "sk_liberty_prime_pill", "lock-life")
					
					// Pill doesn't set hp for some reason, manually setting.
					timer.Simple(0, function()
						ply:SetHealth(150000)
						ply:SetMaxHealth(150000)
					end)

					for plyIndex, player in pairs(player.GetAll()) do
						player:SendLua("sound.Play('npc/libertyprime/mq11_mq11primeactivationli_00071ef7_1.mp3', LocalPlayer():GetPos() + Vector(1300,500,1300), 95, 100, 1)")
					end

					jlib.Announce(ply, Color(155,155,255), "[LIBERTY PRIME] ", Color(255,155,155), "Information:", Color(255,255,255),
 						"\n· Prime is optional-KOS" ..
 						"\n· Prime cannot attack without being first attacked" ..
 						"\n· Prime cannot be deployed during a war or conquest" ..
 						"\n· Prime may remain deployed until death or staff intervention"
					)

					ply:EmitSound("npc/libertyprime/mq11_mq11primeactivationli_00071ef7_1.mp3")
				end
			end)
	end,
}
