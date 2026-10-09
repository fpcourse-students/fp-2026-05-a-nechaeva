{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
-- | Домашка 5. Задачи для уверенности.
module Level2 where

import MetaUtils (todo)

-- 2.1. Унарные числа.
--
-- makeNat строит число из n конструкторов Suc и завершающего Zero.
-- Для отрицательного аргумента выбросьте error. foldNat применяет s ровно n раз
-- к z: foldNat (+ 1) 0 (Suc (Suc Zero)) == 2.
-- Напишите обе функции с помощью сопоставления и рекурсии.

data Nat = Zero | Suc Nat
  deriving (Eq, Show)

makeNat :: Int -> Nat
makeNat = todo "2.1 make"

foldNat :: (a -> a) -> a -> Nat -> a
foldNat = todo "2.1 fold"


-- 2.2. Другое бинарное дерево.
--
-- Empty не содержит значения. У BinNode есть два поддерева и одно значение.
-- Реализуйте mapBinTree, сохраняя форму и меняя содержимое по функции.
-- Затем напишите сигнатуру и тело bangAll: она превращает BinTree (BinTree Int)
-- в BinTree (BinTree String); после каждого числа в строке стоит "!".

data BinTree a = Empty | BinNode (BinTree a) a (BinTree a)
  deriving (Eq, Show)

mapBinTree :: (a -> b) -> BinTree a -> BinTree b
mapBinTree = todo "2.2 map"

bangAll t = todo "2.2 bang"


-- 2.3. Лексикографическое сравнение.
--
-- lexLess xs ys истинно, если xs строго меньше ys.
-- Собственный префикс меньше списка; при первом различии решает пара элементов.
-- Равные списки не меньше друг друга. Для элементов можно использовать compare
-- и операторы сравнения; списки сравнивайте собственной рекурсией,
-- не передавайте целые списки стандартному (<) или compare.

lexLess :: Ord a => [a] -> [a] -> Bool
lexLess = todo "2.3"


-- 2.4. Цифры.
--
-- Верните цифры неотрицательного Int от старшей к младшей.
-- digits 0 == [0], digits 120 == [1, 2, 0].
-- Отрицательный аргумент — error. Используйте div/mod или quotRem,
-- без перевода числа в строку.

digits :: Int -> [Int]
digits = todo "2.4"


-- 2.5. Числа Фибоначчи и списки.
--
-- Бесконечный список fibs уже дан; в make repl смотрите take 10 fibs.
-- isFib проверяет принадлежность последовательности, в том числе 0 и 1.
-- Отрицательные числа не принадлежат ей.
-- countFibs считает элементы входного списка, являющиеся числами Фибоначчи;
-- повторения считаются отдельно. Например, countFibs [0, 1, 1, 4] == 3.
-- Используйте список fibs, без формулы через квадратный корень.
-- Integer выбран, чтобы последовательность не переполнялась.

fibs :: [Integer]
fibs = 0 : 1 : zipWith (+) fibs (drop 1 fibs)

isFib :: Integer -> Bool
isFib = todo "2.5 is"

countFibs :: [Integer] -> Int
countFibs = todo "2.5 count"


-- 2.6. Скользящее окно.
--
-- [1..6] `withWindow` 3 == [[1,2,3],[2,3,4],[3,4,5],[4,5,6]].
-- Длина каждого окна равна n; неполное последнее окно не включается.
-- Если n больше длины входа, результат []; если n <= 0, выбросьте error.
-- Функция должна позволять получить первые окна бесконечного списка.
-- Сигнатуру не меняйте.

withWindow :: [a] -> Int -> [[a]]
withWindow = todo "2.6"


-- 2.7. Сохраните проверенные опции в типе.
--
-- RawOptions пришёл с границы программы. True означает запрос справки:
-- формат и путь должны отсутствовать. False означает запуск:
-- формат обязателен, отсутствие пути означает Stdout.
-- Верните Just Options, если комбинация допустима, иначе Nothing.
-- После этого потребитель Options уже не проверяет сочетания полей.
-- Корректность содержимого FilePath в этом задании не проверяется.

data Format = Plain | JSON
  deriving (Eq, Show)

data Target = Stdout | File FilePath
  deriving (Eq, Show)

data Options = Help | Run Format Target
  deriving (Eq, Show)

data RawOptions = RawOptions Bool (Maybe Format) (Maybe FilePath)
  deriving (Eq, Show)

parseOptions :: RawOptions -> Maybe Options
parseOptions = todo "2.7"
