local def =
{
	run = 500,
	walk = 250,
	step = 18,
	jump = 200,

	view = Vector(0,0,64),
	viewducked = Vector(0,0,28),
	mass = 85,

	min = Vector(-16, -16, 0),
	max = Vector(16, 16, 72),
	maxduck = Vector(16, 16, 36),
	MIN_PL_SIZE = 0.1,
	MAX_PL_SIZE = 10.0,
}

pac.size_constants = def

function pac.GetPlayerSize(ply)
	return ply.pac_player_size or 1
end

function pac.SetPlayerSize(ply, f, force)

	local scale = math.Clamp(f, def.MIN_PL_SIZE, def.MAX_PL_SIZE)
	local olds = ply.pac_player_size or 1

	if olds==scale and not force then return end

	ply.pac_player_size = scale

	pac.dprint("pac.SetPlayerSize",ply, f,scale)

	if ply.SetViewOffset then ply:SetViewOffset(def.view * scale) end
	if ply.SetViewOffsetDucked then ply:SetViewOffsetDucked(def.viewducked * scale) end

	if SERVER then
		if ply.SetStepSize then ply:SetStepSize(def.step * scale) end
	else
		local mat = Matrix()
		mat:Scale( Vector( scale,scale,scale ) )
		ply:EnableMatrix( "RenderMultiply", mat )
	end

	if scale == 1 then
		ply:ResetHull()
	else
		ply:SetHull(def.min * scale, def.max * scale)
		ply:SetHullDuck(def.min * scale, def.maxduck * scale)
	end


end

pac.AddServerModifier("size", function(data, owner)
	if data and tonumber(data.self.OwnerName) then
		 local ent = Entity(tonumber(data.self.OwnerName))
		 if ent and ent:IsValid() and ent:IsPlayer() then
			owner = ent
		 end
	end

	local size

	if data then
		-- find the modifier
		for key, part in pairs(data.children) do
			if part.self.ClassName == "entity" and part.self.Size then
				size = part.self.Size
				break
			end
		end
	else
		size = 1
	end

	if size then
		pac.SetPlayerSize(owner, size)
	end

end)