---
title: "Balanced binary search trees: the easy way"
---
The task of balancing binary search trees has a reputation of being very hard to implement.
Data structure books usually list dozens of different cases, especially for deleting elements.

Let's change this - it's not that hard! The analysis will be a little involved, but the code is
going to be simple.

Here are some design choices:

* We'll implement AVL trees.
* All elements are stored in the leaves. This is unusual,
  people usually store values in internal nodes. But it makes things so much simpler!
* Internal nodes store a reference to the smallest (left-most) element of the sub-tree.
  This will be useful to guide us down the tree.
* Internal nodes also store the sub-tree height. AVL trees are usually described with nodes only
  storing the height difference of their children, but storing the height instead makes things easier still.
* We'll implement this in Haskell. We like algebraic data types for trees!
