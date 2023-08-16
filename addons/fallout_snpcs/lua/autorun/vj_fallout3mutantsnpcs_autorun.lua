/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "[VJ] Fallout 3 Mutant SNPCs"
local AddonName = "[VJ] Fallout 3 Mutant SNPCs"
local AddonType = "SNPCs"
local AutorunFile = "autorun/vj_as_autorun.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	local vCat = "Fallout 3" -- Category, you can also set a category individually by replacing the vCat with a string value
	
	VJ.AddNPC("Yaoguai","npc_vj_fallout_yaoguai",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Supermutant Behemoth","npc_vj_fallout_supermutant_behemoth",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Giantant","npc_vj_fallout_giantant",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Giantantqueen","npc_vj_fallout_giantantqueen",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Bighorner","npc_vj_fallout_bighorner",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Brahmin","npc_vj_fallout_brahmin",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Molerat","npc_vj_fallout_molerat",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Nightstalker","npc_vj_fallout_nightstalker",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Giantrat","npc_vj_fallout_giantrat",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Coyote","npc_vj_fallout_coyote",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Dog","npc_vj_fallout_dog",vCat) -- Adds a NPC to the spawnmenu
    VJ.AddNPC("Mongrel","npc_vj_fallout_mongrel",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Vicious Dog","npc_vj_fallout_viciousdog",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Brahminpack","npc_vj_fallout_brahminpack",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Brahminwater","npc_vj_fallout_brahminwater",vCat) -- Adds a NPC to the spawnmenu
	
	
	
	-- ConVars --
	VJ.AddConVar("vj_zum_zummy_h",100) -- Example 1
	VJ.AddConVar("vj_zum_zummy_d",20) -- Example 2

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