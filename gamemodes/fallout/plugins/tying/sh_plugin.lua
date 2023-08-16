PLUGIN.name = "Tying"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds the ability to tie players."

nut.util.include("sh_charsearch.lua")

if (SERVER) then
	function PLUGIN:PlayerLoadout(client)
		client:setNetVar("restricted")
	end

	function PLUGIN:PlayerUse(client, entity)
		--[[
		if (!client:getNetVar("restricted") and entity:IsPlayer() and entity:getNetVar("restricted") and !entity.nutBeingUnTied) then
			entity.nutBeingUnTied = true
			
			client:setNetVar("tyingU", CurTime())
			entity:setNetVar("tyingU", CurTime())
			
			client:setAction("Untying", 5, function()
				if(IsValid(entity) and IsValid(client) and entity:GetPos():Distance(client:GetPos()) < 96) then
					client:EmitSound("npc/roller/blade_in.wav")

					nut.chat.send(client, "me", "unties " ..entity:Name().. "'s hands . . .")

					entity:setRestricted(false)
				else
					client:falloutNotify("[ ! ]  Untying has failed")  -- Custom notification
				end
				
				client:setNetVar("tyingU", nil)
				entity:setNetVar("tyingU", nil)
				entity.nutBeingUnTied = nil
			end)
		end
		--]]
	end
else
	local COLOR_TIED = Color(245, 215, 110)

	function PLUGIN:DrawCharInfo(client, character, info)
		if (client:getNetVar("restricted")) then
			info[#info + 1] = {"Restrained", COLOR_TIED}
		end
	end
	
	function PLUGIN:PostDrawHUD()
		local client = LocalPlayer()
		
		local tying = client:getNetVar("tying")
		local tyingT = client:getNetVar("tyingT")
		local tyingU = client:getNetVar("tyingU")
		
		if(tying) then
			local progress = (CurTime() - tying) * 0.2
			jlib.DrawProgressBar(ScrW() * 0.3, ScrH() * 0.6, ScrW() * 0.4, 40, progress, "Tying", true, Color(50,200,50,100))
		end	
		
		if(tyingT) then
			local progress = (CurTime() - tyingT) * 0.2
			jlib.DrawProgressBar(ScrW() * 0.3, ScrH() * 0.6, ScrW() * 0.4, 40, progress, "You are being tied", true, Color(200,50,50,100))
		end
		
		if(tyingU) then
			local progress = (CurTime() - tyingU) * 0.2
			jlib.DrawProgressBar(ScrW() * 0.3, ScrH() * 0.6, ScrW() * 0.4, 40, progress, "Untying", true, Color(50,200,50,100))
		end
	end
end
