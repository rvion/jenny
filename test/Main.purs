module Test.Main where

import Prelude
import Node.FS.Aff as FS
import Node.FS.Sync as Sync
import Test.Unit.Assert as Assert
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Data.Array (filterM)
import Data.Foldable (for_)
import Data.String (joinWith)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (exists, readdir)
import Node.FS.Stats (isDirectory)
import Run (applyTemplate, buildTargets, getHole)
import Test.Unit (suite, test)
import Test.Unit.Main (runTest)

main :: Eff _ Unit
main = do
    -- IDEA take a list of specific test test to run
    -- TODO add suite for inline change

    -- find all tests folders
    rootFiles <- Sync.readdir "test"
    folders <- filterM
        (\f -> isDirectory <$> Sync.stat ("test/" <> f))
        rootFiles

    runTest do
        suite "parsing works" do
            test "getHole" do
              Assert.equal
                (getHole "t" "// HOLE t START\n fodezd\nzeo\n// HOLE t END")
                (" fodezd\nzeo")
            test "targets" do
                let input = joinWith "\n"
                      [ "%% FILE ok.txt"
                      , "this is ok. {{= 3+3}}"
                      , "%% FILE ok2.txt"
                      , "this is ok. {{= 3+3}}"
                      , ""
                      , "%% FILE ok3.txt"
                      , "this is ok. {{= 3+2}}"]
                targets <- liftEff $ buildTargets {prefixPath: "out", templatePath: "demo"} input
                Assert.equal (targets # map (_.filepath))
                    [ "./out/ok.txt"
                    , "./out/ok2.txt"
                    , "./out/ok3.txt"
                    ]
                Assert.equal (targets # map (_.content))
                    [ "this is ok. {{= 3+3}}"
                    , "this is ok. {{= 3+3}}\n"
                    , "this is ok. {{= 3+2}}"
                    ]

        suite "generated code match" $
            for_ folders \folder -> test folder do

                  -- apply template
                  liftEff $ do
                    applyTemplate false ({
                      templatePath: jennyPath folder,
                      prefixPath: "out"
                      })
                    pure true

                  correctFolderExist <- exists (correctPath folder)
                  when correctFolderExist do
                    -- FIXME check recursively
                    files <- readdir (correctPath folder)
                    for_ files \file -> do
                        out <- FS.readTextFile UTF8 (outPath folder <> file)
                        correct <- FS.readTextFile UTF8 ((correctPath folder) <> file)
                        Assert.equal out correct

jennyPath :: String -> String
jennyPath folder = "test/" <> folder <> "/test.jenny"

correctPath :: String -> String
correctPath folder = "test/"<> folder <> "/correct/"

outPath :: String -> String
outPath folder = "test/"<> folder <> "/out/"
