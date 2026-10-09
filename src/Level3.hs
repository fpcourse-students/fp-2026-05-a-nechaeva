-- | Домашка 5. Челлендж: персистентный массив на декартовом дереве.
module Level3 where

import Data.List (foldl')
import MetaUtils (todo)
import System.Random (mkStdGen, randoms)

-- 3.1. Декартово дерево по неявному ключу.
--
-- Порядок элементов задаётся симметричным обходом: левое поддерево, корень,
-- правое поддерево. treeSize — число вершин поддерева, treePriority — приоритет.
-- У родителя приоритет не меньше приоритетов детей (равенство разрешено).
-- split и merge уже написаны: прочитайте их и закончите четыре операции ниже.
-- Для работы с узлами используйте mkNode: он вычисляет размер из детей.
--
-- Индексы с нуля. Поиск вне [0, size t) даёт Nothing.
-- insert i x k t вставляет x ПЕРЕД элементом i с приоритетом k;
-- i < 0 означает начало, i >= size t означает конец.
-- remove t i удаляет элемент i; недопустимый индекс оставляет дерево прежним.
-- append t x k добавляет x в конец.
--
-- Сохраняйте старые версии дерева. Реализуйте операции через split/merge и
-- спуск по дереву, без преобразования всего дерева в список.
-- Время — O(h), где h — высота; при независимых случайных приоритетах
-- ожидаемая высота O(log n). Конкретные совпадения приоритетов не исключаются.

data DNode a = DNode
  { treeSize :: Int
  , treePriority :: Int
  , treeElem :: a
  , treeLeft :: DTree a
  , treeRight :: DTree a
  }
  deriving (Eq, Show)

type DTree a = Maybe (DNode a)

size :: DTree a -> Int
size Nothing = 0
size (Just t) = treeSize t

mkNode :: a -> Int -> DTree a -> DTree a -> DTree a
mkNode x k l r = Just (DNode (1 + size l + size r) k x l r)

empty :: DTree a
empty = Nothing

singleton :: a -> Int -> DTree a
singleton x k = mkNode x k empty empty

-- Первые k элементов слева, остальные справа. Границы зажимаются.
split :: Int -> DTree a -> (DTree a, DTree a)
split k t
  | k <= 0 = (empty, t)
  | k >= size t = (t, empty)
split _ Nothing = (empty, empty)
split k (Just t)
  | k <= size (treeLeft t) =
      let (l, r) = split k (treeLeft t)
      in (l, mkNode (treeElem t) (treePriority t) r (treeRight t))
  | otherwise =
      let (l, r) = split (k - size (treeLeft t) - 1) (treeRight t)
      in (mkNode (treeElem t) (treePriority t) (treeLeft t) l, r)

-- Все элементы l должны предшествовать элементам r.
merge :: DTree a -> DTree a -> DTree a
merge Nothing r = r
merge l Nothing = l
merge l@(Just lt) r@(Just rt)
  | treePriority lt >= treePriority rt =
      mkNode (treeElem lt) (treePriority lt) (treeLeft lt) (merge (treeRight lt) r)
  | otherwise =
      mkNode (treeElem rt) (treePriority rt) (merge l (treeLeft rt)) (treeRight rt)

infixl 9 !!?
(!!?) :: DTree a -> Int -> Maybe a
(!!?) = todo "3.1 lookup"

append :: DTree a -> a -> Int -> DTree a
append = todo "3.1 append"

insert :: Int -> a -> Int -> DTree a -> DTree a
insert = todo "3.1 insert"

remove :: DTree a -> Int -> DTree a
remove = todo "3.1 remove"

-- Подготовка входа для GHCi, не задача. Случайные приоритеты воспроизводимы:
-- treeOf не меняет глобальный генератор. Команда: t <- treeOf [10,20,30].
treeOf :: [a] -> IO (DTree a)
treeOf xs = pure $ foldl' (\t (x, k) -> append t x k) empty
  (zip xs (randoms (mkStdGen 42)))
