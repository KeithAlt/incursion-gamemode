AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Noose"
ENT.Author			= "Lenny"
ENT.Spawnable       = true
ENT.Category        = "Claymore Gaming"

ENT.HangingTime = 45 // initial time for the player to be killed should be low for realism.

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 1, "Attached")
end

function ENT:Initialize()
    self:SetModel("models/infra/props_corruption/rope_001.mdl")
    self:SetAngles(self:GetParent():GetForward():Angle())
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX) // make it easier to interact with.

    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end
end

if SERVER then
    function ENT:Use(ply)
        if not IsValid(self:GetAttached()) then
            jlib.RequestBool("Are you sure?", function(bool)
                if not bool then return end
                local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
                if not bone then return end
                ply:Hang(self.HangingTime, self, bone)
                self:SetAttached(ply)
            end, ply, "Yes", "No")
            return
        end

        if self:GetAttached() != ply then
            jlib.RequestBool("Release?", function(bool)
                if not bool then return end

                local victim = self:GetAttached()

                if IsValid(victim) then
                    victim:HangRelease(true, self)
                end

            end, ply, "Yes", "No")
        end
    end

    function ENT:ResetState()
        self:SetAttached(nil)
    end

    function ENT:OnRemove()
        if IsValid(self:GetAttached()) then
            self:GetAttached():UnAttatch()
        end
    end

    local meta = FindMetaTable("Player")
    /*
        Hang a person to a parent entity,
        @time : Length of hanging before being killed.
        @parent : Parent Entity (noose ent)
    */
    function meta:Hang(time, parent)
        if hcWhitelist.isRobot(self) then
			self:notify("Robots cannot be hung")
			return
		end

        if not IsValid(parent) then return end

		self:EmitSound("ambient/alarms/warningbell1.wav", 100, 60)
		self:ScreenFade(SCREENFADE.IN, Color(255,55,55,155), 0.5, 0)

		local ply = self
		local ent = parent

		timer.Simple(0, function()
			ply:ScreenFade(SCREENFADE.OUT, Color(0,0,0,255), time, 1)
		end)

		ply:Attatch(ent, Vector(-5, -0.5, -146), Angle(0, 0, 0))
		local timerID = ply:SteamID64() .. "_hangtimer"

		timer.Create(timerID, time, 0, function() --0 reps as it will be removed by itself or when unattatched
			if !IsValid(ply) then timer.Remove(timerID) return end
			if !ply.isCaptured then timer.Remove(timerID) return end --This shouldn't ever be false, but just in case check anyway

			ply:UnAttatch()
			ent:ResetState()
			ply:SetPos(ent:GetPos() - Vector(0,0,145))
			ply:Kill()

			ply:ScreenFade(SCREENFADE.OUT, Color(255,0,0,100), 0.5, 0)

			local zone = Dismemberment.GetDismembermentZone(HITGROUP_HEAD)
			Dismemberment.Dismember(ply, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, IsValid(ply) and ply:GetForward() or VectorRand())
		end)

		timer.Create(timerID .. "_sfx", 3, 0, function()
			local victim = IsValid(parent) and parent:GetAttached()

			if IsValid(victim) and parent:GetAttached() then
				parent:EmitSound("ambient/materials/cartrap_rope" .. math.random(1,3) .. ".wav", 65, 250)

				timer.Simple(math.random(1, 3), function()
					if IsValid(victim) and victim:Alive() then
						victim:EmitSound("ambient/voices/citizen_beaten" .. math.random(1,5) .. ".wav", 68, math.random(90, 110))
					end
				end)
			else
				timer.Remove(timerID .. "_sfx")
			end
		end)

		if !ply.npcEnt then return end
		local npc = ply.npcEnt

		--Pose npc
		local head          = npc:LookupBone("ValveBiped.Bip01_Head1")
		local upperSpine    = npc:LookupBone("ValveBiped.Bip01_Spine4")
		local lowerSpine    = npc:LookupBone("ValveBiped.Bip01_Spine")
		local leftCalf      = npc:LookupBone("ValveBiped.Bip01_L_Calf")
		local rightCalf     = npc:LookupBone("ValveBiped.Bip01_R_Calf")
		local leftThigh     = npc:LookupBone("ValveBiped.Bip01_L_Thigh")
		local rightThigh    = npc:LookupBone("ValveBiped.Bip01_R_Thigh")
		local leftFoot      = npc:LookupBone("ValveBiped.Bip01_L_Foot")
		local rightFoot     = npc:LookupBone("ValveBiped.Bip01_R_Foot")
		local rightUpperArm = npc:LookupBone("ValveBiped.Bip01_R_UpperArm")
		local leftUpperArm  = npc:LookupBone("ValveBiped.Bip01_L_UpperArm")
		local rightForeArm  = npc:LookupBone("ValveBiped.Bip01_R_Forearm")
		local leftForeArm   = npc:LookupBone("ValveBiped.Bip01_L_Forearm")
		local rightHand     = npc:LookupBone("ValveBiped.Bip01_R_Hand")
		local leftHand      = npc:LookupBone("ValveBiped.Bip01_L_Hand")

		--Head angle
		npc:ManipulateBoneAngles(head, Angle(0,-30,0))
		npc:ManipulateBoneAngles(upperSpine, Angle(0,20,0))

		npc:ManipulateBoneAngles(lowerSpine, Angle(0,10,0)) --Slouch

		--Cross legs
		npc:ManipulateBoneAngles(leftCalf, Angle(0,15,0))
		npc:ManipulateBoneAngles(rightThigh, Angle(0,3,0))
		npc:ManipulateBoneAngles(leftThigh, Angle(0,-5,0))
		npc:ManipulateBoneAngles(rightCalf, Angle(-7,5,0))
		npc:ManipulateBoneAngles(leftFoot, Angle(-10,25,5))
		npc:ManipulateBoneAngles(rightFoot, Angle(5,25,-5))

		--Stretch out arms
		npc:ManipulateBoneAngles(rightUpperArm, Angle(-40,-35,10))
		npc:ManipulateBoneAngles(leftUpperArm, Angle(35,-40,10))
		npc:ManipulateBoneAngles(rightForeArm, Angle(0,-2,-40))
		npc:ManipulateBoneAngles(leftForeArm, Angle(5,-5,-5))

		--Angle hands down
		npc:ManipulateBoneAngles(rightHand, Angle(0,-10,0))
		npc:ManipulateBoneAngles(leftHand, Angle(0,-10,0))
    end

    /*
        Release a persron that is hanged,
        @newpos (bool) : If their position should be offset as if they have been released.
    */
    function meta:HangRelease(newPos, ent)
        if IsValid(ent) then
            ent:SetAttached(nil)
            ent:ResetState()
        end

        self:ScreenFade(SCREENFADE.IN, Color(255,255,255,155), 0.5, 0)
        self:falloutNotify("You've been let free!", "ui/goodkarma.ogg")
        self:UnAttatch()

        timer.Remove(self:SteamID64() .. "_HangTimer")
		timer.Remove(self:SteamID64() .. "_sfx")

        self:SetNWEntity("Hanged", nil)
        self:SetNoDraw(false)
        self:Freeze(false)
        self:SetSolid(SOLID_OBB)

        if newPos then
            if IsValid(ent) then
                self:SetPos(ent:GetPos() + ent:GetForward() * 50)
            else
                print("invalid localization of the noose.")
                self:SetPos(self:GetPos() + self:GetForward() * 100) // if for whatever reason it is not valid above, fallback.
            end
        end
    end
end
