{-# LANGUAGE Arrows #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE RecordWildCards #-}
module SMSAPI.Parse
  ( getResult
  , parseResult
  ) where

import Control.Monad.Reader
import Text.XML.HXT.Core
import SMSAPI.Types

atTag tag = deep (isElem >>> hasName tag)
text = getChildren >>> getText
textAtTag tag = text <<< atTag tag

parseResult = atTag "result" >>>
  proc r -> do

    errCode  <- textAtTag "err" >>> arr (toEnum . read) -< r
    credit   <- textAtTag "credit" >>> arr read -< r
    userID   <- (textAtTag "user_id" >>> arr read) `orElse` (constA Nothing) -< r
    price    <- (textAtTag "price" >>> arr (Just . read)) `orElse` (constA Nothing) -< r
    smsID    <- (textAtTag "sms_id" >>> arr (Just . read)) `orElse` (constA Nothing) -< r
    smsCount <- (textAtTag "sms_count" >>> arr (Just . read)) `orElse` (constA Nothing) -< r

    returnA -< Result {..}

getResult :: MonadIO m => String -> m Result
getResult response = do
  parsed <- liftIO $ runX (readString [] response >>> parseResult)
  case parsed of
    []  -> do
      liftIO $ do
        putStrLn "Invalid response received: "
        putStrLn response
      error "Unable to parse result XML"
    [x] -> do
      return x
    _   -> error "Multiple results, can't happen!"
