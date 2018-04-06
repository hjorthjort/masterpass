import Data.Char(intToDigit, isAlpha, isUpper, toUpper)
import Data.Maybe(isNothing)
import Flags
import System.Directory(doesFileExist, canonicalizePath)
import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomR, randomRs)

type Password = String
data Config = Config {wordsFile :: FilePath,
                      nbrOfWords :: Int,
                      useSpecialChars :: Bool,
                      specialChars :: [Char],
                      useNumber :: Bool,
                      useUpperCase :: Bool
                     }

-- Constants --
---------------

errorTooManyArgs = "Masterpass takes one argument, which is a file of words.\n\
    \If no argument is given, the program looks for a list of commonly used \
    \dictionary files"
errorNoFilename = "File flag takes a path as argument"
-- TODO: Look in more places, to accomodate Windows. Current implementation is
-- only for Unix systems. 
standardWordDicts = [
    "usr/dict/words",
    "/usr/share/dict/words",
    "/var/lib/dict/words"]
standardNrbOfWords = 3
standardSpecialChars = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
digits = map intToDigit [0..9]
flagUseSpecials = "use-specials"
flagSpecialsList = "s"
flagUseNumber = "n"
flagUseUpperCase = "u"

-- Set new functions equal to this to make them compile without working.
ne = error "Not implemented"

-- IO and impure --
-------------------
main = do args <- getArgs
          let flags = parseFlags args
          let config = makeConfig flags
          printPassword config


-- The standard dictionary.
standardWords :: IO (Maybe FilePath)
standardWords = standardWords' standardWordDicts
    where
      standardWords' (f:fs) = do
            -- Look for standard dictionary files.
            filePath <- canonicalizePath f
            exists <- doesFileExist filePath
            if exists
               then return $ Just filePath
               else standardWords' fs
      standardWords' [] = return Nothing

makeConfig flags =
    Config {
       -- TODO: Allow using multiple files, e.g., for several languages.
       wordsFile = maybeFlags (head standardWordDicts) "f" flags,
       nbrOfWords = read $ maybeFlags (show standardNrbOfWords) "w" flags,
       useSpecialChars = isSet flagUseSpecials flags
                         || isSet flagSpecialsList flags,
                         specialChars = maybeFlags standardSpecialChars flagSpecialsList flags,
       useNumber = isSet flagUseNumber flags,
       useUpperCase = isSet flagUseUpperCase  flags
           }


printPassword :: Config -> IO ()
printPassword c = do
    password <- generateRandomPass c
    putStrLn password

generateRandomPass :: Config -> IO Password
generateRandomPass c = do
    wordsString <- readFile (wordsFile c)
    -- We use 3 different random numbers gens: for picking words, for picking
    -- inserting special characters and for inserting numbers.
    rands <- sequence $ take 4 $ [ newStdGen | x <- [1..] ]
    let words = lines wordsString
        password = getRandomWords (nbrOfWords c) (rands !! 0) words
        password' =
            if useUpperCase c
               then randomMakeUpperCase password (rands !! 1)
               else password
        password'' =
            if useSpecialChars c
               then randomInsertChar (specialChars c) password' (rands !! 2)
               else password'
        password''' =
            if useNumber c
               then randomInsertChar digits password'' (rands !! 3)
               else password''
    return password'''

-- Pure --
----------

-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: StdGen -> [a] -> [a]
pickRandoms g list = [ list !! x | x <- randomRs (0, length list - 1) g ]

-- Construct a password of random words from the word list.
getRandomWords :: Int -> StdGen -> [String] -> Password
getRandomWords numberOfWords g = concat . take numberOfWords . pickRandoms g

-- Inserts a character from a list in a random place into a password.
randomInsertChar :: [Char] -> Password -> StdGen -> Password
randomInsertChar specials pass g = insert r1 (specials !! r2) pass
    where
        (r1, g') = randomR (0, length pass - 1) g
        (r2, _) = randomR (0, length specials - 1) g'

randomMakeUpperCase :: Password -> StdGen -> Password
randomMakeUpperCase password g 
  | any isUpper password = password
  | otherwise = replace r1 (toUpper $ password !! r1) password
    where
        (r1, _) = randomR (0, length password - 1) g

insert :: Int -> a -> [a] -> [a]
insert pos elem list = take pos list ++ (elem:drop pos list)

replace :: Int -> a -> [a] -> [a]
replace pos elem list = take pos list ++ (elem:drop (pos+1)  list)
