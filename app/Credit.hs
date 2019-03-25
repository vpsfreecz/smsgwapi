module Main where

import SMSAPI

main = do
  x <- runSMS $ do
    creditInfo

  print x
