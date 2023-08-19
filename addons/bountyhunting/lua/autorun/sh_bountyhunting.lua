AddCSLuaFile("bountyhunting_config.lua")

BountyHunting = BountyHunting or {}
BountyHunting.Config = BountyHunting.Config or {}
include("bountyhunting_config.lua")

--Player meta functions
local PLAYER = FindMetaTable("Player")

function PLAYER:IsBountyHunter()
	if self:IsBot() then return true end

    local char = self:getChar()
    if !char or !char:getFaction() or !char:getClass() then return false end

    return nut.faction.indices[char:getFaction()].IsBountyHunter or nut.class.list[char:getClass()].IsBountyHunter or false
end

function PLAYER:SetTarget(target)
    if SERVER then
        self:SetNWEntity("jBountyTarget", target)
    end
end

function PLAYER:GetTarget()
    return self:GetNWEntity("jBountyTarget", NULL)
end

function PLAYER:SetHunter(hunter)
    if SERVER then
        self:SetNWEntity("jBountyHunter", hunter)
    end
end

function PLAYER:GetHunter()
    return self:GetNWEntity("jBountyHunter", NULL)
end

--ULogs init
--[[hook.Add("InitPostEntity", "BountyHuntingLogsInit", function()
    local GM = #ULogs.GMTypes + 1
    ULogs.AddGMType(GM, "Claymore")

    local LogID = #ULogs.LogTypes + 1
    ULogs.AddLogType(LogID, GM, "Bounty Hunting", function(hunter)
        return IsValid(hunter) and {ULogs.RegisterBase(hunter)} or {}
    end)

    BountyHunting.LogID = LogID
end)]]

--Head collection
hook.Add("InitializedPlugins", "BountyHeadCollection", function()
	print("Loading head/flesh items")

	local ITEM = nut.item.register("playerhead", nil, false, nil, true)
	ITEM.name  = "Player Head"
	ITEM.model = "models/headspack/zombiehead.mdl"
	ITEM.desc  = "Someone's head"

	function ITEM:getName()
		return self:getData("headowner", nil) and self:getData("headowner", nil) .. "'s head" or self.name
	end

	function ITEM:getDesc()
		return self:getData("headowner", nil) and self:getData("headowner", nil) .. "'s head." or self.desc
	end

	ITEM.functions.Deploy = {
		onRun = function(item)
			local ply = item.player or item:getOwner()

			local spike = ents.Create("bounty_headspike")
			spike:SetHead(item:getData("headowner", "Someone"))
			spike:SetPos(ply:GetPos() + (ply:GetForward() * 100))
			local ang = ply:EyeAngles()
			ang.p = 0
			ang.y = ang.y + 180
			spike:SetAngles(ang)
			spike:Spawn()

			hook.Run("PlayerSpawnedSENT", ply, spike)
		end
	}

	ITEM = nut.item.register("food_human_meat", "base_jonjo_food", false, nil, true)
	ITEM.name  = "Human Meat"
	ITEM.model = "models/fallout 3/human_meat.mdl"
	ITEM.desc  = "Fresh human meat, ready for consumption."
	ITEM.amt   = 20
	ITEM.rads  = 5

	function ITEM:getName()
		return self:getData("headowner", nil) and self:getData("headowner", nil) .. "'s flesh" or self.name
	end

	function ITEM:getDesc()
		return self:getData("headowner", nil) and self:getData("headowner", nil) .. "'s flesh." or self.desc
	end

	--[[
	nut.command.add("pk", {
        adminOnly = true,
        onRun = function(ply, args)
            local name = string.Trim(table.concat(args, " "), '"')
			local target, err = jlib.GetPlayer(name)

			if !IsValid(target) then
				if err then
					ply:ChatPrint(err)
				end
			else
				ply:getChar():getInv():add("playerhead", 1, {headowner = target:Nick()})

				net.Start("PKForceNameChange")
				net.Send(target)
			end
        end
    })
	--]]
end)

--Rocket Boots
BountyHunting.BoostFactor = 560

function PLAYER:HasRocketBoots()
	return self:GetNWBool("RocketBoots")
end

function PLAYER:GetRocketCharge()
	return self:GetNWFloat("RocketBootsCharge", 0)
end

function PLAYER:GiveRocketBoots(maxFuel)
	maxFuel = maxFuel or 4

	self.MaxRocketCharge = maxFuel

	if SERVER then
		self:SetNWBool("RocketBoots", true)
	end

	local hID = "RocketBoots" .. self:SteamID64()
	hook.Add("Think", hID, function()
		if !IsValid(self) then
			hook.Remove("Think", hID)
			return
		end

		if self:KeyDown(IN_JUMP) and self:GetMoveType() == MOVETYPE_WALK then
			if self:GetRocketCharge() > 0 then
				local frameTime = SERVER and FrameTime() or engine.ServerFrameTime()
				local factor    = BountyHunting.BoostFactor * frameTime
				self:SetVelocity((self:GetForward() * (factor / 4)) + Vector(0, 0, 1) * factor)

				if !self.NextBoostEffect or self.NextBoostEffect < CurTime() then
					local dat = EffectData()
					dat:SetEntity(self)
					util.Effect("wt_rocketboots_effect", dat, true, true)

					self.NextBoostEffect = CurTime() + 0.95
				end

				if SERVER then
					self:SetRocketCharge(self:GetRocketCharge() - FrameTime())
					self:SetBoosting(true)
				end
			elseif SERVER then
				self:SetBoosting(false)
			end
		elseif self:IsOnGround() and self:GetRocketCharge() < self.MaxRocketCharge then
			if SERVER then
				self:SetRocketCharge(self:GetRocketCharge() + FrameTime())
				self:SetBoosting(false)
			end
		elseif SERVER then
			self:SetBoosting(false)
		end
	end)
end

function PLAYER:RemoveRocketBoots()
	if SERVER then
		self:SetNWBool("RocketBoots", false)
	end

	hook.Remove("Think", "RocketBoots" .. self:SteamID64())
end

function PLAYER:IsBoosting()
	return self:GetNWBool("IsBoosting")
end

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "RocketBootsApply", function(dat)
	timer.Simple(0, function()
		local ply = Player(dat.userid)

		if !isfunction(ply.getChar) then
			return
		end

		if ply:getChar() and ply:getChar():getClass() and nut.class.list[ply:getChar():getClass()].RocketBoots then
			ply:GiveRocketBoots(nut.class.list[ply:getChar():getClass()].RocketBoots)
		elseif ply:HasRocketBoots() then
			ply:RemoveRocketBoots()
		end
	end)
end)
