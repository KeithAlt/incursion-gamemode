local tmpsp = game.SinglePlayer()
local gas_cl_enabled = GetConVar("cl_tfa_fx_gasblur")
local gas_sv_enabled = GetConVar("sv_tfa_fx_gas_override")

local l_FT = FrameTime
local l_mathClamp = math.Clamp
local sv_cheats_cv = GetConVar("sv_cheats")
local host_timescale_cv = GetConVar("host_timescale")
local ft = 0.01
local LastSys

local SoundChars = {
	["*"] = "STREAM",--Streams from the disc and rapidly flushed; good on memory, useful for music or one-off sounds
	["#"] = "DRYMIX",--Skip DSP, affected by music volume rather than sound volume
	["@"] = "OMNI",--Play the sound audible everywhere, like a radio voiceover or surface.PlaySound
	[">"] = "DOPPLER",--Left channel for heading towards the listener, Right channel for heading away
	["<"] = "DIRECTIONAL",--Left channel = front facing, Right channel = read facing
	["^"] = "DISTVARIANT",--Left channel = close, Right channel = far
	["("] = "SPATIALSTEREO_LOOP",--Position a stereo sound in 3D space; broken
	[")"] = "SPATIALSTEREO",--Same as above but actually useful
	["}"] = "FASTPITCH",--Low quality pitch shift
	["$"] = "CRITICAL",--Keep it around in memory
	["!"] = "SENTENCE",--NPC dialogue
	["?"] = "USERVOX"--Fake VOIP data; not that useful
}
local DefaultSoundChar = ")"

local SoundChannels = {
	["shoot"] = CHAN_WEAPON,
	["shootwrap"] = CHAN_STATIC,
	["misc"] = CHAN_AUTO
}

function TFA.PatchSound( path, kind )
	local pathv
	local c = string.sub(path,1,1)

	if SoundChars[c] then
		pathv = string.sub( path, 2, string.len(path) )
	else
		pathv = path
	end

	local kindstr = kind
	if not kindstr then
		kindstr = DefaultSoundChar
	end
	if string.len(kindstr) > 1 then
		local found = false
		for k,v in pairs( SoundChars ) do
			if v == kind then
				kindstr = k
				found = true
				break
			end
		end
		if not found then
			kindstr = DefaultSoundChar
		end
	end

	return kindstr .. pathv
end

function TFA.AddFireSound( id, path, wrap, kindv )
	kindv = kindv or ")"
	if isstring(path) then
		sound.Add({
			name = id,
			channel = wrap and SoundChannels.shootwrap or SoundChannels.shoot,
			volume = 1.0,
			level = 120,
			pitch = { 97, 103 },
			sound = TFA.PatchSound( path, kindv )
		})
	elseif istable(path) then
		local tb = table.Copy( path )
		for k,v in pairs(tb) do
			tb[k] = TFA.PatchSound( v, kindv )
		end
		sound.Add({
			name = id,
			channel = wrap and SoundChannels.shootwrap or SoundChannels.shoot,
			volume = 1.0,
			level = 120,
			pitch = { 97, 103 },
			sound = tb
		})
	end
end

function TFA.AddWeaponSound(id,path,kindv)
	kindv = kindv or ")"
	if isstring(path) then
		sound.Add({
			name = id,
			channel = SoundChannels.misc,
			volume = 1.0,
			level = 80,
			pitch = { 97, 103 },
			sound = TFA.PatchSound( path, kindv )
		})
	elseif istable(path) then
		local tb = table.Copy( path )
		for k,v in pairs(tb) do
			tb[k] = TFA.PatchSound( v, kindv )
		end
		sound.Add({
			name = id,
			channel = SoundChannels.misc,
			volume = 1.0,
			level = 80,
			pitch = { 97, 103 },
			sound = tb
		})
	end
end

local AmmoTypes = {}

function TFA.AddAmmo( id, name )
	if AmmoTypes[name] then return AmmoTypes[name] end
	AmmoTypes[name] = id

	game.AddAmmoType( {
		name  = id
	})

	if language then
		language.Add( id .. "_ammo", name )
	end

	return id
end

hook.Add("Think","TFAFrameTimeThink",function()
	ft = (SysTime() - (LastSys or SysTime())) * game.GetTimeScale()

	if ft > l_FT() then
		ft = l_FT()
	end

	ft = l_mathClamp(ft, 0, 1 / 30)

	if sv_cheats_cv:GetBool() and host_timescale_cv:GetFloat() < 1 then
		ft = ft * host_timescale_cv:GetFloat()
	end

	LastSys = SysTime()
end)

function TFA.FrameTime()
	return ft
end

function TFA.GetGasEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_gasblur", 0)) ~= 0 end
	local enabled

	if gas_cl_enabled then
		enabled = gas_cl_enabled:GetBool()
	else
		enabled = false
	end

	if gas_sv_enabled and gas_sv_enabled:GetInt() ~= -1 then
		enabled = gas_sv_enabled:GetBool()
	end

	return enabled
end

local ejectionsmoke_cl_enabled = GetConVar("cl_tfa_fx_ejectionsmoke")
local ejectionsmoke_sv_enabled = GetConVar("sv_tfa_fx_ejectionsmoke_override")
local muzzlesmoke_cl_enabled = GetConVar("cl_tfa_fx_muzzlesmoke")
local muzzlesmoke_sv_enabled = GetConVar("sv_tfa_fx_muzzlesmoke_override")

function TFA.GetMZSmokeEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_muzzlesmoke", 0)) ~= 0 end
	local enabled

	if muzzlesmoke_cl_enabled then
		enabled = muzzlesmoke_cl_enabled:GetBool()
	else
		enabled = false
	end

	if muzzlesmoke_sv_enabled and muzzlesmoke_sv_enabled:GetInt() ~= -1 then
		enabled = muzzlesmoke_sv_enabled:GetBool()
	end

	return enabled
end

function TFA.GetEJSmokeEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_ejectionsmoke", 0)) ~= 0 end
	local enabled

	if ejectionsmoke_cl_enabled then
		enabled = ejectionsmoke_cl_enabled:GetBool()
	else
		enabled = false
	end

	if ejectionsmoke_sv_enabled and ejectionsmoke_sv_enabled:GetInt() == 0 then
		enabled = ejectionsmoke_sv_enabled:GetBool()
	end

	return enabled
end

local ricofx_cl_enabled = GetConVar("cl_tfa_fx_impact_ricochet_enabled")
local ricofx_sv_enabled = GetConVar("sv_tfa_fx_ricochet_override")

function TFA.GetRicochetEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_impact_ricochet_enabled", 0)) ~= 0 end
	local enabled

	if ricofx_cl_enabled then
		enabled = ricofx_cl_enabled:GetBool()
	else
		enabled = false
	end

	if ricofx_sv_enabled and ricofx_sv_enabled:GetInt() ~= -1 then
		enabled = ricofx_sv_enabled:GetBool()
	end

	return enabled
end

--Local function for detecting TFA Base weapons.
function TFA.PlayerCarryingTFAWeapon(ply)
	if not ply then
		if CLIENT then
			if IsValid(LocalPlayer()) then
				ply = LocalPlayer()
			else
				return false, nil, nil
			end
		elseif game.SinglePlayer() then
			ply = Entity(1)
		else
			return false, nil, nil
		end
	end

	if not (IsValid(ply) and ply:IsPlayer() and ply:Alive()) then return end
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) then
		if (wep.IsTFAWeapon) then return true, ply, wep end

		return false, ply, wep
	end

	return false, ply, nil
end
