module Game.Model.Channel
  ( Channel(..)
  , interruptible
  , Channeling(..)
  , ignoreStun
  ) where

import ClassyPrelude

import Game.Model.Internal (Channel(..), Channeling(..))

-- | 'Control' and 'Action' 'Model.Skill.Skill's can be interrupted.
-- Others cannot, because they are not considered user actions.
interruptible :: Channel -> Bool
interruptible Channel {dur = Control{}} = True
interruptible Channel {dur = Action{}}  = True
interruptible _                         = False

-- | 'Passive' and 'Ongoing' effects are not affected by 'Model.Effect.Stun'.
ignoreStun :: Channeling -> Bool
ignoreStun Passive   = True
ignoreStun Ongoing{} = True
ignoreStun _         = False
