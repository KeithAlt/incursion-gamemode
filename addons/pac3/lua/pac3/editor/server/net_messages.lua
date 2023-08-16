util.AddNetworkString("pac.net.InPAC3Editor")
util.AddNetworkString("pac.net.InPAC3Editor.ClientNotify")
net.Receive( "pac.net.InPAC3Editor.ClientNotify", function( length, client )
	b = (net.ReadBit() == 1)
	net.Start("pac.net.InPAC3Editor")
	net.WriteEntity(client)
	net.WriteBit(b)
	net.Broadcast()
end )

util.AddNetworkString("pac.net.InAnimEditor")
util.AddNetworkString("pac.net.InAnimEditor.ClientNotify")
net.Receive( "pac.net.InAnimEditor.ClientNotify", function( length, client )
	b = (net.ReadBit() == 1)
	net.Start("pac.net.InAnimEditor")
	net.WriteEntity(client)
	net.WriteBit(b)
	net.Broadcast()
end )
