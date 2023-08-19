Areas = Areas or {}

--Networking
net.Receive("AreasPlayerJoin", function()
	local areas = jlib.ReadCompressedTable()
	for i, area in pairs(areas) do
		setmetatable(area, Areas.Meta)
		Areas.Instances[i] = area
	end

	for i, ply in ipairs(player.GetAll()) do
		if ply:GetArea() then
			ply:GetArea():AddPlayer(ply)
		end
	end
end)

net.Receive("AreasInstance", function()
	local area = jlib.ReadCompressedTable()
	setmetatable(area, Areas.Meta)
	Areas.Instances[area.ID] = area
end)

net.Receive("AreasAddPlayer", function()
	local areaID = net.ReadInt(32)
	local ply = net.ReadEntity()
	Areas.Instances[areaID]:AddPlayer(ply)
end)

net.Receive("AreasRemovePlayer", function()
	local areaID = net.ReadInt(32)
	local ply = net.ReadEntity()

	if Areas.Instances[areaID] then
		Areas.Instances[areaID]:RemovePlayer(ply)
	else
		ErrorNoHalt("Attempted to remove player from invalid AreaID[" .. (areaID or "NIL") .. "]")
	end
end)

net.Receive("AreasSetBounds", function()
	local areaID = net.ReadInt(32)
	local mins = net.ReadVector()
	local maxs = net.ReadVector()
	Areas.Instances[areaID]:SetBounds(mins, maxs)
end)

net.Receive("AreasSetName", function()
	local areaID = net.ReadInt(32)
	local name = net.ReadString()
	Areas.Instances[areaID]:SetName(name)
end)

net.Receive("AreasSetFac", function()
	local areaID = net.ReadInt(32)
	local fac = net.ReadInt(32)
	Areas.Instances[areaID]:SetFactionUID(fac)
end)

net.Receive("AreasRemove", function()
	local areaID = net.ReadInt(32)
	Areas.Instances[areaID]:Remove()
end)

local function drawCaptureBar()
	local client = LocalPlayer()
	local renderBool = LocalPlayer().renderBool
	local bar = client.startAreaCaptureTime or false

	if bar and renderBool then
		local progress = (CurTime() - bar) * 0.1
		jlib.DrawProgressBar(ScrW() * 0.3, ScrH() * 0.6, ScrW() * 0.4, 40, progress, "Capturing", true, Color(50,200,50,100))
	else
		client.startAreaCaptureTime = nil
	end
end

net.Receive("AreasDrawCaptureBar", function()
	local renderBool = net.ReadBool() or !LocalPlayer().renderBool

	LocalPlayer().startAreaCaptureTime = CurTime()
	LocalPlayer().renderBool = renderBool
	drawCaptureBar()
end)

hook.Add("HUDPaint", "drawAreaCaptureProgressBar", drawCaptureBar)
