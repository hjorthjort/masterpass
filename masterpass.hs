import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomR, randomRs)
import Flags

type Password = String
data Config = Config {wordsFile :: FilePath,
                      nbrOfWords :: Int,
                      useSpecialChars :: Bool,
                      specialChars :: [Char]
                     }

-- Constants --
---------------

errorTooManyArgs = "Masterpass takes one argument, which is a file of words.\n\
    \If no argument is given, " ++ macStandardWords ++ "is used."
errorNoFilename = "File flag takes a path as argument"
macStandardWords = "/usr/share/dict/words"
standardNrbOfWords = 3
standardSpecialChars = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
flagUseSpecials = "use-specials"
flagSpecialsList = "s"

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
    let config = Config { 
        -- TODO: Allow using multiple files, e.g., for several languages.
        wordsFile = maybeFlags stdFile "f" flags,
        nbrOfWords = read $ maybeFlags (show standardNrbOfWords) "w" flags,
        useSpecialChars = isSet flagUseSpecials flags 
                          || isSet flagSpecialsList flags,
        specialChars = maybeFlags standardSpecialChars flagSpecialsList flags
    }
    printPassword config

printPassword :: Config -> IO ()
printPassword c = do
    password <- generateRandomPass c
    putStrLn password

generateRandomPass :: Config -> IO Password
generateRandomPass c = do
    wordsString <- readFile (wordsFile c)
    rand1 <- newStdGen
    rand2 <- newStdGen
    let words = lines wordsString
        password = getRandomWords (nbrOfWords c) words rand1
    return $ if useSpecialChars c
                then putInSpecial (specialChars c) password rand2
                else password

-- Pure --
----------

-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: [a] -> StdGen -> [a]
pickRandoms list g = [ list !! x | x <- randomRs (0, length list - 1) g ]

-- Construct a password of random words from the word list.
getRandomWords :: Int -> [String] -> StdGen -> Password
getRandomWords numberOfWords words = concat . take numberOfWords . pickRandoms words

-- Inserts a special char in a random place into a password.
putInSpecial :: [Char] -> Password -> StdGen -> Password
putInSpecial specials pass g = take r1 pass ++ (specials !! r2:drop r1 pass)
    where
        (r1, g') = randomR (0, length pass - 1) g
        (r2, _) = randomR (0, length specials - 1) g'
