if not CLIENT then return end
local NukeEvent = false
local time = 40
local DrawAsh = false
local ashTime = 160
local sirensound = Sound( "music/nuke_scn_main.ogg" ) -- Sound while the timer is going down.
local explodesound = Sound( "fo_sfx/explosion/fx_explosion_nukebig_demo.ogg" ) -- Explode sound after timer.
local nukemat = Material( "nukeimage.png", "smooth" )

net.Receive( "Nuclear_VGUI", function( )
    local ply = net.ReadEntity( )
    if not IsValid( ply ) then return end
    local ogtime = time
    NukeEvent = true
    surface.PlaySound( sirensound )

	LocalPlayer():ScreenFade( SCREENFADE.IN, Color(255,255,200,25), 0.25, 0.5 )

    timer.Create( "timesetter", 0.1, time * 10, function( )
        time = time - 0.1

        -- Doesn't work with 0 for some reason.
        if time <= 0.1 and NukeEvent then
			NukeEvent = false

			LocalPlayer():ScreenFade( SCREENFADE.IN, Color(255,255,255,200), 3, 5 )
			surface.PlaySound("fo_sfx/explosion/grenade/concussion/fx_explosion_grenade_concussion.ogg")
			util.ScreenShake(LocalPlayer():GetPos(), 1000, 1000, 10, 1000)

            timer.Simple( .5, function( )
                DrawAsh = true
                time = ogtime -- reset back to original time to prevent sound bug with surface.playsound
				LocalPlayer():ConCommand("pp_dof 1") -- Enable depth of field
				LocalPlayer():ConCommand("pp_dof_initlength 1000")
				--LocalPlayer():ConCommand("pp_sharpen 1") -- Enable pp_sharpen
				ParticleEffectAttach("or_nebulea_big_0x5", PATTACH_POINT_FOLLOW, LocalPlayer(), 0)

				timer.Simple(1, function()
					surface.PlaySound( explodesound )
					surface.PlaySound("ambient/explosions/battle_loop2.wav")
				end)

                timer.Simple( ashTime, function( )
					RunConsoleCommand( "stopsound" )

					timer.Simple(0.1, function()
						surface.PlaySound("fo_tracks/areas/scr/mus_scr_goodspringsstinger.ogg")
					end)

					LocalPlayer():ConCommand("pp_dof 0") -- Disable depth of field
					--LocalPlayer():ConCommand("pp_sharpen 0") -- Disable sharpen
					chat.AddText(Color(255, 150, 0), "The nuclear ashes begin to fade . . .")
					LocalPlayer():ScreenFade( SCREENFADE.IN, Color(0,0,0, 255), 5, 3 )
					LocalPlayer():StopParticles()
					DrawAsh = false
                end )
            end )
        end
    end )
end )

local screenH = ( ScrH( ) / 1080 )

local function DrawNuclearTimer( )
    surface.SetDrawColor( 233, 233, 233, 255 )
    surface.SetMaterial( nukemat )
    surface.DrawTexturedRectRotated( 130 * screenH, 125 * screenH, 250 * screenH, 250 * screenH, CurTime( ) % 360 * 28 )
    surface.SetTextPos( 75 * screenH, 250 * screenH )
    surface.SetTextColor( 255, 255, 0 )
    surface.SetFont( "TrmR_Medium" )
    surface.DrawText( "0:" .. math.Round( time, 2 ) )
end

hook.Add( "HUDPaint", "nukeEventHUD", function( )
    if NukeEvent then
        DrawNuclearTimer( )
    end
end )

local tab = {
    ["$pp_colour_addr"] = 0.2,
    ["$pp_colour_addg"] = 0.1,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 3,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0.02,
    ["$pp_colour_mulb"] = 0
}

hook.Add( "RenderScreenspaceEffects", "OrangeyLookAfterNuke", function( )
    if DrawAsh then
        DrawColorModify( tab )
    end
end )
