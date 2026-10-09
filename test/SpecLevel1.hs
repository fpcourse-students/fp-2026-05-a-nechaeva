module SpecLevel1 where

import Examples qualified as E
import Level1
import Test.Prelude hiding (Done)

tests :: NamedTests
tests = nameTests 1 [testRead, testTree, testMaybeList, testBug, testRecord]

testRead :: Test
testRead = TestList
  [ TestCase $ assertEqual "листья" (E.leafCount E.tree) predictedLeaves
  , TestCase $ assertEqual "преобразованное дерево" (E.transform (> 2) E.tree) predictedMapped
  , TestCase $ assertEqual "старые и новые версии" (E.xs, E.ys, E.zs) predictedVersions
  ]

genTree :: Int -> Gen IntTree
genTree n
  | n <= 0 = oneof [pure Leaf, Node <$> chooseInt (-20, 20) <*> pure []]
  | otherwise = frequency
      [ (1, pure Leaf)
      , (3, do
          x <- chooseInt (-20, 20)
          k <- chooseInt (0, 3)
          children <- vectorOf k (genTree (n `div` 3))
          pure (Node x children))
      ]

values :: IntTree -> [Int]
values Leaf = []
values (Node x children) = x : concatMap values children

testTree :: Test
testTree = TestList
  [ TestCase $ do
      assertEqual "пустой лист" 0 (sumIntTree Leaf)
      assertEqual "узел без детей" 42 (sumIntTree (Node 42 []))
  , TestCase $ assertEqual "все дети, включая последний" 15 $
      sumIntTree (Node 1 [Node 2 [Node 5 [Leaf]], Leaf, Node 3 [], Leaf, Node 4 []])
  , TestCase $ assertEqual "отрицательные значения" (-3) $
      sumIntTree (Node (-10) [Node 3 [], Node 4 [Leaf]])
  , propertyToTest "значения всех узлов" $ forAll (genTree 9) $ \t ->
      sumIntTree t === sum (values t)
  , propertyToTest "sumChildren" $ forAll (resize 10 (listOf (genTree 6))) $ \ts ->
      sumChildren ts === sum (concatMap values ts)
  ]

testMaybeList :: Test
testMaybeList = TestList
  [ TestCase $ do
      assertEqual "пустой вход" (Just [] :: Maybe [Int]) (applyMaybeList Just [])
      assertEqual "порядок и изменение типа" (Just ["3", "1", "2"]) $
        applyMaybeList (Just . show) [3, 1, 2 :: Int]
  , TestCase $ do
      assertEqual "первый отказ" (Nothing :: Maybe [Int]) $
        applyMaybeList positive [0, 1, 2]
      assertEqual "отказ в середине" (Nothing :: Maybe [Int]) $
        applyMaybeList positive [1, 0, 2]
  , TestCase $ assertEqual "отказ в конце" (Nothing :: Maybe [Int]) $
      applyMaybeList positive [1, 2, 0]
  , TestCase $ assertEqual "успешные элементы не отбрасываются" (Just [1, 2, 3]) $
      applyMaybeList positive [1, 2, 3]
  , propertyToTest "все результаты либо Nothing" $ \(xs :: [Int]) ->
      let f x = if even x then Just (show x) else Nothing
      in applyMaybeList f xs === traverse f xs
  ]

testBug :: Test
testBug = TestList
  [ TestCase $ assertBool "нужен список из 1–10 чисел от -100 до 100" admissible
  , TestCase $ assertBool "на этом входе код не расходится с условием" $
      not admissible || parsePositiveBuggy badInput /= traverse positive badInput
  ]
  where
    admissible = not (null badInput) && length badInput <= 10
      && all (\x -> -100 <= x && x <= 100) badInput

testRecord :: Test
testRecord = TestList
  [ TestCase $ assertEqual "Planned запускается" (Task "compile" Running 3) $
      startTask (Task "compile" Planned 2)
  , TestCase $ assertEqual "Running сохраняется" (Task "compile" Running 2) $
      startTask (Task "compile" Running 2)
  , TestCase $ assertEqual "Done сохраняется" (Task "compile" Done 2) $
      startTask (Task "compile" Done 2)
  , propertyToTest "сохраняются название и уже работающие версии" $ \title ->
      forAll (chooseInt (0, 1000)) $ \n ->
        let original = Task title Planned n
            next = startTask original
        in conjoin
          [ taskTitle next === title
          , taskStatus next === Running
          , taskAttempts next === n + 1
          , startTask next === next
          , startTask (Task title Done n) === Task title Done n
          , taskStatus original === Planned
          ]
  ]
