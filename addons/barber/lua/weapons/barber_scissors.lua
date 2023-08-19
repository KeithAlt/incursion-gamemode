SWEP.PrintName = "Barber Scissors"
SWEP.Slot = 1
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "jonjo"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = "Styling other's hair"

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel 	= Model("models/barbershop/scissors/v_scissors.mdl")
SWEP.WorldModel = Model("models/barbershop/scissors/w_scissors.mdl")

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Claymore Gaming"

SWEP.UseHands = true
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsAlwaysRaised = true

SWEP.Range = 200

local scissors_sound = Sound("barbershop/scissors_sound.wav")

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Skillcheck")

	if CLIENT then
		self:NetworkVarNotify("Skillcheck", function(ent, name, old, new)
			if new == true then
				ent:GenerateRange()
				ent:GenerateStages()

				local owner = ent:GetOwner()
				if IsValid(owner) and LocalPlayer() == owner and (owner:getSpecial("I") or 0) > 0 then
					chat.AddText("Your intelligence allows you to steady your hands and make more precise cuts")
				end
			end
		end)
	end
end

function SWEP:Initialize()
	self:SetHoldType("fist")

	if CLIENT then
		self.Dir = 1
		self.CurrentStage = 1
		self.ScratchX = 0
		self.ScratchSpeed = Barber.Config.ScratchSpeed
	end
end

function SWEP:ScissorsAnim()
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	local seq, dur = vm:LookupSequence("use")

	if SERVER then
		vm:SendViewModelMatchingSequence(seq)
		owner:EmitSound(scissors_sound)
		self.SequenceReset = CurTime() + dur + 0.1
	end

	return dur
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end

	local owner = self:GetOwner()
	local customer = owner:GetHaircutCustomer()

	if self:GetSkillcheck() and IsValid(customer) then
		self:ScissorsAnim()
		if CLIENT then
			if self.ScratchX > self.StartRange and self.ScratchX < self.EndRange then
				self.CurrentStage = self.CurrentStage + 1
				self:GenerateRange()
				surface.PlaySound("shelter/sfx/collect_stimpack.ogg")

				if (self.CurrentStage - 1) >= self.Stages then
					net.Start("BarberSkillcheck")
						net.WriteBool(true)
					net.SendToServer()
				end
			else
				surface.PlaySound("shelter/sfx/xmas_gift_bounce_big.ogg")
				net.Start("BarberSkillcheck")
					net.WriteBool(false)
				net.SendToServer()
			end
		end
		return
	end

	if SERVER and !IsValid(customer) then
		local ply, reason = self:FindCustomer()
		if IsValid(ply) then
			if !ply.PendingHaircutRequest then
				Barber.AskForHaircut(owner, ply)
				owner:falloutNotify("You offer a haircut...", "ui/notify.mp3")
				self:SetNextPrimaryFire(CurTime() + 2)
			else
				owner:falloutNotify("This customer already has a pending haircut request")
			end
		else
			owner:falloutNotify(reason)
		end
	end
end

function SWEP:Deploy()
	local vm = self:GetOwner():GetViewModel()
	if !vm or !IsValid(vm) then return end
	local seq, dur = vm:LookupSequence("draw")
	vm:SendViewModelMatchingSequence(seq)
	self.SequenceReset = CurTime() + dur
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	local customer = owner:GetHaircutCustomer()
	if !IsValid(customer) and !self:GetSkillcheck() then
		self:SetNextSecondaryFire(CurTime() + self:ScissorsAnim())
	end
end

function SWEP:Think()
	local seq_reset = self.SequenceReset
	if seq_reset and seq_reset < CurTime() then
		local vm = self:GetOwner():GetViewModel()

		vm:SendViewModelMatchingSequence(vm:LookupSequence("idle"))
		self.SequenceReset = nil
	end
end

if SERVER then
	function SWEP:InRange(ent)
		return ent:GetPos():Distance(self:GetOwner():GetPos()) < self.Range
	end

	function SWEP:FindCustomer()
		local owner = self:GetOwner()
		local tr = owner:GetEyeTrace()
		local ent = tr.Entity

		if IsValid(ent) and self:InRange(ent) then
			if ent:IsPlayer() and Barber.IsBarberChair(ent:GetParent()) then
				if !IsValid(ent:GetBarber()) then
					return ent
				else
					return NULL, "Customer is already having their hair cut"
				end
			elseif Barber.IsBarberChair(ent) then
				return ent:GetDriver(), "No one is sat in the chair"
			else
				return NULL, "Customer must be sat in a chair"
			end
		end

		return NULL, "You are not close enough!"
	end
else
	local barW, barH = 500, 25
	local x, y = ScrW() * 0.5 - barW * 0.5, ScrH() * 0.5 - barH * 0.5
	local color_scratch = Color(255, 200, 0, 255)
	local maxIntel = 25

	function SWEP:DrawHUD()
		if !self:GetSkillcheck() or self.CurrentStage > self.Stages then return end

		local owner = self:GetOwner()
		local customer = owner:GetHaircutCustomer()

		if !IsValid(customer) then return end

		surface.SetDrawColor(ColorAlpha(color_black, 220))
		surface.DrawRect(x, y, barW, barH)
		surface.SetDrawColor(color_white)

		surface.DrawRect(x + self.StartRange, y, self.EndRange - self.StartRange, barH)
		surface.DrawOutlinedRect(x, y, barW, barH)

		local intel = owner:getSpecial("I") or 0
		local speedBonus = Barber.Config.IntelligenceBonus * (intel / maxIntel)
		local speed = self.ScratchSpeed - speedBonus

		self.ScratchX = math.Clamp(self.ScratchX + (speed * FrameTime()) * self.Dir, 0, barW)

		if self.ScratchX >= barW then self.Dir = -1 end
		if self.ScratchX <= 0 then self.Dir = 1 end

		local textX = x + barW * 0.5

		surface.SetDrawColor(color_scratch)
		surface.DrawRect(x + self.ScratchX, y - 4, 2, barH + 8)
		draw.SimpleText(self.CurrentStage .. " / " .. self.Stages, "BarberSkillcheck", textX, y - barH - 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Speed: " .. math.Round(speed), "BarberSkillcheck", textX, y + barH + 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function SWEP:GenerateRange()
		local width = math.random(Barber.Config.MinRange, Barber.Config.MaxRange)
		local start = math.random(0, barW - width)
		self.StartRange = start
		self.EndRange = start + width
	end

	function SWEP:GenerateStages()
		self.CurrentStage = 1
		self.Stages = math.random(3, 6)
	end
end
