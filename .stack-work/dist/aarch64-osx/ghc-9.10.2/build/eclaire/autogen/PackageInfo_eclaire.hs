{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module PackageInfo_eclaire (
    name,
    version,
    synopsis,
    copyright,
    homepage,
  ) where

import Data.Version (Version(..))
import Prelude

name :: String
name = "eclaire"
version :: Version
version = Version [0,1,0,0] []

synopsis :: String
synopsis = "Cross-language semantic UI layout engine powered by Clay"
copyright :: String
copyright = ""
homepage :: String
homepage = ""
