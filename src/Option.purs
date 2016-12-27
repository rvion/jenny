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
  prefixPath :: String,
  debug :: Boolean,
  watch :: Boolean
}

getOpts :: forall eff. Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options
getOpts = runY setup parser
  where
    parser :: Y (Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options)
    parser = (\templates  prefixPath  debug  watch ->
         pure {templates, prefixPath, debug, watch})
      <$> yarg "t" ["template"]
        (Just "template file")
        (Right "At least one template is required")
        false
      <*> yarg "p" ["prefix", "path"]
        (Just "local output path prefix")
        (Right "")
        false
      <*> flag "d" ["debug"]
        (Just "debug")
      <*> flag "w" ["watch", "live"]
        (Just "debug")

    setup :: YargsSetup
    setup = usage   "$0 -t Word1 -d"
         <> example "$0 -t Hello -t World" "Jenny code generator"
