if not SERVER then return end
util.AddNetworkString( "Nuclear_VGUI" )

local FalloutZone = FalloutZone or { }
local plyMeta = FindMetaTable( "Player" )

FalloutZone.debuffTime = 30

function plyMeta:EnterNuclearZone( )
    if self.ZoneDebuff then return end
    if self:GetNoDraw() then return end -- We don't want noclipped players to be affected.

	self:ScreenFade( SCREENFADE.IN, Color(255,255,200,25), 0.25, 0.5 )
	self:addRadsUpdate(15)
    self:BuffStat( "E", -7, FalloutZone.debuffTime )
    self:BuffStat( "P", -7, FalloutZone.debuffTime )
    self:BuffStat( "S", -7, FalloutZone.debuffTime )
    self:BuffStat( "A", -7, FalloutZone.debuffTime )
    self.ZoneDebuff = true
	jlib.Announce( self, Color(255, 150, 0), "You suffer fatigue from the nuclear fallout in the area . . ." )

    timer.Create( "FalloutZoneDebuff" .. self:SteamID64( ), FalloutZone.debuffTime, 1, function( )
        if IsValid( self ) and self.ZoneDebuff then
            self.ZoneDebuff = false
        end
    end )
end

hook.Add( "PlayerDeath", "ResetFalloutDebuff", function( ply )
    if ply.ZoneDebuff then
        ply.ZoneDebuff = false
        timer.Remove( "FalloutZoneDebuff" .. ply:SteamID64( ) )
    end
end )
