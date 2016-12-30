module Util where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Maybe (Maybe(..))
import Node.Buffer (BUFFER, fromString, toString)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (exists, readFile, writeFile)
import Node.Path (FilePath)

type FileEffets eff =
  ( buffer :: BUFFER
  , fs :: FS
  , err :: EXCEPTION
  | eff
  )

getFile :: forall eff.
  FilePath -> Eff (FileEffets eff) (Maybe String)
getFile fp = do
  exst <- exists fp
  if exst
    then do
      buf <- readFile fp
      Just <$> toString UTF8 buf
    else pure Nothing

putFile :: forall eff.
  String -> String -> Eff (FileEffets eff) Unit
putFile filepath str = do
  buffer <- fromString str UTF8
  writeFile filepath buffer
