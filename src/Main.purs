module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array (length)
import Data.Foldable (for_)
import Node.Buffer (BUFFER)
import Node.FS (FS)
import Option (getOpts)
import Run (applyTemplate)
import Watch (newWatchClient, watch)

main :: forall eff. M eff Unit
main = do
  opts <- getOpts

  when opts.debug $
    log "[jenny] debug on"

  when (length opts.templates > 0) do
    for_ opts.templates \templatePath -> do
      log ("[jenny] generating " <> templatePath)
      applyTemplate opts.debug {templatePath, prefixPath: opts.prefixPath}

  when (length opts.watch > 0) do
    client <- newWatchClient
    for_ opts.watch \folderPath -> do
      log ("[jenny] watching *.jenny in " <> folderPath)
      watch client folderPath "*.jenny"
        (\fs -> for_ fs \f -> do
          let watchedTemplatePath = folderPath <> "/" <> f.name
          log watchedTemplatePath
          applyTemplate
            opts.debug
            { templatePath: watchedTemplatePath
            , prefixPath: opts.prefixPath})

type M eff a = Eff
  ( buffer :: BUFFER
  , err :: EXCEPTION
  , fs :: FS
  , console :: CONSOLE
  | eff
  ) a
