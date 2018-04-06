-- | Simple module for handling command line flags, where each flag starts
-- | with an arbitrary number of hyphens, followed by a word, and optionally an
-- | equals sign and an argument.
-- | Example: -a, --add, --file=myfile.txt
module Flags(
    getFlags,
    isSet,
    getFlagArg,
    maybeFlags
            )
    where

import Data.Map as Map (Map, fromList, lookup)
import Data.Maybe

-- | A flag, such as -f or --no-edit
type Flag = String
type FlagArg = String
type FlagList = Map Flag (Maybe FlagArg)

-- | Takes a list of command line arguments and converts them to a dictionery of
-- | flags and their values.
getFlags :: [String] -> FlagList
getFlags = fromList . map (\flag -> (parseFlag flag, if getFlagArg flag == []
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

-- | Checks wether a flag exists in a given flag dictionary.
isSet :: Flag -> FlagList -> Bool
isSet f fs
  | isNothing (Map.lookup f fs) = False
  | otherwise = True

-- | Get argument for first occurence of given flag.
getFlagArgSafe :: Flag -> FlagList -> Maybe FlagArg
getFlagArgSafe f fs | isSet f fs =  fromJust $ Map.lookup f fs
                | otherwise = Nothing

-- | Get the argument for a flag. Will crash if the flag doesn't exist.
getFlagArg :: Flag -> FlagList -> FlagArg
getFlagArg f fs = fromJust $ getFlagArgSafe f fs

-- | If the requested flag exists, returns its argument, otherwise the
-- | fallback value.
maybeFlags :: FlagArg -> Flag -> FlagList -> FlagArg
maybeFlags fallback flag flags = if isSet flag flags
                                    then getFlagArg flag flags
                                    else fallback
