/*--------------------------------------------------

	=============== Autorun File ===============

	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***

	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,

	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.

--------------------------------------------------*/

------------------ Addon Information ------------------

local PublicAddonName = "Super Combine SNPCs"

local AddonName = "Super Combine"

local AddonType = "SNPC"

local AutorunFile = "autorun/vj_su_autorun.lua"

-------------------------------------------------------

local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")

if VJExists == true then

	include('autorun/vj_controls.lua')



	local vCat = "Super Combine"



	VJ.AddNPC_HUMAN("Courser (Hostile)","npc_vj_super combine",{"weapon_vj_institute_rifle"},vCat)

	VJ.AddNPC_HUMAN("Courser (Friendly)","npc_vj_super combinef",{"weapon_vj_institute_rifle"},vCat)

	VJ.AddNPC_HUMAN("Institute Synth (Friendly)","npc_vj_synth_f",{"weapon_vj_institute_rifle"},vCat) -- Add a human SNPC to the spawnlist

  VJ.AddNPC_HUMAN("Institute Synth (Hostile)","npc_vj_synth_h",{"weapon_vj_institute_rifle"},vCat)

  VJ.AddNPC_HUMAN("Institute Synth (Neutral)","npc_vj_synth_n",{"weapon_vj_institute_rifle"},vCat)

	VJ.AddNPCWeapon("VJ_institute_Rifle","weapon_vj_institute_rifle") -- Institute SNPC Rifle




game.AddParticles("particles/supercom.pcf")



local particlename = {

	"super_shlrd",

	"super_shrd2",

	"super_shrd3",

	"super_shrd4",

	"super_broc",

	"manhac_las",

	"combne_las",

	"super_turret",

	"super_turret_las",

	"super_turret_ready",

	"super_exp",

	"super_hover",

}

for _,v in ipairs(particlename) do PrecacheParticleSystem(v) end



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

				VJF:SetTitle("ERROR!")

				VJF:SetSize(790,560)

				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)

				VJF:MakePopup()

				VJF.Paint = function()

					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))

				end



				local VJURL = vgui.Create("DHTML",VJF)

				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)

				VJURL:Dock(FILL)

				VJURL:SetAllowLua(true)

				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")

			elseif (SERVER) then

				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)

			end

		end

	end)

end
