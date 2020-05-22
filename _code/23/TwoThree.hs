data Tree a =
    Empty
  | Leaf a
  | Node2 Int a (Tree a) (Tree a)          -- Node2 height smallest a b
  | Node3 Int a (Tree a) (Tree a) (Tree a) -- Node3 height smallest a b c

height :: Tree a -> Int
height (Leaf _) = 0
height (Node2 h _ _ _) = h
height (Node3 h _ _ _ _) = h

smallest :: Tree a -> a
smallest (Leaf x) = x
smallest (Node2 _ s _ _) = s
smallest (Node3 _ s _ _ _) = s

toList :: Tree a -> [a]
toList Empty = []
toList (Leaf x) = [x]
toList (Node2 _ _ a b) = toList a ++ toList b
toList (Node3 _ _ a b c) = toList a ++ toList b ++ toList c

-- combine children into a node
node2 :: Tree a -> Tree a -> Tree a
node2 a b = Node2 (height a + 1) (smallest a) a b

node3 :: Tree a -> Tree a -> Tree a -> Tree a
node3 a b c = Node3 (height a + 1) (smallest a) a b c

-- combine 2 to 4 trees of height h to make 1 or 2 trees of height h+1
levelUp :: [Tree a] -> [Tree a]
levelUp [a,b] = [node2 a b]
levelUp [a,b,c] = [node3 a b c]
levelUp [a,b,c,d] = [node2 a b, node2 c d]

-- Merge two nonempty trees.
-- Returns 1 or 2 trees of height = maximum height of the two trees.
mergeToList :: Tree a -> Tree a -> [Tree a]
mergeToList a b
  | height a < height b =
    case b of
      Node2 _ _ b1 b2 -> levelUp (mergeToList a b1 ++ [b2])
      Node3 _ _ b1 b2 b3 -> levelUp (mergeToList a b1 ++ [b2, b3])
  | height a > height b =
    case a of
      Node2 _ _ a1 a2 -> levelUp ([a1] ++ mergeToList a2 b)
      Node3 _ _ a1 a2 a3 -> levelUp ([a1,a2] ++ mergeToList a3 b)
  | otherwise = [a, b]

merge :: Tree a -> Tree a -> Tree a
merge a Empty = a
merge Empty b = b
merge a b =
  case mergeToList a b of
    [t] -> t
    [t, u] -> node2 t u

split :: (a -> Bool) -> Tree a -> (Tree a, Tree a)
split _ Empty = (Empty, Empty)

split f (Leaf x)
  | f x   = (Empty, Leaf x)
  | otherwise  = (Leaf x, Empty)

split f (Node2 _ _ a b)
  | f (smallest b) =
    let (a1,a2) = split f a in (a1, merge a2 b)
  | otherwise =
    let (b1,b2) = split f b in (merge a b1, b2)

split f (Node3 _ _ a b c)
  | f (smallest b) =
    let (a1,a2) = split f a in (a1, merge a2 (node2 b c))
  | f (smallest c) =
    let (b1,b2) = split f b in (merge a b1, merge b2 c)
  | otherwise =
    let (c1,c2) = split f c in (merge (node2 a b) c1, c2)

contains :: Ord a => Tree a -> a -> Bool
contains t x =
  case split (>= x) t of
    (_, Empty) -> False
    (_, t) -> smallest t == x

insert :: Ord a => Tree a -> a -> Tree a
insert t x =
  let (t1, t2) = split (>= x) t
  in t1 `merge` (Leaf x) `merge` t2

delete :: Ord a => Tree a -> a -> Tree a
delete t x =
  let (t1, t2) = split (>= x) t
      (_, t3) = split (>x) t2
  in merge t1 t3

fromList :: Ord a => [a] -> Tree a
fromList = foldl insert Empty

main :: IO ()
main = do
  let a = fromList [10, 5, 7, 18, 3]
  print (toList a)
  print (toList (insert a 4))
  print (toList (delete a 10))
  print (contains a 12)
  print (contains a 5)
