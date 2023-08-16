jlib.Plane = jlib.Plane or {}

local Vector3 = FindMetaTable("Vector")

-- Plane meta
Plane = {}
Plane.__index = Plane

function Plane:__tostring()
	return IsValid(self) and ("Plane [" .. self.a .. ", " .. self.b .. ", " .. self.c .. ", " .. self.d .. "]") or "Plane [NULL]"
end

function Plane:IsValid()
	return self.a and self.b and self.c and self.d
end

function Plane:Create()
	local plane = {}
	setmetatable(plane, Plane)

	return plane
end

function Plane:SetNormalAndPoint(normal, p)
	normal:Normalize()

	self.a = normal.x
	self.b = normal.y
	self.c = normal.z
	self.d = -p:Dot(normal)
	self.normal = normal
	self.point = p

	return self
end

-- Points must be given in counter clockwise order
function Plane:Set3Points(p, v1, v2)
	local normal = Vector3.Cross(v1 - p, v2 - p)
	return self:SetNormalAndPoint(normal, p)
end

function Plane:Normalize()
	local result = Plane:Create()
	local dist = math.sqrt(self.a * self.a + self.b * self.b + self.c * self.c)
	result.a = self.a / dist
	result.b = self.b / dist
	result.c = self.c / dist
	result.d = self.d / dist

	return result
end

function Plane:Distance(pt)
	return self.a * pt.x + self.b * pt.y + self.c * pt.z + self.d
end

hook.Run("PlanesLoaded")
