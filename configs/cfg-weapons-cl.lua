-- Settings for how weapons appear on the backs of players (if enabled client-side)
weaponOnBackSettings = {
    back_bone = 24816,
    x = 0.075,
    y = -0.15,
    z = -0.02,
    x_rotation = 0.0,
    y_rotation = 165.0,
    z_rotation = 0.0,
    compatable_weapon_hashes = {
      -- melee:
      --["prop_golf_iron_01"] = 1141786504, -- positioning still needs work

      ["w_me_bat"] = -1786099057,
      ["prop_ld_jerrycan_01"] = 883325847,

      -- assault rifles:

      ["w_ar_carbinerifle"] = -2084633992,
      ["w_ar_carbineriflemk2"] = GetHashKey("WEAPON_CARBINERIFLE_Mk2"),
      ["w_ar_assaultrifle"] = -1074790547,
      ["w_ar_specialcarbine"] = -1063057011,
      ["w_ar_bullpuprifle"] = 2132975508,
      ["w_ar_advancedrifle"] = -1357824103,

      -- sub machine guns:
      ["w_sb_microsmg"] = 324215364,
      ["w_sb_assaultsmg"] = -270015777,
      ["w_sb_smg"] = 736523883,
      ["w_sb_smgmk2"] = GetHashKey("WEAPON_SMGMk2"),
      ["w_sb_gusenberg"] = 1627465347,

      -- sniper rifles:
      ["w_sr_sniperrifle"] = 100416529,

      -- shotguns:
      ["w_sg_assaultshotgun"] = -494615257,
      ["w_sg_bullpupshotgun"] = -1654528753,
      ["w_sg_pumpshotgun"] = 487013001,
      ["w_ar_musket"] = -1466123874,
      ["w_sg_heavyshotgun"] = GetHashKey("WEAPON_HEAVYSHOTGUN"),

      -- ["w_sg_sawnoff"] = 2017895192 don't show, maybe too small?
      -- launchers:

      ["w_lr_firework"] = 2138347493
    }
}


-- Add/remove weapon hashes here to be added for holster checks.
-- For animations
holsterWeapons = {
	'WEAPON_PISTOL',
	'WEAPON_PISTOL_MK2',
	'WEAPON_COMBATPISTOL',
	'WEAPON_DOUBLEACTION',
	'WEAPON_APPISTOL',
	'WEAPON_HEAVYPISTOL',
	'WEAPON_HEAVYPISTOL_02',
	
	'WEAPON_VFPISTOL',
	'WEAPON_VFCOMBATPISTOL',
	'WEAPON_GARDONEPISTOL',
	'WEAPON_DUTYPISTOL',
	'WEAPON_DP9',
	'WEAPON_DPPISTOL',
	'WEAPON_ENDURANCEPISTOL',
	'WEAPON_SERVICEPISTOL',
	'WEAPON_SERVICEPISTOL_02',
	'WEAPON_HEAVYPISTOLLE',
	'WEAPON_HEAVYPISTOL_02',
	
	'WEAPON_COMPACTPISTOL',
	'WEAPON_LANGLEYPISTOL',
	'WEAPON_SPECOPSPISTOL',
	'WEAPON_COMPACTPISTOL',
	'WEAPON_FN509',
	'WEAPON_SAFETYPISTOL',
	
	'WEAPON_M72',
	'WEAPON_M722',
	
	'WEAPON_SAMURAIEDGE'
}

-- For holster/unholster DRAWABLES
HolsterConfig = {
	Weapons = {
	  [GetHashKey('WEAPON_PISTOL')] = true,
	  [GetHashKey('WEAPON_PISTOL_MK2')] = true,
	  [GetHashKey('WEAPON_COMBATPISTOL')] = true,
	  [GetHashKey('WEAPON_DOUBLEACTION')] = true,
	  [GetHashKey('WEAPON_APPISTOL')] = true,
	  [GetHashKey('WEAPON_HEAVYPISTOL')] = true,
	  [GetHashKey('WEAPON_HEAVYPISTOL_02')] = true,

	  [GetHashKey('WEAPON_VFPISTOL')] = true,
	  [GetHashKey('WEAPON_VFCOMBATPISTOL')] = true,
	  [GetHashKey('WEAPON_GARDONEPISTOL')] = true,
	  [GetHashKey('WEAPON_DUTYPISTOL')] = true,
	  [GetHashKey('WEAPON_DP9')] = true,
	  [GetHashKey('WEAPON_DPPISTOL')] = true,
	  [GetHashKey('WEAPON_ENDURANCEPISTOL')] = true,
	  [GetHashKey('WEAPON_SERVICEPISTOL')] = true,
	  [GetHashKey('WEAPON_HEAVYPISTOLLE')] = true,
	  [GetHashKey('WEAPON_HEAVYPISTOL_02')] = true,

	  [GetHashKey('WEAPON_COMPACTPISTOL')] = true,
	  [GetHashKey('WEAPON_LANGLEYPISTOL')] = true,
	  [GetHashKey('WEAPON_SPECOPSPISTOL')] = true,
	  [GetHashKey('WEAPON_COMPACTPISTOL')] = true,
	  [GetHashKey('weapon_fn509')] = true,
	  [GetHashKey('WEAPON_SAFETYPISTOL')] = true,
	  
	  [GetHashKey('WEAPON_SAMURAIEDGE')] = true,
	  [GetHashKey('WEAPON_M72')] = true,
	  [GetHashKey('WEAPON_M722')] = true,
	},
	Peds = {
	  [GetHashKey('mp_m_freemode_01')] = {
		[7] = {
			-- 2 = Empty Belt
			-- 3 = Empty 2 Strap Drop
			-- 5 = Empty Detective
			-- 7 = Empty 1 Strap Drop
			-- 57 = Empty Drop
			-- 59 = Empty 2 Strap Drop
			-- 62 = Empty Belt
			-- 63 = Empty Detective
			-- 65 = Empty Drop
			-- 67 = Empty Revolver
			-- 69 = Empty Drop
			-- 72 = Flop
			-- 120 = Empty Holster
			-- 195 = Empty 1 Strap Drop
			-- 228 = Empty Basketweave
			[1] = 3, -- Glock 2 Strap Drop
			[4] = 7, -- Glock 1 Strap Drop
			[6] = 5, -- Glock Detective
			[8] = 2, -- Glock
			[9] = 2, -- Training
			[56] = 57, -- Glock Drop
			[58] = 59, -- Gardone 2 Strap Drop
			[60] = 61, -- Gardone
			[62] = 63, -- Gardone Detective
			[64] = 65, -- Gardone Drop
			[66] = 67, -- Revolver
			[68] = 69, -- Revolver Drop
			[71] = 72, -- Flip-Flop
			[110] = 0, -- Air Glock
			[111] = 0, -- Air Gardone
			[119] = 120, -- Vest
			[169] = 2, -- Glock
			[170] = 0, -- Dumb Detective Glock
			[171] = 0, -- Tan Glock
			[172] = 0, -- Flush Glock 
			[173] = 3, -- Glock 2 Strap Drop
			[174] = 2, -- HL950
			[184] = 3, -- Duty 2 Strap Drop
			[185] = 5, -- Duty Detective
			[186] = 2, -- Duty
			[187] = 0, -- Air Duty
			[188] = 57, -- Duty Drop
			[189] = 3, -- DP9 2 Strap Drop
			[190] = 5, -- DP9 Detective
			[191] = 2, -- DP9
			[193] = 0, -- Air DP9
			[194] = 57, -- DP9 Drop
			[196] = 195, -- Glock 1 Strap Drop
			[197] = 195, -- Gardone 1 Strap Drop
			[198] = 195, -- DP9 1 Strap Drop
			[199] = 195, -- Duty 1 Strap Drop
			[202] = 195, -- Heavy 1 Strap Drop
			[227] = 228, -- Basketweave Gardone
			
			[230] = 229, -- Sxprk Holster
			[231] = 229, -- Sxprk Holster
			[232] = 229, -- Sxprk Holster
			[233] = 229, -- Sxprk Holster
			[234] = 229, -- Sxprk Holster
		},
		[8] = {
			-- Empty Shoulder
			[16] = 18, -- Glock Shoulder
		},
	  },
	  [GetHashKey('mp_f_freemode_01')] = {
		[7] = {			
			-- 1 Glock 2 Strap Drop
			-- 2 Empty
			-- 3 Empty 2 Strap Drop
			-- 4 Glock 1 Strap Drop
			-- 5 Empty Detective
			-- 6 Glock Detective
			-- 7 Empty 1 Strap Drop
			-- 8 Glock
			-- 9 Training
			-- 33 Glock Drop
			-- 34 Empty Drop
			-- 45 Gardone 2 Strap Drop
			-- 46 Empty 2 Strap Drop
			-- 47 Gardone
			-- 48 Empty
			-- 49 Gardone Detective
			-- 50 Empty Detective
			-- 51 Gardone Drop
			-- 52 Empty Drop
			-- 53 Revolver
			-- 54 Empty Revolver
			-- 55 Revolver Drop
			-- 56 Empty Drop
			-- 81 Air Glock
			-- 82 Air Gardone
			-- 88 Vest
			-- 89 Empty Vest
			-- 138 HL950
			-- 166 DP9 2 Strap Drop
			-- 167 DP9 Detective
			-- 168 DP9
			-- 169 Air DP9
			-- 170 DP9 Drop
			-- 171 Duty 2 Strap Drop
			-- 172 Duty Detective
			-- 173 Duty
			-- 174 Air Duty
			-- 175 Duty Drop
			-- 177 Empty 1 Strap Drop
			-- 178 Glock 1 Strap Drop
			-- 179 Gardone 1 Strap Drop
			-- 180 DP9 1 Strap Drop
			-- 181 Duty 1 Strap Drop
			-- 182 Heavy 1 Strap Drop
			-- 205 Glock Basketweave
			-- 206 Empty Basketweave
			[1] = 3,
			[4] = 7,
			[6] = 5,
			[8] = 2,
			[9] = 2,
			[33] = 34,
			[45] = 3,
			[47] = 2,
			[49] = 5,
			[51] = 52,
			[53] = 54,
			[55] = 56,
			[81] = 0,
			[82] = 0,
			[88] = 89,
			[138] = 2,
			[166] = 3,
			[167] = 5,
			[168] = 2,
			[169] = 0,
			[171] = 3,
			[172] = 5,
			[173] = 2,
			[174] = 0,
			[175] = 34,
			[178] = 177,
			[179] = 177,
			[180] = 177,
			[181] = 177,
			[182] = 177,
			[205] = 206,
		},
		[8] = {
		  [9] = 10,
		},
	  },
	  [GetHashKey('s_m_y_cop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_cop_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_copb_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_deputy_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_dpcop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_aircop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_hwaycop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_hwaycop_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_ranger_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_ranger_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_sheriff_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_sheriff_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_portcop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_rhcop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_m_security_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_hrt_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_hrt_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_tru_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_seb_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_seb_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_swat_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_swat_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_m_y_swat_03')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_cop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_copb_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_aircop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_deputy_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_dpcop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_hrt_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_hrt_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_tru_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_hwaycop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_hwaycop_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_portcop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_ranger_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_rhcop_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_seb_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_seb_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_security_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_sheriff_01')] = {
		[9] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_swat_01')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	  [GetHashKey('s_f_y_swat_02')] = {
		[7] = {
		  [0] = 1,
		},
	  },
	},
  }