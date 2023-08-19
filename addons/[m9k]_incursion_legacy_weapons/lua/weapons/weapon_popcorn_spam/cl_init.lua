include('shared.lua')

SWEP.PrintName          = "Popcorn (spammable)"
SWEP.Slot               = 1
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false

SWEP.WepSelectIcon 		= surface.GetTextureID( "vgui/entities/weapon_popcorn" )

local emitter = ParticleEmitter(Vector(0,0,0))

function SWEP:GetViewModelPosition( pos , ang)
	pos,ang = LocalToWorld(Vector(20,-10,-15),Angle(0,0,0),pos,ang)

	return pos, ang
end

local function kernel_init(particle, vel)
	particle:SetColor(255,255,255,255)
	particle:SetVelocity( vel or VectorRand():GetNormalized() * 15)
	particle:SetGravity( Vector(0,0,-200) )
	particle:SetLifeTime(0)
	particle:SetDieTime(math.Rand(5,10))
	particle:SetStartSize(1)
	particle:SetEndSize(0)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetCollide(true)
	particle:SetBounce(0.25)
	particle:SetRoll(math.pi*math.Rand(0,1))
	particle:SetRollDelta(math.pi*math.Rand(-4,4))
end

function SWEP:Initialize()
end

net.Receive("Popcorn_Eat",function ()
	local ply = net.ReadEntity()
	if !IsValid(ply) then return end
	local size = net.ReadFloat()
	local attachid = ply:LookupAttachment("eyes")
	emitter:SetPos(LocalPlayer():GetPos())

	local angpos = ply:GetAttachment(attachid) or ply:GetAttachment(2)
	local fwd
	local pos

	if (ply != LocalPlayer()) and angpos then
		fwd = (angpos.Ang:Forward()-angpos.Ang:Up()):GetNormalized()
		pos = angpos.Pos + fwd*3
	else
		fwd = ply:GetAimVector():GetNormalized()
		pos = ply:GetShootPos() + gui.ScreenToVector( ScrW()/2, ScrH()/4*3 )*10
	end

	for i = 1,size do
		if !IsValid(ply) then return end

		local particle = emitter:Add( "particle/popcorn-kernel", pos )
		if particle then
			local dir = VectorRand():GetNormalized()
			kernel_init(particle, ((fwd)+dir):GetNormalized() * math.Rand(0,40))
		end
	end
end)

net.Receive("Popcorn_Eat_Start",function ()
	local ply = net.ReadEntity()
	ply.ChewScale = 1
	ply.ChewStart = CurTime()
	ply.ChewDur = SoundDuration("crisps/eat.wav")
end)

function GAMEMODE:MouthMoveAnimation (ply)
	local FlexNum = ply:GetFlexNum() - 1
	if ( FlexNum <= 0 ) then return end

	local chewing = false
	local weight
	if ((ply.ChewScale or 0) > 0) then
		local x = CurTime()-ply.ChewStart
		weight = 0.5*math.sin(x*(2*math.pi/0.625)-0.5*math.pi)+0.5
		chewing = true
	end

	for i=0, FlexNum-1 do

		local Name = ply:GetFlexName( i )

		if ( Name == "jaw_drop" || Name == "right_part" || Name == "left_part" || Name == "right_mouth_drop" || Name == "left_mouth_drop" ) then
			if ( ply:IsSpeaking() ) then
				ply:SetFlexWeight( i, math.Clamp( ply:VoiceVolume() * 2, 0, 2 ) )
			elseif ((ply.ChewScale or 0) > 0) then

				ply.ChewScale = math.Clamp((ply.ChewStart+ply.ChewDur - CurTime())/ply.ChewDur,0,1)
				if (Name == "jaw_drop" ) then
					ply:SetFlexWeight( i, weight*(ply.ChewScale*2) )
				else
					ply:SetFlexWeight( i, weight*((ply.ChewScale*2)-1.25) )
				end
			else
				ply:SetFlexWeight( i, 0 )
			end
		end
	end
end
