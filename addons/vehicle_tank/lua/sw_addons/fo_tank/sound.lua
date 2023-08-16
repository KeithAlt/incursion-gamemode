if !SW_ADDON then
	SW_Addons.AutoReloadAddon(function() end)
	return
end

sound.Add( 
{
    name = "FO_Tank_Idle",
    channel = CHAN_STATIC,
    volume = 1.0,
    soundlevel = 90,
    sound = "vehicles/sgmcars/tank_fo4/idle.wav"
} )

sound.Add( 
{
    name = "FO_Tank_Tracks",
    channel = CHAN_STATIC,
    volume = 1.0,
    soundlevel = 90,
    sound = "vehicles/sgmcars/tank_fo4/tracks.wav"
} )

sound.Add( 
{
    name = "FO_Tank_Drive",
    channel = CHAN_STATIC,
    volume = 1.0,
    soundlevel = 90,
    sound = "vehicles/sgmcars/tank_fo4/first.wav"
} )