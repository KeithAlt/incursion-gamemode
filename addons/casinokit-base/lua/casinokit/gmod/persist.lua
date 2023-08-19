local db = CasinoKit.metso.get("casinokit")

db:query([[
	CREATE TABLE IF NOT EXISTS ckit_persist (
		id INTEGER PRIMARY KEY,
		map VARCHAR(64),
		cls VARCHAR(64),
		pos TEXT,
		ang TEXT,
		extras TEXT
	);
]]):next(nil, function(e)
	ErrorNoHalt("[CasinoKit] Failed to create persist table: " .. tostring(e))
end)

local function vec2str(vec) return string.format("%f:%f:%f", vec.x, vec.y, vec.z) end
local function str2vec(str) local x,y,z = str:match("(%-?[%d%.]+):(%-?[%d%.]+):(%-?[%d%.]+)"); return Vector(tonumber(x), tonumber(y), tonumber(z)) end

local function ang2str(ang) return string.format("%f:%f:%f", ang.p, ang.y, ang.r) end
local function str2ang(str) local x,y,z = str:match("(%-?[%d%.]+):(%-?[%d%.]+):(%-?[%d%.]+)"); return Angle(tonumber(x), tonumber(y), tonumber(z)) end

function CasinoKit.restorePersistedEnts()
	db:query("SELECT * FROM ckit_persist WHERE map = ?", {game.GetMap()}):done(function(pents)
		for _,etbl in pairs(pents) do
			local e = ents.Create(etbl.cls)
			e:SetPos(str2vec(etbl.pos))
			e:SetAngles(str2ang(etbl.ang))
			e:Spawn()
			e:Activate()

			e:CKit_SetPersistedNWFlag(true)
			e.CKitPersistId = tonumber(etbl.id)

			local extras = util.JSONToTable(etbl.extras)

			if e.CKitPersistRestore then
				e:CKitPersistRestore(extras)
			end

			local phys = e:GetPhysicsObject()
			if IsValid(phys) then phys:EnableMotion(false) end
		end
	end)
end
function CasinoKit.savePersistedEnts()
	-- no-op
end

local function serializeEnt(e)
	local extras = {}
	if e.CKitPersistSave then
		local b, err = pcall(e.CKitPersistSave, e, extras)
		if not b then
			MsgN("[CasinoKit] Failed to persist ckit data for " .. e:GetClass() .. ": " .. err)
		end
	end

	return { cls = e:GetClass(), pos = vec2str(e:GetPos()), ang = ang2str(e:GetAngles()), extras = util.TableToJSON(extras) }
end

function CasinoKit.persistEntity(e)
	local ser = serializeEnt(e)

	db:insert("INSERT INTO ckit_persist (map, cls, pos, ang, extras) VALUES (?, ?, ?, ?, ?)", {
		game.GetMap(),
		ser.cls,
		ser.pos,
		ser.ang,
		ser.extras
	}):done(function(id)
		e.CKitPersistId = id
		e:CKit_SetPersistedNWFlag(true)
	end)
end
function CasinoKit.updatePersistedEntity(e)
	assert(not not e.CKitPersistId)

	local ser = serializeEnt(e)

	db:query("UPDATE ckit_persist SET pos = ?, ang = ?, extras = ? WHERE id = ?", {
		ser.pos,
		ser.ang,
		ser.extras,

		e.CKitPersistId
	})
end
function CasinoKit.unpersistEntity(ent)
	assert(not not ent.CKitPersistId)

	db:query("DELETE FROM ckit_persist WHERE id = ?", {ent.CKitPersistId}):done(function()
		ent:CKit_SetPersistedNWFlag(false)
		ent.CKitPersistId = nil
	end)
end

concommand.Add("casinokit_persistthis", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	local tre = ply:GetEyeTrace().Entity
	if not IsValid(tre) or not tre:CKit_IsPersistable() then ply:ChatPrint("invalid " .. tostring(tre)) return end

	CasinoKit.persistEntity(tre)
	ply:ChatPrint("done " .. tostring(tre))
end)
concommand.Add("casinokit_unpersistmap", function(ply)
	if IsValid(ply) then return end

	db:query("DELETE FROM ckit_persist WHERE map = ?", {game.GetMap()}):done(function()
		for _,e in pairs(ents.GetAll()) do
			if e.CKitPersistId then
				e:CKit_SetPersistedNWFlag(false)
			end
		end
	end)
end)

concommand.Add("casinokit_exportpersisted", function(ply)
	if IsValid(ply) then return end

	db:query("SELECT * FROM ckit_persist"):done(function(t)
		file.Write("ckit_pdump.txt", util.TableToJSON(t))
		print("Export complete. See data/ckit_pdump.txt")
	end)
end)
concommand.Add("casinokit_importpersisted", function(ply)
	if IsValid(ply) then return end

	if not file.Exists("ckit_pdump.txt", "DATA") then
		error("No ckit_pdump.txt")
		return
	end

	local data = file.Read("ckit_pdump.txt", "DATA")

	db:query("DELETE FROM ckit_persist"):done(function()
		for _,ser in pairs(util.JSONToTable(data)) do
			db:insert("INSERT INTO ckit_persist (map, cls, pos, ang, extras) VALUES (?, ?, ?, ?, ?)", {
				ser.map,
				ser.cls,
				ser.pos,
				ser.ang,
				ser.extras
			})
		end

		print("done")
	end)
end)

hook.Add("InitPostEntity", "CKitPersistenceRestore", function()
	timer.Simple(3, CasinoKit.restorePersistedEnts)
end)
hook.Add("PostCleanupMap", "CKitPersistenceRestore", CasinoKit.restorePersistedEnts)