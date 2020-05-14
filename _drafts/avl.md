---
title: "Balanced binary search trees: the easy way"
---
The task of balancing binary search trees has a reputation of being very hard to implement.
Data structure books usually list dozens of different cases, especially for deleting elements.

Let's change this - it's not that hard! The analysis will be a little involved, but the code is
going to be simple.

Here are some design choices:

* We'll implement AVL trees. These are binary trees where two sibling subtrees have heights differing
  by at most 1. This guarantees {% latex %} \Theta(\log n) {% endlatex %} depth.
* All elements are stored in the leaves. This is unusual,
  people usually store values in internal nodes. But it makes things so much simpler!
* Internal nodes store a reference to the smallest (left-most) element of the sub-tree.
  This will be useful to guide us down the tree.
* Internal nodes also store the sub-tree height. AVL trees are usually described with nodes only
  storing the height difference of their children, but storing the height instead makes things easier still.
* We'll implement this in Haskell. We like algebraic data types for trees!

![AVL tree](/assets/images/avl/avl_tree.png)

OK, let's get down to it!

## Preliminaries

Start by defining binary trees.

~~~ haskell
data Tree t = Empty | Leaf t | Node Int t (Tree t) (Tree t)
~~~

A tree of elements of type t is either empty, it is a leaf, or it is an internal node.
A leaf contains a value of type t.
An internal node contains: the height, the smallest element in the sub-tree, and the two children.

Write some helper functions:

~~~ haskell
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
~~~
