module Run where

import Prelude
import Data.Array as Array
import Control.Alternative (liftA1)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log, logShow)
import Data.Array (cons, foldM, foldl, head, reverse, snoc, takeWhile, uncons)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), drop, indexOf, joinWith, length, split, trim)
import Data.Tuple (Tuple(..))
import Node.FS.Sync (exists)
import Node.Path (FilePath, dirname)
import Partial.Unsafe (unsafeCrashWith)
import Template (dot)
import Util (getFile, putFile)

foreign import unsafeToJs :: forall a. String -> a
-- app :: forall eff. Options -> M eff Unit
-- app {templates, debug} =

      -- pure tuni

applyTemplate :: Boolean -> String -> Eff _ Unit
applyTemplate debug templatePath = do
  input <- getFile templatePath
  -- context <- getFile dbPath
  let out = dot.compile input (unsafeToJs "{}")
  -- when debug $ log out
  targets <- buildTargets templatePath out
  -- when debug $ logShow (Array.length targets)
  for_ targets \t -> do
    let targetPath = dirname templatePath <> "/" <> t.filepath
    when debug $ log ("writing target " <> targetPath )
    putFile targetPath t.content
  pure unit

type Target = {filepath :: String, content:: String}

type State = {
  currentContent :: Array String,
  currentPath :: Maybe FilePath,
  targets :: Array Target,
  holes :: Array (Tuple String String)
}

buildTargets :: FilePath -> String -> Eff _ (Array Target)
buildTargets templatePath str =
  foldM
    dispatchLine
    initialState
    (lines str)
  # liftA1 finish
  where
    initialState :: State
    initialState = {
      currentContent: [],
      currentPath: Nothing,
      targets: [],
      holes: [] -- Array (Tuple String String)
    }

    finish :: _ -> Array Target
    finish {currentContent, currentPath, targets} =
      case Array.length currentContent > 0, currentPath of
        true, Just path -> snoc targets {
          filepath: path,
          content: unlines currentContent
        }
        _, _ -> targets
        -- FIXME crash when no out file specified

    dispatchLine :: State -> String -> Eff _ State
    dispatchLine state line =
      case words (trim line) of
        [ comment, "%%", "HOLE", holename] -> do
          case (state.currentPath) of
            Nothing -> unsafeCrashWith "hole out of file"
            Just f' -> do
              let f = dirname templatePath <> "/" <> f' 
              fExists <- exists f
              logShow (Tuple f fExists)
              if fExists
                then do
                  holeContent <- getHole holename <$> getFile f
                  pure $ state {
                      currentContent = state.currentContent <>
                        [ unwords [comment, "HOLE", holename, "START"]
                        , holeContent
                        , unwords [comment, "HOLE", holename, "END"]
                        ]
                    }
                else pure $ state {
                    currentContent = state.currentContent <>
                      [ unwords [comment, "HOLE", holename, "START"]
                      , ""
                      , unwords [comment, "HOLE", holename, "END"]
                      ]
                  }

        ["%%", "FILE", filename] -> pure $
          state {
            currentContent = [],
            currentPath = Just filename,
            targets = case state.currentPath of
              Nothing -> state.targets
              Just currentPath -> snoc state.targets {
                filepath: currentPath,
                content: unlines state.currentContent
              }
          }
        _ -> pure $
          state {
            currentContent = snoc state.currentContent line
          }

------- CORE

getHole :: String -> String -> String
getHole holeName file = go (lines file)
  where
    go ls = case uncons ls of
      Just {head, tail} -> case words head of
        [comment, "HOLE", x, "START"] ->
          if x == holeName
          then tail
            # takeWhile (\ l -> case words l of
                [_, "HOLE", _, "END" ] -> false
                _ -> true)
            # unlines
          else go tail
        _ -> go tail
      Nothing -> ""
------- HELPERS

lines :: String -> Array String
lines = split (Pattern "\n")

words :: String -> Array String
words = split (Pattern " ")

-- IDEA CR vs CR LF
unlines :: Array String -> String
unlines = joinWith "\n"

unwords :: Array String -> String
unwords = joinWith " "
