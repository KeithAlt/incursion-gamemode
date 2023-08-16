	

    include('shared.lua')
     
    local matBeam                   = Material( "cable/indy_whip" )
     
    /*---------------------------------------------------------
       Name: Initialize
    ---------------------------------------------------------*/
    function ENT:Initialize()              
     
            self.Size = 0
            self.MainStart = self.Entity:GetPos()
            self.MainEnd = self:GetEndPos()
            self.dAng = (self.MainEnd - self.MainStart):Angle()
            self.speed = 10000
            self.startTime = CurTime()
            self.endTime = CurTime() + self.speed
            self.dt = -1
           
    end
     
    function ENT:Think()
     
            self.Entity:SetRenderBoundsWS( self:GetEndPos(), self.Entity:GetPos(), Vector()*8 )
           
            self.Size = math.Approach( self.Size, 1, 10*FrameTime() )
           
    end
     
     
    function ENT:DrawMainBeam( StartPos, EndPos, dt, dist )
     
            local TexOffset = 0
           
            local ca = Color(255,255,255,255)
           
            EndPos = StartPos + (self.dAng * ((1 - dt)*dist))
           
            -- Beam effect
            render.SetMaterial( matBeam )
            render.DrawBeam( EndPos, StartPos,
                                            2.3,
                                            TexOffset*-0.4, TexOffset*-0.4 + StartPos:Distance(EndPos) / 256,
                                            ca )
     
     
    end
     
    function ENT:Draw()
     
            local Owner = self.Entity:GetOwner()
            if (!Owner || Owner == NULL) then return end
     
            local StartPos          = self.Entity:GetPos()
            local EndPos            = self:GetEndPos()
            local ViewModel         = Owner == LocalPlayer()
     
            if (EndPos == Vector(0,0,0)) then return end
           
            if ( ViewModel ) then
           
                    local vm = Owner:GetViewModel()
                    if (!vm || vm == NULL) then return end
                    local attachment = vm:GetAttachment( 1 )
                    StartPos = self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")) + Vector(0,0,0),self.Owner:GetEyeTrace().HitPos
           
            else
           
                    local vm = Owner:GetActiveWeapon()
                    if (!vm || vm == NULL) then return end
                    local attachment = vm:GetAttachment( 1 )
                    StartPos = self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")) + Vector(0,0,0),self.Owner:GetEyeTrace().HitPos
           
            end
     
            if not StartPos then return end
           
            local TexOffset = CurTime() * -2
           
            local Distance = EndPos:Distance( StartPos ) * self.Size
     
            local et = (self.startTime + (Distance/self.speed))
            if(self.dt != 0) then
                    self.dt = (et - CurTime()) / (et - self.startTime)
            end
            if(self.dt < 0) then
                    self.dt = 0
            end
            self.dAng = (EndPos - StartPos):Angle():Forward()
     
            gbAngle = (EndPos - StartPos):Angle()
            local Normal    = gbAngle:Forward()
     
            self:DrawMainBeam( StartPos, StartPos + Normal * Distance, self.dt, Distance )
             
    end
     
    /*---------------------------------------------------------
       Name: IsTranslucent
    ---------------------------------------------------------*/
    function ENT:IsTranslucent()
            return true
    end

