ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName="Time Bomb"
ENT.Spawnable=true
ENT.AdminOnly=true
ENT.Category="Explosives"
ENT.Author="mitterdoo"
ENT.Contact="connorashcroft@live.com"
ENT.Purpose="Place a bomb then explode it!"
ENT.Model="models/weapons/w_c4_planted.mdl"

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "StartTime" );
    self:NetworkVar( "Int", 1, "TimeToExplode");
    self:NetworkVar( "Bool", 0, "Started");
end
