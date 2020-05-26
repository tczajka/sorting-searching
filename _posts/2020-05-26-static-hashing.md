---
title: "Static perfect hashing in minimal memory"
---
Sometimes we want to build a **static** dictionary data structure. This is when we have a set of data
that doesn't have to change dynamically. When it changes, we can just rebuild the dictionary from
scratch. So we first build the data structure, and then perform lookups without changing it any more.

Example scenarios where we might want to do this:
* Spell checker. We have a set of words that doesn't change, and want to perform lookups to see if
  a word is spelled correctly.
* Search engine. We periodically crawl a lot of web pages and build an index containing all the words,
  with links to the pages. Once the index is built, we don't change it, until we do a new crawl again

What we want is:
1. Linear build time in expectation. So for {% latex %}n{% endlatex %} elements of size {% latex %}S{% endlatex %}
   words each, we want to be able to build the
   data structure in {% latex %}O(nS){% endlatex %} expected time. If elements are of constant size, this is
   {% latex %}O(n){% endlatex %} time.
2. **Guaranteed** quick access time to all elements. We want {% latex %}O(S){% endlatex %} time per access.
   If the element size is constant, this is {% latex %}O(1){% endlatex %} time.
3. Not much memory overhead. We are aiming for memory use of {% latex %}nS + o(n){% endlatex%}.
   Note that {% latex %}nS{% endlatex %} is just the space required to store the elements. So this means that
   for large {% latex %}n{% endlatex %} the fraction of extra memory required for bookkeeping is small
   compared to the actual data.

As usual, we are using the "word RAM" computational model. What we mean by a "word" is a piece of memory that can
store a pointer or a number in the range of 0 to {%latex%}n{%endlatex%}. So a word has at least
{%latex%}\log n{%endlatex%} bits. Note that if we have {%latex%}n{%endlatex%} distinct elements to store
in the hash table, they necessarily have at least {%latex%}\log n{%endlatex%} bits each, or else
they couldn't be distinct.

For a while it was an open problem whether such a data structure (or even just properties 1 and 2)
is even possible. In 1984 Fredman, Komlós, Szemerédi[^fks] described a data structure that does this.

One could try to just use a regular hash table with [universal hashing]({% link _posts/2020-05-21-hashing.md %}).
It sort of works, but it fails properties 2 and 3. We get constant access time, but only in expectation.
No matter how many hash functions we try, there will almost surely be some buckets that have more than
a few entries in them. In fact it can be shown that if we use a completely random hash function to
store {%latex%}n{%endlatex%} elements in {%latex%}n{%endlatex%} buckets,
then with high probability the largest bucket will have {% latex %}\Theta(\log n / \log \log n){% endlatex %} entries.
For universal hashing it could be a lot worse.
A few customers could get angry that their queries are always slow! We don't want that. We would also have
significant memory overhead to store all the buckets and pointers.

## Guaranteeing worst case access time

Start by defining a family of [universal hash functions]({% link _posts/2020-05-21-hashing.md %})
such that the probability of a collision when hashing into {%latex%}m{%endlatex%} buckets is bounded
by {%latex%} c/m {%endlatex%} for some constant {%latex%}c{%endlatex%}. Normally we can make
{%latex%}c \approx 1{%endlatex%}.

Now let's create {%latex%}n{%endlatex%} buckets and randomly select a hash function {%latex%}H{%endlatex%}
that maps elements to those buckets. The expected number of collisions,
i.e. the number of pairs of data elements that hash to the same bucket, is bounded by:

{% latex centred %}
\sum_{0 \le i < j < n} \Pr(H(x_i) = H(x_j)) \le \binom{n}{2} \frac{c}{n} < \frac{n^2}{2} \frac{c}{n} = \frac{cn}{2}
{% endlatex %}

The probability that the number of collisions exceeds twice the expectation, i.e. {% latex %}cn{% endlatex %},
is at most 50% (otherwise the expected value would be larger). If that happens, we just try again and pick a different
{%latex%}H{%endlatex%}. It will take on average 2 tries to get a valid {%latex%}H{%endlatex%}.

Thus we have at most {%latex%}cn{%endlatex%} collisions.

Let {%latex%}b_i{%endlatex%} be the number of elements in bucket {%latex%}i{%endlatex%}. Then the
number of collisions can also be expressed as:

{% latex centred %}
\sum_{i=0}^{n-1} \binom{b_i}{2} \le cn
{% endlatex %}

Now comes the main trick: in each bucket let's make another, second-level mini hash table!

![simple static hashing](/assets/images/static-hashing/simple.png)

We size a given secondary table based on its number of elements. Make it
{% latex %}\max\left(2c\binom{b_i}{2}, 1\right) = \max(cb_i(b_i-1), 1){% endlatex %} (note that this is quadratic
in the number of elements).
Select a random hash function {% latex %}h_i{% endlatex %}. We want **no collisions** in the second
level hash table.

The expected number of collisions in a given second level hash table is bounded by:

{% latex centred %}
\binom{b_i}{2} \frac{c}{\max\left(2c\binom{b_i}{2},1\right)} \le \frac{1}{2}
{% endlatex %}


So with probability at least 50% we don't get any collision at all! In case we get a collision, just
try a different {% latex %}h_i{% endlatex %}. After an average of 2 attempts we will get zero collisions
in that table.

So we don't need any secondary collision resolution method. Just store pointers
to elements directly in mini-buckets.

A lookup is now constant time:
1. Calculate {% latex %}i = H(x){% endlatex %}
2. Calculate {% latex %}j = h_i(x){% endlatex %}
3. The element, if it exists, will be in bucket {% latex %}i{%endlatex%}, entry {% latex %}j{% endlatex %}.

Total space used for second level hash tables is:
{% latex centred %}
\sum_{i=0}^{n-1} \max\left(2c\binom{b_i}{2}, 1\right) \le
2c\sum_{i=0}^{n-1}\binom{b_i}{2} + n \le 2c \cdot cn + n = (2c^2+1)n = O(n)
{% endlatex %}

Memory overhead is therefore {% latex %}\Theta(n){%endlatex%}. It is not negligible, especially
if the actual data elements are small.

## Compression

Now we are aiming to reduce the memory overhead to {% latex %}o(n){% endlatex %}, i.e. something
that is relatively small for large n.

First, let's **increase** the number of main buckets by a factor of {% latex %}z{% endlatex %}
(to be determined later), so we have {% latex %}zn{% endlatex %} buckets. Seems like this will only
make it worse, but bear with me. We will pack them really tightly!

The expected number of collisions is now smaller:

{% latex centred %}
\sum_{i=0}^{zn-1} \binom{b_i}{2} \le \binom{n}{2} \frac {c}{zn} < \frac{n^2}{2} \frac{c}{zn} = \frac{cn}{2z}
{% endlatex %}

Again, we make sure that we don't get more than twice that, i.e. {%latex%}cn/z{%endlatex%}. If we
do, just try a different hash function {% latex %}H{% endlatex %}.

If {% latex %}b_i = 1{% endlatex %}, we are not going to have a second level hash table. Instead,
we will store a pointer to the element directly in the main bucket.

For {% latex %}b_i \ge 2{% endlatex %}, we make a second level hash table of size
{% latex %}2c\binom{b_i}{2} = cb_i(b_i-1){% endlatex %}. This again means that we can easily get zero collisions
in each such table.

The total size of all second level hash tables (and thus also the number of such tables) is bounded by:

{% latex centred %}
\sum_{i=0}^{zn-1} 2c\binom{b_i}{2} < 2c \frac{cn}{z} = 2c^2 \frac{n}{z} = O\left(\frac{n}{z}\right)
{% endlatex %}

![compressed table 1](/assets/images/static-hashing/compressed1.png)

Now let's put all the data elements into a dedicated array. Order them so that the ones that appear
in single-element buckets are ordered first, in the same order as they
appear in the buckets. Also put all the secondary table hash functions and pointers into a separate array,
again in the same order
as they appear in main buckets. In the main bucket table we just need to store
what kind of entry it is (none, single element, or secondary table), and an index into the appropriate array.

![compressed table 2](/assets/images/static-hashing/compressed2.png)

Finally, we group the main buckets into groups of size {% latex %}g{% endlatex %}.
In each group we store just one index of the first single element in the group (if any), and one index
of the first secondary table in the group (if any). In each individual bucket we just store an offset
from those. The above bucket table now looks like this:

![compressed table 3](/assets/images/static-hashing/compressed3.png)

There are {% latex %}zn/g{% endlatex %} groups.
In each group, we need 2 words for the first element index and the first table index, for a total
of {% latex %}2zn/g{% endlatex %} words.

We also have
{% latex %}zn{% endlatex %} individual buckets. Each bucket has the type of bucket (there are 3 types,
so 2 bits), and an offset. However, those offsets are small, between 0 and {% latex %}g{% endlatex %}.
So buckets only need {% latex %}2 + \log g{% endlatex %} bits each. We can pack them into
{% latex %}O(zn \log g / \log n){%endlatex%} words, because we know we can fit {% latex %}\log n{% endlatex %}
bits in a word.

The total space usage for all the elements, all the secondary tables, and all the buckets is therefore:

{% latex centred %}
nS + O\left(\frac{n}{z} + \frac{zn}{g} + \frac{zn\log g}{\log n}\right)
{% endlatex %}

Now we'll pick {%latex%}g{%endlatex%} and {%latex%}z{%endlatex%} to make this as small as possible.
Start with the group size {%latex%}g{%endlatex%}. We want the last two terms to be approximately equal, which
means {% latex %}g\log g \approx \log n{%endlatex%}, or {% latex %}g=\Theta(\log n / \log \log n){% endlatex %}.

This makes the memory usage:

{% latex centred %}
nS + O\left(\frac{n}{z} + \frac{zn\log \log n}{\log n}\right)
{% endlatex %}

Finally optimize the number of buckets {% latex %}zn{% endlatex %}. Again we want the
two terms to be approximately equal, or {% latex %}z = \Theta(\sqrt{\log n / \log \log n}){%endlatex%}.

The final memory usage then is:

{% latex centred %}
nS + O\left(n \sqrt{\frac{\log \log n}{\log n}}\right) = nS + o(n)
{% endlatex %}

Asymptotically smaller than linear overhead! Just as we wanted.


## References

[^fks]: Fredman, Michael L., János Komlós, and Endre Szemerédi. ["Storing a sparse table with O(1) worst case access time."](https://dl.acm.org/doi/abs/10.1145/828.1884) Journal of the ACM (JACM) 31.3 (1984): 538-544.
