// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

// Initialize the basic material
if !VC.Material then VC.Material = {} end
VC.Material.Icon = Material("vcmod/icon_red.png")

// If VCMod does not load in a minute, something is probably wrong
VC.Chat_SomethingWrongMsgTime = CurTime()+60

// Setup the initial message, pre VCMod loaded
local function initMsg()
	local msg = "Still initializing, please wait..."
	if CurTime() >= VC.Chat_SomethingWrongMsgTime then msg = "VCMod loading failed, please try rejoining.\nIf that does not help, contact the servers staff." end
	chat.AddText(VC.Color.Accent_Light, "VCMod: ", VC.Color.Base, msg)
end

// Open menu command
function VC.OpenMenu() if VC.Loaded["shared"] then VC.DoOpenMenu(LocalPlayer(), {}, {}) else initMsg() end end

// Initialize console commands
local cmds = {"vc_open_menu", "vc_menu", "vcmod"} for k,v in pairs(cmds) do concommand.Add(v, function(...) VC.OpenMenu(...) end) end concommand.Add("vc_menu_null", function() end)

// Tap into the chat
hook.Add("OnPlayerChat", "VC_OnPlayerChat", function(ply, txt) if ply == LocalPlayer() then txt = string.lower(txt) if txt == "!vcmod" or txt == "!vc" then VC.OpenMenu() return true end end end)

// Copied from the languages tab
local Info_EverThought = "Ever thought that Garrysmod's vehicles are lacking realism?"
local Info_VCModIsDesigned = "VCMod is designed to provide Garrysmod's vehicle with full assortment of features."

// Create a VCMod section in Sandbox gamemode tools section
hook.Add("PopulateToolMenu", "VC_Menu", function()
	spawnmenu.AddToolMenuOption("VCMod", "Main", "VC_Menu", "Introduction", "", "", function(Pnl)
	local Lbl = vgui.Create("DLabel") Lbl:SetText("") Pnl:AddItem(Lbl) Lbl:SetTall(150) Lbl.Paint = function(obj, Sx, Sy) surface.SetDrawColor(255,255,255,255) surface.SetMaterial(VC.Material.Icon) surface.DrawTexturedRect(Sx/2-75, 0, 150, 150) end

	local Lbl = vgui.Create("DLabel") Lbl:SetTall(40) Lbl:SetColor(VC.Color.Accent) Lbl:SetText("        "..Info_EverThought) Pnl:AddItem(Lbl) Lbl:SetWrap(true)
	local Lbl = vgui.Create("DLabel") Lbl:SetTall(30) Lbl:SetColor(VC.Color.Accent) Lbl:SetText("        "..Info_VCModIsDesigned) Pnl:AddItem(Lbl) Lbl:SetWrap(true)

	local Btn = vgui.Create("DButton") Btn:SetText(VC.Lng and VC.Lng("OpenMenu") or "Open menu") Btn:SetToolTip('You can also open this menu by:\nConsole command: "vcmod"\nIn chat: "!vcmod"\nUsing the "C" menu') Pnl:AddItem(Btn) Btn.DoClick = VC.OpenMenu
		Btn.Paint = function(Obj, Sx, Sy) draw.RoundedBox(4, 0, 0, Sx, Sy, VC.Color.Accent_Light) draw.RoundedBox(4, 2, 2, Sx-4, Sy-4, VC.Color.Base) end
	end)
end)

// Create the "C menu" icon
list.Set("DesktopWindows", "VCMod", {title = "VCMod Menu", icon = "vcmod/icon_red_border.png", init = function(icon, window) window:Close() VC.OpenMenu() end})