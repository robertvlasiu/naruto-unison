{-# LANGUAGE OverloadedLists #-}
{-# OPTIONS_HADDOCK hide     #-}

module Game.Characters.Original.Flashbacks (characters) where

import Game.Characters.Import

import qualified Game.Model.Skill as Skill

characters :: [Int -> Category -> Character]
characters =
  [ Character
    "Kushina Uzumaki"
    "Known as the Red-Hot Habanero for her fiery hair and fierce temper, Naruto's mother possesses exceptional chakra necessary to become the nine-tailed fox's jinchūriki. Kushina specializes in unique sealing techniques that bind and incapacitate her enemies."
    [LeafVillage, Jinchuriki, Wind, Water, Yin, Uzumaki]
    [ [ Skill.new
        { Skill.name      = "Double Tetragram Seal"
        , Skill.desc      = "Kushina seals away an enemy's power, demolishing their destructible defense and her own destructible barrier, dealing 15 piercing damage, stunning them for 1 turn, depleting 1 random chakra, and weakening their damage by 5."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Gen, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                demolishAll
                deplete 1
                pierce 15
                apply 1 [Stun All]
                apply Permanent [Weaken [All] Flat 5]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Life Link"
        , Skill.desc      = "Kushina binds her life-force to that of an enemy. For 4 turns, if either dies, the other will die as well. Effect cannot be avoided, prevented, or removed. While active, this skill becomes [Life Transfer][r]."
        , Skill.classes   = [Mental, Ranged, Bypassing, Unremovable, Uncounterable, Unreflectable]
        , Skill.cost      = [Gen, Rand]
        , Skill.cooldown  = 5
        , Skill.effects   =
          [ To Enemy do
                tag 4
                trap 4 OnDeath $ self killHard
                self do
                    apply 4 [Alternate "Life Link" "Life Transfer"]
                    trap 4 OnDeath $
                        everyone $ whenM (targetHas "Life Link") killHard
          ]
        }
      , Skill.new
        { Skill.name      = "Life Transfer"
        , Skill.desc      = "Kushina transfers part of her life to an ally, restoring 25 health to the target but losing 25 of her own health."
        , Skill.classes   = [Mental, Ranged]
        , Skill.cost      = [Rand]
        , Skill.effects   =
          [ To XAlly $ heal 25
          , To Self $ sacrifice 0 25
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Adamantine Sealing Chains"
        , Skill.desc      = "A cage of chain-shaped chakra seals an enemy, removing the effects of helpful skills from them and stunning them for 2 turns. While active, the target is invulnerable to allies as well as enemies."
        , Skill.classes   = [Chakra, Ranged, Bypassing, Uncounterable, Unreflectable]
        , Skill.cost      = [Blood, Gen]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Enemy do
                purge
                apply 2 [Stun All, Alone, Invulnerable All]
          ]
        }
      ]
    , [ invuln "Adamantine Covering Chains" "Kushina" [Chakra] ]
    ]
  , Character
    "Minato Namikaze"
    "Known as the Yellow Flash for his incredible speed and mastery of space-time techniques, Naruto's father is a jōnin squad leader from the Hidden Leaf Village. Minato fights using unique kunai that allow him to teleport arround the battlefield."
    [LeafVillage, Jonin, Jinchuriki, Sage, Sensor, TeamLeader, Fire, Wind, Lightning, Yin, Yang]
    [ [ Skill.new
        { Skill.name      = "Flying Raijin"
        , Skill.desc      = "Minato teleports to a target, becoming invulnerable for 1 turn. If he teleports to an enemy, he deals 30 damage. If he teleports to an ally, the ally becomes invulnerable for 1 turn."
        , Skill.classes   = [Physical, Melee, Bypassing]
        , Skill.cost      = [Gen, Rand]
        , Skill.effects   =
        [ To Self $ apply 1 [Invulnerable All]
        , To XAllies $
              whenM (targetHas "Space-Time Marking") $
                  apply 1 [Invulnerable All]
        , To Enemies $ whenM (targetHas "Space-Time Marking") $ damage 30
        , To XAlly do
              apply 1 [Invulnerable All]
              whenM (userHas "Space-Time Marking") $ tag' "Space-Time Marking" 1
        , To Enemy do
              damage 30
              whenM (userHas "Space-Time Marking") $ tag' "Space-Time Marking" 1
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Sensory Technique"
        , Skill.desc      = "Minato's senses expand to cover the battlefield, preventing enemies from reducing damage or becoming invulnerable for 2 turns. Each turn, Minato gains 1 random chakra."
        , Skill.classes   = [Chakra, Ranged, Bypassing]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 3
        , Skill.dur       = Control 2
        , Skill.effects   =
          [ To Enemies $ apply 1 [Expose]
          , To Self $ gain [Rand]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Space-Time Marking"
        , Skill.desc      = "For 3 turns, [Flying Raijen] marks its target for 1 turn. Using [Flying Raijen] causes marked allies to become invulnerable for 1 turn and deals 30 damage to marked enemies."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Gen, Nin]
        , Skill.cooldown  = 6
        , Skill.effects   =
          [ To Self $ tag 3 ]
        }
      ]
    , [ invuln "Flying Light" "Minato" [Physical] ]
    ]
  , Character
    "Yondaime Minato"
    "As the fourth Hokage, Minato has been shaped by his responsibilities into a thoughtful and strategic leader. With his space-time jutsu, he redirects the attacks of his enemies and effortlessly passes through their defenses."
    [LeafVillage, Kage, Sage, TeamLeader, Fire, Wind, Lightning, Yin, Yang]
    [ [ Skill.new
        { Skill.name      = "Rasengan"
        , Skill.desc      = "Minato teleports behind an enemy and slams an orb of chakra into them, dealing 35 damage. Costs 1 ninjutsu chakra if [Rasengan] was used last turn."
        , Skill.classes   = [Chakra, Melee, Bypassing, Uncounterable, Unreflectable]
        , Skill.cost      = [Gen, Nin]
        , Skill.effects   =
          [ To Enemy $ damage 35
          , To Self $ tag 1
          ]
        , Skill.changes   =
            changeWith "Rasengan" \x -> x { Skill.cost = [Nin] }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Teleportation Barrier"
        , Skill.desc      = "Space warps around Minato or one of his allies. The first skill an enemy uses on the target within 2 turns will be reflected back at them."
        , Skill.classes   = [Chakra, Ranged, Unreflectable, Invisible]
        , Skill.cost      = [Gen, Gen]
        , Skill.cooldown  = 5
        , Skill.effects   =
          [ To Ally $ apply 2 [Reflect] ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Reaper Death Seal"
        , Skill.desc      = "Minato unleashes the God of Death upon an enemy in exchange for a piece of his soul, sacrificing 15 health to deal 25 affliction damage and weaken the target's damage by 5."
        , Skill.classes   = [Melee]
        , Skill.cost      = [Rand, Rand]
        , Skill.effects   =
          [ To Enemy do
                afflict 25
                apply Permanent [Weaken [All] Flat 5]
          , To Self $ sacrifice 0 15
          ]
        }
      ]
    , [ invuln "Parry" "Minato" [Physical] ]
    ]
  , Character
    "Hashirama Senju"
    "The founder and first Hokage of the Hidden Leaf Village, Hashirama is headstrong and enthusiastic. He believes with all his heart that communities should behave as families, taking care of each other and protecting their children from the cruelties of war. Due to a unique genetic mutation, Hashirama is able shape wood into defensive barriers and constructs."
    [LeafVillage, Kage, Sage, Earth, Water, Fire, Wind, Lightning, Yin, Yang, Senju]
    [ [ Skill.new
        { Skill.name      = "Wooden Dragon"
        , Skill.desc      = "A vampiric dragon made of wood drains chakra from Hashirama's enemies, making him invulnerable to chakra skills for 2 turns. Each turn, Hashirama absorbs 1 random  chakra from his enemies."
        , Skill.classes   = [Chakra, Melee]
        , Skill.cost      = [Blood, Rand]
        , Skill.cooldown  = 2
        , Skill.dur       = Action 2
        , Skill.effects   =
          [ To Self $ apply 1 [Invulnerable Chakra]
          , To REnemy $ absorb 1
          ]
        , Skill.changes   =
            changeWith "Veritable 1000-Armed Kannon"
            \x -> x { Skill.dur = Action 3, Skill.cost = [Blood] }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Wood Golem"
        , Skill.desc      = "A giant humanoid statue attacks an enemy, dealing 20 damage for 2 turns. While active, Hashirama is invulnerable to physical skills."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Blood, Rand]
        , Skill.cooldown  = 2
        , Skill.dur       = Action 2
        , Skill.effects   =
          [ To Enemy $ damage 20
          , To Self $ apply 1 [Invulnerable Physical]
          ]
        , Skill.changes   =
            changeWith "Veritable 1000-Armed Kannon"
            \x -> x { Skill.dur = Action 3, Skill.cost = [Blood] }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Veritable 1000-Armed Kannon"
        , Skill.desc      = "A titanic many-handed Buddha statue looms over the battlefield, providing 30 permanent destructible defense to Hashirama and his allies. For the next 3 turns, [Wooden Dragon] and [Wood Golem] cost 1 fewer arbitrary chakra and last 1 additional turn."
        , Skill.classes   = [Physical]
        , Skill.cost      = [Blood, Blood]
        , Skill.cooldown  = 5
        , Skill.effects   =
          [ To Allies $ defend Permanent 30
          , To Self $ tag 3
          ]
        }
      ]
    , [ invuln "Foresight" "Hashirama" [Mental] ]
    ]
  , Character
    "Young Kakashi"
    "A member of Team Minato, Kakashi is the thirteen-year-old son of the legendary White Fang. His early ninjutsu and borrowed Sharingan make him the equal of any adult he faces."
    [LeafVillage, Jonin, TeamLeader, Lightning, Water, Earth, Fire, Wind, Yin, Yang]
    [ [ Skill.new
        { Skill.name      = "White Light Blade"
        , Skill.desc      = "Kakashi deals 20 piercing damage to an enemy with his sword. For 1 turn, the target's damage is weakened by 5 and Kakashi's damage is increased by 5."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.effects   =
          [ To Enemy do
                pierce 20
                apply 1 [Weaken [All] Flat 5]
                whenM (userHas "Sharingan Stun") $ apply 1 [Stun All]
          , To Self $ apply 1 [Strengthen [All] Flat 5]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Lightning Blade"
        , Skill.desc      = "Using an amateurish early form of his signature technique, Kakashi deals 20 piercing damage to one enemy. For 1 turn, the target's damage is weakened by 5 and Kakashi's damage is increased by 5."
        , Skill.classes   = [Bane, Chakra, Melee]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Enemy do
                pierce 20
                apply 1 [Weaken [All] Flat 5]
                whenM (userHas "Sharingan Stun") $ apply 1 [Stun All]
          , To Self $ apply 1 [Strengthen [All] Flat 5]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Sharingan"
        , Skill.desc      = "Kakashi anticipates an opponent's moves for 2 turns. If they use a skill that gains, depletes, or absorbs chakra, Kakashi gains 1 random chakra. If they use a skill that stuns or disables, Kakashi's skills will stun next turn. If they use a skill that damages, Kakashi's damage will be increased by 10 during the next turn. Ends when triggered."
        , Skill.classes   = [Mental, Ranged, Invisible]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                whenM (userHas "Sharingan Stun") $ apply 1 [Stun All]
                trap 2 OnChakra do
                    removeTrap "Sharingan"
                    self $ gain [Rand]
                trap 2 OnStun do
                    removeTrap "Sharingan"
                    self $ tag' "Sharingan Stun" 1
                trap 2 OnDamage do
                    removeTrap "Sharingan"
                    self $ apply 1 [Strengthen [All] Flat 10]
          ]
        }
      ]
    , [ invuln "Parry" "Kakashi" [Physical] ]
    ]
  , Character
    "Rin Nohara"
    "A chūnin on Team Minato, Rin is a quiet but strong-willed medical-nin. Her priority is always healing her teammates, though she can also defend herself with traps if necessary."
    [LeafVillage, Chunin, Jinchuriki, Fire, Water, Yang]
    [ [ Skill.new
        { Skill.name      = "Pit Trap"
        , Skill.desc      = "An enemy falls into a pit and is trapped there for 1 turn. At the end of their turn, the target takes 15 piercing damage. If they used a skill that turn, they take 15 additional damage. While active, Rin gains 15 points of damage reduction."
        , Skill.classes   = [Physical, Ranged, Invisible, Bypassing]
        , Skill.cost      = [Gen]
        , Skill.effects   =
          [ To Self $ apply 1 [Reduce [All] Flat 15]
          , To Enemy do
                trap 1 (OnAction All) flag
                delay -1 do
                    bonus <- 15 `bonusIf` targetHas "pit trap"
                    pierce (15 + bonus)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Healing Technique"
        , Skill.desc      = "Rin restores 25 health to herself or an ally and cures the target of bane effects."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Ally do
                cureBane
                heal 25
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Medical Kit"
        , Skill.desc      = "Rin or one of her allies uses her medical kit for 3 turns, restoring 10 health each turn and strengthening their healing skills by 10 points."
        , Skill.classes   = [Physical, Unremovable]
        , Skill.cost      = [Rand, Rand]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Ally $ apply 3 [Bless 10, Heal 10] ]
        }
      ]
    , [ invuln "Flee" "Rin" [Physical] ]
    ]
  , Character
    "Obito Uchiha"
    "A member of Team Minato, Obito is treated as a nobody despite his Uchiha heritage. He dreams of becoming Hokage so that people will finally acknowledge him. Accustomed to helping from the sidelines, if he falls in battle, he will lend his strength to his allies."
    [LeafVillage, Chunin, Jinchuriki, Sensor, Fire, Wind, Lightning, Earth, Water, Yin, Yang, Uchiha]
    [ [ Skill.new
        { Skill.name      = "Piercing Stab"
        , Skill.desc      = "Spotting an opening in his enemy's defense, Obito stabs them to deal 15 piercing damage. Deals 10 additional damage during [Sharingan]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.effects   =
          [ To Enemy do
                bonus <- 10 `bonusIf` userHas "Sharingan"
                pierce (15 + bonus)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Grand Fireball"
        , Skill.desc      = "Obito breathes searing fire on an enemy, dealing 15 affliction damage for 2 turns. During [Sharingan], this skill deals the full 30 affliction damage instantly and has no cooldown."
        , Skill.classes   = [Bane, Ranged]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy $ apply 2 [Afflict 15] ]
        }
      , Skill.new
        { Skill.name      = "Grand Fireball "
        , Skill.desc      = "Obito breathes searing fire on an enemy, dealing 15 affliction damage for 2 turns. During [Sharingan], this skill deals the full 30 affliction damage instantly and has no cooldown."
        , Skill.classes   = [Bane, Ranged]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Enemy $ afflict 30 ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Sharingan"
        , Skill.desc      = "Obito targets an ally. For 4 turns, Obito gains 15 points of damage reduction, and if Obito dies, the ally will gain 5 points of damage reduction and deal 5 additional non-affliction damage."
        , Skill.classes   = [Mental, Unremovable]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To XAlly $ tag 4
          ,  To Self do
                apply 4 [ Reduce [All] Flat 15
                        , Alternate "Grand Fireball" "Grand Fireball "
                        ]
                trap 4 OnDeath $ everyone $ whenM (targetHas "Sharingan") $
                    apply' "Borrowed Sharingan" Permanent
                        [ Reduce [All] Flat 5
                        , Strengthen [NonAffliction] Flat 5
                        ]
          ]
        }
      ]
    , [ invuln "Flee" "Obito" [Physical] ]
    ]
  , Character
    "Masked Man"
    "As the nine-tailed beast rampages across the Hidden Leaf Village, a mysterious masked man appears and attempts to bend it to his will. The legendary beast demolishes house after house, laying waste to the defenses of its enemies."
    [LeafVillage, Jinchuriki, Sensor, SRank, Fire, Wind, Lightning, Earth, Water, Yin, Yang, Uchiha]
    [ [ Skill.new
        { Skill.name      = "Kusari Chains"
        , Skill.desc      = "The masked man snares an enemy in sealing chains, stunning their physical skills and preventing them from reducing damage or becoming invulnerable for 1 turn."
        , Skill.classes   = [Chakra, Melee]
        , Skill.cost      = [Tai]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Self $ tag' "Corporeal" 1
          , To Enemy $ apply 1 [Stun Physical, Expose]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Kamui Banishment"
        , Skill.desc      = "The masked man uses a rare space-time technique to banish an enemy to his pocket dimension, dealing 20 piercing damage and making them invulnerable to their allies for 1 turn. While active, the target can only target the masked man or themselves. Deals 20 additional damage and lasts 1 additional turn if the target is affected by [Kusari Chains]."
        , Skill.classes   = [Chakra, Melee, Unreflectable, Soulbound]
        , Skill.cost      = [Gen]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Self $ tag' "Corporeal" 1
          , To Enemy do
                bonus <- 1 `bonusIf` targetHas "Kusari Chains"
                pierce (20 + 20 * bonus)
                userSlot <- user slot
                apply (fromIntegral $ 1 + bonus) [Alone, Taunt userSlot]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Major Summoning: Kurama"
        , Skill.desc      = "The masked man summons the nine-tailed beast to the battlefield to wreak havoc. For 3 turns, it demolishes the enemy team's destructible defense and the masked man's own destructible barrier, then deals 25 damage to a random enemy."
        , Skill.classes   = [Summon, Melee, Bypassing]
        , Skill.cost      = [Blood, Gen, Tai]
        , Skill.cooldown  = 5
        , Skill.dur       = Ongoing 3
        , Skill.effects   =
          [ To Self $ tag' "Corporeal" 1
          , To Enemies demolishAll
          , To REnemy $ damage 25
          ]
        }
      ]
    , [ (invuln "Kamui Phase" "The masked man" [Chakra])
        { Skill.desc     = "The masked man becomes invulnerable for 1 turn. Cannot be used if any skills were used last turn."
        , Skill.require  = HasI 0 "Corporeal"
        , Skill.cooldown = 0
        , Skill.effects  =
          [ To Self do
                tag' "Corporeal" 1
                apply 1 [Invulnerable All]
          ]
        }
      ]
    ]
  ]
