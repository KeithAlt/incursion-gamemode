-- Since I couldn't get stuff to update to this on both client and server I just decided to store it on the server.
-- I guess you could argue it keeps hackers from being able to browse the contents of the merchants..
nut.merchants.templates = {}
nut.merchants.instances = {}

-- We re-verify everything to make sure the player did not try any hacking or glitching.
netstream.Hook("nutMerchantBuy", function(player, merchant, template, item, quantity)
	if (nut.merchants.templates[template]) then -- Verify the template is valid.
		local tmpt = nut.merchants.templates[template]

		if (nut.merchants.instances[merchant]) then -- Verify the merchant instance is valid.
			local merch = nut.merchants.instances[merchant]

			if (tmpt.items[item]) then -- Verify the template actually sells this item.
				local purchase = tmpt.items[item]
				local character = player:getChar()

				if (character:hasMoney(purchase.price * quantity)) then -- Verify that they can afford the purchase.
					local success, fault = character:getInv():add(item, quantity)

					if (success) then -- This happens when everything goes according to plan.
						character:takeMoney(purchase.price * quantity)
						netstream.Start(player, "nutMerchantMessage", "Purchase Successful", false)
						if (player:IsAdmin() or player:IsSuperAdmin()) then
							nut.log.addRaw("["..player:SteamID().."] ("..character:getName()..") Purchased "..item.." x"..quantity.." for "..purchase.price.." each from "..merch.name)
						end;
					elseif (fault == "noSpace") then -- This displays a pop-up within the UI
						netstream.Start(player, "nutMerchantMessage", "You Need More Inventory Space", true)
					else -- Log any unhandled error so it can be coded in if needed.
						player:ChatPrint("Merchant purchase failed with fault: '"..fault.."'.")
					end;
				else -- This might happen if they edit the price in the UI window somehow.
					player:ChatPrint("You cannot afford the purchase cost of $"..(purchase.price * quantity)..".")
				end;
			else -- This might happen if they try pass an item the merchant doesn't sell.
				player:ChatPrint("This merchant does not sell the item you are after.")
			end;
		else -- This would happen if the merchant doesn't exist in the nut.merchants.instances table.
			player:ChatPrint("'"..merchant.."' is an invalid merchant instance.")
		end;
	else -- This would happen if the template does not exist in the nut.merchants.templates table.
		player:ChatPrint("'"..template.."' is an invalid merchant template.")
	end;
end)

-- Like with nutMerchantBuy we re-verify everything to be safe.
netstream.Hook("nutMerchantSell", function(player, merchant, template, item)
	if (nut.merchants.templates[template]) then -- Verify the template is valid.
		local tmpt = nut.merchants.templates[template]

		if (nut.merchants.instances[merchant]) then -- Verify the merchant instance is valid.
			local merch = nut.merchants.instances[merchant]

			-- We double check the merchant buys the specified item.
			if (tmpt.items[item].mode >= 2) then
				local character = player:getChar()
				local inventory = character:getInv()

				-- We make sure they have the item before completing the transaction.
				if (inventory:hasItem(item)) then
					for i, v in pairs(inventory:getItems()) do
						if (v.uniqueID == item and v:getID() != 0) then
							v:remove()
							character:giveMoney(tmpt.items[item].price * (merch.buyScale or 0.5))
							netstream.Start(player, "nutMerchantMessage", "Item Sale Successful", false)
							break
						end;
					end;
				else -- This would happen if the player doesn't have the item.
					player:ChatPrint("You don't have the item you are trying to sell.")
				end;
			else -- This happens if the merchant doesn't buy the item.
				player:ChatPrint("This merchant does not buy that item.")
			end;
		else -- This would happen if the merchant doesn't exist in the nut.merchants.instances table.
			player:ChatPrint("'"..merchant.."' is an invalid merchant instance.")
		end;
	else -- This would happen if the template does not exist in the nut.merchants.templates table.
		player:ChatPrint("'"..template.."' is an invalid merchant template.")
	end;
end)

netstream.Hook("nutMerchantsTemplateSave", function(player, template, data)
	nut.merchants.templates[template] = data
	nut.data.set("merchants_templates", nut.merchants.templates, false, true)
end)

netstream.Hook("nutMerchantsInstanceDelete", function(player, instance, entity)
	if (IsValid(entity)) then entity:Remove() end;
	nut.merchants.instances[instance] = nil
	nut.data.set("merchants_instances", nut.merchants.instances, false, false)
end)

netstream.Hook("nutMerchantsInstanceSave", function(player, instance, data, entity)
	if (IsValid(entity)) then
		data.pos = entity:GetPos()
		data.ang = entity:GetAngles()

		entity:SetModel(data.model)
		entity:setNetVar("instance", instance)

		timer.Simple(1, function() entity:setAnim() end)

		nut.merchants.instances[instance] = data
		nut.data.set("merchants_instances", nut.merchants.instances, false, false)
	end;
end)
