import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomRs)
import Flags

type Password = String

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
    let file = maybeFlags stdFile "f" flags
        nbrOfWords = read $ maybeFlags (show standardNrbOfWords) "w" flags
    -- TODO: Pass a config struct instead of a bunch of parameters.
    printPassword file nbrOfWords

printPassword :: FilePath -> Int -> IO ()
printPassword wordsFile nbrOfWords = do
    password <- generateRandomPass wordsFile nbrOfWords
    putStrLn password

generateRandomPass :: FilePath -> Int -> IO Password
generateRandomPass wordsFile nbrOfWords = do
    wordsString <- readFile wordsFile
    let words = lines wordsString
    rand <- newStdGen
    return $ constructPassword nbrOfWords words rand

-- Pure --
----------

-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: [a] -> StdGen -> [a]
pickRandoms list g = [ list !! x | x <- randomRs (0, length list - 1) g ]

-- Construct a password of random words from the word list.
constructPassword :: Int -> [String] -> StdGen -> Password
constructPassword numberOfWords words = concat . take numberOfWords . pickRandoms words
