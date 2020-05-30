module Game.Model.Barrier (Barrier(..), new) where

import ClassyPrelude

import           Game.Model.Context (Context)
import qualified Game.Model.Context as Context
import           Game.Model.Internal (Barrier(..))
import           Game.Model.Runnable (Runnable(To), RunConstraint)
import           Game.Model.Duration (Duration)
import qualified Game.Model.Skill as Skill

-- | Adds a 'Barrier' with an effect that occurs when its duration
-- 'Barrier.finish'es, which is passed as an argument the 'Barrier.amount' of
-- barrier remaining, and an effect that occurs each turn 'Barrier.while' it
-- exists.
new :: Context
    -> Duration
    -> (Int -> RunConstraint ()) -- ^ Applied at end with amount remaining.
    -> RunConstraint () -- ^ Applied every turn.
    -> Int -- ^ Initial amount.
    -> Barrier
new context dur finish while amount = Barrier
    { user   = Context.user context
    , name   = Skill.name skill
    , finish = \i -> To saved { Context.continues = False } $ finish i
    , while  = To saved { Context.continues = True } while
    , amount
    , dur
    }
  where
    saved = context { Context.new = False }
    skill = Context.skill context
