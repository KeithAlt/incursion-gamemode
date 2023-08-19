/*--------------------------------------------------

	=============== Autorun File ===============

	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***

	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,

	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.

--------------------------------------------------*/

------------------ Addon Information ------------------

local PublicAddonName = "Liberty Prime SNPCs"

local AddonName = "Liberty Prime"

local AddonType = "SNPC"

local AutorunFile = "autorun/vj_libertyp_autorun.lua"

-------------------------------------------------------

local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")

if VJExists == true then
	include('autorun/vj_controls.lua')



	local vCat = "Fallout" //Fallout 3 and New Vegas



	VJ.AddNPC("Liberty Prime","npc_vj_fo3bhs_libertyprime",vCat)

	VJ.AddNPC("Hostile Liberty Prime","npc_vj_fo3ene_libertyprime",vCat)


	-- Particles --
	game.AddParticles("particles/vj_mininuke.pcf")

	local particlename = {

	-- vj_mininuke.pcf

		"vj_mininuke_explosion_fix",

		"mininuke_explosion",

		"mininuke_explosion_generic_smokestreak_parent",

		"mininuke_explosion_child_firesmoke",

		"mininuke_explosion_child_flash",

		"mininuke_explosion_child_flash_mod",

		"mininuke_explosion_child_shrapnel",

		"mininuke_explosion_child_smoke",

		"mininuke_explosion_child_sparks",

		"mininuke_explosion_child_sparks2",

		"mininuke_explosion_shrapnel_fire_child",

		"mininuke_explosion_shrapnel_smoke_child",

	}

	for _,v in ipairs(particlename) do PrecacheParticleSystem(v) end

	-- ConVars --
	VJ.AddConVar("vj_fo3_libertyprime_h",300000000)

	VJ.AddConVar("vj_fo3_libertyprime_d",250)


	-- Menu --

	local AddConvars = {}

	AddConvars["vj_fo3_lp_laserexplosionparticles"] = 1 -- Enable Liberty Prime's lasers making explosion particles?

	for k, v in pairs(AddConvars) do

		if !ConVarExists( k ) then CreateConVar( k, v, {FCVAR_ARCHIVE} ) end

	end

	if (CLIENT) then

	local function VJ_LIBERTYPRIMEMENU_MAIN(Panel)

		if !game.SinglePlayer() then

		if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then

			Panel:AddControl( "Label", {Text = "You are not an admin!"})

			Panel:ControlHelp("Notice: Only admins can change this settings.")

			return

			end

		end

		Panel:AddControl( "Label", {Text = "Notice: Only admins can change this settings."})

		local vj_fo3reset = {Options = {}, CVars = {}, Label = "Reset Everything:", MenuButton = "0"}

		vj_fo3reset.Options["#vjbase.menugeneral.default"] = {

		vj_fo3_lp_laserexplosionparticles = "1",

		}

		Panel:AddControl("ComboBox", vj_fo3reset)

		Panel:AddControl( "Label", {Text = "Extra/Realistic Features:"})

		Panel:ControlHelp("Disabling this settings can give better performance.")

		Panel:AddControl("Checkbox", {Label = "Liberty Prime lasers create particles?", Command = "vj_fo3_lp_laserexplosionparticles"})

	end

	function VJ_ADDTOMENU_LIBERTYPRIME()

		spawnmenu.AddToolMenuOption( "DrVrej", "SNPC Configures", "Liberty Prime", "Liberty Prime", "", "", VJ_LIBERTYPRIMEMENU_MAIN, {} )

	end

		hook.Add( "PopulateToolMenu", "VJ_ADDTOMENU_LIBERTYPRIME", VJ_ADDTOMENU_LIBERTYPRIME )

	end

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
