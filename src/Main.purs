module Main where

import Prelude
import Text.Handlebars (compile)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log)
import Util (getFile)

main :: Eff _ Unit
main = do
  log "ok"
  input <- getFile "test/test1.jenny"
  compile input {
    title: "foo",
    body: "bar"
  } # log
  pure unit
