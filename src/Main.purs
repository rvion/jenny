module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array (cons, foldl, head)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), drop, indexOf, length, split, trim)
import Node.Buffer (BUFFER)
import Node.FS (FS)
import Node.Yargs.Applicative (Y, flag, runY, yarg)
import Node.Yargs.Setup (YargsSetup, example, usage)
import Partial.Unsafe (unsafeCrashWith)
import Text.Handlebars (compile)
import Util (getFile, putFile)

main :: forall eff. M eff Unit
main = do
  opts <- getOpts
  app opts

type Options = {
  templates :: Array String,
  debug :: Boolean
}

app :: forall eff. Options -> M eff Unit
app {templates, debug} =
  if templates == []
  then log "no templates given, exiting."
  else do
    for_ templates $ \template -> do
      input <- getFile template
      let out = compile input context
      -- when debug $ log out
      let targets = buildTargets out
      for_ targets \t -> do
        log ("writing target " <> t.filepath)
        putFile t.filepath t.content
      pure unit
      -- pure tuni

type Target = {filepath :: String, content:: String}

buildTargets :: String -> Array Target
buildTargets str =
  foldl
    dispatchLine
    {currentContent: "", currentPath: Nothing, targets: []}
    (split (Pattern "\n") str)
  # finish
  where
    finish :: _ -> Array Target
    finish {currentContent, currentPath, targets} =
      case length currentContent > 0, currentPath of
        true, Just path -> targets # cons {
          filepath: path,
          content: currentContent
        }
        _, _ -> targets

    dispatchLine state l =
      case indexOf (Pattern "FILE") (trim l) of
        Nothing -> state {
          currentContent = state.currentContent <> l <> "\n"
          -- IDEA CR vs CR LF
        }
        Just i -> case l
          # trim
          # drop 4 -- FIXME
          # trim
          # split (Pattern " ")
          # head of
          Nothing -> unsafeCrashWith "file badly specified"
          Just filename -> state {
            currentContent = "",
            currentPath = Just filename,
            targets = case state.currentPath of
              Nothing -> state.targets
              Just currentPath -> cons {
                filepath: currentPath,
                content: state.currentContent
              } state.targets
          }

context :: { title :: String
, body :: String
}
context = {
  title: "foo",
  body: "bar"
}
getOpts :: forall eff. Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options
getOpts = runY setup parser
  where
    parser :: Y (Eff ( err :: EXCEPTION , console :: CONSOLE | eff ) Options)
    parser = (\t d -> pure {templates:t, debug:d})
      <$> yarg "w" ["word"]
        (Just "A word")
        (Right "At least one word is required")
        false
      <*> flag "d" []
        (Just "debug")

    setup :: YargsSetup
    setup = usage   "$0 -w Word1 -w Word2"
         <> example "$0 -w Hello -w World" "Say hello!"


type M eff a = Eff
  ( buffer :: BUFFER
  , err :: EXCEPTION
  , fs :: FS
  , console :: CONSOLE
  | eff
  ) a
