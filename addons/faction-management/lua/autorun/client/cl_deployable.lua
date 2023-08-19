PANEL = { }
local scrw, scrh = ScrW( ), ScrH( )
local frameW, frameH, animTime, animDelay, animEasy = scrw / 2, scrh - 100, 1.8, 0, .1

function PANEL:Init( )
    self:SetSize( 0, 0 ) -- Required for animation.
    self:MakePopup( )
    self:SetTitle( "Faction Deployables" )
    self:ShowCloseButton(true)
    self:SizeTo( frameW, frameH, animTime, animDelay, animEasy ) -- Sizing "animation"

    self.close = self:Add("UI_DButton")
    self.close:Dock(BOTTOM)
    self.close:SetText("CLOSE")
    self.close:SetContentAlignment(8)
    local close = self.close
    close.DoClick = function()
        if IsValid(self) then
            self:Remove()
        end
    end

	LocalPlayer().cachedPanel = self
	self.deployables = {}
    self.tbl = { } -- initilaizing table.
    self.scroller = self:Add( "UI_DScrollPanel" )
    self.scroller:Dock( FILL )
    --self:BuildItems( self.tbl ) -- build the items to add to the list.

	-- Request our faction storage data
	net.Start("getFactionStoragesByID")
		net.WriteString(nut.faction.indices[LocalPlayer():getChar():getFaction()].uniqueID)
	net.SendToServer()
end

function LoadPanel(panel, tbl)
	panel:BuildItems(tbl)
end

-- Retrieve our faction storage data
net.Receive("sendFactionStoragesByID", function()
	local tbl = net.ReadTable()

	if !tbl then return end

	LocalPlayer().cachedPanel:BuildItems(tbl)
	LocalPlayer().cachedPanel = nil
end)


function PANEL:OnSizeChanged( w, h )
    self:Center( ) -- Center it afterwards.
end

function PANEL:SetTable( tbl )
	if !(LocalPlayer():getChar() or LocalPlayer():getChar():getFaction()) then return end

    self:BuildItems(self.deployables)
end

function PANEL:BuildItems( tbl )
    if tbl == nil then return end
    for k, v in pairs( tbl ) do
        local deployable = self.scroller:Add( "UI_DPanel_Horizontal" )
        deployable:Dock( TOP )
        deployable:SetTall( 150 )
        deployable:DockMargin( 5, 10, 5, 10 )


        local modelview = deployable:Add( "DModelPanel" )
        modelview:Dock( LEFT )
        modelview:DockMargin(10, 10, 10, 10) -- Push slightly in to accomodate for the border.
        modelview:SetTall( 150 )
        modelview:SetModel( v.model )
        modelview:SetWide( 200 )
        modelview:SetFOV( 40 )
        modelview:SetCamPos( modelview:GetCamPos( ) * 3 + ( Vector( 0, 0, 10 ) ) )

        local slct = deployable:Add("UI_DButton")
        slct:SetText("SELECT")
        slct:SetContentAlignment(8)
        slct:Dock(BOTTOM)
        slct.DoClick = function()

			if v.ent and (v.ent == "faction-storage" or v.ent == "workbench") and v.canUse == true then
	            net.Start("hcDeployableSpawn")
	                net.WriteTable(v)
	            net.SendToServer()
			end

            if IsValid(self) then
                self:Close()
            end
        end

        local name = deployable:Add( "UI_DLabel" )
        name:SetText( v.name )
        name:Dock( LEFT )
        name:SetWide( #name:GetText() * 15 )
        name:DockMargin( 10, 10, 0, 0 )
        name:SetContentAlignment( 7 )

        if v.canUse != nil and not v.canUse then
            slct:Remove( )
            local redbox = deployable:Add( "DPanel" )
            redbox:SetPos( 0, 0 )
            redbox:SetSize( 1000, 150 )

            redbox.Paint = function( self, w, h )
                surface.SetDrawColor( 255, 0, 0, 100 )
                surface.DrawRect( 0, 0, w, h )
            end

            local cnt = deployable:Add( "UI_DLabel" )
            cnt:SetTextColor( Color( 0, 0, 0 ) )
            cnt:SetText( "You do not have access to this deployable." )
            cnt:SetWide( #cnt:GetText( ) * 10 )
            cnt:Dock( LEFT )
            cnt:DockMargin( 0, 65, 0, 0 )
            cnt:SetContentAlignment( 8 )
        end
    end
end

vgui.Register( "FactionDeployableMenu", PANEL, "UI_DFrame" )

net.Receive("sendFactionDeployablesList", function(len, ply)
	if hcWhitelist.FactionDeployables then
		hcWhitelist.FactionDeployables = net.ReadTable()
	end
end)
