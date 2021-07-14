---
title: "How fast can we sort?"
---
We all know that we can sort n things in $$O(n \log n)$$ time and that is the best
we can do. Problem solved. Right? **Wrong!**

Sorting is a fascinating topic and I am planning a whole series of posts about it.
It also inspired the blog name.

Let's start with what most programmers already know.

## Classical sorting algorithms

$$O(n \log n)$$ sorting algorithms have been known for a very long time.
John von Neumann already implemented merge sort in 1945 on the EDVAC computer. We're talking about
a computer built out of vacuum tubes, with 1000 words of RAM, capable of performing 1000 operations
per second or so.

Later people discovered quicksort in 1962[^quicksort] and heapsort in 1964[^heapsort].
The only theoretical improvement here is that heapsort is in-place: it uses only $$O(1)$$
additional memory outside the array. Of course the heap-based priority queue is nice in its own right.

We can easily implement another $$O(n \log n)$$ sorting algorithm, AVL-sort, using
the code from my previous post on [AVL trees]({%link _posts/2015-04-21-avl.md%}). We just put all the
elements into an AVL tree, and the extract them back into a list:

~~~ haskell
avlSort :: Ord t => [t] -> [t]
avlSort = toList . fromList
~~~

## Lower bound for comparison-based sorting

Suppose that we restrict ourselves to performing only one operation on the elements we're sorting:
compare two of them to see which one is bigger. This is what we mean by "comparison-based sorting".

Every comparison operation returns a single yes or no answer. If we perform k such operations,
we can get $$2^k$$ different sequences of answers, and hence we can distinguish
between $$2^k$$ different permutations. Since there are $$n!$$
permutations of n elements, it follows that we need at least $$\log_2 (n!)$$
comparisons in the worst case (and also on average, which is slightly harder to see) to distinguish
between them all.

$$
\log_2 (n!) \ge \log_2 (n/2)^{n/2} = n/2 * (\log_2 n - 1) = \Theta(n \log n)
$$

So there you go. That's the proof of the lower bound.

**The significance of this lower bound has been overstated.** Why would you ever so restrict
yourself as to only use comparisons? You can do much more with numbers, or other objects that you'd
want to sort, than just compare two of them. You can add them, you can multiply them, you can index
arrays with them... All these other operations don't seem all that useful for sorting at first sight.
But it turns out they are useful! This is very unintuitive, and fascinating at the same time.

Again and again I have seen serious publications cite this result when it does not apply.
The claim is that n numbers can't be sorted faster than $$O(n \log n)$$.
For example, people will claim that it's impossible to compute convex hulls in 2D faster than
$$O(n \log n)$$, because that requires sorting coordinates.
As we will see in a moment, this claim is false. Numbers can actually be sorted faster than this!

## Faster sorting algorithms

Let's start talking about some asymptotically faster sorting algorithms.
What are some of the things we normally want to sort?

The first group is numbers: integers, rational numbers, floating-point real numbers, complex numbers...
OK maybe not complex numbers, they don't have any natural ordering.

The second group is sequences of characters or numbers, such as text strings (e.g. names) or big
multi-precision integers.

## Sorting integers

Important note here: we are talking about sorting integers that fit in a single machine word,
such as 64-bit integers on a 64-bit computer. In general, we will be talking about sorting w-bit
integers on a w-bit computer. This is not an artificial restriction: comparison-based sorting
algorithms need this as well. Well, we can allow a constant multiple, such as 2w-bit integers on
a w-bit computer. After all, we can implement operations on 2-word integers in $$O(1)$$
time. But we're not talking about huge, multiple-precision integers. If you want to sort million-bit
integers, you have to either find a 1000000-bit computer, or skip below to the section about sorting
strings and sequences.

Here is a summary of various algorithms for sorting integers.
I will be writing about some of them in my future posts.

| long ago | merge sort | $$O(n \log n)$$ |
| long ago | radix sort | $$O(n \frac{w}{\log n})$$ |
| 1977 | van Emde Boas[^boas] | $$O(n \log w)$$ |
| 1983 | Kirkpatrick, Reisch[^kirkpatrick] | $$O(n \log \frac{w}{\log n})$$ |
| 1995 | Andersson, Hagerup, Nilsson, Raman[^andersson] | $$O(n \log \log n)$$ |
| 2002 | Han, Thorup[^han] | $$O(n (\log \log n)^{1/2})$$ |

Some of these run-times depend on the word size w,
but the last two are clearly better than $$O(n \log n)$$,
independently of w.

## Is sorting integers in O(n) time possible?

This is the big open problem. Nobody knows.

Radix sort does it when n is big compared to the word size ($$\log n = \Omega(w)$$).

In their 1995 paper[^andersson], Andersson et al showed how to do this when n is small compared to
the word size ($$\log n = O(w^{1/2-\epsilon})$$).

This got slightly improved in 2014[^belazzougui]. Now we know how to sort in $$O(n)$$ time
when $$\log n = O\left(\sqrt{\frac{w}{\log w}}\right)$$.

## What about other kinds of numbers?

Real numbers are typically represented in a floating point format. This seems harder to handle than
integers, but it's really not. Floating point numbers are represented as two integers: an exponent
and a mantissa. For instance, the IEEE double-precision floating point format, the most common
representation out there, stores real numbers as an 11-bit exponent and a 52-bit mantissa.
The representation is: $$2^\text{exponent} * (1 + \text{mantissa} * 2^{-52})$$.
A number with a higher exponent is bigger than a number with a smaller exponent. For equal exponents,
the number with the bigger mantissa is bigger. So really, sorting these real numbers is equivalent to
sorting 63-bit integers!

Sorting rational numbers can also be reduced to sorting integers. If we have rational numbers
$$\frac{a}{b}$$,
where a and b are w-bit integers, compute $$\lfloor \frac{a}{b} \cdot 2^{2w} \rfloor$$ for each,
and sort the resulting 3w-bit integers. This works because the difference between two different
rationals $$\frac{a}{b}$$ and $$\frac{c}{d}$$ is always at least
$$\frac{1}{bd} > 2^{-2w}$$, so a precision
of 2w bits after the binary point is sufficient.

This is another reason sorting integers is an interesting topic: if we can sort integers, we can
sort all kinds of numbers.

## Sorting strings and sequences

The important thing to notice here is that we can't compare two elements in constant time any more in this case.
Therefore, merge-sort does not work in $$O(n \log n)$$ time. It can be shown that it
works in $$O(L \log n)$$ time, where L is the sum of lengths of the strings.

This too can be improved. In 1994, Andersson and Nillson[^strings] showed how to sort strings in
$$O(L + \text{(time to sort n characters)})$$ time.

If the alphabet is small
(such as ASCII), we can use count sort to sort the n characters, which gives time complexity
$$O(L + |\Sigma|)$$, where $$|\Sigma|$$ is the size of the alphabet.

If the alphabet is large, or we are sorting sequences of numbers, we can use one of the integer sorting algorithms and arrive at, say,
$$O(L + n \sqrt{\log \log n})$$ time.


## References

[^quicksort]: Hoare, Charles AR. "Quicksort." The Computer Journal 5.1 (1962): 10-16.
[^heapsort]: Williams, John William Joseph. "ALGORITHM-232-HEAPSORT." Communications of the ACM 7.6 (1964): 347-348.
[^boas]: van Emde Boas, Peter. "Preserving order in a forest in less than logarithmic time and linear space." Information processing letters 6.3 (1977): 80-82.
[^kirkpatrick]: Kirkpatrick, David, and Stefan Reisch. "Upper bounds for sorting integers on random access machines." Theoretical Computer Science 28.3 (1983): 263-276.
[^strings]: Andersson, Arne, and Stefan Nilsson. "A new efficient radix sort." Foundations of Computer Science, 1994 Proceedings., 35th Annual Symposium on. IEEE, 1994.
[^andersson]: Andersson, Arne, et al. "Sorting in linear time?." Proceedings of the twenty-seventh annual ACM symposium on Theory of computing. ACM, 1995.
[^han]: Han, Yijie, and Mikkel Thorup. "Integer sorting in $$O (n(\log \log n)^{1/2})$$ expected time and linear space." Foundations of Computer Science, 2002. Proceedings. The 43rd Annual IEEE Symposium on. IEEE, 2002.
[^belazzougui]: Belazzougui, Djamal, Gerth Stølting Brodal, and Jesper Sindahl Nielsen. "Expected Linear Time Sorting for Word Size $$\Omega(\log^2 n \log \log n)$$." Algorithm Theory–SWAT 2014. Springer International Publishing, 2014. 26-37.
