ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Base = "hvtank_base"

ENT.Type = "vehicle"



ENT.PrintName = "Chimera Tank"

ENT.Author = "Cody Evans"

--- All copyright and credit goes ---

--- to the base author: Liam0102 ---

ENT.Category = "Fallout"

ENT.AutomaticFrameAdvance = true

ENT.Spawnable = true;

ENT.AdminSpawnable = false;

ENT.AutomaticFrameAdvance =  true;



ENT.Vehicle = "Chimera";

ENT.EntModel = "models/helios/vehicles/fo3/chimera.mdl";



ENT.StartHealth = 5000;



if SERVER then



ENT.NextUse = {Use = CurTime(),Fire = CurTime()};

ENT.FireSound = Sound("fo3/chimera/fire1.wav");

ENT.HeavySound = Sound("fo3/chimera/fire2.wav");





AddCSLuaFile();

function ENT:SpawnFunction(pl, tr)

	local e = ents.Create("chimera_tank");

	e:SetPos(tr.HitPos + Vector(0,0,70));

	e:SetModelScale( e:GetModelScale() * 1, 0 )

	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+180,0));

	e:Spawn();

	e:Activate();

	return e;

end



function ENT:Initialize()

	self.BaseClass.Initialize(self);

	local driverPos = self:GetPos()+self:GetUp()*-30+self:GetForward()*-70+self:GetRight()*0;

	local driverAng = self:GetAngles()+Angle(0,-90,0);

	self.SpeederClass = 2;

	self:SpawnChairs(driverPos,driverAng,false)

	self.ForwardSpeed = 280;

	self.BoostSpeed = 280;

	self.AccelSpeed = 3;

	self.HoverMod = 1;

	self.CanBack = true;

	self.StartHover = 15;

	self.WeaponLocations = {}

	self.Bullet = HVTANKCreateBulletStructure(20,"chimera");

	self:SpawnWeapons();

	self:SpawnCannon();

	self.StandbyHoverAmount = 0;

	self.ExitModifier = {x=0,y=-220,z=0}

end



function ENT:Enter(p,driver)
		p:SetNoDraw(true)
		p:SetNotSolid(true)
    self.BaseClass.Enter(self,p,driver);
end



function ENT:Exit(driver,kill)

	self.BaseClass.Exit(self,driver,kill);

	self:SetSequence( self:LookupSequence( "ragdoll" ) );

	self:ResetSequenceInfo()

	self:SetPlaybackRate( 1.0 )

end



function ENT:FireBlast(pos,gravity,vel,ang)

    if(self.NextUse.FireBlast < CurTime()) then

        local e = ents.Create("chimera_blast");

        e:SetPos(pos);

        e:Spawn();

        e:Activate();

        e:Prepare(self,Sound("fo3/chimera/fire2.wav"),gravity,vel,ang);

        e:SetColor(Color(255,255,255,1));

		self:EmitSound(self.HeavySound, 120, math.random(90,115));

    end

end



function ENT:SpawnCannon()

	local e = ents.Create("prop_physics");

	e:SetPos(self:GetPos()+self:GetUp()*165+self:GetForward()*10+self:GetRight()*0);

	e:SetAngles(self:GetAngles());

	e:SetModel("models/props_junk/PopCan01a.mdl");

	e:SetParent(self);

	e:Spawn();

	e:Activate();

	e:GetPhysicsObject():EnableCollisions(false);

	e:GetPhysicsObject():EnableMotion(false);

	self.Cannon = e;

	self:SetNWEntity("Cannon",e);

end



local ZAxis = Vector(0,0,1);



function ENT:Think()

	self:NextThink(CurTime())

	self.BaseClass.Think(self)



    if(self.Inflight) then



		if self:GetNWInt("Speed") >= 0 and self:GetNWInt("Speed") < 40 then

			self:ResetSequence( self:LookupSequence( "spinning_is_not_swimming" ) );

			self:SetPlaybackRate( 0.3 )

		elseif self:GetNWInt("Speed") >= 40 and self:GetNWInt("Speed") < 80 then

			self:ResetSequence( self:LookupSequence( "spinning_is_not_swimming" ) );

			self:SetPlaybackRate( 0.6 )

		elseif self:GetNWInt("Speed") >= 80 then

			self:ResetSequence( self:LookupSequence( "spinning_is_not_swimming" ) );

			self:SetPlaybackRate( 1.0 )

	    end



	    if self:GetNWInt("Speed") <= 0 then

		    self:SetSequence( self:LookupSequence( "spinning_is_not_swimming" ) );

		    self:SetPlaybackRate( 0 );

	    end



		local saveangle = self.Pilot:GetAimVector():Angle()

	    local weaponangle = self:WorldToLocalAngles( saveangle )

	    local aim = weaponangle;



		local p = aim.p*1;

		if(p <= 70 and p >= 17) then

				p = 17;

			elseif(p >= -150 and p <= -25) then

				p = -25;

		end



		self.Cannon:SetAngles(Angle(p,self:GetAngles().y,self:GetAngles().r));



        if(IsValid(self.Pilot)) then

		    if(self.Pilot:KeyDown(IN_ATTACK) and self.NextUse.FireBlast < CurTime()) then

				self:FireBlast(self.Cannon:GetPos(),false,100000,self.Cannon:GetAngles():Forward()*-1);

				self.NextUse.FireBlast = CurTime() + 0.3;

		    end

			self:NextThink(CurTime());

			return true;

		end

	end

end



function ENT:FireWeapons()

	if(self.NextUse.Fire < CurTime()) then



		local cannon = self.GetNWEntity("Cannon");

		local cannonPos = self.Cannon:GetPos()+self:GetRight()*0+self:GetForward()*20+self:GetUp()*0;

		local cannonAng = self.Cannon:GetAngles();



		local WeaponPos = {

			Vector(cannonPos)+self:GetRight()*0+self:GetForward()*0+self:GetUp()*0,

		}

		for k,v in pairs(WeaponPos) do

			tr = util.TraceLine({

				start = cannonPos+self:GetRight()*0,

				endpos = cannonPos + cannonAng:Forward()*1000,

				filter = {self,cannon},

			})



			self.Bullet.Src		= v;

			self.Bullet.Attacker = self.Pilot or self;

			self.Bullet.Dir = (tr.HitPos - v);



			self:FireBullets(self.Bullet)

		end

		self:EmitSound(self.FireSound, 120, math.random(90,110));

		self.NextUse.Fire = CurTime() + 0.1;

	end

end



function ENT:Exit(driver,kill)

	self.BaseClass.Exit(self,driver,kill);

end



function ENT:PhysicsSimulate( phys, deltatime )

	self.BackPos = self:GetPos()+self:GetForward()*-80+self:GetUp()*0;

	self.FrontPos = self:GetPos()+self:GetForward()*80+self:GetUp()*0;

	self.MiddlePos = self:GetPos()+self:GetUp()*0; // Middle one

	if(self.Inflight) then

		local UP = ZAxis;

		self.RightDir = self.Entity:GetRight();

		self.FWDDir = self.Entity:GetForward();



		if(self.Pilot:KeyDown(IN_MOVERIGHT)) then

		    self.Right = 200;

	    elseif(self.Pilot:KeyDown(IN_MOVELEFT)) then

		    self.Right = -200;

		else

		    self.Right = 0;

		end

		self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,self.Right,5);



		self:RunTraces(); // Ignore



		self.ExtraRoll = Angle(0,0,self.YawAccel / 1*-.1);

	end

	self.BaseClass.PhysicsSimulate(self,phys,deltatime);

end



end



if CLIENT then

	ENT.Sounds={

		Engine=Sound("fo3/chimera/engine.wav"),

	}



	local Health = 0;

	local Speed = 0;

	local Cannon;

	function ENT:Think()

		self.BaseClass.Think(self);

		local p = LocalPlayer();

		local Flying = p:GetNWBool("Flying"..self.Vehicle);

		if(Flying) then

			Health = self:GetNWInt("Health");

			Speed = self:GetNWInt("Speed");

			Cannon = self:GetNWEntity("Cannon");

		end



	end



	ENT.HasCustomCalcView = true;

	local View = {}

	function CalcView()



		local p = LocalPlayer();

		local self = p:GetNWEntity("Chimera", NULL)

		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);



		if(IsValid(self)) then

			if(IsValid(DriverSeat)) then

				local pos = self:GetPos()+LocalPlayer():GetAimVector():GetNormal()*-400+self:GetUp()*250+self:GetRight()*0;

				local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();

				    View.origin = pos;

				    View.angles = face;

				return View;

			end

		end

	end

	hook.Add("CalcView", "ChimeraView", CalcView)



	function ChimeraReticle()



		local p = LocalPlayer();

		local Flying = p:GetNWBool("FlyingChimera");

		local self = p:GetNWEntity("Chimera");

		if(Flying and IsValid(self)) then



		    surface.SetDrawColor( color_white )

			local CannonPos = Cannon:GetPos();

			local tr = util.TraceLine({

				start = CannonPos,

				endpos = CannonPos + Cannon:GetForward()*10000,

				filter = {self,Cannon},

			});



			local vpos = tr.HitPos;

			local screen = vpos:ToScreen();

			local x,y;

			for k,v in pairs(screen) do

				if(k == "x") then

					x = v;

				elseif(k == "y") then

					y = v;

				end

			end



			local w = ScrW()/100*2;

			local h = w;

			x = x - w/2;

			y = y - h/2;

			surface.SetMaterial( Material( "hud/chimera_reticle.png", "noclamp" ) )

			surface.DrawTexturedRectUV( x , y, w, h, 0, 0, 1, 1 )



			HVTANK_DrawHull(3000)

			HVTANK_DrawSpeedometer()



		end

	end

	hook.Add("HUDPaint", "ChimeraReticle", ChimeraReticle)



end
