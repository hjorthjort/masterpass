import Data.Char(intToDigit, isAlpha, isUpper, toUpper)
import Data.Maybe(isNothing)
import Data.List.Split(splitOn)
import Data.List(intersperse)
import Flags
import System.Directory(getCurrentDirectory, doesFileExist, canonicalizePath)
import System.Environment(getArgs)
import System.Random(StdGen, newStdGen, randomR, randomRs)

type Password = String
data Config = Config {wordsFiles :: [FilePath],
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
standardWordDicts =  "dict/english (american),dict/swedish,dict/german_de_de"
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
          currentDir <- getCurrentDirectory
          let flags = parseFlags args
          let config = makeConfig flags currentDir
          printPassword config

printPassword :: Config -> IO ()
printPassword c = do
    password <- generateRandomPass c
    putStrLn password

-- Get content of several files, with newline inbetween
cat :: [FilePath] -> IO String
cat files = fmap concat (sequence (map readFile files))

generateRandomPass :: Config -> IO Password
generateRandomPass c = do
    -- Mash all provided files together.
    wordsString <- cat (wordsFiles c)
    -- We use 3 different random numbers gens: for picking words, for picking
    -- inserting special characters and for inserting numbers.
    rands <- sequence $ take 4 $ [ newStdGen | x <- [1..] ]
    let candidateWords = lines wordsString
        words = getRandomWords (nbrOfWords c) (rands !! 0) candidateWords
        modifiedWords =
            if useUpperCase c
               then randomMakeUpperCase words (rands !! 1)
               else words
        modifiedWords' =
            if useSpecialChars c
               then randomInsertChar (specialChars c) modifiedWords (rands !! 2)
               else modifiedWords
        modifiedWords'' =
            if useNumber c
               then randomInsertChar digits modifiedWords' (rands !! 3)
               else modifiedWords'
    return $ concat $ intersperse " " modifiedWords''

-- Pure --
----------

makeConfig flags currentDir =
    Config {
       wordsFiles = splitOn "," (maybeFlags (currentDir ++ "/" ++ standardWordDicts) "f" flags),
       nbrOfWords = read $ maybeFlags (show standardNrbOfWords) "w" flags,
       useSpecialChars = isSet flagUseSpecials flags
                         || isSet flagSpecialsList flags,
                         specialChars = maybeFlags standardSpecialChars flagSpecialsList flags,
       useNumber = isSet flagUseNumber flags,
       useUpperCase = isSet flagUseUpperCase  flags
           }



-- Return an infinite list of  elements randomly picked from input list.
pickRandoms :: StdGen -> [a] -> [a]
pickRandoms g list = [ list !! x | x <- randomRs (0, length list - 1) g ]

-- Construct a password of random words from the word list.
getRandomWords :: Int -> StdGen -> [String] -> [String]
getRandomWords numberOfWords g = take numberOfWords . pickRandoms g

-- Inserts a character from a list in a random place into a password.
randomInsertChar :: [Char] -> [String] -> StdGen -> [String]
randomInsertChar specials words g = replace r1 newWord words
    where
        (r1, g') = randomR (0, length words - 1) g
        word = words !! r1
        (r2, g'') = randomR (0, length specials - 1) g'
        special = specials !! r2
        (r3, _) = randomR (0, length (words !! r1) - 1) g
        newWord = insert r3 special word

-- TODO: Bug in here, words get repeated
randomMakeUpperCase :: [String] -> StdGen -> [String]
randomMakeUpperCase words g = replace r1 newWord words
    where
        (r1, g') = randomR (0, length words - 1) g
        word = words !! r1
        (r2, _) = randomR (0, length (words !! r1) - 1) g
        newWord = replace r2 (toUpper $ word !! r2) word

insert :: Int -> a -> [a] -> [a]
insert pos elem list = take pos list ++ (elem:drop pos list)

replace :: Int -> a -> [a] -> [a]
replace pos elem list = take pos list ++ (elem:drop (pos+1)  list)
