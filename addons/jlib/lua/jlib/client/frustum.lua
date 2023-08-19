jlib.Frustum = jlib.Frustum or {}

-- Replaced by jlib.MinMaxToVertices
// jlib.Frustum.MinMaxToBox = jlib.MinMaxToVertices

-- Frustum meta
FrustumMeta = {}
FrustumMeta.__index = FrustumMeta

-- Enums
PLANE_TOP = 0
PLANE_BOTTOM = 1
PLANE_LEFT = 2
PLANE_RIGHT = 3
PLANE_NEAR = 4
PLANE_FAR = 5

INSIDE = 1
OUTSIDE = 2
INTERSECT = 3

function FrustumMeta:Create()
	local frustum = {}
	setmetatable(frustum, FrustumMeta)
	frustum.Planes = {
		[0] = Plane:Create(),
		[1] = Plane:Create(),
		[2] = Plane:Create(),
		[3] = Plane:Create(),
		[4] = Plane:Create(),
		[5] = Plane:Create()
	}

	return frustum
end

function FrustumMeta:SetCamData(origin, angle, fov, ratio, znear, zfar)
	self.Origin = origin
	self.Ang = angle
	self.FOV = fov
	self.Ratio = ratio
	self.ZNear = znear
	self.ZFar = zfar
end

function FrustumMeta:GetCamData()
	return self.Origin, self.Ang, self.FOV, self.Ratio, self.ZNear, self.ZFar
end

function FrustumMeta:Calculate()
	local origin, ang, fov, aspectRatio, znear, zfar = self:GetCamData()

	-- The data we'll need
	local forward = -ang:Forward()
	local up = ang:Up()
	local right = ang:Right()
	local fovRad = math.rad(fov)

	-- Width and height of near plane
	local nearH = math.tan(fovRad / 2) * znear
	local nearW = nearH * aspectRatio

	-- Width and height of far plane
	local farH = math.tan(fovRad / 2) * zfar
	local farW = farH * aspectRatio

	-- Get the center of both planes
	local nearC = origin - forward * znear
	local farC = origin - forward * zfar

	-- Get all 4 corners of each plane
	self.nearTL = nearC + up * nearH - right * nearW -- Top left
	self.nearTR = nearC + up * nearH + right * nearW -- Top right
	self.nearBL = nearC - up * nearH - right * nearW -- Bottom left
	self.nearBR = nearC - up * nearH + right * nearW -- Bottom right

	self.farTL = farC + up * farH - right * farW -- Top left
	self.farTR = farC + up * farH + right * farW -- Top right
	self.farBL = farC - up * farH - right * farW -- Bottom left
	self.farBR = farC - up * farH + right * farW -- Bottom right

	self.Planes[PLANE_TOP]:Set3Points(self.nearTR, self.nearTL, self.farTL)
	self.Planes[PLANE_BOTTOM]:Set3Points(self.nearBL, self.nearBR, self.farBR)
	self.Planes[PLANE_LEFT]:Set3Points(self.nearTL, self.nearBL, self.farBL)
	self.Planes[PLANE_RIGHT]:Set3Points(self.nearBR, self.nearTR, self.farBR)
	self.Planes[PLANE_NEAR]:SetNormalAndPoint(-forward, nearC)
	self.Planes[PLANE_FAR]:SetNormalAndPoint(forward, farC)
	//self.Planes[PLANE_NEAR]:Set3Points(self.nearTL, self.nearTR, self.nearBR)
	//self.Planes[PLANE_FAR]:Set3Points(self.farTR, self.farTL, self.farBL)
end

function FrustumMeta:PointInFrustum(vec)
	for i = 0, 5 do
		local plane = self.Planes[i]

		if !IsValid(plane) then continue end

		local dist = plane:Distance(vec)
		if dist < 0 then
			return false
		end
	end

	return true
end

function FrustumMeta:BoxInFrustum(box) -- FIXME: Needs eval
	local result = INSIDE

	for i = 0, 5 do
		local inCount, outCount = 0, 0
		local plane = self.Planes[i]

		if !IsValid(plane) then continue end

		for k = 1, 8 do
			if plane:Distance(box[k]) < 0 then
				outCount = outCount + 1
			else
				inCount = inCount + 1
			end
		end

		if inCount == 0 then
			return OUTSIDE
		elseif outCount > 0 then
			result = INTERSECT
		end
	end

	return result
end

function FrustumMeta:DrawLines()
	-- Near plane
	render.DrawLine(self.nearTR, self.nearTL)
	render.DrawLine(self.nearTL, self.nearBL)
	render.DrawLine(self.nearBL, self.nearBR)
	render.DrawLine(self.nearBR, self.nearTR)

	-- Far plane
	render.DrawLine(self.farTR, self.farTL)
	render.DrawLine(self.farTL, self.farBL)
	render.DrawLine(self.farBL, self.farBR)
	render.DrawLine(self.farBR, self.farTR)

	-- Bottom plane
	render.DrawLine(self.nearBR, self.nearBL)
	render.DrawLine(self.nearBL, self.farBL)
	render.DrawLine(self.farBL, self.farBR)
	render.DrawLine(self.farBR, self.nearBR)

	-- Top plane
	render.DrawLine(self.nearTR, self.nearTL)
	render.DrawLine(self.nearTL, self.farTL)
	render.DrawLine(self.farTL, self.farTR)
	render.DrawLine(self.farTR, self.nearTR)

	-- Left plane
	render.DrawLine(self.nearTL, self.nearBL)
	render.DrawLine(self.nearBL, self.farBL)
	render.DrawLine(self.farBL, self.farTL)
	render.DrawLine(self.farTL, self.nearTL)

	-- Right plane
	render.DrawLine(self.nearTR, self.nearBR)
	render.DrawLine(self.nearBR, self.farBR)
	render.DrawLine(self.farBR, self.farTR)
	render.DrawLine(self.farTR, self.nearTR)
end

function FrustumMeta:DrawNormals()
	local a, b = LocalPlayer():EyePos()

	-- Near plane
	if IsValid(self.Planes[PLANE_NEAR]) then
		b = a + self.Planes[PLANE_NEAR].normal * 50
		render.DrawLine(a, b, Color(255, 0, 0, 150))
	end

	-- Far plane
	if IsValid(self.Planes[PLANE_FAR]) then
		b = a + self.Planes[PLANE_FAR].normal * 50
		render.DrawLine(a, b, Color(0, 255, 0, 150))
	end

	-- Bottom plane
	if IsValid(self.Planes[PLANE_BOTTOM]) then
		b = a + self.Planes[PLANE_BOTTOM].normal * 50
		render.DrawLine(a, b, Color(255, 255, 0, 150))
	end

	-- Top plane
	if IsValid(self.Planes[PLANE_TOP]) then
		b = a + self.Planes[PLANE_TOP].normal * 50
		render.DrawLine(a, b, Color(0, 0, 255, 150))
	end

	-- Left plane
	if IsValid(self.Planes[PLANE_LEFT]) then
		b = a + self.Planes[PLANE_LEFT].normal * 50
		render.DrawLine(a, b, Color(255, 0, 255, 150))
	end

	-- Right plane
	if IsValid(self.Planes[PLANE_RIGHT]) then
		b = a + self.Planes[PLANE_RIGHT].normal * 50
		render.DrawLine(a, b, Color(0, 255, 255, 150))
	end
end

-- Create our global frustum
hook.Add("PlanesLoaded", "FrustumInit", function()
	Frustum = FrustumMeta:Create()
end)

-- Calculate the planes
hook.Add("HookProtect", "Frustum", function()
	HookProtect.CacheExisting("CalcView")
	HookProtect.CacheFuture("CalcView")
	HookProtect.Detour("CalcView", function(ply, origin, ang, fov, znear, zfar)
		if jlib.Frustum.DontCalcView then
			return
		end
		jlib.Frustum.DontCalcView = true
		local camData = HookProtect.RunHook("CalcView", ply, origin, ang, fov, znear, zfar)
		jlib.Frustum.DontCalcView = nil

		if istable(camData) then
			origin = camData.origin or origin
			ang = camData.angles or ang
			fov = camData.fov or fov
		end

		Frustum:SetCamData(origin, ang, fov, ScrW() / ScrH(), znear, zfar)
		Frustum:Calculate()

		return camData
	end)
end)

-- Debug drawing
jlib.Frustum.Colors = {
	[INSIDE] = Color(0, 255, 0, 50),
	[OUTSIDE] = Color(255, 0, 0, 50),
	[INTERSECT] = Color(255, 255, 0, 50)
}

jlib.Frustum.SkipEnts = {
	["viewmodel"] = true,
	["gmod_hands"] = true
}

hook.Add("PostDrawOpaqueRenderables", "FrustumDraw", function()
	if GetConVar("frustumdebug"):GetBool() then
		Frustum:DrawLines()
		Frustum:DrawNormals()

		for i, ent in ipairs(ents.GetAll()) do
			local mins, maxs = ent:GetRenderBounds()
			local pos = ent:GetPos()

			if ent == LocalPlayer() or ent:GetParent() == LocalPlayer() or jlib.Frustum.SkipEnts[ent:GetClass()] then continue end

			local result = Frustum:BoxInFrustum(jlib.MinMaxToVertices(pos + mins, pos + maxs))
			local color = jlib.Frustum.Colors[result]

			render.SetColorMaterial()
			render.DrawBox(pos, ent:GetAngles(), mins, maxs, color)
		end
	end
end)

CreateConVar("frustumdebug", 0, FCVAR_NONE, "Enables frustum deugging view")
