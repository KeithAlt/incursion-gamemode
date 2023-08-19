AddCSLuaFile()

ENT.Spawnable=true;
ENT.Category="Casino Kit"
ENT.PrintName="Hold 'em table"
DEFINE_BASECLASS("casinokit_table")
ENT.Base="casinokit_table"
ENT.GameClass="HoldEm"

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Int",4,"Ante")
	self:NetworkVar("Int",5,"SmallBet")
	self:NetworkVar("Int",6,"TimeoutDelay")
end;

function ENT:Initialize()
	if self:GetAnte()==0 then
		self:SetAnte(5)
		self:SetSmallBet(10)
		self:SetTimeoutDelay(15)
	end;

	BaseClass.Initialize(self)

	-- NOTE: Custom fix for addressing CSS mounting annoyance
	self:SetModel("models/maxib123/table1.mdl")
	self:SetModelScale(0.82)
	self:PhysicsInit(SOLID_VPHYSICS)
end;

function ENT:OnGameConfigReceived(a,b)
	if a=="ante"then
		assert(type(b)=="number"and b>0)
		self:SetAnte(b)
	elseif a=="smallbet"then
		assert(type(b)=="number"and b>0)self:SetSmallBet(b)
	elseif a=="timeoutdelay"then
		assert(type(b)=="number"and b>0)
		self:SetTimeoutDelay(b)
	end
end
