module Main where

-- Sllar
import Examination (checkEnv)
import Common
import Config
import qualified Package
import qualified PackageList
import Paths_sllar_client

-- System
import Control.Monad (when)
import Data.Maybe
import Data.Version (showVersion)
import System.Environment (getArgs)


main :: IO ()
main =
  do env <- checkEnv "TMPDIR"
     when env $
       do args <- getArgs
          withArgs args $
            do let p = putStrLn
               case head args of
                 "install" -> withName $ Package.install (drop 1 args)
                 "show"    -> withName $ Package.showInfo (args !! 1)
                 "init"    -> withName $ Package.initialize (args !! 1)
                 "pack"    -> Package.pack
                 "publish" -> Package.publish
                 "list"    -> PackageList.show'
                 "update"  -> PackageList.update
                 "env"     -> envInfo
                 "help"    -> p "help"
                 _         -> p "help"

--
-- Wrapper around actions with package name.
-- Stops application execution if package name not given
-- Input: function to wrap
-- Output: funtion wrapped by package name existence verification
--
withName :: IO () -> IO ()
withName action = do
    args <- getArgs
    if null $ drop 1 args
      then failDown "Specify package name"
      else action


--
-- Wrapper, that checks if any argument specified
-- Input: arguments, function to applicationy if arguments exists
-- Output: wrapped function
--
withArgs :: [String] -> IO () -> IO ()
withArgs args f = if null args
                    then failDown "No arguments specified"
                    else f


--
-- Showing information about current installation
--
envInfo :: IO ()
envInfo = do
    configPath <- getDataFileName "config"
    config' <- config
    let repos = repositories $ fromMaybe (Config []) config'
        p = putStrLn

    p $ "Sllar-client. Version " ++ showVersion version
    p "For additional information visit https://github.com/grsmv/sllar \n"
    p "Config file:"
    p $ "  " ++ configPath ++ "\n"

    p "Repositories:"
    if not . null $ repos
       then mapM_ (p . ("  " ++)) repos
       else p "  [!] There's no registered repositories"
