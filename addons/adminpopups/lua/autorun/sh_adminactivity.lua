if SERVER then
	if not file.Exists("caseclaims.txt","DATA") then
		file.Write("caseclaims.txt","[]")
	end
	
	local caseclaims = util.JSONToTable(file.Read("caseclaims.txt","DATA"))
	
	local function tabletofile()
		file.Write("caseclaims.txt",util.TableToJSON(caseclaims))
	end
	
	hook.Add("ASayPopupClaim","StoreClaims",function(admin,noob)
		-- insert if it doesn't exist
		caseclaims[admin:SteamID()] = caseclaims[admin:SteamID()] or {
			name = admin:Nick(),
			claims = 0,
			lastclaim = os.time()
		}
		-- update it
		caseclaims[admin:SteamID()] = {
			name = admin:Nick(),
			claims = caseclaims[admin:SteamID()].claims + 1,
			lastclaim = os.time()
		}
		
		tabletofile()
	end)
	
	util.AddNetworkString("ViewClaims")
	
	net.Receive("ViewClaims",function(len,ply)
		local sid = net.ReadString()
		net.Start("ViewClaims")
			net.WriteTable(caseclaims)
			net.WriteString(sid)
		net.Send(ply)
	end)
	
end

if CLIENT then
	
	net.Receive("ViewClaims",function(len)
		local tbl = net.ReadTable()
		local steamid = net.ReadString()
		if steamid and steamid ~= "" and steamid ~= " " then
			local v = tbl[steamid]
			print(v.name.." - "..v.claims.." - last claim "..string.NiceTime(os.time() - v.lastclaim).." ago")
		else
			for k,v in pairs(tbl) do
				print(v.name.." - "..v.claims)
			end
		end
		
	end)
	
	concommand.Add("viewclaims",function(pl,cmd,args)
		net.Start("ViewClaims")
			net.WriteString(table.concat(args,""))
		net.SendToServer()
	end)
	
end