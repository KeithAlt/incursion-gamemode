AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/Frame002a.mdl")
    self:SetModelScale(0.55,0)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	POSTER_LIST[self] = false
end

function ENT:setPlayer(charID, board)
	self:SetNW2String("posterCharID", charID)

	self.owner = charID -- fill -1 or something to make it valid (system generated.)

	if (IsValid(board)) then
		self.board = board
	end

	POSTER_LIST[self] = charID
end

function ENT:OnRemove()
	POSTER_LIST[self] = nil
end

function ENT:Use(activator, caller)
	local charID = self.owner

	if charID == tonumber(activator:getChar():getID()) then
		for board, _ in pairs(JOB_BOARD_LIST) do
			board:removeJobOf(charID)
		end
		
		activator:removeJob()
	end
end

function ENT:Think()
end

function ENT:Touch(TouchEnt)
    if self.Touched and self.Touched > CurTime() then return end
	self.Touched = CurTime() + 1
end