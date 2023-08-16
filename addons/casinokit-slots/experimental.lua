hook.Add("HUDPaint", "asd", function()
	local fovy, aspectRatio = 120, 9 / 16
	local l_fd = 1 / math.tan((fovy * (math.pi / 180)) / 2)
	local l_a1 = (100 + 0.01) / (0.01 - 100)
	local l_a2 = (2 * 100 * 0.01) / (0.01 - 100)
	local t = Matrix {
		{ l_fd / aspectRatio, 0, 0, 0 },
		{ 0, l_fd, 0, 0 },
		{ 0, 0, l_a1, -1 },
		{ 0, 0, l_a2, 0 },
	}

	surface.SetDrawColor(255, 255, 255)
	for y=0,10 do
		for x=0,10 do
			local v = t * Vector(x / 10 - 0.5, y / 10 - 0.5, 0)
			surface.DrawRect(200 + v.x * 10 * 20 - 2, 200 + v.y * 10 * 20 - 2, 4, 4)
		end
	end
end)

local function easefunc(f)
	--[[
	f = f * 2

	if f < 1 then
		return 0.5 * f * f
	else
		f = f - 1
		return -0.5 * (f * (f-2) - 1)
	end]]
	f = f - 1
	return f*f*f + 1
	--return -1 * f * (f-2)
end

local height_segments = 3

local mat = Material("models/wireframe")
local mats = {
	[0] = Material("models/casinokit/slots/fruits/apple.png"),
	Material("models/casinokit/slots/fruits/apple.png"),
	Material("models/casinokit/slots/fruits/banana.png"),
	Material("models/casinokit/slots/fruits/lemon.png"),
	Material("models/casinokit/slots/fruits/orange.png"),
	Material("models/casinokit/slots/fruits/pear.png"),
	Material("models/casinokit/slots/fruits/strawberry.png"),
	Material("models/casinokit/slots/fruits/seven.png"),
}
local itemCount = 8
local wheelSpeeds = {
	2400,
	1800,
	1000
}
local wheelFullRotations = {
	20,
	15,
	10
}
local wheelPositions = {
	0,
	0,
	0
}
local wheelEndPosition = {
	1 + math.random(itemCount),
	1 + math.random(itemCount),
	1 + math.random(itemCount),
}
local wheelVelocities = {
	10,
	10,
	10
}
local wheelSpinStartTime = CurTime()
hook.Add("HUDPaint", "asd", function()
	render.SetMaterial(mat)
	--if true then return end

	local elapsed = CurTime() - wheelSpinStartTime

	--cam.Start3D()
	surface.SetDrawColor(255, 255, 255)
	surface.DrawRect(245, 50, 250, 200)

	for wheel=0,2 do
		local rot = Matrix()

		local vel = wheelVelocities[1 + wheel]

		local finalPos = wheelFullRotations[1 + wheel] + (wheelEndPosition[1 + wheel] / (itemCount + 1))
		--local accel = (2 * finalPos) / (spinDur * spinDur) - (2 * wheelInitVelocity) / (spinDur)
		local accel = (-(vel * vel)) / (2 * finalPos)
		local dur = (math.sqrt(2 * accel * finalPos + (vel * vel)) - vel) / accel

		local physElapsed = math.min(elapsed, dur)
		local wheelPos = (vel * physElapsed + 0.5 * accel * (physElapsed * physElapsed))
		print(wheel, wheelPos, dur)
		rot:Rotate(Angle(0, 0, wheelPos * 360))

		local proj = Matrix()
		do
			--[[
			local left, right, bottom, top, zNear, zFar =
				-5, 80, 60, -60, -60, 60

	        local x = (2.0 * zNear) / (right - left);
	        local y = (2.0 * zNear) / (top - bottom);
	        local a = (right + left) / (right - left);
	        local b = (top + bottom) / (top - bottom);
	        local c = -(zFar + zNear) / (zFar - zNear);
	        local d = -(2.0 * zFar * zNear) / (zFar - zNear);

			proj = Matrix {
				{ x, 0, 0, 0 },
				{ 0, y, 0, 0 },
				{ a, b, c, -1 },
				{ 0, 0, d, 0 },
			}]]

			local fov, aspect, near, far = 90, 9 / 16, -60, 60
			local yScale = 1 / math.tan(math.rad(fov) / 2)
			local xScale = yScale / aspect
			local nearmfar = near - far
			proj = Matrix {
				{ xScale, 0, 0, 0 },
				{ 0, yScale, 0, 0 },
				{ 0, 0, (far + near) / nearmfar, -1 },
				{ 0, 0, 2 * far * near / nearmfar, 0 },
			}
		end
		for a=0, itemCount do
			local ang_start = (math.pi * 2 / (itemCount + 1)) * a
			local ang_advance = -(math.pi * 2 / (itemCount + 1))
			local ang_advance_perseg = (ang_advance / height_segments)

			render.SetMaterial(mats[a % 7])
			mesh.Begin(MATERIAL_QUADS, height_segments)

			for i=0, height_segments-1 do
				local ang = ang_start + ang_advance_perseg * i
				local ang_next = ang_start + ang_advance_perseg * (i+1)

				local scale = 100
				local l_v = proj * rot * Vector(wheel*50 + 0, math.sin(ang) * scale, math.cos(ang) * scale)
				local l_v_n = proj * rot * Vector(wheel*50 + 0, math.sin(ang_next) * scale, math.cos(ang_next) * scale)
				local r_v = proj * rot * Vector(wheel*50 + 35, math.sin(ang) * scale, math.cos(ang) * scale)
				local r_v_n = proj * rot * Vector(wheel*50 + 35, math.sin(ang_next) * scale, math.cos(ang_next) * scale)

				local low_tex = 1 - (i+0) / height_segments
				local high_tex = 1 - (i+1) / height_segments

				mesh.Position(Vector(250 + r_v_n.x, 150 + r_v_n.y, 0)); mesh.TexCoord(0, 1, high_tex); mesh.Color(255, 255, 255, 255); mesh.AdvanceVertex()
				mesh.Position(Vector(250 + r_v.x,   150 + r_v.y, 0)); mesh.TexCoord(0, 1, low_tex); mesh.Color(255, 255, 255, 255); mesh.AdvanceVertex()
				mesh.Position(Vector(250 + l_v.x,   150 + l_v.y, 0)); mesh.TexCoord(0, 0, low_tex); mesh.Color(255, 255, 255, 255); mesh.AdvanceVertex()
				mesh.Position(Vector(250 + l_v_n.x, 150 + l_v_n.y, 0)); mesh.TexCoord(0, 0, high_tex); mesh.Color(255, 255, 255, 255); mesh.AdvanceVertex()
			end

			mesh.End()
		end
	end
	--cam.End3D()

	--hook.Remove("HUDPaint", "asd")
end)