if ( SERVER ) then
	AddCSLuaFile()
	SWEP.Weight = 15
end

if ( CLIENT ) then
    CreateClientConVar("pc_effect_type","1",true, true)
	CreateClientConVar("pc_effect_length","8.95",true, true)
	SWEP.PrintName		= "Particle Cannon"			
	SWEP.Author			= "Hds46"
	SWEP.Category		= "C&C"
	SWEP.Slot			= 1
	SWEP.SlotPos		= 6
	SWEP.IconLetter		= "x"

end

game.AddParticles( "particles/pc_fire01.pcf" )

------------General Swep Info---------------
SWEP.Author         = "Hds46"
SWEP.Contact        = "None"
SWEP.Purpose        = "Toast things from sky"
SWEP.Instructions   = "Left Click - Shoot. \nRight Click - Setup Particle Cannon"
SWEP.Spawnable      = true
SWEP.AdminOnly      = false
-----------------------------------------------

-----------------Models---------------------------
SWEP.ViewModel      = "models/weapons/c_pistol.mdl"
SWEP.UseHands       = true

SWEP.HoldType	    = "pistol"

SWEP.WorldModel     = "models/weapons/w_pistol.mdl"
-----------------------------------------------

-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"
-------------End Primary Fire Attributes------------------------------------
 
-------------Secondary Fire Attributes-------------------------------------
SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"
-------------End Secondary Fire Attributes--------------------------------
 
function SWEP:Reload()
end 
 
function SWEP:Think()
	if IsValid(self.Owner) and self.Owner:KeyReleased(IN_ATTACK) and SERVER then
	if IsValid(self.SensorEnt) then
	self.SensorEnt:Remove()
	end
	if IsValid(self.particle) then
	if ( self.particle.BeamSound ) then 
	self.particle.BeamSound:ChangeVolume( 0, 0.02 ) 
	self.particle.BeamSound:Stop() 
	self.particle.BeamSound = nil
	self.particle:Remove()
	end
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
    self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	end
	if IsValid(self.Owner) and self.Owner:KeyDown(IN_ATTACK) and SERVER then
	if IsValid(self.SensorEnt) then
	local pos
	local num = 0
	local checkforlag = 0
	self.haspath = false
	while !self.haspath  do
	local tracesensor = {}
    tracesensor.start = self.Owner:GetEyeTrace().HitPos + Vector(0,0,num)
    tracesensor.endpos = tracesensor.start + Vector(0,0,4200)
    tracesensor.filter = function(ent) if !ent:IsWorld() then return false end end
    local traceworldsensor = util.TraceLine(tracesensor)
    if traceworldsensor.HitSky then
	pos = traceworldsensor.HitPos - Vector(0,0,40)
	self.haspath = true
	break
	else
	if !traceworldsensor.HitSky then
	num = num + 84
	if num >= self.SensorEnt.EntHeight then
	pos = self.Owner:GetEyeTrace().HitPos + Vector(0,0,4000)
	self.haspath = true
	break
	end
	checkforlag = checkforlag + 1
	if checkforlag >= 50 then
	break
	end
	end
	end
	end
	if IsValid(self.SensorEnt) then
	self.SensorEnt:SetPos(LerpVector( math.Clamp((1 - math.Clamp(self.SensorEnt:GetPos():Distance(pos)/1200,0,1))/20,0.005,1), self.SensorEnt:GetPos(), pos ))
	if !self.particle.BeamSound then
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	self.particle.BeamSound = CreateSound(self.particle,Sound("lt_beam.wav"))
	self.particle.BeamSound:SetSoundLevel( 140 )
	self.particle.BeamSound:PlayEx(1,120)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	self.particle.BeamSound = CreateSound(self.particle,Sound("kt_beam.wav"))
	self.particle.BeamSound:SetSoundLevel( 140 )
	self.particle.BeamSound:PlayEx(1,60)
	else
	self.particle.BeamSound = CreateSound(self.particle,Sound("ambient/levels/citadel/zapper_loop2.wav"))
	self.particle.BeamSound:SetSoundLevel( 140 )
	self.particle.BeamSound:PlayEx(1,120)
	end
	end
	local tracebeam = {}
    tracebeam.start = self.SensorEnt:GetPos()
    tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
    tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
    local traceworldbeam = util.TraceLine(tracebeam)
	if traceworldbeam.Hit then
	if self.NextBeamEffect == nil then
	self.NextBeamEffect = 0
	end
	if self.NextBeamEffect < CurTime() then
	self.NextBeamEffect = CurTime() + 0.3
	if game.SinglePlayer() then
	local pc_particle = EffectData()
	pc_particle:SetEntity(self.SensorEnt)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	util.Effect("pc_particle_cannon_particle2",pc_particle)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	util.Effect("pc_ion_cannon_particle2",pc_particle)
	end
	else
	timer.Simple(0.002,function()
	if IsValid(self) and IsValid(self.SensorEnt) and IsValid(self.Owner) then
	local pc_particle = EffectData()
	pc_particle:SetEntity(self.SensorEnt)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	util.Effect("pc_particle_cannon_particle2",pc_particle)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	util.Effect("pc_ion_cannon_particle2",pc_particle)
	end
	end
	end)
	end
	end
	if self.NextBeamAttack == nil then
	self.NextBeamAttack = 0
	end
	if self.NextBeamAttack < CurTime() then
	self.NextBeamAttack = CurTime() + 0.1
	if tonumber(self.Owner:GetInfo("pc_effect_type")) != 3 then
	local physExplo = ents.Create( "env_physexplosion" )
	physExplo:SetPos( traceworldbeam.HitPos )
	physExplo:SetKeyValue( "magnitude", "1000" )	-- Power of the Physicsexplosion
	physExplo:SetKeyValue( "radius", "350" )	-- Radius of the explosion
	physExplo:SetKeyValue( "spawnflags", "1" )
	physExplo:SetKeyValue( "targetentityname", "prop_physics" )
	physExplo:Spawn()
	physExplo:Fire( "Explode", "", 0 )
	end
	for k,v in pairs(ents.FindInSphere(traceworldbeam.HitPos,330)) do
	if IsValid(v) and v != self.Owner then
	v.InGround = true
	timer.Create("ent_ground" .. v:EntIndex(),0.2,1,function()
	if IsValid(v) then
	v.InGround = false
	end
	end)
	local dmginfo = DamageInfo()
    dmginfo:SetDamageType( DMG_GENERIC  )
	dmginfo:SetDamage( math.random(25,40) )
	dmginfo:SetDamagePosition( traceworldbeam.HitPos )
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	dmginfo:SetDamageForce( Vector(0,0,0) )
	else
	dmginfo:SetDamageForce( Vector(0,0,20*1000) )
	end
	dmginfo:SetAttacker( self.Owner )
	dmginfo:SetInflictor( self.SensorEnt )
	if v:IsNPC() or v:IsPlayer() or string.find(v:GetClass(),"prop") then
	if vFireInstalled then
	if !v:IsOnFire() then
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 3 or tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	v:Ignite(3)
	end
	end
	else
	if GetConVarNumber("ai_serverragdolls") > 0 then
	if !v.IsSensorEntPC then
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 3 or tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	v:Ignite(10,100)
	end
	end
	end
	end
	end
	v:TakeDamageInfo(dmginfo)
	end
	end
	if vFireInstalled then
	if math.random(1,100) <= 80 then
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 3 or tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then 
	local newFireEnt = CreateVFire(IsValid(traceworldbeam.HitEntity) and traceworldbeam.HitEntity or game.GetWorld(), traceworldbeam.HitPos + traceworldbeam.HitNormal:Angle():Up()*math.Rand(-200,200) + traceworldbeam.HitNormal:Angle():Right()*math.Rand(-200,200), traceworldbeam.HitNormal, 10)
	end
	end
	end
	local owner = self.Owner
	local tracedamagebeam = util.TraceHull( {
	start = self.SensorEnt:GetPos(),
	endpos = self.SensorEnt:GetPos() - Vector(0,0,90000),
	filter = function(ent) if (ent:IsWorld() or (ent:IsPlayer() and ent != owner ) or ent:IsNPC()) then return true end end,
	mins = Vector( -100, -100, -100 ),
	maxs = Vector( 100, 100, 100 )
    } )
	if IsValid(tracedamagebeam.Entity) and tracedamagebeam.Entity and !tracedamagebeam.Entity.InGround and tracedamagebeam.Entity != self.Owner and (tracedamagebeam.Entity:IsPlayer() or tracedamagebeam.Entity:IsNPC() or type( tracedamagebeam.Entity ) == "NextBot") then
	local dmginfo = DamageInfo()
    dmginfo:SetDamageType( DMG_GENERIC  )
	dmginfo:SetDamage( math.random(25,40) )
	dmginfo:SetDamagePosition( traceworldbeam.HitPos )
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	dmginfo:SetDamageForce( Vector(0,0,0) )
	else
	dmginfo:SetDamageForce( Vector(0,0,20*1000) )
	end
	dmginfo:SetAttacker( self.Owner )
	dmginfo:SetInflictor( self.SensorEnt )
	if tracedamagebeam.Entity:IsNPC() or tracedamagebeam.Entity:IsPlayer() then
	if vFireInstalled then
	if !tracedamagebeam.Entity:IsOnFire() then
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 3 or tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	tracedamagebeam.Entity:Ignite(3)
	end
	end
	else
	if GetConVarNumber("ai_serverragdolls") > 0 then
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 3 or tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	tracedamagebeam.Entity:Ignite(10,100)
	end
	end
	end
	end
	tracedamagebeam.Entity:TakeDamageInfo(dmginfo)
	end
	end
	if IsValid(self.Shake) then
	self.Shake:SetPos(traceworldbeam.HitPos)
	if self.NextShake == nil then
	self.NextShake = 0
	end
	if self.NextShake < CurTime() then
	self.NextShake = CurTime() + 0.2
	self.Shake:Fire( "StartShake", "", 0 )
	end
	end
	end
	end
	end
	end
end

function SWEP:Equip()
end


function SWEP:Holster()
if SERVER then
if IsValid(self.SensorEnt) then
self.SensorEnt:Remove()
end
if IsValid(self.Shake) then
if ( self.particle.BeamSound ) then 
self.particle.BeamSound:ChangeVolume( 0, 0.02 ) 
self.particle.BeamSound:Stop() 
self.particle.BeamSound = nil
self.Shake:Remove()
end
end
end
return true
end

function SWEP:OnRemove()
if SERVER then
if IsValid(self.SensorEnt) then
self.SensorEnt:Remove()
end
if IsValid(self.Shake) then
if ( self.particle.BeamSound ) then 
self.particle.BeamSound:ChangeVolume( 0, 0.02 ) 
self.particle.BeamSound:Stop() 
self.particle.BeamSound = nil
self.Shake:Remove()
end
end
end
end

function SWEP:OnDrop()
if SERVER then
if IsValid(self.SensorEnt) then
self.SensorEnt:Remove()
end
if IsValid(self.Shake) then
if ( self.particle.BeamSound ) then 
self.particle.BeamSound:ChangeVolume( 0, 0.02 ) 
self.particle.BeamSound:Stop() 
self.particle.BeamSound = nil
self.Shake:Remove()
end
end
end
end

function SWEP:Deploy()
   self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
   self.Owner:GetViewModel():SetPlaybackRate(4)
   self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration()/4)
   self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration()/4)
   return true
end

function SWEP:DoImpactEffect( tr, nDamageType )
return true
end

function SWEP:PrimaryAttack()
if self:GetNextPrimaryFire() < CurTime() then
if IsValid(self.SensorEnt) then return end
if CLIENT then return end
self.Weapon:SetNextPrimaryFire(CurTime() + 1)
self.Weapon:SetNextSecondaryFire(CurTime() + 1)
local playertrace = self.Owner:GetEyeTrace()
local trace = {}
trace.start = playertrace.HitPos
trace.endpos = trace.start + Vector(0,0,80000)
trace.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworld = util.TraceLine(trace)
if traceworld.HitSky then
local Ang = self.Owner:GetAngles()
Ang.pitch = 0
Ang.roll = Ang.roll
Ang.yaw = Ang.yaw - 180
local ent
	local pos
	local tracesensor = {}
    tracesensor.start = playertrace.HitPos
    tracesensor.endpos = tracesensor.start + Vector(0,0,4200)
    tracesensor.filter = function(ent) if !ent:IsWorld() then return false end end
    local traceworldsensor = util.TraceLine(tracesensor)
    if traceworldsensor.HitSky then
	pos = traceworldsensor.HitPos - Vector(0,0,40)
	else
	pos = playertrace.HitPos + Vector(0,0,4000)
	end
	local height = 4200
	self.SensorEnt = ents.Create("prop_dynamic")
	self.SensorEnt:SetPos(pos)
	self.SensorEnt:SetAngles(Ang)
	self.SensorEnt:SetModel("models/gibs/gunship_gibs_sensorarray.mdl")
	self.SensorEnt:Spawn()
	self.SensorEnt:Activate()
	self.SensorEnt.IsSensorEntPC = true
	self.SensorEnt.BeamType = tonumber(self.Owner:GetInfo("pc_effect_type"))
	self.SensorEnt.EntHeight = height
	self.SensorEnt:SetMaterial("models/effects/vol_light001")
	if IsValid(self) and IsValid(self.Owner) then
	self.SensorEnt.Caller = self.Owner
	else
	self.SensorEnt.Caller = game:GetWorld()
	end
	self.SensorEnt.BeamDamageCooldown = 0
	if SERVER then
	if IsValid(self.SensorEnt) then
	self.SensorEnt.BeamTurnedOn = true
	end
	local tracebeam = {}
    tracebeam.start = trace.start
    tracebeam.endpos = trace.start - Vector(0,0,90000)
    tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
    local traceworldbeam = util.TraceLine(tracebeam)
	if traceworldbeam.Hit then
	if game.SinglePlayer() then
	local LaserBeam = EffectData()
	LaserBeam:SetStart(self.SensorEnt:GetPos())
	LaserBeam:SetOrigin(traceworldbeam.HitPos)
	LaserBeam:SetEntity(self.SensorEnt)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	util.Effect("pc_particle_cannon",LaserBeam)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	util.Effect("pc_ion_cannon",LaserBeam)
	else
	util.Effect("pc_solar_beam",LaserBeam)
	end
	local LaserParticle = EffectData()
	LaserParticle:SetStart(self.SensorEnt:GetPos())
	LaserParticle:SetOrigin(traceworldbeam.HitPos)
	LaserParticle:SetNormal(traceworldbeam.HitNormal)
	LaserParticle:SetEntity(self.SensorEnt)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	util.Effect("pc_particle_cannon_particle",LaserBeam)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	util.Effect("pc_ion_cannon_particle",LaserBeam)
	else
	util.Effect("pc_solar_beam_particle",LaserParticle)
	end
	else
	timer.Simple(0.002,function()
	if IsValid(self.SensorEnt) then
	local LaserBeam = EffectData()
	LaserBeam:SetStart(self.SensorEnt:GetPos())
	LaserBeam:SetOrigin(traceworldbeam.HitPos)
	LaserBeam:SetEntity(self.SensorEnt)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	util.Effect("pc_particle_cannon",LaserBeam)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	util.Effect("pc_ion_cannon",LaserBeam)
	else
	util.Effect("pc_solar_beam",LaserBeam)
	end
	local LaserParticle = EffectData()
	LaserParticle:SetStart(self.SensorEnt:GetPos())
	LaserParticle:SetOrigin(traceworldbeam.HitPos)
	LaserParticle:SetNormal(traceworldbeam.HitNormal)
	LaserParticle:SetEntity(self.SensorEnt)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	util.Effect("pc_particle_cannon_particle",LaserBeam)
	elseif tonumber(self.Owner:GetInfo("pc_effect_type")) == 2 then
	util.Effect("pc_ion_cannon_particle",LaserBeam)
	else
	util.Effect("pc_solar_beam_particle",LaserParticle)
	end
	end
	end)
	end
	self.Target = ents.Create( "info_target" )
	self.Target:SetPos(traceworldbeam.HitPos)
	self.Target:Spawn()
	self.Shake = ents.Create( "env_shake" )
	self.Shake:SetPos( traceworldbeam.HitPos )
	self.Shake:SetKeyValue( "amplitude", "5" )
	self.Shake:SetKeyValue( "radius", "1000" )
	self.Shake:SetKeyValue( "duration", "3" )
	self.Shake:SetKeyValue( "frequency", "255" )
	self.Shake:SetKeyValue( "spawnflags", "4" )
	self.Shake:Spawn()
	self.Shake:Activate()
	self.Shake:Fire( "StartShake", "", 0 )
	local partname = "fire_medium_01"
	self.particle = ents.Create("info_particle_system")
	self.particle:SetAngles(self.Shake:GetAngles())
	self.particle:SetKeyValue("effect_name",partname)
	if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
	self.particle:SetKeyValue("start_active",tostring(1))
	end
	self.particle:Spawn()
	self.particle:Activate()
	self.particle:SetPos(self.Shake:GetPos())
	self.particle:SetParent(self.Shake)
end
end
else
if IsValid(self.SensorEnt) then
self.SensorEnt:Remove()
self.Weapon:SetNextPrimaryFire(CurTime() + 1)
self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end
self.Owner:SendLua("surface.PlaySound('common/wpn_denyselect.wav')")
end
end
end

function SWEP:SecondaryAttack()
  if !(self.Weapon:GetNextPrimaryFire() < CurTime()) then return end
  if self.Owner:KeyDown(IN_ATTACK) then return end
  self:SetNextPrimaryFire( CurTime() + 1 )
  self:CallOnClient("DermaMenuPT", "")
end

function DissolveEntity(ent)
local entnametodissolve = "entname" .. ent:EntIndex()
ent:SetKeyValue("targetname",entnametodissolve)
local dissolver = ents.Create("env_entity_dissolver")
dissolver:SetPos(ent:GetPos())
dissolver:SetKeyValue("target", entnametodissolve)
dissolver:Spawn()
dissolver:SetKeyValue("dissolvetype",3)
dissolver:Fire("Dissolve", entnametodissolve, 0)
dissolver:Fire("kill", "", 0.1)
end

hook.Add("EntityTakeDamage","PCBeam_Disslove",function(target,dmginfo)
if target:IsRagdoll() and IsValid(dmginfo:GetInflictor()) and (dmginfo:GetInflictor().IsSensorEntPC and string.find(dmginfo:GetInflictor():GetClass(),"prop_dynamic")) and dmginfo:GetInflictor().BeamType == 2 then
DissolveEntity(target)
end
if IsValid(target) and (target:IsPlayer() or target:IsNPC() or type( target ) == "NextBot") and IsValid(dmginfo:GetInflictor()) and (dmginfo:GetInflictor().IsSensorEntPC and string.find(dmginfo:GetInflictor():GetClass(),"prop_dynamic")) and SERVER then
local info = dmginfo:GetDamage()
if target:Health() <= info and !target.PCBeamAttacked then
target.PCBeamAttacked = true
if dmginfo:GetInflictor().BeamType == 1 then
target.PCBeamAttackedTypeCustom = true
if game.SinglePlayer() then
local effectdata = EffectData()
effectdata:SetOrigin(target:GetPos())
util.Effect( "particlecannon_burn", effectdata )
else
local pos = target:GetPos()
timer.Simple(0.002,function()
local effectdata = EffectData()
effectdata:SetOrigin(pos)
util.Effect( "particlecannon_burn", effectdata )
end)
end
elseif dmginfo:GetInflictor().BeamType == 3 then
if game.SinglePlayer() then
local effectdata = EffectData()
effectdata:SetOrigin(target:GetPos())
effectdata:SetNormal(Vector(0,0,1))
util.Effect( "solarbeam_disslove", effectdata )
else
local pos = target:GetPos()
timer.Simple(0.002,function()
local effectdata = EffectData()
effectdata:SetOrigin(pos)
effectdata:SetNormal(Vector(0,0,1))
util.Effect( "solarbeam_disslove", effectdata )
end)
end
end
if dmginfo:GetInflictor().BeamType == 1 then
				local corpsestyle = math.random(0,4)
				if target:IsNPC() and (target:GetClass()=="npc_zombie" or 
				target:GetClass()=="npc_citizen" or
				target:GetClass()=="npc_barney" or
				target:GetClass()=="npc_metropolice" or
				target:GetClass()=="npc_alyx" or
				target:GetClass()=="npc_combine_s" or
				target:GetClass()=="npc_vortigaunt" or
				target:GetClass()=="npc_stalker" or
				target:GetClass()=="npc_eli" or
				target:GetClass()=="npc_gman" or
				target:GetClass()=="npc_monk" or
				target:GetClass()=="npc_mossman" or
				target:GetClass()=="npc_fastzombie" or
				target:GetClass()=="npc_poisonzombie" or
				target:GetClass()=="npc_zombie_torso" or
				target:GetClass()=="npc_fastzombie_torso" or
				target:GetClass()=="npc_magnusson" or
				target:GetClass()=="npc_kleiner" or
				target:GetClass()=="npc_zombine" or
				target:GetClass()=="npc_breen") then
					if (corpsestyle == 0) then
					target:SetModel("models/Humans/Charple01.mdl")
					end				
					if (corpsestyle == 1) then
					target:SetModel("models/Humans/Charple01.mdl")
					end
					if (corpsestyle == 2) then
					target:SetModel("models/Humans/Charple02.mdl")
					end
					if (corpsestyle == 3) then
					target:SetModel("models/Humans/Charple03.mdl")
					end
					if (corpsestyle == 4) then
					target:SetModel("models/Humans/Charple04.mdl")
					end
					target:Ignite(10)
end
end
if dmginfo:GetInflictor().BeamType == 2 then
target.PCBeamAttackedIon = true
target:SetShouldServerRagdoll( true )
end
target:SetHealth(0)
if dmginfo:GetInflictor().BeamType == 3 then
for i=1,16 do
local traceline2 = {}
traceline2.start = target:GetPos() + target:GetAngles():Forward()*-15 + Vector(math.Rand(-30,30),math.Rand(-30,30),0)
traceline2.endpos = traceline2.start - Vector(0,0,50)
traceline2.filter = {target}
local trw = util.TraceLine(traceline2)
local decpos1 = trw.HitPos + trw.HitNormal
local decpos2 = trw.HitPos - trw.HitNormal
util.Decal("Dark", decpos1, decpos2) 	
end
end
if target:IsPlayer() then
target:SetShouldServerRagdoll( true )
end
if target:IsNPC() and GetConVarNumber("ai_serverragdolls") == 0 then
if dmginfo:GetInflictor().BeamType == 3 then
dmginfo:SetDamageForce(Vector(0,0,0))
target:SetRenderMode( 4 )
target:SetColor( Color( 255, 255, 255, 0 ) )
target:Remove()
end
end
end
end
end)

local function PlyHitByPCBeam(ply,inflictor,attacker)
if SERVER and IsValid(inflictor) and inflictor.IsSensorEntPC then
if IsValid(ply:GetRagdollEntity()) then
local pos = ply:GetPos()
if inflictor.BeamType == 3 then
timer.Simple(0.002,function()
local effectdata = EffectData()
effectdata:SetOrigin(pos)
effectdata:SetNormal(Vector(0,0,1))
util.Effect( "solarbeam_disslove", effectdata )
end)
ply:GetRagdollEntity():Remove()
end
if inflictor.BeamType == 2 then
ply:GetRagdollEntity():Remove()
end
if inflictor.BeamType == 1 then
local corpsestyle = math.random(0,4)
if (corpsestyle == 0) then
ply:SetModel("models/Humans/Charple01.mdl")
end				
if (corpsestyle == 1) then
ply:SetModel("models/Humans/Charple01.mdl")
end
if (corpsestyle == 2) then
ply:SetModel("models/Humans/Charple02.mdl")
end
if (corpsestyle == 3) then
ply:SetModel("models/Humans/Charple03.mdl")
end
if (corpsestyle == 4) then
ply:SetModel("models/Humans/Charple04.mdl")
end
ply:GetRagdollEntity():Remove()
end
end
end
end
hook.Add("PlayerDeath", "PlyHitByPCBeam",PlyHitByPCBeam)

local function pcremoverageffect(ent,ragdoll)
if ent.PCBeamAttacked and !ent.PCBeamAttackedTypeCustom and !ent.PCBeamAttackedIon and SERVER then
ragdoll:Remove()
end
if ent.PCBeamAttackedIon and SERVER then
DissolveEntity(ragdoll)
end
end
hook.Add("CreateEntityRagdoll", "pcremoverageffect",pcremoverageffect)

function SWEP:DermaMenuPT()
    if dermamenu == nil then
        local Lines
        dermamenu = vgui.Create("DFrame")
        dermamenu:SetSize(200, 100)
        dermamenu:SetPos(ScrW()/2.55, ScrH()/2.3)
        dermamenu:SetTitle("Particle Cannon")
        dermamenu:SetSizable(true)
        dermamenu:SetDeleteOnClose(false)
        dermamenu:ShowCloseButton(false)
        dermamenu:SetDeleteOnClose(true)
		dermamenu:ShowCloseButton(true)
        dermamenu:MakePopup()
		dermamenu.OnClose = function()
        dermamenu = nil
        end
		Lines = vgui.Create( "DPanel" )
        Lines:SetPos(-5,25)
        Lines:SetSize( 200, 70 )
		Lines:SetParent(dermamenu)
        Lines.Paint = function()
        draw.RoundedBox(10, 10, 0, Lines:GetWide() - 10 , Lines:GetTall() , Color(145, 145, 145, 255))
		end
		local dModeMC = vgui.Create("DComboBox")
        dModeMC:SetParent(dermamenu)
        dModeMC:SetPos(50, 30)
        dModeMC:SetSize(100, 25)
        dModeMC.OnSelect = function( self, index, value )
		RunConsoleCommand("pc_effect_type", index)
		end

        dModeMC:AddChoice("Particle Cannon")
        dModeMC:AddChoice("Ion Cannon")
		dModeMC:AddChoice("Solar Beam")

        dModeMC:ChooseOptionID(tonumber(LocalPlayer():GetInfo("pc_effect_type")))
		local DermaNumSlider = vgui.Create( "DLabel", dermamenu )
        DermaNumSlider:SetPos( 50, 60 )
        DermaNumSlider:SetSize( 100, 25 )
        DermaNumSlider:SetText( "Select beam type" )
		DermaNumSlider:SetWide(150)
	end
end


if CLIENT then
/*---------------------------------------------------------
	Solar Beam effect
---------------------------------------------------------*/

local sparks = Material("effects/spark")
local solarmuzzle = Material("effects/splashwake1")
local solarmuzzle2 = Material("effects/yellowflare")
local solarbeam = Material( "effects/solarbeam" )
local solarbeam2 = Material( "Effects/blueblacklargebeam" )
local glow = CreateMaterial("glow01", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 3, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
local glow2 = Material( "particle/particle_glow_04_additive" )

local EFFECT={}


function EFFECT:Init(data)
self.ParentEntity = data:GetEntity()
self.BeamWidth = 20
self.BeamSpriteSize = 80
self.MinSize = 500
self.MinSize2 = 480
end

function EFFECT:Think()
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
end
if !IsValid(self.ParentEntity) then return false end
return true
end

function EFFECT:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))

self.BeamDistance = (self.StartPos - self.Orig):Length()


local start_pos = self.StartPos
local end_pos = self.Orig
local dir = ( end_pos - start_pos );
local mindist = math.Clamp(self.MinSize + dir:Length()/8,500,500)
local mindist2 = math.Clamp(self.MinSize2 + dir:Length()/8,480,480)
local maxdist = math.Clamp(dir:Length()/200,2,15)
local increment = dir:Length()  / (tonumber(LocalPlayer():GetInfo("pc_effect_length") or 8.95));
dir:Normalize();
 
// set material
render.SetMaterial( solarbeam2 )
 
// start the beam with 14 points
for i=1,5 do
render.StartBeam( increment );
//
local i;
for i = 1, 10 do
	// get point
	local point = start_pos + dir * ( (i - 1) * increment ) + VectorRand() * math.random( 1, maxdist )
    render.SetMaterial( solarbeam )
	// texture coords
	local tcoord = CurTime() + ( 1 / 30 ) * -i;
 
	// add point
	render.AddBeam(
		point + VectorRand()*50,
		mindist2,
		tcoord*2,
		Color( 255,255,255,255 )
	);
 
end
 
// finish up the beam
render.EndBeam();

end
end

effects.Register(EFFECT, "pc_solar_beam", true)

local EFFECT2={}


function EFFECT2:Init(data)
self.ParentEntity = data:GetEntity()
self.Orig = data:GetOrigin()
self.Norm = data:GetNormal()
self.ParticleLife = CurTime() + 2
self.ParticleTime = 0
self.ParticleNum = 0
self.MuzzleSize = 50
self.MuzzleSize2 = 50
end

function EFFECT2:Think()
if self.ParticleTime < CurTime() then
local emmiter = ParticleEmitter(self.Orig,false)
for i=0,(math.Round(1 + self.ParticleNum)) do
	local particle = emmiter:Add(sparks,self.Orig + Vector(math.Rand(math.Rand(-350,-200),math.Rand(200,350)),math.Rand(math.Rand(-350,-200),math.Rand(200,350)),math.Rand(0,150)))
		if particle then
			particle:SetLifeTime(0)
			particle:SetDieTime( math.Clamp(0.1+(self.ParticleNum/math.Rand(30,40)),0.1,3) )
			particle:SetAirResistance(300)
			particle:SetStartAlpha( math.Rand( 0, 30 ) )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( math.Rand(3,6) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( 0 )
			particle:SetColor(255,255,255,255)
			particle:SetGravity(Vector(math.Rand(math.Rand(-500,-500),math.Rand(500,500)),math.Rand(math.Rand(-500,-500),math.Rand(500,500)),math.Clamp(50+(self.ParticleNum*math.Rand(9,15)),50,2000)))
		end
	end
	self.ParticleTime = CurTime() + 0.1
end
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
end
if !IsValid(self.ParentEntity) then
return false 
end
return true
end

function EFFECT2:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self.Norm = traceworldbeam.HitNormal
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
self.ParticleNum = math.Clamp(self.ParticleNum + (FrameTime()*40),0,200)
self.MuzzleSize = math.Clamp(self.MuzzleSize + FrameTime()*1600*2,0,1000)
self.MuzzleSize2 = math.Clamp(self.MuzzleSize2 + FrameTime()*1600*2,0,2500)
render.SetMaterial(solarmuzzle)
render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize,self.MuzzleSize,Color(255,255,0,255),CurTime()*-720)
render.SetMaterial(solarmuzzle2)
render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize2,self.MuzzleSize2,Color(255,255,255,255),CurTime()*-720)
render.SetMaterial(glow)
render.DrawSprite(self.Orig + Vector(0,0,20),1000,1000,Color(255,255,0,255))
render.SetMaterial(glow2)
render.DrawQuadEasy(self.StartPos,self.ParentEntity:GetAngles():Up()*-1,self.MuzzleSize,self.MuzzleSize,Color(255,255,0,255),CurTime()*-720)
end

effects.Register(EFFECT2, "pc_solar_beam_particle", true)

local EFFECT3={}

function EFFECT3:Init( data )
self.Position = data:GetOrigin()
self.Angle = data:GetNormal()
self.Angle.z = 0.4*self.Angle.z

local Emitter = ParticleEmitter(self.Position)

	if Emitter then
		for i=1,50 do
			local particle = Emitter:Add( "effects/fleck_antlion"..math.random(1,2), self.Position + Vector(math.Rand(-8,8),math.Rand(-8,8),math.Rand(-32,32)))
				particle:SetVelocity( self.Angle*math.Rand(256,385) + VectorRand()*64)
				particle:SetLifeTime( math.Rand(-0.3, 0.1) )
				particle:SetDieTime( math.Rand(0.7, 1) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1.5, 1.7) )
				particle:SetEndSize( math.Rand( 1.8, 2) )
				particle:SetRoll( math.Rand( 360, 520 ) )
				particle:SetRollDelta( math.random( -2, 2 ) )
				particle:SetColor( 70, 70, 70 )	
		end
	
		
		for i=1,20 do
			local particle = Emitter:Add( "particles/smokey", self.Position + Vector(math.Rand(-8,9),math.Rand(-8,8),math.Rand(-32,32)) - self.Angle*8)
				particle:SetVelocity( self.Angle*math.Rand(256,385) + VectorRand()*64  )
				particle:SetDieTime( math.Rand(0.4, 0.8) )
				particle:SetStartAlpha( 140 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 8, 12) )
				particle:SetEndSize( math.Rand( 24, 32) )
				particle:SetRoll( math.Rand( 360, 520 ) )
				particle:SetRollDelta( math.random( -2, 2 ) )
				particle:SetColor( 50, 50, 50 )	
		end

		Emitter:Finish()
	end
end


function EFFECT3:Think()
	return false
end


function EFFECT3:Render()
end


effects.Register(EFFECT3, "pc_solarbeam_disslove" )

/*---------------------------------------------------------
	Particle Cannon effect
---------------------------------------------------------*/

local sparks = Material("effects/spark")
local solarmuzzle = Material("effects/splashwake1")
local solarmuzzle2 = Material("effects/yellowflare")
local particlecannonbeam = Material( "effects/pc_beam" )
local glow = CreateMaterial("glow01", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 3, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
local glow2 = Material( "particle/particle_glow_04_additive" )

local EFFECT={}


function EFFECT:Init(data)
self.ParentEntity = data:GetEntity()
self.BeamWidth = 20
self.BeamSpriteSize = 80
self.MinSize = 500
self.MinSize2 = 480
end

function EFFECT:Think()
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
end
if !IsValid(self.ParentEntity) then return false end
return true
end

function EFFECT:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))

self.BeamDistance = (self.StartPos - self.Orig):Length()


local start_pos = self.StartPos
local end_pos = self.Orig
local dir = ( end_pos - start_pos );
local mindist = math.Clamp(self.MinSize + dir:Length()/8,500,500)
local mindist2 = math.Clamp(self.MinSize2 + dir:Length()/8,480,480)
local maxdist = math.Clamp(dir:Length()/200,2,15)
local increment = dir:Length()  / (tonumber(LocalPlayer():GetInfo("pc_effect_length") or 8.95));
dir:Normalize();
 
// set material
render.SetMaterial( particlecannonbeam )
 
// start the beam with 14 points
for i=1,5 do
render.StartBeam( increment  );
//
local i;
for i = 1, 10 do
	// get point
	local point = start_pos + dir * ( (i - 1) * increment ) + VectorRand() * math.random( 1, maxdist )
    render.SetMaterial( particlecannonbeam )
	// texture coords
	local tcoord = 0.5;
 
	// add point
	render.AddBeam(
		point + VectorRand()*10,
		mindist2,
		tcoord,
		Color( 255,255,255,255 )
	);
 
end
 
// finish up the beam
render.EndBeam();

end
end

effects.Register(EFFECT, "pc_particle_cannon", true)

local EFFECT2={}


function EFFECT2:Init(data)
self.ParentEntity = data:GetEntity()
self.Orig = data:GetOrigin()
self.Norm = data:GetNormal()
self.ParticleLife = CurTime() + 2
self.ParticleTime = 0
self.ParticleNum = 0
self.MuzzleSize = 50
self.MuzzleSize2 = 50
end

function EFFECT2:Think()
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
if self.ParticleTime < CurTime() then
local emmiter = ParticleEmitter(self.Orig,false)
for i=0,math.Rand(2,6) do
local velocity = ( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(30,70)) ):GetNormalized()
velocity:Mul( math.Rand( 100, 125 ) )
local particle = emmiter:Add( "effects/energysplash", self.Orig )
particle:SetVelocity( velocity*5 )
particle:SetDieTime( math.Rand(2,4) )
particle:SetStartSize( math.Rand( 10, 25 ) )
particle:SetEndSize( 2 )
particle:SetStartAlpha( 255 )
particle:SetEndAlpha( 0 )
particle:SetStartLength( math.random(80,100) )
particle:SetEndLength( math.random(30,50) )
particle:SetAirResistance( 5 )
particle:SetGravity( Vector(0,0,math.Rand(-200,-100)) )
particle:SetColor( 255,255,255 )
end
--[[
local emmiter = ParticleEmitter(self.Orig,false)
for i=0,(math.Round(1 + self.ParticleNum)) do
	local particle = emmiter:Add(sparks,self.Orig + Vector(math.Rand(math.Rand(-350,-200),math.Rand(200,350)),math.Rand(math.Rand(-350,-200),math.Rand(200,350)),math.Rand(0,150)))
		if particle then
			particle:SetLifeTime(0)
			particle:SetDieTime( math.Clamp(0.1+(self.ParticleNum/math.Rand(30,40)),0.1,3) )
			particle:SetAirResistance(300)
			particle:SetStartAlpha( math.Rand( 0, 30 ) )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( math.Rand(3,6) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( 0 )
			particle:SetColor(255,255,255,255)
			particle:SetGravity(Vector(math.Rand(math.Rand(-500,-500),math.Rand(500,500)),math.Rand(math.Rand(-500,-500),math.Rand(500,500)),math.Clamp(50+(self.ParticleNum*math.Rand(9,15)),50,2000)))
		end
	end
--]]
self.ParticleTime = CurTime() + 0.4
end
end
if !IsValid(self.ParentEntity) then
return false 
end
return true
end

function EFFECT2:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self.Norm = traceworldbeam.HitNormal
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
self.ParticleNum = math.Clamp(self.ParticleNum + (FrameTime()*40),0,200)
self.MuzzleSize = math.Clamp(self.MuzzleSize + FrameTime()*1600*2,0,1000)
self.MuzzleSize2 = math.Clamp(self.MuzzleSize2 + FrameTime()*1600*2,0,2500)
render.SetMaterial(solarmuzzle)
render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize,self.MuzzleSize,Color(255,255,255,255),CurTime()*-720)
render.SetMaterial(solarmuzzle2)
render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize2,self.MuzzleSize2,Color(255,255,255,255),CurTime()*-720)
render.SetMaterial(glow)
render.DrawSprite(self.Orig + Vector(0,0,20),1000,1000,Color(255,255,255,255))
render.SetMaterial(glow2)
render.DrawQuadEasy(self.StartPos,self.ParentEntity:GetAngles():Up()*-1,self.MuzzleSize,self.MuzzleSize,Color(255,255,255,255),CurTime()*-720)
end

effects.Register(EFFECT2, "pc_particle_cannon_particle", true)

if (CLIENT) then
local EFFECT={}

function EFFECT:Init( data )
	self.Position = data:GetOrigin()
	local Pos = self.Position
	local Norm = Vector(0,0,1)
	Pos = Pos + Norm * 6
	local emitter = ParticleEmitter( Pos )
		for i=1, 16 do
			local particle = emitter:Add( "particles/flamelet"..math.random( 1, 5 ), Pos + Vector(math.random(-20,20),math.random(-20,20),math.random(-30,50)))
				particle:SetVelocity( Vector(math.random(-30,30),math.random(-30,30),math.random(90,120)) )
				particle:SetDieTime( math.Rand( 1.6, 1.8 ) )
				particle:SetStartAlpha( math.Rand( 200, 240 ) )
				particle:SetStartSize( 16 )
				particle:SetEndSize( math.Rand( 48, 64 ) )
				particle:SetRoll( math.Rand( 360, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( math.Rand( 150, 255 ), math.Rand( 100, 150 ), 100 )
			end
		for i=1, 18 do
		local particle = emitter:Add( "particles/smokey", Pos + Vector(math.random(-25,25),math.random(-25,25),math.random(-30,70)))
			particle:SetVelocity( Vector(math.random(-30,30),math.random(-30,30),math.random(35,50)) )
			particle:SetDieTime( math.Rand( 2.4, 2.9 ) )
			particle:SetStartAlpha( math.Rand( 160, 200 ) )
			particle:SetStartSize( 24 )
			particle:SetEndSize( math.Rand( 32, 48 ) )
			particle:SetRoll( math.Rand( 360, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 20, 20, 20 )
		end
	emitter:Finish()
	
end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()
		
end
effects.Register( EFFECT, "particlecannon_burn" )

local EFFECT={}
    
function EFFECT:Init( data )
        self.Ent = data:GetEntity()
 
        self:SetModel("models/XQM/Rails/gumball_1.mdl")
		self:SetMaterial("lights/White002")
		self:SetRenderMode( 4 )
		self.Alpha = 120
		self.Alpha2 = 255
		self:SetColor(Color(229,0,255,self.Alpha))
		self.LifeTime = CurTime() + 4
		self.Size = 4
        self.CircleSize = 4		
end
	
function EFFECT:Think( )
    if !(self.LifeTime < CurTime()) then
	if self.Ent != NULL then
	self.StartPos = self.Ent:GetPos()
	local tracebeam = {}
	tracebeam.start = self.StartPos
	tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
	tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
	local traceworldbeam = util.TraceLine(tracebeam)
	self.Orig = traceworldbeam.HitPos

	self:SetPos(self.Orig)
	end
		if self.Size >= 40 then 
	    self.Size = -1
		self:SetModelScale( self.Size, 0 )
		return false
	    end
	return true 
	end
	return false 
end
local circle = Material("particle/particle_ring_wave_additive")
function EFFECT:Render() 
if self.Ent != NULL then
self.StartPos = self.Ent:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos

self:SetPos(self.Orig)

if self.CircleSize > -1 and self.CircleSize < 1000 then
self.CircleSize = math.Clamp(self.CircleSize + FrameTime()*800,4,1000)
end
if self.Size >= 1000 then
self.CircleSize = -1
end

self.Alpha2 = math.Clamp(self.Alpha2 - FrameTime()*160,0,255)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,5),self.Ent:GetAngles():Up(),self.CircleSize,self.CircleSize,Color(255,0,191,self.Alpha2),0)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,150),self.Ent:GetAngles():Up(),self.CircleSize - 50,self.CircleSize - 50,Color(255,0,191,self.Alpha2),0)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,240),self.Ent:GetAngles():Up(),self.CircleSize - 300,self.CircleSize - 300,Color(255,0,191,self.Alpha2),0)

self.Alpha = math.Clamp(self.Alpha - FrameTime()*80,0,120)
self:SetColor(Color(229,0,255,self.Alpha))
if self.Size > -1 and self.Size < 40 then
self.Size = math.Clamp(self.Size + FrameTime()*20,4,40)
self:SetModelScale( self.Size, 0 )
else
self:Remove()
end
if self.Size != 40 and self.Size != -1  then
self:DrawModel()
else
self:SetNoDraw(true)
self:Remove()
end
render.SetShadowColor( 255, 255, 255 )
end
end
effects.Register(EFFECT,"pc_particle_cannon_particle2")

/*---------------------------------------------------------
	Ion Cannon effect
---------------------------------------------------------*/

local sparks = Material("effects/spark")
local solarmuzzle = Material("effects/splashwake1")
local solarmuzzle2 = Material("effects/yellowflare")
local ioncannonbeam = Material( "effects/pc_ionbeam" )
local glow = CreateMaterial("glow01", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 3, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
local glow2 = Material( "particle/particle_glow_04_additive" )

local EFFECT={}


function EFFECT:Init(data)
self.ParentEntity = data:GetEntity()
self.BeamWidth = 20
self.BeamSpriteSize = 80
self.MinSize = 500
self.MinSize2 = 480
end

function EFFECT:Think()
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
end
if !IsValid(self.ParentEntity) then return false end
return true
end

function EFFECT:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))

self.BeamDistance = (self.StartPos - self.Orig):Length()


local start_pos = self.StartPos
local end_pos = self.Orig
local dir = ( end_pos - start_pos );
local mindist = math.Clamp(self.MinSize + dir:Length()/8,500,500)
local mindist2 = math.Clamp(self.MinSize2 + dir:Length()/8,480,480)
local maxdist = math.Clamp(dir:Length()/200,2,15)
local increment = dir:Length()  / (tonumber(LocalPlayer():GetInfo("pc_effect_length") or 8.95));
dir:Normalize();
 
// set material
render.SetMaterial( ioncannonbeam )
 
// start the beam with 14 points
for i=1,5 do
render.StartBeam( increment  );
//
local i;
for i = 1, 10 do
	// get point
	local point = start_pos + dir * ( (i - 1) * increment ) + VectorRand() * math.random( 1, maxdist )
    render.SetMaterial( ioncannonbeam )
	// texture coords
	local tcoord = 0.5;
 
	// add point
	render.AddBeam(
		point + VectorRand()*10,
		mindist2,
		tcoord,
		Color( 255,255,255,255 )
	);
 
end
 
// finish up the beam
render.EndBeam();

end
end

effects.Register(EFFECT, "pc_ion_cannon", true)

local EFFECT2={}

local glow_ion = CreateMaterial("glow_ion", "UnlitGeneric", {["$basetexture"] = "effects/fluttercore", ["$spriterendermode"] = 3, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})

function EFFECT2:Init(data)
self.ParentEntity = data:GetEntity()
self.Orig = data:GetOrigin()
self.Norm = data:GetNormal()
self.ParticleLife = CurTime() + 2
self.ParticleTime = 0
self.ParticleNum = 0
self.MuzzleSize = 50
self.MuzzleSize2 = 50
end

function EFFECT2:Think()
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
if self.ParticleTime < CurTime() then
local emmiter = ParticleEmitter(self.Orig,false)
for i=0,math.Rand(10,20) do
local velocity = ( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(30,70)) ):GetNormalized()
velocity:Mul( math.Rand( 100, 125 ) )
local particle = emmiter:Add( "effects/energysplash", self.Orig )
particle:SetVelocity( velocity*10 )
particle:SetDieTime( math.Rand(2,4) )
particle:SetStartSize( math.Rand( 10, 25 ) )
particle:SetEndSize( 2 )
particle:SetStartAlpha( 255 )
particle:SetEndAlpha( 0 )
particle:SetStartLength( math.random(140,180) )
particle:SetEndLength( math.random(30,50) )
particle:SetColor( 255,255,255 )
end
for i=1,15 do
		local particle = emmiter:Add("particle/particle_smokegrenade", self.Orig + Vector(math.Rand(-2,2),math.Rand(-2,2),0)*2)
		particle:SetVelocity(Vector(math.Rand(-3,3),math.Rand(-3,3),math.Rand(0,5))*math.random(400,800))
		particle:SetDieTime(math.Rand(5,10))
		particle:SetStartAlpha(math.Rand(140,200))
		particle:SetStartSize(math.Rand(120,160))
		particle:SetEndSize(math.Rand(100,120))
		particle:SetColor(255,255,255)
		particle:SetAirResistance(500)
		particle:SetRoll(math.Rand(150,180))
        particle:SetRollDelta(math.Rand(-1.6,1.6))
end
for i=1,40 do
		local particle = emmiter:Add("particle/particle_smokegrenade", self.Orig + Vector(math.Rand(-2,2),math.Rand(-2,2),0)*20)
		particle:SetVelocity(Vector(math.Rand(-4,4),math.Rand(-4,4),math.Rand(2,4))*math.random(30,40))
		particle:SetDieTime(math.Rand(5,10))
		particle:SetStartAlpha(math.Rand(140,200))
		particle:SetStartSize(math.Rand(50,70))
		particle:SetEndSize(math.Rand(100,120))
		particle:SetColor(255,255,255)
		particle:SetAirResistance(500)
		particle:SetRoll(math.Rand(150,180))
        particle:SetRollDelta(math.Rand(-1.6,1.6))
		particle:SetAirResistance(1)
		particle:SetGravity(Vector(0,0,math.random(-100,-50)))
end	
for i=1, 256 do
local part = emmiter:Add("particle/particle_noisesphere", self.Orig ) 
if part then
part:SetColor(255,255,255)
part:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal() * math.random(1100,1500))
part:SetDieTime(math.random(0.5,1))
local siz = math.random(40,60)
part:SetStartSize(siz)
part:SetEndSize(siz)
part:SetAirResistance(140)
part:SetRollDelta(math.random(-2,2))
end
end
for i=0,math.Rand(6,9) do
local velocity = ( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(0,30)) ):GetNormalized()
velocity:Mul( math.Rand( 100, 125 ) )
local pos = self.Orig + Vector(math.Rand(-350,350),math.Rand(-350,350),math.Rand(0,20))
local particle = emmiter:Add( glow_ion,  pos )
particle:SetVelocity( velocity )
particle:SetDieTime( math.Rand(1,1.5) )
particle:SetStartSize( math.Rand( 10, 25 ) )
particle:SetEndSize( 2 )
particle:SetStartAlpha( 255 )
particle:SetEndAlpha( 0 )
particle:SetAirResistance( 5 )
particle:SetGravity( Vector(0,0,math.Rand(-10,10)) )
particle:SetColor(255, 255, 255)
end
for i=0,math.Rand(26,40) do
local velocity = ( Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(0,10)) ):GetNormalized()
velocity:Mul( math.Rand( 100, 125 ) )
local pos = self.Orig + Vector(math.Rand(-350,350),math.Rand(-350,350),math.Rand(0,20))
local particle = emmiter:Add( "particle/particle_noisesphere", pos )
particle:SetVelocity( velocity )
particle:SetDieTime( math.Rand(0.5,1) )
particle:SetStartSize( math.Rand( 10, 25 ) )
particle:SetEndSize( 2 )
particle:SetStartAlpha( 255 )
particle:SetEndAlpha( 0 )
particle:SetAirResistance( 5 )
particle:SetGravity( Vector(0,0,math.Rand(-10,10)) )
particle:SetColor(255, 255, math.random(230,255))
particle:SetRoll( math.Rand( 20, 80 ) )
particle:SetRollDelta( math.random( -1, 1 ) )
end
--[[
local emmiter = ParticleEmitter(self.Orig,false)
for i=0,(math.Round(1 + self.ParticleNum)) do
	local particle = emmiter:Add(sparks,self.Orig + Vector(math.Rand(math.Rand(-350,-200),math.Rand(200,350)),math.Rand(math.Rand(-350,-200),math.Rand(200,350)),math.Rand(0,150)))
		if particle then
			particle:SetLifeTime(0)
			particle:SetDieTime( math.Clamp(0.1+(self.ParticleNum/math.Rand(30,40)),0.1,3) )
			particle:SetAirResistance(300)
			particle:SetStartAlpha( math.Rand( 0, 30 ) )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( math.Rand(3,6) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( 0 )
			particle:SetColor(255,255,255,255)
			particle:SetGravity(Vector(math.Rand(math.Rand(-500,-500),math.Rand(500,500)),math.Rand(math.Rand(-500,-500),math.Rand(500,500)),math.Clamp(50+(self.ParticleNum*math.Rand(9,15)),50,2000)))
		end
	end
--]]
self.ParticleTime = CurTime() + 0.4
end
end
if !IsValid(self.ParentEntity) then
return false 
end
return true
end

function EFFECT2:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self.Norm = traceworldbeam.HitNormal
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
self.ParticleNum = math.Clamp(self.ParticleNum + (FrameTime()*40),0,200)
self.MuzzleSize = math.Clamp(self.MuzzleSize + FrameTime()*1600*2,0,1000)
self.MuzzleSize2 = math.Clamp(self.MuzzleSize2 + FrameTime()*1600*2,0,2500)
render.SetMaterial(solarmuzzle)
render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize,self.MuzzleSize,Color(255,255,255,255),CurTime()*-720)
render.SetMaterial(solarmuzzle2)
render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize2,self.MuzzleSize2,Color(255,255,255,255),CurTime()*-720)
render.SetMaterial(glow)
render.DrawSprite(self.Orig + Vector(0,0,20),1000,1000,Color(255,255,255,255))
render.SetMaterial(glow2)
render.DrawQuadEasy(self.StartPos,self.ParentEntity:GetAngles():Up()*-1,self.MuzzleSize,self.MuzzleSize,Color(255,255,255,255),CurTime()*-720)
end

effects.Register(EFFECT2, "pc_ion_cannon_particle", true)

local EFFECT={}
    
function EFFECT:Init( data )
        self.Ent = data:GetEntity()
 
        self:SetModel("models/XQM/Rails/gumball_1.mdl")
		self:SetMaterial("lights/White002")
		self:SetRenderMode( 4 )
		self.Alpha = 120
		self.Alpha2 = 255
		self:SetColor(Color(0,161,255,self.Alpha))
		self.LifeTime = CurTime() + 4
		self.Size = 4
        self.CircleSize = 4		
end
	
function EFFECT:Think( )
    if !(self.LifeTime < CurTime()) then
	if self.Ent != NULL then
	self.StartPos = self.Ent:GetPos()
	local tracebeam = {}
	tracebeam.start = self.StartPos
	tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
	tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
	local traceworldbeam = util.TraceLine(tracebeam)
	self.Orig = traceworldbeam.HitPos

	self:SetPos(self.Orig)
	end
		if self.Size >= 60 then 
	    self.Size = -1
		self:SetModelScale( self.Size, 0 )
		return false
	    end
	return true 
	end
	return false 
end
local circle = Material("particle/particle_ring_wave_additive")
function EFFECT:Render() 
if self.Ent != NULL then
self.StartPos = self.Ent:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos

self:SetPos(self.Orig)

--[[
if self.CircleSize > -1 and self.CircleSize < 1400 then
self.CircleSize = math.Clamp(self.CircleSize + FrameTime()*800,4,1400)
end
if self.Size >= 1400 then
self.CircleSize = -1
end

self.Alpha2 = math.Clamp(self.Alpha2 - FrameTime()*160,0,255)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,5),self.Ent:GetAngles():Up(),self.CircleSize,self.CircleSize,Color(0,161,255,self.Alpha2),0)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,150),self.Ent:GetAngles():Up(),self.CircleSize - 50,self.CircleSize - 50,Color(0,161,255,self.Alpha2),0)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,240),self.Ent:GetAngles():Up(),self.CircleSize - 300,self.CircleSize - 300,Color(0,161,255,self.Alpha2),0)
--]]

self.Alpha = math.Clamp(self.Alpha - FrameTime()*80,0,120)
self:SetColor(Color(0,161,255,self.Alpha))
if self.Size > -1 and self.Size < 60 then
self.Size = math.Clamp(self.Size + FrameTime()*20,4,60)
self:SetModelScale( self.Size, 0 )
else
self:Remove()
end
if self.Size != 60 and self.Size != -1  then
self:DrawModel()
else
self:SetNoDraw(true)
self:Remove()
end
render.SetShadowColor( 255, 255, 255 )
end
end
effects.Register(EFFECT,"pc_ion_cannon_particle2")
end
end

local function ActivateCLPropPhysics()
    if CLIENT then return end
	local sphereprop = ents.Create("prop_physics")
	sphereprop:SetPos(Vector(-99999,-99999,-99999))
	sphereprop:SetModel("models/hunter/misc/sphere025x025.mdl")
	sphereprop:SetAngles(Angle(0,0,0))
	sphereprop:Spawn()
	sphereprop:Fire("kill",0,1)
end

local clprop_checked
if clprop_checked then return end
clprop_checked = true
ActivateCLPropPhysics()
clprop_checked = false