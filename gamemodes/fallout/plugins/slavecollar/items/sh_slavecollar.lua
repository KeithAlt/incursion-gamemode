ITEM.name = "Slave Collar"
ITEM.desc = "Explosive device worn around neck with a GPS tracker."
ITEM.model = "models/marvless/weapons/w_slavecollar.mdl"
ITEM.category = "Slavery"

if (CLIENT) then
	LOCK = Material("icon16/lock.png", "noclamp smooth")

	function ITEM:paintOver(item, w, h)
		if item:getData("arm") then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end

		if item:getData("equip") then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(LOCK)
			surface.DrawTexturedRect(4, 4, 8, 8)
		end

		time = string.FormattedTime(item:getData("time", nut.config.get("maxEnslaveTime")), "%02i:%02i")

		surface.SetFont("nutSmallFont")
		surface.SetTextColor(color_white)
		surface.SetTextPos(4, h - 18)
		surface.DrawText(time)
	end
else

	--[[-------------------------------------------------------------------------
	Clothing system.
	---------------------------------------------------------------------------]]
	-- Set "collar" to clientside entity when bool == true and delete when bool == false
	--[[
	function ITEM:addPart(bool)
		if IsEntity(self:getData("collar")) and self:getData("collar"):IsValid() then
			self:getData("collar"):Remove()
		end

		if not bool then
			if not IsEntity(self:getData("collar")) and not self:getData("collar"):IsValid() then return end

			self:getData("collar"):Remove()
			return
		end

		local owner = self:getOwner()
		if type(self:getOwner()) == "table" then
			owner = self:getOwner()[2]
		end

		local collar = ents.Create("prop_physics")
		collar:SetModel("models/marvless/weapons/w_slavecollar.mdl")
		collar:FollowBone(owner, owner:LookupBone("ValveBiped.Bip01_Neck1"))
		collar:SetLocalPos(Vector(3, -2, 0))
		collar:SetLocalAngles(Angle(90, 0, 0))
		collar:SetCollisionGroup(COLLISION_GROUP_WORLD)
		collar:Spawn()

		self:setData("collar", collar)
	end
	--]]

	function ITEM:addPart(bool)
		local owner = self:getOwner()
		if type(self:getOwner()) == "table" then
			owner = self:getOwner()[2]
		end

		if bool then
			owner:AddAccessory("slave_collar_clothes")
			if SERVER then
				owner:falloutNotify("[ ! ]  You have been enslaved", "ui/badkarma.ogg") -- Information notification
				owner:ChatPrint("[ INFO ]  As a slave, you must obey the commands of your captures")
				owner:ChatPrint("- You are under FearRP consistently while enslaved")
				owner:ChatPrint("- Disobeying your captures commands is against server rules")
			end
		else
			owner:RemoveAccessory("slave_collar_clothes")
		end
	end

	function ITEM:wearCollar(bool, beep)
		if not self:getOwner() then return end

		owner = self:getOwner()
		if type(self:getOwner()) == "table" then
			owner = self:getOwner()[2]
		end

		local char = owner:getChar()
		if !char then return end

		self:setData("equip", bool)
		self:setData("proximity", self:getData("proximity", false))
		self:setData("arm", false)

		self:addPart(bool)

		if not self:getData("time") then
			self:setData("time", nut.config.get("maxEnslaveTime"))
		end

		if beep then
			owner:EmitSound("slavecollar/beep.wav")
		end

		if bool then
			owner:setNetVar("enslaved", true)
			char:setVar("collarID", self.id)
		else
			owner:setNetVar("enslaved", nil)
			char:setVar("collarID", -1)
		end

		if self:getData("equip") then
			timer.Create("slaveCollarTime"..self:getID(), 1, self:getData("time"), function()

				-- If player exists, otherwise close
				if not self:getOwner() then
					timer.Remove("slaveCollarTime"..self:getID())
				end

				self:setData("time", self:getData("time") - 1)

				if timer.RepsLeft("slaveCollarTime"..self:getID()) == 0 then
					self:remove()
				end
			end)
		else
			if timer.Exists("slaveCollarTime"..self:getID()) then
				timer.Remove("slaveCollarTime"..self:getID())
			end
		end
	end
end

ITEM.functions.arm = {
	name = "Arm",
	tip = "Specify this as the slave collar to use.",
	icon = "icon16/tick.png",
	onRun = function(item)
		item:setData("arm", not item:getData("arm", false))

		item:setData("owner", item:getOwner():getChar():getID())

		item.player:EmitSound("slavecollar/beep.wav")

		return false
	end,
	onCanRun = function(item)
		return (not item:getData("equip")) and not IsValid(item.entity)
	end
}

/**
ITEM.functions.force = {
	name = "Force Lock",
	tip = "(Admin only) Lock the item.",
	icon = "icon16/lock.png",
	onRun = function(item)
		item:wearCollar(not item:getData("equip", false), true)

		return false
	end,
	onCanRun = function(item)
		if item:getOwner() then
			if item:getOwner():IsAdmin() then --only let admins use this thing
				return true
			else
				return false
			end
		end

		return not IsValid(item.entity)
	end
}
**/

function ITEM:onLoadout()
	self:wearCollar(self:getData("equip", false))
end

function ITEM:onRemoved()
	self:wearCollar(false)
end

function ITEM:getDesc()
	local locked = "NO"
	if self:getData("equip") then
		locked = "YES"
	end

	return self.desc.."\nLocked: "..locked
end

function ITEM:onCanBeTransfered(curInv, inventory)
	return not self:getData("equip", false)
end
