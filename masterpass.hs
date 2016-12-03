import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomRs)
import Flags

type Password = String
data Config = Config {wordsFile :: FilePath, 
                      nbrOfWords :: Int
                     }

-- Constants --
---------------

errorTooManyArgs = "Masterpass takes one argument, which is a file of words.\n\
    \If no argument is given, " ++ macStandardWords ++ "is used."
errorNoFilename = "File flag takes a path as argument"
macStandardWords = "/usr/share/dict/words"
standardNrbOfWords = 3

-- Set new functions equal to this to make them compile without working.
ne = error "Not implemented"

-- IO and impure --
-------------------

-- The standard dictionary.
-- TODO: Make the path returned be OS dependent. Current implementation is
-- OSX only.
standardWords :: IO FilePath
standardWords = return macStandardWords

main = do
    args <- getArgs
    let flags = getFlags args
    stdFile <- standardWords
    let wordsFile = maybeFlags stdFile "f" flags
        -- |read| is to convert the return value to an integer.
        nbrOfWords = read $ maybeFlags (show standardNrbOfWords) "w" flags
        config = Config{wordsFile = wordsFile, nbrOfWords = nbrOfWords}
    printPassword config

printPassword :: Config -> IO ()
printPassword c = do
    password <- generateRandomPass c
    putStrLn password

generateRandomPass :: Config -> IO Password
generateRandomPass c = do
    wordsString <- readFile (wordsFile c)
    rand1 <- newStdGen
    let words = lines wordsString
        password = getRandomWords (nbrOfWords c) words rand1
    return password

-- Pure --
----------

-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: [a] -> StdGen -> [a]
pickRandoms list g = [ list !! x | x <- randomRs (0, length list - 1) g ]

-- Construct a password of random words from the word list.
getRandomWords :: Int -> [String] -> StdGen -> Password
getRandomWords numberOfWords words = concat . take numberOfWords . pickRandoms words
