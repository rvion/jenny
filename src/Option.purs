module Option where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Node.Yargs.Applicative (Y, flag, runY, yarg)
import Node.Yargs.Setup (YargsSetup, example, usage)

type Options = {
  templates :: Array String,
  watch :: Array String,
  prefixPath :: String,
  debug :: Boolean
}

getOpts :: forall eff. Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options
getOpts = runY setup parser
  where
    parser :: Y (Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options)
    parser = (\templates  watch  prefixPath  debug ->
         pure {templates, watch, prefixPath, debug})
      <$> yarg "template" ["t"]
        (Just "template file")
        (Left [])
        false
      <*> yarg "watch" ["w", "live"]
        (Just "watch *.jenny templates in given folder")
        (Left [])
        false
      <*> yarg "p" ["prefix", "path"]
        (Just "local output path prefix (default: 'gen')")
        (Left "gen")
        false
      <*> flag "d" ["debug"]
        (Just "debug")
      -- flag "watch-folder" ["watch", "live", "f"]
        -- (Just "watch templates and re-run jenny on change")

    setup :: YargsSetup
    setup = usage   "$0 -t Word1 -d"
         <> example "$0 -t Hello -t World" "Jenny code generator"
