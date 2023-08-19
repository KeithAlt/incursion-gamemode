--shared (I don't like this one bit)
local rschat = {
	hooks = {}
}

rschat.blacklist = { -- Blacklisted starting phrases
	[1] = "/",
	[2] = "!",
	[3] = "~",
	[4] = "//",
	[5] = "/w",
}
--cvars
do
	rschat.cvars = {
		svEnabled 	= CreateConVar("rschat_sv_enabled", 1, bit.bor(FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE), "Enable floating chat messages"),
		svEffects 	= CreateConVar("rschat_sv_effects", 1, bit.bor(FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE), "Allow effects for floating chat messages"),
		svHeight 	= CreateConVar("rschat_sv_height", 	8, bit.bor(FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE), "How far above players' heads messages should show")
	}
end

--effects (potential for custom ones too :))
--this is shared so we can look stuff up on the server
do
	rschat.fx 	= {
		white 	= { cat = 1 }, --no enums but 1 is color, 2 is moving
		red 	= { cat = 1 },
		yellow 	= { cat = 1 },
		green 	= { cat = 1 },
		cyan 	= { cat = 1 },
		purple 	= { cat = 1 },

		glow1 	= {
			cat = 1,
			fn 	= function(time)
				return HSVToColor((time / rschat.cvars.lifetime:GetFloat()) * 180, 1, 1)
			end
		},

		glow2 	= {
			cat = 1,
			fn 	= function(time)
				local frac = (time / rschat.cvars.lifetime:GetFloat())

				if(frac < 2 / 3) then
					return HSVToColor(360 - 120 * (frac / (2 / 3)), 1, 1)
				else
					return HSVToColor(240 + 120 * (3 * (frac - 2 / 3)), 1, 1)
				end
			end
		},

		glow3 	= {
			cat = 1,
			fn 	= function(time)
				local frac = (time / rschat.cvars.lifetime:GetFloat())

				if(frac < 1 / 3) then
					frac = frac * 3

					return Color(255 * (1 - frac), 255, 255 * (1 - frac))
				elseif(frac < 2 / 3) then
					frac = (frac - (1 / 3)) * 3

					return Color(255 * frac, 255, 255 * frac)
				else
					frac = (frac - (2 / 3)) * 3

					return Color(255 * (1 - frac), 255, 255)
				end
			end
		},

		flash1 	= {
			cat = 1,
			fn 	= function(time)
				return (math.floor(time * 5) % 2) == 0 and rschat.colors.yellow or rschat.colors.red
			end
		},

		flash2 	= {
			cat = 1,
			fn 	= function(time)
				return (math.floor(time * 5) % 2) == 0 and rschat.colors.blue or rschat.colors.cyan
			end
		},

		flash3 	= {
			cat = 1,
			fn 	= function(time)
				return (math.floor(time * 5) % 2) == 0 and rschat.colors.green or rschat.colors.green2
			end
		},

		scroll 	= {
			cat = 2,
			fn 	= function(time, i, x, y, w)
				local frac = (time / rschat.cvars.lifetime:GetFloat())

				--I kinda bsd the tileW/2 but it works so *shrug*
				return x + (w / 2) + 50 - (w + 100 + rschat.data.sheet.tileW / 2) * frac, y
			end
		},

		shake 	= {
			cat = 2,
			fn 	= function(time, i, x, y, w)
				local offset = math.abs(math.cos(time * 30 + i / 3)) * (rschat.data.sheet.tileH / 2)

				return x, y - offset * math.max((1 - time) * 2, 0)
			end
		},

		slide 	= {
			cat = 2,
			fn 	= function(time, i, x, y)
				local dur = rschat.cvars.lifetime:GetFloat()

				if(time < 0.5) then
					y = (-1 + time * 2) * rschat.data.sheet.tileH
				elseif(time > dur - 0.5) then
					y = ((time - dur + 0.5) * 2) * rschat.data.sheet.tileH
				end

				return x, y
			end
		},

		wave 	= {
			cat = 2,
			fn 	= function(time, i, x, y, w)
				return x, y - ((math.cos(time * 10 + i / 4) + 1) / 2) * (rschat.data.sheet.tileH / 2)
			end
		},

		wave2 	= {
			cat = 2,
			fn 	= function(time, i, x, y, w)
				local offset = ((math.cos(time * 10 + i / 4) + 1) / 2) * (rschat.data.sheet.tileH / 2)
				return x - offset, y - offset
			end
		},
	}
end

--shared because we dk if we're running on the server or client
rschat.fn = {}

rschat.fn.getEffects = function(str)
	local fx = {}

	--not sure if this is how runescape does it but oh well
	while(str:match("^([^:]+):")) do
		local effect = str:match("^([^:]+):"):lower()
		local data = rschat.fx[effect]
		if(data) then
			fx[data.cat] = effect

			str = str:sub(#effect + 2)
		else
			break
		end
	end

	return fx, str
end

--the big server side stuff
if(SERVER) then
	--addfile
	--resource.AddFile("materials/runescape/font2.vmt")
	-- resource.AddWorkshop("808687122")

	--network strings
	util.AddNetworkString("RSChat.addText")

	--suppressing chat effect text
	rschat.fn.sendMessage = function(ply, fx, str, filter)
		net.Start("RSChat.addText")
			net.WriteEntity(ply)
			net.WriteString(fx[1] or "")
			net.WriteString(fx[2] or "")
			net.WriteString(str)
		net.Send(filter)
	end

	--darkrp is dumb
	--and even better, we have to wait to check the variable :^)
	rschat.hooks.init = function()
		if(DarkRP) then
			rschat.cvars.svOOC = CreateConVar("rschat_sv_showooc", 1, bit.bor(FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE), "Whether or not to show messages for OOC chat")

			--fuck this is dumb
			local ttr = DarkRP.talkToRange
			local ttp = DarkRP.talkToPerson

			DarkRP.talkToRange = function(ply, name, msg, size)
				local str = msg

				if(rschat.cvars.svEnabled:GetBool()) then
					local fx = {}

					if(rschat.cvars.svEffects:GetBool()) then
						fx, str = rschat.fn.getEffects(msg)
					end

					--https://github.com/FPtje/DarkRP/blob/353dc3286092cdb2efade2cc0f2145db5a6c2e69/gamemode/modules/base/sv_util.lua#L49
					local filter = {}

					for k, v in pairs(ents.FindInSphere(ply:EyePos(), size)) do
						if(v:IsPlayer()) then
							filter[#filter + 1] = v
						end
					end

					rschat.fn.sendMessage(ply, fx, str, filter)
				end

				ttr(ply, name, str, size)
			end

			--what the fuck are these arguments
			DarkRP.talkToPerson = function(receiver, col1, text1, col2, msg, ply)
				local str = msg

				if(rschat.cvars.svEnabled:GetBool()) then
					if(col2 and msg and ply) then
						local fx = {}

						if(rschat.cvars.svEffects:GetBool()) then
							fx, str = rschat.fn.getEffects(msg)
						end

						--check for ooc (stupid)
						if not(!rschat.cvars.svOOC:GetBool() and text1:find(string.format("^%%(%s%%)", DarkRP.getPhrase("ooc")))) then
							rschat.fn.sendMessage(ply, fx, str, receiver)
						end
					end
				end

				ttp(receiver, col1, text1, col2, str, ply)
			end
		else
			rschat.hooks.PS = function(ply, text, team)
				if(rschat.cvars.svEnabled:GetBool()) then
					local fx = {}
					local str = text

					if(rschat.cvars.svEffects:GetBool()) then
						fx, str = rschat.fn.getEffects(text)
					end

					rschat.fn.sendMessage(ply, fx, str, player.GetAll())

					if(#fx > 0) then
						return str
					end
				end
			end

			hook.Add("PlayerSay", "RSChat.PS", rschat.hooks.PS)
		end
	end

	hook.Add("Initialize", "RSChat.I", rschat.hooks.init)

	--done
	return AddCSLuaFile()
end

--cvars
do
	rschat.cvars.clEnabled 	= CreateConVar("rschat_cl_enabled", 	1, bit.bor(FCVAR_CLIENTCMD_CAN_EXECUTE), "Enable floating chat messages")
	rschat.cvars.clEffects 	= CreateConVar("rschat_cl_effects", 	1, bit.bor(FCVAR_CLIENTCMD_CAN_EXECUTE), "Allow effects for floating chat messages")
	rschat.cvars.clHeight 	= CreateConVar("rschat_cl_height", 		8, bit.bor(FCVAR_CLIENTCMD_CAN_EXECUTE), "How far above players' heads messages should show")
	rschat.cvars.scale 		= CreateConVar("rschat_cl_scale", 		2, bit.bor(FCVAR_CLIENTCMD_CAN_EXECUTE), "Scale of floating chat messages")
	rschat.cvars.lifetime 	= CreateConVar("rschat_cl_lifetime", 	5, bit.bor(FCVAR_CLIENTCMD_CAN_EXECUTE), "How long to show floating chat messages")
end

--lookup tables
do
	rschat.mat 		= Material("runescape/font2")
	rschat.trans 	= Color(0, 0, 0, 0)

	rschat.data 	= {
		--barf
		charWidth 	= {
			nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
			nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
			 4,  2,  5, 12,  7, 11, 11,  2,  4,  4,  7,  8,  2,  6,  2,  5,
			 6,  4,  6,  6,  7,  6,  7,  6,  6,  6,  2,  4,  6,  7,  6,  7,
			12,  7,  6,  6,  6,  6,  6,  6,  6,  4,  7,  7,  6,  9,  7,  7,
			 6,  8,  6,  6,  6,  6,  6, 10,  7,  6,  6,  5,  5,  5,  7,  8,
			 4,  6,  6,  5,  6,  6,  6,  6,  6,  2,  5,  6,  2,  8,  6,  6,
			 6,  7,  5,  6,  5,  6,  6,  7,  6,  6,  6,  6,  2,  6, 10, nil
		},

		sheet 		= {
			sheetW 		= 256,
			sheetH 		= 128,
			tileW 		= 16,
			tileH 		= 16,
			tracking 	= 2 --better place for this?
		}
	}

	rschat.colors 	= {
		yellow 	= Color(255, 250, 0),
		red 	= Color(255, 24,  0),
		green 	= Color(0,   255, 14),
		green2 	= Color(128, 255, 128),
		blue 	= Color(0,   0,   255),
		cyan 	= Color(1,   255, 255),
		purple 	= Color(255, 2,   255),
		white 	= Color(255, 255, 255),
		black 	= Color(0, 	 0,   0)
	}
end

--other stuff
rschat.msgs = {}

--util stuff
rschat.fn.addMessage = function(ply, options)
	if hook.Run("ShouldRenderRunescapeChat", ply) == false then
		return
	end

	--not sure when this would be pre-set, but ya never know
	for k, v in pairs(rschat.blacklist) do
		if options.text:StartWith(v) == true and not string.lower(options.text):StartWith("/y") then
		return end
	end

	if string.lower(options.text):StartWith("/y") then -- For yelling
		options.color = rschat.colors.yellow
		options.fx[2] = "shake"
		options.text = string.Replace(options.text, "/y", "")
		options.text = string.Replace(options.text, "/Y", "")
	end

	if not(options.width) then
		options.width = 0

		for i = 1, #options.text do
			options.width = options.width +
				(
					rschat.data.charWidth[string.byte(options.text[i])] or
					rschat.data.charWidth[string.byte('?')]
				) +
				rschat.data.sheet.tracking
		end
	end

	--systime, not curtime :)
	options.time = SysTime()

	rschat.msgs[ply] = options
end

--this function makes meshes in a 2D space
--it's more work for us later but it's the most flexible way to do it
rschat.fn.drawMesh = function(ply, col)
	local options = rschat.msgs[ply]
	local msg = options.text

	--default to yellow but if we've got gradients do that instead
	if not(col) then
		col = rschat.colors.white

		local name 	= options.fx[1]
		local fx 	= rschat.fx[name]

		if(fx) then
			if(fx.fn) then
				col = fx.fn(SysTime() - options.time)
			else
				col = rschat.colors[name]
			end
		end
	end

	--convenience
	local sw = rschat.data.sheet.sheetW
	local sh = rschat.data.sheet.sheetH
	local tw = rschat.data.sheet.tileW
	local th = rschat.data.sheet.tileH

	mesh.Begin(MATERIAL_QUADS, #msg) --I guess use quads?

	local cx = 0

	for i = 1, #msg do
		--ascii is neat
		local char = options.text[i]
		local byte = string.byte(char)

		local w = rschat.data.charWidth[byte]

		--default to ?
		if not(w) then
			char = '?'
			byte = string.byte(char)

			w = rschat.data.charWidth[byte]
		end

		--sprite sheet coords
		local x = (byte % (sw / tw))
		local y = math.floor(byte / (sw / tw))

		--uvs
		local us = tw / sw
		local vs = th / sh

		local u = x * us
		local v = y * vs

		--use effects if we've got them
		local dx, dy = cx, 0

		local fx2 = options.fx[2]

		if(fx2 and rschat.fx[fx2]) then
			dx, dy = rschat.fx[fx2].fn(SysTime() - options.time, i, dx, dy, options.width)
		end

		--not a fan of all this
		mesh.Position(Vector(dx + tw, 	dy, 		0))
		mesh.TexCoord(0, u + us, 	v)
		mesh.Color(col.r, col.g, col.b, col.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(dx + tw, 	dy + th, 	0))
		mesh.TexCoord(0, u + us, 	v + vs)
		mesh.Color(col.r, col.g, col.b, col.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(dx, 		dy + th, 	0))
		mesh.TexCoord(0, u, 		v + vs)
		mesh.Color(col.r, col.g, col.b, col.a)
		mesh.AdvanceVertex()

		mesh.Position(Vector(dx, 		dy, 		0))
		mesh.TexCoord(0, u, 		v)
		mesh.Color(col.r, col.g, col.b, col.a)
		mesh.AdvanceVertex()

		cx = cx + w + rschat.data.sheet.tracking
	end

	--rschat.msgs[ply].width = cx --can't do this because we need it before we call this

	mesh.End()
end

--actual message stuff - good now :)
--if the addon is serverside, we'll get a net message
net.Receive("RSChat.addText", function()
	if not(rschat.cvars.clEnabled:GetBool()) then return end

	local ply = net.ReadEntity()
	local fx = {
		net.ReadString(),
		net.ReadString()
	}

	if not(rschat.cvars.svEffects:GetBool() and rschat.cvars.clEffects:GetBool()) then
		fx = {}
	end

	rschat.fn.addMessage(ply, {
		fx = fx,
		text = net.ReadString()
	})
end)

--if it's clientside, the net string won't exist
rschat.hooks.OPC = function(ply, text, ...)
	if not(rschat.cvars.clEnabled:GetBool()) then return end

	if(util.NetworkStringToID("RSChat.addText") == 0) then
		local fx = {}
		local str = text

		local cv = rschat.cvars

		if(cv.svEffects:GetBool() and cv.clEffects:GetBool()) then
			fx, str = rschat.fn.getEffects(str)
		end

		rschat.fn.addMessage(ply, {
			text 	= str,
			fx 		= fx
		})
	end
end

--drawing meshes
rschat.hooks.PDTR = function(depth, skybox)
	if not(depth or skybox) then
		render.SetLightingOrigin(Vector())
		render.ResetModelLighting(1, 1, 1)
		render.SetBlend(1)

		render.SuppressEngineLighting(true)
		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)

		--this is nuts
		--2d cams inside stencils, gah damn
		local ipos 		= EyePos()
		local stime 	= SysTime()
		local scale 	= rschat.cvars.scale:GetFloat()
		local height 	= rschat.cvars.svHeight

		if(height:GetFloat() == tonumber(height:GetDefault())) then
			height = rschat.cvars.clHeight:GetFloat()
		else
			height = height:GetFloat()
		end

		render.SetMaterial(rschat.mat)

		for ply, msg in pairs(rschat.msgs) do
			if(IsValid(ply) and (ply ~= LocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer())) then
				--darkrp range check
				//if(DarkRP and not GAMEMODE.Config.alltalk) then --is this reliable?
				//	--https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/chat/sv_chat.lua#L110
				//	--note that 250 ^ 2 isn't hard coded - it's 250 for normal chat, but 90 for whisper and 550 for yell
				//	--but messages won't be received if they're not in range to begin with - so this isn't the end of the world :)
				//	if(ply:GetPos():DistToSqr(LocalPlayer():GetPos()) > 302500) then
				//		--don't like using glua keywords
				//		continue
				//	end
				//end

				if(stime < msg.time + rschat.cvars.lifetime:GetFloat()) then
					--a little bit above the head :)
					if ply:GetPos():DistToSqr(LocalPlayer():GetPos()) > 350*350 then
						continue
					end

					local pos
					local bone = ply:LookupBone("ValveBiped.Bip01_Head1")

					if(bone) then
						pos = ply:GetBonePosition(bone)
						pos.z = pos.z + height
					else
						pos = ply:GetPos()
						pos.z = pos.z + 64 + height
					end

					--stencils (rip)
					render.ClearStencil()
					render.SetStencilEnable(true)

					render.SetStencilWriteMask(255)
					render.SetStencilTestMask(255)

					render.SetStencilFailOperation(STENCILOPERATION_KEEP)
					render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

					render.SetStencilReferenceValue(69) --;)
					render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

					--drawing a quad for clipping
					render.DrawQuadEasy(
						pos,
						-(pos - ipos):GetNormalized(),
						32 * (rschat.data.sheet.tileW + rschat.data.sheet.tracking) * scale, --pretty much arbitrary
						rschat.data.sheet.tileH * scale * 4, --same
						rschat.trans,
						0
					)

					--set it to equal mode
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

					--normal drawing
					cam.Start2D()
						local spos = pos:ToScreen()

						--matrices are rad
						local mpos = Vector(
							spos.x - (msg.width / 2 - 1) * scale, -- -1 for shadow
							spos.y - (scale * rschat.data.sheet.tileH),
							0
						)

						local mat = Matrix()

						mat:SetTranslation(mpos)
						mat:SetScale(Vector(1, 1, 1) * scale)

						--maybe scissor
						if(msg.fx[2] == "scroll") then
							render.SetScissorRect(spos.x - 50 * scale, 0, spos.x + 50 * scale, ScrH(), true)
						elseif(msg.fx[2] == "slide") then
							render.SetScissorRect(0, mpos.y - scale, ScrW(), mpos.y + (rschat.data.sheet.tileH + 1) * scale, true)
						end

						--shadow
						cam.PushModelMatrix(mat)
							rschat.fn.drawMesh(ply, rschat.colors.black)
						cam.PopModelMatrix()

						--normal
						mat:Translate(Vector(-1, -1, 0))

						cam.PushModelMatrix(mat)
							rschat.fn.drawMesh(ply, msg.color)
						cam.PopModelMatrix()

						--undo scissor
						if(msg.fx[2] == "scroll" or msg.fx[2] == "slide") then
							render.SetScissorRect(0, 0, 0, 0, false)
						end
					cam.End2D()

					render.SetStencilEnable(false)
				end
			end
		end

		render.PopFilterMin()
		render.PopFilterMag()
		render.SuppressEngineLighting(false)
	end
end

--adding hooks
hook.Add("OnPlayerChat", 					"RSChat.OPC", 	rschat.hooks.OPC)
hook.Add("PostDrawTranslucentRenderables", 	"RSChat.PDTR", 	rschat.hooks.PDTR)
