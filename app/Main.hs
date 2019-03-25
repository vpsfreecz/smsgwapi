module Main where

import SMSAPI
import System.Environment
import qualified Data.Text as T

main = do
  args <- getArgs
  case args of
    [] -> error "Usage: smsgwsend NUMBER MESSAGE"
    [number, message] -> do
      result <- runSMS $ do
        sendMessage (T.pack number) (T.pack message)
      print result
    _ -> error "Too many arguments"

