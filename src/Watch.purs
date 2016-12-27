module Watch where

import Prelude
import Control.Monad.Eff (Eff)
import Node.Path (FilePath)

type FileInfos = {
  name ::String,
  size :: String,
  mtime_ms :: String,
  exists :: String,
  type :: String
}

foreign import watch :: forall eff.
  FilePath -- root dir
  -> String -- ^ match
  -> (Array FileInfos -> Eff eff Unit )  -- ^ action
  -> Eff eff Unit

foreign import debug :: forall eff a. a -> Eff eff Unit

testWatch :: forall eff. Eff eff Unit
testWatch = watch "/Users/rvion/dev/jenny/examples/db" "*.jenny" debug
