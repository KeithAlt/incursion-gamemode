-- Quick little prop_dynamic mod that makes it so that prop_dynamics of a certain model will automatically react to the USE key and play the right sound.
-- If you're using NP++, the indentation might be fucked for you, not sure, I use atom and it looks fine for me, not sure why it does this. :(
--  - Bizzclaw

local DoorTrace = {
    mins = Vector(-6,-6,-6),
    maxs = Vector(6,6,6),
    mask = MASK_SOLID,
    dist = 90,
}

DoorReplacements = DoorReplacements or {} -- table of models, global so people can add their own doors to it with external scripts I guess whyt not???
ControlPanels = ControlPanels or {}


DoorReplacements["models/fallout_nv/clutter/clfence/clfencegate01.mdl"] = { -- table is keyed by the model name
    opentext = LangText and "#DOOR_GATE_OPEN" or "Open Gate",
    closetext = LangText and "#DOOR_GATE_CLOSE" or "Close Gate",
    snd_open = "fallout_nv/fx/drs/drs_gatechainlink_01_open.mp3", -- opening sound, you can mke this a table and it will select random ones.
    snd_close = "fallout_nv/fx/drs/drs_gatechainlink_01_close.mp3", -- closing sound
    snd_delay_open = 0, -- delay before open sound plays
    snd_delay_close = 1, -- ditto, but for closing
    snd_lock = "physics/metal/metal_chainlink_impact_soft1.wav",
    anim_open = "open", -- sequence for opening, default "open"
    anim_close = "close", -- ditto, default "close"
}
DoorReplacements["models/fallout_nv/clutter/clfence/clfencegateroad01.mdl"] = {
    opentext = LangText and "#DOOR_GATE_OPEN" or "Open Gate",
    closetext = LangText and "#DOOR_GATE_CLOSE" or "Close Gate",
    snd_open = "fallout_nv/fx/drs/drs_gatechainlink_01_open.mp3",
    snd_close = "fallout_nv/fx/drs/drs_gatechainlink_01_close.mp3",
    snd_delay_close = 1
}
DoorReplacements["models/fallout_nv/dungeons/utility/utldoor01.mdl"] = {
    opentext = LangText and "#DOOR_DOOR_OPEN" or "Open Door",
    closetext = LangText and "#DOOR_DOOR_CLOSE" or "Close Door",
    snd_open = "fx/drs/drs_metalutilitysmall_open.mp3",
    snd_close = "fx/drs/drs_metalutilitysmall_close.mp3"
}
DoorReplacements["models/fallout_nv/dungeons/vault_sized/halls/vdoor01.mdl"] = {
    opentext = LangText and "#DOOR_DOOR_OPEN" or "Open Door",
    closetext = LangText and "#DOOR_DOOR_CLOSE" or "Close Door",
    snd_open = "fallout_nv/fx/drs/vault/drs_vault_blast_01_open.mp3",
    snd_close = "fallout_nv/fx/drs/vault/drs_vault_blast_01_close.mp3"
}
DoorReplacements["models/fallout_nv/dungeons/vault_sized/doors/vdoorsliding01.mdl"] = {
    opentext = LangText and "#DOOR_DOOR_OPEN" or "Open Door",
    closetext = LangText and "#DOOR_DOOR_CLOSE" or "Close Door",
    snd_open = "fallout_nv/fx/drs/vault/drs_vaultvertical_01_open.mp3",
    snd_close = "fallout_nv/fx/drs/vault/drs_vaultvertical_01_close.mp3"
}
DoorReplacements["models/fallout_nv/dungeons/enclave/ecvdoorsm01.mdl"] = {
    opentext = LangText and "#DOOR_DOOR_OPEN" or "Open Door",
    closetext = LangText and "#DOOR_DOOR_CLOSE" or "Close Door",
    snd_open = "fx/drs/drs_enclave_small_open.mp3",
    snd_close = "fx/drs/drs_enclave_small_close.mp3"
}
DoorReplacements["models/fallout_nv/dungeons/enclave/ecvdoorbg01.mdl"] = {
    opentext = LangText and "#DOOR_DOOR_OPEN" or "Open Door",
    closetext = LangText and "#DOOR_DOOR_CLOSE" or "Close Door",
    snd_open = "fx/drs/drs_enclave_large_open.mp3",
    snd_close = "fx/drs/drs_enclave_large_close.mp3"
}

local vaultDoor = {
    model  = "models/fallout_nv/dungeons/vault_sized/roomu/vgeardoor01.mdl",
    snd_open = "fallout_nv/fx/drs/drs_vaultgear_open_stereo.mp3",
    snd_close = "fallout_nv/fx/drs/drs_vaultgear_close_stereo.mp3",
}
ControlPanels["models/fallout_nv/dungeons/vault_sized/accessories/controlpanelvault01.mdl"] = {
    door = vaultDoor,
    radius = 512,
    opentext = "Open Vault Door",
    closetext = "Close Vault Door"
}

local overSeerDoor = {
    model = "models/fallout_nv/dungeons/vault_sized/room/vrmoverseerdesk01.mdl",
    snd_open = "fallout_nv/fx/drs/drs_vaultcg04secret_open.mp3",
    snd_close = "fallout_nv/fx/drs/drs_vaultcg04secret_close.mp3",
    rate = 3,
}
ControlPanels["models/fallout_nv/dungeons/vault_sized/accessories/voverseerterminal01.mdl"] = {
    door = overSeerDoor,
    radius = 512,
    opentext = "Open Overseer's bunker",
    closetext = "Close Overseer's bunker"
}
ControlPanels["models/props_lab/freightelevatorbutton.mdl"] = {
    door = overSeerDoor,
    radius = 512,
    opentext = "Open Overseer's bunker",
    closetext = "Close Overseer's bunker"
}

local function CanUseDoor(door)
    print(door:GetCycle())
    return IsValid(door)  and CurTime() >= (door.nextUse or 0) and (door:GetCycle() <= 0.01 or door:GetCycle() >= 0.98)
end

local function openDoor(door, doorData)
    if not CanUseDoor(door) then return false end

    door.Open = not door.Open
    local anim = door.Open and (doorData.anim_open or "open") or (doorData.anim_close or "close")
    local snd = door.Open and doorData.snd_open or doorData.snd_close
    local delay = door.Open and (doorData.opentime or 1) or (doorData.closetime or 1)

    door:SetPlaybackRate(doorData.rate or 1)
    door:Fire("SetAnimation", anim)
    door.nextUse = CurTime() + 1
    if snd then
        if istable(snd) then
            snd = table.Random(snd)
        end
        local delaytime = door.Open and (doorData.snd_delay_open or 0) or doorData.snd_delay_close or 0
        timer.Simple(delaytime, function()
            if not IsValid(door) then return false end
            door:EmitSound(snd, doorData.soundlvl or 70)
        end)
    end
end

function InitDoors()
    local ents1 = ents.FindByClass("prop_dynamic")
    for k, v in pairs(ents1) do
        local doorData = DoorReplacements[v:GetModel()]
        local controlData = ControlPanels[v:GetModel()]
        if doorData then
            v.doorData = doorData
        end
        if controlData then
            v.controlData = controlData
        end
    end
end

InitDoors()

hook.Add("OnEntityCreated", "rsrg_doorcreate", function(ent)
    if ent:GetClass() == "prop_dynamic" then
        local doorData = DoorReplacements[ent:GetModel()]
        local controlData = ControlPanels[ent:GetModel()]
        if doorData then
            ent.doorData = doorData
        end
        if controlData then
            ent.controlData = controlData
        end
    end
end)

hook.Add("InitPostEntity", "rsrg_doorinit", InitDoors)
hook.Add("PostCleanupMap", "rsrg_doorunclean", InitDoors)

hook.Add("KeyPress", "rsrg_doorpress", function(ply, key)
    if ply:Alive() and key == IN_USE then

        local traced = table.Copy(DoorTrace) -- copy the table to tracedata, or ,traced so it doens't get overridden
        traced.start = ply:EyePos()
        traced.endpos = traced.start + ply:EyeAngles():Forward() * traced.dist
        traced.owner = ply
        traced.filter = ply

        local htr = util.TraceLine(traced)
        local ent = htr.Entity

        if not ent then
            htr = util.TraceHull(traced)
            ent = htr.Entity
        end

        local doorData = IsValid(ent) and ent.doorData
        if doorData then
            local door = ent
            if door:GetSaveTable().m_bLocked then
                if doorData.snd_lock then
                    door:EmitSound(doorData.snd_lock, 60)
                end
                return false
            end
            if not CanUseDoor(door) then return false end

            door.Open = not door.Open
            local anim = door.Open and (doorData.anim_open or "open") or (doorData.anim_close or "close")
            local snd = door.Open and doorData.snd_open or doorData.snd_close
            local delay = door.Open and (doorData.opentime or 1) or (doorData.closetime or 1)

            door:SetPlaybackRate(1)
            door:Fire("SetAnimation", anim)
            if snd then
                if istable(snd) then
                    snd = table.Random(snd)
                end
                local delaytime = door.Open and (doorData.snd_delay_open or 0) or doorData.snd_delay_close or 0
                timer.Simple(delaytime, function()
                    if not IsValid(door) then return false end
                    door:EmitSound(snd, doorData.soundlvl or 70)
                end)
            end
        end
        local controlData = IsValid(ent) and ent.controlData
        if controlData then
            if not IsValid(ent.linkedDoor) then
                for k, v in pairs(ents.FindByClass("prop_dynamic")) do
                    if v:GetPos():Distance(ent:GetPos()) and v:GetModel() == controlData.door.model then
                        ent.linkedDoor = v
                    end
                end
            end

            local door = ent.linkedDoor
            if not door then return false end

            if CanUseDoor(door) then
                openDoor(door, controlData.door)
            end
        end
    end
end)

concommand.Add("rsrg_testdoor", function(ply, cmd, args)
    if not ply:IsAdmin() then return false end

    local mdl = args[1]
    if not mdl or not DoorReplacements[mdl] then return false end
    local door = ents.Create("prop_dynamic")
    door:SetModel(mdl)
    door.doorData = DoorReplacements[mdl]
    door:SetPos(ply:GetEyeTrace().HitPos)
    door:SetAngles(Angle(0,ply:EyeAngles().y,0))
    door:SetKeyValue( "solid", "6" )
    door:Spawn()
    door:Activate()

    undo.Create("Door")
    undo.AddEntity(door)
    undo.SetPlayer(ply)
    undo.Finish()
end)

    local function UpdateDoors(pos)
        for _, door in ipairs(ents.FindByClass("prop_door_rotating")) do
            if pos and door:GetPos():Distance(pos) > 256 then continue end
            timer.Create("DoorUpdate_"..door:EntIndex(), 0.5, 1, function()
            local tab = door:GetSaveTable()
            local state = tonumber(tab.m_eDoorState)
            if tab.m_bLocked then
                door:SetNWString("DoorUse", "PromptLocked")
            elseif state == 9 or state == 3 then
                door:SetNWString("DoorUse", "PromptOpen")
            else
                door:SetNWString("DoorUse", "PromptClose")
            end
        end)
    end
end

    hook.Add("KeyPress", "RSRGDoorUpdate", function(ply, key)
        if key == IN_USE then
            UpdateDoors(ply:GetPos())
        end
    end)
