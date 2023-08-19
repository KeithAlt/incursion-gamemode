--[[
	Serialization library
	Purpose: for serializing/deserializing commonly used objects
]]

function jlib.SerializeVector(vector)
	return util.TableToJSON({pos.x, pos.y, pos.z})
end

function jlib.DeserializeVector(data)
	return Vector(unpack(util.JSONToTable(data)))
end

function jlib.SerializeAngle(ang)
	return util.TableToJSON({ang.p, ang.y, ang.r})
end

function jlib.DeserializeAngle(data)
	return Angle(unpack(util.JSONToTable(data)))
end
