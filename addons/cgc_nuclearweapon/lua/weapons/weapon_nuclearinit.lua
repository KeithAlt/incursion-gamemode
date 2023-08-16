SWEP.PrintName = "Nuclear Strike"
SWEP.Category = "Claymore Gaming"
SWEP.Author = "Lenny"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.AllowsAutoSwitchFrom = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.Ammo = ""
SWEP.Primary.Damage = 8000
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = true
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.NuclearCooldown = 300

SWEP.ViewModelBoneMods = {
    ["Slam_base"] = {
        scale = Vector( 0.009, 0.009, 0.009 ),
        pos = Vector( 0, 0, 0 ),
        angle = Angle( 0, 0, 0 )
    },
    ["ValveBiped.Bip01_R_Forearm"] = {
        scale = Vector( 1, 1, 1 ),
        pos = Vector( -16.852, 6.48, -1.668 ),
        angle = Angle( 0, 0, 0 )
    }
}

function SWEP:PrimaryAttack( )
	local ply = self:GetOwner( )

	if timer.Exists("nuclearBombCoolDown") then
		jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "A nuclear strike has been deployed to recently!\n· Please wait ", Color(255,255,0), tostring(math.Round(timer.TimeLeft("nuclearBombCoolDown"))), Color(255,155,155),  " seconds")
		ply:EmitSound("npc/turret_floor/click1.wav")
		return
	end

    if not IsFirstTimePredicted( ) then return end -- don't want several nukes to show.
    local location = ply:GetEyeTrace( ).HitPos

    if SERVER then
		ply:EmitSound("npc/turret_floor/ping.wav")
		ply:SendLua("surface.PlaySound('fallout/orbit/standby.wav')")
        ply:StripWeapon( self:GetClass( ) ) -- remove the weapon
		DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) has deployed a nuclear strike on the map", "☢️ Nuclear Strike Log ☢️" , Color(255,0,0), "BTeam")

		-- Warning siren for all players
		BroadcastLua("sound.Play('orbital_alert.ogg', LocalPlayer():GetPos() + Vector(15,150,15), 125, 65, 1.5)")
		jlib.falloutNotifyAll("☢ A strange sound echos in the air . . .")

		timer.Simple(9, function()
			jlib.Announce(player.GetAll(), Color(255,0,0), "[WARNING] ", Color(255,155,155), "A", Color(255,255,0), " Nuclear Strike ", Color(255,155,155), "has been deployed!")
			DiscordEmbed("A nuclear missile has been launched and is heading towards the wasteland. May God have mercy on the souls of it's victims.", "💥 NUCLEAR DETONATION ALERT 💥", Color(255,255,0), "IncursionChat")

	        local nuke = ents.Create( "tacticalnukeent" ) -- create nuke where we are looking
	        nuke:SetPos( location + Vector(0, 0, 20))
	        nuke:Spawn()
	        nuke:Activate()

	        net.Start( "Nuclear_VGUI" )
	            net.WriteEntity(ply)
	        net.Broadcast()
		end)

		timer.Create("nuclearBombCoolDown", self.NuclearCooldown, 0, function()
			timer.Remove("nuclearBombCoolDown")
 		end)

	else
		-- Blank to prevent clicking sound
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if IsValid(self) and IsValid(self:GetOwner()) then
        local data = EffectData()
        data:SetOrigin(self:GetOwner():GetEyeTrace().HitPos)
        util.Effect( "CommandPointer", data )
    end
end
