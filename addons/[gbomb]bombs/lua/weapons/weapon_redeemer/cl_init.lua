include('shared.lua')

local iScreenWidth = surface.ScreenWidth()
local iScreenHeight = surface.ScreenHeight()

local iRecHeight = 1.7*iScreenHeight
local iRecWidth = 1.275*iScreenWidth

--code riped off directly from Night Eagle (hopefully he doesn't find out...  ;-)
SWEP.QuadTable = {}
SWEP.QuadTable.w = iScreenHeight
SWEP.QuadTable.h = iScreenHeight
SWEP.QuadTable.x = (iScreenWidth - iScreenHeight) * .5
SWEP.QuadTable.y = 0

SWEP.ScopeTable = {}
SWEP.ScopeTable.x = SWEP.QuadTable.h * .25 + SWEP.QuadTable.x
SWEP.ScopeTable.y = SWEP.QuadTable.h * .25
SWEP.ScopeTable.w = SWEP.QuadTable.w * .5
SWEP.ScopeTable.h = SWEP.QuadTable.h * .5


function SWEP:DrawHUD()

if not self.Owner:GetNWBool("DrawReticle") then return end

	--Draw the Reticle
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(surface.GetTextureID("sprites/reticle1"))
	
	surface.DrawTexturedRect(-0.5*(iRecWidth - iScreenWidth), -0.5*(iRecHeight - iScreenHeight), iRecWidth, iRecHeight )
	
	--Draw the Scope
	surface.SetDrawColor(0,0,0,255)
	
	surface.DrawRect(0,0,self.QuadTable.x,self.QuadTable.h)
	surface.DrawRect(surface.ScreenWidth() - self.QuadTable.x,0,self.QuadTable.x,self.QuadTable.h)
	
	surface.SetTexture(surface.GetTextureID("gui/sniper_corner"))
	surface.DrawTexturedRectRotated(self.ScopeTable.x,self.ScopeTable.y,self.ScopeTable.w,self.ScopeTable.h,0)
	surface.DrawTexturedRectRotated(self.ScopeTable.x,iScreenHeight - self.ScopeTable.y,self.ScopeTable.w,self.ScopeTable.h,90)
	surface.DrawTexturedRectRotated(iScreenWidth - self.ScopeTable.x,iScreenHeight - self.ScopeTable.y,self.ScopeTable.w,self.ScopeTable.h,180)
	surface.DrawTexturedRectRotated(iScreenWidth - self.ScopeTable.x,self.ScopeTable.y,self.ScopeTable.w,self.ScopeTable.h,270)
	
	
end
