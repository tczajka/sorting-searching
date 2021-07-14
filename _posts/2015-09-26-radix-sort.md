---
title: "Radix sort: sorting integers (often) faster than std::sort."
---
This post will describe a very simple integer sorting algorithm: radix sort. Despite its simplicity,
it is a very practical algorithm. As we will see, even a simple implementation can easily outperform
std::sort from the C++ standard library.

It is also interesting theoretically, since its runtime complexity is in some cases better than
standard comparison-based sorting. As we'll see below, the run-time complexity for sorting n w-bit
integers is:

$$
\Theta\left(n \frac{w}{\log n}\right)
$$


## Algorithm

Suppose we start with an array of numbers such as this:

~~~
853, 872, 265, 238, 199, 772, 584, 204, 480, 173,
499, 349, 308, 314, 317, 186, 825, 398, 899, 161
~~~

Counter-intuively, we begin by sorting it based on the least significant decimal digit:

~~~
480, 161, 872, 772, 853, 173, 584, 204, 314, 265,
825, 186, 317, 238, 308, 398, 199, 499, 349, 899
~~~

Now, we sort it based on the middle decimal digit. But we take care that we do this in a **stable** fashion,
that is: for numbers that are tied on the middle digit, keep them in the current order.

~~~
204, 308, 314, 317, 825, 238, 349, 853, 161, 265,
872, 772, 173, 480, 584, 186, 398, 199, 499, 899
~~~

The numbers are now sorted by the last two digits. It is not hard to guess what we will do next. Once we have sorted them by the most significant digit, taking care not to change the order in case of ties, we will have sorted the array.

I haven't said **how** exactly we perform the sorting based on a single digit,
so let's do this last round slowly. We use count-sort. Here is how it works:

**Step 1.** Go through the data and count how many times each top digit appears.
0 appears 0 times, 1 appears 4 times, etc.:

~~~
count: 0, 4, 3, 5, 2, 1, 0, 1, 4, 0
~~~

**Step 2.** Compute prefix sums in `count`. This will give us, for each digit, the index of the first
entry with that digit in the final sorted order.

~~~
position: 0, 0, 4, 7, 12, 14, 15, 15, 16, 20
~~~

For instance, we now know that numbers starting with the digit 4 will begin at index 12.

**Step 3.** Shuffle the data. For each number, we simply place it directly at the correct `position`!
After placing a number we increment the `position` for the given digit.

~~~
X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X
position: 0, 0, 4, 7, 12, 14, 15, 15, 16, 20
X, X, X, X, 204, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X
position: 0, 0, 5, 7, 12, 14, 15, 15, 16, 20
X, X, X, X, 204, X, X, 308, X, X, X, X, X, X, X, X, X, X, X, X
position: 0, 0, 5, 8, 12, 14, 15, 15, 16, 20
X, X, X, X, 204, X, X, 308, 314, X, X, X, X, X, X, X, X, X, X, X
position: 0, 0, 5, 9, 12, 14, 15, 15, 16, 20
...
161, 173, 186, 199, 204, 238, 265, 308, 314, 317,
349, 398, 480, 499, 584, 772, 825, 853, 872, 899
~~~

**Step 4.** We have shuffled the data into a new, temporary array. Move it back to the original array. In practice, we can simply swap pointers here.

## Running time

Of course in practice we don't sort based on decimal digits. We could sort based on individual bits but we can do better than that. Sort based on **groups** of bits.

If we sort k bits at a time, there are $$2^k$$ possible "digits".
The `count` array will need to be of that length. Hence, let's make $$k \le \log_2 n$$,
so that the helper array isn't longer than the data being sorted.

For added performance, it may be useful to make k somewhat smaller than $$\log_2 n$$.
In our implementation below, we use $$k = \lfloor \frac{1}{3}\log_2 n \rfloor $$.
This increases the number of rounds 3-fold, but has several advantages that outweigh that:
* The count array only uses $$n^{1/3} $$ memory.
* Computing prefix sums in step 2 takes negligible time.
* Counting in step 1 doesn't randomly increment counters all over memory.
  It randomly increments counters in a tiny section of memory, which is good for cache performance.
* Shuffling in step 3 doesn't randomly write all over memory. It writes consecutively in only
  $$n^{1/3}$$ different locations at a time, which also improves cache performance.

For the purposes of analyzing asymptotic performance, we simply say: $$ k = \Theta(\log n)$$.

If the numbers being sorted have w bits, we have $$\Theta(\frac{w}{\log n}) $$ rounds.
Each round is done in $$\Theta(n)$$ time, hence the total running time of radix sort is:

$$
\Theta\left(n \frac{w}{\log n}\right)
$$

Note what this means. The larger the n, the less time we spend per element!
This is in contrast with comparison-based sorts, where we spend $$\Theta(\log n) $$
per element, which increases with n.

This indicates that there is a threshold: for small n it is better to use a comparison-based sort.
For large n, radix sort is better.

What is the threshold? It should be about when
$$\frac{w}{\log n} \approx \log n$$, that is, when
$$n \approx 2^{w^{1/2}}$$.

For instance, when w=64, $$n \approx 2^8 = 256$$ or so should be the threshold.
If n is significantly bigger than this, radix sort should start to dominate.

## C++ implementation

~~~ cpp
template<class T>
void radix_sort(vector<T> &data) {
  static_assert(numeric_limits<T>::is_integer &&
                !numeric_limits<T>::is_signed,
                "radix_sort only supports unsigned integer types");
  constexpr int word_bits = numeric_limits<T>::digits;

  // max_bits = floor(log n / 3)
  // num_groups = ceil(word_bits / max_bits)
  int max_bits = 1;
  while ((size_t(1) << (3 * (max_bits+1))) <= data.size()) {
    ++max_bits;
  }
  const int num_groups = (word_bits + max_bits - 1) / max_bits;

  // Temporary arrays.
  vector<size_t> count;
  vector<T> new_data(data.size());

  // Iterate over bit groups, starting from the least significant.
  for (int group = 0; group < num_groups; ++group) {
    // The current bit range.
    const int start = group * word_bits / num_groups;
    const int end = (group+1) * word_bits / num_groups;
    const T mask = (size_t(1) << (end - start)) - T(1);

    // Count the values in the current bit range.
    count.assign(size_t(1) << (end - start), 0);
    for (const T &x : data) ++count[(x >> start) & mask];

    // Compute prefix sums in count.
    size_t sum = 0;
    for (size_t &c : count) {
      size_t new_sum = sum + c;
      c = sum;
      sum = new_sum;
    }

    // Shuffle data elements.
    for (const T &x : data) {
      size_t &pos = count[(x >> start) & mask];
      new_data[pos++] = x;
    }

    // Move the data to the original array.
    data.swap(new_data);
  }
}
~~~

## Experiments

I generated arrays of random 64-bit integers and timed the time per element it takes to sort using
`std::sort` and `radix_sort`.

|------------------|
|n | `std::sort` | `radix_sort` |
|-:|------------:|-------------:|
| 10 | 3.3 ns | 284.2 ns |
| 100 | 6.1 ns | 91.6 ns |
| 1 000 | 19.3 ns | 59.8 ns |
| 10 000 | 54.8 ns | 46.8 ns |
| 100 000 | 66.9 ns | 40.1 ns |
| 1 000 000 | 81.1 ns  | 40.8 ns |
| 10 000 000 | 95.1 ns | 40.7 ns |
| 100 000 000 | 108.4 ns | 40.6 ns |

We see the effect as predicted: for `std::sort`, the running time per element increases with n,
for radix_sort it decreases with n. It's not exactly proportional and inversely proportional to
$$\log n$$
due to various effects (mostly cache sizes), but the trend is there.
Most importantly: for large n, radix_sort is clearly winning!

## Further optimizations

More optimizations are possible which can lead to improvements in performance. Some ideas:
* Optimize the number of rounds as a function of n. Taking $$\frac{1}{3} \log n$$
  bits at a time is a rough guess at what should work well.
* Currently we scan the data array twice in each iteration: once to count, a second time to shuffle.
  It can be reduced to a single scan: while shuffling based on the current digit, we could also be
  counting the next digit at the same time.

These tweaks might improve the algorithm by a constant factor. Some time in the future I will
describe how to get a better asymptotic running time. Until then!
