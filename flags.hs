module Flags(
    getFlags,
    isSet,
    getFlagArg
            )
    where

import Data.Map as Map
import Data.Maybe

type Flag = String
type FlagArg = String
type FlagList = Map Flag (Maybe FlagArg)

getFlags :: [String] -> FlagList
getFlags = fromList . Prelude.map (\flag -> (parseFlag flag, if getFlagArg flag == []
                                   then Nothing
                                   else Just (getFlagArg flag)
                         )
               ) .
        Prelude.filter isFlag
    where
        isFlag ('-':rest) = True
        isFlag _ = False
        parseFlag = takeWhile (/='=') . dropWhile (=='-')
        getFlagArg = drop 1 . dropWhile (/='=')

isSet :: Flag -> FlagList -> Bool
isSet f fs
  | isNothing (Map.lookup f fs) = False
  | otherwise = True

-- | Get argument for first occurence of given flag.
getFlagArgSafe :: Flag -> FlagList -> Maybe FlagArg
getFlagArgSafe f fs | isSet f fs =  fromJust $ Map.lookup f fs
                | otherwise = Nothing

getFlagArg :: Flag -> FlagList -> FlagArg
getFlagArg f fs = fromJust $ getFlagArgSafe f fs
