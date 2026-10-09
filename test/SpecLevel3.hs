module SpecLevel3 where

import Data.List (foldl')
import Level3
import Test.Prelude

tests :: NamedTests
tests = nameTests 3 [testTreap]

-- Вход строится через ДАННЫЕ merge/singleton, а не через append студента.
build :: [Int] -> [Int] -> DTree Int
build xs keys = foldl' merge empty (zipWith singleton xs keys)

flatten :: DTree a -> [a]
flatten Nothing = []
flatten (Just t) = flatten (treeLeft t) ++ treeElem t : flatten (treeRight t)

actualSize :: DTree a -> Int
actualSize Nothing = 0
actualSize (Just t) = 1 + actualSize (treeLeft t) + actualSize (treeRight t)

valid :: DTree a -> Bool
valid Nothing = True
valid t@(Just node) =
  treeSize node == actualSize t
  && all (\child -> maybe True ((<= treePriority node) . treePriority) child)
      [treeLeft node, treeRight node]
  && valid (treeLeft node) && valid (treeRight node)

same :: [Int] -> DTree Int -> Property
same xs t = conjoin [flatten t === xs, size t === length xs, property (valid t)]

genInput :: Gen ([Int], [Int])
genInput = do
  n <- chooseInt (0, 25)
  xs <- vectorOf n (chooseInt (-100, 100))
  -- Частые совпадения приоритетов обязательны для корректного merge.
  keys <- vectorOf n (chooseInt (-2, 2))
  pure (xs, keys)

testTreap :: Test
testTreap = TestList
  [ TestCase $ assertEqual "пустой поиск" (Nothing :: Maybe Int) (empty !!? 0)
  , propertyToTest "поиск и границы" $ forAll genInput $ \(xs, keys) ->
      forAll (chooseInt (-5, length xs + 5)) $ \i ->
        let expected = if i < 0 then Nothing else case drop i xs of
              [] -> Nothing
              x : _ -> Just x
        in build xs keys !!? i === expected
  , propertyToTest "append" $ forAll genInput $ \(xs, keys) ->
      forAll (chooseInt (-100, 100)) $ \x ->
        forAll (chooseInt (-2, 2)) $ \k -> same (xs ++ [x]) (append (build xs keys) x k)
  , propertyToTest "insert: перед индексом, с нуля" $ forAll genInput $ \(xs, keys) ->
      forAll (chooseInt (-5, length xs + 5)) $ \i ->
        forAll (chooseInt (-100, 100)) $ \x ->
          forAll (chooseInt (-2, 2)) $ \k ->
            let (l, r) = splitAt i xs
            in same (l ++ x : r) (insert i x k (build xs keys))
  , propertyToTest "remove: недопустимый индекс сохраняет версию" $ forAll genInput $ \(xs, keys) ->
      forAll (chooseInt (-5, length xs + 5)) $ \i ->
        let (l, r) = splitAt i xs
            expected = if i < 0 then xs else l ++ drop 1 r
        in same expected (remove (build xs keys) i)
  , propertyToTest "последовательность версий" $ forAll genInput $ \(xs, keys) ->
      let t = build xs keys
          appended = append t 7 0
          inserted = insert 0 8 0 appended
          removed = remove inserted 1
          expected = 8 : drop 1 (xs ++ [7])
      in conjoin
        [ same xs t
        , same (xs ++ [7]) appended
        , same (8 : xs ++ [7]) inserted
        , same expected removed
        ]
  , TestCase $ assertEqual "insert 0 на непустом дереве" [9,1,2] $
      flatten (insert 0 9 10 (build [1,2] [0,1]))
  , TestCase $ assertEqual "remove 0 удаляет первый" [2] $
      flatten (remove (build [1,2] [0,1]) 0)
  ]
