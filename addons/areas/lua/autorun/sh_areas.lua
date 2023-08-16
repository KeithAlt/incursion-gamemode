Areas = Areas or {}
Areas.Instances = Areas.Instances or {}
Areas.PlayerMeta = Areas.PlayerMeta or FindMetaTable("Player")

Areas.Print = jlib.GetPrintFunction("[Areas]")
Areas.Print("Loaded!")

-- Add set/get methods to the areas meta
local lenTypes = {
	["Int"] = true,
	["UInt"] = true
}

function Areas.AddVar(name, vType, shouldSave, default)
	if SERVER then
		util.AddNetworkString("AreasSet" .. name)
	end

	if CLIENT then
		net.Receive("AreasSet" .. name, function()
			local areaID = net.ReadInt(32)
			local val = net["Read" .. vType](lenTypes[vType] and 32 or nil)
			local area = Areas.Instances[areaID]
			area["Set" .. name](area, val)
		end)
	end

	Areas.Meta["Set" .. name] = function(self, val)
		self[name] = val

		if SERVER then
			net.Start("AreasSet" .. name)
				net.WriteInt(self.ID, 32)
				net["Write" .. vType](val, lenTypes[vType] and 32 or nil)
			net.Broadcast()

			if shouldSave then
				Areas.SaveAreas()
			end
		end
	end

	Areas.Meta["Get" .. name] = function(self)
		return self[name] or (istable(default) and table.Copy(default) or default)
	end
end

-- Player meta funcs
local PLAYER = Areas.PlayerMeta

function PLAYER:SetArea(areaID)
	self:SetNW2Int("Area", areaID)
end

function PLAYER:GetArea()
	return Areas.Instances[self:GetNW2Int("Area", 0)]
end

-- Util funcs
function Areas.GetArea(vector)
	for k, area in pairs(Areas.Instances) do
		if area:IsInBounds(vector) then
			return area
		end
	end
end

-- Run area think
timer.Create("AreaThink", 0.5, 0, function()
	for i, area in pairs(Areas.Instances) do
		if area.Think then
			area:Think()
		end
	end
end)

-- Including area meta
AddCSLuaFile("sh_areameta.lua")
include("sh_areameta.lua")

-- Including custom modules
Areas.ModulePath = "area_modules"

function Areas.GetFullPath(file)
	return Areas.ModulePath .. "/" .. file
end

if SERVER then
	Areas.IncludeFuncs = {
		["sv"] = function(path)
			include(path)
		end,
		["cl"] = function(path)
			AddCSLuaFile(path)
		end,
		["sh"] = function(path)
			AddCSLuaFile(path)
			include(path)
		end
	}
else
	Areas.IncludeFuncs = {
		["cl"] = function(path)
			include(path)
		end,
		["sh"] = function(path)
			include(path)
		end
	}
end

function Areas.Include(file)
	local realm = string.sub(file, 1, 2)
	local includeFunc = Areas.IncludeFuncs[realm]

	if isfunction(includeFunc) then
		includeFunc(Areas.GetFullPath(file))
	end
end

for i, file in ipairs(file.Find(Areas.ModulePath .. "/*.lua", "LUA")) do
	Areas.Include(file)
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "AreasDisconnect", function(dat)
	local ply = Player(dat.userid)
	if IsValid(ply) then
		local area = ply:GetArea()
		if IsValid(area) then
			area:RemovePlayer(ply)
		end
	end
end)

hook.Add("InitPostEntity", "AreasCaptureCommands", function()
	MsgC(Color(0,255,255), "[AREAS] ", Color(255,255,255), "Initializing area capture mechanics . . .\n")

	nut.command.add("area_removeowner", {
		syntax = "<While within zone>",
		adminOnly = true,
		onRun = function(ply)

			local areaID = Areas.getLocalAreaID(ply) or false

			if !areaID then
				ply:notify("You are not in a valid area")
				return
			end

			jlib.RequestBool("Remove area owners?", function(bool)
				if !bool then return end

				Areas.RemoveOwner(areaID)
				ply:notify("Removed faction owners from area")

			end, ply, "Yes", "No")
		end
	})

	nut.command.add("area_unclaim", {
		syntax = "<While within zone>",
		onRun = function(ply)
			if !hcWhitelist.isHC(ply) then
				ply:notify("You are not an officer!")
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "You need to be an officer of your faction in-order to request an unclaim")
				return
			end

			local areaID = Areas.getLocalAreaID(ply) or false

			if !areaID then
				ply:notify("You are not in a valid area")
				return
			end

			jlib.RequestBool("Request a base reset?", function(bool)
				if !bool then return end

				jlib.RequestString("Reason for unclaim?", function(text)
					if !text or #text <= 1 then
						ply:notify("Unclaim request cancelled")
						return
					end

					local areaName = ply:GetArea().Name or false

					if !areaName then
						ply:notify("You are not in a valid area")
						return
					end

					DiscordEmbed(
						"· **Player:** " .. jlib.SteamIDName(ply) ..
						"\n\n· **Faction:** " .. team.GetName(ply:Team()) ..
						"\n\n· **Area:** " .. areaName ..
						"\n\n· **Reason:**\n```" .. text .. "```",
						"🚩 Base Unclaim Request 🚩" , Color(255,255,0), "BTeamChat"
					)

					jlib.Announce(ply, Color(255,255,0), "[AREA] ", Color(255,255,155), "Area unclaim request submitted to B-Team", Color(255,255,255), "\n· A B-Team member must personally unclaim your base\n· Wait at least 48 hours before contacting B-Team to check on your request status")
					ply:notify("Unclaim request submitted")

				end, ply, "Submit to B-Team")

			end, ply, "YES (REQUEST)", "NO (CANCEL)")
		end
	})

	nut.command.add("area_capture", {
		syntax = "<While within zone>",
		onRun = function(ply)

			if ply:GetArea().FactionUID and #ply:GetArea().FactionUID > 0  then
				ply:notify("This area is already claimed")
				return
			end

			if !ply:GetArea():GetCapture() then
				ply:notify("This area is not capturable")
				return
			end

			if !hcWhitelist.isHC(ply) then
				ply:notify("You are not an officer!")
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "You need to be an officer of your faction in-order to start an area capture")
				return
			end

			if Areas.GetOwnership(nut.faction.indices[ply:getChar():getFaction()].uniqueID) then
				ply:notify("Your faction is already based")
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "You already have a faction base claimed!")
				return
			end

			local area = ply:GetArea() or false

			if !area or #area > 0 then
				ply:notify("You are not in a capturable area")
				return
			end

			local capturingPly = ply

			jlib.RequestBool("Capture this area?", function(bool)
				if !bool then return end

				ply.captureSequence = 0
				local plyTeam = ply:Team()

				for index, entity in pairs(ents.FindInSphere(ply:GetPos(), 800)) do
					if entity:IsPlayer() and entity:Team() == plyTeam then
						jlib.Announce(entity, Color(255,255,0), "[AREA] ", Color(255,255,155), "Your faction has started capturing this area...")
					end
				end

				net.Start("AreasDrawCaptureBar")
					net.WriteBool(true)
				net.Send(ply)

				local areaID = Areas.getLocalAreaID(ply)

				timer.Create(areaID .. "_capture", 1, 10, function()
					if !IsValid(ply) or !ply:Alive() or Areas.getLocalAreaID(ply) != areaID then

						if IsValid(ply) then
							ply.captureSequence = nil

							net.Start("AreasDrawCaptureBar")
								net.WriteBool(false)
							net.Send(ply)
						end

						timer.Remove(areaID .. "_capture")
						return
					end

					if ply.captureSequence == 9 then
						net.Start("AreasDrawCaptureBar")
							net.WriteBool(false)
						net.Send(ply)

						Areas.AddOwner(areaID, ply:getChar():getFaction())

						local areaName = ply:GetArea().Name or "Area"

						for index, member in pairs(player.GetAll()) do
							if member:Team() == ply:Team() then
								member:SendLua("displayScrText('Territory Captured')")
								member:falloutNotify("Your faction has claimed a territory", "fo_tracks/areas/scr/mus_scr_victorysinger(alt2).ogg")
							else
								jlib.Announce(member, Color(255, 150, 0), "A faction has claimed new territory in the wasteland...")
							end
						end

						DiscordEmbed("The " .. nut.faction.indices[ply:getChar():getFaction()].name .. " have captured " .. (areaName or "a new area") ,"🚩 Claim Notification 🚩", Color(255,255,0), "IncursionChat")
					end

					ply.captureSequence = ply.captureSequence + 1
				end)
			end, ply, "Yes", "No")
		end
	})


	-- Initalize our related configuration settings
	nut.config.add("requireDeployablesInArea", false, "Should officers only be able to spawn deployables in areas they own?", false, {
		category = "areas"
	})

	MsgC(Color(0,255,255), "[AREAS] ", Color(255,255,255), "Finished loading area capture mechanics\n")
end)
