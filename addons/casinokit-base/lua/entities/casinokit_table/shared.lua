ENT.Type = "anim"
ENT.Editable = true

ENT.CasinoKitTable = true
ENT.SeatCount = 4

ENT.SeatData = {
	model = "models/props_combine/breenchair.mdl",
	lpos = Vector(0, 0, 15),
	lang = Angle(0, -90, 0)
}

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ClGameClass")
	self:NetworkVar("String", 1, "DealerId", { KeyName = "dealerid", Edit = { type = "Generic", category = "Casino Kit", order = 5 } })

	if SERVER then
		self:NetworkVarNotify("DealerId", self.OnDealerIdChanged)
	end
end

function ENT:Setowning_ent(ent)
	if ent:IsPlayer() then
		self.TableOwner = ent
	end
end

function ENT:CanConfigureTable(ply)
	return ply:IsSuperAdmin() or self:GetOwner() == ply
end

-- angle in radians of opposite of dealer
local startAng = math.rad(90)

-- angle per seat
local angPerSeat = math.rad(1)

local d = {}
local function Deprecate(msg)
	local dbg = debug.getinfo(3, "Sl")
	local srcstr = string.format("%s@%d", dbg.source, dbg.currentline)

	if d[srcstr] then return end
	d[srcstr] = true

	if not msg then
		local thisdbg = debug.getinfo(2, "n")
		msg = thisdbg.name .. "() is deprecated"
	end
	print("[Deprecation Warning] " .. msg .. " (called at " .. srcstr .. ")")
end

function ENT:SeatIndexOrientation(i, offset)
	Deprecate()

	return self:SeatToLocal(i, offset)
end

-- The dealer's position in radians
ENT.DealerAngle = 0

-- The distance of dealer from center
ENT.DealerDistance = 50

-- The distance from origin at which the seat normal lines are cached and used for position
ENT.SeatNormalBaseDistance = 40

-- ellipse A and B variables to define approximate table shape
ENT.TableEllipseA = 1
ENT.TableEllipseB = 1

-- Convert seat index (which can be a fraction) to a local position
-- seat should be between 0 and SeatCount, where 0 = dealer position
function ENT:SeatToLocal(seat, offset)
	-- TODO move cache creation to Initialize
	if not self._STLCache then
		self._STLCache = {}
	end

	local cache = self._STLCache[seat]
	if not cache then
		-- Calculate radians for this seat
		local radPerSeat = (math.pi * 2) / (self.SeatCount + 1)
		local rad = self.DealerAngle + seat * radPerSeat

		-- Calculate normal on ellipse
		local a, b = self.TableEllipseA, self.TableEllipseB
		local px, py = a*math.cos(rad), b*math.sin(rad) -- position of ellipse vertex
		local nx, ny = px*b/a, py*a/b -- normal of ellipse vertex

		-- Calculate normal line equation on normal base distance to get intersection point on X axis
		local normalBaseDistance = self.SeatNormalBaseDistance
		local normalBaseX, normalBaseY = px * normalBaseDistance, py * normalBaseDistance

		-- line equation for ellipse vertex normal at base distance
		local slope = nx / ny
		local d = normalBaseX - slope*normalBaseY -- figure out d from line eq
		local isectX = (ny == 0 or slope == 0) and 0 or (d / (-slope)) -- do line-line intersection to get X

		cache = {isectX, px, py, nx, ny, (-Vector(nx, ny)):Angle()}
		self._STLCache[seat] = cache
	end

	local ea, eb = self.TableEllipseA, self.TableEllipseB

	-- fetch from cached array
	local isectX, px, py, nx, ny, normalAngle = unpack(cache)

	offset = offset or 45

	local pos = Vector(nx*offset*ea, isectX + ny*offset*eb, 0)
	local ang = Angle(normalAngle.p, normalAngle.y, normalAngle.r)
	return pos, ang
end

function ENT:GetCachedSeatindexPlyTuples()
	if self._cachedSIPT and self._cachedSIPTExpire > CurTime() then
		return self._cachedSIPT
	end

	local r = {}
	for _,seat in pairs(self:GetChildren()) do
		local sitter = seat.GetSitter and seat:GetSitter()
		if IsValid(sitter) then
			table.insert(r, {seat:GetSeatIndex(), sitter})
		end
	end

	self._cachedSIPT = r
	self._cachedSIPTExpire = CurTime() + 1
	return r
end