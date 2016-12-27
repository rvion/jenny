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

main :: forall eff. M eff Unit
main = do
  {templates, debug, prefixPath} <- getOpts
  if templates == []
    then log "no templates given, exiting."
    else do
      log "ok"
      for_ templates \templatePath ->
        applyTemplate debug {templatePath,prefixPath}

type M eff a = Eff
  ( buffer :: BUFFER
  , err :: EXCEPTION
  , fs :: FS
  , console :: CONSOLE
  | eff
  ) a
