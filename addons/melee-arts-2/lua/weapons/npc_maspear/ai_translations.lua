
/*---------------------------------------------------------
   Name: SetupWeaponHoldTypeForAI
   Desc: Mainly a Todo.. In a seperate file to clean up the init.lua
---------------------------------------------------------*/
function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	if ( t == "melee" ) then
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_MELEE_ATTACK_SWING
 	self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_MELEE_ATTACK_SWING
 	self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_RANGE_ATTACK_THROW

	
	self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_IDLE_ANGRY_MELEE
	
	self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_WALK
	self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_WALK
	self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_WALK
	self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_WALK
	

	self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN
	self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
	
	return end
	
	if ( t == "smg" ) then
	
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_SUITCASE
	self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_WALK_SUITCASE
	self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ] 				= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
	
	return end
	
	if ( t == "shotgun" ) then
	
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_MELEE_ATTACK_SWING
 	self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_MELEE_ATTACK_SWING
 	self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_RANGE_ATTACK_THROW

	
	self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_IDLE_ANGRY_MELEE
	
	self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_WALK
	self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_WALK
	self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_WALK
	self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_WALK
	
	self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_RUN
	self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN
	self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
	
	return end
	
	if ( t == "pistol") then 

	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_UNARMED
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_IDLE_SHOTGUN

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_MELEE_ATTACK1
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_MELEE_ATTACK1
 	self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_MELEE_ATTACK1
 	self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_MELEE_ATTACK1
	self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_MELEE_ATTACK1

	
	self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_IDLE_SHOTGUN
	
	self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_WALK_UNARMED
	self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_WALK_UNARMED
	self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_WALK_UNARMED
	self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_WALK_UNARMED
	
	self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN_AIM_SHOTGUN
	
	return end
end
