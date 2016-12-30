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

foreign import data WatchClient :: *
foreign import newWatchClient :: forall eff.
  Eff eff WatchClient

foreign import watch :: forall eff.
  WatchClient
  -> FilePath -- root dir
  -> String -- ^ match
  -> (Array FileInfos -> Eff eff Unit )  -- ^ action
  -> Eff eff Unit

foreign import debug :: forall eff a. a -> Eff eff Unit

testWatch :: forall eff. Eff eff Unit
testWatch = do
  client <- newWatchClient
  watch client "/Users/rvion/dev/jenny/examples/db" "*.jenny" debug
