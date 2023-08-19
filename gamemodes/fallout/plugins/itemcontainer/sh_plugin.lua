local PLUGIN = PLUGIN

PLUGIN.name = "World Item Container"
PLUGIN.author = "Thadah Denyse"
PLUGIN.desc = "Spawns world containers with items inside"

nut.config.add("wicEnabled", true, "Whether or not World Item Container is enabled.", nil, {category = "WorldItemContainer"})
nut.config.add("wicCount", 2, "Number of items each container will have inside.", nil, {data = {min = 1, max = 20}, category = "WorldItemContainer"})
nut.config.add("wicMaxContainerSpawn", 1, "Number of containers each spawn will have.", nil, {data = {min = 1, max = 50}, category = "WorldItemContainer"})
nut.config.add("wicMaxWorldContainers", 6, "Number of containers the World will have.", nil, {data = {min = 1, max = 20}, category = "WorldItemContainer"})
nut.config.add("wicTime", 1, "How much time it will take for a container to spawn.", nil, {data = {min = 1, max = 86400}, category = "WorldItemContainer"})
nut.config.add("wicContainerTime", 1, "How much time it will take for a container to spawn.", nil, {data = {min = 1, max = 86400}, category = "WorldItemContainer"})
nut.config.add("wicContainerDeathTime", 20, "How much time it will take for a container to dissapear (in seconds).", nil, {data = {min = 10, max = 84600}, category = "WorldItemContainer"})
nut.config.add("wicWidth", 6, "How wide the container's inventory will be.", nil, {data = {min = 1, max = 20}, category = "WorldItemContainer"})
nut.config.add("wicHeight", 4, "How high the container's inventory will be.", nil, {data = {min = 1, max = 20}, category = "WorldItemContainer"})

--Chances a category will have to be chosen over other categories
PLUGIN.itemRare = {
	exotic	 = {25, {"category4"}},
	rare	 = {75, {"category3"}},
	uncommon = {365, {"category2"}},
	common	 = {750, {"category"}}
}

--Items that will spawn inside the containers
PLUGIN.itemTable = {
	category 		=	{"scrap", "scrap", "scrap", "cork", "cork", "electronics"},
	category2		=	{"scrap", "scrap", "cork", "cork", "crystal", "powder"},
	category3		=	{"scrap", "scrap", "powder", "electronics", "cork", "crystal"},
	category4		=	{"scrap", "fielddata", "scrap", "crystal", "cork", "powder"},
}

--Container Models
PLUGIN.containerModel = {
	"models/props_junk/wood_crate001a.mdl",


}

PLUGIN.spawnedContainers = PLUGIN.spawnedContainers or {}
PLUGIN.contPoints = PLUGIN.contPoints or {}

if (SERVER) then
	local wicTime = 1

	function PLUGIN:Think()
		local curTime = CurTime()
		if nut.config.get("wicEnabled") then

			self:removeInvalidContainers()
						
			if (#self.spawnedContainers <= nut.config.get("wicMaxWorldContainers") or #self.spawnedContainers <= (nut.config.get("wicMaxContainerSpawn")*#self.contPoints)) then 
				if nut.config.get("wicContainerTime") <= curTime then
					for i=1,nut.config.get("wicMaxContainerSpawn") do
						local point = table.Random(self.contPoints) 
						
						if (!point) then return end

						if nut.config.get("wicMaxContainerSpawn") == 1 then
							for _, v in pairs(self.spawnedContainers) do
								if point == v[2] then return end
							end
						end

						if #self.spawnedContainers >= nut.config.get("wicMaxWorldContainers") then return end

						self:setContainer(point)
					
					end
				end
			end	
		end
	end

	function PLUGIN:removeInvalidContainers()
		for k, v in ipairs(self.spawnedContainers) do
			if !IsValid(v[1]) then
				table.remove(self.spawnedContainers, k)
			end
		end
	end

	function PLUGIN:setContainer(point)
		local entity = ents.Create("nut_itemcontainer")
		entity:SetPos(point + Vector(1,128,1))
		entity:SetAngles(entity:GetAngles())
		entity:Spawn()
		entity:setNetVar("name", "Container" )
		entity:setNetVar("max", 5000 )
		entity:SetModel(table.Random(self.containerModel))
		entity:SetSolid(SOLID_VPHYSICS)
		entity:PhysicsInit(SOLID_VPHYSICS)


		local physObj = entity:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end

		local invName = "itemcontainer-"..math.random()

		nut.item.newInv(0, invName, function(inventory)
			if (IsValid(entity)) then
				inventory:setSize(nut.config.get("wicWidth"), nut.config.get("wicHeight"))
				entity:setInventory(inventory)
			end
		end)

		local result = self:chooseRandom()

		self:addItems(result, entity)

		table.insert(self.spawnedContainers, {entity, points})
	end

	function PLUGIN:chooseRandom()
		local result
		local c = 0
		local r = math.random(1, 1000)
		for _, v in pairs(self.itemRare) do
			c = c + v[1]
			if c >= r then
				result = table.Random(v[2])
				break
			else
				continue
			end
		end

		if !result then
			result = self.itemRare["common"][2]
		end

		return result
	end

	function PLUGIN:addItems(result, entity)
		local inv = entity:getInv()
		for i=1,nut.config.get("wicCount") do
			local item = table.Random(self.itemTable[result])
			inv:add(item)
		end
	end

	function PLUGIN:SaveData()
		self:savePoints()
	end

	function PLUGIN:LoadData()
		self:loadPoints()
	end

	function PLUGIN:loadPoints()
		self.contPoints = self:getData() or {}
	end
	
	function PLUGIN:savePoints()
		self:setData(self.contPoints)
	end
	

	function PLUGIN:ContItemRemoved(entity, inventory)
		self:saveCont()
	end

	function PLUGIN:ContCanTransfer(inventory, client, oldX, oldY, x, y, newInvID)
		local inventory2 = nut.item.inventories[newInvID]

		print(inventory2)
	end

	netstream.Hook("contExit", function(client)
		local entity = client.nutBagEntity

		if (IsValid(entity)) then
			entity.receivers[client] = nil
		end

		client.nutBagEntity = nil
	end)
else
	netstream.Hook("nut_displayContSpawnPoints", function(data)
		for k, v in pairs(data) do
			print(data)
			local emitter = ParticleEmitter( v )
			local smoke = emitter:Add( "sprites/glow04_noz", v )
			smoke:SetVelocity( Vector( 0, 0, 1 ) )
			smoke:SetDieTime(15)
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(255)
			smoke:SetStartSize(64)
			smoke:SetEndSize(64)
			smoke:SetColor(255,0,0)
			smoke:SetAirResistance(300)
		end
	end)

	netstream.Hook("contOpen", function(entity, index)
		local inventory = nut.item.inventories[index]

		if (IsValid(entity) and inventory and inventory.slots) then
			nut.gui.inv1 = vgui.Create("nutInventory")
			nut.gui.inv1:ShowCloseButton(true)

			local inventory2 = LocalPlayer():getChar():getInv()

			if (inventory2) then
				nut.gui.inv1:setInventory(inventory2)
			end

			local panel = vgui.Create("nutInventory")
			panel:ShowCloseButton(true)
			panel:SetTitle("Container")
			panel:setInventory(inventory)
			panel:MoveLeftOf(nut.gui.inv1, 4)
			panel.OnClose = function(this)

				if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
					nut.gui.inv1:Remove()
				end

				netstream.Start("contExit")
			end
			local oldClose = nut.gui.inv1.OnClose
			nut.gui.inv1.OnClose = function()
				if (IsValid(panel) and !IsValid(nut.gui.menu)) then
					panel:Remove()
				end

				netstream.Start("contExit")
				nut.gui.inv1.OnClose = oldClose
			end

			nut.gui["inv"..index] = panel
		end
	end)
end

nut.command.add("wicaddspawn", {
	adminOnly = true,
	onRun = function(client)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + Vector(trace.HitNormal*5)
		table.insert(PLUGIN.contPoints, hitpos)
		client:notify("You've added a new container spawner")
	end
})

nut.command.add("wicremovespawn", {
	adminOnly = true,
	syntax = "<number distance>",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local range = arguments[1] or 128
		local count = 0
		for k, v in pairs(PLUGIN.contPoints) do
			local distance = v:Distance(hitpos)
			if distance <= tonumber(range) then
				PLUGIN.contPoints[k] = nil
				count = count+1
			end
		end
		client:notify(count.." spawners have been removed")
	end
})


nut.command.add("wicdisplayspawn", {
	adminOnly = true,
	onRun = function(client)
		if SERVER then
			netstream.Start(client, "nut_displayContSpawnPoints", PLUGIN.contPoints)
			client:notify("Displaying all container spawnpoints for 15 seconds")
		end
	end
})