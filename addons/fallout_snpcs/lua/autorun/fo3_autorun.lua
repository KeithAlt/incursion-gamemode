/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Fallout 3 SNPCs"
local AddonName = "Fallout 3 SNPCs"
local AddonType = "SNPC"
local AutorunFile = "autorun/fo3_autorun.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	local vCat = "Fallout 3"
	-- Mirelurk's -------------------------------------------------------------------------------------------------------------------------
	VJ.AddNPC("Mirelurk","npc_vj_fo3_mirelurk",vCat)
	VJ.AddNPC("Mirelurk King","npc_vj_fo3_mirelurk_king",vCat)
	VJ.AddNPC("Swamplurk Queen","npc_vj_fo3_mirelurk_queen",vCat)
	VJ.AddNPC("Mirelurk Hunter","npc_vj_fo3_mirelurk_hunter",vCat)
	VJ.AddNPC("Swamplurk","npc_vj_fo3_swamplurk",vCat)
	VJ.AddNPC("Nukalurk","npc_vj_fo3_nukalurk",vCat)
	VJ.AddNPC("Magmalurk","npc_vj_fo3_magmalurk",vCat)
	
	-- Radroaches -------------------------------------------------------------------------------------------------------------------------
	VJ.AddNPC("Radroach","npc_vj_fo3_radroach",vCat)
	VJ.AddNPC("Nukaroach","npc_vj_fo3_nukaroach",vCat)
	VJ.AddNPC("Glowroach","npc_vj_fo3_glowroach",vCat)
	
	-- Deathclaws -------------------------------------------------------------------------------------------------------------------------
	VJ.AddNPC("Deathclaw","npc_vj_fo3_dc_deathclaw",vCat)
	VJ.AddNPC("Enclave Deathclaw","npc_vj_fo3_dc_deathclaw_enclave",vCat)
	VJ.AddNPC("Alpha Deathclaw","npc_vj_fo3_dc_deathclaw_alpha",vCat)
	VJ.AddNPC("Baby Deathclaw","npc_vj_fo3_dc_deathclaw_baby",vCat)
	VJ.AddNPC("Deathclaw Matriarch","npc_vj_fo3_dc_deathclaw_mother",vCat)
	
	-- Feral Ghoul's -------------------------------------------------------------------------------------------------------------------------
	VJ.AddNPC("Armored Feral Ghoul","npc_vj_fo3_fg_feralghoul_armored",vCat)
	//VJ.AddNPC("Feral Ghoul Reaver","npc_vj_fo3_fg_feralghoul_reaver",vCat)
	VJ.AddNPC("Glowing One","npc_vj_fo3_fg_feralghoul_glowing",vCat)
	VJ.AddNPC("Feral Ghoul","npc_vj_fo3_fg_feralghoul",vCat)
	VJ.AddNPC("Swamp Ghoul","npc_vj_fo3_fg_feralghoul_swamp",vCat)
	VJ.AddNPC("Feral Ghoul Roamer","npc_vj_fo3_fg_feralghoul_roamer",vCat)
	VJ.AddNPC("Feral Ghoul Trooper","npc_vj_fo3_fg_feralghoul_trooper",vCat)
	VJ.AddNPC("Swamp Ghoul Trooper","npc_vj_fo3_fg_feralghoul_trooper_swamp",vCat)
	VJ.AddNPC("Glowing Trooper","npc_vj_fo3_fg_feralghoul_trooper_glowing",vCat)
	VJ.AddNPC("Feral Ghoul Roaming Trooper","npc_vj_fo3_fg_feralghoul_trooper_roaming",vCat)
	VJ.AddNPC("Robco Glowing One","npc_vj_fo3_fg_feralghoul_glowing_robco",vCat)
	VJ.AddNPC("Robco Feral Ghoul","npc_vj_fo3_fg_feralghoul_robco",vCat)
	VJ.AddNPC("Robco Swamp Ghoul","npc_vj_fo3_fg_feralghoul_swamp_robco",vCat)
	VJ.AddNPC("Robco Feral Ghoul Roamer","npc_vj_fo3_fg_feralghoul_roamer_robco",vCat)
	
	-- Radscorpion's -------------------------------------------------------------------------------------------------------------------------
	VJ.AddNPC("Giant Radscorpion","npc_vj_fo3_rs_giant_radscorpion",vCat)
	VJ.AddNPC("Albino Radscorpion","npc_vj_fo3_rs_albino_radscorpion",vCat)
	VJ.AddNPC("Bark Scorpion","npc_vj_fo3_rs_bark_scorpion",vCat)
	VJ.AddNPC("Glow Radscorpion","npc_vj_fo3_rs_glow_radscorpion",vCat)
	VJ.AddNPC("Nuka Radscorpion","npc_vj_fo3_rs_nuka_radscorpion",vCat)
	VJ.AddNPC("Radscorpion","npc_vj_fo3_rs_radscorpion",vCat)

-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("VJ Base is not installed")
				VJF:SetSize(900,800)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				local VJURL = vgui.Create("DHTML")
				VJURL:SetParent(VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				local x,y = VJF:GetSize()
				VJURL:SetSize(x*0.99,y*0.96)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end

game.AddParticles("particles/centaur_spit.pcf")
game.AddParticles("particles/glowingone.pcf")
game.AddParticles("particles/goregrenade.pcf")
game.AddParticles("particles/magmalurk_flame.pcf")
game.AddParticles("particles/radiation_shockwave.pcf")
game.AddParticles("particles/spore1.pcf")
game.AddParticles("particles/sporecarrier_glow.pcf")
game.AddParticles("particles/sporecarrier_radiation.pcf")
game.AddParticles("particles/fo3_fx.pcf")

local particlename = {
-- Centaur --
"centaur_spit",

-- Feral Ghoul --
"glowingone_testA",
"glowingone_testB",
"glowingone_testC",
"goregrenade_splash",
"radiation_shockwave",
"radiation_shockwave_debris",
"radiation_shockwave_ring",

-- Mirelurk --
"magmalurk_flame",
"magmalurk_flame_pilot",
"fo3_mirelurk_charge",
"fo3_mirelurk_pulse",
"fo3_mirelurk_hybrid",

-- Spore Carrier --
"spore_splash",
"spore_splash_02",
"spore_splash_03",
"spore_splash_05",
"spore_splash_player",
"spore_splash_player_splat",
"spore_trail",
"sporecarrier_glow",
"sporecarrier_radiation",
"sporecarrier_radiation_debris",
"sporecarrier_radiation_ring"
}
for _,v in ipairs(particlename) do PrecacheParticleSystem(v) end