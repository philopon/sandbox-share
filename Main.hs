import Control.Applicative
import Control.Monad
import Control.Exception

import System.Process
import System.Directory
import System.FilePath
import System.Exit
import System.Environment

import Data.List
import Data.Maybe

test = sandboxConfs "/Users/philopon/cabal-sandbox/yesod"

sandboxConfsd :: FilePath -> IO (Maybe FilePath)
sandboxConfsd dir = 
  getDirectoryContents sandbox >>=
  return . listToMaybe . fmap (sandbox </>) . filter ("packages.conf.d" `isInfixOf`)
  where sandbox = dir </> ".cabal-sandbox"

sandboxConfs :: FilePath -> IO [FilePath]
sandboxConfs dir = do
  mbconfd <- sandboxConfsd dir
  case mbconfd of
    Nothing    -> return []
    Just confd -> getDirectoryContents confd >>= return . filter (".conf" `isSuffixOf`) . map (confd </>)

register :: FilePath -> IO ()
register conf = do
  (_, _, Just stderr, ph) <- createProcess (proc "cabal" args) { std_err = CreatePipe }
  exitCode <- waitForProcess ph
  case exitCode of
    ExitSuccess -> return ()
    failure     -> throwIO failure
  where args = ["sandbox", "hc-pkg", "--", "register", "--force", conf]

main :: IO ()
main = do
  args <- getArgs
  case args of
    [path] -> mapM_ register =<< sandboxConfs path
    _      -> getProgName >>= \pn -> putStrLn $ "USAGE: " ++ pn ++ " DIR"
