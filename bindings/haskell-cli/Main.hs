module Main (main) where

import Eclaire (clayCommit, irVersion)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["version"] -> do
      version <- irVersion
      putStrLn $ "Eclaire " ++ packageVersion ++ " (IR " ++ show version ++ ", Clay " ++ clayCommit ++ ")"
    ["--version"] -> mainVersion
    ["--help"] -> putStrLn "Usage: eclaire version | --version | --help"
    [] -> mainVersion
    _ -> putStrLn "Usage: eclaire version | --version | --help"
  where
    packageVersion = "0.1.4"
    mainVersion = putStrLn $ "Eclaire " ++ packageVersion ++ " (Clay " ++ clayCommit ++ ")"
