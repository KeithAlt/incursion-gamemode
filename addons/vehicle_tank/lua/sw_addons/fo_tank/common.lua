if !SW_ADDON then
	SW_Addons.AutoReloadAddon(function() end)
	return
end

function SW_ADDON:MakeEnt(classname, ply, parent, name)
    local ent = ents.Create(classname)

    if !IsValid(ent) then return end
	ent.__SW_Vars = ent.__SW_Vars or {}
	self:SetName(ent, name)
	self:SetParent(ent, parent)
	
	if ent.__IsSW_Entity then
		ent:SetAddonID(self.Addonname)
	end

    if !ent.CPPISetOwner then return ent end
    if !IsValid(ply) then return ent end

    ent:CPPISetOwner(ply)
    return ent
end

function SW_ADDON:AddToEntList(name, ent)
	name = tostring(name or "")

	self.ents = self.ents or {}
	self.ents[name] = self.ents[name] or {}
	
	if IsValid(ent) then
		self.ents[name][ent] = true
	else
		self.ents[name][ent] = nil
	end
end

function SW_ADDON:GetAllFromEntList(name)
	name = tostring(name or "")

	self.ents = self.ents or {}
	return self.ents[name] or {}
end

function SW_ADDON:ForEachInEntList(name, func)
	if !isfunction(func) then return end
	local entlist = self:GetAllFromEntList(name)
	
	local index = 1
	for k, v in pairs(entlist) do
		if !IsValid(k) then
			entlist[k] = nil
			continue
		end
		
		local bbreak = func(self, index, k)
		if bbreak == false then
			break
		end
		
		index = index + 1
	end
end

function SW_ADDON:GetName(ent)
	if !IsValid(ent) then return end
	if !ent.__SW_Vars then return "" end
	
	return self:ValidateName(ent.__SW_Vars.Name)
end

function SW_ADDON:SetName(ent, name)
	if !IsValid(ent) then return end
	if !ent.__SW_Vars then return end
	local vars = ent.__SW_Vars
	
	name = self:ValidateName(name)
	if name == "" then
		name = tostring(util.CRC(tostring(ent)))
	end
	
	local oldname = self:GetName(ent)
	vars.Name = name
	
	local parent = self:GetParent(ent)
	if !IsValid(parent) then return end
	
	parent.__SW_Vars = parent.__SW_Vars or {}
	local vars_parent = parent.__SW_Vars

	vars_parent.ChildrenENTs = vars_parent.ChildrenENTs or {}
	vars_parent.ChildrenENTs[oldname] = nil
	vars_parent.ChildrenENTs[name] = ent
end

function SW_ADDON:GetParent(ent)
	if !IsValid(ent) then return end
	if !ent.__SW_Vars then return end
	local vars = ent.__SW_Vars

    if !IsValid(vars.ParentENT) then return end
	if vars.ParentENT == ent then return end

	return vars.ParentENT
end

function SW_ADDON:SetParent(ent, parent)
	if !IsValid(ent) then return end
	if !ent.__SW_Vars then return end

	if parent == ent then
		parent = nil
	end
	
	local vars = ent.__SW_Vars

	vars.ParentENT = parent
	vars.SuperParentENT = self:GetSuperParent(ent)

	parent = self:GetParent(ent)
	if !IsValid(parent) then return end
	
	parent.__SW_Vars = parent.__SW_Vars or {}
	local vars_parent = parent.__SW_Vars

	local name = self:GetName(ent)
	vars_parent.ChildrenENTs = vars_parent.ChildrenENTs or {}
	vars_parent.ChildrenENTs[name] = ent
end

function SW_ADDON:GetSuperParent(ent)
	if !IsValid(ent) then return end
	if !ent.__SW_Vars then return end

	local vars = ent.__SW_Vars
	
	if IsValid(vars.SuperParentENT) and (vars.SuperParentENT != ent) then
		return vars.SuperParentENT
	end
	
	if !IsValid(vars.ParentENT) then
		return ent
	end
	
	vars.SuperParentENT = self:GetSuperParent(vars.ParentENT)
	if vars.SuperParentENT == ent then return end
    if !IsValid(vars.SuperParentENT) then return end
	
	return vars.SuperParentENT
end

function SW_ADDON:GetEntityPath(ent)
	if !IsValid(ent) then return end
	
	local name = self:GetName(ent)
	local parent = self:GetParent(ent)
	
	if !IsValid(parent) then
		return name
	end
	
	local parent_name = self:GetName(parent)
	name = parent_name .. "/" .. name
	
	return name
end

function SW_ADDON:GetChildren(ent)
	if !IsValid(ent) then return end
	if !ent.__SW_Vars then return end

	return ent.__SW_Vars.ChildrenENTs or {}
end

function SW_ADDON:GetChild(ent, name)
	local children = self:GetChildren(ent)
	if !children then return end
	
	local child = children[name]
	if !IsValid(child) then return end
	
	if self:GetParent(child) != ent then
		children[name] = nil
		return
	end

	return child
end

function SW_ADDON:ChangePoseParameter( ent, val, name, divide )
	if !IsValid(ent) then return end
	val = val or 0
	name = name or ""
	divide = divide or 1
	
	ent:SetPoseParameter( name, val/divide ) 
end

function SW_ADDON:Exit_Seat( ent, ply, pvf, pvr, pvu, evf, evr, evu )
	if !IsValid(ent) then return false end
	if !IsValid(ply) then return false end

	local Filter = function( addon, veh, f_ent )
		if !IsValid(f_ent) then return false end
		if !IsValid(ply) then return false end
		if f_ent == veh then return false end
		if f_ent == ply then return false end
		if f_ent:GetModel() == "models/sligwolf/unique_props/seat.mdl" then return false end

		return true
	end	

	local lpos = ent:GetPos()
	local lang = ent:GetAngles()
	local fwd = lang:Forward()
	local rgt = lang:Right()
	local up = lang:Up()
	local pos = lpos - fwd*pvf - rgt*pvr - up*pvu
	
	pvf = pvf or 0
	pvr = pvr or 0
	pvu = pvu or 0
	evf = evf or 0
	evr = evr or 0
	evu = evu or 0

	local tb = {
		V1 = { VecA = Vector(0,0,0), VecB = Vector(0,0,70) },
		V2 = { VecA = Vector(15,0,0), VecB = Vector(15,0,70) },
		V3 = { VecA = Vector(0,15,0), VecB = Vector(0,15,70) },
		V4 = { VecA = Vector(-15,0,0), VecB = Vector(-15,0,70) },
		V5 = { VecA = Vector(0,-15,0), VecB = Vector(0,-15,70) },
		V6 = { VecA = Vector(15,15,0), VecB = Vector(15,15,70) },
		V7 = { VecA = Vector(-15,15,0), VecB = Vector(-15,15,70) },
		V8 = { VecA = Vector(-15,-15,0), VecB = Vector(-15,-15,70) },
		V9 = { VecA = Vector(15,-15,0), VecB = Vector(15,-15,70) },
	}
	
	for k,v in pairs(tb) do
		local tr = self:Tracer( ent, pos+v.VecA, pos+v.VecB, Filter )
		if tr.Hit then return true end
	end
	
	ply:SetPos(pos)
	ply:SetEyeAngles((lpos-(lpos - fwd*evf - rgt*evr + up*evu)):Angle())
	return false
end

function SW_ADDON:VehicleOrderThink()
	if CLIENT then
		local ply = LocalPlayer()
		if !IsValid(ply) then return end
		local vehicle = ply:GetVehicle()
		if !IsValid(vehicle) then return end
		
		if gui.IsGameUIVisible() then return end
		if gui.IsConsoleVisible() then return end
		if IsValid(vgui.GetKeyboardFocus()) then return end
		if ply:IsTyping() then return end
		
		for k,v in pairs(self.KeySettings or {}) do
			if (!v.cv) then continue end
			
			local isdown = input.IsKeyDown( v.cv:GetInt() )
			self:SendVehicleOrder(vehicle, k, isdown)
		end
		
		return
	end

	for vehicle, players in pairs(self.PressedKeyMap or {}) do
		if !IsValid(vehicle) then continue end
		
		for ply, keys in pairs(players or {}) do
			if !IsValid(ply) then continue end
			
			for name, callback_data in pairs(keys or {}) do
				if !callback_data.state then continue end
				
				local callback_hold = callback_data.callback_hold
				callback_hold(self, ply, vehicle, true)
			end
		end
	end
end

function SW_ADDON:VehicleOrderLeave(ply, vehicle)
	if CLIENT then return end
	
	local holdedkeys = self.PressedKeyMap or {}
	holdedkeys = holdedkeys[vehicle] or {}
	holdedkeys = holdedkeys[ply] or {}

	for name, callback_data in pairs(holdedkeys) do
		if !callback_data.state then continue end
	
		local callback_hold = callback_data.callback_hold
		local callback_up = callback_data.callback_up
		
		callback_hold(self, ply, vehicle, false)
		callback_up(self, ply, vehicle, false)
		
		callback_data.state = false
	end
end

function SW_ADDON:RegisterVehicleOrder(name, callback_hold, callback_down, callback_up)
	self.hooks = self.hooks or {}
	self.hooks.VehicleOrderThink = "Think"
	self.hooks.VehicleOrderMenu = "PopulateToolMenu"
	self.hooks.VehicleOrderLeave = "PlayerLeaveVehicle"

	if CLIENT then return end

	local ID = self.NetworkaddonID or ""
	if ID == "" then
		error("Invalid NetworkaddonID!")
		return
	end

	name = name or ""
	if name == "" then return end

	local netname = "SligWolf_VehicleOrder_"..ID.."_"..name
	
	local valid = false
	if !isfunction(callback_hold) then
		callback_hold = (function() end)
	else
		valid = true
	end
		
	if !isfunction(callback_down) then
		callback_down = (function() end)
	else
		valid = true
	end
	
	if !isfunction(callback_up) then
		callback_up = (function() end)
	else
		valid = true
	end	
	
	if !valid then
		error("no callback functions given!")
		return
	end	
	
	util.AddNetworkString( netname )
	net.Receive( netname, function( len, ply )
		local ent = net.ReadEntity()
		local down = net.ReadBool() or false
		
		if !IsValid(ent) then return end
		if !IsValid(ply) then return end
		if !ply:InVehicle() then return end

		local veh = ply:GetVehicle()
		if(ent != veh) then return end
		
		local setting = self.KeySettings[name]
		if !setting then return end
		
		self.KeyBuffer = self.KeyBuffer or {}
		self.KeyBuffer[veh] = self.KeyBuffer[veh] or {}
	
		local changedbuffer = self.KeyBuffer[veh][name] or {}
		local times  = changedbuffer.times or {}
		
		local mintime = setting.time or 0
		if mintime > 0 then
			local lasttime = times[down] or 0
			local deltatime = CurTime() - lasttime
		
			if deltatime <= mintime then return end
		end
		
		if changedbuffer.state == down then return end
		
		times[down] = CurTime()	
		changedbuffer.times = times
		changedbuffer.state = down
		
		self.KeyBuffer[veh][name] = changedbuffer
		
		self.PressedKeyMap = self.PressedKeyMap or {}
		self.PressedKeyMap[veh] = self.PressedKeyMap[veh] or {}
		self.PressedKeyMap[veh][ply] = self.PressedKeyMap[veh][ply] or {}
		self.PressedKeyMap[veh][ply][name] = {
			callback_hold = callback_hold,
			callback_up = callback_up,
			callback_down = callback_down,
			state = down,
		}

		if down then
			callback_down(self, ply, veh, down)
			return
		end
		
		callback_up(self, ply, veh, down)
	end)
end

function SW_ADDON:RegisterKeySettings(name, default, time, description, extra_text)
	self.hooks = self.hooks or {}
	self.hooks.VehicleOrderThink = "Think"
	self.hooks.VehicleOrderMenu = "PopulateToolMenu"
	self.hooks.VehicleOrderLeave = "PlayerLeaveVehicle"

	name = name or ""
	description = description or ""
	help = help or ""
	default = default or 0
	time = time or 0.1
	
	if (name == "") then return end
	if (description == "") then return end
	if (default == 0) then return end

	local setting = {}
	setting.description = description
	setting.cvcmd = "cl_"..self.NetworkaddonID.."_key_"..name
	setting.default = default
	setting.time = time

	if (extra_text != "") then
		setting.extra_text = extra_text
	end

	if CLIENT then
		setting.cv = CreateClientConVar( setting.cvcmd, tostring( default ), true, false )
	end

	self.KeySettings = self.KeySettings or {}
	self.KeySettings[name] = setting
end

if CLIENT then

function SW_ADDON:SendVehicleOrder(vehicle, name, down)
	if !IsValid(vehicle) then return end

	local ID = self.NetworkaddonID or ""
	if ID == "" then
		error("Invalid NetworkaddonID!")
		return
	end
	
	name = name or ""
	down = down or false

	if name == "" then return end
	
	self.KeyBuffer = self.KeyBuffer or {}
	self.KeyBuffer[vehicle] = self.KeyBuffer[vehicle] or {}
	
	local changedbuffer = self.KeyBuffer[vehicle][name] or {}

	if changedbuffer.state == down then return end
	changedbuffer.state = down
	
	self.KeyBuffer[vehicle][name] = changedbuffer

	local netname = "SligWolf_VehicleOrder_"..ID.."_"..name
	net.Start(netname) 
		net.WriteEntity(vehicle)
		net.WriteBool(down)
	net.SendToServer()
end
end

function SW_ADDON:SoundEdit(sound, state, pitch, pitchtime, volume, volumetime)

	sound = sound or nil
	if !sound then return end
	
	state = state or 0
	pitch = pitch or 100
	pitchtime = pitchtime or 0
	volume = volume or 1
	volumetime = volumetime or 0
	
	if state == 0 then
		sound:Stop()
	end
	if state == 1 then
		sound:Play()
	end
	if state == 2 then
		sound:ChangePitch(pitch, pitchtime)
	end
	if state == 3 then
		sound:ChangeVolume(volume, volumetime)
	end
	if state == 4 then
		sound:Play()
		sound:ChangePitch(pitch, pitchtime)
		sound:ChangeVolume(volume, volumetime)
	end
	if state == 5 then
		sound:Stop()
		sound:ChangePitch(pitch, pitchtime)
		sound:ChangeVolume(volume, volumetime)
	end
end

function SW_ADDON:ViewEnt( ply )
	if !IsValid(ply) then return end
	
	local Old_Cam = ply:GetViewEntity()
	ply.__SW_Old_Cam = Old_Cam
	local Cam = ply.__SW_Old_Cam
	
	if !IsValid(Cam) then return end
	if !ply.__SW_Cam_Mode then return end
	
	ply:SetViewEntity(ply)
	ply.__SW_Cam_Mode = false
end

function SW_ADDON:ValidateName(name)
	name = tostring(name or "")
	name = string.gsub(name, "^!", "", 1)
	name = string.gsub(name, "[\\/]", "")
	return name
end

function SW_ADDON:VectorToLocalToWorld( ent, vec )
	if !IsValid(ent) then return nil end
	
	vec = vec or Vector()
	vec = ent:LocalToWorld(vec)
	
	return vec
end

function SW_ADDON:DirToLocalToWorld( ent, ang, dir )
	if !IsValid(ent) then return nil end
	
	dir = dir or ""
	
	if dir == "" then
		dir = "Forward"
	end
	
	ang = ang or Angle()
	ang = ent:LocalToWorldAngles(ang)
		
		
	local func = ang[dir]
	if !isfunction(func) then return end

	return func(ang)
end

function SW_ADDON:GetAttachmentPosAng(ent, attachment)
	if !self:IsValidModel(ent) then return nil end
	attachment = tostring(attachment or "")

	if attachment == "" then
		local pos = ent:GetPos()
		local ang = ent:GetAngles()

		return pos, ang, false
	end

	local Num = ent:LookupAttachment(attachment) or 0
	if Num <= 0 then
		local pos = ent:GetPos()
		local ang = ent:GetAngles()

		return pos, ang, false
	end

	local Att = ent:GetAttachment(Num)
	if not Att then
		local pos = ent:GetPos()
		local ang = ent:GetAngles()

		return pos, ang, false
	end

	local pos = Att.Pos
	local ang = Att.Ang

	return pos, ang, true
end

local Color_trGreen = Color( 50, 255, 50 )
local Color_trBlue = Color( 50, 50, 255 )
local Color_trTextHit = Color( 100, 255, 100 )

function SW_ADDON:Tracer( ent, vec1, vec2, filterfunc )
	if !IsValid(ent) then return nil end
	
	vec1 = vec1 or Vector()
	vec2 = vec2 or Vector()

	if !isfunction(filterfunc) then
		filterfunc = (function()
			return true
		end)
	end
	
	local tr = util.TraceLine( {
		start = vec1,
		endpos = vec2,
		filter = function(trent, ...)
			if !IsValid(ent) then return false end
			if !IsValid(trent) then return false end
			if trent == ent then return false end
			
			local sp = self:GetSuperParent(ent)
			if !IsValid(sp) then return false end
			if trent == sp then return false end

			if self:GetSuperParent(trent) == sp then return false end
			return filterfunc(self, sp, trent, ...)
		end
	} )
	
	if !tr then return nil end
	
	vec1 = tr.StartPos
	
	debugoverlay.Cross( vec1, 1, 0.1, color_white, true ) 
	debugoverlay.Cross( vec2, 1, 0.1, color_white, true ) 
	debugoverlay.Line( vec1, tr.HitPos, 0.1, Color_trGreen, true )
	debugoverlay.Line( tr.HitPos, vec2, 0.1, Color_trBlue, true )
	debugoverlay.EntityTextAtPosition(vec1, 0, "Start", 0.1, color_white)
	
	if tr.Hit then
		debugoverlay.EntityTextAtPosition(tr.HitPos, 0, "Hit", 0.1, Color_trTextHit)
	end
	
	debugoverlay.EntityTextAtPosition(vec2, 0, "End", 0.1, color_white)
	
	return tr
end

function SW_ADDON:GetRelativeVelocity(ent)
	if !IsValid(ent) then return end

	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end
	
	local v = phys:GetVelocity()
	return phys:WorldToLocalVector(v)
end

function SW_ADDON:GetForwardVelocity(ent)
	local v = self:GetRelativeVelocity(ent)
	if !v then return 0 end
	
	return v.y or 0
end

function SW_ADDON:GetKPHSpeed(v)
	local UnitKmh = math.Round((v * 0.75) * 3600 * 0.0000254)
	return UnitKmh
end