local PANEL = {}
	function PANEL:Init()
		self:SetSize(512 + 128, 512 + 128)
		self:Center()
		self:MakePopup()
		self:SetSkin("fallout")
		self:SetPaintBackground(false)

		recipes = {}
		category = {}

		local cB = self:Add("DPanel")
			cB:Dock(BOTTOM)
			cB:SetHeight(42)
			cB:DockPadding(6, 6, 6, 6)
		local closeButton = cB:Add("falloutButton")
			closeButton:Dock(FILL)
			closeButton:SetFont("falloutRegular")
			closeButton:SetText("Close")
			closeButton.DoClick = function()
				self:Remove()
			end;

		recipeList = self:Add("DPanel")
			recipeList:Dock(LEFT)
			recipeList:SetWidth(256)
			recipeList:DockMargin(0, 0, 16, 16)
			recipeList:DockPadding(6, 6, 6, 6)

			recipeScroll = recipeList:Add("DScrollPanel")
				recipeScroll:Dock(FILL)

		infoPanel = self:Add("DPanel")
			infoPanel:Dock(RIGHT)
			infoPanel:SetWidth(256 + 128 - 24)
			infoPanel:DockMargin(0, 0, 0, 16)
			infoPanel:DockPadding(6, 6, 6, 6)
	end;

	function PANEL:open(rec)
		local items = nut.item.list

		recipes = rec
		category = cate

		for i, v in pairs(recipes) do
			recipeScroll.i = recipeScroll:Add("falloutButton")
				recipeScroll.i:Dock(TOP)
				recipeScroll.i:SetHeight(24)
				recipeScroll.i:DockMargin(0, 0, 0, 6)
				recipeScroll.i:SetFont("falloutRegular")
				recipeScroll.i:SetExpensiveShadow(1, Color(0, 0, 0))
				recipeScroll.i:SetText(v["name"])
				recipeScroll.i.DoClick = function()
					infoPanel:Clear()

					craft = infoPanel:Add("falloutButton")
						craft:Dock(BOTTOM)
						craft:SetText("Craft")
						craft:SetHeight(24)
						craft:SetFont("falloutRegular")
						craft:SetExpensiveShadow(1, Color(0, 0, 0))
						craft.DoClick = function()
							print(i, v["category"])
							netstream.Start("completeCraft", v["category"], i)
							self:Remove()
						end;

					local model = infoPanel:Add("DModelPanel")
						model:Dock(TOP)
						model:SetModel(v["model"] or "models/hunter/blocks/cube025x025x025.mdl")
						model:SetHeight(128)

						local mn, mx = model.Entity:GetRenderBounds()
						local size = 0
						size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
						size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
						size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

						model:SetFOV(98)
						model:SetCamPos(Vector(size, size, size))
						model:SetLookAt((mn + mx) * 0.5)

					if (v["skill"]) then
						local skill = infoPanel:Add("DLabel")
							skill:SetText(" Required Skill: " .. nut.skerk.skerks[v["skill"]]["title"])
							skill:Dock(TOP)
							skill:SetFont("falloutRegular")
							skill:SetExpensiveShadow(1, Color(0, 0, 0))
							skill:SizeToContentsY()

							if (!LocalPlayer():hasSkerk(v["skill"])) then
								skill:SetTextColor(Color(255, 100, 100))
								if (craft) then craft:Remove() end;
							else
								skill:SetTextColor(Color(100, 255, 100))
							end;
					end;

					if v["intelligence"] and v["intelligence"] > 0 then
						local intelligence = LocalPlayer():getSpecial("I")

						local inti = infoPanel:Add("DLabel")
							inti:SetText(" Intelligence: "..v["intelligence"].." (Have "..intelligence..")")
							inti:Dock(TOP)
							inti:SetFont("falloutRegular")
							inti:SetExpensiveShadow(1, Color(0, 0, 0))
							inti:SizeToContentsY()

						if (intelligence < v["intelligence"]) then
							inti:SetTextColor(Color(255, 100, 100))
							if (craft) then craft:Remove() end;
						else
							inti:SetTextColor(Color(100, 255, 100))
						end
					end

					local mt1 = infoPanel:Add("DLabel")
						mt1:Dock(TOP)
						mt1:SetText(" Required Materials:")
						mt1:SetExpensiveShadow(1, Color(0, 0, 0))
						mt1:SetFont("falloutRegular")
						mt1:SizeToContentsY()

					for x, y in pairs(v["materials"]) do
						local t = infoPanel:Add("DLabel")
							t:Dock(TOP)
							t:SetFont("falloutRegular")
							t:SetExpensiveShadow(1, Color(0, 0, 0))

							if (y[1] > y[2]) then
								if (craft) then craft:Remove() end;
								t:SetTextColor(Color(255, 100, 100))
								t:SetText("     - "..y[1].."x "..items[x].name.." (Missing "..y[1] - y[2]..")")
							else
								t:SetTextColor(Color(100, 255, 100))
								t:SetText("     - "..y[1].."x "..items[x].name.." (Have "..y[2]..")")
							end;
					end;

					local mt2 = infoPanel:Add("DLabel")
						mt2:Dock(TOP)
						mt2:SetText(" Resulting Items:")
						mt2:SetFont("falloutRegular")
						mt2:SetExpensiveShadow(1, Color(0, 0, 0))
						mt2:SizeToContentsY()

					for x, y in pairs(v["results"]) do
						local t = infoPanel:Add("DLabel")
							t:Dock(TOP)
							t:SetFont("falloutRegular")
							t:SetExpensiveShadow(1, Color(0, 0, 0))
							t:SetText("     - "..y.."x "..items[x].name)
					end;
				end;
		end;
	end;

vgui.Register("nutCrafting", PANEL, "DPanel")
