

matproxy.Add( {
	name = "ScreenColor",
	init = function( self, mat, values )
		self.ResultTo = values.resultvar
	end,
	bind = function( self, mat, ent )
		if ent.GetScreenIdleColorVector then
			mat:SetVector(self.ResultTo, ent:GetScreenIdleColorVector())
		end
	end
} )