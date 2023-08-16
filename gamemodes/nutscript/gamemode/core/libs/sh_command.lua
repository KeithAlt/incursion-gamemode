nut.command = nut.command or {}
nut.command.list = nut.command.list or {}
local PLAYER = FindMetaTable("Player")

local COMMAND_PREFIX = "/"

-- Adds a new command to the list of commands.
function nut.command.add(command, data)
	data.syntax = data.syntax or "[none]"

	if !data.onRun and !data.onRunClient then
		return ErrorNoHalt("Command '"..command.."' does not have a callback, not adding!\n")
	end

	if !data.onCheckAccess then
		if data.adminOnly then
			data.onCheckAccess = PLAYER.IsAdmin
		elseif data.superAdminOnly then
			data.onCheckAccess = PLAYER.IsSuperAdmin
		elseif data.group then
			if istable(data.group) then
				data.onCheckAccess = function(client)
					for _, group in ipairs(data.group) do
						if client:IsUserGroup(group) then
							return true
						end
					end

					return false
				end
			elseif isstring(data.group) then
				data.onCheckAccess = function(client)
					return client:IsUserGroup(data.group)
				end
			end
		end
	end

	local onCheckAccess = data.onCheckAccess

	if onCheckAccess then
		local onRun = data.onRun

		data._onRun = data.onRun
		data.onRun = function(client, arguments)
			if (!onCheckAccess(client)) then
				return "@noPerm"
			else
				if isfunction(onRun) then
					return onRun(client, arguments)
				end
			end
		end
	end

	local alias = data.alias

	if alias then
		if istable(alias) then
			for _, a in ipairs(alias) do
				nut.command.list[a] = data
			end
		elseif isstring(alias) then
			nut.command.list[alias] = data
		end
	end

	nut.command.list[command] = data
end

-- Returns whether or not a player is allowed to run a certain command.
function nut.command.hasAccess(client, command)
	command = nut.command.list[command]

	if command then
		if command.onCheckAccess then
			return command.onCheckAccess(client)
		else
			return true
		end
	end

	return false
end

-- Gets a table of arguments from a string.
function nut.command.extractArgs(text)
	local skip = 0
	local arguments = {}
	local curString = ""

	for i = 1, #text do
		if (i <= skip) then continue end

		local c = text:sub(i, i)

		if (c == "\"") then
			local match = text:sub(i):match("%b"..c..c)

			if (match) then
				curString = ""
				skip = i + #match
				arguments[#arguments + 1] = match:sub(2, -2)
			else
				curString = curString..c
			end
		elseif (c == " " and curString != "") then
			arguments[#arguments + 1] = curString
			curString = ""
		else
			if (c == " " and curString == "") then
				continue
			end

			curString = curString..c
		end
	end

	if (curString != "") then
		arguments[#arguments + 1] = curString
	end

	return arguments
end

if (SERVER) then
	util.AddNetworkString("NSCmdRunClient")

	-- Finds a player or gives an error notification.
	function nut.command.findPlayer(client, name)
		local target = type(name) == "string" and nut.util.findPlayer(name) or NULL

		if (IsValid(target)) then
			return target
		else
			client:notifyLocalized("plyNoExist")
		end
	end

	-- Forces a player to run a command.
	function nut.command.run(client, command, arguments)
		local cmdTbl = nut.command.list[command]

		if cmdTbl then
			if cmdTbl.onRunClient then
				net.Start("NSCmdRunClient")
					net.WriteString(command)
					jlib.WriteCompressedTable(arguments)
				net.Send(client)
			end

			if cmdTbl.onRun then
				local results = {cmdTbl.onRun(client, arguments or {})}
				local result = results[1]

				if type(result) == "string" then
					if IsValid(client) then
						if result:sub(1, 1) == "@" then
							client:notifyLocalized(result:sub(2), unpack(results, 2))
						else
							client:notify(result)
						end
					else
						print(result)
					end
				end
			end
		end
	end

	-- Add a function to parse a regular chat string.
	function nut.command.parse(client, text, realCommand, arguments)
		if (realCommand or text:utf8sub(1, 1) == COMMAND_PREFIX) then
			-- See if the string contains a command.

			local match = realCommand or text:lower():match(COMMAND_PREFIX.."([_%w]+)")

			-- is it unicode text?
			-- i hate unicode.
			if (!match) then
				local post = string.Explode(" ", text)
				local len = string.len(post[1])

				match = post[1]:utf8sub(2, len)
			end

			local command = nut.command.list[match]
			-- We have a valid, registered command.
			if (command) then
				-- Get the arguments like a console command.
				if (!arguments) then
					arguments = nut.command.extractArgs(text:sub(#match + 3))
				end

				-- Runs the actual command.
				nut.command.run(client, match, arguments)

				if (!realCommand) then
					nut.log.add(client, "command", text)
				end
			else
				if (IsValid(client)) then
					client:notifyLocalized("cmdNoExist")
				else
					print("Sorry, that command does not exist.")
				end
			end

			return true
		end

		return false
	end

	concommand.Add("nut", function(client, _, arguments)
		local command = arguments[1]
		table.remove(arguments, 1)

		nut.command.parse(client, nil, command or "", arguments)
	end)

	netstream.Hook("cmd", function(client, command, arguments)
		if ((client.nutNextCmd or 0) < CurTime()) then
			local arguments2 = {}

			for k, v in ipairs(arguments) do
				if (type(v) == "string" or type(v) == "number") then
					arguments2[#arguments2 + 1] = tostring(v)
				end
			end

			nut.command.parse(client, nil, command, arguments2)
			client.nutNextCmd = CurTime() + 0.2
		end
	end)
else
	function nut.command.send(command, ...)
		netstream.Start("cmd", command, {...})
	end

	function nut.command.run(command, args)
		local cmdTbl = nut.command.list[command]

		if cmdTbl and cmdTbl.onRunClient then
			return cmdTbl.onRunClient(args)
		end
	end

	net.Receive("NSCmdRunClient", function()
		local cmd = net.ReadString()
		local args = jlib.ReadCompressedTable()
		local cmdTbl = nut.command.list[cmd]

		if cmdTbl and (!cmdTbl.onCheckAccess or cmdTbl.onCheckAccess(LocalPlayer())) then
			nut.command.run(cmd, args)
		end
	end)
end
