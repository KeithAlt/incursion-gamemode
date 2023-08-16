include("pac3/core/shared/libraries/luadata.lua")
include("hands.lua")
include("pac_weapon.lua")
include("modifiers.lua")
include("footsteps_fix.lua")
include("projectiles.lua")
include("boneanimlib.lua")

local cvar = CreateConVar("pac_restrictions", "0", FCVAR_REPLICATED)

function pac.GetRestrictionLevel()
	return cvar:GetInt()
end

function pac.SimpleFetch(url,cb,failcb)
	if not url or url:len()<4 then return end

	url = pac.FixupURL(url)

	http.Fetch(url,
	function(data,len,headers,code)
		if code~=200 then
			Msg"[PAC] Url "print(string.format("failed loading %s (server returned %s)",url,tostring(code)))
			if failcb then
				failcb(code,data,len,headers)
			end
			return
		end
		cb(data,len,headers)
	end,
	function(err)
		Msg"[PAC] Url "print(string.format("failed loading %s (%s)",url,tostring(err)))
		if failcb then
			failcb(err)
		end
	end)
end

CreateConVar("pac_sv_draw_distance", 0, bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE))
CreateConVar("pac_sv_hide_outfit_on_death", 0, bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE))

do
	local tohash = {
		-- Crash
		'weapon_unusual_isotope.pcf',

		-- Invalid
		'blood_fx.pcf',
		'boomer_fx.pcf',
		'charger_fx.pcf',
		'default.pcf',
		'electrical_fx.pcf',
		'environmental_fx.pcf',
		'fire_01l4d.pcf',
		'fire_fx.pcf',
		'fire_infected_fx.pcf',
		'firework_crate_fx.pcf',
		'fireworks_fx.pcf',
		'footstep_fx.pcf',
		'gen_dest_fx.pcf',
		'hunter_fx.pcf',
		'infected_fx.pcf',
		'insect_fx.pcf',
		'item_fx.pcf',
		'locator_fx.pcf',
		'military_artillery_impacts.pcf',
		'rain_fx.pcf',
		'rain_storm_fx.pcf',
		'rope_fx.pcf',
		'screen_fx.pcf',
		'smoker_fx.pcf',
		'speechbubbles.pcf',
		'spitter_fx.pcf',
		'steam_fx.pcf',
		'steamworks.pcf',
		'survivor_fx.pcf',
		'tank_fx.pcf',
		'tanker_explosion.pcf',
		'test_collision.pcf',
		'test_distancealpha.pcf',
		'ui_fx.pcf',
		'vehicle_fx.pcf',
		'water_fx.pcf',
		'weapon_fx.pcf',
		'witch_fx.pcf'
	}

	pac.BlacklistedParticleSystems = {}

	for i, val in ipairs(tohash) do
		pac.BlacklistedParticleSystems[val] = true
	end
end
