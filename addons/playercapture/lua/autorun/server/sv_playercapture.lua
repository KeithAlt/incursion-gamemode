PLAYER = FindMetaTable("Player")

util.AddNetworkString("playercapture_startFree")
util.AddNetworkString("playercapture_haltFree")

playercaptureConfig = playercaptureConfig or {}
include("playercapture_config.lua")

function PLAYER:Attatch(ent, offset, angleOffset) --Attatches player to the given ent
    if !IsValid(self) then return end

    local ply = self
    if ply.isCaptured then return end --Already attatched

    local npc = ents.Create("playercapture_npc")
    npc:SetModel(ply:GetModel())
    npc:SetPos(offset)
    npc:SetAngles(angleOffset)
    npc:SetMoveParent(ent)
    npc:Spawn()
    ply.npcEnt = npc
    ply.attatchedEnt = ent
    ply.isCaptured = true
    ply.origHP = ply:Health()
    ply.origArmor = ply:Armor()
	ply:SetNWEntity("PCNPCEnt", npc)

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ent)
    ply:SetParent(ent)

    --Remove weapons and save them so they can be added back
    local weapons = ply:GetWeapons()
    ply:StripWeapons()
    local weaponClasses = {}
    for k,v in pairs(weapons) do
        table.insert(weaponClasses, v:GetClass())
    end
    ply.weapons = weaponClasses
end

function PLAYER:UnAttatch() --If the player is attatched to an ent it will remove them from it
    if !IsValid(self) then return end

    local ply = self

    local timerID = ply:SteamID64() .. "capturetimer"
    if timer.Exists(timerID) then timer.Remove(timerID) end
    if !ply.isCaptured then return end --Already not attatched

    local forward = ply.attatchedEnt:GetForward()
    ply:SetParent()
    ply:UnSpectate()
    ply.isCaptured = false
    ply.attatchedEnt.CapturedPly = nil
    ply.npcEnt:Remove()

    --Spawn them, reset their pos, HP and armor
    ply:Spawn()
    ply:SetPos(ply.attatchedEnt:GetPos() + (Vector(55, 55, 0) * forward) + Vector(0, 0, 20))
    ply:SetHealth(ply.origHP)
    ply:SetArmor(ply.origArmor)
    ply:DropToFloor()
    ply.origHP = nil
    ply.origArmor = nil

    --Give their weapons back
    for k,v in pairs(ply.weapons) do
        ply:Give(v)
    end
end

function PLAYER:Crucify(ent) --Poses the player's NPC model
    if !IsValid(self) then return end

    local ply = self
    ply:Attatch(ent, Vector(-33, 0, 85), Angle(0, 0, 0))

    local timerID = ply:SteamID64() .. "capturetimer"
    timer.Create(timerID, playercaptureConfig.playerCheckFrequency, 0, function() --0 reps as it will be removed by itself or when unattatched
        if !IsValid(ply) then timer.Remove(timerID) return end
        if !ply.isCaptured then timer.Remove(timerID) return end --This shouldn't ever be false, but just in case check anyway
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), playercaptureConfig.playerCheckRadius)) do
            if v:IsPlayer() and v != ply then
                return
            end
        end
        ply:UnAttatch()
        ply:Kill() --If there are no players around kill the player attatched to the cross
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

    npc:ManipulateBoneAngles(lowerSpine, Angle(0,-5,0)) --Slouch

    --Cross legs
    npc:ManipulateBoneAngles(leftCalf, Angle(30,30,0))
    npc:ManipulateBoneAngles(rightThigh, Angle(0,3,0))
    npc:ManipulateBoneAngles(leftThigh, Angle(0,-15,0))
    npc:ManipulateBoneAngles(rightCalf, Angle(-7,10,0))
    npc:ManipulateBoneAngles(leftFoot, Angle(-10,10,0))
    npc:ManipulateBoneAngles(rightFoot, Angle(10,25,0))

    --Stretch out arms
    npc:ManipulateBoneAngles(rightUpperArm, Angle(55,0,50))
    npc:ManipulateBoneAngles(leftUpperArm, Angle(-55,0,-50))
    npc:ManipulateBoneAngles(rightForeArm, Angle(35,0,0))
    npc:ManipulateBoneAngles(leftForeArm, Angle(-35,0,0))

    --Angle hands down
    npc:ManipulateBoneAngles(rightHand, Angle(0,-30,0))
    npc:ManipulateBoneAngles(leftHand, Angle(0,-30,0))
end

function PLAYER:Pod(ent) --Poses the player's NPC model
    if !IsValid(self) then return end

    local ply = self
    ply:Attatch(ent, Vector(0, 0, 10), Angle(0, -90, 0))

    if !ply.npcEnt then return end
    local npc = ply.npcEnt

    --Pose npc
    local head          = npc:LookupBone("ValveBiped.Bip01_Head1")
    local upperSpine    = npc:LookupBone("ValveBiped.Bip01_Spine4")
    local middleSpine   = npc:LookupBone("ValveBiped.Bip01_Spine2")
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

    --Bend forward a bit
    npc:ManipulateBoneAngles(head, Angle(0,-25,0))
    npc:ManipulateBoneAngles(upperSpine, Angle(0,-10,0))
    npc:ManipulateBoneAngles(middleSpine, Angle(0,10,0))
    npc:ManipulateBoneAngles(lowerSpine, Angle(0,10,0))

    --Manipulate arms
    npc:ManipulateBoneAngles(rightUpperArm, Angle(-27,-10,0))
    npc:ManipulateBoneAngles(leftUpperArm, Angle(27,0,0))
    npc:ManipulateBoneAngles(rightForeArm, Angle(-30,-35,-50))
    npc:ManipulateBoneAngles(leftForeArm, Angle(10,-75,50))
    npc:ManipulateBoneAngles(rightHand, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftHand, Angle(0,-35,0))

    --Manipulate legs
    npc:ManipulateBoneAngles(rightThigh, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftThigh, Angle(0,0,0))
    npc:ManipulateBoneAngles(rightCalf, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftCalf, Angle(0,0,0))
    npc:ManipulateBoneAngles(rightFoot, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftFoot, Angle(0,0,0))
end

function PLAYER:ResearchPod(ent) --Poses the player's NPC model
    if !IsValid(self) then return end

    local ply = self
    ply:Attatch(ent, Vector(0, 0, 50), Angle(0, -90, 0))

    if !ply.npcEnt then return end
    local npc = ply.npcEnt

    --Pose npc
    local head          = npc:LookupBone("ValveBiped.Bip01_Head1")
    local upperSpine    = npc:LookupBone("ValveBiped.Bip01_Spine4")
    local middleSpine   = npc:LookupBone("ValveBiped.Bip01_Spine2")
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

    --Bend forward a bit
    npc:ManipulateBoneAngles(head, Angle(0,-25,0))
    npc:ManipulateBoneAngles(upperSpine, Angle(0,-10,0))
    npc:ManipulateBoneAngles(middleSpine, Angle(0,10,0))
    npc:ManipulateBoneAngles(lowerSpine, Angle(0,10,0))

    --Manipulate arms
    npc:ManipulateBoneAngles(rightUpperArm, Angle(-27,-10,0))
    npc:ManipulateBoneAngles(leftUpperArm, Angle(27,0,0))
    npc:ManipulateBoneAngles(rightForeArm, Angle(-30,-35,-50))
    npc:ManipulateBoneAngles(leftForeArm, Angle(10,-75,50))
    npc:ManipulateBoneAngles(rightHand, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftHand, Angle(0,-35,0))

    --Manipulate legs
    npc:ManipulateBoneAngles(rightThigh, Angle(0,-20,0))
    npc:ManipulateBoneAngles(leftThigh, Angle(0,-25,0))
    npc:ManipulateBoneAngles(rightCalf, Angle(0,35,0))
    npc:ManipulateBoneAngles(leftCalf, Angle(0,30,0))
    npc:ManipulateBoneAngles(rightFoot, Angle(0,25,0))
    npc:ManipulateBoneAngles(leftFoot, Angle(0,30,0))
end

function PLAYER:Cell(ent) --Poses the player's NPC model
    if !IsValid(self) then return end
	self:EmitSound("doors/door_metal_large_chamber_close1.wav")

    local ply = self
    ply:Attatch(ent, Vector(0, 0, 11), Angle(0, -90, 0))

    if !ply.npcEnt then return end
    local npc = ply.npcEnt

    --Pose npc
    local head          = npc:LookupBone("ValveBiped.Bip01_Head1")
    local upperSpine    = npc:LookupBone("ValveBiped.Bip01_Spine4")
    local middleSpine   = npc:LookupBone ("ValveBiped.Bip01_Spine2")
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

    --Bend forward a bit
    npc:ManipulateBoneAngles(head, Angle(0,-25,0))
    npc:ManipulateBoneAngles(upperSpine, Angle(0,0,0))
    npc:ManipulateBoneAngles(middleSpine, Angle(0,0,0))
    npc:ManipulateBoneAngles(lowerSpine, Angle(0,0,0))

    --Manipulate arms
    npc:ManipulateBoneAngles(rightUpperArm, Angle(-27,-10,0))
    npc:ManipulateBoneAngles(leftUpperArm, Angle(27,0,0))
    npc:ManipulateBoneAngles(rightForeArm, Angle(-30,-35,-50))
    npc:ManipulateBoneAngles(leftForeArm, Angle(10,-75,50))
    npc:ManipulateBoneAngles(rightHand, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftHand, Angle(0,-35,0))

    --Manipulate legs
    npc:ManipulateBoneAngles(rightThigh, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftThigh, Angle(0,0,0))
    npc:ManipulateBoneAngles(rightCalf, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftCalf, Angle(0,0,0))
    npc:ManipulateBoneAngles(rightFoot, Angle(0,0,0))
    npc:ManipulateBoneAngles(leftFoot, Angle(0,0,0))
end

--Remove the ply's NPC ent, etc. if they DC while captured
hook.Add("PlayerDisconnected", "playercapture_validPlyCheck", function(ply)
    if ply.isCaptured then
        ply.attatchedEnt.CapturedPly = nil
        if ply.npcEnt then
            ply.npcEnt:Remove()
        end
    end
end)
