groupsConfig = {}
AddCSLuaFile("groups_config.lua")
include("groups_config.lua")

AddCSLuaFile("groups/groups.lua")
include("groups/groups.lua")

hook.Add("InitPostEntity", "GroupsCommandRegister", function()
    nut.command.add("groups", {
        onRun = function(ply, args)
            net.Start("GroupsOpenMenu")
            net.Send(ply)
        end
    })

    nut.command.add("groupinvite", {
        syntax = "<string playername>",
        onRun = function(ply, args)
            if ply:GetGroup() and ply:GetGroup():GetOwner() == ply then
                if ply.lastInviteSent and ply.lastInviteSent + 10 >= CurTime() then
                    ply:notify("Please wait before sending another invite.")
                    return
                end

                ply.lastInviteSent = CurTime()

                local target = nut.command.findPlayer(ply, table.concat(args, " "))
                if !IsValid(target) then
                    return
                end

                if target:GetGroup() then
                    ply:notify("This player is already a part of a group.")
                    return
                elseif table.Count(ply:GetGroup():GetPlayers()) >= groupsConfig.MaxPlayers then
                    ply:notify("Your group is already full.")
                    return
                end
                net.Start("GroupsInvite")
                    net.WriteEntity(ply)
                net.Send(target)
                ply:notify("Successfully sent invite to " .. target:Nick())
            else
                ply:notify("You are not the owner of a group.")
            end
        end
    })

/**
    nut.command.add("group", {
        syntax = "<string message>",
        onRun = function(ply, args)
            local group = ply:GetGroup()
            if !group then return end

            local message =  table.concat(args, " ")
            for p, rank in pairs(group:GetPlayers()) do
                p:GroupChat(message, ply)
            end
        end
    })
**/

    if groupsConfig.DevMode then
        nut.command.add("forcejoingroup", {
            superAdminOnly = true,
            syntax = "<string playername>",
            onRun = function(ply, args)
                if !ply:GetGroup() then return end
                local target = nut.command.findPlayer(ply, table.concat(args, " "))
                ply:GetGroup():AddPlayer(target)
            end
        })

        nut.command.add("forcegroupdisband", {
            superAdminOnly = true,
            syntax = "<string playername>",
            onRun = function(ply, args)
                local target = nut.command.findPlayer(ply, table.concat(args, " "))
                if !target:GetGroup() then return end
                target:GetGroup():Disband()
            end
        })

        nut.command.add("forcegroupsync", {
            superAdminOnly = true,
            onRun = function(ply, args)
                net.Start("SyncGroups")
                    net.WriteTable(GROUPS)
                net.Broadcast()
            end
        })
    end
end)

properties.Add("GroupsInvite", {
    ["MenuLabel"] = "Invite to Group",
    ["MenuIcon"] = "icon16/add.png",
    ["Order"] = 10000,
    ["Filter"] = function(self, ent)
        local group = LocalPlayer():GetGroup()
        return ent:IsPlayer() and group and group:GetOwner() == LocalPlayer() and !ent:GetGroup() and table.Count(group:GetPlayers()) < groupsConfig.MaxPlayers
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        if ply.lastInviteSent and ply.lastInviteSent + 10 >= CurTime() then
            ply:notify("Please wait before sending another invite.")
            return
        end

        ply.lastInviteSent = CurTime()

        local group = ply:GetGroup()
        local target = net.ReadEntity()
        if !group then return end

        net.Start("GroupsInvite")
            net.WriteEntity(ply)
        net.Send(target)
        ply:notify("Successfully sent invite")
    end
})
