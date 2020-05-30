{-# LANGUAGE OverloadedLists #-}
{-# OPTIONS_HADDOCK hide     #-}

module Game.Characters.Original.Family (characters) where

import Game.Characters.Import

import qualified Game.Model.Skill as Skill

characters :: [Int -> Category -> Character]
characters =
  [ Character
    "Konohamaru Sarutobi"
    "The overly bold grandson of the third Hokage, Konohamaru has a knack for getting into trouble and requiring others to bail him out. His usefulness in battle depends on how willing his teammates are to babysit him."
    [LeafVillage, Fire, Wind, Lightning, Yang, Sarutobi]
    [ [ Skill.new
        { Skill.name      = "Refocus"
        , Skill.desc      = "Konohamaru tries his best to concentrate on the fight. For 3 turns, status effects from his allies on him are twice as powerful, and allies who graint him health or destructible defense will grant twice as much. While active, this skill becomes [Unsexy Technique][n]."
        , Skill.classes   = [Mental]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Self $
                apply 3 [Alternate "Refocus" "Unsexy Technique", Boost 2]
          ]
        }
      , Skill.new
        { Skill.name      = "Unsexy Technique"
        , Skill.desc      = "Konohamaru distracts an enemy with his modified version of the transformation technique he learned from Naruto. For 1 turn, the target ignores helpful effects and cannot become invulnerable or benefit from damage reduction, counters, or reflects."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy $ apply 1 [Seal, Expose, Uncounter] ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Throw a Fit"
        , Skill.desc      = "Konohamaru freaks out and punches wildly at an enemy, dealing 10 damage to them for 3 turns. Deals 5 additional damage per helpful status effect on Konohamaru from his allies."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 3
        , Skill.dur       = Action 3
        , Skill.effects   =
          [ To Enemy do
              helpful <- user numHelpful
              damage (10 + 5 * helpful)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Throw a Shuriken"
        , Skill.desc      = "Konohamaru flings a shuriken almost too big for his hands at an enemy, dealing 10 damage and 10 additional damage per helpful status effect on Konohamaru from his allies."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Tai]
        , Skill.effects   =
          [ To Enemy do
              helpful <- user numHelpful
              damage (10 + 10 * helpful)
          ]
        }
      ]
    , [ invuln "Hide?" "Konohamaru" [Mental] ]
    ]
  , Character
    "Tsume Inuzuka"
    "A jōnin from the Hidden Leaf Village and mother to Kiba, Tsume shares his wild temperament, impatience, and odd sense of humor. Kuromaru, her animal companion, keeps her enemies at bay and strikes back at any who dare to attack her."
    [LeafVillage, Jonin, Inuzuka]
    [ [ Skill.new
        { Skill.name      = "Call Kuromaru"
        , Skill.desc      = "Kuromaru guards Tsume from her enemies for 4 turns, providing her with 10 points of damage reduction and dealing 10 damage to enemies who use non-bane skills on her. While active, this skill becomes [Fierce Bite][t]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Self do
                apply 4 [ Reduce [All] Flat 10
                        , Alternate "Call Kuromaru" "Fierce Bite"
                        ]
                trapFrom 4 (OnHarmed NonBane) $ damage 10
          ]
        }
      , Skill.new
        { Skill.name      = "Fierce Bite"
        , Skill.desc      = "Kuromaru pounces on an enemy, dealing 25 damage. If the target dies during the same turn, Tsume will become unkilllable for 2 turns, during which her damage will be increased by 10 and she will ignore stuns and disabling effects."
        , Skill.classes   = [Physical, Melee, Bypassing]
        , Skill.cost      = [Tai]
        , Skill.effects   =
          [ To Enemy do
                trap' -1 OnDeath $ self $
                    apply 2 [Strengthen [All] Flat 10, Endure, Focus]
                damage 25
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Tunneling Fang"
        , Skill.desc      = "Spinning like a buzzsaw, Tsume deals 15 piercing damage to an enemy for 2 turns. Deals 5 additional damage during [Call Kuromaru]. While active, all stun and disabling effects applied by the target will have their duration reduced by 2 turns."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.dur       = Action 2
        , Skill.effects   =
          [ To Enemy do
                bonus <- 5 `bonusIf` userHas "Call Kuromaru"
                pierce (15 + bonus)
                apply 1 [Throttle 2 Stuns]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Light Bomb"
        , Skill.desc      = "Tsume blinds her enemies with a flash-bang, making her team invulnerable to non-bane skills for 1 turn."
        , Skill.classes   = [Physical]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 1
        , Skill.charges   = 3
        , Skill.effects   =
          [ To Allies $ apply 1 [Invulnerable NonBane] ]
        }
      ]
    , [ invuln "Dodge" "Tsume" [Physical] ]
    ]
  , Character
    "Hiashi Hyūga"
    "A jōnin from the Hidden Leaf Village and father to Hinata and Hanabi, Hiashi does not tolerate weakness or failure. All of the Hyūga clan's secret techniques have been passed down to him, and he wields them with unmatched expertise."
    [LeafVillage, Jonin, Hyuga]
    [ [ Skill.new
        { Skill.name      = "Gentle Fist"
        , Skill.desc      = "Hiashi slams an enemy, dealing 20 damage and depleting 1 random chakra. Next turn, he repeats the attack on a random enemy."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai, Rand]
        , Skill.cooldown  = 2
        , Skill.dur       = Action 2
        , Skill.start     =
          [ To Self flag
          , To Enemy do
                deplete 1
                damage 20
          ]
        , Skill.effects   =
          [ To REnemy $ unlessM (userHas "gentle fist") do
                damage 20
                deplete 1
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Eight Trigrams Palm Rotation"
        , Skill.desc      = "Hiashi spins toward an enemy, becoming invulnerable for 2 turns and dealing 15 damage to the target and 10 to all other enemies each turn."
        , Skill.classes   = [Chakra, Melee]
        , Skill.cost      = [Blood, Rand]
        , Skill.cooldown  = 3
        , Skill.dur       = Action 2
        , Skill.effects   =
          [ To Self $ apply 1 [Invulnerable All]
          , To Enemy $ damage 15
          , To XEnemies $ damage 10
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Eight Trigrams Air Palm Wall"
        , Skill.desc      = "Targeting himself or an ally, Hiashi prepares to blast an enemy's attack back. The first skill that an enemy uses on the target next turn will be reflected."
        , Skill.classes   = [Chakra, Melee]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Ally $ apply 1 [Reflect] ]
        }
      ]
    , [ invuln "Byakugan Foresight" "Hiashi" [Mental] ]
    ]
  , Character
    "Inoichi Yamanaka"
    "A jōnin from the Hidden Leaf Village and Ino's father, Inoichi can solve practically any dilemma with his analytical perspective. Under his watchful gaze, every move made by his enemies only adds to his strength."
    [LeafVillage, Jonin, Sensor, Water, Yamanaka]
    [ [ Skill.new
        { Skill.name      = "Psycho Mind Transmission"
        , Skill.desc      = "Inoichi invades the mind of an enemy, dealing 20 damage to them for 2 turns and disabling the countering and reflecting effects of their skills."
        , Skill.classes   = [Mental, Melee, Uncounterable, Unreflectable]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 1
        , Skill.dur       = Control 2
        , Skill.effects   =
          [ To Enemy do
                damage 20
                apply 1 [ Disable Counters
                        , Disable $ Only Reflect
                        , Disable $ Any ReflectAll
                        ]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Sensory Radar"
        , Skill.desc      = "Inoichi steps back and focuses on the tide of battle. Whenever an enemy uses a skill on Inoichi or his allies, Inoichi recovers 10 health and gains a stack of [Sensory Radar]. While active, this skill becomes [Sensory Radar: Collate][r]."
        , Skill.classes   = [Mental, Ranged]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Self $ hide Permanent
                [Alternate "Sensory Radar" "Sensory Radar: Collate"]
          , To Enemies $ trap Permanent OnHarm $ self do
                heal 10
                addStack
          ]
        }
      , Skill.new
        { Skill.name      = "Sensory Radar: Collate"
        , Skill.desc      = "Inoichi compiles all the information he has gathered and puts it to use. For each stack of [Sensory Radar], he gains 1 random chakra. Ends [Sensory Radar]."
        , Skill.classes   = [Mental, Ranged]
        , Skill.cost      = [Rand]
        , Skill.effects   =
          [ To Self do
                everyone $ removeTrap "Sensory Radar"
                stacks <- userStacks "Sensory Radar"
                gain $ replicate stacks Rand
                remove "Sensory Radar"
                cancelChannel "Sensory Radar"
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Mental Invasion"
        , Skill.desc      = "Inoichi preys on an enemy's weaknesses. For 4 turns, all invulnerability effects applied by the target will have their duration reduced by 1 turn. While active, members of Inoichi's team who use a mental skill on the target will become invulnerable for 1 turn."
        , Skill.classes   = [Mental, Ranged]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.dur       = Control 4
        , Skill.effects   =
          [ To Enemy do
              apply 1 [Throttle 1 $ Any Invulnerable]
              delay -1 $
                  trapFrom 1 (OnHarmed Mental) $ apply 1 [Invulnerable All]
          ]
        }
      ]
    , [ invuln "Mobile Barrier" "Inoichi" [Chakra] ]
    ]
  , Character
    "Shikaku Nara"
    "A jōnin from the Hidden Leaf Village and Shikamaru's father, Shikaku is a master tactician capable of analyzing enormous quantities of information at lightning speed. Always one step ahead of his enemies, Shikaku spots the weaknesses in their actions and uses them as opportunities to take back control."
    [LeafVillage, Jonin, Yin, Nara]
    [ [ Skill.new
        { Skill.name      = "Shadow Possession"
        , Skill.desc      = "Shikamaru captures an enemy in shadows, stunning their non-mental skills for 2 turns and dealing 20 damage. Deals 10 additional damage if the target is affected by [Black Spider Lily]. The following turn, this skill becomes [Shadow Dispersion][g]."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Gen, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Self $
                apply 1 [Alternate "Shadow Possession" "Shadow Dispersion"]
          , To Enemy do
                bonus <- 10 `bonusIf` targetHas "Black Spider Lily"
                damage (20 + bonus)
                bonusDur <- targetStacks "Ensnared"
                apply (fromIntegral $ 2 + bonusDur) [Stun NonMental]
          ]
        }
      , Skill.new
        { Skill.name      = "Shadow Dispersion"
        , Skill.desc      = "Extending his shadow tendrils, Shikaku deals 20 damage to all enemies not affected by [Shadow Possession] and stuns their non-mental skills for 1 turn. Deals 10 additional damage to targets affected by [Black Spider Lily]."
        , Skill.require   = HasU 0 "Shadow Possession"
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Gen]
        , Skill.effects   =
          [ To Enemies do
                bonus <- 10 `bonusIf` targetHas "Black Spider Lily"
                damage (20 + bonus)
                bonusDur <- targetStacks "Ensnared"
                apply (fromIntegral $ 1 + bonusDur) [Stun NonMental]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Black Spider Lily"
        , Skill.desc      = "Shikaku draws his enemies closer with shadow tendrils for 3 turns. If an enemy affected by [Black Spider Lily] uses a skill that stuns or disables Shikaku or his allies, [Shadow Possession] and [Shadow Dispersion] will stun them for 1 additional turn if used within 3 turns."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Gen]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Enemies do
                bombWith [Bypassing] 3 []
                    [ To Done $ removeTrap "Black Spider Lily" ]
                trap 3 OnStun $ apply' "Ensnared" 3 []
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Problem Analysis"
        , Skill.desc      = "By predicting enemy attacks and using them as opportunities, Shikaku protects himself or an ally. The first skill used on them next turn that deals non-affliction damage will instead have its damage converted into destructible defense."
        , Skill.classes   = [Mental, Invisible]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Ally do
                apply 1 [DamageToDefense]
                trap 1 (OnDamaged NonAffliction) do
                    remove "Problem Analysis"
                    removeTrap "Problem Analysis"
          ]
        }
      ]
    , [ invuln "Team Formation" "Shikaku" [Physical] ]
    ]
  , Character
    "Chōza Akimichi"
    "A jōnin from the Hidden Leaf Village and Chōji's father, Chōza instills confidence in his comrades with his bravery and wisdom. Never one to back down from a fight, he defends his allies and forces the attention of his enemies to himself."
    [LeafVillage, AlliedForces, Jonin, TeamLeader, Yang, Akimichi]
    [ [ Skill.new
        { Skill.name      = "Chain Bind"
        , Skill.desc      = "Chōza slows an enemy, dealing 5 damage and weakening their physical, chakra, and summon damage by 10 for 1 turn. Chōza's team gains 5 permanent destructible defense."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.effects   =
          [ To Enemy do
                damage 5
                apply 1 [Weaken [Physical, Chakra, Summon] Flat 10]
          , To Allies $ defend Permanent 5
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Human Boulder"
        , Skill.desc      = "Chōza transforms into a rolling juggernaut. For 3 turns, he deals 15 damage to an enemy and provides 10 destructible defense to himself and his allies for 1 turn. Each turn, if the target is affected by [Chain Bind], it lasts 1 additional turn on them."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Blood, Rand]
        , Skill.cooldown  = 3
        , Skill.dur       = Action 3
        , Skill.effects   =
          [ To Allies $ defend 1 10
          , To Enemy do
                damage 15
                prolong 1 "Chain Bind"
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Partial Expansion"
        , Skill.desc      = "If used on an enemy, the next non-mental skill they use on Chōza or his allies will be countered. If used on an ally, the next non-mental skill an enemy uses on them will be countered. The person countered will take 10 damage."
        , Skill.classes   = [Physical, Melee, Invisible, Unreflectable, Nonstacking, Bypassing]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To XAlly $ trapFrom Permanent (Counter NonMental) $ damage 10
          , To Enemy $ trap Permanent (Countered NonMental) $ damage 10
          ]
        }
      ]
    , [ invuln "Block" "Chōza" [Physical] ]
    ]
  ]
