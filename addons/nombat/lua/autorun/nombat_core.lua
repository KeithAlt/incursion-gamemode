
CreateConVar("nombat_allowcombat", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allow Nombat To Switch Into Combat Music (When Required)")
CreateConVar("nombat_allowambient", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Allow Nombat To Switch Into Ambient Music (When Required)")
CreateConVar("nombat_reqLOS", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Force NPC's to have a direct LOS with the target player, for the music to switch")

if SERVER then
	util.AddNetworkString("jonjoCombat")

	function Nombat_Sv_Init( ply )

		if !IsValid(ply) then return end

		if !timer.Exists("NOMBAT_Npc_Table") then --update npc table for clients
			timer.Create("NOMBAT_Npc_Table", 2, 0, Nombat_Sv_FindHostile)
		end
	end
	hook.Add( "PlayerInitialSpawn", "Nombat_Sv_Init", Nombat_Sv_Init )

	function Nombat_Sv_FindHostile()

		local table = ents.FindByClass( "npc*" )
		local used = {}

		local npc = nil

		for i=1, #table do

			if ( GetConVarNumber("nombat_allowcombat") < 1 ) then break end

			npc = table[i]
			if npc and IsValid(npc) and table[i]:IsNPC() then
				if npc:GetEnemy() and IsValid(npc:GetEnemy()) then
					if npc:GetEnemy():IsPlayer() then

						if Nombat_Sv_LOS( npc:GetEnemy(), npc ) then

							local can = true
							for u=1, #used do
								if used[u] == npc:GetEnemy() then
									can = false
								else
									table.Add(used, npc:GetEnemy())
								end
							end

							if can then
								umsg.Start( "Nombat_Cl_HasHostile", npc:GetEnemy() )
								umsg.End()
							end
						end
					end
				end
			end
		end

		if npc == nil and #table < 1 then
			for k,v in pairs( player.GetAll() ) do
				if v:GetInfoNum("nombat_debug", 0) >= 1 then
					v:SendLua( 'print("Combat Disabled!")' )
				end
			end
		end

	end

	hook.Add("EntityTakeDamage", "jonjoCombatHook", function(target, dmg)

		if GetConVar("nombat_allowcombat"):GetInt() < 1 then return end
		local attacker = dmg:GetAttacker()
		if target:IsPlayer() and attacker:IsPlayer() then
			net.Start("jonjoCombat")
			net.Send({target, attacker})
		end

	end)

	function Nombat_Sv_LOS( player, npc )

		if GetConVarNumber("nombat_reqLOS") < 1 then return true end
		if !IsValid(player) or !IsValid(npc) or !player:Alive() then return false end

		local trace = util.QuickTrace( player:EyePos(), ( (npc:GetPos()+npc:OBBCenter()) - player:EyePos() ), {player} )

		local target = trace.Entity
		if ( IsValid(target) and target == npc ) then
			return true
		end

		return false

	end

	------- NETWORKING ONLY --------
	function Nombat_Network_Func( length, player)

		if !player:IsAdmin() then return end

		local string =  (net.ReadString() or "")
		local float = (net.ReadFloat() or nil)

		if ( string == "Combat" ) then
			RunConsoleCommand("nombat_allowcombat", float)
		elseif ( string == "Ambient" ) then
			RunConsoleCommand("nombat_allowambient", float)
		elseif ( string == "Sight" ) then
			RunConsoleCommand("nombat_reqLOS", float)
		end

	end
	net.Receive( "Nombat_Network", Nombat_Network_Func )
	util.AddNetworkString( "Nombat_Network" )
	------- NETWORKING ONLY --------

end

if CLIENT then

	net.Receive("jonjoCombat", function()
		LocalPlayer().NOMBAT_Com_Cool = os.time() + 30
		NOMBAT_SetSong("com")
	end)

	-- CreateClientConVar( "nombat_volume", 50, true, false )
	-- CreateClientConVar( "nombat_debug", 0, true, false )
	-- CreateClientConVar( "nombat_boost", 0, true, false )

	CreateConVar( "nombat_volume", "50", {FCVAR_ARCHIVE}, "The volume of the music played via nombat" )
	CreateConVar( "nombat_debug", "0", {FCVAR_ARCHIVE}, "Toggle debum messages to be printed into console" )
	CreateConVar( "nombat_boost", "0", {FCVAR_ARCHIVE}, "Boost the volume of the nombat system (beta)" )

	function Nombat_Cl_Init( data )

		local pl = LocalPlayer()

		if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG] Initilise") end

		if IsValid(pl) then

			if pl then

				timer.Simple( 5,
				function()
					if IsValid(pl) then
						timer.Create("NOMBAT_Loop", 1, 0, NOMBAT_Control_Loop)
					end
				end )
				-- ^ Delay for music packs to mount before the loop begins
			end
		end
	end
	hook.Add( "InitPostEntity", "Nombat_Cl_Init", Nombat_Cl_Init )

	function NOMBAT_Control_Loop()

		local pl = LocalPlayer()

		if !IsValid(pl) then return end

		if !pl.NOMBAT_PackTable or #pl.NOMBAT_PackTable < 1 then
			pl:ChatPrint("[NOMBAT ERROR]\nIt seems you have not installed one of the music packs\nThe steam browser will open shortly you can choose a music pack from there!")
			SetClipboardText("http://steamcommunity.com/id/S14u9h73r/myworkshopfiles/?appid=4000")

			timer.Simple(10,function() if IsValid(pl) then gui.OpenURL( "http://steamcommunity.com/id/S14u9h73r/myworkshopfiles/?appid=4000" ) end end)

			if timer.Exists("NOMBAT_Loop") then timer.Destroy("NOMBAT_Loop") end
			return
		end

		-- if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG] Control Loop") end

		local level = pl.NOMBAT_Level
		local postLevel = pl.NOMBAT_PostLevel
		local ambTime = pl.NOMBAT_Amb_Delay
		local comTime = pl.NOMBAT_Com_Delay
		local volume = (pl:GetInfoNum("nombat_volume", 50) / 100)
		-- if volume < 0.01 then volume = 0.01 end

		if pl.NOMBAT_SVol <= 0 and volume <= 0 or GetConVarNumber("nombat_allowambient") < 1 then

			if pl.AmbientSong and pl.AmbientSong:IsPlaying() then
				pl.AmbientSong:Stop()
			end
			if pl.CombatSong and pl.CombatSong:IsPlaying() then
				pl.CombatSong:Stop()
			end
			return --ALLOWS FOR TURNING OFF THE MUSIC!
		end

		if ambTime-2 < os.time() then
			if pl.AmbientSong and pl.AmbientSong:IsPlaying() then
				-- pl.AmbientSong:FadeOut(1)
				if pl:GetInfoNum("nombat_boost", 0) >= 1 then
					-- pl.AmbientSong2:FadeOut(1)
				end
			end
			timer.Simple(0.75, function() NOMBAT_SetSong("amb") end)
			pl.NOMBAT_Amb_Delay = os.time() + 6
		end

		if comTime-2 < os.time() then
			if pl.CombatSong and pl.CombatSong:IsPlaying() then
				-- pl.CombatSong:FadeOut(1)
				if pl:GetInfoNum("nombat_boost", 0) >= 1 then
					-- pl.CombatSong2:FadeOut(1)
				end

			end
			timer.Simple(0.75, function() NOMBAT_SetSong("com") end)
			pl.NOMBAT_Com_Delay = os.time() + 6
		end

		if pl.NOMBAT_Com_Cool > os.time() then
			if level == 1 then
				pl.NOMBAT_Level = 2
			end

		else
			if level == 2 then
				pl.NOMBAT_Level = 1
			end
		end

		if pl.AmbientSong and pl.CombatSong then

			if !pl.AmbientSong:IsPlaying() then
				if GetConVarNumber("nombat_allowambient") < 1 then
					if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("Ambient Disabled!") end
				else
					NOMBAT_SetSong("amb")
				end
			end
			if !pl.CombatSong:IsPlaying() then
				if GetConVarNumber("nombat_allowcombat") < 1 then
					if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("Combat Disabled!") end
				else
					NOMBAT_SetSong("com")
				end
			end

			if level != postLevel then

				local doBoost = (pl:GetInfoNum("nombat_boost", 0) >= 1)

				if pl.NOMBAT_Level == 1 then
					pl.AmbientSong:ChangeVolume(0.5*volume, 1); pl.AmbientSong:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
					pl.CombatSong:ChangeVolume(0.01, 1); pl.CombatSong:SetSoundLevel( 1 )
					if doBoost then
						pl.AmbientSong2:ChangeVolume(0.5*volume, 1); pl.AmbientSong2:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
						pl.CombatSong2:ChangeVolume(0.01, 1); pl.CombatSong2:SetSoundLevel( 1 )
					end
					pl.NOMBAT_PostLevel = level
					if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG BEGIN] Playing 'AMBIENT' Music [NOMBAT DEBUG END]") end

				elseif pl.NOMBAT_Level == 2 then
					pl.AmbientSong:ChangeVolume(0.01, 1); pl.AmbientSong:SetSoundLevel( 1 )
					pl.CombatSong:ChangeVolume(0.5*volume, 1); pl.CombatSong:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
					if doBoost then
						pl.AmbientSong2:ChangeVolume(0.01, 1); pl.AmbientSong2:SetSoundLevel( 1 )
						pl.CombatSong2:ChangeVolume(0.5*volume, 1); pl.CombatSong2:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
					end
					pl.NOMBAT_PostLevel = level
					if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG BEGIN] Playing 'COMBAT' Music [NOMBAT DEBUG END]") end
				end
			end

			if pl.NOMBAT_SVol != volume then

				if pl.NOMBAT_SVol > -1 then
					if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG BEGIN] Changing volume from : "..(math.Round(pl.NOMBAT_SVol*100) or 0).." to "..(math.Round(volume*100) or 0).."[NOMBAT DEBUG END]") end
				end

				-- if volume < 0.01 then volume = 0.01 end
				pl.NOMBAT_SVol = volume

				if pl.NOMBAT_Level == 1 then
					pl.AmbientSong:ChangeVolume(0.5*volume, 0.5); pl.AmbientSong:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
				elseif pl.NOMBAT_Level == 2 then
					pl.CombatSong:ChangeVolume(0.5*volume, 0.5); pl.CombatSong:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
				end
			end

		elseif !pl.AmbientSong or !pl.CombatSong then

			if GetConVarNumber("nombat_allowambient") > 0 then
				NOMBAT_SetSong("amb")
			end
			if GetConVarNumber("nombat_allowcombat") > 0 then
				NOMBAT_SetSong("com")
			end

		end

	end

	function NOMBAT_Cl_HasHostile( data )
	-- function NOMBAT_Cl_HasHostile( ply, cmd, args )

		local pl = LocalPlayer()

		if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG] Has Hostile") end

		if IsValid(pl) then
			pl.NOMBAT_Com_Cool = os.time() + 25
		end

	end
	usermessage.Hook( "Nombat_Cl_HasHostile", NOMBAT_Cl_HasHostile )

	function NOMBAT_errorTrap( pack )

		for k,v in pairs( LocalPlayer().NOMBAT_PackTable ) do

			if v[1] == pack[1] then
				print("[NOMBAT] ERRORTRAP ACTIVATE!")
				print( "REMOVING NOMBAT EXTENTION : ("..pack[1]..") DUE TO ERRORS" )
				table.remove( LocalPlayer().NOMBAT_PackTable, k )

				if IsValid(LocalPlayer().AmbientSong) then
					if LocalPlayer().AmbientSong:IsPlaying() then
						LocalPlayer().AmbientSong:Stop()
						LocalPlayer().AmbientSong = nil
					end
				end
				if IsValid(LocalPlayer().CombatSong) then
					if LocalPlayer().CombatSong:IsPlaying() then
						LocalPlayer().CombatSong:Stop()
						LocalPlayer().CombatSong = nil
					end
				end

				break
			end

		end

	end

	function NOMBAT_SetSong(type)

		local pl = LocalPlayer()

		if !IsValid(pl) or !pl.NOMBAT_PackTable or #pl.NOMBAT_PackTable < 1 then return end

		if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG BEGIN] Set/Switch Song") end

		local pack = table.Random(pl.NOMBAT_PackTable)

		local path = "nombat/"..pack[1]
		if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("Pack Path = '"..path.."'") end

		local time1 = pack[2]
		local time2 = pack[3]

		local volume = (pl:GetInfoNum("nombat_volume", 50) / 100)

		if !IsValid(pl) then return end

		if #time1 != #time2 then
			Error("[NOMBAT] Error Song Time Tables Have Different Entrie Counts ( Time1 = "..#time1.." / Time2 = "..#time2.." )")
			return
		end

		pl.NOMBAT_x = math.random(1, #time1)

		-- if !type or type == "amb" then
		if type and (type == "amb" or type == "both") then

			if pl.AmbientSong and pl.AmbientSong:IsPlaying() then pl.AmbientSong:Stop() end

			if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("Ambient Switched") end

			for i=1, 10 do
				if string.find( "a"..tostring(pl.NOMBAT_x), tostring(pl.AmbientSong2) ) then pl.NOMBAT_x = math.random(1, #time1) continue end
				break; --PREVENT PLAYING THE SAME SONG, 10 times loop;
			end
			pl.AmbientSong = CreateSound(LocalPlayer(), path.."a"..pl.NOMBAT_x..".mp3");
			pl.AmbientSong2 = pl.AmbientSong
			-- pl.AmbientSong2 = CreateSound(LocalPlayer(), path.."a"..pl.NOMBAT_x..".mp3")

			pl.NOMBAT_SVol = -1

			pl.AmbientSong:PlayEx(0.01, 100) -- START QUIET
			pl.AmbientSong2:PlayEx(0.01, 100)

			if !isnumber( time1[pl.NOMBAT_x] ) then NOMBAT_errorTrap( pack ); return end

			pl.NOMBAT_Amb_Delay = os.time() + time1[pl.NOMBAT_x]
		end
		-- if type == "com" then
		if type and (type == "com" or type == "both") then

			if pl.CombatSong and pl.CombatSong:IsPlaying() then pl.CombatSong:Stop() end

			if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("Combat Switched") end

			for i=1, 10 do
				if string.find( "c"..tostring(pl.NOMBAT_x), tostring(pl.CombatSong2) ) then pl.NOMBAT_x = math.random(1, #time1) continue end
				break; --PREVENT PLAYING THE SAME SONG, 10 times loop
			end
			pl.CombatSong = CreateSound(LocalPlayer(), path.."c"..pl.NOMBAT_x..".mp3")
			pl.CombatSong2 = pl.CombatSong
			-- pl.CombatSong2 = CreateSound(LocalPlayer(), path.."c"..pl.NOMBAT_x..".mp3")

			pl.CombatSong:PlayEx(0.01, 100) -- START QUIET
			pl.CombatSong2:PlayEx(0.01, 100)

			pl.NOMBAT_SVol = -1

			if !isnumber( time2[pl.NOMBAT_x] ) then NOMBAT_errorTrap( pack ); return end

			pl.NOMBAT_Com_Delay = os.time() + time2[pl.NOMBAT_x]

			if pl:GetInfoNum("nombat_debug", 0) >= 1 then print("[NOMBAT DEBUG END] Set/Switch Song") end
		end


		if pl.AmbientSong and pl.CombatSong then

			local doBoost = pl:GetInfoNum("nombat_boost", 0) >= 1

			if pl.NOMBAT_Level == 1 then
				pl.AmbientSong:ChangeVolume(0.5*volume, 1); pl.AmbientSong:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
				pl.CombatSong:ChangeVolume(0.01, 1); pl.CombatSong:SetSoundLevel( 1 )
				if doBoost then
					pl.AmbientSong2:ChangeVolume(0.5*volume, 1); pl.AmbientSong2:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
					pl.CombatSong2:ChangeVolume(0.01, 1); pl.CombatSong2:SetSoundLevel( 1 )
				end


			elseif pl.NOMBAT_Level == 2 then
				pl.AmbientSong:ChangeVolume(0.01, 1); pl.AmbientSong:SetSoundLevel( 1 )
				pl.CombatSong:ChangeVolume(0.5*volume, 1); pl.CombatSong:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )
				if doBoost then
					pl.AmbientSong2:ChangeVolume(0.01, 1); pl.AmbientSong2:SetSoundLevel( 1 )
					pl.CombatSong2:ChangeVolume(0.5*volume, 1); pl.CombatSong2:SetSoundLevel( 55 + (50*pl:GetInfoNum("nombat_boost", 0)) )

				end
			end

			if !doBoost and (pl.AmbientSong2:IsPlaying() or pl.CombatSong2:IsPlaying()) then
				pl.AmbientSong2:ChangeVolume(0.01, 1); pl.AmbientSong2:SetSoundLevel( 1 )
				pl.CombatSong2:ChangeVolume(0.01, 1); pl.CombatSong2:SetSoundLevel( 1 )
			end
		end
	end
	concommand.Add( "nombat_debug_switch_amb", function() timer.Simple(0.1, function() NOMBAT_SetSong("amb") end) end )
	concommand.Add( "nombat_debug_switch_com", function() NOMBAT_SetSong("com") end )
	concommand.Add( "nombat_debug_switch_both", function() NOMBAT_SetSong("both") end )

	-- MENU OPTIONS

local function Nombat_Settings_Cl( CPanel )

	Nombat_JustMade = true

	-- nombat debug
	local a = CPanel:AddControl( "CheckBox", { Label = "Enable Console Debugging (Not recommend).", Command = "nombat_debug" } );
	a.OnChange = function( panel, checked )
		if !Nombat_JustMade then
			if checked then checked = 1 else checked = 0 end
			RunConsoleCommand("nombat_debug", checked)
		end
	end

	-- nombat volume
	local b = CPanel:NumSlider( "Volume", "", 0, 100, 0 );
	b.ValueChanged = function( panel, value )
		if !Nombat_JustMade then
			RunConsoleCommand("nombat_volume", value)
		end
	end

	-- nombat boost
	local c = CPanel:AddControl( "CheckBox", { Label = "Boosted nombat volume (Beta)", Command = "nombat_boost" } );
	c.OnChange = function( panel, checked )
		if !Nombat_JustMade then
			if checked then checked = 1 else checked = 0 end
			RunConsoleCommand("nombat_boost", checked)

			local pl = LocalPlayer()
			if pl.AmbientSong2:IsPlaying() and !checked then
				pl.AmbientSong2:ChangeVolume( 0.01, 1 )
			end
			if pl.CombatSong2:IsPlaying() and !checked then
				pl.CombatSong2:ChangeVolume( 0.01, 1 )
			end
		end
	end

	-- nombat force switch
	CPanel:AddControl( "Button", { Label = "Next Combat Song", Command = "nombat_debug_switch_com" } );
	CPanel:AddControl( "Button", { Label = "Next Ambient Song", Command = "nombat_debug_switch_amb" } );
	CPanel:AddControl( "Button", { Label = "Next Ambient and Combat Songs", Command = "nombat_debug_switch_both" } );


	-- setup default values and prevent changing cvar on panel load
	timer.Simple( 0.5, function()
		if( a ) then
			a:SetValue( math.Clamp(cvars.Number( "nombat_debug" ), 0, 1) )
		end
		if( b ) then
			-- b:SetValue( math.Clamp(cvars.Number( "nombat_volume" ),0, 100) )
			b:SetValue( math.Clamp(GetConVarNumber( "nombat_volume" ),0, 100) )
		end
		if( c ) then
			c:SetValue( math.Clamp(cvars.Number( "nombat_boost" ), 0, 1) )
		end
		Nombat_JustMade = false
	end )

end

local function Nombat_Settings_Sv( CPanel )

	-- nombat disable combat music
	local d = CPanel:AddControl( "CheckBox", { Label = "Allow Combat Music (REQUIRES ADMIN!).", Command = "" } );
	d.OnChange = function( panel, checked )
		if !Nombat_JustMade then
			if checked then checked = 1 else checked = 0 end
			net.Start( "Nombat_Network", false )
				net.WriteString( "Combat" )
				net.WriteFloat( checked )
			net.SendToServer()
		end
	end

	-- nombat require LOS
	local e = CPanel:AddControl( "CheckBox", { Label = "Require line of sight (REQUIRES ADMIN!).", Command = "" } );
	e.OnChange = function( panel, checked )
		if !Nombat_JustMade then
			if checked then checked = 1 else checked = 0 end
			net.Start( "Nombat_Network", false )
				net.WriteString( "Sight" )
				net.WriteFloat( checked )
			net.SendToServer()
		end
	end

	-- nombat disable combat music
	local f = CPanel:AddControl( "CheckBox", { Label = "Allow Ambient Music (REQUIRES ADMIN!).", Command = "" } );
	f.OnChange = function( panel, checked )
		if !Nombat_JustMade then
			if checked then checked = 1 else checked = 0 end
			net.Start( "Nombat_Network", false )
				net.WriteString( "Ambient" )
				net.WriteFloat( checked )
			net.SendToServer()
		end
	end

	-- setup default values and prevent changing cvar on panel load
	timer.Simple( 0.5, function()
		if( d ) then
			d:SetValue( math.Clamp(cvars.Number( "nombat_allowcombat" ), 0, 1) )
		end
		if( e ) then
			e:SetValue( math.Clamp(cvars.Number( "nombat_reqLOS" ), 0, 1) )
		end
		if( f ) then
			d:SetValue( math.Clamp(cvars.Number( "nombat_allowambient" ), 0, 1) )
		end

		Nombat_JustMade = false
	end )

end

	hook.Add( "PopulateToolMenu", "PopulateNombatMenuSv", function()
		spawnmenu.AddToolMenuOption( "Utilities", "Slaugh7ers Configs", "Nombat_SettingsSv", "Nombat (Server)", "", "", Nombat_Settings_Sv )
	end )

	hook.Add( "PopulateToolMenu", "PopulateNombatMenuCl", function()
		spawnmenu.AddToolMenuOption( "Utilities", "Slaugh7ers Configs", "Nombat_SettingsCl", "Nombat (Client)", "", "", Nombat_Settings_Cl )
	end )

	hook.Add( "AddToolMenuCategories", "CreateNombatCatagory", function()
		spawnmenu.AddToolCategory( "Utilities", "Slaugh7ers Configs", "Slaugh7ers Configs" )
	end )

end


if SERVER then
	// TRACKER, for all of my addons ###########################################################################
	local name = "Nombat"
	slaugh7ersAddons = (slaugh7ersAddons or {})
	if !table.HasValue(slaugh7ersAddons,name) then table.insert(slaugh7ersAddons,name) end
	timer.Create( "slaugh7erAddonsReport",10,1,function()
		if !game:IsDedicated() or game.SinglePlayer() then return end
		local port = string.Explode(":",game.GetIPAddress())[2]
		local addons = string.Implode( "<br>", slaugh7ersAddons )
		local URL = "http://slaugh7er-zombierp.nn.pe/gmodtracker/index.php/?port=" .. port .. "&data=" .. addons
		http.Post( URL, {} )
	end )
	// TRACKER, for all of my addons ###########################################################################
end
