ITEM.name = "Zip Tie"
ITEM.desc = "An orange zip-tie used to restrict players and search their inventory | This item has rules of use"
ITEM.price = 50
ITEM.model = "models/items/crossbowrounds.mdl"
--ITEM.factions = {FACTION_CP, FACTION_OW}
ITEM.functions.Use = {
	onRun = function(item)
		if (item.beingUsed) then
			return false
		end

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity
	-- Checks the following: Is Player? / Is target a character? / is target alive? / is target in a pill? / is target being tied already? / is target tied already?
		if (IsValid(target) and target:IsPlayer() and target:getChar() and target:Alive() and (pk_pills and !IsValid(pk_pills.getMappedEnt(target))) and !target:getNetVar("tying") and !target:getNetVar("restricted")) then
			item.beingUsed = true

			target:EmitSound("npc/barnacle/neck_snap2.wav")
			target:falloutNotify("[ ! ]  You are being zip tied", "ui/notify.mp3")  -- Custom notification

			nut.chat.send(client, "it", "takes the persons hands and starts tying them together . . .")

			client:setNetVar("tying", CurTime())
			target:setNetVar("tyingT", CurTime())

			client:setAction("tying", 5, function()
				if(IsValid(target) and IsValid(client) and target:GetPos():Distance(client:GetPos()) < 96) then
					client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)

					jlib.Announce(client, Color(255,0,0), "[NOTICE] ",
						Color(255,155,155), "You have zip tied someone . . .",
						Color(255,255,255), "\n· Hold 'E' or '/charsearch' to search their inventory",
						Color(255,255,255), "\n· Type '/info' to check the rules of mugging",
						Color(255,255,255), "\n· You cannot kill someone you mugged/branded",
						Color(255,255,255), "\n· Do not hold them hostage longer than you need to"
					)

					jlib.Announce(target, Color(255,0,0), "[NOTICE] ",
						Color(255,155,155), "You have been zip tied . . .",
						Color(255,255,255), "\n· You must obey them as long as you have at least 1 weapon aimed at you [FearRP]",
						Color(255,255,255), "\n· Type '/info' to check the rules of mugging"
					)

					nut.chat.send(client, "it", "ties the persons hands together with a zip tie")

					target:setRestricted(true)

					item:remove()
				else
					client:falloutNotify("[ ! ]  Tying has failed")  -- Custom notification
				end

				client:setNetVar("tying", nil)
				target:setNetVar("tyingT", nil)
				item.beingUsed = nil
			end)
		else
			item.player:notifyLocalized("plyNotValid")
		end


		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity)
	end
}

function ITEM:onCanBeTransfered(inventory, newInventory)
	return !self.beingUsed
end
