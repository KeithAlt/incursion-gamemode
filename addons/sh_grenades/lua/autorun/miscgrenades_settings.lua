if (SERVER) then
	AddCSLuaFile()
	AddCSLuaFile("healgrenade_config.lua")
	AddCSLuaFile("electricgrenade_config.lua")
	AddCSLuaFile("percussiongrenade_config.lua")
	AddCSLuaFile("smokegrenade_config.lua")
end

include("healgrenade_config.lua")
include("electricgrenade_config.lua")
include("percussiongrenade_config.lua")
include("smokegrenade_config.lua")

MISCGRENADES_SETTINGS = {
	-- Use Steam Workshop instead of FastDL for content?
	UseWorkshop = false,
}

/** if (SERVER) then
	if (MISCGRENADES_SETTINGS.UseWorkshop) then
		resource.AddWorkshop("776355104")
	else
		-- don't need the spawnmenu icon if we're playing TTT
		if (engine.ActiveGamemode() ~= "terrortown") then
			resource.AddSingleFile("materials/entities/weapon_sh_electricgrenade.png")
			resource.AddSingleFile("materials/entities/weapon_sh_healgrenade.png")
			resource.AddSingleFile("materials/entities/weapon_sh_percussiongrenade.png")
			resource.AddSingleFile("materials/entities/weapon_sh_smokegrenade.png")

			resource.AddSingleFile("materials/weapons/weapon_sh_electricgrenade.vmt")
			resource.AddSingleFile("materials/weapons/weapon_sh_electricgrenade.vtf")
			resource.AddSingleFile("materials/weapons/weapon_sh_healgrenade.vmt")
			resource.AddSingleFile("materials/weapons/weapon_sh_healgrenade.vtf")
			resource.AddSingleFile("materials/weapons/weapon_sh_percussiongrenade.vmt")
			resource.AddSingleFile("materials/weapons/weapon_sh_percussiongrenade.vtf")
			resource.AddSingleFile("materials/weapons/weapon_sh_smokegrenade.vmt")
			resource.AddSingleFile("materials/weapons/weapon_sh_smokegrenade.vtf")
		else -- TTT specific content
			resource.AddSingleFile("materials/vgui/ttt/icon_electricgrenade.vmt")
			resource.AddSingleFile("materials/vgui/ttt/icon_electricgrenade.vtf")
			resource.AddSingleFile("materials/vgui/ttt/icon_healgrenade.vmt")
			resource.AddSingleFile("materials/vgui/ttt/icon_healgrenade.vtf")
			resource.AddSingleFile("materials/vgui/ttt/icon_percussiongrenade.vmt")
			resource.AddSingleFile("materials/vgui/ttt/icon_percussiongrenade.vtf")
			resource.AddSingleFile("materials/vgui/ttt/weapon_sh_smokegrenade.vmt")
			resource.AddSingleFile("materials/vgui/ttt/weapon_sh_smokegrenade.vtf")
		end

		resource.AddSingleFile("materials/models/weapons/v_models/eq_electricgrenade/electricgrenade.vmt")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_electricgrenade/electricgrenade.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_electricgrenade/electricgrenade_ref.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_healgrenade/healgrenade.vmt")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_healgrenade/healgrenade.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_healgrenade/healgrenade_ref.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_percussiongrenade/percussiongrenade.vmt")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_percussiongrenade/percussiongrenade.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_percussiongrenade/percussiongrenade_ref.vtf")
		resource.AddSingleFile("materials/models/weapons/w_models/w_eq_percussiongrenade/w_eq_percussiongrenade.vmt")
		resource.AddSingleFile("materials/models/weapons/w_models/w_eq_percussiongrenade/w_eq_percussiongrenade.vtf")
		resource.AddSingleFile("materials/particle/particle_smokegrenade2.vmt")
		resource.AddSingleFile("materials/particle/particle_smokegrenade.vtf")
	end
end**/
