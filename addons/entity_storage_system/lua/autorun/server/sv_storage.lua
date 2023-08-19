entityVault = entityVault or {}
local mapName = game.GetMap()
entityVault.path = "entity-vault/" .. mapName

-- Logging
local function log(msg)
	MsgC(Color(0,0,255), "[VAULT] ", Color(255,255,255), msg .. "\n")
end

-- Initialize our directories
if !file.IsDir( "entity-vault", "DATA") then
	log("No vault directory detected; creating...")
	file.CreateDir("entity-vault")
	log("Vault directory created")
end

if !file.IsDir( entityVault.path, "DATA") then
	log("No " .. entityVault.path .. " directory detected; creating . . .")
	file.CreateDir(entityVault.path)
	log(entityVault.path .. " directory created")
end

-- Set our room position vectors
function entityVault.setRoomPos(vector)
	log("Updating vault room position data")

	vector = {
		["x"] = vector.x,
		["y"] = vector.y,
		["z"] = vector.z
	}

	file.Write(entityVault.path .. "/coordinates.json", util.TableToJSON(vector))
end

-- Get out room position vectors
function entityVault.getRoomPos()
	local roomPos = util.JSONToTable(file.Read(entityVault.path .. "/coordinates.json", "DATA"))
	return Vector(roomPos.x, roomPos.y, roomPos.z)
end
