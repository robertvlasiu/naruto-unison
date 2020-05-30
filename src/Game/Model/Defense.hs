{-# LANGUAGE DeriveAnyClass #-}

module Game.Model.Defense (Defense(..)) where

import ClassyPrelude

import Data.Aeson (ToJSON)

import qualified Class.Labeled
import           Class.Labeled (Labeled)
import           Class.TurnBased (TurnBased(..))
import           Game.Model.Duration (Duration)
import           Game.Model.Slot (Slot)

-- | Destructible defense.
data Defense = Defense { amount :: Int
                       , user   :: Slot
                       , name   :: Text
                       , dur    :: Duration
                       } deriving (Eq, Show, Read, Generic, ToJSON)
instance TurnBased Defense where
    getDur     = dur
    setDur d x = x { dur = d }
instance Labeled Defense where
    name = name
    user = user
