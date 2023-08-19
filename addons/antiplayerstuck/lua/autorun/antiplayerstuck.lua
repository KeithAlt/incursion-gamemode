if not SERVER then return end

local function ShouldCollide(ent1, ent2)
	local shouldCollide = hook.Run("ShouldCollide", ent1, ent2)
	if shouldCollide == nil then shouldCollide = true end
	return shouldCollide
end

local function ShouldCheck(ply)
	return IsValid(ply) and ply:IsPlayer() and ply:Alive() and !ply:InVehicle() and !ply:IsNoClipping() and ply:IsSolid()
end

local function CheckIfPlayerStuck()
	for _, ply in ipairs(player.GetAll()) do
		if ShouldCheck(ply) then
			local Offset = Vector(5, 5, 5)
			local Stuck = false

			if ply.Stuck then
				Offset = Vector(2, 2, 2)
			end

			for _, ent in pairs(ents.FindInBox(ply:GetPos() + ply:OBBMins() + Offset, ply:GetPos() + ply:OBBMaxs() - Offset)) do
				if ShouldCheck(ent) and ent != ply and ShouldCollide(ply, ent) then
					ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

					local velocity = ent:GetForward() * 200

					ply:SetVelocity(velocity)
					ent:SetVelocity(-velocity)
					Stuck = true
				end
			end

			if !Stuck then
				ply.Stuck = false
				if ply:GetCollisionGroup() != COLLISION_GROUP_PLAYER then
					ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
					MsgC(Color(255,155,0), "[ANTI-STUCK] ", Color(255,255,255), "Changing collision group back to player for: " .. jlib.SteamIDName(ply))
				end
			end
		end
	end
end

timer.Create("CheckIfPlayerStuck", 4, 0, CheckIfPlayerStuck)
