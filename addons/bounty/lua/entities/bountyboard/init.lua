AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( Player, tr, Class )
	if (!tr.Hit) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal* 20 + Vector(0,0,58)
	local SpawnAng = Player:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( Class )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel("models/tbfu_noticeboard/noticeboard.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
    self.posters = {}

	self:GeneratePoses()
	JOB_BOARD_LIST[self] = true
end

function ENT:OnRemove()
	JOB_BOARD_LIST[self] = nil
end

function ENT:GeneratePoses()
    self.PosterPoses = {}
	self.PosterPoses.WPoses = {}
	self.PosterPoses.Taken = {{},{}}
	for i = -4, 5 do
	    table.insert(self.PosterPoses.WPoses,i * 12)
	end
end

function ENT:GenerateID(Poster)
    local UpOrDown = math.random(1,2)
	local WID = math.random(1,#self.PosterPoses.WPoses)
	local WPos = self.PosterPoses.WPoses[WID]

	if table.HasValue(self.PosterPoses.Taken[UpOrDown], WID) then
	    //All poses taken, randomize location even if poster there
		if #self.PosterPoses.Taken[1] + #self.PosterPoses.Taken[2] >= 20 then
			return WPos, math.random(-22,22)
		else
			return self:GenerateID(Poster)
		end
	end
	table.insert(self.PosterPoses.Taken[UpOrDown], WID)
	Poster.IDs = {UpOrDown,WID}

	if UpOrDown == 1 then
	    return WPos, math.random(10,28)
	elseif UpOrDown == 2 then
	    return WPos, math.random(-10,-32)
	end
end

function ENT:removeJobOf(charID)
	for entity, targetID in pairs(self.posters) do
		if (charID == targetID) then
			self.posters[entity] = nil

			if (IsValid(entity)) then
				entity:Remove()
			end
		end
	end
end

function ENT:addPoster(charID)
	local entity = ents.Create("bountyposter")
	local IDPosF, IDPosU = self:GenerateID(entity)

	entity:SetMoveType(MOVETYPE_NONE)
	entity:SetParent(self)
	entity:SetAngles(self:GetAngles())
	entity:SetPos(self:GetPos()+self:GetRight()*(IDPosF-5.25)+self:GetForward()*1+self:GetUp()*IDPosU)

	entity:setPlayer(charID, self)
	entity:Spawn()

	self.posters[entity] = charID
end

function ENT:Use(activator, caller)
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + .5;

	net.Start("open_place_bounty_menu")
	net.Send(activator)
end

function ENT:Touch(TouchEnt)
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 1;
end