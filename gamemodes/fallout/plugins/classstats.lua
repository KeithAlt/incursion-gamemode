PLUGIN.name = "Class Stats"
PLUGIN.author = "Stan"
PLUGIN.desc = "Allows class stats to be set and applied"

function doLoadout(client)
	local char = client:getChar()
	if (char) then
		local charClass = char:getClass()
		local class = nut.class.list[charClass]
		if !class then return end
		if (class.None) then return end

		if (class.armor) then
			client:SetArmor( class.armor )
		else
			client:SetArmor( 0 )
		end

		-- Set the players model scale on spawn
		if (class.scale) then
			local scaleViewFix = class.scale
			local scaleViewFixOffset = Vector(0, 0, 64)
			local scaleViewFixOffsetDuck = Vector(0, 0, 28)

			client:SetViewOffset(scaleViewFixOffset * class.scale)
			client:SetViewOffsetDucked(scaleViewFixOffsetDuck * class.scale)

			client:SetModelScale( scaleViewFix )
		else
			client:SetViewOffset(Vector(0, 0, 64))
			client:SetViewOffsetDucked(Vector(0, 0, 28))
			client:SetModelScale ( 1 )
		end

		-- Set the players run speed on spawn
		if (class.runSpeed) then
			if (class.runSpeedMultiplier) then
				client:SetRunSpeed( math.Round(nut.config.get("runSpeed") * class.runSpeed) )
			else
				client:SetRunSpeed( class.runSpeed )
			end
		end

		-- Set the players walk speed on spawn
		if (class.walkSpeed) then
			if (class.walkSpeedMultiplier) then
				client:SetWalkSpeed( math.Round(nut.config.get("walkSpeed") * class.walkSpeed) )
			else
				client:SetWalkSpeed( class.walkSpeed )
			end
		end

		-- Make sure players in this class are using this model on spawn
		if class.modelOverride && client:GetModel() != class.modelOverride then
			client:getChar():setModel(class.modelOverride)
			client:SetModel(class.modelOverride)
		end

		-- Set the players jump power on spawn
		if (class.jumpPower) then
			if (class.jumpPowerMultiplier) then
				client:SetJumpPower( math.Round(160 * class.jumpPower) )
			else
				client:SetJumpPower( class.jumpPower )
			end
		else
			client:SetJumpPower( 160 )
		end

		-- Set the players blood color on spawn (https://wiki.garrysmod.com/page/Enums/BLOOD_COLOR)
		if (class.bloodcolor) then
			client:SetBloodColor(class.bloodcolor)
		else
			client:SetBloodColor( BLOOD_COLOR_RED ) --This is the index for regular red blood
		end

		-- Set the player to this pill on spawn (FIXME: This can be rewritten/improved)
		if (class.pill and pk_pills) and !client.pillTransforming then -- Requires Parakeet's pills addon
			jlib.Announce(client, Color(255,0,0), "[NOTICE] ", Color(255,255,255), "You will fully spawn in your class in 9 seconds . . .")
			local pillChar = client:getChar()
			client.pillTransforming = true

			timer.Simple(9, function()
				if IsValid(client) and client:Alive() and client:getChar() == pillChar then
					client:SetPos(client:GetPos() + Vector(0,0,5)) -- Anti stuck for certain pills
	    			pk_pills.apply(client, class.pill, "lock-life")
					client.pillTransforming = false
				end
			end)
		end

		-- Set the player health on spawn
		if class.health then
			client:SetMaxHealth(class.health)
			client:SetHealth(class.health)
		end

		-- A hacky fix for cases where a faction is removed from the game
		if class.verify and SERVER and client:getChar():getFaction() != nut.faction.indices[class.faction].index then
			jlib.TransferFaction(client, class.faction) -- Transfer the player to the parent faction of class
		end

		-- Support for radiation system
		if class.radImmune then
			client.isImmune = true
		else
			client.isImmune = false
		end

		-- Support thirdparty fearRP system
		if class.fearResist then
			client.fearResist = class.fearResist
		end

		-- Support thirdparty fearRP system
		if class.fearPower then
			client.fearPower = class.fearPower
		end
	end
end

function PLUGIN:PlayerSpawn(client)
	--Run short timer to give var to read correctly when change character, probably unneeded now but I left it in just to be sure
	timer.Simple(0.1,function()
		if (IsValid(client) and client:Team()) and (client:Team() != 0) then
		local classLoaded = client:GetVar("playerClassPluginLoaded", false)
			if classLoaded == true then
				doLoadout(client)
			else
				timer.Simple(0.5, function() doLoadout(client) end)
			end
		end
	end)
end

if SERVER then
	function PLUGIN:PlayerInitialSpawn(ply)
		ply:SetVar("playerClassPluginLoaded", false)
	end
	function PLUGIN:PlayerLoadedChar(client)
		client:SetVar("playerClassPluginLoaded", false)
	end

	function PLUGIN:CharacterLoaded(id)
		local character = nut.char.loaded[id]
		if (character) then
			local client = character:getPlayer()
			if (IsValid(client)) then
				timer.Simple(1, function()client:SetVar("playerClassPluginLoaded", true) end)
			end
		end
	end
	--Respawn player when they change class, you may disable this by commenting it out
	function PLUGIN:OnPlayerJoinClass(client)
		client:KillSilent()
		timer.Simple(0.2, function() client:Spawn() end) --Timer done to avoid bugs with viewmodel camera
	end
end

--[[If you already don't know what this does,
basically it allows you to do things like:
CLASS.health = 200
CLASS.armor = 100
CLASS.scale = 1.2
CLASS.color = Vector(255 / 255, 255 / 255, 255 / 255)

With multiplier true, it will take the default speed set in the NutScipt config and multiply by the amount given.
If this value is false then it will set that value to the number given in "runSpeed"/"walkSpeed".
Leaving these inputs out of a class will simply set the run and walk speeds of the NutScript config.
CLASS.runSpeed = 1.2
CLASS.runSpeedMultiplier = true
CLASS.walkSpeed = 150
CLASS.walkSpeedMultiplier = false

CLASS.jumpPower is same as how run and walk speed work

The colour one works strange if you don't know how to use it, it uses vector colour and will only work on colourable playermodels
like on default models where you can change the t-shirt colour though the context menu and click on playermodel and then colours.
Basically if you want to force colours you must format it like this:

Vector(255 / 255, 255 / 255, 255 / 255)
Change the first 255 in each table part, do not change the second 255 after the slash, this works as the way this is done is 255 in rgb is 1 in vector colour,
this divides it down to shorter values.
Basically just replace the first 255's before the slash as your RGB number but do not change the second 255.
If you wish to outright disable players choosing their own colours, simply replace the:

local col = client:GetInfo( "cl_playercolor" )
client:SetPlayerColor( Vector( col ) )

with this but using the same rules as above:

Vector(255 / 255, 255 / 255, 255 / 255)

If you're still confused by the colour, perhaps the wiki page will help you more https://wiki.garrysmod.com/page/Player/SetPlayerColor

CLASS.bloodcolor
Use ENUMs found on wiki
--]]
