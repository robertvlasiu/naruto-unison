-- | Turn execution. The surface of the game engine.
module Game.Engine
  ( runTurn
  , processTurn
  , unSoulbound
  , skipTurn
  , forfeit
  , resetInactive
  ) where

import ClassyPrelude

import Control.Monad (zipWithM_)
import Data.List (deleteFirstsBy)

import           Class.Hook (MonadHook)
import qualified Class.Hook as Hook
import qualified Class.Labeled as  Labeled
import qualified Class.Parity as Parity
import           Class.Play (MonadGame)
import qualified Class.Play as P
import           Class.Random (MonadRandom)
import qualified Class.TurnBased as TurnBased
import qualified Game.Action as Action
import qualified Game.Engine.Chakras as Chakras
import qualified Game.Engine.Effects as Effects
import qualified Game.Engine.Ninjas as Ninjas
import qualified Game.Engine.Traps as Traps
import           Game.Model.Act (Act)
import qualified Game.Model.Act as Act
import qualified Game.Model.Barrier as Barrier
import           Game.Model.Class (Class(..))
import qualified Game.Model.Context as Context
import           Game.Model.Copy (Copy(Copy))
import qualified Game.Model.Copy
import qualified Game.Model.Delay as Delay
import           Game.Model.Effect (Effect(..))
import qualified Game.Model.Game as Game
import           Game.Model.Ninja (Ninja, is)
import qualified Game.Model.Ninja as Ninja
import           Game.Model.Player (Player)
import qualified Game.Model.Player as Player
import qualified Game.Model.Runnable as Runnable
import qualified Game.Model.Skill as Skill
import           Game.Model.Slot (Slot)
import qualified Game.Model.Slot as Slot
import           Game.Model.Status (Bomb(..), Status)
import qualified Game.Model.Status as Status
import qualified Game.Model.Trap as Trap
import           Game.Model.Trigger (Trigger(..))
import           Util ((<$>.), (—), (∈), (∉))

-- | The game engine's main function.
-- Performs 'Act's and 'Model.Channel.Channel's;
-- applies effects from 'Bomb's, 'Barrier.Barrier's, 'Delay.Delay's, and
-- 'Model.Trap.Trap's;
-- decrements all 'TurnBased.TurnBased' data;
-- and resolves 'Model.Chakra.Chakras' for the next turn.
-- Uses 'processTurn' internally.
runTurn :: ∀ m o. ( MonadGame m, MonadHook m, MonadRandom m
                  , MonoTraversable o, Act ~ Element o
                  ) => o -> m ()
runTurn acts = do
    processTurn $ traverse_ (Action.act True) acts
    Chakras.gain

-- | The underlying mechanism of 'runTurn'.
-- Performs posteffects such as 'Model.Channel.Channel's and 'Model.Trap.Trap's.
-- Using 'runTurn' is generally preferable to invoking this function directly.
processTurn :: ∀ m. (MonadGame m, MonadHook m, MonadRandom m) => m () -> m ()
processTurn runner = do
    initial     <- P.ninjas
    player      <- Game.playing <$> P.game
    let opponent = Player.opponent player
    runner
    channels <- concatMap getChannels . filter Ninja.alive <$> P.allies player
    traverse_ (Action.act False) channels
    Traps.runTurn initial
    doBombs Remove initial
    doBarriers
    doDelays
    doDeaths
    expired <- P.ninjas
    P.modifyAll Ninjas.decr
    doBombs Expire expired
    doBombs Done initial
    doHpsOverTime
    P.alter \g -> g { Game.playing = opponent }
    doDeaths
    yieldVictor
    Hook.turn player initial =<< P.ninjas
  where
    getChannels n = Act.fromChannel n <$>.
                    filter ((/= -1) . TurnBased.getDur) $
                    Ninja.channels n

-- | Runs 'Game.delays'.
doDelays :: ∀ m. (MonadGame m, MonadRandom m) => m ()
doDelays = traverse_ delay . filter Ninja.alive =<< P.ninjas
  where
    delay n = traverse_ (P.launch . Delay.effect) .
              filter ((<= -1) . Delay.dur) $ Ninja.delays n

-- | Executes 'Status.bombs' of a @Status@.
doBomb :: ∀ m. (MonadGame m, MonadRandom m) => Bomb -> Slot -> Status -> m ()
doBomb bomb target st = traverse_ detonate $ Status.bombs st
  where
    context = (Context.fromStatus st) { Context.target = target }
    detonate x
      | bomb /= Runnable.target x = return ()
      | otherwise = P.withContext context . Action.wrap $ Runnable.run x

-- | Executes 'Status.bombs' of all 'Status'es that were removed.
doBombs :: ∀ m. (MonadGame m, MonadRandom m) => Bomb -> [Ninja] -> m ()
doBombs bomb ninjas = zipWithM_ comp ninjas =<< P.ninjas
  where
    comp n n' = sequence $
                doBomb bomb (Ninja.slot n) <$> deleteFirstsBy Labeled.eq
                (stats n) (stats n')
      where
        stats
          | Ninja.alive n' = Ninja.statuses
          | otherwise      = filter ((Necromancy ∈) . Status.classes) .
                             Ninja.statuses

-- | Executes 'Barrier.while' and 'Barrier.finish' effects.
doBarriers :: ∀ m. (MonadGame m, MonadRandom m) => m ()
doBarriers = do
    player <- P.player
    ninjas <- P.ninjas
    traverse_ (doBarrier player) $ concatMap (head <$>. collect) ninjas
  where
    collect n = groupBy Labeled.eq . sortWith Barrier.name $ Ninja.barrier n
    doBarrier p b
      | Barrier.dur b == -1 = P.launch . Barrier.finish b $ Barrier.amount b
      | Parity.allied p $ Barrier.user b = P.launch $ Barrier.while b
      | otherwise = return ()

-- | Executes 'Trigger.death'.
doDeaths :: ∀ m. (MonadGame m, MonadHook m, MonadRandom m) => m ()
doDeaths = traverse_ doDeath Slot.all

-- | If the 'Ninja.health' of a 'Ninja' reaches 0,
-- they are either resurrected by triggering 'OnRes'
-- or they die and trigger 'OnDeath'.
-- If they die, their 'Soulbound' effects are canceled.
doDeath :: ∀ m. (MonadGame m, MonadHook m, MonadRandom m) => Slot -> m ()
doDeath slot = do
    n <- P.ninja slot
    let res
          | n `is` Plague = mempty
          | otherwise     = Traps.getOf slot OnRes n

    if Ninja.health n > 0 then
        return ()

    else if null res then do
        P.modify slot $ Ninjas.clearTraps OnDeath
        sequence_ $ Traps.getOf slot OnDeath n
        traverse_ (doBomb Done slot) .
            filter ((Necromancy ∉) . Status.classes) $ Ninja.statuses n
        P.modifyAll $ unSoulbound slot

    else do
        P.modify slot $ Ninjas.setHealth 1 . Ninjas.clearTraps OnRes
        sequence_ res

-- | Removes 'Soulbound' effects. Applied when a Ninja dies or is factory-reset.
unSoulbound :: Slot -> Ninja -> Ninja
unSoulbound user n = Ninjas.modifyStatuses
        (const [st | st <- Ninja.statuses n
                   , user /= Status.user st
                     || Soulbound ∉ Status.classes st]) $
        n { Ninja.traps = [trap | trap <- Ninja.traps n
                                , user /= Trap.user trap
                                  || Soulbound ∉ Trap.classes trap]
          , Ninja.copies = filter keep $ Ninja.copies n
          }
  where
    keep Nothing = True
    keep (Just Copy{skill}) = user /= Skill.owner skill
                              || Soulbound ∉ Skill.classes skill
-- | Executes 'Model.Effect.Afflict' and 'Model.Effect.Heal'
-- 'Model.Effect.Effect's.
doHpsOverTime :: ∀ m. MonadGame m => m ()
doHpsOverTime = traverse_ doHpOverTime Slot.all

doHpOverTime :: ∀ m. MonadGame m => Slot -> m ()
doHpOverTime slot = do
    player <- P.player
    n      <- P.ninja slot
    hp     <- Effects.hp player n <$> P.ninjas
    when (Ninja.alive n) . P.modify slot $ Ninjas.adjustHealth (— hp)

-- | Updates 'Game.victor'.
yieldVictor :: ∀ m. MonadGame m => m ()
yieldVictor = whenM (Game.inProgress <$> P.game) do
    ninjas <- P.ninjas
    let splitNs = splitAt (length ninjas `quot` 2) ninjas
    P.alter \g ->
        g { Game.victor = filter (victor splitNs) [Player.A, Player.B] }
  where
    victor (_, ninjas) Player.A = not $ any Ninja.alive ninjas
    victor (ninjas, _) Player.B = not $ any Ninja.alive ninjas

forfeit :: ∀ m. MonadGame m => Player -> m ()
forfeit player = whenM (Game.inProgress <$> P.game) do
    P.modifyAll suicide
    P.alter \g -> g { Game.victor  = [Player.opponent player]
                    , Game.forfeit = True
                    }
  where
    suicide n
      | Parity.allied player n = n { Ninja.health = 0 }
      | otherwise              = n

-- | Adds to 'Game.inactive', and forfeits if a threshold is reached.
skipTurn :: ∀ m. (MonadGame m, MonadHook m, MonadRandom m)
         => Int -> Player -> m ()
skipTurn threshold player = do
    P.alter \g ->
        g { Game.inactive = Parity.modifyOf player (+ 1) $ Game.inactive g }
    inactive <- Parity.getOf player . Game.inactive <$> P.game
    if inactive >= threshold then
        forfeit player
    else
        runTurn []

-- | Resets 'Game.inactive'.
resetInactive :: ∀ m. MonadGame m => Player -> m ()
resetInactive player = P.alter \g ->
    g { Game.inactive = Parity.setOf player 0 $ Game.inactive g }
