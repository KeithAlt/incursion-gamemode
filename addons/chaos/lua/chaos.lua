if SERVER then
	local freesidePos = Vector(-2596.741943, 9221.331055, 4700.196777)
	local niptonPos = Vector(-8881.136719, -2236.415283, -404.471283)
	local ghostPos = Vector(-5355.625488, -5537.659180, -524.681396)
	local khansPos = Vector(-2361.414551, 13288.419922, 55.286411)
	local ncrPos = Vector(-9549.886719, 11415.091797, -36.132210)
	local bosPos = Vector(7556.368652, -4860.919434, -350.836426)
	local legionPos = Vector(-8878.410156, -10553.985352, -118.313171)

	concommand.Add( "send_freeside", function(ply, cmd, args)
		local pos = freesidePos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to Freeside")
	end)

	concommand.Add( "send_nipton", function(ply, cmd, args)
		local pos = niptonPos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to Nipton")
	end)

	concommand.Add( "send_ghost", function(ply, cmd, args)
		local pos = ghostPos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to Ghost Town")
	end)

	concommand.Add( "send_khans", function(ply, cmd, args)
		local pos = khansPos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to Khans")
	end)

	concommand.Add( "send_ncr", function(ply, cmd, args)
		local pos = ncrPos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to NCR")
	end)

	concommand.Add( "send_bos", function(ply, cmd, args)
		local pos = bosPos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to BOS")
	end)

	concommand.Add( "send_legion", function(ply, cmd, args)
		local pos = legionPos
		local ent = ply:GetEyeTrace().Entity

		ent:SetPos(pos + Vector(math.random(50), math.random(50), math.random(50)))
		ply:ChatPrint("[ SEND_ ] Entity sent to Legion")
	end)
end

/**concommand.Add( "bench_getfaction", function(ply, cmd, args)
	print("Scanning entity . . .")
	local ent = ply:GetEyeTrace().Entity
	local faction = ent:getNetVar("faction")
	local classes = ent:getNetVar("classes")

	if isstring(ent:getNetVar("faction")) then
		ply:ChatPrint(faction)
	end
	if istable(ent:getNetVar("classes")) then
		PrintTable(classes)
	end
	--PrintTable(ent:getNetVar("classes"))
	print("Scan ended . . .")
end)**/

if SERVER then
	local pos = nil

	concommand.Add( "set_pos", function(ply, cmd, args)
		pos = ply:GetPos()
		ply:ChatPrint("[ CHAOS ] Position vector saved . . .")
	end)

	concommand.Add( "send_pos", function(ply, cmd, args)
		ent = ply:GetEyeTrace().Entity

		if IsValid(ent) then
			ent:SetPos(pos)
			ply:ChatPrint("[ CHAOS ] Sending entity to specified vector . . .")
			return
		end

		ply:ChatPrint("[ CHAOS ] Invalid Entity!")
	end)

	concommand.Add( "set_u", function(ply, cmd, args)
		ent = Entity(2992)

		if IsValid(ent) then
			ent:SetPos(pos)
			ply:ChatPrint("[ CHAOS ] Sending entity to unqiue vector . . .")
			return
		end
	end)
end

concommand.Add( "bringbenches", function()
	for k, v in pairs(ents.FindByClass("workbench")) do
		v:SetPos(Entity(1):GetPos())
		v:SetAngles(Angle(0,90))
		v:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
end)

concommand.Add( "bringstorages", function()
	for k, v in pairs(ents.FindByClass("faction-storage")) do
		v:SetPos(Entity(1):GetPos())
		v:SetAngles(Angle(0,90))
		v:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
end)

concommand.Add( "workbenchcolis", function()
	for k, v in pairs(ents.FindByClass("workbench")) do
		v:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
end)

concommand.Add( "getentindex", function()
	if SERVER then
		local traceEnt = Entity(1).GetEyeTrace().Entity
		print("[CHAOS] Entity Index is :" .. traceEnt:GetEntIndex())
	end
end)
