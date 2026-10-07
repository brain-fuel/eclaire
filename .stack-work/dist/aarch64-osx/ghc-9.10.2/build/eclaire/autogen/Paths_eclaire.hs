{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
#if __GLASGOW_HASKELL__ >= 810
{-# OPTIONS_GHC -Wno-prepositive-qualified-module #-}
#endif
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_eclaire (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath




bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/Users/mattlaine/para/projects/layouts/eclaire/.stack-work/install/aarch64-osx/da3b69980b476f78383aa5124a67e6097c553cc47d0b7e3790ab8a173f859a2f/9.10.2/bin"
libdir     = "/Users/mattlaine/para/projects/layouts/eclaire/.stack-work/install/aarch64-osx/da3b69980b476f78383aa5124a67e6097c553cc47d0b7e3790ab8a173f859a2f/9.10.2/lib/aarch64-osx-ghc-9.10.2-b8ed/eclaire-0.1.0.0-CS4ncrsgEi0IFNmTuFWdwO-eclaire"
dynlibdir  = "/Users/mattlaine/para/projects/layouts/eclaire/.stack-work/install/aarch64-osx/da3b69980b476f78383aa5124a67e6097c553cc47d0b7e3790ab8a173f859a2f/9.10.2/lib/aarch64-osx-ghc-9.10.2-b8ed"
datadir    = "/Users/mattlaine/para/projects/layouts/eclaire/.stack-work/install/aarch64-osx/da3b69980b476f78383aa5124a67e6097c553cc47d0b7e3790ab8a173f859a2f/9.10.2/share/aarch64-osx-ghc-9.10.2-b8ed/eclaire-0.1.0.0"
libexecdir = "/Users/mattlaine/para/projects/layouts/eclaire/.stack-work/install/aarch64-osx/da3b69980b476f78383aa5124a67e6097c553cc47d0b7e3790ab8a173f859a2f/9.10.2/libexec/aarch64-osx-ghc-9.10.2-b8ed/eclaire-0.1.0.0"
sysconfdir = "/Users/mattlaine/para/projects/layouts/eclaire/.stack-work/install/aarch64-osx/da3b69980b476f78383aa5124a67e6097c553cc47d0b7e3790ab8a173f859a2f/9.10.2/etc"

getBinDir     = catchIO (getEnv "eclaire_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "eclaire_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "eclaire_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "eclaire_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "eclaire_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "eclaire_sysconfdir") (\_ -> return sysconfdir)



joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
