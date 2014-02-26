import Control.Applicative

import System.IO
import System.Process
import System.Directory
import System.FilePath
import System.Exit
import System.Environment

import Data.List

getPackageDBFromConfig :: FilePath -> IO FilePath
getPackageDBFromConfig filename = do
    file <- readFile filename
    case filter ("package-db:" `isPrefixOf`) $ lines file of
        pdb:_ -> return . dropWhile (`elem` " \t") . drop 11 $ pdb
        _     -> fail $ filename ++ ": package-db entry not found."

sandboxConfs :: FilePath -> IO [FilePath]
sandboxConfs dir = 
    filter (".conf" `isSuffixOf`) . map (dir </>) <$> getDirectoryContents dir
  
main :: IO ()
main = do
    args <- getArgs
    case args of
        [path] -> do 
            froms <- sandboxConfs =<< getPackageDBFromConfig (path </> "cabal.sandbox.config")
            to    <- getCurrentDirectory >>= getPackageDBFromConfig . (</> "cabal.sandbox.config")
            mapM_ (\from -> copyFile from (to </> takeFileName from)) froms
            rawSystem "cabal" ["sandbox", "hc-pkg", "--", "recache", "--user"] >>= exitWith

        _      -> getProgName >>= \pn -> hPutStrLn stderr ("USAGE: " ++ pn ++ " DIR") >> exitFailure

