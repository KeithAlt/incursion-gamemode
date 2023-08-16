AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString( "Popcorn_Explosion" )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( true )
	timer.Simple(5, function()
		self:Remove()
	end
		)

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end
end

local break_sounds = {
	Sound("physics/cardboard/cardboard_box_impact_hard1.wav"),
	Sound("physics/cardboard/cardboard_box_impact_hard2.wav"),
	Sound("physics/cardboard/cardboard_box_impact_hard3.wav"),
	Sound("physics/cardboard/cardboard_box_impact_hard4.wav"),
	Sound("physics/cardboard/cardboard_box_impact_hard5.wav"),
	Sound("physics/cardboard/cardboard_box_impact_hard6.wav"),
	Sound("physics/cardboard/cardboard_box_impact_hard7.wav")
}
