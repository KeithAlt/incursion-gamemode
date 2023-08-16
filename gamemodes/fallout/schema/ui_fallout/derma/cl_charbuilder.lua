local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.charBuilder)) then
			nut.gui.charBuilder:Remove()
		end

		nut.gui.charBuilder = self

		data = {desc = "An average wastelander traveling the wastes.", data = {}}

		self:Dock(FILL)
		self:MakePopup()
		self:Center()
		self:ParentToHUD()
	end;

	function PANEL:creator()
		data.data.gender = "male"

		local creator = self:Add("DPanel")
			creator:Dock(FILL)
			creator.Paint = function(p, w, h)
				surface.SetDrawColor(0, 0, 0)
				surface.DrawRect(0, 0, w, h)
			end;

			local preview = creator:Add("nutSpawnIcon")
				preview:SetSize(ScrW(), ScrH())

			models = creator:Add("UI_DFrame")
				models:Dock(RIGHT)
				models:DockMargin(0, 128, 96, 128)
				models:SetWidth(384)
				models:SetTitle(faction["name"]:upper().." ❱❱ CHOOSE MODEL")
				local scroll = models:Add("DScrollPanel")
					scroll:Dock(FILL)
					scroll:DockMargin(0, 0, 0, 12)

			local function populateModels()
				scroll:Clear()

				for i, v in pairs(faction["mdls"][data.data.gender]) do
					local button = scroll:Add("UI_DButton")
						button:Dock(TOP)
						button:DockMargin(0, 0, 0, 12)
						if (istable(v)) then
							button:SetText("  "..v[2])
						else
							local t = string.Split(v, "/")
								t = string.Split(t[#t], ".")
							button:SetText("  "..t[1])
						end;
						button.DoClick = function()
							if (istable(v)) then
								data.model = v[1]
								preview:SetModel(v[1])
							else
								data.model = v
								preview:SetModel(v)
							end;
							preview:SetCursor("none")
							preview:SetFOV(24)
							preview:SetCamPos(preview:GetCamPos() + Vector(0, -1, 1))
							for i = 1, 5 do preview:SetDirectionalLight(i, Color(50, 50, 50)) end;
							local ent = preview.Entity
							ent:SetAngles(Angle(0, -20, 0))
							ent:SetEyeTarget(Vector(0, 0, 67))
						end;

						if (scroll:ChildCount() == 2) then button.DoClick() end;
				end;
			end;

			buttons = creator:Add("UI_DPanel_Horizontal")
				buttons:SetSize(640, 44)
				buttons:DockPadding(6, 6, 6, 6)
				buttons:SetPos((ScrW() * 0.5) - 320, ScrH() - 128)
				local back = buttons:Add("UI_DButton")
					back:Dock(LEFT)
					back:DockMargin(0, 0, 6, 0)
					back:SetText("  RETURN  ")
					back:SizeToContentsX()
					back.DoClick = function()
						fadeOut(function()
							vgui.Create("nutCharCreate")
							self:Remove()
						end)
					end;
				local sex = buttons:Add("UI_DButton")
					sex:Dock(LEFT)
					sex:SetText("  SEX  ")
					sex:SizeToContentsX()
					if (!faction["mdls"]["female"]) then sex:SetDisabled(true) end;
					sex.DoClick = function()
						if (data.data.gender == "male") then
							data.data.gender = "female"
						else
							data.data.gender = "male"
						end;

						populateModels()
					end;
				local skin = buttons:Add("UI_DButton")
					skin:Dock(LEFT)
					skin:SetText("  SKIN  ")
					skin:SizeToContentsX()
					if (!faction["canCustomize"]) then skin:SetDisabled(true) end;
					skin.DoClick = function()
						local ent = preview.Entity
						if (ent:GetSkin() >= ent:SkinCount()) then
							ent:SetSkin(1)
							data.data.skin = 1
						else
							ent:SetSkin(ent:GetSkin() + 1)
							data.data.skin = ent:GetSkin()
						end;
					end;
				local next = buttons:Add("UI_DButton")
					next:Dock(RIGHT)
					next:SetText("  CONTINUE  ")
					next:SizeToContentsX()
					next.DoClick = function()
						models:Hide()
						buttons:Hide()
						self:name()
					end;

		populateModels()

		fadeIn()
	end;

	function PANEL:name()
		local function generateName()
			local f = {
				"Addison", "Ashley", "Arron", "Bailey", "Blaine",
				"Casey", "Corey", "Darren", "Emerson", "Evan", "Florian",
				"Haiden", "Hayley", "Jamie", "Jesse", "Kiley",
				"Kerry", "Kelsey", "London", "Lee", "Lonnie",
				"Marley", "Morgan", "MacKenzie", "Payton", "Parker",
				"Reese", "Reed", "Robin", "Regan", "Sean",
				"Skylar", "Skye", "Sydney", "Shay", "Silver",
				"Taylor", "Tory", "Tyne", "Weasley", "Wynne",
			}

			local l = {
				"Smith", "Jones", "Brown", "Johnson", "Williams",
				"Miller", "Taylor", "Wilson", "Davis", "White",
				"Clark", "Hall", "Thomas", "Thompson", "Moore",
				"Hill", "Walker", "Anderson", "Wright", "Martin",
				"Wood", "Allen", "Robinson", "Lewis", "Scott",
				"Young", "Jackson", "Adams", "Tryniski", "Green",
				"Evans", "King", "Baker", "John", "Harris",
				"Roberts", "Campbell", "James", "Stewart", "Lee",
			}

			return table.Random(f), table.Random(l)
		end;

		local bg = self:Add("DPanel")
			bg:SetSize(ScrW(), ScrH())
			bg.Paint = function(p, w, h)
				nut.util.drawBlur(p, 5)
				surface.SetDrawColor(0, 0, 0, 235)
				surface.DrawRect(0, 0, w, h)
			end;
		name = self:Add("UI_DFrame")
			name:MakePopup()
			name:SetSize(512, 166)
			name:SetPos((ScrW() * 0.5) - 256, (ScrH() * 0.5) - 83)
			name:SetTitle(faction["name"]:upper().." ❱❱ NAME CHARACTER")
			local t1 = name:Add("DPanel")
				t1:Dock(TOP)
				t1:DockMargin(0, 0, 0, 12)
				t1:SetHeight(32)
				t1:SetPaintBackground(false)
				local l1 = t1:Add("UI_DLabel")
					l1:Dock(LEFT)
					l1:SetText("First Name:")
					l1:SizeToContentsX()
				first = t1:Add("UI_DTextEntry")
					first:Dock(RIGHT)
					first:SetWidth(384)
			local t2 = name:Add("DPanel")
				t2:Dock(TOP)
				t2:DockMargin(0, 0, 0, 12)
				t2:SetHeight(32)
				t2:SetPaintBackground(false)
				local l2 = t2:Add("UI_DLabel")
					l2:Dock(LEFT)
					l2:SetText("Last Name:")
					l2:SizeToContentsX()
				last = t2:Add("UI_DTextEntry")
					last:Dock(RIGHT)
					last:SetWidth(384)
			local t3 = name:Add("DPanel")
				t3:Dock(TOP)
				t3:DockMargin(0, 0, 0, 12)
				t3:SetHeight(32)
				t3:SetPaintBackground(false)
				local back = t3:Add("UI_DButton")
					back:Dock(LEFT)
					back:SetWidth(238)
					back:SetText("RETURN")
					back:SetContentAlignment(5)
					back.DoClick = function()
						models:Show()
						buttons:Show()
						bg:Remove()
						name:Remove()
					end;
				local complete = t3:Add("UI_DButton")
					complete:Dock(RIGHT)
					complete:SetWidth(238)
					complete:SetText("COMPLETE")
					complete:SetContentAlignment(5)
					complete.DoClick = function()
						local f, l = first:GetText(), last:GetText()

						if (f:find("%s") or l:find("%s")) then
							Derma_Message("Your character name cannot contain any spaces.", nil, "OK")
							return
						elseif (f:find("%d") or l:find("%d")) then
							Derma_Message("Your character name cannot contain any numbers.", nil, "OK")
							return
						elseif (f:find("%p") or l:find("%p")) then
							Derma_Message("Your character name cannot contain any punctuation.", nil, "OK")
							return
						elseif(f:len() < 1 or l:len() < 1) then
							Derma_Message("Your character's first or last name cannot be blank.", nil, "OK")
							return
						elseif ((f:len() + l:len()) < 5) then
							Derma_Message("Your character's name cannot be shorter than five letters.", nil, "OK")
							return
						elseif ((f:len() + l:len()) > 24) then
							Derma_Message("Your character's name cannot be longer than twenty four letters.", nil, "OK")
							return
						end;

						data.name = f:lower():gsub("^%l", string.upper).." "..l:lower():gsub("^%l", string.upper)

						for i, v in pairs(faction["models"]) do
							if (data.model == v) then
								data.model = i
								break
							end;
						end;

						name:Hide()

						local creating = self:Add("UI_DLabel")
							creating:SetSize(ScrW(), ScrH())
							creating:SetContentAlignment(5)
							creating:SetText("Creating Character...")
							creating:SetFont("UI_Bold")

						netstream.Hook("charAuthed", function(fault, ...)
							timer.Remove("nutCharTimeout")

							if (type(fault) == "string") then
								creating:Remove()
								name:Show()
								name:MakePopup()
								Derma_Message("ERROR: "..fault, nil, "OK")
								return
							end;

							if (type(fault) == "table") then
								nut.characters = fault
							end;

							creating:SetText("Character Created!")

							fadeOut(function()
								vgui.Create("nutCharMenu"):open()
								self:Remove()
							end)
						end)

						timer.Create("nutCharTimeout", 20, 1, function()
							if (IsValid(nut.gui.charBuilder)) then
								creating:Remove()
								name:Show()
								name:MakePopup()
								Derma_Message("The character creation timed out, please try again.", nil, "OK")
							end;
						end)

						netstream.Start("charCreate", data)
					end;

			local f, l = generateName()
				first:SetText(f)
				last:SetText(l)
	end;

	function PANEL:open(f)
		data.faction = f

		faction = nut.faction.indices[f]

		self:creator()
	end;

	function PANEL:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 235)
		surface.DrawRect(0, 0, w, h)
	end;

vgui.Register("nutCharBuilder", PANEL, "EditablePanel")
