-- Helper functions.
module Core.Util
  ( (!?), (!!), (—), (∈), (∉)
  , Lift
  , intersects, intersectsSet
  , duplic
  , shorten
  ) where

import ClassyPrelude hiding ((<|), mapMaybe)
import Control.Monad.Trans.Class (MonadTrans)
import Data.List (nub)

infixl 9 !?
-- | 'unsafeIndex'.
(!?) :: ∀ o. IsSequence o => o -> Index o -> Maybe (Element o)
(!?) = index
{-# INLINE (!?) #-}

infixl 9 !!
-- | 'unsafeIndex'.
(!!) :: ∀ o. IsSequence o => o -> Index o -> Element o
(!!) = unsafeIndex
{-# INLINE (!!) #-}

-- | '-' allowing for sections.
infixl 6 —
(—) :: ∀ a. Num a => a -> a -> a
(—) = (-)
{-# INLINE (—) #-}

-- | 'elem'.
infix 4 ∈
(∈) :: ∀ o. (MonoFoldable o, Eq (Element o)) => Element o -> o -> Bool
(∈) = elem
{-# INLINE (∈) #-}

-- | 'notElem'.
infix 4 ∉
(∉) :: ∀ o. (MonoFoldable o, Eq (Element o)) => Element o -> o -> Bool
(∉) = notElem
{-# INLINE (∉) #-}

-- | True if any elements are shared by both collections.
intersects :: ∀ a b.
    (MonoFoldable a, MonoFoldable b, Element a ~ Element b, Eq (Element a))
    => a -> b -> Bool
intersects x y = any (∈ y) x
{-# INLINE intersects #-}

-- | True if any elements are shared by both collections.
intersectsSet :: ∀ a. SetContainer a => a -> a -> Bool
intersectsSet xs = not . null . intersection xs
{-# INLINE intersectsSet #-}

-- | True if a list contains multiple identical values.
duplic :: ∀ a. Eq a => [a] -> Bool
duplic x = nub x /= x
{-# INLINE duplic #-}

-- | Removes spaces and special characters.
shorten :: Text -> Text
shorten = omap f . filter (∉ bans)
  where
    bans :: String
    bans  = " -:()®'/?"
    f 'ō' = 'o'
    f 'Ō' = 'O'
    f 'ū' = 'u'
    f 'Ū' = 'U'
    f 'ä' = 'a'
    f a = a

-- | A metaconstraint for liftable functions.
-- Useful for default signatures of MTL classes:
-- > default myfunc :: Lift MyMonad m => m ()
-- > myfunc = lift myfunc
type Lift mtl m = (MonadTrans (Car m), mtl (Cdr m), m ~ Car m (Cdr m))
-- Just don't worry about it
type family Car m :: (* -> *) -> * -> * where Car (t n) = t
type family Cdr (m :: * -> *) :: * -> * where Cdr (t n) = n
