import System.Environment(getArgs)

type Password = String

errorTooManyArgs = "Masterpass takes one argument, which is a file of words.\n\
    \If no argument is given, /usr/share/dictionary/words is used."

ne = error "Not implemented"

-- The standard dictionary.
-- TODO: Make the path returned be OS dependent. Current implementation is
-- OSX only.
standardWords :: IO FilePath
standardWords = return "/usr/share/dictionary/words"

main = do
    args <- getArgs
    case length args of
      0 -> do standardFile <- standardWords
              printPassword standardFile
      1 -> printPassword (head args)
      2 -> putStrLn errorTooManyArgs

printPassword :: FilePath -> IO ()
printPassword wordsFile = do
    password <- generatePassword wordsFile
    putStrLn password

generatePassword :: FilePath -> IO Password
generatePassword = ne
