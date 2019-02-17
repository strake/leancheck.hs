-- |
-- Module      : Test.LeanCheck.Function
-- Copyright   : (c) 2015-2018 Rudy Matela
-- License     : 3-Clause BSD  (see the file LICENSE)
-- Maintainer  : Rudy Matela <rudy@matela.com.br>
--
-- This module is part of LeanCheck,
-- a simple enumerative property-based testing library.
--
-- This module exports 'Listable' and 'Show' function typeclass instances.
-- These can be useful for testing higher-order properties --- properties that
-- take functions as arguments.
--
-- > > import Test.LeanCheck
-- > > import Test.LeanCheck.Function
--
-- > > check $ \f p xs -> filter p (map f xs) == map f (filter p xs :: [Int])
-- > *** Failed! Falsifiable (after 36 tests):
-- > \_ -> 0
-- > \x -> case x of
-- >       0 -> True
-- >       _ -> False
-- > [1]
--
-- > > check $ \f p xs -> filter p (map f xs) == map f (filter p xs :: [Bool])
-- > *** Failed! Falsifiable (after 20 tests):
-- > \_ -> False
-- > \x -> case x of
-- >       False -> False
-- >       True -> True
-- > [True]
--
-- > > check $ \f z xs -> foldr f z xs == foldl f z (xs :: [Int])
-- > *** Failed! Falsifiable (after 75 tests):
-- > \x _ -> case x of
-- >         0 -> 1
-- >         _ -> 0
-- > 0
-- > [0,0]
--
-- Warning: this is only intended to be used in testing modules.  Avoid
-- importing this on modules that are used as libraries.
--
-- The 'Listable' and 'Show' function instance are defined in, respectively:
--
-- * "Test.LeanCheck.Function.Listable"
-- * "Test.LeanCheck.Function.Show"
--
-- The 'Show' instance will work for all functions whose return types are
-- instances of ShowFunction from "Test.LeanCheck.Function.ShowFunction".
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Test.LeanCheck.Function () where
import Test.LeanCheck.Core (Listable) -- for Haddock
import Test.LeanCheck.Function.Listable ()
import Test.LeanCheck.Function.Show ()
