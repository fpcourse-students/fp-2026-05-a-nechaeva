module SpecLevel2 where

import Control.Exception (ErrorCall)
import Data.Char (digitToInt)
import Data.List qualified as List
import Level2
import Test.Prelude

tests :: NamedTests
tests = nameTests 2
  [ testNat, testBinTree, testLexLess, testDigits, testFibs, testWindow, testOptions ]

testNat :: Test
testNat = TestList
  [ TestCase $ assertEqual "makeNat 0" Zero (makeNat 0)
  , TestCase $ assertEqual "makeNat 3" (Suc (Suc (Suc Zero))) (makeNat 3)
  , TestCase $ assertEqual "foldNat 0" ("z" :: String) (foldNat ('s' :) "z" Zero)
  , TestCase $ assertEqual "foldNat 3" "sssz" (foldNat ('s' :) "z" (Suc (Suc (Suc Zero))))
  , TestCase $ assertThrows @ErrorCall (foldNat (+ 1) (0 :: Int) (makeNat (-1)))
  , propertyToTest "makeNat/foldNat" $ forAll (chooseInt (0, 200)) $ \n ->
      foldNat (+ 3) 7 (makeNat n) === 7 + 3 * n
  ]

genBin :: Int -> Gen (BinTree Int)
genBin n
  | n <= 0 = pure Empty
  | otherwise = frequency
      [ (1, pure Empty)
      , (3, BinNode <$> genBin (n `div` 2)
          <*> chooseInt (-100, 100) <*> genBin (n `div` 2))
      ]

testBinTree :: Test
testBinTree = TestList
  [ propertyToTest "map id сохраняет форму" $ forAll (genBin 10) $ \t ->
      mapBinTree id t === t
  , propertyToTest "согласованность композиции" $ forAll (genBin 10) $ \t ->
      mapBinTree length (mapBinTree show t) === mapBinTree (length . show) t
  , TestCase $ assertEqual "изменение типа" (BinNode Empty 2 (BinNode Empty 1 Empty)) $
      mapBinTree length (BinNode Empty "ab" (BinNode Empty "x" Empty))
  , TestCase $ assertEqual "вложенная пустота" (BinNode Empty Empty Empty :: BinTree (BinTree String)) $
      bangAll (BinNode Empty Empty Empty :: BinTree (BinTree Int))
  , TestCase $ assertEqual "bangAll сохраняет обе формы"
      (BinNode Empty (BinNode Empty "-3!" Empty) (BinNode Empty Empty Empty)) $
      bangAll (BinNode Empty (BinNode Empty (-3) Empty) (BinNode Empty Empty Empty))
  ]

testLexLess :: Test
testLexLess = TestList
  [ TestCase $ assertBool "[] не меньше []" (not (lexLess ([] :: [Int]) []))
  , TestCase $ assertBool "префикс" (lexLess [1 :: Int] [1, 2])
  , TestCase $ assertBool "первое различие" (lexLess [1, 2, 100 :: Int] [1, 3, 0])
  , propertyToTest "сравнение списков" $ \(xs :: [Int], ys :: [Int]) ->
      lexLess xs ys === (xs < ys)
  ]

testDigits :: Test
testDigits = TestList
  [ TestCase $ assertEqual "ноль" [0] (digits 0)
  , TestCase $ assertEqual "нули внутри и в конце" [1, 0, 0, 2, 0] (digits 10020)
  , TestCase $ assertEqual "maxBound" (map digitToInt (show (maxBound :: Int))) (digits maxBound)
  , TestCase $ assertThrows @ErrorCall (digits (-1))
  , propertyToTest "десятичные цифры" $ \(NonNegative n) ->
      digits n === map digitToInt (show (n :: Int))
  ]

testFibs :: Test
testFibs = TestList
  [ TestCase $ assertEqual "повторения" 4 (countFibs [1, 1, 1, 1])
  , TestCase $ assertEqual "разные значения" 3 (countFibs [0, 1, 4, 6, 7, 8, 9, 11])
  , TestCase $ assertEqual "пустой список" 0 (countFibs [])
  , TestCase $ assertBool "отрицательное число" (not (isFib (-1)))
  , TestCase $ assertBool "Integer без переполнения" (isFib 354224848179261915075)
  , TestCase $ assertBool "сосед большого числа" (not (isFib 354224848179261915076))
  , propertyToTest "подсчёт, включая отрицательные" $
      forAll (resize 30 (listOf (chooseInteger (-500, 500)))) $ \xs ->
        countFibs xs === length (filter (\x -> x `elem` known) xs)
  ]
  where
    known = [0,1,2,3,5,8,13,21,34,55,89,144,233,377]

testWindow :: Test
testWindow = TestList
  [ TestCase $ assertEqual "окно 1" [[1],[2],[3]] (withWindow [1,2,3 :: Int] 1)
  , TestCase $ assertEqual "пустой список" ([] :: [[Int]]) (withWindow [] 2)
  , TestCase $ assertEqual "окно больше списка" ([] :: [[Int]]) (withWindow [1] 2)
  , TestCase $ assertEqual "первые окна бесконечного входа" [[1,2,3],[2,3,4],[3,4,5],[4,5,6]] $
      take 4 (withWindow [1..] 3)
  , TestCase $ assertThrows @ErrorCall (withWindow [1 :: Int] 0)
  , TestCase $ assertThrows @ErrorCall (withWindow ([] :: [Int]) (-1))
  , propertyToTest "все полные окна" $
      forAll (resize 30 (arbitrary :: Gen [Int])) $ \xs ->
        forAll (chooseInt (1, 40)) $ \n ->
          withWindow xs n === filter ((== n) . length) (map (take n) (List.tails xs))
  ]

testOptions :: Test
testOptions = TestList
  [ TestList
      [ TestCase $ assertEqual ("комбинация " ++ show raw) (lookup raw valid) (parseOptions raw)
      | raw <- rawVariants
      ]
  , propertyToTest "сохраняется путь" $ \path ->
      parseOptions (RawOptions False (Just JSON) (Just path)) === Just (Run JSON (File path))
  ]
  where
    rawVariants =
      [ RawOptions help format path
      | help <- [False, True]
      , format <- [Nothing, Just Plain, Just JSON]
      , path <- [Nothing, Just "a.txt", Just "b.txt"]
      ]
    valid = (RawOptions True Nothing Nothing, Help) :
      [ (RawOptions False (Just f) path, Run f target)
      | f <- [Plain, JSON]
      , (path, target) <- [(Nothing, Stdout), (Just "a.txt", File "a.txt"), (Just "b.txt", File "b.txt")]
      ]
