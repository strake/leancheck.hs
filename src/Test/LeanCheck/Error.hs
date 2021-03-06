-- |
-- Module      : Test.LeanCheck.Error
-- Copyright   : (c) 2015-2020 Rudy Matela
-- License     : 3-Clause BSD  (see the file LICENSE)
-- Maintainer  : Rudy Matela <rudy@matela.com.br>
--
-- This module is part of LeanCheck,
-- a simple enumerative property-based testing library.
--
-- This module re-exports "Test.LeanCheck" but some test functions have been
-- specialized to catch errors (see the explicit export list below).
--
-- This module is unsafe as it uses `unsafePerformIO` to catch errors.
{-# LANGUAGE CPP #-}
module Test.LeanCheck.Error
  ( holds
  , fails
  , exists
  , counterExample
  , counterExamples
  , witness
  , witnesses
  , results

  , fromError
  , errorToNothing
  , errorToFalse
  , errorToTrue
  , anyErrorToNothing

  , module Test.LeanCheck
  )
where

#if __GLASGOW_HASKELL__ <= 704
import Prelude hiding (catch)
#endif

import Test.LeanCheck hiding
  ( holds
  , fails
  , exists
  , counterExample
  , counterExamples
  , witness
  , witnesses
  , results
  )

import qualified Test.LeanCheck as C
  ( holds
  , fails
  , results
  )

import Control.Monad (liftM)
import System.IO.Unsafe (unsafePerformIO)
import Data.Maybe (listToMaybe, fromMaybe)
import Control.Exception ( evaluate
                         , catch
#if __GLASGOW_HASKELL__
                         , Exception
                         , SomeException
                         , ArithException
                         , ArrayException
                         , ErrorCall
                         , PatternMatchFail
                         , catches
                         , Handler (Handler)
#endif
                         )

-- | Takes a value and a function.  Ignores the value.  Binds the argument of
--   the function to the type of the value.
bindArgumentType :: a -> (a -> b) -> a -> b
bindArgumentType _ f  =  f

-- | Transforms a value into 'Just' that value or 'Nothing' on some errors:
--
--   * ArithException
--   * ArrayException
--   * ErrorCall
--   * PatternMatchFail
--
-- > > errorToNothing False
-- > Just False
--
-- > > errorToNothing (0 :: Int)
-- > Just 0
--
-- > > errorToNothing (undefined :: ())
-- > Nothing
--
-- This function uses 'unsafePerformIO'.
errorToNothing :: a -> Maybe a
errorToNothing x  =  unsafePerformIO $
#if __GLASGOW_HASKELL__
  (Just `liftM` evaluate x) `catches` map ($ return Nothing)
                                      [ hf (undefined :: ArithException)
                                      , hf (undefined :: ArrayException)
                                      , hf (undefined :: ErrorCall)
                                      , hf (undefined :: PatternMatchFail)
                                      ]
  where
  hf :: Exception e => e -> IO a -> Handler a -- handlerFor
  hf e h  =  Handler $ bindArgumentType e (\_ -> h)
#else
  (Just `liftM` evaluate x) `catch` (\_ -> return Nothing)
#endif

-- | Transforms a value into 'Just' that value or 'Nothing' on error.
anyErrorToNothing :: a -> Maybe a
anyErrorToNothing x  =  unsafePerformIO $
#if __GLASGOW_HASKELL__
  (Just `liftM` evaluate x) `catch` \e -> do let _  =  e :: SomeException
                                             return Nothing
#else
  (Just `liftM` evaluate x) `catch` (\_ -> return Nothing)
#endif

-- | Transforms errors into 'False' values.
--
-- > > errorToFalse False
-- > False
--
-- > > errorToFalse True
-- > True
--
-- > > errorToFalse undefined
-- > False
--
-- This functions uses 'unsafePerformIO'.
errorToFalse :: Bool -> Bool
errorToFalse  =  fromError False

-- | Transforms errors into 'True' values.
--
-- > > errorToTrue False
-- > False
--
-- > > errorToTrue True
-- > True
--
-- > > errorToTrue undefined
-- > True
--
-- This functions uses 'unsafePerformIO'.
errorToTrue :: Bool -> Bool
errorToTrue  =  fromError True

-- | Transforms errors into a default value.
--
-- > > fromError 0 (15 :: Int)
-- > 15
--
-- > > fromError 0 (undefined :: Int)
-- > 0
fromError :: a -> a -> a
fromError x  =  fromMaybe x . errorToNothing

-- | An error-catching version of 'Test.LeanCheck.holds'
--   that returns 'False' in case of errors.
--
-- > prop_cannot_be_seven :: Int -> Bool
-- > prop_cannot_be_seven 7  =  error "Argument cannot be seven"
-- > prop_cannot_be_seven _  =  True
--
-- > > import Test.LeanCheck
-- > > holds 100 prop_cannot_be_seven
-- > *** Exception: Argument cannot be seven
--
-- > > import Test.LeanCheck.Error
-- > > holds 100 prop_cannot_be_seven
-- > False
holds :: Testable a => Int -> a -> Bool
holds n  =  errorToFalse . C.holds n

-- | An error-catching version of 'Test.LeanCheck.fails'
--   that returns 'True' in case of errors.
fails :: Testable a => Int -> a -> Bool
fails n  =  errorToTrue . C.fails n

-- | An error-catching version of 'Test.LeanCheck.exists'.
exists :: Testable a => Int -> a -> Bool
exists n  =  or . take n . map snd . results

-- | An error-catching version of 'Test.LeanCheck.counterExample'.
counterExample :: Testable a => Int -> a -> Maybe [String]
counterExample n  =  listToMaybe . counterExamples n

-- | An error-catching version of 'Test.LeanCheck.witness'.
witness :: Testable a => Int -> a -> Maybe [String]
witness n  =  listToMaybe . witnesses n

-- | An error-catching version of 'Test.LeanCheck.counterExamples'.
counterExamples :: Testable a => Int -> a -> [[String]]
counterExamples n  =  map fst . filter (not . snd) . take n . results

-- | An error-catching version of 'Test.LeanCheck.witnesses'.
witnesses :: Testable a => Int -> a -> [[String]]
witnesses n  =  map fst . filter snd . take n . results

-- | An error-catching version of 'Test.LeanCheck.results'.
results :: Testable a => a -> [([String],Bool)]
results  =  map (mapSnd errorToFalse) . C.results
  where
  mapSnd f (x,y)  =  (x,f y)
