-- Retrieve the class name of unique
local function getCharClassName(uniqueID)
	for index, class in pairs(nut.class.list) do
		if class.uniqueID == uniqueID then
			return class.name
		end
	end
end

-- Send our character data strings to staff
net.Receive("getCharacterData", function(len, pl)
	for i, v in ipairs(nut.characters) do
		local character = nut.char.loaded[v]

		local string =
		"\n	Character: " .. character.vars.name ..
		"\n 	|_ Class: " .. getCharClassName(character.vars.data.class) ..
		"\n 	|_ Money: " .. character.vars.money ..
		"\n 	|_ Flags: " .. character.vars.data.f ..
		"\n	============"

		net.Start("readCharacterData")
			net.WriteString(string)
		net.SendToServer()
	end;

	for index, fac in pairs(nut.faction.indices) do
		if nut.faction.hasWhitelist(index) == true then
			string = "\n 	|_ " .. fac.name

			net.Start("readCharacterData")
				net.WriteString(string)
			net.SendToServer()
		end
	end
end)
