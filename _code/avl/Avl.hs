data Tree t = Empty | Leaf t | Node Int t (Tree t) (Tree t)

height :: Tree t -> Int
height Empty = error "height Empty"
height (Leaf _) = 0
height (Node h _ _ _) = h

smallest :: Tree t -> t
smallest Empty = error "smallest Empty"
smallest (Leaf x) = x
smallest (Node _ s _ _) = s

left, right :: Tree t -> Tree t
left  (Node _ _ a _) = a
left _ = error "only internal nodes have children"
right (Node _ _ _ b) = b
right _ = error "only internal nodes have children"

toList :: Tree t -> [t]
toList Empty = []
toList (Leaf x) = [x]
toList (Node _ _ a b) = toList a ++ toList b

node :: Tree t -> Tree t -> Tree t
node a b
  | abs (height a - height b) <= 1
    = Node (max (height a) (height b) + 1) (smallest a) a b
  | otherwise = error "unbalanced tree"

merge :: Tree t -> Tree t -> Tree t
merge Empty x = x
merge x Empty = x
merge a b
  | abs (height a - height b) <= 1
    = node a b
  | height a == height b - 2 && height (right b) == height b - 2
    -- the special case: [h-2] + {[h-1],[h-2]}
    = let (bl,br) = (left b, right b)
          (bll,blr) = (left bl, right bl)
      in node (node a bll) (node blr br)
  | height a < height b
    = merge (merge a (left b)) (right b)
  | otherwise
    = merge (left a) (merge (right a) b)

split :: Tree t -> (t->Bool) -> (Tree t, Tree t)
split Empty _ = (Empty, Empty)
split (Leaf x) isBig
  | isBig x   = (Empty, Leaf x)
  | otherwise = (Leaf x, Empty)

split (Node _ _ a b) isBig
  | isBig (smallest b)
    = let (a1,a2) = split a isBig
      in (a1, merge a2 b)
  | otherwise
    = let (b1,b2) = split b isBig
      in (merge a b1, b2)

contains :: Ord t => Tree t -> t -> Bool
contains a x =
  case split a (>=x) of
    (_, Empty) -> False
    (_, b) -> smallest b == x

insert :: Ord t => Tree t -> t -> Tree t
insert a x =
  let (a1, a2) = split a (>=x)
  in merge a1 (merge (Leaf x) a2)

delete :: Ord t => Tree t -> t -> Tree t
delete a x =
  let (b, _) = split a (>=x)
      (_, c) = split a (>x)
  in merge b c

fromList :: Ord t => [t] -> Tree t
fromList = foldl insert Empty
