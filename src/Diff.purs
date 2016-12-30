module Diff where

import Control.Monad.Eff (Eff)
import Prelude

foreign import showDiff :: forall eff.
  String -> String -> Eff eff Unit
