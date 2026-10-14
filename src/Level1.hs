{-# OPTIONS_GHC -Wno-unused-matches #-}
-- | Домашка 5. Типы данных: обязательные задачи.
module Level1 where

import Examples qualified as E
import MetaUtils (todo)

-- 1.1. Прочитайте код до запуска.
--
-- Примеры находятся в src/Examples.hs. Запишите результаты выражений ниже
-- литералами и конструкторами, без вызовов функций из условия.
-- Сначала предскажите ответы, затем сверьтесь через make repl.
-- Для дерева используйте конструкторы E.Leaf и E.Node.

-- E.leafCount E.tree
predictedLeaves :: Int
predictedLeaves = 3

-- E.transform (> 2) E.tree
predictedMapped :: E.Tree Bool
predictedMapped = E.Node (E.Leaf False) False (E.Node (E.Leaf True) True (E.Leaf True))

-- (E.xs, E.ys, E.zs)
predictedVersions :: ([Int], [Int], [Int])
predictedVersions = ([3,4], [1,3,4], [2,1,3,4])


-- 1.2. Дерево с произвольным числом детей.
--
-- Leaf не хранит значений; Node хранит Int и список поддеревьев.
-- Просуммируйте значения всех Node. В частности, Node x [] содержит значение x.
-- Закончите ветку Node в sumIntTree и напишите sumChildren целиком.
-- sumChildren складывает значения всех деревьев из списка детей.
-- Можно использовать знакомые функции над списками; сигнатуры не меняйте.

data IntTree = Leaf | Node Int [IntTree]
  deriving (Eq, Show)

sumIntTree :: IntTree -> Int
sumIntTree t = case t of
  Leaf -> 0
  Node x children -> x + sumChildren children

sumChildren :: [IntTree] -> Int
sumChildren = sum.map sumIntTree


-- 1.3. Все результаты или отказ.
--
-- Примените f к каждому элементу. Если все результаты Just, верните Just
-- со списком значений в исходном порядке. Если встретился Nothing,
-- результат всей функции — Nothing. Для [] результат — Just [].
-- Пустой случай и разбор результата f уже даны; закончите рекурсивную ветку.
-- Используйте сопоставление и рекурсию, без traverse/sequence и свёрток.

applyMaybeList :: (a -> Maybe b) -> [a] -> Maybe [b]
applyMaybeList f xs = case xs of
  [] -> Just []
  x : rest -> case f x of
    Nothing -> Nothing
    Just y -> case applyMaybeList f rest of
      Nothing -> Nothing
      Just ys -> Just (y:ys)


-- 1.4. Контрпример вместо объяснения.
--
-- parsePositiveBuggy должна принимать список положительных чисел целиком
-- либо отказывать, как applyMaybeList positive. Данный код делает что-то другое.
-- Запишите список из 1–10 чисел от -100 до 100, на котором результаты различаются.
-- Функции ниже не исправляйте: задача — обнаружить ошибку входным примером.

positive :: Int -> Maybe Int
positive n
  | n > 0 = Just n
  | otherwise = Nothing

parsePositiveBuggy :: [Int] -> Maybe [Int]
parsePositiveBuggy xs = Just (filter (> 0) xs)

badInput :: [Int]
badInput = [-1, 1]


-- 1.5. Вспомните записи.
--
-- Task хранит название, состояние и число запусков. startTask запускает Planned:
-- меняет состояние на Running и увеличивает число запусков на один.
-- Running и Done остаются без изменений. Название сохраняется во всех случаях.
-- Напишите функцию целиком; попробуйте синтаксис обновления записи.
-- Это новая версия значения: исходная запись по-прежнему доступна.

data TaskStatus = Planned | Running | Done
  deriving (Eq, Show)

data Task = Task
  { taskTitle :: String
  , taskStatus :: TaskStatus
  , taskAttempts :: Int
  }
  deriving (Eq, Show)

startTask :: Task -> Task
startTask t 
  | taskStatus t == Planned =
    t { taskStatus = Running
    , taskAttempts = taskAttempts t + 1 }
  |otherwise = t
