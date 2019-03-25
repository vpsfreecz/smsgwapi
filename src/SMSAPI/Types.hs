module SMSAPI.Types
  ( Error(..)
  , Result(..)
  , APICfg(..)
  ) where

import Data.Text (Text)

data Error =
    Ok
  | UnknownError
  | LoginInvalid
  | PasswordOrHashMismatch
  | TimeDeviationTooLarge
  | IPNotAllowed
  | UnknownAction
  | SaltReused
  | NoDBConnection
  | NotEnoughMinerals
  | InvalidRecipientNumber
  | EmptyMessage
  | MessageTooLong -- more than 459 chars
  deriving (Eq, Ord, Enum, Show)

data Result = Result
  { errCode :: Error
  , credit :: Float
  , userID :: Maybe Integer
  , price :: Maybe Float
  , smsID :: Maybe Integer
  , smsCount :: Maybe Integer
  } deriving (Eq, Ord, Show)

data APICfg = APICfg
  { user :: Text
  , pass :: Text
  }
