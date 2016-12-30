module Option where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Node.Yargs.Applicative (Y, flag, runY, yarg)
import Node.Yargs.Setup (YargsSetup, defaultHelp, defaultVersion, example, usage)

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
        (Just "generate given template file\n[you can pass several --template opts]")
        (Left [])
        false
      <*> yarg "watch-folder" ["w"]
        (Just "watch *.jenny templates in folder\n[you can specify several folder to watch]")
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
    setup = usage   "Jenny: the programmer assistant"
         <> example
              "jenny --template=./foo/demo.jenny --prefix=bar --debug"
              "# gen ./foo/demo.jenny in ./foo/bar/ folder "
         <> example
              "jenny --watch $(pwd)/examples/db/ --debug"
              "# watch all *.jenny files in "
         <> defaultHelp -- add --help
         <> defaultVersion -- add --version
