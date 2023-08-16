local star = Material( "sprites/glow04_noz" )

hook.Add("PostDrawOpaqueRenderables", "DrawKnockoutStars", function()
    for _, ply in ipairs(player.GetAll()) do
        local ragdoll = ply:GetNWEntity("KnockoutDoll", nil)

        if IsValid(ragdoll) then
            local attach = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))

            if attach then
                local stars = 3

                for i = 1, stars do
                    local time = CurTime() * 3 + ( math.pi * 2 / stars * i )
                    local offset = Vector(math.sin(time) * 5, math.cos(time) * 5, 10)

                    render.SetMaterial(star)
                    render.DrawSprite(attach.Pos + offset, 8, 8, Color(220, 220, 0))
                end
            end
        end
    end
end)

local w, h = 600, 40

net.Receive("KnockoutStartCuff", function()
	local endTime = CurTime() + knockoutConfig.cuffTime
	hook.Add("HUDPaint", "KnockoutProgressBar", function()
		jlib.DrawProgressBar((ScrW() / 2) - (w / 2), ScrH() - h - 60, w, h, 1 - ((endTime - CurTime()) / knockoutConfig.cuffTime), "Cuffing", true, Color(255, 0, 0, 255))
	end)
end)

net.Receive("KnockoutStopCuff", function()
	hook.Remove("HUDPaint", "KnockoutProgressBar")
end)

hook.Add("PlayerCanMenu", "Knockout", function()
    if IsValid(LocalPlayer():GetNWEntity("KnockoutDoll", NULL)) then
        return false
    end
end)

netstream.Hook("knockoutRagdollRender", function(client, accessories)
	local target = client:GetNWEntity("KnockoutDoll")
	
	if(!IsValid(target)) then return end
	
	-- Removes the Clientside Entities when the target ragdoll is removed
	target:CallOnRemove("knockoutRagdollRemove", function()
		if(target.Arms) then
			SafeRemoveEntity(target.Arms)
		end
		
		if(target.Head) then
			SafeRemoveEntity(target.Head)
		end
		
		if(target.Accessories) then
			for k, accessory in pairs(target.Accessories) do
				SafeRemoveEntity(accessory)
			end
		end
	end)

	local group = Armor.GetGroupFromMdl(client:GetModel())
	if !group then return end 
	local forceArms = true
	local forceHead = true
	local race = client:GetRace()
	local sex = client:GetSex()
	local path = Armor.Consts.BodiesPath .. group .. "/"
	
	local armsPath = path .. "/arms/" .. sex .. "_arm.mdl"
	util.PrecacheModel(armsPath)

	if IsValid(target.Arms) then
		target.Arms:Remove()
	end

	local arms = (armsPath and ClientsideModel(armsPath, RENDERGROUP_OPAQUE)) or false
	if IsValid(arms) and (!client:GetForceNoArms() or forceArms) then
		arms:SetParent(target)
		arms:AddEffects(EF_BONEMERGE)
		arms:Spawn()
		arms:SetSkin(client:GetHeadSkin())
		arms.ply = target
		arms.IsArms = true
		arms.type = "Arms"
		arms.RenderOverride = Armor.RenderOverride

		target.Arms = arms
	end

	if !IsValid(target.Head) then
		Armor.MakeHeadRagdoll(client, target, forceHead)
	end
	
	for aType, accessory in pairs(accessories or client.Accessories or {}) do
		Armor.AddAccessoryRagdoll(client, target, accessory.id or accessory)
	end
end)