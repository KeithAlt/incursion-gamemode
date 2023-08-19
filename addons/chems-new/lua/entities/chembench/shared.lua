ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.Category  = "Claymore Gaming"
ENT.PrintName = "Chem Bench"
ENT.Author    = "jonjo"

ENT.Spawnable = true

function ENT:StartSoundLoop()
    self.loopID = self:StartLoopingSound("chems-boiling.wav")
end

function ENT:StopSoundLoop()
    if self.loopID then
        self:StopLoopingSound(self.loopID)
    end
end

function ENT:OnRemove()
    self:StopSoundLoop()
end