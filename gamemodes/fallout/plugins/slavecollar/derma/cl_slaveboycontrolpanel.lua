local PANEL = {}

function PANEL:Init()	
	self:Dock(FILL)
	self:DockMargin(ScrW() * 0.25, ScrH() * 0.25, ScrW() * 0.25, ScrH() * 0.25)

	self:MakePopup()
	self:SetTitle("")

	self.item = LocalPlayer():getSlaveboy()

	self.lineToID = {}

	self.manifest = self:Add("DListView")
	self.manifest:Dock(FILL)
	self.manifest:AddColumn("Name")
	self.manifest:AddColumn("Location")
	self.manifest:AddColumn("Proximity")
	self:updateManifest()
	self.manifest.OnRowRightClick = function(this, rowID)
		local character = self:findCharacter(self.lineToID[rowID])
		if(!character) then return false end

		if not IsValid(character:getPlayer()) then
			for _, client in ipairs(player.GetAll()) do
				if not client:getChar() then continue end
				
				if client:getChar():getID() == character.id then
					character = client
				end
			end
		else
			character = character:getPlayer()
		end

		-- Interactions with slaves
		self.menu = DermaMenu()
		local detonate = self.menu:AddOption("Detonate", function()
			net.Start("nutSlaveCollarActions")
			net.WriteString("detonate")
			net.WriteEntity(character)
			net.SendToServer()

			self:updateManifest()
		end)
		detonate:SetIcon("icon16/bomb.png")

		local lock = self.menu:AddOption("Unlock", function()
			net.Start("nutSlaveCollarActions")
			net.WriteString("unlock")
			net.WriteEntity(character)
			net.SendToServer()

			self:updateManifest()
		end)
		lock:SetIcon("icon16/lock_open.png")

		local proximity = self.menu:AddOption("Toggle Proximity", function()
			net.Start("nutSlaveCollarActions")
			net.WriteString("proximity")
			net.WriteEntity(character)
			net.SendToServer()

			self:updateManifest()
		end)
		proximity:SetIcon("icon16/tick.png")

		local locate = self.menu:AddOption("Locate", function()
			self:locate(character)
		end)
		locate:SetIcon("icon16/map.png")

		self.menu:Open(gui.MouseX(), gui.MouseY(), nil, self)
	end

	if type(nut.plugin.list["slavecollar"].factions) == "table" then
		//if table.HasValue(nut.plugin.list["slavecollar"].factions, nut.faction.indices[LocalPlayer():Team()].uniqueID) then
			self.spawnpointButton = self:Add("DButton")
			self.spawnpointButton:Dock(BOTTOM)
			self.spawnpointButton:SetText("Create Spawnpoint")
			self.spawnpointButton.DoClick = function()
				net.Start("nutCreateSpawnpoint")
				net.SendToServer()
			end
		//end
	end
end

function PANEL:updateManifest(manifest)
	self.manifest:Clear()

	if not manifest then
		net.Start("nutUpdateSlaveManifest")
		net.SendToServer()
		return
	end

	for k, character in ipairs(manifest) do
		self.manifest:AddLine(character["name"], character["location"], character["proximity"])
		self.lineToID[k] = character["id"]
	end
end

function PANEL:findCharacter(id)
	id = tonumber(id)

	for _, client in ipairs(player.GetAll()) do
		if not client:getChar() then continue end
		
		if client:getChar():getID() == id then
			return client:getChar()
		end
	end
end

function PANEL:locate(target)
	local startTime = CurTime()
	hook.Add("HUDPaint", "nutLocateSlave", function()
		if CurTime() >= startTime + 15 then return end

		local point = target.LocalToWorld(target, target.OBBCenter(target))
		local pos = point:ToScreen()

		draw.SimpleText("▼", "nutHugeFont", pos.x, pos.y, nut.config.get("color"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
end

function PANEL:OnRemove()
	if LocalPlayer().weapon_mad_collar then
		LocalPlayer().weapon_mad_collar = nil
	end
end

vgui.Register("nutSlaveboyControlPanel", PANEL, "DFrame")

net.Receive("nutSlaveboyControlPanel", function()
	LocalPlayer().weapon_mad_collar = vgui.Create("nutSlaveboyControlPanel")
end)

net.Receive("nutUpdateSlaveManifestToClient", function()
	if not LocalPlayer().weapon_mad_collar then return end

	local manifest = net.ReadTable()

	LocalPlayer().weapon_mad_collar:updateManifest(manifest)
end)