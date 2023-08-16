TFA.ENUM_COUNTER = TFA.ENUM_COUNTER or 0

local function gen( input )
	local key = "STATUS_" .. string.upper( input )
	return key
end

function TFA.AddStatus( input )
	local key = gen(input)
	if not TFA.Enum[key] then
		TFA.Enum[key] = TFA.ENUM_COUNTER * 1
		TFA.ENUM_COUNTER = TFA.ENUM_COUNTER + 1
	end
end

function TFA.GetStatus( input )
	local key = gen(input)
	if not TFA.Enum[ key ] then
		TFA.AddStatus( input )
	end
	return TFA.Enum[ key ]
end

TFA.AddStatus( "idle" )
TFA.AddStatus( "draw" )
TFA.AddStatus( "holster" )
TFA.AddStatus( "holster_final" )
TFA.AddStatus( "holster_ready" )
TFA.AddStatus( "reloading" )
TFA.AddStatus( "reloading_wait" )
TFA.AddStatus( "reloading_shotgun_start" )
TFA.AddStatus( "reloading_shotgun_start_shell" )
TFA.AddStatus( "reloading_shotgun_loop" )
TFA.AddStatus( "reloading_shotgun_end" )
TFA.AddStatus( "shooting" )
TFA.AddStatus( "silencer_toggle" )
TFA.AddStatus( "bashing" )
TFA.AddStatus( "inspecting" )
TFA.AddStatus( "fidget" )

TFA.AddStatus( "pump" )

TFA.AddStatus( "grenade_pull" )
TFA.AddStatus( "grenade_ready" )
TFA.AddStatus( "grenade_throw" )

TFA.Enum.HolsterStatus = {
	[TFA.Enum.STATUS_HOLSTER] = true,
	[TFA.Enum.STATUS_HOLSTER_FINAL] = true,
	[TFA.Enum.STATUS_HOLSTER_READY] = true
}
TFA.Enum.ReloadStatus = {
	[TFA.Enum.STATUS_RELOADING] = true,
	[TFA.Enum.STATUS_RELOADING_WAIT] = true,
	[TFA.Enum.STATUS_RELOADING_SHOTGUN_START] = true,
	[TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP] = true,
	[TFA.Enum.STATUS_RELOADING_SHOTGUN_END] = true
}
TFA.Enum.ReadyStatus = {
	[TFA.Enum.STATUS_IDLE] = true,
	[TFA.Enum.STATUS_INSPECTING] = true,
	[TFA.Enum.STATUS_FIDGET] = true
}
TFA.Enum.IronStatus = {
	[TFA.Enum.STATUS_IDLE] = true,
	[TFA.Enum.STATUS_SHOOTING] = true,
	[TFA.Enum.STATUS_PUMP] = true
}