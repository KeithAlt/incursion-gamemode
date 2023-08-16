AddCSLuaFile()



function gbversion( player, command, arguments )
    player:ChatPrint( "Garry's Bombs: 4" )
end
concommand.Add( "gb_version", gbversion )

if (CLIENT) then
     function gbhelp( ply, text, public)
         if (string.find(text, "!gb") != nil) then
			 chat.AddText("Console commands:")
             chat.AddText("gb_easyuse [0/1] - Should fireworks interact on use?")
	         chat.AddText("gb_fragility [0/1] - Should fireworks arm, launch on damage?")
	         chat.AddText("gb_unfreeze [0/1] - Should fireworks unfreeze stuff?")
			 chat.AddText("gb_deleteconstraints [0/1] - Should fireworks delete constraints?")
			 chat.AddText("gb_explosion_damage  [0/1] - Should fireworks do damage upon explosion?")
		 end
		 if (string.find(text, "!gbe")) then
			 chat.AddText("Current version is 4")

         end
     end
end
hook.Add( "OnPlayerChat", "gbhelp", gbhelp )