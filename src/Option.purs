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
  dbPath :: String,
  debug :: Boolean
}

getOpts :: forall eff. Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options
getOpts = runY setup parser
  where
    parser :: Y (Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options)
    parser = (\templates dbPath debug -> pure {templates,dbPath,debug})
      <$> yarg "w" ["word"]
        (Just "A word")
        (Right "At least one word is required")
        false
      <*> yarg "d" ["dbPath"]
        (Just "A word")
        (Left "db/test.dump.json")
        false
      <*> flag "d" []
        (Just "debug")

    setup :: YargsSetup
    setup = usage   "$0 -w Word1 -w Word2"
         <> example "$0 -w Hello -w World" "Say hello!"
