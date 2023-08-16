CharBrand = CharBrand or {}
CharBrand.brandCooldownTime = 7200 // The amount of time (in sec) until a player can be branded again
CharBrand.maxDescLength = 50 // The amount of characters that a torture description can be
CharBrand.Author = "Keith"

hook.Add("InitPostEntity", "charBrandInit", function()
	local ITEM = nut.item.register("blemishkit", nil, false, nil, true)
	ITEM.name = "Blemish Kit"
	ITEM.desc = "A medical kit used to heal scared tissue and typically permanent bodily damage | This item is used to alter branded character descriptions"
	ITEM.model = "models/fallout/doctorsbag.mdl"
	ITEM["functions"].BlemishUse = {
		name = "Use (on target player)",
		icon = "icon16/user_edit.png",
		onRun = function(item)
		  local ply = item.player
			local target = ply:GetEyeTrace().Entity

			if !IsValid(target) or !target:getChar() or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 400 then
				ply:notify("Target player is to far away or invalid!")
				return
			else
				jlib.RequestBool("Do you wish to use your blemish kit?", function(plyBool)
					if !plyBool then
						return false
					elseif !target:getChar():getData("brandDesc") then
						ply:notify("The target player has no blemishes to heal")
						return false
					end

					jlib.RequestString("Enter your changes", function(text)
						if !item or !text then
							return false
						elseif #text > CharBrand.maxDescLength then
							ply:notify("Your change is to long - [" .. CharBrand.maxDescLength .. "] chars at max!")
							return false
						end

						ply:notify("Blemish request sent to patient")
						ply:falloutNotify("➲ You used a blemish kit on someone")
						item:remove()

						jlib.RequestBool("Someone is trying to alter your brands", function(targBool)
							if !targBool and IsValid(ply) then
								ply:notify("The patient refused your request")
								return
							end

							CharBrand.SetBrand(target, text)
							ply:notify("The patient accepted your blemish request")
						end, target, "Accept", "Decline")
					end, ply, "Apply")
				end, ply, "Yes", "No")

				return false
			end
		end
	}

	// Command to submit a brand request on a target
	nut.command.add("brand", {
		syntax = "Use while looking at a player",
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 400 then
				return "You are not close enough to or not looking at a valid player"
			elseif (target.NextBrand or 0) > CurTime() then
				return "target has a brand cooldown"
			end


			CharBrand.CreateBrandInquiry(target, ply)
			//ply.BrandTarget = target
		end
	})

	// Command to check if a player has a pending brand
	nut.command.add("checkbrand", {
		syntax = "Use while looking at a player",
		adminOnly = true,
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 400 then
				return "Target player is to far away or invalid!"
			end

			CharBrand.CheckBrand(ply)

			return
		end
	})

	// Command to forcefully edit a character description
	nut.command.add("editdesc", {
		syntax = "Use while looking at a player",
		adminOnly = true,
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 400 then
				return "Target player is to far away or invalid!"
			end

			CharBrand.ChangeDescription(ply, target)

			return
		end
	})

	// Command staff run to accept a torture description change request
	nut.command.add("acceptbrand", {
		syntax = "Use while looking at a player",
		adminOnly = true,
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 1000 or !ply:IsAdmin() then
				return "You are not close enough to or not looking at a valid player"
			end

			CharBrand.ApproveBrand(target)

			return "You have approved the brand"
		end
	})

	// Command staff run to decline a torture description change request
	nut.command.add("declinebrand", {
		syntax = "Use while looking at a player",
		adminOnly = true,
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 1000 or !ply:IsAdmin() then
				return "You are not close enough to or not looking at a valid player"
			end

			CharBrand.DeclineBrand(ply)

		end
	})

	// Command to remove a brand cooldown on a target
	nut.command.add("removebrandcooldown", {
		syntax = "Use while looking at a player",
		adminOnly = true,
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 1000 or !ply:IsAdmin() then
				return "You are not close enough to or not looking at a valid player"
			elseif !target.NextBrand then
				return target:Nick() .. " does not have a brand cooldown"
			end

			target.NextBrand = nil

			return "You have removed a brand cooldown on " .. target:Nick()
		end
	})

	// Command to manually specify a target's brand
	nut.command.add("changebrand", {
		syntax = "Use while looking at a player",
		adminOnly = true,
		onRun = function(ply)
			local target = ply:GetEyeTrace().Entity

			if !target or !target:IsPlayer() or target:GetPos():Distance(ply:GetPos()) > 1000 or !ply:IsAdmin() then
				return "You are not close enough to or not looking at a valid player"
			end

			jlib.RequestString("Enter the new brand", function(text)
				if !text then
					return
				elseif #text > CharBrand.maxDescLength then
					ply:notify("Your change is to long - [" .. CharBrand.maxDescLength .. "] chars at max!")
					return
				end

				CharBrand.SetBrand(target, text)
				ply:notify("Target's brand changed")
			end, ply, "Apply")
		end
	})
end)
