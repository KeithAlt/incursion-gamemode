hook.Add("OnCharVarChanged", "BrandDesc", function(char, key, old, new)
    if key != "desc" or char.BrandEdit then return end

    if char.skipVarChanged then
        char.skipVarChanged = nil
        return
    end

    char.skipVarChanged = true

    char:setDesc(new .. char:getData("brandDesc", ""))
end)

// Adds a charBrand descriptor to currently existing charBrand
local function ChatNotify(ply, string)
	if !IsValid(ply) or !ply:IsPlayer() or !string then
		Error("Invalid ply or string")
	end

	jlib.Announce(ply, Color(255,0,0), "[BRANDING]", Color(255,255,255), " Information:\n", string)
end

local function addCharDescInfo(ply, string)
	if !IsValid(ply) or !string then
		ply:notify("Invalid player or string")
		return
	end

	local char = ply:getChar()

	char.BrandEdit = true
	char:setDesc(ply:getChar():getDesc() .. " | " .. string)
	ply:notify("Your character description has been updated")
	char.BrandEdit = nil
end

// Specific to NS command
function CharBrand.CreateBrandInquiry(target, inflictor)
	if target.pendingBrand then
		inflictor:notify("The target already has a pending brand")
		return
	end

	jlib.RequestBool("Do you wish to brand this person?", function(bool)
		if !bool then return end
		ChatNotify(inflictor,"● Your brand must be a physically described change to the character")

		jlib.RequestString("Enter the physical change", function(text)

			if !target:IsPlayer() or !target:Alive() or (#text < Armor.Config.DescLenMin) then
				inflictor:notify("Invalid target or brand input")
				return
			end

			target.BrandInflictor = inflictor
			target.pendingBrand = text
			jlib.AlertStaff(jlib.SteamIDName(inflictor) .. " is attempting to torture " .. target:Nick() .. " and requires staff approval\n - CHANGE: " .. " ' " .. text .. " '\n- Run the /accept CMD to accept the change while looking at player")
			inflictor:ConCommand("say !help I have submitted a torture request on a player")

		end, inflictor, "Submit")

	end, inflictor, "Yes", "No")
	//DiscordEmbed(jlib.SteamIDName(inflictor) .. " submitted a brand request on " .. jlib.SteamIDName(target) .. " with the change of: " .. string, "Character Brand Request Log" , Color(255,255,0), "Admin")
end

function CharBrand.DeclineBrand(ply)
	local target = ply:GetEyeTrace().Entity

	if !target or !target:IsPlayer() or !target:Alive() then
		ply:notify("Invalid player target")
		return
	elseif !target.pendingBrand then
		ply:notify("The player does not have a pending brand")
		//ply:ChatPrint("[ STAFF NOTICE ]  " .. target:Nick() .. " does not have a pending brand request\n- Inform the captures to try again(?)")
		return
	end

	if target.NextBrand then // removes brand cooldown
		target.NextBrand = nil
	end

	target.pendingBrand = nil

	ply:notify("Declined the pending brand request")
	target:notify("Your pending brand has been declined")
end

function CharBrand.CheckBrand(ply)
	local target = ply:GetEyeTrace().Entity

	if !target or !target:IsPlayer() or !target:Alive() then
		ply:notify("Invalid player target")
		return
	elseif !target.pendingBrand then
		ply:notify("The player does not have a pending brand")
		//ply:ChatPrint("[ STAFF NOTICE ]  " .. target:Nick() .. " does not have a pending brand request\n- Inform the captures to try again(?)")
		return
	end

	ply:ChatPrint("[STAFF INFO] " .. target:Nick() .. " has the following pending brand change: \n" .. target.pendingBrand)
	ply:notify("Pending brand printed to chat")
end

// Specific to NS command
function CharBrand.ApproveBrand(ply)
	if !ply or !ply:IsPlayer() or !ply:Alive() then
		Error("Invalid player target")
		return
	elseif !ply.pendingBrand then
		ply:notify("You do not have a pending brand")
		Error("Player target lacks a pending brand")
		return
	end

	local char = ply:getChar()

	jlib.RequestBool("Were you forcefully branded?", function(bool)
		if !bool then return end

		ChatNotify(ply,
		"● You now have a PK reason on all involved in your torture"
		.. "\n● Your captures cannot kill you, do not waste this immunity"
		.. "\n● Brands can be healed by certain individuals in the wasteland")

		for index, proxyPly in ipairs(ents.FindInSphere(ply:GetPos(), 800)) do
			if proxyPly:IsPlayer() and proxyPly != ply and proxyPly:GetMoveType() != MOVETYPE_NOCLIP and !proxyPly:IsHandcuffed() then
				proxyPly:addKarma(10, 2)
				proxyPly:falloutNotify("⚖ You've lost karma for torturing someone!", "ui/badkarma.ogg")

				ChatNotify(proxyPly,
				"● You cannot kill someone you forcefully branded"
				.. "\n● Even being idle-nearby a torture associates you to it"
				.. "\n● This individual now has a PK reason on you")

			end
		end
	end, ply, "Yes (Tortured)", "No (Willing)")

	addCharDescInfo(ply, ply.pendingBrand)
	char:setData("brandDesc", (char:getData("brandDesc") or "") .. " | " .. ply.pendingBrand) // Saves the brand desc for future use

	DiscordEmbed(jlib.SteamIDName(ply) .. " has accepted the torture request from " .. jlib.SteamIDName(ply.BrandInflictor) .. " with the change of: " .. target.pendingBrand, "Character Brand Log" , Color(255,255,0), "Admin")

	ply:ScreenFade(SCREENFADE.IN, Color( 255, 255, 255, 150 ), 0.4, 1)
	ply:falloutNotify("➲ You've been marked . . .", "fx/fx_poison_stinger.mp3")
	ply.pendingBrand = nil
	ply.BrandInflictor = nil

	ply.NextBrand = CurTime() + CharBrand.brandCooldownTime
end

// Changes the entire charBrand
function CharBrand.SetBrand(ply, str)
	if !ply or !ply:getChar() or !ply:getChar():getData("brandDesc") then
		ply:notify("You don't have a brand to change")
	elseif !str or #str <= 3 then
		ply:notify("Invalid brand change request: to short")
		return
	end

	local char = ply:getChar()
	local charDesc = char:getDesc()
	local charBrandDesc = char:getData("brandDesc")

	local newDesc = string.gsub(charDesc, charBrandDesc, "") or charDesc

	char:setData("brandDesc", " | " .. str)
	char.BrandEdit = true
	char:setDesc(newDesc ..  " | " .. str)
	char.BrandEdit = nil
end

// Remove brand
function CharBrand.RemoveBrand(ply)
	local char = ply:getChar()
	local charDesc = char:getDesc()
	local charBrandDesc = char:getData("brandDesc")

	if !char or !charDesc or !charBrandDesc then return end

	local newDesc = string.gsub(charDesc, charBrandDesc, "")

	char:setData("brandDesc", "")
	char.BrandEdit = true
	char:setDesc(newDesc)
	char.BrandEdit = nil
end

// Change a players entire description
function CharBrand.ChangeDescription(inflictor, target)
	local char = target:getChar()
	local charDesc = char:getDesc()

	jlib.RequestString("Enter new char description:", function(text)

		if !target:IsPlayer() or !target:Alive() or (#text < Armor.Config.DescLenMin) then
			inflictor:notify("Invalid target or description argument")
			return
		end

		jlib.AlertStaff(jlib.SteamIDName(inflictor) .. " has manually changed " .. jlib.SteamIDName(target) .. " description:\n- From: " .. charDesc .. "\n- To: " .. text)
		DiscordEmbed(jlib.SteamIDName(inflictor) .. " has manually changed " .. jlib.SteamIDName(target) .. " description:\n- From: " .. charDesc .. "\n- To: " .. text, "Staff Description Edit Log" , Color(255,255,0), "Admin")

		CharBrand.RemoveBrand(target)
		char:setDesc(text)

	end, inflictor, "Submit")
end
