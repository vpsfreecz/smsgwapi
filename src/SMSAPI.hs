{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module SMSAPI
  ( runSMS
  , creditInfo
  , sendMessage
  , Error(..)
  , Result(..)) where

import Control.Lens
import Control.Monad
import Control.Monad.Reader

import Data.Char (chr)
import Data.Time.Format
import Data.Time.LocalTime

import System.Random
import Crypto.Hash             (hashWith, MD5 (..))
import Data.ByteArray.Encoding (convertToBase, Base (Base16))

import Network.Wreq

import qualified Data.Text as T
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as BSL

import SMSAPI.Config
import SMSAPI.Parse
import SMSAPI.Types

apiURL :: String
apiURL = "https://api.smsbrana.cz/smsconnect/http.php"

type SMSMonad a = ReaderT APICfg IO a

runSMS :: SMSMonad a -> IO a
runSMS m = do
  cfg <- apiCfg
  flip runReaderT cfg m

loginParams :: SMSMonad Options
loginParams = do
  APICfg { .. } <- ask
  t <- liftIO $ getZonedTime
  salt <- liftIO $ replicateM 33 $ randomASCII

  let ft = formatTime defaultTimeLocale "%Y%m%dT%H%M%S" t
      authHash = convertToBase Base16 $ hashWith MD5 (BS.pack $ (T.unpack pass) ++ ft ++ salt)

  return $ defaults & param "login" .~ [ user ]
                    & param "time"  .~ [ T.pack ft ]
                    & param "salt"  .~ [ T.pack $ salt ]
                    & param "hash"  .~ [ T.pack . BS.unpack $ authHash ]
  where
    randomASCII :: IO Char
    randomASCII = getStdRandom $ randomR (chr 48, chr 122)

creditInfo :: SMSMonad Float
creditInfo = do
  lp <- loginParams
  let opts = lp & param "action" .~ [ "credit_info" ]
  Result{..} <- performRequest opts
  return credit

sendMessage :: T.Text -> T.Text -> SMSMonad Result
sendMessage number message = do
  lp <- loginParams
  let opts = lp & param "action" .~ [ "send_sms" ]
                & param "number" .~ [ number ]
                & param "message" .~ [ message ]
  performRequest opts

performRequest :: MonadIO m => Options -> m Result
performRequest opts = do
  r <- liftIO $ getWith opts apiURL
  case r ^. responseStatus . statusCode of
    200 -> getResult $ BS.unpack . BSL.toStrict $ r ^. responseBody
    _   -> error "Got non-200 response code"
