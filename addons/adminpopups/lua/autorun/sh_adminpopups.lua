local cfg = cfg or {}

--[[
	Admin Popups by Jacob
	Support given at ScriptFodder or steam (www.steamcommunity.com/id/lostalien)
	Please use the config below or request support from me. I will not provide support if you modify the code
	Some clientside configuration can be done with cvars (cl_adminpopups_*)
]]

cfg.autoclose = 60 -- the case will auto close after this amount of seconds
cfg.preventchat = true -- Prevents adminchat messages shown on popups
cfg.caseUpdateOnly = false -- Once a case is claimed, only the claimer sees further updates
cfg.useFAdmin = false -- Use FAdmin reports (///help me please)
cfg.debug = false -- Debug mode allows admins to send popups too and prints button commands
cfg.xpos = 20 -- X cordinate of the popup. Can be changed in case it blocks something important
cfg.ypos = 20 -- Y cordinate of the popup. Can be changed in case it blocks something important
cfg.dutyjobs = { -- These are the 'on duty' jobs. Clients can restrict notifications to these jobs only
	"admin on duty",
	"mod on duty",
	"moderator on duty"
}


if CLIENT then
	-- Clients are able to configure these ingame with console, however you can set the default here. Only change the first number after the convar name
	CreateClientConVar("cl_adminpopups_closeclaimed",0,true,false) -- This will autoclose cases claimed by others.
	CreateClientConVar("cl_adminpopups_dutymode",0,true,false) -- see below
	-- 0 = Always show popups
	-- 1 = Show chat messages while on NOT duty
	-- 2 = Show console messages while NOT on duty
	-- 3 = Disable admin messages
end

--[[
	End of config, do not touch the code below
]]


for k,v in pairs(cfg.dutyjobs) do
	cfg.dutyjobs[k] = v:lower()
end

local function hasAccess(ply)
	/**if ulx then
		return ply:query("ulx seeasay")
	end**/
	if serverguard then
		return ply:IsAdmin() or ply:IsSuperAdmin()
	end
	return false
end

local function sendPopup(noob,message)
	--if not cfg.state then return end
	if cfg.caseUpdateOnly then
		if noob.CaseClaimed then
			if noob.CaseClaimed:IsValid() and noob.CaseClaimed:IsPlayer() then
				net.Start("ASayPopup")
					net.WriteEntity(noob)
					net.WriteString(message)
					net.WriteEntity(noob.CaseClaimed)
				net.Send(noob.CaseClaimed)
			end
		else
			for k,v in pairs(player.GetAll()) do
				if hasAccess(v) then
					net.Start("ASayPopup")
						net.WriteEntity(noob)
						net.WriteString(message)
						net.WriteEntity(noob.CaseClaimed)
					net.Send(v)
				end
			end
		end
	else
		for k,v in pairs(player.GetAll()) do
			if hasAccess(v) then
				net.Start("ASayPopup")
					net.WriteEntity(noob)
					net.WriteString(message)
					net.WriteEntity(noob.CaseClaimed)
				net.Send(v)
			end
		end
	end
	if noob:IsValid() and noob:IsPlayer() then
		timer.Destroy("adminpopup-"..noob:SteamID64())
		timer.Create("adminpopup-"..noob:SteamID64(),cfg.autoclose,1,function() if noob:IsValid() and noob:IsPlayer() then noob.CaseClaimed = nil end end)
	end
end

hook.Add("ULibCommandCalled","CheckForASay",function(ply,cmd,args)
	if cmd == "ulx asay" and ply:query("ulx asay") then
		if #args < 1 then return end
		if ply:query("ulx seeasay") then
			if cfg.debug then
				sendPopup(ply,table.concat(args," "))
				return not cfg.preventchat
			end
		else
			sendPopup(ply,table.concat(args," "))
			return not cfg.preventchat
		end
	end
end)

hook.Add("OnPlayerChat","CheckForASay",function(ply,msg,team)
	if string.ToTable(msg)[1] == "@" and IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin()) then
		if ply == LocalPlayer() then
			local tbl = string.ToTable(msg)
			tbl[1] = ""
			chat.AddText(Color(70,0,130),"You",Color(151,211,255)," to admins: ",Color(0,255,0), table.concat(tbl))
		end
		return true
	end
end)

if SERVER then
	util.AddNetworkString("ASayPopup")
	util.AddNetworkString("ASayPopupClaim")
	util.AddNetworkString("ASayPopupClose")

	net.Receive("ASayPopupClaim",function(len,ply)
		local noob = net.ReadEntity()
		if hasAccess(ply) and not noob.CaseClaimed then
			for k,v in pairs(player.GetAll()) do
				if hasAccess(v) then
					net.Start("ASayPopupClaim")
						net.WriteEntity(ply)
						net.WriteEntity(noob)
					net.Send(v)
				end
			end
			hook.Call("ASayPopupClaim",GAMEMODE,ply,noob) -- for use of other addons (such as statistics) like this one steamcommunity.com/workshop/gmod/?id=76561198019733081
			noob.CaseClaimed = ply
		end
	end)

	net.Receive("ASayPopupClose",function(len,ply)
		local noob = net.ReadEntity()
		if not noob or not noob:IsValid() then print "lmao" return end
		if not noob.CaseClaimed == ply then print("should not happen") return end
		if timer.Exists("adminpopup-"..noob:SteamID64()) then
			timer.Destroy("adminpopup-"..noob:SteamID64())
		end
		for k,v in pairs(player.GetAll()) do
			if hasAccess(v) then
				net.Start("ASayPopupClose")
					net.WriteEntity(noob)
				net.Send(v)
			end
		end
		noob.CaseClaimed = nil
	end)

	hook.Add("PlayerDisconnected","PopupsClose",function(noob)
		for k,v in pairs(player.GetAll()) do
			if hasAccess(v) then
				net.Start("ASayPopupClose")
					net.WriteEntity(noob)
				net.Send(v)
			end
		end
	end)

end

if CLIENT then

	local mat_lightning = Material("icon16/lightning_go.png")
	local mat_arrow = Material("icon16/arrow_left.png")
	local mat_link = Material("icon16/link.png")
	local mat_eye = Material("icon16/eye.png")
	local mat_case = Material("icon16/briefcase.png")

	local aframes = aframes or {}

	surface.CreateFont("adminpopup", {
		font = "Railway",
		size = 15,
		weight = 400
	})

	local function asayframe(noob,message,claimed)
		if not noob:IsValid() or not noob:IsPlayer() then return end
		for k,v in pairs(aframes) do
			if v.idiot == noob then
				local txt = v:GetChildren()[5]
				txt:AppendText("\n".. message)
				txt:GotoTextEnd()
				timer.Destroy("adminpopup-"..noob:SteamID64()) -- destroy so we can extend
				timer.Create("adminpopup-"..noob:SteamID64(),cfg.autoclose,1,function() if v:IsValid() then v:Remove() end end)
				surface.PlaySound("ui/hint.wav") -- just a headsup that it changed
				return
			end
		end

		local w,h = 300,120

		local frm = vgui.Create("DFrame")
		frm:SetSize(w,h)
		frm:SetPos(cfg.xpos,cfg.ypos)
		frm.idiot = noob
		function frm:Paint(w,h)
			draw.RoundedBox( 0, 0, 0, w, h, Color(10,10,10,230) )
		end
		frm.lblTitle:SetColor(Color(255,255,255))
		frm.lblTitle:SetFont("adminpopup")
		frm.lblTitle:SetContentAlignment(7)

		if claimed and claimed:IsValid() and claimed:IsPlayer() then
			frm:SetTitle(noob:Nick().." - Claimed by "..claimed:Nick())
			if claimed == LocalPlayer() then
				function frm:Paint(w,h)
					draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 10,230) )
					draw.RoundedBox( 0, 2, 2, w-4, 16, Color(38, 166, 91) )
				end
			else
				function frm:Paint(w,h)
					draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 10,230) )
					draw.RoundedBox( 0, 2, 2, w-4, 16, Color(207, 0, 15) )
				end
			end
		else
			frm:SetTitle(noob:Nick())
		end




		local msg = vgui.Create("RichText",frm)
		msg:SetPos(10,30)
		msg:SetSize(190,h-35)
		msg:SetContentAlignment(7)
		msg:InsertColorChange( 255, 255, 255, 255 )
		msg:SetVerticalScrollbarEnabled(false)
		function msg:PerformLayout()
			self:SetFontInternal( "DermaDefault" )
		end
		msg:AppendText(message)

		--buttons

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 1)
		cbu:SetSize(83,18)
		cbu:SetText("          Goto")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.DoClick = function()
			local toexec = [["ulx goto $]]..noob:SteamID()..[["]]
			if serverguard then
				toexec = [[sg goto "]]..noob:SteamID()..[["]]
			end
			LocalPlayer():ConCommand(toexec)
			if cfg.debug then
				print(toexec)
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
				draw.RoundedBox( 1, 0, 0, w, h, Color(255,50,50,255) )
			elseif cbu.Hovered then
				draw.RoundedBox( 1, 0, 0, w, h, Color(205,30,30,255) )
			else
				draw.RoundedBox( 1, 0, 0, w, h, Color(80,80,80,255) )
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(mat_lightning)
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 2)
		cbu:SetSize(83,18)
		cbu:SetText("          Return")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.should_unjail = false
		cbu.DoClick = function()
			local toexec = [["ulx return ^"]]
			if serverguard then
				toexec = [["sg return"]]
			end
			LocalPlayer():ConCommand(toexec)
			if cfg.debug then
				print(toexec)
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
				draw.RoundedBox( 1, 0, 0, w, h, Color(255,50,50,255) )
			elseif cbu.Hovered then
				draw.RoundedBox( 1, 0, 0, w, h, Color(205,30,30,255) )
			else
				draw.RoundedBox( 1, 0, 0, w, h, Color(80,80,80,255) )
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(mat_arrow)
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 3)
		cbu:SetSize(83,18)
		cbu:SetText("          Freeze")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.should_unfreeze = false
		cbu.DoClick = function()
			local toexec = [["ulx freeze $]]..noob:SteamID()..[["]]
			if cbu.should_unfreeze then
				toexec = [["ulx unfreeze $]]..noob:SteamID()..[["]]
			end
			if serverguard then
				toexec = [[sg freeze "]]..noob:SteamID()..[["]]
			end
			LocalPlayer():ConCommand(toexec)
			if cfg.debug then
				print(toexec)
				--
			end
			cbu.should_unfreeze = not cbu.should_unfreeze
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
				draw.RoundedBox( 1, 0, 0, w, h, Color(255,50,50,255) )
			elseif cbu.Hovered then
				draw.RoundedBox( 1, 0, 0, w, h, Color(205,30,30,255) )
			else
				draw.RoundedBox( 1, 0, 0, w, h, Color(80,80,80,255) )
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(mat_link)
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 4)
		cbu:SetSize(83,18)
		cbu:SetText("          spectate")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.DoClick = function()
			local toexec = [["ulx spectate $]]..noob:SteamID()..[["]]
			if serverguard then
				toexec = [[sg spectate "]]..noob:SteamID()..[["]]
			end
			LocalPlayer():ConCommand(toexec)
			if cfg.debug then
				print(toexec)
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
				draw.RoundedBox( 1, 0, 0, w, h, Color(255,50,50,255) )
			elseif cbu.Hovered then
				draw.RoundedBox( 1, 0, 0, w, h, Color(205,30,30,255) )
			else
				draw.RoundedBox( 1, 0, 0, w, h, Color(80,80,80,255) )
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(mat_eye)
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local cbu = vgui.Create("DButton",frm)
		cbu:SetPos(215,20 * 5)
		cbu:SetSize(83,18)
		cbu:SetText("          Claim case")
		cbu:SetColor(Color(255,255,255))
		cbu:SetContentAlignment(4)
		cbu.shouldclose = false
		cbu.DoClick = function()
			if not cbu.shouldclose then
				if frm.lblTitle:GetText():lower():find("claimed") then
					chat.AddText(Color(255,150,0),"[ERROR] Case has already been claimed")
					surface.PlaySound("common/wpn_denyselect.wav")
				else
					net.Start("ASayPopupClaim")
						net.WriteEntity(noob)
					net.SendToServer()
					cbu.shouldclose = true
					cbu:SetText("          Close case")
				end
			else
				net.Start("ASayPopupClose")
					net.WriteEntity(noob or nil)
				net.SendToServer()
			end
		end
		cbu.Paint = function(self,w,h)
			if cbu.Depressed or cbu.m_bSelected then
				draw.RoundedBox( 1, 0, 0, w, h, Color(255,50,50,255) )
			elseif cbu.Hovered then
				draw.RoundedBox( 1, 0, 0, w, h, Color(205,30,30,255) )
			else
				draw.RoundedBox( 1, 0, 0, w, h, Color(80,80,80,255) )
			end
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(mat_case)
			surface.DrawTexturedRect(5, 1, 16, 16)
		end

		local bu = vgui.Create("DButton",frm)
		bu:SetText("×")
		bu:SetTooltip("Close")
		bu:SetColor(Color(255,255,255))
		bu:SetPos(w-18,2)
		bu:SetSize(16,16)
		function bu:Paint(w,h)
		end
		bu.DoClick = function()
			frm:Close()
		end

		frm:ShowCloseButton(false) -- we have our close button, so we won't need it

		frm:SetPos(-w-30,cfg.ypos + (130 * #aframes)) -- move out of screen
		frm:MoveTo(cfg.xpos,cfg.ypos + (130 * #aframes),0.2,0,1,function() -- move back in
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
		end)

		function frm:OnRemove() -- for animations when there are several panels
			table.RemoveByValue(aframes,frm)
			for k,v in pairs(aframes) do
				v:MoveTo(cfg.xpos,cfg.ypos + (130 *(k-1)),0.1,0,1,function() end)
			end
			if noob and noob:IsValid() and noob:IsPlayer() and timer.Exists("adminpopup-"..noob:SteamID64()) then
				timer.Destroy("adminpopup-"..noob:SteamID64())
			end
		end
		table.insert(aframes,frm)

		timer.Create("adminpopup-"..noob:SteamID64(),cfg.autoclose,1,function() if frm:IsValid() then frm:Remove() end end)	-- auto close
	end

	net.Receive("ASayPopup",function(len)
		local pl = net.ReadEntity()
		local msg = net.ReadString()
		local claimed = net.ReadEntity()

		local dutymode = cvars.Number("cl_adminpopups_dutymode")
		if dutymode == 0 then
			asayframe(pl,msg,claimed)
		elseif dutymode == 1 then
			if table.HasValue(cfg.dutyjobs,team.GetName(LocalPlayer():Team()):lower()) then
				asayframe(pl,msg,claimed)
			else
				chat.AddText(Color(245, 171, 53),"[Admin Popups] ",team.GetColor(pl:Team()),pl:Nick(),Color(255,255,255),": ",msg)
			end
		elseif dutymode == 2 then
			if table.HasValue(cfg.dutyjobs,team.GetName(LocalPlayer():Team()):lower()) then
				asayframe(pl,msg,claimed)
			else
				MsgC(Color(245, 171, 53),"[Admin Popups] ",team.GetColor(pl:Team()),pl:Nick(),Color(255,255,255),": ",msg,"\n")
			end
		end

	end)

	net.Receive("ASayPopupClose",function(len)
		local noob = net.ReadEntity()

		if not noob:IsValid() or not noob:IsPlayer() then return end

		for k,v in pairs(aframes) do
			if v.idiot == noob then
				v:Remove()
			end
		end
		if timer.Exists("adminpopup-"..noob:SteamID64()) then
			timer.Destroy("adminpopup-"..noob:SteamID64())
		end

	end)

	net.Receive("ASayPopupClaim",function(len)
		local pl = net.ReadEntity()
		local noob = net.ReadEntity()
		for k,v in pairs(aframes) do
			if v.idiot == noob then
				if cvars.Bool("cl_adminpopups_closeclaimed") and pl ~= LocalPlayer() then
					v:Remove()
				else
					local titl = v:GetChildren()[4]
					titl:SetText(titl:GetText() .. " - Claimed by "..pl:Nick())
					if pl == LocalPlayer() then
						function v:Paint(w,h)
							draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 10,230) )
							draw.RoundedBox( 0, 2, 2, w-4, 16, Color(38, 166, 91) )
						end
					else
						function v:Paint(w,h)
							draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 10,230) )
							draw.RoundedBox( 0, 2, 2, w-4, 16, Color(207, 0, 15) )
						end
					end
					local bu = v:GetChildren()[11]
					bu.DoClick = function()
						if LocalPlayer() == pl then
							net.Start("ASayPopupClose")
								net.WriteEntity(noob)
							net.SendToServer()
						else
							v:Close()
						end
					end

				end
			end
		end
	end)

	concommand.Add( "adminpopups_claimtop", function( ply, cmd, args )
		if #aframes > 0 then
			local button = aframes[1]:GetChildren()[10] -- button we want is 10th child of frame #1
			button.DoClick() --no need to write it all again.
		end
	end)

end

if SERVER then
	local function updateHook()
		if not serverguard then return end
		hook.Remove("PlayerSay", "reports.PlayerSay")
		hook.Add("PlayerSay", "reports.PlayerSay",function(ply,txt,team)
			if txt[1] ~= "@" then return end

			txt = txt:sub(2)

			if #txt < 1 then return end

			serverguard.Notify(ply, SGPF("report_received", ply:Name(), txt))

			if hasAccess(ply) then
				if cfg.debug then
					sendPopup(ply,txt)
					return not cfg.preventchat
				end
			else
				sendPopup(ply,txt)
				return not cfg.preventchat
			end
		end)
	end
	updateHook()
	hook.Add("InitPostEntity","adminpopups.serverguard",function()
		timer.Simple(5,updateHook)
	end)
end

if cfg.useFAdmin then
	FAdmin = FAdmin or {}
	FAdmin.StartHooks = FAdmin.StartHooks or {}

	FAdmin.StartHooks["Popups"] = function()
	   FAdmin.Commands.AddCommand("//", function(ply,cmd,args)

			if #args < 1 then return end

			if hasAccess(ply) then
				if cfg.debug then
					sendPopup(ply,table.concat(args," "))
					return not cfg.preventchat
				end
			else
				sendPopup(ply,table.concat(args," "))
				return not cfg.preventchat
			end


		end)
	end
end
