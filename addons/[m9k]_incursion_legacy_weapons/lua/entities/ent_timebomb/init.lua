AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("timebomb_set")

sound.Add( {
	name = "bomb_activated",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 80,
	pitch = 22,
	sound = "npc/attack_helicopter/aheli_crash_alert2.wav"
} )

function ENT:Initialize()
    self.Entity:SetModel( 'models/weapons/w_c4_planted.mdl' )
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetUseType(SIMPLE_USE)
    self:SetTimeToExplode(35)
    local phys = self.Entity:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:OnRemove()
	self:StopSound("bomb_activated")
end

local function StartFuse(aaa,ply)
	if(not aaa:GetStarted())then
		aaa:EmitSound("buttons/blip1.wav",100,200)
		aaa:SetStarted(1)
		aaa:SetStartTime(CurTime())
		timer.Simple(aaa:GetTimeToExplode(),function()
			if aaa:IsValid()then
				local pos=aaa:GetPos()
				util.BlastDamage(aaa,ply,pos,1000,1000)
				local data=EffectData()
				data:SetOrigin(pos)
				data:SetAngles(Angle(0,0,90))
				util.Effect("nuke_blastwave_fallout",data,true,true);
				aaa:StopSound("bomb_activated")
				aaa:Remove()
			end
		end)
	end
end
function TimeBomb_SetTime(ply,cmd,args)
	local explodetime=args[2]
	if not args[1] then return end
	local bomb=Entity(args[1])
	if(bomb==nil)then return end
	if(!bomb:GetStarted())then
		local TimeToExplode=tonumber(explodetime)
		if(ply:GetPos():Distance(bomb:GetPos())>256)then return end
		if(TimeToExplode==nil)then
			ply:PrintMessage(HUD_PRINTTALK,"Number contains invalid characters!")
			return
		end
		if(TimeToExplode>600 or TimeToExplode<30)then
			ply:PrintMessage(HUD_PRINTTALK,"Time cannot be less than 00:10 or greater than 10:00!")
			return
		end
		bomb:SetTimeToExplode(TimeToExplode)
		StartFuse(bomb,ply)
		bomb:EmitSound("bomb_activated")

		local fx = ents.Create("prop_physics")
		fx:SetModel(bomb:GetModel())
		fx:SetPos(bomb:GetPos())
		fx:SetAngles(bomb:GetAngles())
		fx:SetParent(bomb)
		fx:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		fx:SetMaterial("Models/effects/comball_sphere")
		fx:SetColor(Color(0,255,0))
		fx:Spawn()
		fx:EmitSound("npc/attack_helicopter/aheli_damaged_alarm1.wav", 60, 70)
	end
end

function ENT:Use(activator,caller)
	if activator:IsPlayer() && !self:GetStarted() then
		net.Start("timebomb_set")
		net.WriteEntity(self)
		net.WriteString(self:GetTimeToExplode())
		net.Send(activator)
	elseif self:GetStarted() && activator:getSpecial("I") < 10 && SERVER then
		activator:falloutNotify("[ ! ]  You need at least 10 intelligence to defuse the bomb!", "ui/notify.mp3")
	elseif self:GetStarted() && activator:getSpecial("I") >= 10 && SERVER then
		activator:falloutNotify("[ ! ]  You have defused the bomb!", "ui/goodkarma.ogg")

		local defusedBomb = ents.Create("prop_physics")
		defusedBomb:SetModel(self:GetModel())
		defusedBomb:SetPos(self:GetPos())
		defusedBomb:SetAngles(self:GetAngles())
		defusedBomb:Spawn()

		self:EmitSound("ambient/energy/zap" .. math.random(1,9) .. ".wav")

		timer.Simple(100, function()
			if IsValid(defusedBomb) then
				defusedBomb:Remove()
			end
		end)

		self:Remove()
	end

end
concommand.Add("timebomb_settime",TimeBomb_SetTime)
function ENT:SpawnFunction(ply,tr)
	if(not util.IsValidModel("models/weapons/w_c4_planted.mdl"))then
		ply:PrintMessage(HUD_NOTIFY,"Sorry, you must have CS:S mounted for this!")
		return
	end
	if not tr.Hit then return end
	local pos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create(ClassName)
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	return ent
end
