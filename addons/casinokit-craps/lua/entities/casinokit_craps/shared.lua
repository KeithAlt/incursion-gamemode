AddCSLuaFile()DEFINE_BASECLASS("casinokit_table")ENT.Base="casinokit_table"ENT.SeatCount=0;ENT.Model="models/casinokit/craps.mdl"ENT.Spawnable=true;ENT.Category="Casino Kit"ENT.PrintName="Craps table"ENT.GameClass="Craps"ENT.DealerAngle=math.pi;ENT.DealerDistance=35;function ENT:SetupDataTables()BaseClass.SetupDataTables(self)self:NetworkVar("Bool",0,"Rolling")self:NetworkVar("Bool",1,"PointRound")self:NetworkVar("Bool",3,"CanBet")self:NetworkVar("Int",1,"MinBet")self:NetworkVar("Int",2,"RollInterval")end;function ENT:GetTimeToNextRoll()return self:GetRollInterval()-CurTime()%self:GetRollInterval()end