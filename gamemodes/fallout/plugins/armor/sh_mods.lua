local function BuffStat(ply, item, stat, amt)
	item.ArmorBuffs = item.ArmorBuffs or {}
	item.ArmorBuffs[stat.."M"] = ply:BuffStat(stat, amt, -1)
end

local function EndBuff(ply, item, stat)
	if !item.ArmorBuffs or !item.ArmorBuffs[stat.."M"] then
		return
	end

	ply:StopStatBuff(stat, item.ArmorBuffs[stat.."M"])
	item.ArmorBuffs[stat.."M"] = nil
end

nut.armor.mods = {
	strength = {
		name 	= "Strength Modulator",
		desc 	= "Improves your strength SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "strength",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "S", 3)
		end,
		
		OnRemove = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Strength (+3)"
		end,
	},
	perception = {
		name 	= "Perception Modulator",
		desc 	= "Improves your perception SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "perception",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "P", 3)
		end,

		OnRemove = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Perception (+3)"
		end,
	},
	endurance = {
		name 	= "Endurance Modulator",
		desc 	= "Improves your endurance SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "endurance",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "E", 3)
		end,

		OnRemove = function(ply, item)
			EndBuff(ply, item, "E")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Endurance (+3)"
		end,
	},
	charisma = {
		name 	= "Charisma Modulator",
		desc 	= "Improves your charisma SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "charisma",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "C", 3)
		end,

		OnRemove = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Charisma (+3)"
		end,
	},
	intellgence = {
		name 	= "Intelligence Modulator",
		desc 	= "Improves your intelligence SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "intellgence",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "I", 3)
		end,

		OnRemove = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Intelligence (+3)"
		end,
	},
	agility = {
		name 	= "Agility Modulator",
		desc 	= "Improves your agility SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "agility",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "A", 3)
		end,

		OnRemove = function(ply, item)
			EndBuff(ply, item, "A")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Agility (+3)"
		end,
	},
	luck = {
		name 	= "Luck Modulator",
		desc 	= "Improves your luck SPECIAL by +3",
		model = "models/maxib123/enclavelockersmall.mdl",
		isPA 	= nil,
		slot 	= "luck",
		OnEquip = function(ply, item)
			BuffStat(ply, item, "L", 3)
		end,

		OnRemove = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		
		ArmorDesc = function() -- Called by armor's getDesc()
			return "Luck (+3)"
		end,
	},
}

function PLUGIN:PlayerSpawn(client, char)
	local char = client:getChar()
	if(!char) then return end
	
	local inventory = char:getInv()
	for k, item in pairs(inventory:getItems()) do
		if(item.ArmorBuffs) then
			item.ArmorBuffs = nil
		end
	end
end
