---
title: "Zero to the power of zero"
---

## The controversy

The value of 0<sup>0</sup> is controversial.

[Wikipedia](https://en.wikipedia.org/wiki/Zero_to_the_power_of_zero) says:

> Zero to the power of zero, denoted by 0<sup>0</sup>, is a mathematical expression with no agreed-upon value.
> The most common possibilities are 1 or leaving the expression undefined,
> with justifications existing for each, depending on context.

Mathematica and [WolframAlpha](https://www.wolframalpha.com/input/?i=0%5E0) refuse to compute the value.

Some textbooks on mathematical analysis, when defining exponentiation, explicitly leave 0<sup>0</sup> undefined
as an exception.

On the other hand, the [IEEE 754](https://en.wikipedia.org/wiki/IEEE_754) floating point standard specifies
that 0.0<sup>0.0</sup> = 1.0 and as a result, most programming languages implement it that way.

Spoiler: I will argue that the value of 1 is clearly "correct". Of course it's a matter of definition,
one can in theory define the operation to do anything, but it is "correct" in the sense that it is the only sensible
value, consistent with all applications, and moreover, it is a very important value. It is also
implicitly assumed to be 1 in various formulas even by those people who insist it should not be 1.

I will also show that the argument against defining 0<sup>0</sup> essentially relies on a mistake:
an incorrect algorithm for computing limits that is unfortunately often taught in schools. Refusal
to define 0<sup>0</sup> is a futile attempt to salvage the correctness of the algorithm, which however
does not actually solve the problem in general.

## Definition

The simplest way to resolve the issue seems to be to start with a definition, plug in zeroes, and see
what we get.

A **semigroup** is a set of objects with an associative multiplication operation. This is a very
general concept: it can be natural numbers, real numbers, square matrices, linear operators, all
kinds of things.

In any semigroup we can define exponentiation to any posive integral power:

{% latex centred %}
\begin{aligned}
x^1 &= x \\
x^{n+1} &= x^n \cdot x
\end{aligned}
{% endlatex %}

Often a semigroup has an identity element {%latex%}I{%endlatex%}
such that {% latex %}I\cdot x = x\cdot I = x{% endlatex %}.
For numbers, it's just the number 1. For matrices, it's the identity matrix.
Such a semigroup is called a **monoid**.

In a monoid we expand and simplify the definition of exponentiation to include the 0 exponent:

{% latex centred %}
\begin{aligned}
x^0 &= I \\
x^{n+1} &= x^n \cdot x
\end{aligned}
{% endlatex %}

Well, now just plug in x=0 into that definition and what do you get: 0<sup>0</sup> = 1.

This definition can then be extended to negative exponents, rational exponents, even irrational exponents.
But since we're only concerned with 0<sup>0</sup> here, we're not going to go further.

## The 0<sup>n</sup> function

Since 0<sup>n</sup> = 0 for all n > 0, one might think that the most natural thing to expect is
that it would also be true for n = 0. However we see from the definition that it is not so.

{% latex centred %}
0^n =
\begin{cases}
1 &\text{if } n = 0 \\
0 &\text{if } n > 0
\end{cases}
= [n=0]
{% endlatex %}

We have here used the [Iverson bracket](https://en.wikipedia.org/wiki/Iverson_bracket) notation.

This seems like a strangely complicated formula for 0<sup>n</sup>, but we will see that it is in fact
a very nice and useful function.

## Combinatorics

What is the number of sequences of n letters, selected from an alphabet of size A? It's A<sup>n</sup>.

What if the alphabet is empty, A=0? Then the number of sequences is:
{% latex centred %}
0^n = [n = 0] =
\begin{cases}
1 &\text{if } n = 0 \\
0 &\text{if } n > 0
\end{cases}
{% endlatex %}

Does this make sense? Yes! If n > 0, we can't form a sequence, because
we will get stuck when trying to write the first letter. But when n=0, there is no problem! We don't
have to write any letters, so it's fine if the alphabet is empty. There is exactly one way to do it:
write an empty sequence of letters.

## The exp function

The exponential function has the following basic property, often taken to define exp in the first place:

{% latex centred %}
\exp x = \sum_{n=0}^{\infty} \frac{x^n}{n!}
{% endlatex %}

Let's plug in x=0:

{% latex centred %}
\exp 0 = \sum_{n=0}^{\infty} \frac{0^n}{n!} = \sum_{n=0}^{\infty} \frac{[n=0]}{n!} = \frac{1}{0!} = 1
{% endlatex %}

The 0<sup>n</sup> function played an essential role in this calculation.

## The binomial distribution

The binomial distribution is a probability distribution of the number of successes in n independent
trials, each successful with probability p. The formula is:

{% latex centred %}
\Pr(X = k) = \binom{n}{k}p^k(1-p)^{n-k}
{% endlatex %}

What if p=0?

{% latex centred %}
\begin{aligned}
\Pr(X = k) &= \binom{n}{k}0^k1^{n-k} = \binom{n}{k}[k=0] = [k=0] \\
&=
\begin{cases}
1 &\text{if } k = 0 \\
0 &\text{if } k > 0
\end{cases}
\end{aligned}
{% endlatex %}

This makes sense! k=0 successes is certain, any other outcome is impossible.

## Even-cardinality subsets

Given a set of n elements, how many more even-cardinality subsets are there than odd-cardinality subsets?

We can calculate it like this:
{% latex centred %}
\begin{aligned}
\sum_{k=0}^n \binom{n}{k}(-1)^k &= \sum_{k=0}^n \binom{n}{k}(-1)^k1^{n-k} = (-1 + 1)^n = 0^n \\
&=
\begin{cases}
1 &\text{if } n = 0 \\
0 &\text{if } n > 0
\end{cases}
\end{aligned}
{% endlatex %}

And indeed, for n=0 we have 1 even-cardinality subset (the empty set), and no odd-cardinality subsets,
while for n>0 there are as many even as odd cardinality subsets.

## Möbius function

The [Möbius function](https://en.wikipedia.org/wiki/M%C3%B6bius_function) {% latex %}\mu(n){% endlatex %}
is a useful [multiplicative function](https://en.wikipedia.org/wiki/Multiplicative_function) in number theory.

One important property of it concerns sums over divisors of a positive integer n:

{% latex centred %}
S(n) = \sum_{d|n} \mu(d)
{% endlatex %}

It can be shown that since μ is multiplicative, S is also multiplicative.

Also for prime p and α > 0:
{% latex centred %}
S(p^\alpha) = \mu(1) + \mu(p) + \mu(p^2) + \ldots + \mu(p^\alpha) = 1 - 1 + 0 + \ldots + 0 = 0
{% endlatex %}

Let's factor n into prime numbers:
{% latex centred %}
n = \prod_{i=1}^{k} p_i^{\alpha_i}
{% endlatex %}

and then we have:
{% latex centred %}
\begin{aligned}
S(n) &= S\left(\prod_{i=1}^{k} p_i^{\alpha_i}\right) = \prod_{i=1}^k S(p_i^{\alpha_i}) = \prod_{i=1}^k 0 = 0^k
= [k=0] = [n=1] \\
&= \begin{cases}
1 &\text{if } n = 1 \\
0 &\text{if } n > 1
\end{cases}
\end{aligned}
{% endlatex %}

## Fractional exponents

What about the 0<sup>x</sup> function for **real** (rather than natural) exponents {% latex %}x \ge 0{% endlatex %}?

Some people argue that while the case for 0<sup>n</sup>=[n=0] is convincing, the case for 0<sup>x</sup>=[x=0]
is less convincing, and 0<sup>0</sup> should only be defined for the integral exponent 0, and left undefined
for the real exponent 0.0.

I have three ways to answer that.

### Natural numbers are real numbers

A ubiquitous convention in mathematics is that natural numbers are a subset of integer
numbers, which in turn are a subset of rational numbers, which are a subset of real numbers.

{% latex centred %}
\mathbb{N} \subset \mathbb{Z} \subset \mathbb{Q} \subset \mathbb{R}
{% endlatex %}

This lets us mix an match integers with rational numbers and irrational numbers in expressions
without having to worry about converting between these types.

If so, it makes no sense to say that 0<sup>0</sup>=1 but 0<sup>0.0</sup> is undefined, because
the natural number 0 is the same number as the real number 0.0.

One reason to doubt this is how numbers are constructed from sets in set theory. Natural numbers
are constructed first. Then integers are constructed as equivalence classes of pairs of natural numbers.
Similarly rational numbers are then constructed as equivalence classes of pairs of integers. Finally real
numbers are constructed from rational numbers using Dedekind cuts or Cauchy sequences.

If we literally follow such a construction, then indeed the natural number 0, the integer 0,
the rational number 0, and the real number 0 will be four different objects. However, there is
an easy fix. When constructing integers as certain equivalence classes of pairs of natural numbers,
we can simply replace the non-negative integers with the actual natural numbers. Similarly, we can
replace the "integral rationals" with actual integers, and "rational reals" with the actual rationals.
After we do that, the 0 number is the same object belonging to all four sets.

### Consistency is good

Even if one were to treat integers as disjoint from reals, it would be nice to know that if
the notation a<sup>b</sup> means something for integers a and b, then it also means the equivalent
thing for the real equivalents of a and b. Technically what it means is that it would be nice if the integer-to-real
mapping was a homomorphism for the a<sup>b</sup> operation.

Otherwise, if the notation changed meaning between the "integer context" and "real context", we would have to be
extremely careful about which context we are in! And it wouldn't be clear from notation such as
x<sup>0</sup>. It would be a mess. We don't want notation to be ambiguous.

### 0<sup>x</sup> is sometimes useful for fractional exponents

What is the (right-sided) derivative of {% latex %}x^p{% endlatex %} at x = 0 for {%latex%}p\ge 1{%endlatex%}?
Let's calculate:

{% latex centred %}
\begin{aligned}
\left.{\frac{d}{dx}x^p}\right\vert_{x=0} &= \left.{p x^{p-1}}\right\vert_{x=0} = p\cdot 0^{p-1} = p[p=1] = [p=1] \\
&= \begin{cases}
1 &\text{if } p = 1 \\
0 &\text{if } p > 1
\end{cases}
\end{aligned}
{% endlatex %}

And indeed this is correct! The derivative at x = 0 is 1 for p = 1, and 0 for p > 1. The derivative
at 0 discontinuously "jumps" from 0 to 1 as soon as we increase the exponent p even slightly above 1.

## The naive limit algorithm

Given all these nice uses of 0<sup>0</sup> = 1, why do some people resist defining it like this?

The only reason I have seen has to do with what I call the "naive limit algorithm".

Suppose we want to calculate this limit:
{% latex centred %}
\lim_{n\to\infty} \left(n^2 3^{-n}\right)^{1/n}
{% endlatex %}

The argument goes that somebody could calculate it like this:
{% latex centred %}
\lim_{n\to\infty} n^2 3^{-n} = 0 \\
\lim_{n\to\infty} \frac{1}{n} = 0 \\
\lim_{n\to\infty} \left(n^2 3^{-n}\right)^{1/n} = 0^0 = 1
{% endlatex %}

Which would give an incorrect answer. The correct answer is 1/3.

However, the mistake is not in the step 0<sup>0</sup> = 1. The mistake already happened in the
previous step, where we simplified the limit to 0<sup>0</sup>.

A common (incorrect) thinking about this is: we allow calculating limits separately for
sub-expressions only if the resulting expression makes sense.
If it does not make sense, then doing that is not allowed. If only we declare that 0<sup>0</sup> is not a valid
expression, the reduction to 0<sup>0</sup> will not be allowed, so it solves the problem. If however
we do define 0<sup>0</sup> to mean something, the reduction would be allowed.

That's what I call the "naive limit algorithm". It doesn't work.

Let's apply the same algorithm to a different limit:
{% latex centred %}
\lim_{n\to\infty} 10 + \frac{1}{n} = 10 \\
\lim_{n\to\infty} \left\lceil{10 + \frac{1}{n}}\right\rceil = \lceil 10 \rceil = 10
{% endlatex %}

There is an error here. The correct value of the last limit is not 10, it is 11. But this time we can't fix it the same
way: we can't say "let's just leave {% latex %}\lceil 10 \rceil{%endlatex %} undefined".
Everybody agrees that is a valid expression and has to be defined!

The naive limit algorithm simply doesn't always work.

In general, the algorithm can be described as follows. If:
{% latex centred %}
\lim_{n\to\infty} a_n = a \\
\lim_{n\to\infty} b_n = b \\
\lim_{n\to\infty} c_n = c \\
\ldots
{% endlatex %}
and {%latex%}f(a, b, c, \ldots) {% endlatex %} is a valid expression, then:

{% latex centred %}
\lim_{n\to\infty} f(a_n, b_n, c_n, \ldots) = f(a, b, c, \ldots)
{% endlatex %}

Is this true? It's not always true! What we wrote here is precisely the definition of continuity
of f at the point (a, b, c, ...). Some functions are not continuous!

Therefore the appropriate condition shouldn't have been "{%latex%}f(a, b, c, \ldots) {% endlatex %} is a valid expression", it should have been "f is continuous at (a, b, c, ...)".

Well, x<sup>y</sup> is simply not continuous at (0, 0). As we saw, even 0<sup>x</sup>
is not continuous at 0. It's inherently so, it reflects deep mathematical reality.

Refusing to define the operation there doesn't
really help the situation at all. If we don't define it at (0, 0), it's still not going to be continuous there,
 it would not even be defined there, which is worse! We can't use the naive limit algorithm at that point either way.

## Conclusion

I think we should just all agree that:
{%latex centred %}
0^0 = 1
{%endlatex %}

It follows directly from definitions, and it's a nice and consistent and useful property
of exponentiation. There is no convincing reason to make an exception.

Let me know what you think!
