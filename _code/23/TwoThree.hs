data Tree t =
    Empty
  | Leaf t
  | Node2 Int t (Tree t) (Tree t)          -- Node2 height smallest a b
  | Node3 Int t (Tree t) (Tree t) (Tree t) -- Node3 height smallest a b c

height :: Tree t -> Int
height (Leaf _) = 0
height (Node2 h _ _ _) = h
height (Node3 h _ _ _ _) = h

smallest :: Tree t -> t
smallest (Leaf x) = x
smallest (Node2 _ s _ _) = s
smallest (Node3 _ s _ _ _) = s

-- combine children into a node
node2 :: Tree t -> Tree t -> Tree t
node2 a b = Node2 (height a + 1) (smallest a) a b

node3 :: Tree t -> Tree t -> Tree t -> Tree t
node3 a b c = Node3 (height a + 1) (smallest a) a b c

-- combine 2 to 4 trees of height h to make 1 or 2 trees of height h+1
levelUp :: [Tree t] -> [Tree t]
levelUp [a,b] = [node2 a b]
levelUp [a,b,c] = [node3 a b c]
levelUp [a,b,c,d] = [node2 a b, node2 c d]

-- Merge two nonempty trees.
-- Returns 1 or 2 trees of height = maximum height of the two trees.
mergeToSameHeight :: Tree t -> Tree t -> [Tree t]
mergeToSameHeight a b
  | height a < height b =
    case b of
      Node2 _ _ b1 b2 -> levelUp (mergeToSameHeight a b1 ++ [b2])
      Node3 _ _ b1 b2 b3 -> levelUp (mergeToSameHeight a b1 ++ [b2, b3])
  | height a > height b =
    case a of
      Node2 _ _ a1 a2 -> levelUp ([a1] ++ mergeToSameHeight a2 b)
      Node3 _ _ a1 a2 a3 -> levelUp ([a1,a2] ++ mergeToSameHeight a3 b)
  | otherwise = [a, b]

merge :: Tree t -> Tree t -> Tree t
merge a Empty = a
merge Empty b = b
merge a b =
  case mergeToSameHeight a b of
    [t] -> t
    [t, u] -> node2 t u

split :: (t -> Bool) -> Tree t -> (Tree t, Tree t)
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

contains :: Ord t => Tree t -> t -> Bool
contains a x =
  case split (>= x) a of
    (_, Empty) -> False
    (_, a2) -> smallest a2 == x

insert :: Ord t => Tree t -> t -> Tree t
insert a x =
  let (a1, a2) = split (>= x) a
  in a1 `merge` (Leaf x) `merge` a2

delete :: Ord t => Tree t -> t -> Tree t
delete a x =
  let (a1, a2) = split (>= x) a
      (_, a3) = split (>x) a2
  in merge a1 a3

fromList :: Ord t => [t] -> Tree t
fromList = foldl insert Empty

prepend :: Tree t -> [t] -> [t]
prepend Empty xs = xs
prepend (Leaf x) xs = x : xs
prepend (Node2 _ _ a b) xs = prepend a (prepend b xs)
prepend (Node3 _ _ a b c) xs = prepend a (prepend b (prepend c xs))

toList :: Tree t -> [t]
toList a = prepend a []

main :: IO ()
main = do
  let a = fromList [10, 5, 7, 18, 3]
  print (toList a)
  print (toList (insert a 4))
  print (toList (delete a 10))
  print (contains a 12)
  print (contains a 5)
