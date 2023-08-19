ENT.Type = "anim"
ENT.PrintName = "Switcher Base"
ENT.Author = "Chancer"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Category = "Switcher Entities"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.name = "Model Switcher"
ENT.model = "models/props_canal/bridge_pillar02.mdl"
--ENT.nsfaction = "" -- the new faction to make the player
--ENT.nsclass = "" -- the new class to make the player
--ENT.nsmodel = "" -- the new Model to make the playuer
--ENT.itemCost = "" -- by uniqueID, the required fuel for the switcher
--ENT.itemDesc = "" -- the notification you will recieve if the item is put in
--ENT.humanOnly = true -- If the Switcher should only be usable by humans
--ENT.customNotification = "" -- a custom client-side descriptor
--ENT.notificationOverride = true -- Should the client-side notification not display if itemCost is true?
ENT.TransformTime = 1
ENT.NotifDescription = "Do you want to switch?"

--[[
if ENT.ItemCost and !ENT.notificationOverride then -- A client notification for what the chamber does
	if SERVER then
		ENT.netSwitcherString = (ENT.name .. "UseNotification")
		util.AddNetworkString( ENT.netSwitcherString )
	end

	if CLIENT then --  Unique information notification
		net.Receive(ENT.netSwitcherString, function()
			chat.AddText(Color(255,0,0), "[ " .. ENT.name .. " ]", Color(255,100,100), " Information:")
			chat.AddText("· This chamber requires a fuel item")
			chat.AddText("· " .. ENT.customNotification or "")
			if !ENT.humanOnly then
				chat.AddText("· The chamber will convert any creature")
			elseif ENT.humanOnly then
				chat.AddText("· The chamber will convert humans only")
			end
		end)
	end
end
--]]


if (SERVER) then
	function ENT:Initialize()
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local pos = self:GetPos()

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
			physicsObject:Sleep()
		end
	end

	--changes a player's faction
	local function changeFaction(client, name)
		local character = client:getChar()

		if (not IsValid(client) or not character) then
			return false
		end

		-- Find the specified faction.
		local oldFaction = nut.faction.indices[character:getFaction()]
		local faction = nut.faction.teams[name]
		if (not faction) then
			for k, v in pairs(nut.faction.indices) do
				if (nut.util.stringMatches(L(v.name, client), name)) then
					faction = v
					break
				end
			end
		end

		if (not faction) then
			return false
		end

		-- Change to the new faction.
		character.vars.faction = faction.uniqueID
		character:setFaction(faction.index)
		if (faction.onTransfered) then
			faction:onTransfered(client, oldFaction)
		end
		hook.Run("CharacterFactionTransfered", character, oldFaction, faction)
	end

	--changes a player's faction
	local function changeClass(client, class)
		local char = client:getChar()

		if (IsValid(client) and char) then
			local num = isnumber(tonumber(class)) and tonumber(class) or -1

			if (nut.class.list[num]) then
				local v = nut.class.list[num]

				if (char:joinClass(num)) then
					local class = nut.class.list[num]
					char:setData("class", class.uniqueID)
					--client:notifyLocalized("becomeClass", L(v.name, client))

					return
				else
					--client:notifyLocalized("becomeClassFail", L(v.name, client))

					return
				end
			else
				for k, v in ipairs(nut.class.list) do
					if (nut.util.stringMatches(v.uniqueID, class) or nut.util.stringMatches(L(v.name, client), class)) then
						if (char:joinClass(k)) then
							local class = nut.class.list[k]
							char:setData("class", class.uniqueID)
							--client:notifyLocalized("becomeClass", L(v.name, client))

							return
						else
							--client:notifyLocalized("becomeClassFail", L(v.name, client))

							return
						end
					end
				end
			end
		end
	end

	function ENT:Use(activator)
		if ((self.nextUse or 0) > CurTime()) then return end
		self.nextUse = CurTime() + 5

		if (self.nextNotif or 0) > CurTime() then
			self.nextNotif = CurTime() + 5
			netstream.Start(activator, "nut_switcherPreUseNotif", self)
		end

		local char = activator:getChar()

			if self.itemCost then
				for _, item in pairs(char:getInv():getItems()) do
						if item.uniqueID == self.itemCost and not self.activated then
						activator:falloutNotify(self.itemDesc, "ui/notify.mp3")
						self:EmitSound("ambient/levels/citadel/pod_open1.wav")
						jlib.Announce(activator, Color(255, 0, 0), "[NOTICE]  ", Color(255, 255, 255), "Remember, you cannot kill anyone you forcefully transform!")
						item:remove()
						self.activated = true
						return --returns here so that the item is put in without player going into chamber
					end
			end

			--notifies player about what they need if they don't have it
			if !self.activated then
				local itemTable = nut.item.list[self.itemCost]
				if(itemTable) then
					activator:falloutNotify("This chamber requires " ..itemTable:getName())
				end

				return
			end
		end

		--these are after the itemCost so that things that can't use the pod can still prepare them for others
		if !Armor.IsHuman(char) and self.humanOnly then  -- Check model to make sure is actually a "non-human" trying to use it (NON-NEW MODEL)
			activator:falloutNotify("[ ! ] Only humans can use this chamber!", "ui/notify.mp3")
			return
		end

		if char:getModel() == "models/arachnit/fallout4/synths/synthgeneration1.mdl" then
			activator:falloutNotify("You can't escape what you've become. . .", "ui/ui_xp_up.mp3")
			return
		end

		netstream.Start(activator, "nut_switcherStart", self)
	end

	--called after confirmation prompt
	function ENT:activate(activator)
		local char = activator:getChar()
		if !char then return end
		local inv = char:getInv()

		--unequips armor before changing them
		for _, item in pairs(inv:getItems()) do
			if item.isjArmor or item.isArmor then
				item:setData("equipped", false)

				if !IsValid(item.player) then
					item.player = activator
				end
			end
		end

		if char:getData("oldMdl") then
			char:setModel(char:getData("oldMdl"))
			char:setData("oldMdl", nil)
		end
		char:setVar("armor", nil)

		self:onUseStart(activator) --function that runs before the changes

		--make player invisible and stop them from moving
		activator:ScreenFade(SCREENFADE.IN, Color( 255,255,255, 255 ), 0.5, 0)
		activator:Lock()
		activator:SetNoDraw(true)
		activator:SetNotSolid(true)
		activator:SetMoveType(MOVETYPE_NONE)
		jlib.TimedSpectate(activator, self, self.TransformTime or 1)
		activator:ConCommand("simple_thirdperson_enabled 0") -- prevents a STP view bug
		activator:SelectWeapon("nut_keys")

		activator:setAction("Changing...", self.TransformTime or 1, function()
			local oldPos = activator:GetPos()

			--restore movement and visibility
			activator:SetNoDraw(false)
			activator:SetNotSolid(false)
			activator:SetMoveType(MOVETYPE_WALK)
			activator:UnLock()

			--set faction
			if(self.nsfaction) then
				changeFaction(activator, self.nsfaction)
			end

			--set class
			if(self.nsclass) then
				changeClass(activator, self.nsclass)
			end

			--set model
			if(self.nsmodel) then
				activator:getChar():setModel(self.nsmodel)
			end

			self:onUseEnd(activator) --function that runs at the end

			activator:SetPos(oldPos)

			self.activated = nil
		end)
	end

	--ran before the timer starts
	function ENT:onUseStart(activator)

	end

	--ran after the timer ends
	function ENT:onUseEnd(activator)

	end

	netstream.Hook("nut_switcherEnd", function(activator, entity)
		entity:activate(activator)
	end)
else
	--A notification that happens before everything else
	function ENT:preUseNotif()

	end

	--networking that runs the pre use notification
	netstream.Hook("nut_switcherPreUseNotif", function(entity)
		if(entity.preUseNotif) then
			entity:preUseNotif()
		end
	end)

	netstream.Hook("nut_switcherStart", function(entity)
		if entity.ItemCost and !entity.notificationOverride then -- A client notification for what the chamber does
			chat.AddText(Color(255,0,0), "[ " ..entity.name.. " ]", Color(255,100,100), " Information:")
			chat.AddText("· This chamber requires a fuel item")
			chat.AddText("· " ..entity.customNotification or "")
		end

		if(entity.notificationOverride) then
			if !entity.humanOnly then
				chat.AddText("· The chamber will convert any creature")
			elseif entity.humanOnly then
				chat.AddText("· The chamber will convert humans only")
			end
		end

		Derma_Query(entity.NotifDescription, "Confirmation", "Yes", function()
			netstream.Start("nut_switcherEnd", entity)
		end, "No")
	end)

	function ENT:Draw()
		self:DrawModel()
	end

	ENT.DrawEntityInfo = true
	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha
	local drawText = nut.util.drawText
	local configGet = nut.config.get

	function ENT:onDrawEntityInfo(alpha)
		local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
		local x, y = position.x, position.y
		local tx, ty = drawText(self.name or self.PrintName, x, y, colorAlpha(configGet("color"), alpha), 1, 1, nil, alpha * 2)
		--drawText(self.harvestMsg, ScrW() * 0.5, ScrH() * 0.8, colorAlpha(color_white, alpha), 1, 1, "nutEntDesc", alpha * 0.65)
	end
end
