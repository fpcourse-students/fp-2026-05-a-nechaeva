-- | Примеры с практики 5. Здесь нет заданий.
module Examples where

data Tree a
  = Leaf a
  | Node (Tree a) a (Tree a)
  deriving (Eq, Show)

tree :: Tree Int
tree = Node (Leaf 1) 2 (Node (Leaf 3) 4 (Leaf 5))

height :: Tree a -> Int
height t = case t of
  Leaf _ -> 1
  Node l _ r -> 1 + max (height l) (height r)

transform :: (a -> b) -> Tree a -> Tree b
transform f t = case t of
  Leaf x -> Leaf (f x)
  Node l x r -> Node (transform f l) (f x) (transform f r)

leafCount :: Tree a -> Int
leafCount t = case t of
  Leaf _ -> 1
  Node l _ r -> leafCount l + leafCount r

-- Старые версии доступны после построения новых.
xs, ys, zs :: [Int]
xs = [3, 4]
ys = 1 : xs
zs = 2 : ys

-- Команды для make repl:
-- :t Examples.Node
-- :k Examples.Tree
-- height tree
-- transform (+ 10) tree
-- (xs, ys, zs)
