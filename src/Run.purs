module Run where

import Prelude
import Data.Array as Array
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log, logShow)
import Data.Array (foldM, snoc, takeWhile, uncons)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(Pattern), joinWith, split, trim)
import Data.Tuple (Tuple(..))
import Diff (showDiff)
import Node.FS.Sync (exists)
import Node.Path (FilePath, dirname)
import Partial.Unsafe (unsafeCrashWith)
import Template (dot)
import Util (getFile, putFile)

foreign import unsafeToJs :: forall a. String -> a
-- app :: forall eff. Options -> M eff Unit
-- app {templates, debug} =

      -- pure tuni
type OptionsP2 = {
  templatePath :: String,
  prefixPath :: String
}
applyTemplate :: Boolean -> OptionsP2 -> Eff _ Unit
applyTemplate debug opts = do
  fExists <- exists opts.templatePath
  if fExists
    then do
      input <- getFile opts.templatePath
      -- context <- getFile dbPath
      let out = dot.compile input (unsafeToJs "{}")
      when debug $ log "-----------------------------"
      -- when debug $ log out
      targets <- buildTargets opts out
      -- when debug $ logShow (Array.length targets)
      for_ targets \t -> do
        let targetPath = t.filepath
        goo <- getFile targetPath
        when debug $ log ("writing target " <> targetPath )
        showDiff goo t.content 
        putFile targetPath t.content
      pure unit
    else do
      log "file does not exist"

type Target = {filepath :: String, content:: String}

type State = {
  currentContent :: Array String,
  currentPath :: Maybe FilePath,
  targets :: Array Target,
  holes :: Array (Tuple String String)
}

-- TODO refactor this function to have less args
buildTargets :: OptionsP2 -> String -> Eff _ (Array Target)
buildTargets opts str =
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
      holes: []
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
            Just f -> do
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
            currentPath = Just (finalPathFor opts filename),
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

finalPathFor :: OptionsP2 -> FilePath -> FilePath
finalPathFor opts fp =
  if opts.prefixPath == ""
    then dirname opts.templatePath <> "/" <> fp
    else dirname opts.templatePath <> "/" <> opts.prefixPath <> "/" <> fp


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
