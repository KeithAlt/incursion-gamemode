
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "TX225 Cannon Blast"
ENT.Author = "Cody Evans"
--- Base by Liam0102 ---
ENT.Category = "Star Wars"
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

if SERVER then
	AddCSLuaFile()
	function ENT:Initialize()

		self:SetModel("models/props_junk/PopCan01a.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:StartMotionController();
		self:SetUseType(SIMPLE_USE);
		self:SetRenderMode(RENDERMODE_TRANSALPHA);
		self:SetColor(Color(255,255,255,1));
		self:SetNWBool("White",self.IsWhite);
		self:SetNWInt("StartSize",self.StartSize or 20);
		self:SetNWInt("EndSize",self.EndSize or 15);
		self.Damage = 300;
	end

	function ENT:Prepare(e,s,gravity,vel,ang)
		e:EmitSound(s)
		local phys = self:GetPhysicsObject();
		phys:SetMass(100);
		phys:EnableGravity(gravity);
		phys:SetVelocity(ang*(-200000))
	end

    function ENT:PhysicsCollide(data, physobj)
		local pos = self:GetPos()+self:GetForward()*math.random(-self.Damage/2,self.Damage/2)+self:GetRight()*math.random(-self.Damage/2,self.Damage/2)
		local fx = EffectData()
		fx:SetOrigin(pos);
		util.Effect("effect_fo3_teslahit",fx,true,true);
		for k,v in pairs(ents.FindInSphere(self:GetPos(),300)) do
			v:TakeDamage(20);
		end
		self:Remove()
	end
end

if CLIENT then
	function ENT:Initialize()
		self.FXEmitter = ParticleEmitter(self:GetPos())
	end

	function ENT:Draw()
		self:DrawModel();
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local sprite = "sprites/tfaenginered";
		local blue = self.FXEmitter:Add(sprite,self:GetPos())
		blue:SetVelocity(normal)
		blue:SetDieTime(0.3)
		blue:SetStartAlpha(255)
		blue:SetEndAlpha(55)
		blue:SetStartSize(20)
		blue:SetEndSize(5)
		blue:SetRoll(roll)
		blue:SetColor(0,205,255)
	end
end
