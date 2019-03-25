{-# LANGUAGE OverloadedStrings #-}
module SMSAPI.Config (apiCfg) where

import System.Directory
import System.FilePath.Posix
import System.Exit (exitFailure)
import qualified Data.Text.IO as TIO

import SMSAPI.Types

import Data.Ini.Config

iniParser :: IniParser APICfg
iniParser = section "api" $ APICfg <$> field "user" <*> field "password"

parseAPICfg :: FilePath -> IO (Either String APICfg)
parseAPICfg fpath = do
    rs <- TIO.readFile fpath
    return $ parseIniFile rs iniParser

apiCfg :: IO APICfg
apiCfg = do
  hom <- getHomeDirectory
  let homPth = hom </> ".smsgwapi.conf"
  tst <- doesFileExist homPth
  case tst of
    False -> putStrLn "No config found, please create ~/.smsgwapi.conf" >> exitFailure
    True -> do
      res <- parseAPICfg homPth
      case res of
       Left err -> putStrLn ("Unable to parse config: " ++ err) >> exitFailure
       Right cfg -> return cfg
