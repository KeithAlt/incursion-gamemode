local PLUGIN = PLUGIN
PLUGIN.name = "Automated Class Recruitment"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "Class recruitment through quizzes."

nut.util.include("sv_plugin.lua")

function PLUGIN:CanTakeQuizz( char, quizz )
	local quizzData = char:getData("quizzes", {})

	if quizzData[quizz] and quizzData[quizz] > os.time() then
		return false
	end

	return true
end

if CLIENT then
	-- Quizz Menu --
	local PANEL = {}
	function PANEL:Init()
		if not PLUGIN.QuizzAnswers then return end

		self:SetSize(550, 450)
		self:Center()
		self:MakePopup()
		self:SetTitle("Quizz")

		self.button = vgui.Create("DButton", self)
		self.button:SetText("Submit")
		self.button:Dock(BOTTOM)
		self.button:DockPadding(4, 2, 4, 2)
		self.button:DockMargin(4,2,4,2)
		self.button.DoClick = function()
			if #self.answers != #PLUGIN.QuizzAnswers then
				Derma_Message("You need to answer all questions!", "Error", "Ok")
				return
			end

			netstream.Start("fo_classquizz", PLUGIN.QuizzEnt, self.answers)
			self:Close()
		end

		self.panel = vgui.Create("DScrollPanel", self)
		self.panel:Dock(FILL)
		self.panel:DockPadding(4, 2, 4, 2)
		self.panel:DockMargin(4, 2, 4, 2)

		self.list = vgui.Create("DIconLayout", self.panel)
		self.list:Dock(FILL)

		self.answers = {}

		for qID, q in pairs(PLUGIN.QuizzAnswers) do
			local panel = self.list:Add("DPanel")
			panel:SetSize(515, 100)

			local label = vgui.Create("DLabel", panel)
			label:SetSize(505, 50)
			label:SetPos(5, 0)
			label:SetText(q[1])
			label:SetWrap(true)

			local comboBox = vgui.Create("DComboBox", panel)
			comboBox:SetSize(505, 25)
			comboBox:SetPos(5, 55)
			comboBox:SetValue("Answer...")
			comboBox.OnSelect = function( panel, index, value )
				self.answers[qID] = index
			end

			for aID, a in pairs(q[2]) do
				comboBox:AddChoice(a)
			end
		end
	end

	vgui.Register("fo_Quizz", PANEL, "DFrame")

	netstream.Hook("fo_classquizz", function( ent, answers )
		PLUGIN.QuizzEnt = ent
		PLUGIN.QuizzAnswers = answers
		vgui.Create("fo_Quizz")
	end)

end

properties.Add( "classquizzid", {
	MenuLabel = "Quizz id",
	Order = 999,
	MenuIcon = nil,

	Filter = function( self, ent, ply )

		if ( ent:GetClass() != "fo_classquizz" ) then return false end
		if ( not ply:IsSuperAdmin() ) then return false end

		return true
	end,

	Action = function( self, ent )

		Derma_StringRequest(
			"Quizz id",
			"Enter the quizz id you want",
			"",
			function( text ) 
				local number = tonumber(text)
				if ( !isnumber(number) ) then return end

				netstream.Start("fo_classquizzset", ent, number)
			end
		)

	end,

	Receive = function( self, length, ply )
	end

} )

netstream.Hook("fo_classquizzset", function(ply, ent, id)
	if ( !IsValid( ent ) ) then return end
	if ( ent:GetClass() != "fo_classquizz" ) then return false end
	if ( not ply:IsSuperAdmin() ) then return false end

	local quizz = PLUGIN.Quizzes[id]

	ent.foQuizz = id
	ent:setNetVar("title", quizz[1])
	ent:SetModel(quizz[2])
	--ent:SetMoveType(MOVETYPE_NONE)
	ent:PhysicsInit( SOLID_VPHYSICS )
	ent:SetMoveType( MOVETYPE_VPHYSICS )
	ent:SetSolid( SOLID_VPHYSICS )
	ent:SetUseType( SIMPLE_USE )
	local phys = ent:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end)