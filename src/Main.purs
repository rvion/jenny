module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Foldable (for_)
import Node.Buffer (BUFFER)
import Node.FS (FS)
import Option (getOpts)
import Run (applyTemplate)
import Watch (watch)

main :: forall eff. M eff Unit
main = do
  opts <- getOpts
  if opts.templates == []
    then log "no templates given, exiting."
    else do
      -- log "ok"
      if opts.watch
        then do
          log "foo"
          watch
            "/Users/rvion/dev/jenny/examples/db"
            "*.jenny"
            (\fs -> for_ fs \f -> do
              log ("/Users/rvion/dev/jenny/examples/db" <> "/" <> f.name)
              applyTemplate
                opts.debug
                { templatePath: "/Users/rvion/dev/jenny/examples/db" <> "/" <> f.name
                , prefixPath: opts.prefixPath})
        else
          for_ opts.templates \templatePath ->
            applyTemplate opts.debug {templatePath, prefixPath: opts.prefixPath}

type M eff a = Eff
  ( buffer :: BUFFER
  , err :: EXCEPTION
  , fs :: FS
  , console :: CONSOLE
  | eff
  ) a
