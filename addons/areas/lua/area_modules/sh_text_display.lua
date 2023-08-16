-- This will show text upon entering an area. Other modules also use it to display expanded text, such as the capture module.

Areas.Text = Areas.Text or {}
Areas.Text.Print = jlib.GetPrintFunction("[AreasText]", Color(128, 0, 128, 255))
Areas.Text.Time = 10
Areas.Text.Msg = "LEAVE RESTRICTED AREA"
Areas.AddVar("Text", "Bool", true, false)

if CLIENT then
	function Areas.Text.Start(area)
		if(istable(area) and (!area:GetFactionUID() or area:GetFactionUID() == "")) then
			-- Strings to display
			local displayString = {
				{
					(area:GetName() or "Unnamed"),
					nut.config.get("color"),
					"nutAreaDisplay",
				}
			}

			Areas.Text.DisplayImage(area, "") -- Resets image since there shouldn't be one.
			Areas.Text.DisplayText(area, displayString, Color(255,255,255))
		end
	end

	function Areas.Text.Stop(area)

	end

	hook.Add("PlayerEnteredArea", "AreaText", function(ply, area)
		--if ply == LocalPlayer() and area:GetOutOfBounds() then
		if ply == LocalPlayer() then
			Areas.Text.Start(area)
		end
	end)

	hook.Add("PlayerLeftArea", "AreaText", function(ply, area)
		--if ply == LocalPlayer() and area:GetOutOfBounds() then
		if ply == LocalPlayer() then
			Areas.Text.Stop(area)
		end
	end)

	hook.Add("HUDPaint", "AreaText", function()
		-- FIXME
	end)

	-- Configureable values.
	local speed = 1
	local targetScale = 0
	local dispString = {}
	local tickSound = "ui/char" .. math.random(1,5)..".wav"
	local dieTime = 7

	local dispImage = ""

	-- Non configureable values.
	local scale = 0
	local flipTable = {}
	local powTime = RealTime()*speed
	local curChar = 0
	local dieTrigger = false
	local dieTimer = RealTime()
	local dieAlpha = 0
	local ft, w, h, dsx, dsy
	local dispTextCol

	function Areas.Text.DisplayText(area, text, textColor)
		speed = nut.config.get("areaDispSpeed")
		targetScale = 1
		dispString = text or area.text or "Test"
		--dispTextCol = textColor or Color(255,255,255)
		dieTime = time or 8

		scale = targetScale * .5
		flipTable = {}
		powTime = RealTime()*speed
		curChar = 0
		dieTrigger = false
		dieTimer = RealTime()
		dieAlpha = 255
	end

	function Areas.Text.DisplayImage(area, image)
		dispImage = image
	end

	-- This is all from the nutscript area plugin, used for text
	local function drawMatrixString(str, font, x, y, scale, angle, color)
		surface.SetFont(font)
		local tx, ty = surface.GetTextSize(str)

		local matrix = Matrix()
		matrix:Translate(Vector(x, y, 1))
		matrix:Rotate(angle or Angle(0, 0, 0))
		matrix:Scale(scale)

		cam.PushModelMatrix(matrix)
			surface.SetTextPos(2, 2)
			surface.SetTextColor(color or Color(255,151,0))
			surface.DrawText(str)
		cam.PopModelMatrix()
	end

	hook.Add("RenderScreenspaceEffects", "AreasText", function()
		-- values
		if ((hook.Run("CanDisplayArea") == false) or (dieTrigger and dieTimer < RealTime() and dieAlpha <= 1)) then
			return
		end

		ft = FrameTime()
		w, h = ScrW(), ScrH()

		for k, stringData in pairs(dispString) do
			local message = stringData[1]
			local stringColor = stringData[2] or Color(255,255,255)
			local stringFont = stringData[3] or "nutAreaDisplay"

			local messageYOffset = k-1
			if(!message) then continue end

			dsx, dsy = 0

			local strEnd = string.utf8len(message)
			local rTime = RealTime()

			surface.SetFont(stringFont)
			local sx, sy = surface.GetTextSize(message)

			-- Number of characters to display.
			local maxDisplay = math.Round(rTime*speed - powTime)

			-- resize if it's too big.
			while (sx and sx*targetScale > w*.8) do
				targetScale = targetScale * .9
			end

			-- scale lerp
			scale = Lerp(ft*1, scale, targetScale)
			--scale = targetScale

			-- change event
			if (maxDisplay != curChar and curChar < strEnd) then
				curChar = maxDisplay
				if (string.utf8sub(message, curChar, curChar) != " ") then
					LocalPlayer():EmitSound(tickSound, 100, math.random(190, 200))
				end
			end

			-- draw recursive
			for i = 1, math.min(maxDisplay, strEnd) do
				-- character scale/color lerp
				flipTable[i] = flipTable[i] or {}
				flipTable[i][1] = flipTable[i][1] or .1
				--flipTable[i][1] = flipTable[i][1] or targetScale*3
				flipTable[i][2] = flipTable[i][2] or 0
				flipTable[i][1] = Lerp(ft*4, flipTable[i][1], scale)
				flipTable[i][2] = Lerp(ft*4, flipTable[i][2], 255)

				-- draw character.
				local char = string.utf8sub(message, i, i)
				local tx, ty = surface.GetTextSize(char)
				drawMatrixString(char,
					stringFont,
					math.Round(w/2 + dsx - (sx or 0)*scale/2),
					math.Round(h/3*1 - ((sy or 0) * messageYOffset*1.8)*scale/2),
					Vector(Format("%.2f", flipTable[i][1]), Format("%.2f", scale), 1),
					nil,
					Color(stringColor.r, stringColor.g, stringColor.b,
					(dieTrigger and dieTimer < RealTime()) and dieAlpha or flipTable[i][2])
				)

				-- next
				dsx = dsx + tx*scale
			end

			if (maxDisplay >= strEnd) then
				if (dieTrigger != true) then
					dieTrigger = true
					dieTimer = RealTime() + 2
				else
					if (dieTimer < RealTime()) then
						dieAlpha = Lerp(ft*4, dieAlpha, 0)
					end
				end
			end
		end

		if(dispImage != "") then
			surface.SetDrawColor(255,255,255,dieAlpha)
			surface.SetMaterial(dispImage)
			surface.DrawTexturedRect(w*0.4635, h*0.15, (w*0.073) * scale, (h*0.13) * scale)
		end
	end)

	surface.CreateFont("nutAreaDisplaySmall", {
		font = "Akbar",
		extended = true,
		size = ScreenScale(16),
		weight = 800,
		shadow = true,
	})

	net.Receive("AreasTextStart", Areas.Text.Start)
	net.Receive("AreasTextStop", Areas.Text.Stop)
else
	util.AddNetworkString("AreasTextStart")
	util.AddNetworkString("AreasTextStop")

	function Areas.Text.Start(ply)
		ply.InTextZone = true
	end

	function Areas.Text.Stop(ply)

	end

	hook.Add("PlayerEnteredArea", "Text", function(ply, area)

	end)

	hook.Add("PlayerLeftArea", "Text", function(ply, area)

	end)
end

hook.Add("InitPostEntity", "AreasTextEntry", function()

end)
