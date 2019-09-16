{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE CPP             #-}
{-# OPTIONS_HADDOCK hide     #-}

module Characters.Development (cs) where

import Characters.Base

#ifdef DEVELOPMENT
import qualified Model.Skill as Skill

cs :: [Category -> Character]
cs =
  [ Character
    "Gaara of the Funk"
    "This development-only character exists in stack exec -- yesod devel, but not stack exec -- yesod keter."
    [ [ Skill.new
        { Skill.name    = "Nchk-Nchk-Nchk-Nchk"
        , Skill.desc    = "The power of beatboxing grants 50 of each chakra type."
        , Skill.effects =
          [ To Self $ gain $ replicate 50 =<< [Blood, Gen, Nin, Tai] ]
        }
      ]
    , [ Skill.new
        { Skill.name    = "Dance Dance Resurrection"
        , Skill.desc    = "Revives a dead target to full health."
        , Skill.classes = [Necromancy, Bypassing, Direct, Uncounterable, Unreflectable]
        , Skill.effects =
          [ To Enemy factory
          , To XAlly factory
          ]
        }
      ]
    , [ Skill.new
        { Skill.name    = "Funk Coffin"
        , Skill.desc    = "Instantly kills a target who does not respect the funk."
        , Skill.classes = [Bypassing, Direct, Uncounterable, Unreflectable]
        , Skill.effects =
          [ To Enemy kill
          , To Ally  kill
          ]
        }
      ]
    , [ Skill.new
        { Skill.name    = "The Funk Wasn't With You"
        , Skill.desc    = "Permanently stuns the entire enemy team. Once used, this skill becomes [Could've Had a V8]."
        , Skill.classes = [Bypassing, Direct, Uncounterable, Unreflectable]
        , Skill.effects =
          [ To Enemies $ apply 0 [Stun All]
          , To Self    $ vary "The Funk Wasn't With You" "Could've Had a V8"
          ]
        }
      , Skill.new
        { Skill.name    = "Could've Had a V8"
        , Skill.desc    = "Frees the enemy team from the effect of [The Funk Wasn't With You]. Once used, this skill becomes [The Funk Wasn't With You]."
        , Skill.classes = [Bypassing, Direct, Uncounterable, Unreflectable]
        , Skill.effects =
          [ To Enemies $ remove "The Funk Wasn't With You"
          , To Self    $ vary "The Funk Wasn't With You" baseVariant
          ]
        }
      ]
    ]
  ]
#else
cs :: [Category -> Character]
cs = []
#endif