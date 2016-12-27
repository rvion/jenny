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
  debug :: Boolean
}

getOpts :: forall eff. Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options
getOpts = runY setup parser
  where
    parser :: Y (Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options)
    parser = (\templates debug -> pure {templates, debug})
      <$> yarg "w" ["word"]
        (Just "A word")
        (Right "At least one word is required")
        false
      <*> flag "d" []
        (Just "debug")

    setup :: YargsSetup
    setup = usage   "$0 -t Word1 -d"
         <> example "$0 -t Hello -t World" "Jenny code generator"
