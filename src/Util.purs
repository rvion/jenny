module Util where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Node.Buffer (BUFFER, toString)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readFile)

type ReadFileEffets eff =
  ( buffer :: BUFFER
  , fs :: FS
  , err :: EXCEPTION
  | eff
  )

getFile :: forall eff.
  String -> Eff (ReadFileEffets eff) String
getFile str = do
  buf <- readFile str
  toString UTF8 buf
