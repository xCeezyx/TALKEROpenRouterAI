local unique_characters =  {

    --[[ CORDON ]]--
    ["actor"] = "",                                          -- player
    ["esc_m_trader"] = "gruff",                              -- Sidorovich
    ["m_trader"] = "gruff",                                  -- Sidorovich
    ["esc_2_12_stalker_nimble"] = "cautious",                -- Nimble
    ["esc_2_12_stalker_wolf"] = "confident",                 -- Wolf
    ["esc_2_12_stalker_fanat"] = "zealous",                  -- Fanatic
    ["esc_2_12_stalker_trader"] = "gruff",                   -- Sidorovich
    ["esc_smart_terrain_5_7_loner_mechanic_stalker"] = "practical",  -- Xenotech
    ["devushka"] = "casual, determined",                               -- Hip
    ["esc_main_base_trader_mlr"] = "",                       -- Loris
    ["esc_3_16_military_trader"] = "stern",                  -- Major Zhurov
    ["army_south_mechan_mlr"] = "",                          -- Seryoga

    --[[ GREAT SWAMPS ]]--
    ["mar_smart_terrain_doc_doctor"] = "wise",               -- Doctor
    ["mar_smart_terrain_base_stalker_leader_marsh"] = "cold",-- Cold
    ["mar_base_stalker_tech"] = "analytical",                -- Novikov
    ["mar_base_owl_stalker_trader"] = "mysterious",          -- Spore
    ["mar_smart_terrain_base_doctor"] = "intellectual",      -- Professor Kalancha
    ["guid_marsh_mlr"] = "easygoing",                        -- Ivan Trodnik
    ["mar_base_stalker_barmen"] = "welcoming",               -- Librarian

    --[[ DARKSCAPE ]]--
    ["dasc_tech_mlr"] = "methodical",                        -- Polymer
    ["dasc_trade_mlr"] = "shrewd",                           -- Cutter
    ["ds_domik_isg_leader"] = "commanding",                  -- Major Hernandez

    --[[ GARBAGE ]]--
    ["hunter_gar_trader"] = "rough",                         -- Butcher

    --[[ AGROPROM ]]--
    ["agr_smart_terrain_1_6_near_2_military_colonel_kovalski"] = "strict", -- Major Kuznetsov
    ["agr_1_6_medic_army_mlr"] = "compassionate",            -- Rogovets
    ["agr_smart_terrain_1_6_army_trader_stalker"] = "wary",  -- Sergeant Spooner
    ["agr_1_6_barman_army_mlr"] = "authoritative",           -- Commander
    ["agr_smart_terrain_1_6_army_mechanic_stalker"] = "precise", -- Lieutenant Kirilov

    --[[ AGROPROM UNDERGROUND ]]--
    ["agr_u_bandit_boss"] = "ruthless",                      -- Reefer

    --[[ DARK VALLEY ]]--
    ["zat_b7_bandit_boss_sultan"] = "manipulative",          -- Sultan
    ["val_smart_terrain_7_3_bandit_mechanic_stalker"] = "sarcastic", -- Limpid
    ["guid_dv_mal_mlr"] = "brash",                           -- Pug
    ["val_smart_terrain_7_4_bandit_trader_stalker"] = "sly", -- Olivius

    --[[ ROSTOK ]]--
    ["bar_visitors_barman_stalker_trader"] = "friendly",     -- Barkeep
    ["bar_visitors_zhorik_stalker_guard2"] = "stern",        -- Zhorik
    ["bar_visitors_garik_stalker_guard"] = "guarded",        -- Garik
    ["bar_informator_mlr"] = "sneaky",                       -- Snitch
    ["guid_bar_stalker_navigator"] = "helpful",              -- Navigator
    ["bar_arena_manager"] = "assertive",                     -- Arnie
    ["bar_arena_guard"] = "stoic",                           -- Liolik
    ["bar_dolg_leader"] = "commanding",                      -- General Voronin
    ["bar_dolg_general_petrenko_stalker"] = "disciplined",   -- Colonel Petrenko
    ["bar_dolg_medic"] = "calm",                             -- Aspirin
    ["bar_visitors_stalker_mechanic"] = "gruff",             -- Mangun
    ["bar_zastava_2_commander"] = "tough",                   -- Sergeant Kitsenko
    ["bar_duty_security_squad_leader"] = "rigid",            -- Captain Gavrilenko

    --[[ YANTAR ]]--
    ["yan_stalker_sakharov"] = "inquisitive",                -- Professor Sakharov
    ["mechanic_army_yan_mlr"] = "cautious",                  -- Peregrine
    ["yan_povar_army_mlr"] = "stoic",                        -- Spirit
    ["yan_ecolog_kruglov"] = "scientific",                   -- Professor Kruglov

    --[[ ARMY WAREHOUSES ]]--
    ["mil_smart_terrain_7_7_freedom_leader_stalker"] = "charismatic", -- Lukash
    ["mil_freedom_medic"] = "laid-back",                     -- Solid
    ["mil_smart_terrain_7_10_freedom_trader_stalker"] = "mercantile", -- Skinflint
    ["mil_smart_terrain_7_7_freedom_mechanic_stalker"] = "dedicated", -- Screw
    ["mil_freedom_guid"] = "cunning",                        -- Leshiy
    ["stalker_gatekeeper"] = "stern",                        -- Gatekeeper

    --[[ DEAD CITY ]]--
    ["cit_killers_merc_mechanic_stalker"] = "resourceful",   -- Hog
    ["cit_killers_merc_trader_stalker"] = "scheming",        -- Dushman
    ["ds_killer_guide_main_base"] = "watchful",              -- Leopard
    ["cit_killers_merc_barman_mlr"] = "jovial",              -- Aslan
    ["cit_killers_merc_medic_stalker"] = "professional",     -- Surgeon

    --[[ RED FOREST ]]--
    ["red_forester_tech"] = "reclusive",                     -- Forester
    ["red_greh_trader"] = "taciturn",                        -- Stribog
    ["red_greh_tech"] = "efficient",                         -- Dazhbog

    --[[ DESERTED HOSPITAL ]]--
    ["kat_greh_sabaoth"] = "",                               -- Chernobog and variants
    ["gen_greh_sabaoth"] = "",
    ["sar_greh_sabaoth"] = "",

    --[[ JUPITER ]]--
    ["jup_b220_trapper"] = "rugged",                         -- Trapper
    ["jup_a6_stalker_barmen"] = "warm",                      -- Hawaiian
    ["guid_jup_stalker_garik"] = "curious",                  -- Garry
    ["jup_a6_stalker_medik"] = "compassionate",              -- Bonesetter
    ["zat_a2_stalker_mechanic"] = "handy",                   -- Cardan
    ["jup_b217_stalker_tech"] = "focused",                   -- Nitro
    ["jup_a6_freedom_trader_ashot"] = "boisterous",          -- Ashot
    ["jup_a6_freedom_leader"] = "confident",                 -- Loki
    ["jup_b6_scientist_tech"] = "calculating",               -- Tukarev
    ["jup_b6_scientist_nuclear_physicist"] = "cautious",     -- Professor Hermann
    ["jup_b6_scientist_biochemist"] = "methodical",          -- Professor Ozersky
    ["jup_depo_isg_leader"] = "tough",                       -- Major Hernandez
    ["jup_cont_mech_bandit"] = "sly",                        -- Nile
    ["jup_cont_trader_bandit"] = "conniving",                -- Klenov
    ["jup_depo_isg_tech"] = "meticulous",                    -- Lieutenant Maus

    --[[ ZATON ]]--
    ["zat_stancia_mech_merc"] = "practical",                 -- Kolin
    ["zat_stancia_trader_merc"] = "opportunistic",           -- Vector
    ["zat_a2_stalker_nimble"] = "nervous",                   -- Nimble
    ["zat_b30_owl_stalker_trader"] = "secretive",            -- Owl
    ["zat_tech_mlr"] = "inventive",                          -- Spleen
    ["zat_b22_stalker_medic"] = "gentle",                    -- Axel
    ["zat_a2_stalker_barmen"] = "welcoming",                 -- Beard
    ["zat_b18_noah"] = "eccentric",                          -- Noah
    ["guid_zan_stalker_locman"] = "jovial",                  -- Pilot
    ["zat_b106_stalker_gonta"] = "grizzled",                 -- Gonta
    ["zat_b106_stalker_garmata"] = "stoic",                  -- Garmata
    ["zat_b106_stalker_crab"] = "alert",                     -- Crab
    ["army_degtyarev_jup"] = "determined",                   -- Colonel Degtyarev and variants
    ["army_degtyarev"] = "determined",
    ["stalker_rogue"] = "loyal",                             -- Rogue and variants
    ["stalker_rogue_ms"] = "loyal",
    ["stalker_rogue_oa"] = "loyal",
    ["zat_b7_stalker_victim_1"] = "heroic",                  -- Spartacus

    --[[ OUTSKIRTS ]]--
    ["pri_monolith_monolith_trader_stalker"] = "fanatical",  -- Krolik
    ["lider_monolith_haron"] = "zealous",                    -- Charon
    ["pri_monolith_monolith_mechanic_stalker"] = "precise",  -- Cleric
    ["monolith_eidolon"] = "cryptic",                        -- Eidolon
    ["guid_pri_a15_mlr"] = "friendly",                       -- Tourist
    ["trader_pri_a15_mlr"] = "cheerful",                     -- Cashier
    ["pri_medic_stalker"] = "nurturing",                     -- Yar
    ["merc_pri_a18_mech_mlr"] = "hardened",                  -- Trunk
    ["pri_special_trader_mlr"] = "guarded",                  -- Meeker
    ["merc_pri_grifon_mlr"] = "commanding",                  -- Griffin
    ["mechanic_monolith_kbo"] = "calm",                      -- Bracer
    ["trader_monolith_kbo"] = "silent",                      -- Olivar
    ["stalker_stitch"] = "steady",                           -- Stitch and variants
    ["stalker_stitch_ms"] = "steady",
    ["stalker_stitch_oa"] = "steady",
    ["lost_stalker_strelok"] = "enigmatic",                  -- Strelok and variants
    ["stalker_strelok_hb"] = "enigmatic",
    ["stalker_strelok_oa"] = "enigmatic",
    ["lazarus_stalker"] = "",                                -- Lazarus

}

return unique_characters