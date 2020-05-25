---
title: "Static perfect hashing in minimal memory"
---
Sometimes we want to build a **static** dictionary data structure. This is when we have a set of data
that doesn't have to change dynamically. When it changes, we can just rebuild the dictionary from
scratch. So we first build the data structure, and then perform lookups without changing it any more.

Example scenarios where we might want to do this:
* Spell-checker. We have a set of words that doesn't change, and want to perform lookups to see if
  a word is spelled correctly.
* Search engine. We periodically scan a set of web pages and build an index containing all the words,
  with links to the pages. Once the index is built, we don't change it, until we do a new full scan.

What we would optimally want is:
1. Linear time build time in expectation. So for {% latex %}n{% endlatex %} elements of size {% latex %}S{% endlatex %}
   words each, we want to be able to build the
   data structure in {% latex %}O(nS){% endlatex %} expected time. If elements are of constant size, this is
   {% latex %}O(n){% endlatex %} time.
2. Guaranteed quick access time to all elements. We want {% latex %}O(S){% endlatex %} time per access.
   If the element size is constant, this is constant time.
3. Very little memory overhead. We are aiming for memory use of {% latex %}nS + o(n){% endlatex%}.
   Note that {% latex %}nS{% endlatex %} is just the space required to store the elements. So this means that
   for large {% latex %}n{% endlatex %} the fraction of extra memory required for bookkeeping is small
   compared to the actual data.

As usual, we are using the "word RAM" model. What we mean by a "word" is a piece of memory that can
store a pointer or a number in the range of 0 to {%latex%}n{%endlatex%}. So a word has at least
{%latex%}\log n{%endlatex%} bits. Note that if we have {%latex%}n{%endlatex%} distinct elements to store
in the hash table, they necessarily have at least {%latex%}\log n{%endlatex%} bits each, or else
they couldn't be distinct.

For a while it was an open problem whether such a data structure (or even just properties 1 and 2)
is even possible. In 1984 Fredman, Komlós, Szemerédi[^fks] described a data structure that does this.

One could try to just use a regular hash table with [universal hashing]({% link _posts/2020-05-21-hashing.md %}).
It sort-of works, but it fails properties 2 and 3. We get constant access time, but only in expectation.
No matter how many hash functions we try, there will almost surely be some buckets that have more than
a few entries in them. In fact it can be shown that if you use a completely random hash function to
store {%latex%}n{%endlatex%} elements in {%latex%}n{%endlatex%} buckets,
then with high probability the largest bucket will have {% latex %}\Theta(\log n / \log \log n){% endlatex %} entries.
A few customers could get angry that their queries are always slow! We don't want that. We would also have
significant overhead to store all the buckets and pointers.

## Guaranteeing worst case access time

Start by defining a family of [universal hash functions]({% link _posts/2020-05-21-hashing.md %})
such that the probability of a collision when hashing into a random of {%latex%}m{%endlatex%} is bounded
by {%latex%} c/m {%endlatex%} for some constant {%latex%}c{%endlatex%}. Normally {%latex%}c{%endlatex%}
can be made close to 1.

Now let's create {%latex%}n{%endlatex%} buckets and randomly select a hash function {%latex%}H{%endlatex%}
that maps elements to those buckets. The expected number of collisions,
i.e. the count of pairs of data elements that hash to the same bucket, is bounded by:

{% latex centred %}
\sum_{0 \le i < j < n} \Pr(H(x_i) = H(x_j)) \le \binom{n}{2} \frac{c}{n} < \frac{n^2}{2} \frac{c}{n} = \frac{c}{2} n
{% endlatex %}

The probability that the number of collisions exceeds twice the expectation, i.e. {% latex %}cn{% endlatex %},
is at most 50% (otherwise the expected value would be larger). If that happens, we just try again and pick a different
{%latex%}H{%endlatex%}. It will take on average at most 2 tries to get a valid {%latex%}H{%endlatex%}.

Thus we have at most {%latex%}cn{%endlatex%} collisions.

Let {%latex%}b_k{%endlatex%} be the number of elements in bucket {%latex%}k{%endlatex%}. Then the
number of collisions can also be expressed as:

{% latex centred %}
\sum_{k=0}^{n-1} \binom{b_k}{2} \le cn
{% endlatex %}

## Eliminating memory overhead

## References

[^fks]: Fredman, Michael L., János Komlós, and Endre Szemerédi. ["Storing a sparse table with O(1) worst case access time."](https://dl.acm.org/doi/abs/10.1145/828.1884) Journal of the ACM (JACM) 31.3 (1984): 538-544.
