Workbenches = Workbenches or {}
Workbenches.Benches = Workbenches.Benches or {}
Workbenches.Presets = Workbenches.Presets or {}
Workbenches.Recipes = Workbenches.Recipes or {}
Workbenches.BenchEnts = Workbenches.BenchEnts or {}

Workbenches.Config = Workbenches.Config or {}
include("workbenches_config.lua")

--Core workbench types
Workbenches.Cores = {
	["Multicraft"] = {
		["sv_init"] = function()
			util.AddNetworkString("WBMC-Use")
			util.AddNetworkString("WBMC-TakeItem")
			util.AddNetworkString("WBMC-TakeAll")
			util.AddNetworkString("WBMC-StartCraft")

			net.Receive("WBMC-StartCraft", function(len, ply)
				local uniqueID = net.ReadString()
				local bench = net.ReadEntity()
				local category = bench:getNetVar("category", "Default")

				if !IsValid(bench) or ply:GetPos():DistToSqr(bench:GetPos()) > 500 * 500 then
					return
				end

				bench:StartProduction(uniqueID, ply, category)
			end)

			net.Receive("WBMC-TakeAll", function(len, ply)
				local bench = net.ReadEntity()

				if !IsValid(bench) or ply:GetPos():DistToSqr(bench:GetPos()) > 500 * 500 then
					return
				end

				bench:TakeItems(ply)
			end)

			net.Receive("WBMC-TakeItem", function(len, ply)
				local uniqueID = net.ReadString()
				local bench = net.ReadEntity()

				if !IsValid(bench) or ply:GetPos():DistToSqr(bench:GetPos()) > 500 * 500 then
					return
				end

				bench:TakeItem(ply, uniqueID)
			end)
		end,
		["cl_init"] = function()
			surface.CreateFont("WBMCMenu", {font = "Roboto", size = 20, weight = 500})

			net.Receive("WBMC-Use", function()
				local ent = net.ReadEntity()

				Workbenches.Cores.Multicraft.use(ent, LocalPlayer())
			end)

			function Workbenches.Cores.Multicraft.ActiveCraftsMenu(menu, activeCrafts, items, bench)
				if IsValid(menu.activeCrafts) then
					menu.activeCrafts:Close()
				end

				if IsValid(menu.takeAll) then
					menu.takeAll:Remove()
				end

				if #activeCrafts == 0 and jlib.TableSum(items) == 0 then
					return
				end

				local frame = vgui.Create("UI_DFrame")
				frame:SetSize(300, 800)
				frame:Center()
				frame:MoveLeftOf(menu, 20)
				frame:SetTitle("Crafting")
				frame:MakePopup()

				local scrollPanel = vgui.Create("DScrollPanel", frame)
				scrollPanel:Dock(FILL)

				local c = nut.gui.palette.color_primary
				local hoverColor = Color(c.r - (c.r/4), c.g - (c.g/4), c.b - (c.b/4))

				local scrollBar = scrollPanel:GetVBar()
				scrollBar:SetHideButtons(true)
				scrollBar.Paint = function() end
				scrollBar.btnGrip.Paint = function(s, w, h)
					if s.Depressed then
						surface.SetDrawColor(hoverColor)
					else
						surface.SetDrawColor(c)
					end
					surface.DrawRect(0, 0, w, h)
				end

				local i = 0
				for k, craft in pairs(activeCrafts) do
					local item = nut.item.list[craft.item]

					local itemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
					itemPanel:SetSize(200, 75)
					itemPanel:SetPos(((frame:GetWide() - 30) / 2) - (itemPanel:GetWide() / 2), i * 95)
					itemPanel.Paint = function(s, w, h)
						surface.SetDrawColor(nut.gui.palette.color_background)
						surface.DrawRect(0, 0, w, h)

						//DisableClipping(true)
						surface.SetDrawColor(Color(0, 0, 0))
						surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

						surface.SetDrawColor(nut.gui.palette.color_primary)
						surface.DrawOutlinedRect(0, 0, w, h)
						surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
						//DisableClipping(false)
					end

					local itemIcon = vgui.Create("nutSpawnIcon", itemPanel)
					itemIcon:SetModel(item.model)
					itemIcon:SetSize(64, 64)
					itemIcon:Dock(LEFT)

					local itemName = vgui.Create("UI_DLabel", itemPanel)
					itemName:SetText(item.name)
					itemName:SetFont("WBMCMenu")
					itemName:SizeToContents()
					itemName:MoveRightOf(itemIcon)

					local progressBar = vgui.Create("DPanel", itemPanel)
					progressBar:SetSize(100, 12)
					progressBar.Paint = function(s, w, h)
						surface.SetDrawColor(0, 0, 0, 255)
						surface.DrawOutlinedRect(0, 0, w, h)

						surface.SetDrawColor(100, 255, 100, 255)
						surface.DrawRect(1, 1, (w - 2) * math.min((CurTime() - craft.startTime) / (craft.endTime - craft.startTime), 1), h - 2)
					end
					progressBar:MoveRightOf(itemIcon)
					progressBar:MoveBelow(itemName, 3)

					i = i + 1
				end

				for uniqueID, amt in pairs(items) do
					for j = 1, amt do
						local item = nut.item.list[uniqueID]

						local itemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
						itemPanel:SetSize(200, 75)
						itemPanel:SetPos(((frame:GetWide() - 30) / 2) - (itemPanel:GetWide() / 2), i * 95)
						itemPanel.Paint = function(s, w, h)
							surface.SetDrawColor(nut.gui.palette.color_background)
							surface.DrawRect(0, 0, w, h)

							//DisableClipping(true)
							surface.SetDrawColor(Color(0, 0, 0))
							surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

							surface.SetDrawColor(nut.gui.palette.color_primary)
							surface.DrawOutlinedRect(0, 0, w, h)
							surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
							//DisableClipping(false)
						end

						local itemIcon = vgui.Create("nutSpawnIcon", itemPanel)
						itemIcon:SetModel(item.model)
						itemIcon:SetSize(64, 64)
						itemIcon:Dock(LEFT)

						local itemName = vgui.Create("UI_DLabel", itemPanel)
						itemName:SetText(item.name)
						itemName:SetFont("WBMCMenu")
						itemName:SizeToContents()
						itemName:MoveRightOf(itemIcon)

						local takeItem = vgui.Create("UI_DButton", itemPanel)
						takeItem:SetSize(100, 18)
						takeItem:MoveRightOf(itemIcon)
						takeItem:MoveBelow(itemName, 3)
						takeItem:SetText("Take")
						takeItem:SetFont("WBMCMenu")
						takeItem.DoClick = function(s)
							net.Start("WBMC-TakeItem")
								net.WriteString(uniqueID)
								net.WriteEntity(bench)
							net.SendToServer()
						end

						i = i + 1
					end
				end

				local takePanel = vgui.Create("UI_DPanel_Horizontal")
				takePanel:SetSize(300, 30)
				takePanel:SetPos(frame:GetPos())
				takePanel:MoveBelow(frame, 20)
				takePanel:MakePopup()

				local takeAll = vgui.Create("UI_DButton", takePanel)
				takeAll.DoClick = function(s)
					net.Start("WBMC-TakeAll")
						net.WriteEntity(bench)
					net.SendToServer()
				end
				takeAll:SetText("Take All")
				takeAll:DockMargin(3, 3, 3, 3)
				takeAll:Dock(FILL)
				takeAll:SetContentAlignment(5)
				takeAll:SetFont("WBMCMenu")

				menu.activeCrafts = frame
				menu.takeAll = takePanel
			end
		end,
		["EntFuncs"] = {
			["Think"] = function(self)
				local activeCrafts = self:getNetVar("activeCrafts", {})

				for i = 1, #activeCrafts do
					local craft = activeCrafts[i]

					if !craft then continue end

					if CurTime() >= craft.endTime then
						self:FinishProduction(craft.item)
					end
				end
			end,
			["StartProduction"] = function(self, uniqueID, ply, category)
				local activeCrafts = self:getNetVar("activeCrafts", {})

				if #activeCrafts >= self:GetMaxCrafts() then
					ply:notify("This " .. self:GetBenchName():lower() .. "'s craft slots are all taken!")
					return
				end

				local recipe = Workbenches.Recipes[category][uniqueID].ingredients

				local char = ply:getChar()
				local inv = char:getInv()

				--Check they have the required components
				local items = {}
				for component, amtRequired in pairs(recipe) do
					local componentItems = inv:getItemsByUniqueID(component)
					local amt = #componentItems

					if amt < amtRequired then
						ply:notify("You don't have the required materials to craft this!")
						return
					end

					local itemsToAdd = {}
					for i = 1, amtRequired do
						itemsToAdd[#itemsToAdd + 1] = componentItems[i]
					end

					items = table.Add(items, itemsToAdd)
				end

				--Remove the components from their inventory
				for k, v in ipairs(items) do
					v:remove()
				end

				--Start the craft timer
				activeCrafts[#activeCrafts + 1] = {
					item = uniqueID,
					startTime = CurTime(),
					endTime = CurTime() + Workbenches.Recipes[category][uniqueID].time
				}

				self:setNetVar("activeCrafts", activeCrafts)

				self:SetActive(true)
				if self.Sound then
					self:StartBenchSound()
				end

				nut.leveling.giveXP(ply, 2)
			end,
			["FinishProduction"] = function(self, uniqueID)
				local activeCrafts = self:getNetVar("activeCrafts", {})

				for k, craft in pairs(activeCrafts) do
					if craft.item == uniqueID then
						table.remove(activeCrafts, k)
						break
					end
				end
				self:setNetVar("activeCrafts", activeCrafts)

				local items = self:getNetVar("items", {})
				items[uniqueID] = (items[uniqueID] or 0) + 1

				self:setNetVar("items", items)

				if #activeCrafts <= 0 then
					self:SetActive(false)

					if self.Sound then
						self:StopBenchSound(1)
					end
				end
			end,
			["TakeItems"] = function(self, ply)
				local char = ply:getChar()
				local inv = char:getInv()

				local items = self:getNetVar("items", {})
				if jlib.TableSum(items) <= 0 then
					ply:notify("No items to take!")

					return
				end

				for item, amt in pairs(items) do
					for i = 1, amt do
						local data = hook.Run("WBMCTakeItem", self, ply, item) or {}

						local x = inv:add(item, 1, data)

						if !x then
							ply:notify("You don't have space to take any more items!")

							return
						end

						items[item] = math.max(items[item] - 1, 0)
					end
				end

				self:setNetVar("items", items)
			end,
			["TakeItem"] = function(self, ply, uniqueID)
				local char = ply:getChar()
				local inv = char:getInv()

				local items = self:getNetVar("items", {})
				if items[uniqueID] <= 0 then
					ply:notify("No " .. uniqueID .. " left to take!")

					return
				end

				local data = hook.Run("WBMCTakeItem", self, ply, uniqueID) or {}

				local x = inv:add(uniqueID, 1, data)

				if !x then
					ply:notify("You don't have space to take this item!")

					return
				end

				items[uniqueID] = math.max(items[uniqueID] - 1, 0)

				self:setNetVar("items", items)
			end
		},
		["entInit"] = function(ent)
			for key, func in pairs(Workbenches.Cores.Multicraft.EntFuncs) do
				ent[key] = func
			end
		end,
		["config"] = function(panel, options, ent)
			--Option for recipes

			if CLIENT then
				local categorySelector = panel:Add("DComboBox")
				categorySelector:SetWide(300)

				for category, recipes in pairs(Workbenches.Recipes) do
					categorySelector:AddChoice(category, recipes)
				end

				local outputs = {}

				local recipeList = panel:Add("DListView")
				recipeList:AddColumn("Item Recipes")
				recipeList:SetMultiSelect(false)
				recipeList:SetSize(300, 300)
				recipeList:MoveBelow(categorySelector, 5)

				categorySelector.OnSelect = function(s, i, val, dat)
					for output, recipe in pairs(dat) do
						local item = nut.item.list[output]

						recipeList:AddLine(item.name).uniqueID = item.uniqueID
					end
				end

				recipeList.OnClickLine = function(s, line)
					if outputs[line.uniqueID] then
						outputs[line.uniqueID] = nil

						if line.tick then
							line.tick:Remove()
							line.tick = nil
						end
					else
						outputs[line.uniqueID] = true

						local tick = line:Add("DImage")
						tick:SetSize(16, 16)
						tick:SetImage("icon16/tick.png")
						tick:SetPos(line:GetWide() - 32, 0)
						line.tick = tick
					end
				end

				local maxCraftsEntry = panel:Add("DTextEntry")
				maxCraftsEntry:SetWide(300)
				maxCraftsEntry:SetNumeric(true)
				maxCraftsEntry:MoveBelow(recipeList)
				maxCraftsEntry:SetPlaceholderText("Maximum Simultaneous Crafts")

				local function buttonEnabled(s)
					if maxCraftsEntry:GetValue() != "" and table.Count(outputs) > 0 then
						s:SetDisabled(false)
					else
						s:SetDisabled(true)
					end
				end

				local savePresetButton = Workbenches.AddPresetButton(panel:GetParent(), options, buttonEnabled)
				savePresetButton.ExtraOptions = function(o)
					o.outputs = outputs
					o.maxCrafts = tonumber(maxCraftsEntry:GetValue())
					o.category = categorySelector:GetSelected()
				end

				local finishButton = panel:GetParent():Add("DButton")
				finishButton:SetText("Finish")
				finishButton:Dock(BOTTOM)
				finishButton:SetDisabled(true)
				finishButton.Think = buttonEnabled

				finishButton.DoClick = function(s)
					options.outputs = outputs
					options.maxCrafts = tonumber(maxCraftsEntry:GetValue())
					options.category = categorySelector:GetSelected()

					net.Start("WBConfig")
						jlib.WriteCompressedTable(options)
						net.WriteEntity(ent)
					net.SendToServer()

					panel:GetParent():Close()
				end

				panel:SizeToChildren(true, true)
				panel:Center()
			end
		end,
		["setup"] = function(ent, options)
			ent:setNetVar("outputs", options.outputs)
			ent:setNetVar("category", options.category or "Default")
			ent:SetMaxCrafts(options.maxCrafts)
		end,
		["use"] = function(ent, ply, backButton)
			if SERVER then
				net.Start("WBMC-Use")
					net.WriteEntity(ent)
				net.Send(ply)
			end

			if CLIENT then
				local w, h = ScrW(), ScrH()
				local bench = ent
				local char = LocalPlayer():getChar()
				local inv = char:getInv()

				local frame = vgui.Create("UI_DFrame")
				frame:SetDraggable(false)
				frame:SetSize(w * .234, h * .740)
				frame:SetTitle(ent:GetBenchName())
				frame:Center()

				local closePanel = vgui.Create("UI_DPanel_Horizontal")
				closePanel:SetSize(w * .234, h * .0277)
				closePanel:MoveBelow(frame, h * .018)
				closePanel:CenterHorizontal()

				local closeButton = vgui.Create("UI_DButton", closePanel)
				closeButton.DoClick = function(s)
					frame:Close()
					closePanel:Remove()

					if IsValid(frame.recipeFrame) then
						frame.recipeFrame:Close()
					end

					if IsValid(frame.activeCrafts) then
						frame.activeCrafts:Close()
					end

					if IsValid(frame.takeAll) then
						frame.takeAll:Remove()
					end

					if backButton then
						vgui.Create("nutMenu")
					end
				end
				closeButton:SetText(backButton and "Back" or "Close")
				closeButton:DockMargin(w * .0015, h * .0027, w * .0015, h * .0027)
				closeButton:Dock(FILL)
				closeButton:SetContentAlignment(5)
				closeButton:SetFont("WBMCMenu")
				closePanel:MakePopup()
				frame:MakePopup()

				local paint = closePanel.Paint
				local startTime = backButton and 0 or SysTime()
				closePanel.Paint = function(s, w, h)
					Derma_DrawBackgroundBlur(s, startTime)
					paint(s, w, h)
				end

				local scrollPanel = vgui.Create("DScrollPanel", frame)
				scrollPanel:Dock(FILL)

				local c = nut.gui.palette.color_primary
				local hoverColor = Color(c.r - (c.r/4), c.g - (c.g/4), c.b - (c.b/4))

				local scrollBar = scrollPanel:GetVBar()
				scrollBar:SetHideButtons(true)
				scrollBar.Paint = function() end
				scrollBar.btnGrip.Paint = function(s, w, h)
					if s.Depressed then
						surface.SetDrawColor(hoverColor)
					else
						surface.SetDrawColor(c)
					end
					surface.DrawRect(0, 0, w, h)
				end

				local recipes = {}
				local category = ent:getNetVar("category", "Default")

				for k, _ in pairs(ent:getNetVar("outputs", {})) do
					recipes[k] = Workbenches.Recipes[category][k]
				end

				local i = 0
				for k, recipe in SortedPairsByMemberValue(recipes, "time") do
					local item = nut.item.list[k]
					if !item then
						print("WARNING: Workbench with invalid item", k)
						continue
					end

					local itemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
					itemPanel:SetSize(w * .156, h * .0694)
					itemPanel:SetPos(((frame:GetWide() - (w * .0156)) / 2) - (itemPanel:GetWide() / 2), i * (h * .0925))
					itemPanel.Paint = function(s, w, h)
						surface.SetDrawColor(nut.gui.palette.color_background)
						surface.DrawRect(0, 0, w, h)

						//DisableClipping(true)
						surface.SetDrawColor(Color(0, 0, 0))
						surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

						surface.SetDrawColor(nut.gui.palette.color_primary)
						surface.DrawOutlinedRect(0, 0, w, h)
						surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
						//DisableClipping(false)
					end

					local itemIcon = vgui.Create("nutSpawnIcon", itemPanel)
					itemIcon:SetModel(item.model)
					itemIcon:SetSize(w * .033, h * .0592)
					itemIcon:Dock(LEFT)
					itemIcon.DoClick = function(s)
						if IsValid(frame.recipeFrame) then
							frame.recipeFrame:Close()
						end

						frame.recipeFrame = vgui.Create("UI_DFrame")

						local rFrame = frame.recipeFrame
						rFrame:Hide()
						rFrame:SetSize(w * .1041, h * .018)
						rFrame:SetPos(frame:GetPos())
						rFrame:MoveRightOf(frame, h * .018)
						rFrame:MakePopup()
						rFrame:SetTitle("Recipe")

						local j = 1
						for componentID, amt in pairs(recipe.ingredients) do
							local componentLabel = vgui.Create("UI_DLabel", rFrame)
							componentLabel:SetText(nut.item.list[componentID].name .. " x" .. amt)
							componentLabel:SetFont("WBMCMenu")
							componentLabel:SizeToContents()
							componentLabel:SetPos(w * .002, (h*.0277) * j)

							if #inv:getItemsByUniqueID(componentID) >= amt then
								componentLabel:SetTextColor(Color(100, 255, 100, 255))
							else
								componentLabel:SetTextColor(Color(255, 100, 100, 255))
							end

							j = j + 1
						end

						local craftButton = vgui.Create("UI_DButton", rFrame)
						craftButton:SetText("Start Crafting")
						craftButton:SetPos(w * .002, (h*.0277) * j)
						craftButton:SetWide(rFrame:GetWide() - (w * .0041))
						craftButton:SetTall(h * .0203)
						craftButton.DoClick = function(self)
							net.Start("WBMC-StartCraft")
								net.WriteString(k)
								net.WriteEntity(bench)
							net.SendToServer()
						end
						craftButton:SetFont("WBMCMenu")

						rFrame:SizeToChildren(false, true)
						local _, rH = rFrame:GetSize()
						rFrame:SetSize(w * .1041, h * .0185)

						rFrame:Show()

						rFrame:SizeTo(w * .1041, rH, 0.6)
					end

					local itemName = vgui.Create("UI_DLabel", itemPanel)
					itemName:SetText(item.name)
					itemName:SetFont("WBMCMenu")
					itemName:SizeToContents()
					itemName:MoveRightOf(itemIcon)

					local itemTime = vgui.Create("UI_DLabel", itemPanel)
					itemTime:SetText("Production Time: " .. (recipe.time or 60) .. "s")
					itemTime:SetFont("WBMCMenu")
					itemTime:SizeToContents()
					itemTime:MoveBelow(itemName, 3)
					itemTime:MoveRightOf(itemIcon)

					i = i + 1
				end

				--Update craft panel whenever items/activeCrafts changes
				local activeCraftsOriginal = bench:getNetVar("activeCrafts", {})
				local itemsOriginal = bench:getNetVar("items", {})

				if #activeCraftsOriginal > 0 or jlib.TableSum(itemsOriginal) > 0 then
					Workbenches.Cores.Multicraft.ActiveCraftsMenu(frame, activeCraftsOriginal, itemsOriginal, bench)
				end

				frame.Think = function()
					local activeCrafts = bench:getNetVar("activeCrafts", {})
					local items = bench:getNetVar("items", {})

					if #activeCrafts != #activeCraftsOriginal or jlib.TableSum(items) != jlib.TableSum(itemsOriginal) then
						activeCraftsOriginal = activeCrafts
						itemsOriginal = items

						Workbenches.Cores.Multicraft.ActiveCraftsMenu(frame, activeCrafts, items, bench)
					end
				end
			end
		end,
		["lockpicked"] = function(ent, lockpicker)
			Workbenches.Cores.Multicraft.use(ent, lockpicker)
		end
	},
	["Singlecraft"] = {
		["sv_init"] = function()
			util.AddNetworkString("WBSC-Use")
			util.AddNetworkString("WBSC-InsertFuel")
			util.AddNetworkString("WBSC-EjectFuel")

			net.Receive("WBSC-InsertFuel", function(len, ply)
				local ent = net.ReadEntity()

				if ply:GetPos():Distance(ent:GetPos()) > 250 then return end

				local items = ply:getChar():getInv():getItems()
				for _,item in pairs(items) do
					if item.uniqueID == ent:GetInput() and item:getData("uses", ent:GetMaxUses()) > 0 then
						ent:SetFuel(math.min(ent:GetMaxUses(), item:getData("uses", ent:GetMaxUses())))
						item:remove()
						ent:OnFueled()
						return
					end
				end

				ply:notify("You lack the " .. nut.item.list[ent:GetInput()].name:lower() .. " required to fuel this " .. ent:GetBenchName():lower())
			end)

			net.Receive("WBSC-EjectFuel", function(len, ply)
				local ent = net.ReadEntity()

				if ply:GetPos():Distance(ent:GetPos()) > 250 then return end
				if ent:GetFuel() <= 0 then print("Dupe prevented") return end

				local inv = ply:getChar():getInv()
				nut.item.instance(0, ent:GetInput(), nil, nil, nil, function(item)
					item:setData("uses", ent:GetFuel())
					inv:add(item.id)
				end)

				ent:SetFuel(0)
				ent:OnFuelEjected()
			end)
		end,
		["cl_init"] = function()
			net.Receive("WBSC-Use", function()
				local ent = net.ReadEntity()
				local timeLeft = net.ReadInt(32)

				Workbenches.Cores.Singlecraft.use(ent, LocalPlayer(), timeLeft)
			end)
		end,
		["entInit"] = function(ent)
			ent:setNetVar("inventory", {})

			function ent:OnFueled()
				local timerID = "WBProduction" .. self:EntIndex()

				timer.Create(timerID, self:GetProductionTime(), 0, function()
					if !IsValid(self) then
						timer.Remove(timerID)
						return
					end

					self:ProduceItem()
				end)

				self:SetActive(true)
				if self.Sound then
					self:StartBenchSound()
				end
			end

			function ent:OnFuelEjected()
				timer.Remove("WBProduction" .. self:EntIndex())
				self:SetFuel(0)

				self:SetActive(false)
				if self.Sound then
					self:StopBenchSound(1)
				end
			end

			function ent:TakeItem(uniqueID, ply)
				local items = self:getNetVar("inventory", {})

				local char = ply:getChar()
				local inv = char:getInv()

				for uID, amt in pairs(items) do
					if uniqueID == uID and amt > 0 then
						local success = inv:add(uID)

						if success then
							items[uID] = items[uID] - 1
							self:setNetVar("inventory", items)
						else
							ply:notify("You have no space!")
						end

						return
					end
				end

				ply:notify("None found.")
			end

			function ent:TakeAllItems(ply)
				local items = self:getNetVar("inventory", {})

				local char = ply:getChar()
				local inv = char:getInv()

				for uID, amt in pairs(items) do
					for i = 1, amt do
						local success = inv:add(uID)

						if success then
							items[uID] = items[uID] - 1
							self:setNetVar("inventory", items)
						else
							ply:notify("Out of space.")
							return
						end
					end
				end
			end
		end,
		["config"] = function(panel, options, ent)
			--Option for fuel item and output item

			if CLIENT then
				local fuelList = panel:Add("DListView")
				fuelList:AddColumn("Fuel Item")
				fuelList:SetMultiSelect(false)
				fuelList:SetSize(150, 300)

				local outputList = panel:Add("DListView")
				outputList:AddColumn("Output Item")
				outputList:SetPos(150, 0)
				outputList:SetMultiSelect(false)
				outputList:SetSize(150, 300)

				for uniqueID, item in pairs(nut.item.list) do
					fuelList:AddLine(item.name).uniqueID = uniqueID
					outputList:AddLine(item.name).uniqueID = uniqueID
				end

				local maxUseSlider = panel:Add("DNumSlider")
				maxUseSlider:SetWide(300)
				maxUseSlider:MoveBelow(outputList, 5)
				maxUseSlider:SetMinMax(1, 10)
				maxUseSlider:SetValue(3)
				maxUseSlider:SetDecimals(0)
				maxUseSlider:SetText("Fuel Uses")

				local productionTime = panel:Add("DTextEntry")
				productionTime:SetPlaceholderText("Production Time")
				productionTime:SetNumeric(true)
				productionTime:SetWide(300)
				productionTime:MoveBelow(maxUseSlider, 5)

				local invXSlider = panel:Add("DNumSlider")
				invXSlider:SetWide(300)
				invXSlider:MoveBelow(productionTime)
				invXSlider:SetMinMax(1, 10)
				invXSlider:SetValue(7)
				invXSlider:SetDecimals(0)
				invXSlider:SetText("Inv Width")

				local invYSlider = panel:Add("DNumSlider")
				invYSlider:SetWide(300)
				invYSlider:MoveBelow(invXSlider)
				invYSlider:SetMinMax(1, 10)
				invYSlider:SetValue(7)
				invYSlider:SetDecimals(0)
				invYSlider:SetText("Inv Height")

				local function buttonEnabled(s)
					if fuelList:GetSelectedLine() and outputList:GetSelectedLine() and productionTime:GetValue() != "" then
						s:SetDisabled(false)
					else
						s:SetDisabled(true)
					end
				end

				local savePresetButton = Workbenches.AddPresetButton(panel:GetParent(), options, buttonEnabled)
				savePresetButton.ExtraOptions = function(o)
					o.input = fuelList:GetLine(fuelList:GetSelectedLine()).uniqueID
					o.output = outputList:GetLine(outputList:GetSelectedLine()).uniqueID
					o.maxUses = maxUseSlider:GetValue()
					o.productionTime = tonumber(productionTime:GetValue())
					o.invX = invXSlider:GetValue()
					o.invY = invXSlider:GetValue()
				end

				local finishButton = panel:GetParent():Add("DButton")
				finishButton:SetText("Finish")
				finishButton:Dock(BOTTOM)
				finishButton:SetDisabled(true)
				finishButton.Think = buttonEnabled

				finishButton.DoClick = function(s)
					options.input = fuelList:GetLine(fuelList:GetSelectedLine()).uniqueID
					options.output = outputList:GetLine(outputList:GetSelectedLine()).uniqueID
					options.maxUses = maxUseSlider:GetValue()
					options.productionTime = tonumber(productionTime:GetValue())
					options.invX = invXSlider:GetValue()
					options.invY = invYSlider:GetValue()

					net.Start("WBConfig")
						jlib.WriteCompressedTable(options)
						net.WriteEntity(ent)
					net.SendToServer()

					panel:GetParent():Close()
				end

				panel:SizeToChildren(true, true)
				panel:Center()
			end
		end,
		["setup"] = function(ent, options)
			ent:SetInput(options.input)
			ent:SetOutput(options.output)
			ent:SetMaxUses(options.maxUses)
			ent:SetProductionTime(options.productionTime)
			ent:SetInvX(options.invX or 7)
			ent:SetInvY(options.invY or 7)
		end,
		["use"] = function(ent, ply, timeLeft)
			if SERVER then
				net.Start("WBSC-Use")
					net.WriteEntity(ent)
					net.WriteInt(timer.TimeLeft("WBProduction" .. ent:EntIndex()) or -1, 32)
				net.Send(ply)
			end

			if CLIENT then
				local function ButtonPaint(s, w, h)
					surface.SetDrawColor(nut.gui.palette.color_background)
					surface.DrawRect(0, 0, w, h)

					DisableClipping(true)
					surface.SetDrawColor(Color(0, 0, 0))
					surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

					surface.SetDrawColor(nut.gui.palette.color_primary)
					surface.DrawOutlinedRect(0, 0, w, h)
					surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					DisableClipping(false)
				end

				local readyTime

				if ent:GetFuel() > 0 and timeLeft != -1 then
					readyTime = CurTime() + timeLeft
				end

				local w, h = ScrW(), ScrH()
				local frame = vgui.Create("UI_DFrame")
				frame:SetSize(w * .234, h * .277)
				frame:Center()
				frame:SetTitle(ent:GetBenchName())
				frame:MakePopup()
				jlib.AddBackgroundBlur(frame)

				local isFilled = false
				local material

				local materialFrame = vgui.Create("DPanel", frame)
				materialFrame:SetSize(w * .0520, h * .0925)
				materialFrame:SetPos(w * .005, h * .037)
				materialFrame.Paint = ButtonPaint
				materialFrame.Think = function(s)
					if ent:GetFuel() > 0 and !isFilled then
						material = vgui.Create("nutSpawnIcon", materialFrame)
						material:SetModel(nut.item.list[ent:GetInput()].model)
						material:SetSize(w * .0479, h * .085)
						material:Center()
						isFilled = true
					elseif ent:GetFuel() < 1 and isFilled then
						material:Remove()
						material = nil
						isFilled = false
					end
				end

				local fuelBar = vgui.Create("DPanel", materialFrame)
				fuelBar:SetSize(w * .003, h * .083)
				fuelBar:SetPos(w * .0463, h * .0046)

				local fuelFill = vgui.Create("DPanel", fuelBar)
				fuelFill:SetSize(w * .00208, h * .0814)
				fuelFill:SetPos(1, 1)
				fuelFill.Paint = function(s, w, h)
					local f = ent:GetFuel() / ent:GetMaxUses()
					surface.SetDrawColor(HSVToColor(150 * (f - 1/4), 1, 1))
					surface.DrawRect(0, h * (1 - f), w, h * f)
				end

				local fuelAmt = ent:GetFuel()
				local ieButton = vgui.Create("UI_DButton", frame)
				ieButton:SetText(fuelAmt > 1 and "Eject Fuel" or "Insert Fuel")
				ieButton:SizeToContents()
				ieButton:SetPos(0, h * .037)
				ieButton:MoveRightOf(materialFrame, 5)
				ieButton.Think = function(s)
					if ent:GetFuel() > 0 then
						s:SetText("Eject Fuel")
						s:SizeToContents()
						s.DoClick = function(self)
							net.Start("WBSC-EjectFuel")
								net.WriteEntity(ent)
							net.SendToServer()
						end
					else
						s:SetText("Insert Fuel")
						s:SizeToContents()
						s.DoClick = function(self)
							local hasFuel = false
							local items = LocalPlayer():getChar():getInv():getItems()

							for _,item in pairs(items) do
								if item.uniqueID == ent:GetInput() and item:getData("uses", ent:GetMaxUses()) > 0 then
									hasFuel = true
								end
							end

							net.Start("WBSC-InsertFuel")
								net.WriteEntity(ent)
							net.SendToServer()

							if hasFuel then
								readyTime = CurTime() + ent:GetProductionTime()
							end
						end
					end
				end

				local progressBar = vgui.Create("DPanel", frame)
				progressBar:SetSize(w * .1041, h * .023)
				progressBar:SetPos(w * .059, h * .069)

				local progressFill = vgui.Create("DPanel", progressBar)
				progressFill:SetSize(w * 0.103, h * .0212)
				progressFill:SetPos(1, 1)
				progressFill.Paint = function(s, w, h)
					if !readyTime or ent:GetFuel() < 1 then return end

					local t = 1 - ((readyTime - CurTime()) / ent:GetProductionTime())

					if t >= 1 then
						readyTime = CurTime() + ent:GetProductionTime()
					end

					surface.SetDrawColor(HSVToColor(120 * t, 1, 1))
					surface.DrawRect(0, 0, w * t, h)
				end

				local closeButton = vgui.Create("UI_DButton", frame)
				closeButton:Dock(BOTTOM)
				closeButton:SetText("Close")
				closeButton.DoClick = function(s)
					frame:Close()
				end

				local inventoryButton = vgui.Create("UI_DButton", frame)
				inventoryButton:Dock(BOTTOM)
				inventoryButton:SetText("Inventory")
				inventoryButton.DoClick = function(s)
					net.Start("WBRequestInv")
						net.WriteEntity(ent)
					net.SendToServer()
				end

				if ent:GetOwnership() == LocalPlayer() then
					local factionAccessLabel = vgui.Create("UI_DLabel", frame)
					factionAccessLabel:SetText("Allow Faction Access: ")
					factionAccessLabel:SizeToContents()
					factionAccessLabel:MoveBelow(materialFrame, 2)
					factionAccessLabel:MoveLeftOf(materialFrame, -factionAccessLabel:GetWide())



					local factionAccessCheck = vgui.Create("DButton", frame)
					factionAccessCheck:SetPos(factionAccessLabel:GetPos())
					factionAccessCheck:MoveRightOf(factionAccessLabel, 3)
					factionAccessCheck:SetSize(w * .0114, h * .0203)
					factionAccessCheck:SetText("")
					factionAccessCheck.Paint = function(s, w, h)
						surface.SetDrawColor(s:IsHovered() and Color(0, 0, 0, 160) or Color(0, 0, 0, 100))
						surface.DrawRect(0, 0, w, h)

						if ent:GetFactionAccess() then
							surface.SetDrawColor(nut.gui.palette.color_primary)
							surface.DrawLine(0, 0, w, h)
							surface.DrawLine(w, 0, 0, h)
						end
						surface.SetDrawColor(Color(0, 0, 0, 160))
						surface.DrawOutlinedRect(0, 0, w, h)
					end
					factionAccessCheck.DoClick = function(s)
						net.Start("WBFactionAccessToggle")
							net.WriteEntity(ent)
						net.SendToServer()
					end
				end
			end
		end,
		["produce"] = function(ent)
			ent:SetFuel(math.max(ent:GetFuel() - 1, 0))

			local curItems = ent:getNetVar("inventory", {})
			if jlib.TableSum(curItems) < (math.Round(ent:GetInvX()) * math.Round(ent:GetInvY())) then
				curItems[ent:GetOutput()] = (curItems[ent:GetOutput()] or 0) + 1
				ent:setNetVar("inventory", curItems)
			end

			if ent:GetFuel() < 1 then
				ent:OnFuelEjected()
			end
		end,
		["lockpicked"] = function(ent, lockpicker)
			ent:OpenInventory(lockpicker)
		end
	},
	["Infinitecraft"] = {
		["sv_init"] = function()
			util.AddNetworkString("WBIC-Use")
			util.AddNetworkString("WBIC-ChangeProduction")

			net.Receive("WBIC-ChangeProduction", function(len, ply)
				local ent = net.ReadEntity()
				local uniqueID = net.ReadString()

				if ply:GetPos():DistToSqr(ent:GetPos()) > 250 * 250 then return end

				ent:SetOutput(uniqueID)
			end)
		end,
		["cl_init"] = function()
			net.Receive("WBIC-Use", function()
				local ent = net.ReadEntity()

				Workbenches.Cores.Infinitecraft.use(ent, LocalPlayer())
			end)
		end,
		["entInit"] = function(ent)
			local timerID = "WBProduction" .. ent:EntIndex()

			ent:NetworkVarNotify("Output", function(self, name, old, new)
				local delay = self:getNetVar("output", {})[new]

				timer.Create(timerID, delay, 0, function()
					self:ProduceItem()
				end)

				self:SetActive(true)
				if self.Sound then
					self:StartBenchSound()
				end
			end)

			function ent:TakeItem(uniqueID, ply)
				local items = self:getNetVar("inventory", {})

				local char = ply:getChar()
				local inv = char:getInv()

				for uID, amt in pairs(items) do
					if uniqueID == uID and amt > 0 then
						local success = inv:add(uID)

						if success then
							items[uID] = items[uID] - 1
							self:setNetVar("inventory", items)
						else
							ply:notify("You have no space!")
						end

						return
					end
				end

				ply:notify("None found.")
			end

			function ent:TakeAllItems(ply)
				local items = self:getNetVar("inventory", {})

				local char = ply:getChar()
				local inv = char:getInv()

				for uID, amt in pairs(items) do
					for i = 1, amt do
						local success = inv:add(uID)

						if success then
							items[uID] = items[uID] - 1
							self:setNetVar("inventory", items)
						else
							ply:notify("Out of space.")
							return
						end
					end
				end
			end
		end,
		["config"] = function(panel, options, ent)
			--Option for output item(s)

			local outputList = panel:Add("DListView")
			outputList:AddColumn("Output Items")
			outputList:SetMultiSelect(false)
			outputList:SetSize(300, 300)
			outputList.SelectedOutput = {}

			for uniqueID, item in pairs(nut.item.list) do
				outputList:AddLine(item.name).uniqueID = uniqueID
			end

			outputList.OnClickLine = function(s, line)
				Derma_StringRequest("Time", "Production Time", "30", function(text)
					local time = tonumber(text)

					if outputList.SelectedOutput[line.uniqueID] then
						outputList.SelectedOutput[line.uniqueID] = nil

						if line.tick then
							line.tick:Remove()
							line.tick = nil
						end
					else
						outputList.SelectedOutput[line.uniqueID] = time

						local tick = line:Add("DImage")
						tick:SetSize(16, 16)
						tick:SetImage("icon16/tick.png")
						tick:SetPos(line:GetWide() - 32, 0)
						line.tick = tick
					end
				end)
			end

			local invXSlider = panel:Add("DNumSlider")
			invXSlider:SetWide(300)
			invXSlider:MoveBelow(outputList)
			invXSlider:SetMinMax(1, 10)
			invXSlider:SetValue(7)
			invXSlider:SetDecimals(0)
			invXSlider:SetText("Inv Width")

			local invYSlider = panel:Add("DNumSlider")
			invYSlider:SetWide(300)
			invYSlider:MoveBelow(invXSlider)
			invYSlider:SetMinMax(1, 10)
			invYSlider:SetValue(7)
			invYSlider:SetDecimals(0)
			invYSlider:SetText("Inv Height")

			local function buttonEnabled(s)
				if table.Count(outputList.SelectedOutput) > 0 then
					s:SetDisabled(false)
				else
					s:SetDisabled(true)
				end
			end

			local savePresetButton = Workbenches.AddPresetButton(panel:GetParent(), options, buttonEnabled)
			savePresetButton.ExtraOptions = function(o)
				o.output = outputList.SelectedOutput
				o.invX = invXSlider:GetValue()
				o.invY = invYSlider:GetValue()
			end

			local finishButton = panel:GetParent():Add("DButton")
			finishButton:SetText("Finish")
			finishButton:Dock(BOTTOM)
			finishButton:SetDisabled(true)
			finishButton.Think = buttonEnabled

			finishButton.DoClick = function(s)
				options.output = outputList.SelectedOutput
				options.invX = invXSlider:GetValue()
				options.invY = invYSlider:GetValue()

				net.Start("WBConfig")
					jlib.WriteCompressedTable(options)
					net.WriteEntity(ent)
				net.SendToServer()

				panel:GetParent():Close()
			end

			panel:SizeToChildren(true, true)
			panel:Center()
		end,
		["setup"] = function(ent, options)
			ent:setNetVar("output", options.output)
			ent:SetInvX(options.invX or 7)
			ent:SetInvY(options.invY or 7)
		end,
		["use"] = function(ent, ply)
			if SERVER then
				net.Start("WBIC-Use")
					net.WriteEntity(ent)
				net.Send(ply)
			end

			if CLIENT then
				local function ButtonPaint(s, w, h)
					surface.SetDrawColor(nut.gui.palette.color_background)
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(Color(0, 0, 0))
					surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

					surface.SetDrawColor(nut.gui.palette.color_primary)
					surface.DrawOutlinedRect(0, 0, w, h)
					surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
				end

				local c = nut.gui.palette.color_primary
				local hoverColor = Color(c.r - (c.r / 4), c.g - (c.g / 4), c.b - (c.b / 4))
				local curItem = nut.item.list[ent:GetOutput()]

				local background = vgui.Create("UI_DFrame")
				background:SetSize(ScrW(), ScrH())
				background:SetTitle("")
				background.Paint = function(s, w, h)
					nut.util.drawBlur(s, 5)
					surface.SetDrawColor(0, 0, 0, 235)
					surface.DrawRect(0, 0, w, h)
				end

				local w, h = ScrW(), ScrH()
				local frame = vgui.Create("UI_DFrame")
				frame:MakePopup()
				frame:SetDraggable(false)
				frame:SetSize(ScrW() * .208, ScrH() * 0.74)
				frame:SetTitle("Production Menu")
				frame:Center()
				frame.OnClose = function()
					background:Close()
				end

				local currentItemFrame = vgui.Create("UI_DFrame")
				currentItemFrame:SetSize(w * .13, h * .11)
				currentItemFrame:MoveRightOf(frame, 10)
				currentItemFrame:MoveAbove(frame, -currentItemFrame:GetTall())
				currentItemFrame:SetTitle("Currently Producing")

				local currentItem = vgui.Create("nutSpawnIcon", currentItemFrame)
				currentItem:SetModel(curItem and curItem.model or "models/props_c17/streetsign004e.mdl")
				currentItem:SetSize(w * 0.039, ScrH() * 0.069)
				currentItem:SetPos(0, 25)

				local currentItemLabel = vgui.Create("UI_DLabel", currentItemFrame)
				currentItemLabel:SetText(curItem and curItem.name or "Nothing")
				currentItemLabel:SetPos(currentItem:GetPos())
				currentItemLabel:SizeToContents()
				currentItemLabel:MoveRightOf(currentItem, 5)

	
				local currentItemButton = vgui.Create("DButton", currentItemFrame)
				currentItemButton.Paint = ButtonPaint
				currentItemButton:SetPos(currentItemLabel:GetPos())
				currentItemButton:MoveBelow(currentItemLabel, 5)
				currentItemButton:SetText("Inventory")
				currentItemButton:SetSize(w * 0.059, (h * 0.0694) - currentItemLabel:GetTall())
				currentItemButton:SetTextColor(nut.gui.palette.text_primary)
				currentItemButton:SetExpensiveShadow(1, Color(0, 0, 0))
				currentItemButton:SetFont("UI_Regular")
				currentItemButton.Paint = ButtonPaint
				currentItemButton.OnCursorEntered = function(self)
					self:SetTextColor(hoverColor)
					surface.PlaySound("fallout/ui/ui_focus.wav")
				end
				currentItemButton.OnCursorExited = function(self)
					self:SetTextColor(nut.gui.palette.text_primary)
				end
				currentItemButton.DoClick = function()
					net.Start("WBRequestInv")
						net.WriteEntity(ent)
					net.SendToServer()
				end

				local close = vgui.Create("UI_DButton", frame)
				close:Dock(BOTTOM)
				close:SetText("Close")
				close:SetContentAlignment(5)
				close.DoClick = function(self)
					frame:Close()
					currentItemFrame:Close()
				end

				if LocalPlayer() == ent:GetOwnership() then
					local factionAccessToggle = vgui.Create("UI_DButton", frame)
					factionAccessToggle:Dock(BOTTOM)
					factionAccessToggle:SetText("Faction access toggle")
					factionAccessToggle:SetContentAlignment(5)

					factionAccessToggle.Think = function()
						factionAccessToggle:SetText(ent:GetFactionAccess() and "Turn off faction access" or "Turn on faction access")
					end

					factionAccessToggle.DoClick = function()
						net.Start("WBFactionAccessToggle")
							net.WriteEntity(ent)
						net.SendToServer()
					end
				end

				local scroll = vgui.Create("DScrollPanel", frame)
				scroll:SetSize(w * .2083, LocalPlayer() == ent:GetOwnership() and (h * .675) or (h * .648))
				scroll:SetPos(0, h * .0370)

				local scrollBar = scroll:GetVBar()
				scrollBar:SetHideButtons(true)
				scrollBar.Paint = function() end
				scrollBar.btnGrip.Paint = function(s, w, h)
					if s.Depressed then
						surface.SetDrawColor(hoverColor)
					else
						surface.SetDrawColor(c)
					end
					surface.DrawRect(0, 0, w, h)
				end

				local i = 0
				local mW = w * 0.0390
				local mH = h * 0.0694
				for k, v in pairs(ent:getNetVar("output", {})) do
					local item = nut.item.list[k]
					local time = v
					local model = item.model
					local name = item.name

					local modelPanel = vgui.Create("nutSpawnIcon", scroll)
					modelPanel:SetModel(model)
					modelPanel:SetSize(mW, mH)
					modelPanel:SetPos(0, (mH + 5) * i)

					local label = vgui.Create("UI_DLabel", scroll)
					label:SetText(name)
					label:SetPos(modelPanel:GetPos())
					label:SizeToContents()
					label:MoveRightOf(modelPanel, 5)

					local button = vgui.Create("DButton", scroll)
					button:SetPos(label:GetPos())
					button:MoveBelow(label, 5)
					button:SetText("Produce")
					button:SetSize(w * .0598, mH - label:GetTall())
					button:SetTextColor(nut.gui.palette.text_primary)
					button:SetExpensiveShadow(1, Color(0, 0, 0))
					button:SetFont("UI_Bold")
					button.Paint = ButtonPaint
					button.OnCursorEntered = function(self)
						self:SetTextColor(hoverColor)
						surface.PlaySound("fallout/ui/ui_focus.wav")
					end
					button.OnCursorExited = function(self)
						self:SetTextColor(nut.gui.palette.text_primary)
					end
					button.DoClick = function()
						net.Start("WBIC-ChangeProduction")
							net.WriteEntity(ent)
							net.WriteString(k)
						net.SendToServer()

						currentItemLabel:SetText(name)
						currentItemLabel:SizeToContents()
						currentItem:SetModel(model)
					end

					i = i + 1

					local timeLabel = vgui.Create("UI_DLabel", scroll)
					timeLabel:SetText("Production Time: " .. time .. "s")
					timeLabel:SetPos(label:GetPos())
					timeLabel:MoveBelow(label)
					timeLabel:MoveRightOf(button, 5)
					timeLabel:SizeToContents()
				end
			end
		end,
		["produce"] = function(ent)
			local curItems = ent:getNetVar("inventory", {})
			if jlib.TableSum(curItems) < (math.Round(ent:GetInvX()) * math.Round(ent:GetInvY())) then
				curItems[ent:GetOutput()] = (curItems[ent:GetOutput()] or 0) + 1
				ent:setNetVar("inventory", curItems)
			end
		end,
		["lockpicked"] = function(ent, lockpicker)
			ent:OpenInventory(lockpicker)
		end
	}
}

--Run all init functions
if SERVER then
	for id, core in pairs(Workbenches.Cores) do
		if isfunction(core.sv_init) then
			core.sv_init()
		end
	end
else
	for id, core in pairs(Workbenches.Cores) do
		if isfunction(core.cl_init) then
			core.cl_init()
		end
	end
end

--NS Init
hook.Add("InitPostEntity", "WBNSInit", function()
	nut.command.add("recipemaker", {
		superAdminOnly = true,
		onRun = function(ply, args)
			net.Start("WBOpenRecipeMaker")
			net.Send(ply)
		end
	})

	nut.command.add("recipemanager", {
		superAdminOnly = true,
		onRun = function(ply, args)
			net.Start("WBOpenRecipeManager")
			net.Send(ply)
		end
	})

	nut.command.add("giverecipemats", {
		superAdminOnly = true,
		onRun = function(ply, args)
			local ingredients = Workbenches.Recipes[args[1]].ingredients

			local inv = ply:getChar():getInv()

			for k,v in pairs(ingredients) do
				for i = 1, v do
					inv:add(k)
				end
			end
		end
	})

	nut.command.add("workbench_data", {
		adminOnly = true,
		onRun = function(ply)
			local entity = ply:GetEyeTrace().Entity

			if !IsValid(entity) or entity:GetClass() != "workbench" then
				ply:notify("Target entity is not a workbench")
				return
			end

			jlib.Announce(ply,
				Color(0,255,0), "[WORKBENCH] ", Color(155,255,155), "Information:",
				Color(255,255,255), "\n· FACTION: " .. (entity:getNetVar("faction") or "Public Access") ..
				"\n· CLASSES:"
			)

			if entity:getNetVar("classes") then
				for k, v in pairs(entity:getNetVar("classes")) do
					ply:ChatPrint("	|_ " .. k)
				end
			else
				ply:ChatPrint("	|_ Public Access")
			end
		end
	})
end)

--Workbench initial setup menu
function Workbenches.OpenConfigMenu(ply, bench)
	if !ply:IsSuperAdmin() then
		ply:notify("A superadmin must first configure this workbench!")
		return
	end

	if SERVER then
		net.Start("WBOpenConfig")
			net.WriteEntity(bench)
		net.Send(ply)
	else
		local frame = vgui.Create("DFrame")
		frame:SetTitle("Config")
		frame:SetSize(800, 600)
		frame:MakePopup()
		frame:Center()
		frame:SetBackgroundBlur(true)

		local panel = frame:Add("DPanel")
		panel:SetSize(200, 0)
		panel:SetPaintBackground(false)

		local workbenchType = panel:Add("DComboBox")
		workbenchType:SetText("Workbench Type")
		workbenchType:SetWide(150)
		workbenchType:SetContentAlignment(5)
		workbenchType:CenterHorizontal()

		for name, core in pairs(Workbenches.Cores) do
			workbenchType:AddChoice(name, core)
		end

		local name = panel:Add("DTextEntry")
		name:SetPlaceholderText("Name")
		name:SetWide(150)
		name:CenterHorizontal()
		name:MoveBelow(workbenchType, 5)

		local model = panel:Add("DTextEntry")
		model:SetPlaceholderText("Model")
		model:SetWide(150)
		model:CenterHorizontal()
		model:MoveBelow(name, 5)

		local capturable = panel:Add("DCheckBoxLabel")
		capturable:SetText("Capturable")
		capturable:SetWide(150)
		capturable:CenterHorizontal()
		capturable:MoveBelow(model, 5)

		local display3D2D = panel:Add("DCheckBoxLabel")
		display3D2D:SetText("Display 3D2D")
		display3D2D:SetWide(150)
		display3D2D:CenterHorizontal()
		display3D2D:MoveBelow(capturable, 5)

		local color3D2D = panel:Add("DColorButton")
		color3D2D:SetText("3D2D Color")
		color3D2D:SetWide(150)
		color3D2D:SetTall(20)
		color3D2D:SetContentAlignment(5)
		color3D2D:CenterHorizontal()
		color3D2D:SetColor(Color(160, 160, 160, 255))
		color3D2D:MoveBelow(display3D2D, 5)
		color3D2D.DoClick = function(s)
			local picker = frame:Add("DFrame")
			picker:SetTitle("Pick Color")
			picker:SetSize(300, 200)
			picker:Center()

			local mixer = picker:Add("DColorMixer")
			mixer:Dock(FILL)
			mixer:SetPalette(false)
			mixer:SetColor(color3D2D:GetColor())

			picker.OnClose = function()
				color3D2D:SetColor(mixer:GetColor())
			end
		end

		local chooseFactionButton = panel:Add("DButton")
		chooseFactionButton:SetText("Choose Faction")
		chooseFactionButton:SetWide(150)
		chooseFactionButton:CenterHorizontal()
		chooseFactionButton:MoveBelow(color3D2D, 5)
		chooseFactionButton.DoClick = function(s)
			local f = vgui.Create("DFrame")
			f:SetTitle("Select Faction")
			f:SetSize(800, 600)
			f:Center()
			f:MakePopup()

			local factionsScroll = vgui.Create("DScrollPanel", f)
			factionsScroll:SetSize(200, 500)
			factionsScroll:Center()

			local i = 0
			for k, v in pairs(nut.faction.indices) do
				local button = vgui.Create("DButton", factionsScroll)
				button:SetText(v.name)
				button:SizeToContents()
				button:SetPos(factionsScroll:GetWide() / 2 - button:GetWide() / 2, i * (button:GetTall() + 5))
				button:SetTextColor(Color(235, 235, 235, 255))
				button.DoClick = function()
					chooseFactionButton.faction = v.uniqueID
					factionsScroll:Clear()

					local classes = {}

					for _, c in pairs(nut.class.list) do
						if c.faction == v.index then
							table.insert(classes, c)
						end
					end

					local selection = {}

					local j = 0
					for _, c in pairs(classes) do
						local b = vgui.Create("DButton", factionsScroll)
						b:SetText(c.name)
						b:SizeToContents()
						b:SetPos(factionsScroll:GetWide() / 2 - b:GetWide() / 2, j * (b:GetTall() + 5))
						b:SetTextColor(Color(235, 235, 235, 255))
						b.DoClick = function()
							if b.selected then
								b.selected:Remove()
								b.selected = nil

								selection[c.uniqueID] = nil

								chooseFactionButton.classes = selection
							else
								b.selected = vgui.Create("DImage", factionsScroll)
								b.selected:SetPos(b:GetPos())
								b.selected:MoveRightOf(b, 3)
								b.selected:SetImage("icon16/tick.png")
								b.selected:SizeToContents()

								selection[c.uniqueID] = true

								chooseFactionButton.classes = selection
							end
						end

						j = j + 1
					end
				end

				i = i + 1
			end
		end

		local sound = panel:Add("DTextEntry")
		sound:SetPlaceholderText("Sound")
		sound:SetWide(150)
		sound:CenterHorizontal()
		sound:MoveBelow(chooseFactionButton, 5)
		sound.OnChange = function(s)
			s.ValidSound = false

			if !s:GetText() or s:GetText() == "" then
				return
			end

			for i, f in ipairs(file.Find("sound/" .. s:GetText(), "GAME")) do
				s.ValidSound = true
				nut.util.notify("Valid sound path selected.")
				return
			end
		end

		local lockpickable = panel:Add("DCheckBoxLabel")
		lockpickable:SetText("Lockpickable")
		lockpickable:SetWide(150)
		lockpickable:CenterHorizontal()
		lockpickable:MoveBelow(sound, 5)
		lockpickable.OnChange = function(s, bool)
			if bool then
				local level = panel:Add("DNumberWang")
				level:SetWide(150)
				level:CenterHorizontal()
				level:SetText("Lockpick level")
				level:MoveBelow(lockpickable, 5)
				level:SetMinMax(1, 3)

				s.LockpickLevel = level

				panel:SizeToChildren(false, true)
				panel:Center()
			else
				s.LockpickLevel:Remove()

				panel:SizeToChildren(false, true)
				panel:Center()
			end
		end

		panel:SizeToChildren(false, true)
		panel:Center()

		local choosePresetButton = frame:Add("DButton")
		choosePresetButton:SetText("Choose Preset")
		choosePresetButton:Dock(BOTTOM)

		choosePresetButton.DoClick = function(s)
			net.Start("WBRequestPresets")
				net.WriteEntity(bench)
			net.SendToServer()

			frame:Close()
		end

		local nextButton = frame:Add("DButton")
		nextButton:SetText("Next")
		nextButton:Dock(BOTTOM)
		nextButton:SetDisabled(true)

		nextButton.Think = function(s)
			if name:GetValue() != "" and model:GetValue() != "" and workbenchType:GetSelected() then
				nextButton:SetDisabled(false)
			else
				nextButton:SetDisabled(true)
			end
		end

		nextButton.DoClick = function(s)
			local coreID, core = workbenchType:GetSelected()
			local options = {
				name = name:GetValue(),
				model = model:GetValue(),
				color = color3D2D:GetColor(),
				coreID = coreID,
				capturable = capturable:GetChecked() or false,
				display3D2D = display3D2D:GetChecked() or false,
				lockpickable = lockpickable:GetChecked() or false,
				LockpickLevel = lockpickable:GetChecked() and lockpickable.LockpickLevel:GetValue() or nil,
				faction = chooseFactionButton.faction,
				classes = chooseFactionButton.classes,
				sound = sound.ValidSound and sound:GetText() or nil
			}

			s:Remove()
			choosePresetButton:Remove()
			panel:Clear()

			core.config(panel, options, bench)
		end
	end
end
if CLIENT then
	net.Receive("WBOpenConfig", function()
		Workbenches.OpenConfigMenu(LocalPlayer(), net.ReadEntity())
	end)
end

--Preset handling
function Workbenches.SavePreset(key, options)
	if SERVER then
		Workbenches.Presets[key] = options
		Workbenches.SavePresets()
	end

	if CLIENT then
		net.Start("WBSavePreset")
			net.WriteString(key)
			jlib.WriteCompressedTable(options)
		net.SendToServer()
	end
end
if SERVER then
	net.Receive("WBSavePreset", function(_, ply)
		if !ply:IsSuperAdmin() then return end

		local key = net.ReadString()
		local options = jlib.ReadCompressedTable()

		Workbenches.SavePreset(key, options)
	end)
end

local function WBIsOfficer(ply, ent) -- Is the player either an acceptable officer or a superadmin
	if ent:GetClass() != "workbench" then return false end
	return ent:getNetVar("faction") and ent:getNetVar("faction") == nut.faction.indices[ply:Team()].uniqueID and hcWhitelist.isHC(ply) or ply:IsSuperAdmin()
end

--Workbench removal option
properties.Add("WBRemove", {
	["MenuLabel"] = "[ADMIN] Delete from Database",
	["MenuIcon"] = "icon16/cancel.png",
	["Order"] = 10000,
	["Filter"] = function(self, ent, ply)
		return ent:GetClass() == "workbench" and ply:IsSuperAdmin()
	end,
	["Action"] = function(self, ent, tr)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	["Receive"] = function(self, len, ply)
		if !ply:IsSuperAdmin() then return end

		local ent = net.ReadEntity()
		local index = ent.benchID

        if !index or !ent:GetConfigured() then
			ply:notify("Storage never was saved; removing!")
			ent:Remove()
			return
		end

		jlib.RequestBool("This will FULLY delete the entity & data", function(bool)
			if !bool then return end
			jlib.RequestBool("This includes all items within! Continue?", function(bool2)
				if !bool2 then return end
				jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(255,255,255), " You deleted the workbench from the database")
				ply:notify("Workbench deleted from database")
				ent:EmitSound("ui/ui_items_gunsbig_down.mp3")

				local pos = ent:GetPos()
				local effectdata = EffectData()
				effectdata:SetOrigin( pos )
				util.Effect( "flash_smoke", effectdata )

				if ply:IsSuperAdmin() then
					DiscordEmbed(jlib.SteamIDName(ply) .. " has FULLY DELETED workbench (" .. (Workbenches.Benches[index].name or index) .. ") from the database", "Workbench Deletion Log" , Color(255,0,0), "Admin")
					Workbenches.RemoveBench(index)
					ent:Remove()
				end

			end, ply, "YES (DELETE)", "NO (CANCEL)")
		end, ply, "DELETE", "CANCEL")
	end
})

/**
--Workbench removal option
properties.Add("Remove", {
	["MenuLabel"] = "Remove",
	["MenuIcon"] = "icon16/cancel.png",
	["Order"] = 10000,
	["Filter"] = function(self, ent)
		return !(ent:GetClass() == "workbench" or ent:GetClass() == "faction-storage")
	end,
	["Action"] = function(self, ent, tr)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	["Receive"] = function(self, len, ply)
		if !ply:IsSuperAdmin() then return end

		local ent = net.ReadEntity()
		ent:Remove()
	end
})
**/

--Update pos option
properties.Add("WBUpdate", {
	["MenuLabel"] = "Save position",
	["MenuIcon"] = "icon16/arrow_refresh.png",
	["Order"] = 10001,
	["Filter"] = function(self, ent, ply)
		return WBIsOfficer(ply, ent)
	end,
	["Action"] = function(self, ent, tr)
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	["Receive"] = function(self, len, ply)
		local ent = net.ReadEntity()
		local index = ent.benchID

		jlib.RequestBool("Save current workbench position?", function(bool)
			if !bool then return end

			ply:SelectWeapon("nut_hands" or ply:GetWeapons()[1]) -- Addresses a physgun click annoyance issue
			jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(0,255,0), " Succesfully ", Color(255,255,155), "saved workbench position!", Color(255,255,255), "\n· Your workbench will now remain here until stowed")
			ply:notify("Workbench postion saved")
			ent:EmitSound("ui/ui_items_gunsbig_up.mp3")
			Workbenches.Benches[index].pos = ent:GetPos()
			Workbenches.Benches[index].angles = ent:GetAngles()
			Workbenches.SaveBenches()

			ply:ChatPrint((Workbenches.Benches[index].name or index))

			DiscordEmbed(jlib.SteamIDName(ply) .. " has saved a workbench (" .. (Workbenches.Benches[index].name or index) .. ") into the world", "Workbench Save Log" , Color(255,255,0), "Admin")

		end, ply, "YES (SAVE)", "NO (CANCEL)")

	end
})

properties.Add("WBStow", {
    ["MenuLabel"] = "Stow in Armory",
    ["MenuIcon"] = "icon16/door_in.png",
    ["Order"] = 10002,
    ["Filter"] = function(self, ent, ply)
		return WBIsOfficer(ply, ent)
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        local ent = net.ReadEntity()
        local index = ent.benchID

        if !index then
			ply:notify("Can't stow an unconfigured workbench")
			return
		end

		jlib.RequestBool("Stow your workbench?", function(bool)
			if !bool then return end
			jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(0,255,0), " Succesfully ", Color(255,255,155), "stowed workbench!", Color(255,255,255), "\n· Your workbench and it's items can be re-deployed via the /factionmanagement menu")
			ply:notify("Workbench has been stowed")
			ent:EmitSound("ui/ui_items_gunsbig_down.mp3")

			local pos = ent:GetPos()
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			util.Effect( "flash_smoke", effectdata )

			ent:Remove()

			DiscordEmbed(jlib.SteamIDName(ply) .. " has stowed a workbench (" .. (Workbenches.Benches[index].name or index) .. ") into their faction armory", "Workbench Stow Log" , Color(255,255,0), "Admin")
		end, ply, "YES (STOW)", "NO (CANCEL)")

    end
})

--Support for using a player as a workbench
local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

function PLAYER:GetBenchName()
	return "Personal Crafting"
end

function PLAYER:GetMaxCrafts()
	return Workbenches.Config.MaxPlayerCrafts
end

function PLAYER:getNetVar(key, default)
	if key == "outputs" then
		return Workbenches.Config.PlayerRecipes
	end

	return ENTITY.getNetVar(self, key, default)
end

for key, func in pairs(Workbenches.Cores.Multicraft.EntFuncs) do
	if key != "Think" then
		PLAYER[key] = func
	end
end

if SERVER then
	hook.Add("PlayerInitialSpawn", "WorkbenchPlayerSupport", function(ply)
		local hookID = "WorkbenchPlayerSupport" .. ply:SteamID64()
		hook.Add("Think", hookID, function()
			if !IsValid(ply) then
				hook.Remove("Think", hookID)
				return
			end

			Workbenches.Cores.Multicraft.EntFuncs.Think(ply)
		end)
	end)
end

--Melter particles
game.AddParticles("particles/zrms_melter_vfx.pcf")

PrecacheParticleSystem("zrms_melter_coalpit")
PrecacheParticleSystem("zrms_melter_head")
PrecacheParticleSystem("zrms_melter_chimney")
PrecacheParticleSystem("zrms_melter_chimney")

--Deployable workbenches
hook.Add("InitPostEntity", "WBDeployables", function()
	for k, mdl in pairs(Workbenches.Config.Deployables) do
		local ITEM = nut.item.register("deployable_" .. string.Replace(k, " ", "_"):lower(), nil, false, nil, true)
		ITEM.name  = k
		ITEM.model = mdl
		ITEM.desc  = "A deployable " .. k

		ITEM.functions.Use = {
			onRun = function(item)
				local ply = item.player or item:getOwner()

				local preset = Workbenches.Presets[k]
				local options = table.Copy(preset)
				options.pos = ply:GetPos() + (ply:GetForward() * 100)
				options.angles = ply:EyeAngles()
				options.angles.p = 0
				options.angles.y = options.angles.y + 180

				local bench = Workbenches.SpawnBench(options, Workbenches.Cores[options.coreID], 0)

				hook.Run("PlayerSpawnedSENT", ply, bench)
			end
		}
	end
end)
