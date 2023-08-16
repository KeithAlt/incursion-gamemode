function initWeaponParticles()
  game.AddParticles( "particles/paect_fx.pcf" ) -- For placeable particle effects
  game.AddParticles("particles/keith_tracer_acid1.pcf") -- For plasma particle tracer
  game.AddParticles("particles/keith_tracer_laser.pcf") -- For laser particle tracer
  game.AddParticles("particles/pg_ex.pcf") -- Plasma Explosion
  game.AddParticles("particles/keith_tracer_huge.pcf")
  game.AddParticles("particles/keith_laser_big.pcf")

  PrecacheParticleSystem("keith_laser_big")
  PrecacheParticleSystem("Black_Circles")
  PrecacheParticleSystem("pgex*") -- plasma explosion effect
  PrecacheParticleSystem("keith_tracer1_acid1") -- plasma tracer effect
  PrecacheParticleSystem("keith_tracer_laser") -- laser tracer effect
  PrecacheParticleSystem("keith_tracer_huge") -- Laser cannon effect
  PrecacheParticleSystem("mr_b_fx_1_core") -- 1
  PrecacheParticleSystem("mr_gas_flame_01") -- 2
  PrecacheParticleSystem("mr_ambient_mist") -- 3
  PrecacheParticleSystem("mr_effect_01") -- 4
  PrecacheParticleSystem("mr_effect_02") -- 5
  PrecacheParticleSystem("mr_effect_03_overflow") -- 6
  PrecacheParticleSystem("mr_effect_05") -- 7
  PrecacheParticleSystem("mr_hydrogen") -- 8
  PrecacheParticleSystem("mr_oxygen") -- 9
  PrecacheParticleSystem("mr_gas_leak_01") -- 10
  PrecacheParticleSystem("mr_fx_falling_bsparks") -- 11
  PrecacheParticleSystem("mr_bdigsmoke_1") -- 12
  PrecacheParticleSystem("mr_smallsmoke_1_noise") -- 13
  PrecacheParticleSystem("mr_portal_entrance") -- 14
  PrecacheParticleSystem("mr_portal_exit") -- 15
  PrecacheParticleSystem("mr_jet_01a") -- 16
  PrecacheParticleSystem("mr_trail_1") -- 17
  PrecacheParticleSystem("mr_jet_big") -- 18
  PrecacheParticleSystem("mr_cop_anomaly_electra_a") -- 19
  PrecacheParticleSystem("mr_cop_anomaly_burner") -- 20
  PrecacheParticleSystem("mr_cop_anomaly_burner_flame") -- 21
  PrecacheParticleSystem("mr_trail_burn_1") -- 22
  PrecacheParticleSystem("mr_cop_burner_type2") -- 23
  PrecacheParticleSystem("mr_b_trail_2") -- 24
  PrecacheParticleSystem("bfg9k_projectile") -- 25
  PrecacheParticleSystem("mr_noise_1") -- 26
  PrecacheParticleSystem("mr_electric_1") -- 27
  PrecacheParticleSystem("mr_fx_17") -- 28
  PrecacheParticleSystem("mr_holodisp_1") -- 29
  PrecacheParticleSystem("mr_fog_2") -- 30
  PrecacheParticleSystem("mr_bigfire_1") -- 31
  PrecacheParticleSystem("mr_firespray_1") -- 32
  -- Just fucking kill me...
  PrecacheParticleSystem("mr_frostspray_1") -- 33
  PrecacheParticleSystem("mr_electricspray_1") -- 34
  PrecacheParticleSystem("mr_anamorphic_1") -- 35
  PrecacheParticleSystem("mr_energybeam_1") -- 36
  PrecacheParticleSystem("weapon_core_highcharge") -- 37
  PrecacheParticleSystem("mr_skybox_galaxy1") -- 38
  PrecacheParticleSystem("mr_rain_1") -- 39
  PrecacheParticleSystem("mr_snow_1") -- 40
  PrecacheParticleSystem("mr_gushing_blood") -- 41
  PrecacheParticleSystem("mr_jet_trail_1_a") -- 42
  PrecacheParticleSystem("mr_bigsparks_1") -- 43
  PrecacheParticleSystem("mr_emberspray_1") -- 44
  PrecacheParticleSystem("mr_gushing_blood_small") -- 45
  PrecacheParticleSystem("mr_liquidnitrogen_para") -- 46
  PrecacheParticleSystem("mr_acid_ground_1") -- 47
  PrecacheParticleSystem("mr_acid_trail") -- 48
  PrecacheParticleSystem("mr_fire_embers") -- 49
  PrecacheParticleSystem("mr_waterleak_01a_sm") -- 50
  PrecacheParticleSystem("mr_waterleak_01a") -- 51
  PrecacheParticleSystem("mr_hugefire_1a") -- 52
  PrecacheParticleSystem("mr_fx_beamelectric_arcc1") -- 53
  PrecacheParticleSystem("mr_fireball_01a") -- 54
  PrecacheParticleSystem("mr_acid_trail_2") -- 55
  PrecacheParticleSystem("nr_blackhole") -- 56
  PrecacheParticleSystem("mr_fireball_01a_nofollower") -- 57
  PrecacheParticleSystem("mr_magicball_01a") -- 58
  PrecacheParticleSystem("mr_fx_01_parent") -- 59
  PrecacheParticleSystem("mr_Fx_04_core") -- 60
  PrecacheParticleSystem("mr_fx_08") -- 61
  PrecacheParticleSystem("nr_jetflame_base") -- 62
  PrecacheParticleSystem("nr_jetflame_base_trail") -- 63
  PrecacheParticleSystem("nr_jetflame_basebig") -- 64
  PrecacheParticleSystem("nr_jetflame_basetrail") -- 65
  PrecacheParticleSystem("nr_freighter_mainv") -- 66
  PrecacheParticleSystem("nr_freighterflame_main") -- 67
  PrecacheParticleSystem("nr_chopperCore") -- 68
  PrecacheParticleSystem("nr_ambient_fog_2a_0x2") -- 69
  PrecacheParticleSystem("nr_warp_engine_exhaust") -- 70
  PrecacheParticleSystem("nr_projectile_0x5") -- 71
  PrecacheParticleSystem("or_energetic_core_0x5") -- 72
  PrecacheParticleSystem("nr_starfield_0x2") -- 73
  PrecacheParticleSystem("or_nebulea_big_0x5") -- 74
  PrecacheParticleSystem("nr_ambient_fog_2a_0x2_ye") -- 75
  PrecacheParticleSystem("nr_ambient_fog_2a_0x2_red") -- 76
  PrecacheParticleSystem("nr_ambient_fog_2a_0x2_green") -- 77
  PrecacheParticleSystem("nr_graviton_surge") -- 78
  PrecacheParticleSystem("_new_candleflame_main") -- 79
  PrecacheParticleSystem("_gunfire_generic") -- 80
  PrecacheParticleSystem("_______thruster_bigwarp") -- 81
  PrecacheParticleSystem("_amb_wind_dusty") -- 82
  PrecacheParticleSystem("_amb_blizzard") -- 83
  PrecacheParticleSystem("_new_energybeam_main") -- 84
  PrecacheParticleSystem("_env_sakura_512") -- 85 // Should we go all the way to 512 effects?
  PrecacheParticleSystem("_ground_heat") -- 86
  PrecacheParticleSystem("__energetic_fire_main") -- 87
  PrecacheParticleSystem("_ax_barrel_fire_flame") -- 88
  PrecacheParticleSystem("_ae_smoke_main") -- 89
  PrecacheParticleSystem("_ae_a_smoke_grenade") -- 90
  PrecacheParticleSystem("_ae_b_rocket_jet_a") -- 91
  PrecacheParticleSystem("_ae_b_rocket_jet_b") -- 92
  PrecacheParticleSystem("_or_energy_ball") -- 93
  PrecacheParticleSystem("_gunfire_ar2_main") -- 94
  PrecacheParticleSystem("_ai_nitro_flame") -- 95
  PrecacheParticleSystem("_ai_wormhole") -- 96
  PrecacheParticleSystem("_ai_blackhole") -- 97
  PrecacheParticleSystem("_ai_blackhole_orange") -- 98
  PrecacheParticleSystem("_ai_blackhole_mini") -- 99
  PrecacheParticleSystem("_ai_blackhole_mini_orange") -- 100
  PrecacheParticleSystem("_ai_blackhole_supersmall_orange") -- 101
  PrecacheParticleSystem("_ai_blackhole_supersmall") -- 102
end

hook.Add("InitPostEntity", "TFA_WEAPON_PARTICLES_INIT", initWeaponParticles)
