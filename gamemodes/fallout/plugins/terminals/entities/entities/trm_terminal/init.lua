AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SetupTerminal()
	self:SetNWBool( "Terminal:O/F", false )
	self:SetNWString( "Terminal:Key", "loading" )
	self:SetNWInt( "Terminal:InUse", CurTime() )
	self:SetNWBool( "Terminal:Destroy", false )
	
	self.Memory = ( self.Memory or {} )
	self.HP = 100
end

function ENT:Initialize()
	self:SetModel( "models/sd_fallout4/terminal1.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetupTerminal()
end

function ENT:EndTouch( entity )
	if ( entity:GetClass() == "nut_item" ) then
		local item = nut.item.instances[entity.nutItemID]
		if (item and item.uniqueID != "disk") then return end

		if ( not self.Memory.DiskText ) and ( not self:GetNWBool( "Terminal:Destroy" ) ) then
			if ( CurTime() > (entity.CooldownInsert or 0) ) then
				
				local index = item:getID()
				
				local diskData = nut.plugin.list["terminals"]:readDisk(index)
				
				self.Memory.DiskTitle = (diskData.title) or "Disk"
				self.Memory.DiskText = (diskData.text) or {"Empty Disk"}
				self.Memory.DiskAuthor = diskData.author
				self.Memory.DiskEditor = diskData.editor
				self.Memory.DiskPrinter = diskData.printer
				self.Memory.DiskPass = diskData.pass
				self.Memory.Encrypt = diskData.encrypt
				
				self.Memory.index = index

				nut.plugin.list["terminals"]:deleteDisk(index)
				item:remove()
				
				self:EmitSound( "terminalr/insert.wav" )
			end
		end
	elseif ( entity:GetClass() == "trm_hackkit" ) then
		if ( CurTime() > entity.CooldownInsert ) and ( not self.Memory.HackModule ) then
			self.Memory.HackModule = true
			entity:Remove()
		end
	elseif ( entity:GetClass() == "trm_repairkit" ) then
		if ( self:GetNWBool( "Terminal:Destroy" ) == true ) then
			self.HP = 100
			self:SetNWBool( "Terminal:Destroy", false )
			entity:Remove()
		end
	end
end

--replaced elsewhere
--[[
function ENT:EjectDisk(Info)
	local ang = self:GetAngles()

	local diskData = {
		author = Info.author,
		editor = Info.editor,
		printer = Info.printer,
		encrypt = Info.encrypt,
	}
	
	local item = inventory:add("disk", 1, {diskData})

	--saves items that arent in terminals
	TerminalR.DiskData[item:getID()] = {
		text = Info.text,
		title = Info.title, 
		author = Info.author,
		editor = Info.editor,
		printer = Info.printer,
		encrypt = Info.encrypt,
		pass = Info.pass
	}

	
	local inventory = char:getInv()
	if(!) then
		local dropPos = entity:GetPos() + ang:Forward()*15 + ang:Up()*10

		nut.item.spawn("disk", dropPos, function(item, ent)
			ent.CooldownInsert = CurTime() + 5
			

			
			item:setData("author", Info.author)
			item:setData("editor", Info.editor)
			item:setData("printer", Info.printer)
			item:setData("encrypt", Info.encrypt)
		end, Angle(280, 0, ang.y))
	end	
end
--]]


function ENT:EjectHackModule()
	local ang = self:GetAngles()
	local disk = ents.Create( "trm_hackkit" )
	disk:SetPos( self:GetPos() + ang:Forward()*15 + ang:Up()*10 )
	disk:SetAngles( Angle( 280, 0, ang.y ) )	
	disk:Spawn()
	disk.CooldownInsert = CurTime() + 5
	self.Memory.HackModule = nil
end

function ENT:OnTakeDamage( dmg )
	self.HP = self.HP - dmg:GetDamage()
	if ( self.HP <= 0 ) and ( not self:GetNWBool( "Terminal:Destroy" ) ) then
		self:SetNWBool( "Terminal:O/F", false )
		self:SetNWBool( "Terminal:Destroy", true )
		self:Ignite( 10 )
	end	
end

function ENT:Use( ply, caller )
	if ( self:GetNWBool("Terminal:O/F") == false ) then
		if ( self:GetNWBool( "Terminal:Destroy" ) ) then ply:ChatPrint( "Terminal Destroy" )return end
		self:SetNWBool( "Terminal:O/F", true )
		self:EmitSound( "terminalr/turn_on.wav" )
	else
		if ( CurTime() > self:GetNWInt( "Terminal:InUse" ) ) then
			local NTab = {
				EntIndex = self:EntIndex(),
				Key = self:GetNWString( "Terminal:Key" ),
				Memory = self.Memory
			}
			net.Start("Net_TerminalR:Open")
				net.WriteTable( NTab )
			net.Send(ply)
		end
	end	
end
 
function ENT:Think()
end