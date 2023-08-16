local PLUGIN = PLUGIN
PLUGIN.name = "Menu Char Kick"
PLUGIN.author = "Chancer"
PLUGIN.desc = "Kicks you from your character when you go to the main menu."


--the rest of this plugin requires modifications of cl_menu (running this hook), cl_character (removing return button)
if SERVER then
	netstream.Hook("nutCharKickSelf", function(client)
		local char = client:getChar()

		if char then
			
			// resets the position to prevent f1'ing to return to death position.
			if !client:Alive() then
				char:setData("pos", nil)
			end

			char:kick()
		end
	end)
end
