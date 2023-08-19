local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

--[[
	GetPrintFunction
	Purpose: Return a function that prints messages with the given prefix
]]
function jlib.GetPrintFunction(prefix, prefixColor, messageColor)
	return function(...)
		local msg = {...}
		msg[#msg + 1] = "\n"
		MsgC(prefixColor or Color(255, 0, 0, 255), prefix .. " ", messageColor or Color(255, 255, 255, 255), unpack(msg))
	end
end

--[[
	Print
	Purpose: Print a message with the [jlib] prefix
]]
jlib.Print = jlib.GetPrintFunction("[jlib]")

--[[
	IsStaffFaction
	Purpose: Returns whether the given player is a member of the staff faction
]]
function jlib.IsStaffFaction(ply)
	if !ply:getChar() or !ply:getChar():getFaction() then
		return false
	end

	return nut.faction.indices[ply:getChar():getFaction()].uniqueID == "staff"
end

--[[
	AlertStaff
	Purpose: Sends a message to all staff on the server
]]
if SERVER then
	util.AddNetworkString("jlibStaffAlert")
else
	net.Receive("jlibStaffAlert", function(len, ply)
		local msg = net.ReadString()
		jlib.AlertStaff(msg)
	end)
end

function jlib.AlertStaff(msg)
	if SERVER then
		local plys = {}
		for k, ply in ipairs(player.GetAll()) do
			if ply:IsAdmin() then
				table.insert(plys, ply)
			end
		end

		net.Start("jlibStaffAlert")
			net.WriteString(msg)
		net.Send(plys)
	else
		chat.AddText(Color(255, 0, 0, 255), "[STAFF ALERT] ", Color(255, 255, 255, 255), msg)
	end
end

--[[
	GetPlayer
	Purpose: Find a player who's name matches a given search term
]]
function jlib.GetPlayer(searchTerm)
	local results = {}

	for k, ply in ipairs(player.GetAll()) do
		if ply:Nick():lower():find(searchTerm:lower()) then
			results[#results + 1] = ply
		end
	end

	if #results == 0 then
		return NULL, "No player found"
	elseif #results > 1 then
		return NULL, "Several players found, be more specific"
	elseif #results == 1 then
		return results[1]
	end
end

--[[
	TableSum
	Purpose: Recursively return the sum of all the values in the table
]]
function jlib.TableSum(tbl)
	local sum = 0

	for k, v in pairs(tbl) do
		if isnumber(v) then
			sum = sum + v
		elseif istable(v) then
			sum = sum + jlib.TableSum(v)
		end
	end

	return sum
end

--[[
	Read/Write Compressed Table
	Purpose: Read and write a compressed table from/to a net message
]]
function jlib.WriteCompressedTable(tbl)
	local json = util.TableToJSON(tbl)
	local data = util.Compress(json)
	local len  = #data

	net.WriteInt(len, 32)
	net.WriteData(data, len)
end

function jlib.ReadCompressedTable()
	local len  = net.ReadInt(32)
	local data = net.ReadData(len)
	local json = util.Decompress(data)
	local tbl  = util.JSONToTable(json)

	return tbl
end

--[[
	Read/Write Compressed String
	Purpose: Read and write a compressed string from/to a net message
]]
function jlib.WriteCompressedString(str)
	local data = util.Compress(str)
	local len  = #data

	net.WriteInt(len, 32)
	net.WriteData(data, len)
end

function jlib.ReadCompressedString()
	local len  = net.ReadInt(32)
	local data = net.ReadData(len)
	local str = util.Decompress(data)

	return str
end

--[[
	Rainbow
	Purpose: Smoothly cycles through all colors
]]
function jlib.Rainbow(frequency)
	return HSVToColor(CurTime() * frequency % 360, 1, 1)
end

--[[
	ColorCycle
	Purpose: Smoothly cycles from one color to another continuously
]]
function jlib.ColorCycle(col1, col2, freq)
	freq = freq or 1

	local difference = Color(col1.r - col2.r, col1.g - col2.g, col1.b - col2.b)

	local time = CurTime()

	local rgb = {r = 0, g = 0, b = 0}

	for k,v in pairs(rgb) do
		if col1[k] > col2[k] then
			rgb[k] = col2[k]
		else
			rgb[k] = col1[k]
		end
	end

	return Color(rgb.r + math.abs(math.sin(time * freq) * difference.r), rgb.g + math.abs(math.sin(time * freq + 2) * difference.g), rgb.b + math.abs(math.sin(time * freq + 4) * difference.b))
end

--[[
	FindPlayersInBox
	Purpose: Find only players in a given area
]]
function jlib.FindPlayersInBox(mins, maxs)
	local entsList = ents.FindInBox(mins, maxs)
	local plyList = {}

	for k, v in pairs(entsList) do
		if IsValid(v) and v:IsPlayer() then
			plyList[#plyList + 1] = v
		end
	end

	return plyList
end

--[[
	FindPlayersInSphere
	Purpose: Find all players within a sphere
]]
function jlib.FindPlayersInSphere(origin, radius)
	local plys = {}
	local r2 = radius ^ 2

	for i, ply in ipairs(player.GetAll()) do
		if ply:GetPos():DistToSqr(origin) <= r2 then
			plys[#plys + 1] = ply
		end
	end

	return plys
end

--[[
	WrapText
	Purpose: Return a word wrapped version of the input string
]]
function jlib.WrapText(lineWidth, str, font)
	surface.SetFont(font)

	local spaceLeft = lineWidth
	local spaceWidth = surface.GetTextSize(" ")

	local strTbl = string.Explode(" ", str)
	for i, word in ipairs(strTbl) do
		local wordWidth = surface.GetTextSize(word)

		if wordWidth + spaceWidth > spaceLeft then
			strTbl[i] = "\n" .. strTbl[i]

			spaceLeft = lineWidth - wordWidth
		elseif word:EndsWith("\n") then
			spaceLeft = lineWidth - wordWidth
		else
			spaceLeft = spaceLeft - (wordWidth + spaceWidth)
		end
	end

	local finalStr = ""
	for i, word in ipairs(strTbl) do
		finalStr = finalStr .. word
		if !word:EndsWith("\n") and (!strTbl[i + 1] or !strTbl[i + 1]:StartWith("\n")) and i != #strTbl then
			finalStr = finalStr .. " "
		end
	end

	local w, h = surface.GetTextSize(finalStr)

	return finalStr, h ,w
end

--[[
	RandomString
	Purpose: Return a randomly generated string of characters
]]
--0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
jlib.Chars = {}
for i = 48,  57 do table.insert(jlib.Chars, string.char(i)) end
for i = 65,  90 do table.insert(jlib.Chars, string.char(i)) end
for i = 97, 122 do table.insert(jlib.Chars, string.char(i)) end

function jlib.RandomString(len)
	local str = ""

	for i = 1, len do
		str = str .. jlib.Chars[math.random(1, #jlib.Chars)]
	end

	return str
end

--[[
	SetNWTable
	Purpose: Easily network a table for an entity
]]
if SERVER then
	util.AddNetworkString("jlibNWTable")
end

jlib.TableNetworkedEnts = jlib.TableNetworkedEnts or {}

function ENTITY:SetNWTable(key, tbl)
	self.NWTables = self.NWTables or {}

	if !IsValid(self) or !istable(tbl) or !isstring(key) then
		return
	end

	if SERVER then
		local i = table.insert(jlib.TableNetworkedEnts, self)
		self.NWTblID = i

		self:CallOnRemove("jlibRemoveNWTable", function(s)
			table.remove(jlib.TableNetworkedEnts, self.NWTblID)
		end)

		net.Start("jlibNWTable")
			jlib.WriteCompressedTable(tbl)
			net.WriteString(key)
			net.WriteEntity(self)
		net.Broadcast()

		self.NWTables[key] = tbl
	end
end

function ENTITY:GetNWTable(key, default)
	self.NWTables = self.NWTables or {}

	return self.NWTables[key] or default or {}
end

if SERVER then
	net.Receive("jlibNWTable", function(len, ply)
		for i, ent in ipairs(jlib.TableNetworkedEnts) do
			for key, tbl in pairs(ent.NWTables or {}) do
				net.Start("jlibNWTable")
					jlib.WriteCompressedTable(tbl)
					net.WriteString(key)
					net.WriteEntity(ent)
				net.Send(ply)
			end
		end
	end)
end

if CLIENT then
	net.Receive("jlibNWTable", function()
		local tbl = jlib.ReadCompressedTable()
		local key = net.ReadString()
		local ent = net.ReadEntity()

		if !IsValid(ent) then
			return
		end

		ent.NWTables = ent.NWTables or {}
		ent.NWTables[key] = tbl
	end)

	hook.Add("InitPostEntity", "jlibNWTable", function(ply)
		net.Start("jlibNWTable")
		net.SendToServer()
	end)
end

--[[
	CallAfterTicks
	Purpose: Call the given function after X number of ticks
]]
function jlib.CallAfterTicks(totalTicks, func)
	local ticks = 0
	local id = "jlib" .. tostring(func)

	hook.Add("Think", id, function()
		ticks = ticks + 1
		if totalTicks <= ticks then
			hook.Remove("Think", id)
			func()
		end
	end)
end

--[[
	UpperFirstChar
	Purpose: Replace the first character of a string with the upper case version of the same char
]]
function jlib.UpperFirstChar(str)
	return str:sub(0, 1):upper() .. str:sub(2)
end

--[[
	CommaNumber
	Purpose: Add commas to seperate thousands to a number
	Credits: Lua wiki
]]
function jlib.CommaNumber(amount)
	local formatted = amount

	while true do
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end

	return formatted
end

--[[
	Conversion Functions
]]
function jlib.UnitsToInches(units)
	return units * 0.75
end

function jlib.UnitsToCentimeters(units)
	return jlib.UnitsToInches(units) * 2.54
end

function jlib.UnitsToMeters(units)
	return jlib.UnitsToInches(units) * 0.0254
end

function jlib.ColorToHex(color)
	return "0x" .. bit.tohex(color.r, 2) .. bit.tohex(color.g, 2) .. bit.tohex(color.b, 2)
end

--[[
	GetTeamColor
]]
function jlib.GetTeamColor(ply)
	local char = ply:getChar()

	if !char then return team.GetColor(ply:Team()) end

	local classIndex = char:getClass()

	if !classIndex then return team.GetColor(ply:Team()) end

	local classTbl = nut.class.list[classIndex]

	if !classTbl then return team.GetColor(ply:Team()) end

	return classTbl.Color or team.GetColor(ply:Team())
end

--[[
	IsNoClipping
]]
function jlib.IsNoClipping(ply)
	return ply:GetMoveType() == MOVETYPE_NOCLIP
end

PLAYER.IsNoClipping = jlib.IsNoClipping

--[[
	Default ragdoll replacement functions
]]
function jlib.GetRagdoll(ply)
	return ply:GetNWEntity("jDoll")
end
PLAYER.GetRagdollEntity = jlib.GetRagdoll

function jlib.GetRagdollOwner(ent)
	return ent:GetNWEntity("RagdollOwner")
end
ENTITY.GetRagdollOwner = jlib.GetRagdollOwner

--[[
	Detour functions
	Purpose: Automate detouring of existing functions
]]

jlib.OldFuncs = jlib.OldFuncs or {}

function jlib.Detour(tbl, key, funcName, shouldDebug, extra)
	funcName = funcName or key
	shouldDebug = shouldDebug != nil and shouldDebug or true
	jlib.OldFuncs[funcName] = jlib.OldFuncs[funcName] or tbl[key]

	tbl[key] = function(...)
		if isfunction(extra) then
			local succ, err = pcall(extra, ...)

			if !succ then
				ErrorNoHalt(err)
			end
		end

		if shouldDebug then
			jlib.Print(funcName .. " called.")
			debug.Trace()
		end

		return jlib.OldFuncs[funcName](...)
	end
end

function jlib.UnDetour(tbl, key, funcName)
	funcName = funcName or key

	if jlib.OldFuncs[funcName] then
		tbl[key] = jlib.OldFuncs[funcName]
		jlib.OldFuncs[funcName] = nil
	end
end

--[[
	Request Functions
	Purpose: Request values from a client
]]
if SERVER then
	util.AddNetworkString("jlibRequestString")
	util.AddNetworkString("jlibRequestFloat")
	util.AddNetworkString("jlibRequestInt")
	util.AddNetworkString("jlibRequestBool")
end

function jlib.RequestString(title, callback, ply, confirmBtnText)
	confirmBtnText = confirmBtnText or "Confirm"
	if SERVER then
		net.Start("jlibRequestString")
			net.WriteString(title)
			net.WriteString(confirmBtnText)
		net.Send(ply)

		ply.StringRequests = ply.StringRequests or {}
		ply.StringRequests[title] = callback
	else
		local pnl = vgui.Create("UI_DFrame")
		pnl:SetTitle(title)
		pnl:SetSize(300, 200)
		pnl:Center()
		pnl:MakePopup()
		jlib.AddBackgroundBlur(pnl)

		local textEntry = pnl:Add("UI_DTextEntry")
		textEntry:SetPlaceholderText(title)
		textEntry:SetWide(250)
		textEntry:Center()

		local confirmBtn = pnl:Add("UI_DButton")
		confirmBtn:Dock(BOTTOM)
		confirmBtn:SetText(confirmBtnText)
		confirmBtn.DoClick = function()
			callback(textEntry:GetValue())
			pnl:Close()
		end
	end
end

if SERVER then
	net.Receive("jlibRequestString", function(len, ply)
		local title = net.ReadString()
		local str = net.ReadString()
		if ply.StringRequests and isfunction(ply.StringRequests[title]) then
			ply.StringRequests[title](str)
			ply.StringRequests[title] = nil
		end
	end)
end

if CLIENT then
	net.Receive("jlibRequestString", function()
		local title = net.ReadString()
		local confirmBtn = net.ReadString()
		jlib.RequestString(title, function(str)
			net.Start("jlibRequestString")
				net.WriteString(title)
				net.WriteString(str)
			net.SendToServer()
		end, NULL, confirmBtn)
	end)
end

function jlib.RequestInt(title, callback, min, max, ply, confirmBtnText)
	confirmBtnText = confirmBtnText or "Confirm"
	if SERVER then
		net.Start("jlibRequestInt")
			net.WriteString(title)
			net.WriteString(confirmBtnText)
			net.WriteInt(min, 32)
			net.WriteInt(max, 32)
		net.Send(ply)

		ply.IntRequests = ply.IntRequests or {}
		ply.IntRequests[title] = {func = callback, min = min, max = max}
	else
		local pnl = vgui.Create("UI_DFrame")
		pnl:SetTitle(title)
		pnl:SetSize(400, 200)
		pnl:Center()
		pnl:MakePopup()
		jlib.AddBackgroundBlur(pnl)

		local slider = pnl:Add("DNumSlider")
		slider:SetText(title)
		slider:SetDecimals(0)
		slider:SetMinMax(min, max)
		slider:SetValue((min + max) / 2)
		slider:SetWide(350)
		slider:Center()
		slider.Label:SetFont("UI_Regular")
		slider.Label:SetTextColor(nut.gui.palette.text_primary)
		slider.Label:SetExpensiveShadow(1, Color(0, 0, 0))

		local confirmBtn = pnl:Add("UI_DButton")
		confirmBtn:Dock(BOTTOM)
		confirmBtn:SetText(confirmBtnText)
		confirmBtn.DoClick = function()
			callback(math.floor(math.Clamp(slider:GetValue(), min, max)))
			pnl:Close()
		end
	end
end

if SERVER then
	net.Receive("jlibRequestInt", function(len, ply)
		local title = net.ReadString()
		local int = net.ReadInt(32)
		if ply.IntRequests and ply.IntRequests[title] then
			local request = ply.IntRequests[title]
			request.func(math.Clamp(int, request.min, request.max))
			ply.IntRequests[title] = nil
		end
	end)
end

if CLIENT then
	net.Receive("jlibRequestInt", function()
		local title = net.ReadString()
		local confirmBtn = net.ReadString()
		local min = net.ReadInt(32)
		local max = net.ReadInt(32)
		jlib.RequestInt(title, function(int)
			net.Start("jlibRequestInt")
				net.WriteString(title)
				net.WriteInt(int, 32)
			net.SendToServer()
		end, min, max, NULL, confirmBtn)
	end)
end

function jlib.RequestFloat(title, callback, min, max, decimals, ply, confirmBtnText)
	confirmBtnText = confirmBtnText or "Confirm"
	if SERVER then
		net.Start("jlibRequestFloat")
			net.WriteString(title)
			net.WriteString(confirmBtnText)
			net.WriteFloat(min)
			net.WriteFloat(max)
			net.WriteInt(decimals, 32)
		net.Send(ply)

		ply.FloatRequests = ply.FloatRequests or {}
		ply.FloatRequests[title] = {func = callback, min = min, max = max, decimals = decimals}
	else
		local pnl = vgui.Create("UI_DFrame")
		pnl:SetTitle(title)
		pnl:SetSize(400, 200)
		pnl:Center()
		pnl:MakePopup()
		jlib.AddBackgroundBlur(pnl)

		local slider = pnl:Add("DNumSlider")
		slider:SetText(title)
		slider:SetDecimals(decimals)
		slider:SetMinMax(min, max)
		slider:SetValue((min + max) / 2)
		slider:SetWide(350)
		slider:Center()
		slider.Label:SetFont("UI_Regular")
		slider.Label:SetTextColor(nut.gui.palette.text_primary)
		slider.Label:SetExpensiveShadow(1, Color(0, 0, 0))

		local confirmBtn = pnl:Add("UI_DButton")
		confirmBtn:Dock(BOTTOM)
		confirmBtn:SetText(confirmBtnText)
		confirmBtn.DoClick = function()
			callback(math.Round(math.Clamp(slider:GetValue(), min, max), decimals))
			pnl:Close()
		end
	end
end

if SERVER then
	net.Receive("jlibRequestFloat", function(len, ply)
		local title = net.ReadString()
		local float = net.ReadFloat()
		if ply.FloatRequests and ply.FloatRequests[title] then
			local request = ply.FloatRequests[title]
			request.func(math.Round(math.Clamp(float, request.min, request.max), request.decimals))
			ply.FloatRequests[title] = nil
		end
	end)
end

if CLIENT then
	net.Receive("jlibRequestFloat", function()
		local title = net.ReadString()
		local confirmBtn = net.ReadString()
		local min = net.ReadFloat()
		local max = net.ReadFloat()
		local decimals = net.ReadInt(32)
		jlib.RequestFloat(title, function(float)
			net.Start("jlibRequestFloat")
				net.WriteString(title)
				net.WriteFloat(float)
			net.SendToServer()
		end, min, max, decimals, NULL, confirmBtn)
	end)
end

function jlib.RequestBool(title, callback, ply, trueBtnText, falseBtnText, extendedMessage)
	trueBtnText = trueBtnText or "Yes"
	falseBtnText = falseBtnText or "No"
	if SERVER then
		net.Start("jlibRequestBool")
			net.WriteString(title)
			net.WriteString(extendedMessage or "")
			net.WriteString(trueBtnText)
			net.WriteString(falseBtnText)
		net.Send(ply)

		ply.BoolRequests = ply.BoolRequests or {}
		ply.BoolRequests[title] = {func = callback}
	else
		local space = 20

		local pnl = vgui.Create("UI_DFrame")
		pnl:SetTitle(title)
		pnl:SetSize(400, 100)
		pnl:Center()
		pnl:MakePopup()
		jlib.AddBackgroundBlur(pnl)

		if extendedMessage != "" then
			local msgPnl = pnl:Add("UI_DLabel")
			local left, _, right = pnl:GetDockPadding()
			msgPnl:SetWide(pnl:GetWide() - (left + right))
			msgPnl:SetWrap(true)
			msgPnl:SetText(extendedMessage)
			msgPnl:SetAutoStretchVertical(true)
			msgPnl:Dock(TOP)
			jlib.CallAfterTicks(2, function()
				if IsValid(pnl) and IsValid(msgPnl) then
					pnl:SetTall(msgPnl:GetTall() + 100)
				end
			end)
		end

		local trueBtn = pnl:Add("UI_DButton")
		trueBtn:SetSize((pnl:GetWide() / 2) - space, pnl:GetTall() / 2)
		trueBtn:SetText(trueBtnText)
		trueBtn:SetContentAlignment(5)
		trueBtn.DoClick = function()
			callback(true)
			pnl:Close()
		end
		trueBtn:Dock(LEFT)

		local falseBtn = pnl:Add("UI_DButton")
		falseBtn:SetSize((pnl:GetWide() / 2) - space, pnl:GetTall() / 2)
		falseBtn:SetText(falseBtnText)
		falseBtn:SetContentAlignment(5)
		falseBtn.DoClick = function()
			callback(false)
			pnl:Close()
		end
		falseBtn:Dock(RIGHT)
	end
end

if SERVER then
	net.Receive("jlibRequestBool", function(len, ply)
		local title = net.ReadString()
		local bool = net.ReadBool()
		if ply.BoolRequests and ply.BoolRequests[title] then
			local request = ply.BoolRequests[title]
			request.func(bool)
			ply.BoolRequests[title] = nil
		end
	end)
end

if CLIENT then
	net.Receive("jlibRequestBool", function()
		local title = net.ReadString()
		local msg = net.ReadString()
		local trueBtn = net.ReadString()
		local falseBtn = net.ReadString()
		jlib.RequestBool(title, function(bool)
			net.Start("jlibRequestBool")
				net.WriteString(title)
				net.WriteBool(bool)
			net.SendToServer()
		end, NULL, trueBtn, falseBtn, msg)
	end)
end

if SERVER then
	util.AddNetworkString("jlibSendNotification")
end

if CLIENT then
	net.Receive("jlibSendNotification", function()
		local title = net.ReadString()
		local body = net.ReadString()

		local panel = vgui.Create("forpNotificationBox")
		panel:SetTitle(title or "Information")
		panel:SetText(body)
	end)
end

function jlib.SendNotification(ply, title, body)
	net.Start("jlibSendNotification")
		net.WriteString(title)
		net.WriteString(body)
	net.Send(ply)
end

--[[
	Announce
	Purpose: Print a message to selected player's chat, supports colors
]]
if SERVER then
	util.AddNetworkString("jlibAnnounce")

	function jlib.Announce(plys, ...)
		local msg = {...}

		net.Start("jlibAnnounce")

		net.WriteUInt(#msg, 32)

		for i, msgPart in ipairs(msg) do
			if isstring(msgPart) then
				net.WriteBit(true)
				net.WriteString(msgPart)
			elseif IsColor(msgPart) then
				net.WriteBit(false)
				net.WriteColor(msgPart)
			else
				error("jlib.Announce only accepts strings and colors")
			end
		end

		net.Send(plys)
	end
end

if CLIENT then
	function jlib.Announce(...)
		chat.AddText(...)
	end

	net.Receive("jlibAnnounce", function()
		local msg = {}
		local msgLen = net.ReadUInt(32)

		for i = 1, msgLen do
			if net.ReadBit() == 1 then
				msg[#msg + 1] = net.ReadString()
			else
				msg[#msg + 1] = net.ReadColor()
			end
		end

		jlib.Announce(unpack(msg))
	end)
end

--[[
	WeightedRandom
	Return a value from a table using the keys as probabilities
	The sum of probabilities must be exactly 100
]]
function jlib.WeightedRandom(tbl)
	local seed = math.Rand(0, 100)

	for chance, value in pairs(tbl) do
		seed = seed - chance

		if seed < 0 then
			return value
		end
	end
end

--[[
	RaySphereIntersection
	Returns a vector describing where the ray will hit the sphere
]]
function jlib.RaySphereIntersection(center, radius, rayOrigin, rayNormal, filter)
	-- Perform the ray-sphere intersection
	local oc = rayOrigin - center
	local a = rayNormal:Dot(rayNormal)
	local b = 2 * oc:Dot(rayNormal)
	local c = oc:Dot(oc) - radius ^ 2
	local discriminant = b * b - 4 * a * c

	if discriminant >= 0 then
		local numerator = -b - math.sqrt(discriminant)

		if numerator > 0 then
			local hitPos = rayOrigin + (rayNormal * (numerator / (2 * a)))

			-- Final check for obstructions
			if !util.QuickTrace(rayOrigin, rayNormal * (rayOrigin:Distance(hitPos)), filter).Hit then
				return hitPos
			end
		end
	end
end

--[[
	MinMaxToVertices
	Returns all 8 vertices of a cube given it's mins and maxs
]]
function jlib.MinMaxToVertices(min, max)
	return {
		Vector(min.x, min.y, min.z),
		Vector(min.x, min.y, max.z),
		Vector(min.x, max.y, min.z),
		Vector(min.x, max.y, max.z),
		Vector(max.x, min.y, min.z),
		Vector(max.x, min.y, max.z),
		Vector(max.x, max.y, min.z),
		Vector(max.x, max.y, max.z)
	}
end

--[[
	Possession
]]
jlib.Possession = jlib.Possession or {}

function PLAYER:SetMaster(master)
	self:SetNW2Entity("master", master)
end

function PLAYER:GetMaster()
	return self:GetNW2Entity("master", NULL)
end

function PLAYER:SetSlave(slave)
	self:SetNW2Entity("slave", slave)
end

function PLAYER:GetSlave()
	return self:GetNW2Entity("slave", NULL)
end

jlib.Possession.MoveMethods = {
	"Buttons",
	"ForwardMove",
	"SideMove",
	"UpMove",
	"ViewAngles",
	"MouseX",
	"MouseY",
	"MouseWheel",
	"Impulse"
}

hook.Add("StartCommand", "jlibPossession", function(ply, cmd)
	if !ply:Alive() then return end

	local master = ply:GetMaster()
	local slave = ply:GetSlave()

	if IsValid(slave) then
		ply.LastCMD = cmd

		-- Trick to make only the slave shoot and not the master
		if cmd:KeyDown(IN_ATTACK) then
			cmd:RemoveKey(IN_ATTACK)
			cmd:SetButtons(cmd:GetButtons() + IN_ALT1)
		end

		if CLIENT then
			jlib.Possession.STPConvar = jlib.Possession.STPConvar or GetConVar("simple_thirdperson_enabled")
			jlib.Possession.STPConvar:SetBool(false)
		end
	elseif IsValid(master) then
		cmd:ClearMovement()
		cmd:ClearButtons()

		-- Selecting the same weapon
		local masterWep = master:GetActiveWeapon()
		local wepClass = masterWep:GetClass()
		if !ply:HasWeapon(wepClass) then
			ply:Give(wepClass)
		end

		local childWep = ply:GetWeapon(wepClass)
		if IsValid(childWep) then
			local ammoTypes = {masterWep:GetPrimaryAmmoType(), masterWep:GetSecondaryAmmoType()}
			for i, ammoType in ipairs(ammoTypes) do
				master:SetAmmo(ply:GetAmmoCount(ammoType), ammoType)
			end

			masterWep:SetClip1(childWep:Clip1() + 1)
			masterWep:SetClip2(childWep:Clip2() + 1)

			if ply:GetActiveWeapon():GetClass() != wepClass then
				cmd:SelectWeapon(childWep)
			end
		end

		if nut then
			local masterRaised = master:isWepRaised()
			if masterRaised != ply:isWepRaised() then
				ply:setWepRaised(masterRaised)
			end
		end

		-- Copying the UserCmd data over
		local masterCMD = master.LastCMD

		if masterCMD then
			for i, method in ipairs(jlib.Possession.MoveMethods) do
				cmd["Set" .. method](cmd, masterCMD["Get" .. method](masterCMD))
			end

			-- Forcing the slave to shoot
			if masterCMD:KeyDown(IN_ALT1) then
				cmd:RemoveKey(IN_ALT1)
				cmd:SetButtons(cmd:GetButtons() + IN_ATTACK)
			end
		end
	end
end)

hook.Add("Move", "jlibPossession", function(ply, mv, cmd)
	if IsValid(ply:GetSlave()) then return true end
end)

-- Possession chat swaps
local PossessionChatBlacklist = { -- For skipping commands
	["/"] = true,
	["!"] = true,
	["~"] = true
}

function jlib.Possession.ChatSwap(hookName, hookReturn)
	hook.Add(hookName, "jlibPossession", function(ply, msg, isTeam, isDead)
		if PossessionChatBlacklist[msg:sub(1, 1)] then
			return
		end

		local slave = ply:GetSlave()
		local master = ply:GetMaster()

		if IsValid(master) then
			if ply.IsFromMaster then
				ply.IsFromMaster = nil
			else
				return hookReturn
			end
		end

		if IsValid(slave) then
			slave.IsFromMaster = true
			hook.Run("PlayerSay", slave, msg, isTeam, isDead)
			return hookReturn
		end
	end)
end
jlib.Possession.ChatSwap("PlayerSay", "")
jlib.Possession.ChatSwap("OnPlayerChat", true)

--[[
	jlib.SendSound
	Plays a given sound on the given player(s)
]]
if SERVER then
	util.AddNetworkString("jlibSendSound")

	function jlib.SendSound(sound, ply)
		net.Start("jlibSendSound")
			net.WriteString(sound)
		net.Send(ply)
	end
else
	net.Receive("jlibSendSound", function()
		surface.PlaySound(net.ReadString())
	end)
end

--[[
	jlib.SteamIDName
]]
function jlib.SteamIDName(ply)
	return ply:Nick() .. "(" .. ply:SteamID() ..  ")"
end
PLAYER.SteamIDName = jlib.SteamIDName

--[[
	jlib.SpeedTest
	Will repeat a function n number of times are return the average CPU time
]]
function jlib.SpeedTest(func, n)
	local start = SysTime()
	for i = 1, n do
		func()
	end
	return (SysTime() - start) / n
end

--[[
	IsInCombat - to check if a player has recently engaged in combat
]]

jlib.DefaultCombatTime = 60

function PLAYER:IsInCombat(time)
	return self.LastCombatInteraction and CurTime() - self.LastCombatInteraction < (time or jlib.DefaultCombatTime)
end

function jlib.UpdateCombatInteraction(ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply.LastCombatInteraction = CurTime()
	end
end

hook.Add("ScalePlayerDamage", "jlibIsInCombat", function(victim, hit, dmg)
	jlib.UpdateCombatInteraction(victim)
	jlib.UpdateCombatInteraction(dmg:GetAttacker())
	jlib.UpdateCombatInteraction(dmg:GetInflictor())
end)

--[[
	Speed manipulation methods
]]
PLAYER._SetWalkSpeed = PLAYER._SetWalkSpeed or PLAYER.SetWalkSpeed
PLAYER._SetRunSpeed = PLAYER._SetRunSpeed or PLAYER.SetRunSpeed
PLAYER._GetWalkSpeed = PLAYER._GetWalkSpeed or PLAYER.GetWalkSpeed
PLAYER._GetRunSpeed = PLAYER._GetRunSpeed or PLAYER.GetRunSpeed

function PLAYER:SetSpeedBuff(amt)
	local oldBuff = self:GetSpeedBuff()
	local curWalk = self:GetWalkSpeed()
	local curRun = self:GetRunSpeed()

	self:SetNW2Float("SpeedBuff", amt)
	self:SetWalkSpeed(curWalk)
	self:SetRunSpeed(curRun)

	hook.Run("PlayerSpeedBuffChanged", oldBuff, amt)
end

function PLAYER:GetSpeedBuff()
	return self:GetNW2Float("SpeedBuff", 1)
end

function PLAYER:IncreaseSpeedBuff(amt)
	self:SetSpeedBuff(self:GetSpeedBuff() + amt)
end

function PLAYER:ReduceSpeedBuff(amt)
	self:SetSpeedBuff(self:GetSpeedBuff() - amt)
end

function PLAYER:SetWalkSpeed(speed)
	self:_SetWalkSpeed(speed * self:GetSpeedBuff())
end

function PLAYER:SetRunSpeed(speed)
	self:_SetRunSpeed(speed * self:GetSpeedBuff())
end

function PLAYER:GetWalkSpeed()
	return self:_GetWalkSpeed() / self:GetSpeedBuff()
end

function PLAYER:GetRunSpeed()
	return self:_GetRunSpeed() / self:GetSpeedBuff()
end

-- Fixed SprintEnable/SprintDisable methods
function PLAYER:SetSprintEnabled(enabled)
	self:SetNW2Bool("SprintEnabled", enabled)
end

function PLAYER:GetSprintEnabled()
	return self:GetNW2Bool("SprintEnabled", true)
end
PLAYER.IsSprintEnabled = PLAYER.GetSprintEnabled

function PLAYER:SprintEnable()
	self:SetSprintEnabled(true)
end

function PLAYER:SprintDisable()
	self:SetSprintEnabled(false)
end

hook.Add("Move", "SprintEnabled", function(ply, mv)
	if ply:IsSprintEnabled() == false then
		mv:SetMaxSpeed(ply:GetWalkSpeed())
		mv:SetMaxClientSpeed(ply:GetWalkSpeed())
	end
end)

--[[
	PAC3 & Serverguard permissions compatibility
]]
-- Create the permission
hook.Add("PostGamemodeLoaded", "PAC3Permission", function()
	serverguard.permission:Add("PAC3")
end)

-- Check the permission in PAC3 hooks
local function CanUsePAC3(ply)
	if !IsValid(ply) then return false end

	local hasPerm = serverguard.player:HasPermission(ply, "PAC3")
	if hasPerm then
		return true
	else
		ply:ChatPrint("You are not authorized to use PAC3")
		return false
	end
end

hook.Add("PrePACConfigApply", "PAC3Restrict", CanUsePAC3)
hook.Add("PrePACEditorOpen", "PAC3Restrict", CanUsePAC3)

--[[
	Lookupify
]]
function jlib.Lookupify(tbl)
	local lookup = {}
	for _, v in pairs(tbl) do
		lookup[v] = true
	end
	return lookup
end

--[[
	jDisallowPickup
	Purpose: Easily disallow an entity to be phys/grav picked up by anyone
]]
function ENTITY:SetDisallowPickup(bool)
	self:SetNW2Bool("jDisallowPickup", bool)
end

function ENTITY:GetDisallowPickup()
	return self:GetNW2Bool("jDisallowPickup", false)
end

function ENTITY:SetAllowPickup(bool)
	self:SetNW2Bool("jDisallowPickup", !bool)
end

function ENTITY:GetAllowPickup()
	return !self:GetNW2Bool("jDisallowPickup", false)
end

local function AllowPickup(ply, ent)
	if ent:GetDisallowPickup() then return false end
end
hook.Add("PhysgunPickup", "jDisallowPickup", AllowPickup)
hook.Add("GravGunPickupAllowed", "jDisallowPickup", AllowPickup)

--[[
	Table of commonly used colors
]]
jlib.Colors = {}
jlib.Colors.Error = Color(200, 50, 50)
jlib.Colors.Success = Color(23, 231, 93)
jlib.Colors.Neutral = Color(17, 101, 255)
