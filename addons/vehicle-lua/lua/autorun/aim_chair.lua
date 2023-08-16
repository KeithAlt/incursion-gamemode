local Category = "Syphadias"

local function AimAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_HL2MP_IDLE_CROUCH ) 
end

local V = {
	Name = "Aiming Seat",
	Model = "models/nova/airboat_seat.mdl",
	Class = "prop_vehicle_prisoner_pod",
	Category = Category,

	Author = "Syphadias",
	Information = "Seat by Syphadias with custom animation",
	Offset = 5,

	KeyValues = {
		vehiclescript = "scripts/vehicles/prisoner_pod.txt",
		limitview = "0"
	},
	Members = {
		HandleAnimation = AimAnimation,
	}
}
list.Set( "Vehicles", "aim_chair", V )
