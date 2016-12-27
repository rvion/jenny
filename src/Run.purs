module Run where

import Prelude
import Data.Array as Array
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log, logShow)
import Data.Array (cons, foldl, head, reverse, snoc)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), drop, indexOf, joinWith, length, split, trim)
import Node.Path (dirname)
import Partial.Unsafe (unsafeCrashWith)
import Template (dot)
import Util (getFile, putFile)

foreign import unsafeToJs :: forall a. String -> a
-- app :: forall eff. Options -> M eff Unit
-- app {templates, debug} =

      -- pure tuni

applyTemplate :: Boolean -> String -> Eff _ Unit
applyTemplate debug template = do
  input <- getFile template
  -- context <- getFile dbPath
  let out = dot.compile input (unsafeToJs "{}")
  -- when debug $ log out
  let targets = buildTargets out
  -- when debug $ logShow (Array.length targets)
  for_ targets \t -> do
    let targetPath = dirname template <> "/" <> t.filepath
    when debug $ log ("writing target " <> targetPath )
    putFile targetPath t.content
  pure unit

type Target = {filepath :: String, content:: String}

buildTargets :: String -> Array Target
buildTargets str =
  foldl
    dispatchLine
    {currentContent: [], currentPath: Nothing, targets: []}
    (split (Pattern "\n") str)
  # finish
  where
    finish :: _ -> Array Target
    finish {currentContent, currentPath, targets} =
      case Array.length currentContent > 0, currentPath of
        true, Just path -> snoc targets {
          filepath: path,
          content: joinWith "\n" currentContent
        }
        _, _ -> targets
        -- FIXME crash when no out file specified

    dispatchLine state l =
      case indexOf (Pattern "FILE") (trim l) of
        Nothing -> state {
          currentContent = snoc state.currentContent l
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
            currentContent = [],
            currentPath = Just filename,
            targets = case state.currentPath of
              Nothing -> state.targets
              Just currentPath -> snoc state.targets {
                filepath: currentPath,
                content: joinWith "\n" state.currentContent
              }
          }
