util.AddNetworkString("BarberOpenMenu")
util.AddNetworkString("BarberCancel")
util.AddNetworkString("BarberFinalize")
util.AddNetworkString("BarberUpdatePreview")
util.AddNetworkString("BarberUpdatePreviewCol")
util.AddNetworkString("BarberSkillcheck")

local HAIR_GROUP = 2
local BEARD_GROUP = 3

function Barber.StartHaircut(barber, customer)
	customer:SetBarber(barber)
	barber:SetHaircutCustomer(customer)

	net.Start("BarberOpenMenu")
		net.WriteEntity(customer)
	net.Send({barber, customer})
end

function Barber.CancelHaircut(ply)
	local msg = "The haircut has been cancelled"

	for i, p in ipairs({ply, ply:GetHaircutCustomer(), ply:GetBarber()}) do
		if IsValid(p) then
			p:SetBarber(NULL)
			p:SetHaircutCustomer(NULL)

			p:falloutNotify(msg)

			if p != ply then
				net.Start("BarberCancel")
				net.Send(p)
			end
		end
	end
end

function Barber.StartSkillcheck(barber)
	local wep = barber:GetWeapon("barber_scissors")
	barber:SelectWeapon("barber_scissors")
	wep:SetSkillcheck(true)
end

function Barber.FinalizeHaircut(barber, customer, hairGroup, beardGroup, color, hairGroups, beardGroups)
	net.Start("BarberCancel")
	net.Send(customer)

	if !Barber.CanUseHair(HAIR_GROUP, hairGroup, customer) or !Barber.CanUseHair(BEARD_GROUP, beardGroup, customer) then
		barber:notify("Invalid hair/beard selected")
		Barber.CancelHaircut(barber)
		return
	end

	Barber.StartSkillcheck(barber)

	customer.DesiredHair = hairGroup
	customer.DesiredBeard = beardGroup
	customer.DesiredColor = color
	customer.HairGroups = hairGroups
	customer.BeardGroups = beardGroups
end

function Barber.ChangeHair(ply, hairGroup, beardGroup, color)
	local char = ply:getChar()

	local bodygroups = {0, hairGroup, beardGroup}

	ply:SetFacialCustomization(bodygroups, color)

	if char then
		char:setData("faceBodygroups", bodygroups)
		char:setData("hairColor", color)
	end
end

function Barber.FinishHaircut(barber, succ)
	local customer = barber:GetHaircutCustomer()

	local msg
	local hairGroup
	local beardGroup
	local color = Barber.CanColorHead(customer) and customer.DesiredColor or color_white

	if succ then
		msg = "Haircut complete"
		hairGroup = customer.DesiredHair
		beardGroup = customer.DesiredBeard
	else
		local allowedHairs, allowedBeards = Barber.GetAllowedCuts(customer, HAIR_GROUP, customer.HairGroups), Barber.GetAllowedCuts(customer, BEARD_GROUP, customer.BeardGroups)
		msg = "The haircut was botched..."
		hairGroup = allowedHairs[math.random(#allowedHairs)]
		beardGroup = allowedBeards[math.random(#allowedBeards)]
	end

	Barber.ChangeHair(customer, hairGroup, beardGroup, color)

	barber:falloutNotify(msg)
	customer:falloutNotify(msg)

	customer:SetBarber(NULL)
	barber:SetHaircutCustomer(NULL)
	customer.DesiredHair = nil
	customer.DesiredBeard = nil
	customer.DesiredColor = nil
	customer.HairGroups = nil
	customer.BeardGroups = nil

	-- Effect code --
	local effectData = EffectData()
	effectData:SetOrigin(customer:GetBonePosition(customer:LookupBone("ValveBiped.Bip01_Head1")))
	effectData:SetEntity(customer)
	util.Effect("darkenergyglow", effectData)

	customer:EmitSound("ui/paintjob.mp3", 75, 110, 1)
end

function Barber.ConditionalCancelHaircut(ply)
	if IsValid(ply:GetBarber()) or IsValid(ply:GetHaircutCustomer()) then
		Barber.CancelHaircut(ply)
	end
end

function Barber.AskForHaircut(barber, customer)
	if customer:IsBot() then
		Barber.StartHaircut(barber, customer)
		return
	end

	customer.PendingHaircutRequest = true
	jlib.RequestBool("Do you want your hair cut?", function(response)
		customer.PendingHaircutRequest = false
		if response == true then
			Barber.StartHaircut(barber, customer)
		elseif IsValid(barber) then
			barber:falloutNotify("This customer doesn't want their hair cut")
		end
	end, customer)
end

-- Menu update networking
net.Receive("BarberUpdatePreview", function(len, ply)
	local customer = ply:GetHaircutCustomer()
	if IsValid(customer) then
		net.Start("BarberUpdatePreview")
			net.WriteUInt(net.ReadUInt(2), 2)
			net.WriteUInt(net.ReadUInt(16), 16)
		net.Send(customer)
	end
end)

net.Receive("BarberUpdatePreviewCol", function(len, ply)
	local customer = ply:GetHaircutCustomer()
	if IsValid(customer) then
		net.Start("BarberUpdatePreviewCol")
			net.WriteColor(net.ReadColor())
		net.Send(customer)
	end
end)

net.Receive("BarberCancel", function(len, ply)
	Barber.CancelHaircut(ply)
end)

net.Receive("BarberFinalize", function(len, ply)
	local customer = ply:GetHaircutCustomer()
	if IsValid(ply) and IsValid(customer) then
		Barber.FinalizeHaircut(ply, customer, net.ReadUInt(16), net.ReadUInt(16), net.ReadColor(), net.ReadUInt(16), net.ReadUInt(16))
	end
end)

-- Automatic haircut cancelling
hook.Add("PlayerDeath", "BarberCancelCut", Barber.ConditionalCancelHaircut)
hook.Add("PlayerSpawn", "BarberCancelCut", Barber.ConditionalCancelHaircut)
hook.Add("PlayerDisconnected", "BarberCancelCut", Barber.ConditionalCancelHaircut)
hook.Add("PlayerLoadedChar", "BarberCancelCut", Barber.ConditionalCancelHaircut)
hook.Add("PlayerSwitchWeapon", "BarberCancelCut", function(ply, oldWep, newWep)
	if IsValid(oldWep) and oldWep:GetClass() == "barber_scissors" then
		Barber.ConditionalCancelHaircut(ply)
	end
end)

-- Skillcheck networking
net.Receive("BarberSkillcheck", function(len, ply)
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep:GetClass() == "barber_scissors" then
		-- Client authoritative here since at best we could check each of their
		-- skillcheck attempts but they could just give the correct number
		-- for those too since the client already knows what the number needs to be
		local succ = net.ReadBool()

		wep:SetSkillcheck(false)

		if succ then
			Barber.FinishHaircut(ply, succ)
		else
			Barber.FinishHaircut(ply, succ)
		end
	end
end)
