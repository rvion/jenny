module Run where

import Prelude
import Data.Array as Array
import Data.String as String
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Exception (Error, try)
import Data.Array (foldM, snoc, takeWhile, uncons)
import Data.Either (Either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(Pattern), joinWith, split, trim)
import Data.Tuple (Tuple)
import Diff (showDiff)
import Node.Path (FilePath, dirname)
import Partial.Unsafe (unsafeCrashWith)
import Template (dot)
import Util (getFile, putFile)


type OptionsP2 = {
  templatePath :: String,
  prefixPath :: String
}
applyTemplate :: Boolean -> OptionsP2 -> Eff _ (Either Error Unit)
applyTemplate debug opts = try do
  mbInput <- getFile opts.templatePath
  case mbInput of
    Nothing -> log "[jenny] file does not exist"
    Just input -> do
      when debug $ log ("\n[debug] --------" <> opts.templatePath <> "----------")
      out <- dot.compile input (dirname opts.templatePath)
      targets <- buildTargets opts out
      when debug $ log (show (Array.length targets) <> " targets:")
      for_ targets \t -> do
        let targetPath = t.filepath
        when debug do
          log ("  - " <> targetPath )
          previousContent <- fromMaybe "" <$> (getFile targetPath)
          if (String.length previousContent < 1000 &&
              String.length t.content < 1000)
            then showDiff previousContent t.content
            else log "    | [file too large]"
        putFile targetPath t.content
      pure unit

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
              mbContent <- getFile f
              let holeContent = case mbContent of
                    Just content -> getHole holename content
                    Nothing -> ""
              pure $ state {
                  currentContent = state.currentContent <>
                    [ unwords [comment, "HOLE", holename, "START"]
                    , holeContent
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
