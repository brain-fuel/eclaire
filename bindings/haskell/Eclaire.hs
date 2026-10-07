{-# LANGUAGE ForeignFunctionInterface #-}

module Eclaire
  ( irVersion
  , minMemorySize
  , clayCommit
  ) where

import Data.Word (Word32)
import Foreign.C.Types (CUInt (..), CSize (..))

foreign import ccall unsafe "eclaire_ir_version"
  c_ir_version :: IO Word32

foreign import ccall unsafe "eclaire_min_memory_size"
  c_min_memory_size :: CUInt -> IO CSize

irVersion :: IO Word32
irVersion = c_ir_version

minMemorySize :: Word32 -> IO Int
minMemorySize maxElements = fromIntegral <$> c_min_memory_size (fromIntegral maxElements)

clayCommit :: String
clayCommit = "e6cc36941ab2af5d81107617039d6f527a1c660b"
