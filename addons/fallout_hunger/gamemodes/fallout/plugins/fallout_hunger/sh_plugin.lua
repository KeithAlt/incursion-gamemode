PLUGIN.name = "Hunger & Thirst"
PLUGIN.author = "jonjo"
PLUGIN.desc = "Hunger and thirst"


jonjo_items = {}
nut.util.include("sh_foodanddrink.lua")

foodandrinkConfig = {}
nut.util.include("sh_config.lua")

resource.AddSingleFile("materials/hunger.png")
resource.AddSingleFile("materials/thirst.png")

function PLUGIN:PluginLoaded() --Initialize all the food/drink items
	for k,v in pairs(jonjo_items.food) do
		local ITEM = nut.item.register(string.Replace("food_"..k:lower(), " ", "_"), "base_jonjo_food", false, nil, true)
		ITEM.name  = k
		ITEM.model = v.model
		ITEM.desc  = v.desc
		ITEM.amt   = v.amt
		ITEM.extra = v.extra
		ITEM.rads  = v.rads
	end

	for k,v in pairs(jonjo_items.drink) do
		local ITEM = nut.item.register(string.Replace("drink_"..k:lower(), " ", "_"), "base_jonjo_drink", false, nil, true)
		ITEM.name  = k
		ITEM.model = v.model
		ITEM.desc  = v.desc
		ITEM.amt   = v.amt
		ITEM.extra = v.extra
		ITEM.rads  = v.rads
	end
end

//function PLUGIN:PlayerInitialSpawn(ply) --Initialize their thirst and hunger values
//    ply:SetNWFloat("thirst", 100)
//    ply:SetNWFloat("hunger", 100)
//end

local function HungerImmune(ply) -- Checks the player class for 'noHunger' config var
	local char = ply:getChar()
	local class = char and char:getClass() or nil
	if char and class and nut.class.list[class].noHunger then
	 	return true
	else
		return false
	end
end

function PLUGIN:PlayerSpawn(ply) --Reset any buffs/debuffs they may have incurred if they are now immune
	if HungerImmune(ply) then
		ply.thirstbuff = 0
		ply.hungerbuff = 0
		ply:SprintEnable() -- prevents swap char bug
		ply:SetNWBool("noHunger", true)
	else
		ply:SetNWBool("noHunger", false)
	end
end

if SERVER then
	util.AddNetworkString("StartAlcoholEffect")

	local function HungerAndThirstTick()
		for k,v in pairs(player.GetAll()) do
			if v:GetNWBool("noHunger") then continue end --They're immune to hunger/thirst

			local char = v:getChar()
			if !char then continue end

			local thirst = math.Clamp(char:getData("thirst", 100) - 0.02, 0, 100)
			local hunger = math.Clamp(char:getData("hunger", 100) - 0.015, 0, 100)
			char:setData("thirst", thirst)
			char:setData("hunger", hunger)

			v.justNeutralThirst = v.justNeutralThirst or false
			v.justHydrated = v.justHydrated or false
			v.justThirsty = v.justThirsty or false
			v.justCritialThirst = v.justCritialThirst or false

			if thirst < 80 and thirst > 25 then --Neutral
				if !v.justNeutralThirst then
					v:falloutNotify("✚ Your thirst is satisfied", "ui/notify.mp3")
					v.justNeutralThirst = true
				end

				local rs = v:GetRunSpeed()
				local ws = v:GetWalkSpeed()
				v.thirstbuff = 0
				v:SetRunSpeed(rs)
				v:SetWalkSpeed(ws)
			else
				v.justNeutralThirst = false
			end

			if thirst > 80 then --Buff
				if !v.justHydrated then
					v:falloutNotify("✚ You are hydrated [+1 AGIL]", "ui/notify.mp3")
					v.justHydrated = true
				end

				local rs = v:GetRunSpeed()
				local ws = v:GetWalkSpeed()
				v.thirstbuff = 1
				v:SetRunSpeed(rs)
				v:SetWalkSpeed(ws)
			else
				v.justHydrated = false
			end

			if thirst < 25 then --Debuff
				if !v.justThirsty then
					v:falloutNotify("✚ You are dehydrated [-1 AGIL]", "ui/notify.mp3")
					v.justThirsty = true
				end

				local thirstbuff = (100 - thirst)/10
				local rs = v:GetRunSpeed()
				local ws = v:GetWalkSpeed()
				v.thirstbuff = -thirstbuff
				v:SetRunSpeed(rs)
				v:SetWalkSpeed(ws)
			else
				v.justThirsty = false
			end

			if thirst <= 10 then
				v.ThirstWasSprintEnabled = v.ThirstWasSprintEnabled == nil and v:IsSprintEnabled() or v.ThirstWasSprintEnabled
				v:SprintDisable()
				// if !v.speedNeedsChange then
				// 	v.speedNeedsChange = true
				// end

				if !v.justCritialThirst then
					v:falloutNotify("✚ You are in dire need of a drink! [+ SLOWNESS]", "ui/addicteds.wav")
					v.justCritialThirst = true
				end
			else
				if v.ThirstWasSprintEnabled != nil then
					v:SetSprintEnabled(v.ThirstWasSprintEnabled)
					v.ThirstWasSprintEnabled = nil
				end
				v.justCritialThirst = false

				// if v.speedNeedsChange then --set their walk/runspeed back to what it should have been considering their class and armor speed buffs/penalties
				// 	local items = char:getInv():getItems()
				// 	local armor

				// 	local ws, defaultWalk = nut.config.get("walkSpeed"), nut.config.get("walkSpeed")
				// 	local rs, defaultRun  = nut.config.get("runSpeed"), nut.config.get("runSpeed")

				// 	local class = nut.class.list[char:getClass()]

				// 	if class then
				// 		if isnumber(class.runSpeed) then
				// 			rs = defaultRun * class.runSpeed
				// 		end

				// 		if isnumber(class.walkSpeed) then
				// 			ws = defaultWalk * class.walkSpeed
				// 		end
				// 	end

				// 	for _,item in pairs(items) do
				// 		if !item.uniqueID:StartWith("armor_") then continue end

				// 		if item:getData("equipped", false) then
				// 			armor = item.type
				// 			break
				// 		end
				// 	end

				// 	if armor then
				// 		ws = defaultWalk + (defaultWalk * (nut.armor.armors[armor].speedBoost / 100))
				// 		rs = defaultRun + (defaultRun * (nut.armor.armors[armor].speedBoost / 100))
				// 	end

				// 	v:SetWalkSpeed(ws)
				// 	v:SetRunSpeed(rs)

				// 	v.speedNeedsChange = nil
				// end
			end

			v.justNeutralHunger = v.justNeutralHunger or false
			v.justFed = v.justFed or false
			v.justHungry = v.justHungry or false

			if hunger < 80 and hunger > 25 then --Neutral
				if !v.justNeutralHunger then
					v:falloutNotify("✚ Your hunger is satisfied", "ui/notfy.mp3")
					v.justNeutralHunger = true
				end

				v.hungerbuff = 0
			else
				v.justNeutralHunger = false
			end

			if hunger > 80 then --Buff
				if !v.justFed then
					v:falloutNotify("✚ Your hunger is very satiated [+1 END]", "ui/notfy.mp3")
					v.justFed = true
				end

				v.hungerbuff = 1
			else
				v.justFed = false
			end

			if hunger < 25 then --Debuff
				if !v.justHungry then
					v:falloutNotify("✚ You are starving! [-1 END]", "ui/addicteds.wav")
					v.justHungry = true
				end

				local hungerbuff = (100 - hunger)/10
				v.hungerbuff = -hungerbuff
			else
				v.justHungry = false
			end
		end
	end
	timer.Create("HungerAndThirstTick", 1, 0, HungerAndThirstTick)


	local PLAYER = FindMetaTable("Player")

	function PLAYER:AddHunger(amt)
		local char = self:getChar()
		if !char then return end

		char:setData("hunger", math.min(char:getData("hunger", 100) + amt, 100))
	end

	function PLAYER:AddThirst(amt)
		local char = self:getChar()
		if !char then return end

		char:setData("thirst", math.min(char:getData("thirst", 100) + amt, 100))
	end
end

local function drawOutline(x, y, w, h)
	if !CLIENT then return end
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x, y, w + 6, h)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawOutlinedRect(x, y, w + 6, h)
end

if CLIENT then
	net.Receive("StartAlcoholEffect", function()
		hook.Add("RenderScreenspaceEffects", "AlcoholEffects", function()
			DrawMotionBlur(0.4, 0.8, 0.01)
			DrawSharpen(1.2, 1.2)
			DrawToyTown(2, ScrH()/2)
		end)

		timer.Simple(90, function()
			hook.Remove("RenderScreenspaceEffects", "AlcoholEffects")
		end)
	end)
end

local hungerIcon = Material("hunger.png")
local thirstIcon = Material("thirst.png")
function PLUGIN:HUDPaint() --Draw hunger/thirst bars and icons
	if LocalPlayer():GetNWBool("noHunger") then return end --They're immune to hunger/thirst

	if hook.Run("ShouldDrawHungerHUD") == false then return end

	local ply = LocalPlayer()
	local char = ply:getChar()

	if !char then return end

	local thirst = char:getData("thirst", 100)
	local hunger = char:getData("hunger", 100)

	local col = nut.gui.palette.color_primary

	--Hunger bar
	local x = ScrW() - 358
	local y = ScrH() - 105
	local w = 105
	local h = 12

	drawOutline(x, y, w, h)
	surface.SetDrawColor(col.r, col.g, col.b, col.a)
	surface.DrawRect(x + 3, y + 3, w * (hunger / 100), h - 6)

	--Hunger Icon
	surface.SetMaterial(hungerIcon)
	surface.DrawTexturedRect(x + w + 10, y - 32 + h, 20, 32)

	--Thirst bar
	x = x + w + 46

	drawOutline(x, y, w, h)
	surface.SetDrawColor(col.r, col.g, col.b, col.a)
	surface.DrawRect(x + 3, y + 3, w * (thirst / 100), h - 6)

	--Thirst Icon
	surface.SetMaterial(thirstIcon)
	surface.DrawTexturedRect(x + w + 10, y - 30 + h, 22, 30)
end
