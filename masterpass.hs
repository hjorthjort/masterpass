import Data.Char(intToDigit)
import Flags
import System.Directory(doesFileExist)
import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomR, randomRs)

type Password = String
data Config = Config {wordsFile :: FilePath,
                      nbrOfWords :: Int,
                      useSpecialChars :: Bool,
                      specialChars :: [Char],
                      useNumber :: Bool
                     }

-- Constants --
---------------

errorTooManyArgs = "Masterpass takes one argument, which is a file of words.\n\
    \If no argument is given, the program looks for a list of commonly used \
    \dictionary files"
errorNoFilename = "File flag takes a path as argument"
standardWordDicts = [
    "usr/dict/words",
    "/usr/share/dict/words",
    "/var/lib/dict/words"]
standardNrbOfWords = 3
standardSpecialChars = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
digits = map intToDigit [0..9]
flagUseSpecials = "use-specials"
flagSpecialsList = "s"
flagUseNumber = "s"

-- Set new functions equal to this to make them compile without working.
ne = error "Not implemented"

-- IO and impure --
-------------------

-- The standard dictionary.
-- TODO: Make the path returned be OS dependent. Current implementation is
-- OSX only.
standardWords :: IO FilePath
standardWords = standardWords' standardWordDicts
    where
        standardWords' dicts = do
            exists <- doesFileExist (head dicts)
            if exists
               then return $ head dicts
               else standardWords' (tail dicts)

main = do
    args <- getArgs
    let flags = getFlags args
    stdFile <- standardWords
    let config = Config {
        -- TODO: Allow using multiple files, e.g., for several languages.
        wordsFile = maybeFlags stdFile "f" flags,
        nbrOfWords = read $ maybeFlags (show standardNrbOfWords) "w" flags,
        useSpecialChars = isSet flagUseSpecials flags
                          || isSet flagSpecialsList flags,
        specialChars = maybeFlags standardSpecialChars flagSpecialsList flags,
        useNumber = isSet "n" flags
    }
    printPassword config

printPassword :: Config -> IO ()
printPassword c = do
    password <- generateRandomPass c
    putStrLn password

generateRandomPass :: Config -> IO Password
generateRandomPass c = do
    wordsString <- readFile (wordsFile c)
    -- We use 3 different random numbers gens: for picking words, for picking
    -- inserting special characters and for inserting numbers.
    rands <- sequence $ take 3 $ [ newStdGen | x <- [1..] ]
    let words = lines wordsString
        password = getRandomWords (nbrOfWords c) words (rands !! 0)
        password' =
            if useSpecialChars c
               then randomInsertChar (specialChars c) password (rands !! 1)
               else password
        password'' =
            if useNumber c
               then randomInsertChar digits password' (rands !! 2)
               else password'
    return password''

-- Pure --
----------

-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: [a] -> StdGen -> [a]
pickRandoms list g = [ list !! x | x <- randomRs (0, length list - 1) g ]

-- Construct a password of random words from the word list.
getRandomWords :: Int -> [String] -> StdGen -> Password
getRandomWords numberOfWords words = concat . take numberOfWords . pickRandoms words

-- Inserts a character from a list in a random place into a password.
randomInsertChar :: [Char] -> Password -> StdGen -> Password
randomInsertChar specials pass g = take r1 pass ++ (specials !! r2:drop r1 pass)
    where
        (r1, g') = randomR (0, length pass - 1) g
        (r2, _) = randomR (0, length specials - 1) g'
