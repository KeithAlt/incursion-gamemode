AddCSLuaFile()
if(SERVER) then
	util.AddNetworkString( "gb4_sound" )
end
DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""

function ENT:Initialize()
     if (SERVER) then
		self.FILTER                           = {}
		self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE ) 
		self.SOUND = self:GetVar("SOUND")
     end
end

net.Receive( "gb4_sound", function( len, pl )
	local sound = net.ReadString()
	LocalPlayer():EmitSound(sound)
end );

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		net.Start("gb4_sound")
			net.WriteString(self:GetVar("SOUND"))
		net.Broadcast()		
		
		for k, v in pairs(player.GetAll()) do
			util.ScreenShake( v:GetPos(), 5,5,  self:GetVar("Shocktime"), 500 )
		end
		self:Remove()
	end
end

function ENT:Draw()
     return false
end