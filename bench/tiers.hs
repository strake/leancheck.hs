-- tiers.hs -- prints tiers of values up to a certain point
--
-- Copyright (c) 2015-2017 Rudy Matela.
-- Distributed under the 3-Clause BSD licence (see the file LICENSE).
import Test.LeanCheck
import Test.LeanCheck.Utils.Types
import Test.LeanCheck.Function
import System.Environment
import Data.List (intercalate)

beside :: String -> String -> String
beside heading s = init $ unlines $
  zipWith
    (++)
    ([heading] ++ repeat (replicate (length heading) ' '))
    (lines s)

listLines :: [String] -> String
listLines []  = "[]"
listLines [s] | '\n' `notElem` s = "[" ++ s ++ "]"
listLines ss  = (++ "]")
              . unlines
              . zipWith beside (["[ "] ++ repeat ", ")
              $ ss

showListLines :: Show a => [a] -> String
showListLines = listLines . map show

showTiersLines :: Show a => Int -> [[a]] -> String
showTiersLines n = listLines . dotsLongerThan n . map showListLines

dotsLongerThan :: Int -> [String] -> [String]
dotsLongerThan n xs = take n xs ++ ["..." | not . null $ drop n xs]

showDotsLongerThan :: Show a => Int -> [a] -> String
showDotsLongerThan n xs = "["
                       ++ intercalate "," (dotsLongerThan n $ map show xs)
                       ++ "]"

putTiers :: Show a => Int -> [[a]] -> IO ()
putTiers n = putStrLn . ("  " `beside`) . showTiersLines n

main :: IO ()
main = do
  as <- getArgs
  let (t,n) = case as of
                []    -> ("Int", 12)
                [t]   -> (t,     12)
                [t,n] -> (t, read n)
  case t of
    -- simple types
    "()"               -> put t n (u :: ()                   )
    "Int"              -> put t n (u :: Int                  )
    "Nat"              -> put t n (u :: Nat                  )
    "Integer"          -> put t n (u :: Integer              )
    "Bool"             -> put t n (u :: Bool                 )
    "Char"             -> put t n (u :: Char                 )
    -- lists
    "[()]"             -> put t n (u :: [()]                 )
    "[Int]"            -> put t n (u :: [Int]                )
    "[Nat]"            -> put t n (u :: [Nat]                )
    "[Integer]"        -> put t n (u :: [Integer]            )
    "[Bool]"           -> put t n (u :: [Bool]               )
    "[Char]"           -> put t n (u :: [Char]               )
    "String"           -> put t n (u :: String               )
    -- pairs
    "((),())"          -> put t n (u :: ((),())              )
    "(Int,Int)"        -> put t n (u :: (Int,Int)            )
    "(Nat,Nat)"        -> put t n (u :: (Nat,Nat)            )
    "(Bool,Bool)"      -> put t n (u :: (Bool,Bool)          )
    "(Bool,Int)"       -> put t n (u :: (Bool,Int)           )
    "(Int,Bool)"       -> put t n (u :: (Int,Bool)           )
    "(Int,Int,Int)"    -> put t n (u :: (Int,Int,Int)        )
    "(Nat,Nat,Nat)"    -> put t n (u :: (Nat,Nat,Nat)        )
    -- lists & pairs
    "[((),())]"        -> put t n (u :: [((),())]            )
    "([()],[()])"      -> put t n (u :: ([()],[()])          )
    "([Bool],[Bool])"  -> put t n (u :: ([Bool],[Bool])      )
    "([Int],[Int])"    -> put t n (u :: ([Int],[Int])        )
    -- functions
    "()->()"           -> put t n (u :: () -> ()             )
    "()->Bool"         -> put t n (u :: () -> Bool           )
    "Bool->()"         -> put t n (u :: Bool -> ()           )
    "Bool->Bool"       -> put t n (u :: Bool -> Bool         )
    "Bool->Bool->Bool" -> put t n (u :: Bool -> Bool -> Bool )
    "Int->Int"         -> put t n (u :: Int -> Int           )
    "Int->Int->Int"    -> put t n (u :: Int -> Int -> Int    )
    "()->Nat"          -> put t n (u :: () -> Nat            )
    "Nat->()"          -> put t n (u :: Nat -> ()            )
    "Nat->Nat"         -> put t n (u :: Nat -> Nat           )
    "Nat->Nat->Nat"    -> put t n (u :: Nat -> Nat -> Nat    )
    "(Nat,Nat)->Nat"   -> put t n (u :: (Nat,Nat) -> Nat     )
    "Bool->Maybe Bool" -> put t n (u :: Bool -> Maybe Bool   )
    "Maybe Bool->Bool" -> put t n (u :: Maybe Bool -> Bool   )
    "Maybe Bool->Maybe Bool" -> put t n (u :: Maybe Bool -> Maybe Bool)
    -- more functions
    "Nat2->Nat2"       -> put t n (u :: Nat2 -> Nat2         )
    "Nat2->Nat3"       -> put t n (u :: Nat2 -> Nat3         )
    "Nat3->Nat2"       -> put t n (u :: Nat3 -> Nat2         )
    "Nat3->Nat3"       -> put t n (u :: Nat3 -> Nat3         )
    -- special lists
    "Set Bool"         -> put t n (u :: Set Bool             )
    "Set ()"           -> put t n (u :: Set ()               )
    "Set Nat"          -> put t n (u :: Set Nat              )
    "Set Nat2"         -> put t n (u :: Set Nat2             )
    "Set Nat3"         -> put t n (u :: Set Nat3             )
    "Bag Bool"         -> put t n (u :: Bag Bool             )
    "Bag ()"           -> put t n (u :: Bag ()               )
    "Bag Nat"          -> put t n (u :: Bag Nat              )
    "Bag Nat2"         -> put t n (u :: Bag Nat2             )
    "Bag Nat3"         -> put t n (u :: Bag Nat3             )
    "NoDup Bool"       -> put t n (u :: NoDup Bool           )
    "NoDup ()"         -> put t n (u :: NoDup ()             )
    "NoDup Nat"        -> put t n (u :: NoDup Nat            )
    "NoDup Nat2"       -> put t n (u :: NoDup Nat2           )
    "NoDup Nat3"       -> put t n (u :: NoDup Nat3           )
    -- unhandled
    _                  -> putStrLn $ "unknown/unhandled type `" ++ t ++ "'"
  where
  u :: a
  u = undefined
  put :: (Show a, Listable a) => String -> Int -> a -> IO ()
  put t n a = do
    putStrLn $ "tiers :: [" ++ t ++ "]  ="
    putTiers n $ tiers `asTypeOf` [[a]]
    putStrLn $ ""
    putStrLn $ "map length (tiers :: [" ++ t ++ "])  =  "
          ++ showDotsLongerThan n (map length $ tiers `asTypeOf` [[a]])
