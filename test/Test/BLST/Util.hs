-- SPDX-FileCopyrightText: 2022 Serokell <https://serokell.io>
-- SPDX-License-Identifier: MPL-2.0

{-# OPTIONS_GHC -Wwarn #-}

module Test.BLST.Util
  ( fromHex
  , toHex
  , deserializePoint
  , deserializePoint'
  , fromHex'
  , deserializeAffine'
  ) where

import Data.ByteArray (Bytes)
import Data.ByteArray qualified as BA
import Data.ByteArray.Sized (SizedByteArray)
import Data.ByteArray.Sized qualified as AS
import Data.Maybe (fromJust)
import Data.Text (Text)
import GHC.TypeNats (KnownNat)
import System.IO.Unsafe (unsafePerformIO)
import Text.Hex (decodeHex, encodeHex)

import Crypto.BLST.Internal.Bindings qualified as B
import Crypto.BLST.Internal.Classy qualified as C

fromHex :: (KnownNat n) => Text -> SizedByteArray n Bytes
fromHex = AS.convert . AS.unsafeSizedByteArray . fromJust . decodeHex

fromHex' :: BA.ByteArray a => Text -> a
fromHex' = BA.convert . fromJust . decodeHex

toHex :: BA.ByteArray a => SizedByteArray n a -> Text
toHex = encodeHex . BA.convert . AS.unSizedByteArray

deserializePoint :: C.IsPoint p => Text -> B.Point p
deserializePoint = unsafePerformIO . C.fromAffine . deserializeAffine

deserializePoint' :: C.IsPoint p => SizedByteArray (C.SerializedSize p) Bytes -> B.Point p
deserializePoint' = unsafePerformIO . C.fromAffine . deserializeAffine'

deserializeAffine :: C.IsPoint p => Text -> B.Affine p
deserializeAffine = deserializeAffine' . fromHex

deserializeAffine' :: C.IsPoint p => SizedByteArray (C.SerializedSize p) Bytes -> B.Affine p
deserializeAffine' = unsafePerformIO . fmap (either (error . show) id) . C.deserialize
