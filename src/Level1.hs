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
predictedLeaves = todo "1.1 leaves"

-- E.transform (> 2) E.tree
predictedMapped :: E.Tree Bool
predictedMapped = todo "1.1 mapped"

-- (E.xs, E.ys, E.zs)
predictedVersions :: ([Int], [Int], [Int])
predictedVersions = todo "1.1 versions"


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
  Node x children -> todo "1.2 node"

sumChildren :: [IntTree] -> Int
sumChildren = todo "1.2 children"


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
    Just y -> todo "1.3"


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
badInput = todo "1.4"


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
startTask = todo "1.5"
