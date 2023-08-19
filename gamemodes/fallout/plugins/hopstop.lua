PLUGIN.name = "Hop Stop"
PLUGIN.author = "Vex"
PLUGIN.desc = "Put a stop to that B-Hop!"

if (SERVER) then
	function PLUGIN:KeyPress(player, key)
		if (key == IN_JUMP) && !player:InVehicle() && player:GetMoveType() != MOVETYPE_NOCLIP then
			local stamima = player:getLocalVar("stm", 0)

			if (stamima >= 25) then
				player:setLocalVar("stm", stamima - 25)
			end;
		end;
	end;
end;

function PLUGIN:StartCommand(ply, cmd)
	if ply:getLocalVar("stm", 0) < 25 and cmd:KeyDown(IN_JUMP) and ply:GetMoveType() == MOVETYPE_WALK and (!isfunction(ply.HasRocketBoots) or !ply:HasRocketBoots()) then
		cmd:RemoveKey(IN_JUMP)
	end
end
