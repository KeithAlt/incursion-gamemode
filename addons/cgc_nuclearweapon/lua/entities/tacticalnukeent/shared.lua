AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Nuke"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.NuclearCooldown = 120 -- The amount of time until another nuke can be launched
ENT.Radius = 6500 -- Inside radius
ENT.OuterRadius = 8000 -- Those who are inside the explode radius but not close enough to be killed.
ENT.ExplodeTimer = 38 -- Make sure this is the same as the one in cl_nucleartimer
ENT.FalloutZoneRadius = 8000 --  Outer radius where the debuffs will be applied.
ENT.AreaTimer = 360 -- In seconds, how long the linger effects should stay.
ENT.AreaCheckTime = 3 -- Every 6 seconds it applies the debuffs,

if SERVER then
    function ENT:Initialize( )
        self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetNoDraw( true )
        self:SetSolid( 1 )
        self:DrawShadow( false )
        local phys = self:GetPhysicsObject( )

        if ( phys:IsValid( ) ) then
            phys:Wake( )
        end

		local smoke = ents.Create("gb_sviolet")
		smoke:Spawn()
		smoke:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		smoke:SetModelScale(0.5)
		smoke:SetPos(self:GetPos() + Vector(0,5))
		smoke:SetAngles(Angle(90,0))
		smoke:GetPhysicsObject():EnableMotion(false)
		smoke:Arm()

        timer.Simple( self.ExplodeTimer, function( )
			if IsValid( smoke ) then
				smoke:Remove()
			end

            if IsValid( self ) then
                self:Explode( )
            end
        end )
    end

    function ENT:Explode( )
        for k, v in pairs( player.GetAll( ) ) do
            if IsValid( v ) and v:Alive( ) then
                v:SendLua("surface.PlaySound('weapons/fatman/reload/kawaiidesu.wav')")
            end
        end

        -- Delay to create the "effect" of the nuke detonating.
        timer.Simple( 1.5, function( )
            for k, v in pairs( ents.FindInSphere( self:GetPos( ), self.Radius ) ) do
                if v:IsPlayer( ) then
                    if v:GetNoDraw( ) then continue end -- Don't kill anyone that is hidden in no clip.
                    v:Kill( )
                end
            end

            local nukespot = self:GetPos( ) -- Save the position for the timer.
            local radius = self.FalloutZoneRadius -- Save the radius for the timer.

            timer.Create( "FalloutZone_Nuclear", self.AreaCheckTime, 0, function( )
                for k, v in pairs( ents.FindInSphere( nukespot, radius ) ) do
                    if IsValid( v ) and v:IsPlayer( ) and v:Alive( ) then
                        v:EnterNuclearZone() -- See sv_net for meta function.
                    end
                end
            end )

            timer.Simple(self.AreaTimer, function()
                timer.Remove( "FalloutZone_Nuclear" )
            end)

            self:Remove( )
        end )

        local effectdata = EffectData( )
        effectdata:SetMagnitude( 3 )
        effectdata:SetOrigin( self:GetPos( ) )
        effectdata:SetScale( .01 )
        util.Effect( "nuke_effect_ground_l", effectdata )
		util.Effect( "nuke_effect_ground_l", effectdata )
        util.Effect( "nuke_blastwave_l", effectdata )

		-- This is not very clean. Fuck you.
		timer.Simple(3, function()
			local fog = ents.Create("edit_fog")
			fog:SetPos(Vector(0,0,0))
			fog:Spawn()
			fog:SetFogColor(Vector(-10000,-10000))
			fog:SetFogStart(0)
			fog:SetFogEnd(1000)
			fog:SetDensity(1)
			fog:SetNoDraw(true)
			fog:SetNotSolid(true)
			fog:GetPhysicsObject():EnableMotion(false)

			timer.Simple(161, function()
				if IsValid(fog) then
					fog:Remove()
				end
			end)
		end)
    end
end
