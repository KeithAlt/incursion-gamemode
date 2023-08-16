--[[---------------------------------------------------------------------------
This is an example of a custom entity.
---------------------------------------------------------------------------]]
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetSkin(1)
	BROADCASTS.RegisterBroadcastListener(self) --Pass in an ID as a second argument, otherwise it's automatically chosen.
	self.Activated = true -- Is the entity actually on
end

function ENT:Use(ply)
	if self.Activated then
		self.Activated = false
		self:SetSkin(0)
		self:EmitSound("falloutradio/fx/pipboy_radio_off.mp3")

		if ply:GetPos():DistToSqr(self:GetPos()) < self.ListenDistance and self.broadcastListenID then
		  ply:BroadcastHear(self.broadcastListenID, false)
		end

		return
	else
		self.Activated = true
		self:SetSkin(1)
		self:EmitSound("falloutradio/fx/pipboy_radio_on.mp3")
	end

end

function ENT:Think()
	if self.Activated then
		self.nextBroadcastThink = self.nextBroadcastThink or CurTime()
    if self.nextBroadcastThink < CurTime() then
      local plys = player.GetAll()
      for i = 1, #plys do
        local ply = plys[i]
        --Add/Remove if they are within dist.
        if ply:GetPos():DistToSqr(self:GetPos()) < self.ListenDistance and self.broadcastListenID and !ply:IsListeningToBroadcast(self.broadcastListenID) and !ply.TransmissionCooldown then
            ply:BroadcastHear(self.broadcastListenID, true)
						self:EmitSound("buttons/button9.wav")

						ply.TransmissionCooldown = true

						timer.Simple(BROADCASTS.Config.TransmissionCooldown, function()
							if IsValid(ply) and ply.TransmissionCooldown then
								ply.TransmissionCooldown = false
							end
						end)

        elseif ply.broadcastData.notForced and !ply:IsListeningToBroadcast(self.broadcastListenID) and !ply.TransmissionCooldown then
            ply:BroadcastHear(self.broadcastListenID, false)
        end
      end
      self.nextBroadcastThink = CurTime() + 2
    end
	end
end

function ENT:OnRemove()
    local plys = player.GetAll()
    for i = 1, #plys do
        local ply = plys[i]
        if ply:GetPos():DistToSqr(self:GetPos()) < self.ListenDistance and ply.broadcastData.notForced then
            ply:BroadcastHear(self.broadcastListenID, false)
        end
    end
    BROADCASTS.BroadcastListeners[self.broadcastListenID] = nil
end
