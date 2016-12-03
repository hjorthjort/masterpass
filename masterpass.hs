import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomRs)
import Flags

type Password = String

errorTooManyArgs = "Masterpass takes one argument, which is a file of words.\n\
    \If no argument is given, " ++ macStandardWords ++ "is used."
errorNoFilename = "File flag takes a path as argument"

ne = error "Not implemented"

-- IO and impure --
-------------------

macStandardWords = "/usr/share/dict/words"
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
    printPassword file

printPassword :: FilePath -> IO ()
printPassword wordsFile = do
    password <- generateRandomPass wordsFile
    putStrLn password

generateRandomPass :: FilePath -> IO Password
generateRandomPass wordsFile = do
    wordsString <- readFile wordsFile
    let words = lines wordsString
    rand <- newStdGen
    return $ constructPassword words rand

-- Pure --
----------

numberOfWords :: Int
numberOfWords = 3

-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: [a] -> StdGen -> [a]
pickRandoms list g = [ list !! x | x <- randomRs (0, length list) g ]

-- Construct a password of random words from the word list.
constructPassword :: [String] -> StdGen -> Password
constructPassword words = concat . take numberOfWords . pickRandoms words
