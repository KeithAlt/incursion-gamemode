function PLUGIN:SanitizeSteamID(sid)
	for _, char in ipairs(string.Explode("", sid, false)) do
		if !tonumber(char) then
			return false
		end
	end
	return sid
end

function PLUGIN:GenerateReport(steamID64)
	steamID64 = self:SanitizeSteamID(steamID64)
	if !steamID64 then return {} end

	local characters = {}

	local fields = "_id, _name, _desc, _model, _attribs, _data, _money, _faction"
	local condition = "_schema = '"..nut.db.escape(SCHEMA.folder).."' AND _steamID = "..steamID64

	nut.db.query("SELECT "..fields.." FROM nut_characters WHERE "..condition, function(data)
		for k, v in ipairs(data or {}) do
			local id = tonumber(v._id)

			if (id) then
				characters[id] = {}

				local data = {}

				for k2, v2 in pairs(nut.char.vars) do
					if (v2.field and v[v2.field]) then
						local value = tostring(v[v2.field])

						if (type(v2.default) == "number") then
							value = tonumber(value) or v2.default
						elseif (type(v2.default) == "boolean") then
							value = tobool(vlaue)
						elseif (type(v2.default) == "table") then
							value = util.JSONToTable(value)
						end

						data[k2] = value
					end
				end

				characters[id].data = data

				nut.db.query("SELECT _invID FROM nut_inventories WHERE _charID = "..id, function(data)
					if (data and #data > 0) then
						for x, y in pairs(data) do
							characters[id].invID = y._invID
						end
					end
				end)

				nut.db.query("SELECT _uniqueID FROM nut_items WHERE _invID = "..characters[id].invID, function(data)
					if (data and #data > 0) then
						local items = {}

						for x, y in pairs(data) do
							items[#items + 1] = y._uniqueID
						end

						characters[id].inv = items
					end
				end)

				nut.db.query("SELECT _items FROM nut_stash WHERE _charID = "..id, function(data)
					if (data and #data > 0) then
						local items = {}
						local itms = {}

						for x, y in pairs(data) do
							items = util.JSONToTable(y._items)
						end

						for x, y in pairs(items) do
							nut.db.query("SELECT _uniqueID FROM nut_items WHERE _itemID = "..x, function(data)
								if (data and #data > 0) then
									for a, b in pairs(data) do
										itms[#itms + 1] = b._uniqueID
									end
								end
							end)
						end

						characters[id].stash = itms
					end
				end)
			end
		end
	end)

	return characters
end

function PLUGIN:SendReport(reportPly, receiver)
	netstream.Start(receiver, "nutReport", self:GenerateReport(reportPly:SteamID64()))
end
