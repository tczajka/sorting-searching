---
title: "How to pick a hash function, part 2"
---

In [part 1]({% link _posts/2020-05-21-hashing.md %}) we discussed universal hashing and introduced
a classic family of universal hash functions, the Carter-Wegman hash function for integers and its
generalizations for bigger data structures.

While that works fine, there is a simpler way that is equally good. We don't need to deal with
prime numbers and modulo, we can make do with just multiplications, additions and bit shifts, and
get an equally good universal hash function family!

## Hashing integers

We want a function that hashes a w-bit integer into m bits ({% latex %}m \le w{% endlatex %}).

Philipp Wölfel[^wolfel] defined the following function in his Ph.D. thesis:

Pick two random w-bit integers a and b, with odd a. Then use:

{% latex centred %}
h_1(x) = (ax + b) \bmod 2^w \text{ div } 2^{w-m}
{% endlatex %}

In other words: compute {% latex %}ax+b{% endlatex %}, ignore overflow, and take the top m bits.
Can't get much simpler than this!

Incredibly this is a universal hash function family with optimal collision rate. For any pair of
different x and y, the probility of collision is {% latex %}\Pr(h_1(x) = h_1(y)) \le 2^{-m} {% endlatex %}.

In C:

~~~c
unsigned hash(unsigned x, int m) {
  return (a * x + b) >> (w - m);
}
~~~

## Hashing bigger data

Now suppose we have a bigger data structure consisting of n w-bit words, {% latex %}(x_1, \ldots, x_n){% endlatex %}.

Pick random 2w-bit numbers {% latex %}a_1, \ldots, a_n, b{% endlatex %} and use:

{% latex centred %}
h_2(x_1,\ldots,x_n) = (a_1x_1 + \ldots + a_nx_n + b) \bmod 2^{2w} \text{ div } 2^{2w-m}
{% endlatex %}

There is an extra optimization possible - we can replace some multiplications by additions by
taking input numbers in pairs. Suppose n is even.

{% latex centred %}
h_3(x_1,\ldots,x_n) =
((x_1 + a_2)(x_2 + a_1) + \ldots + (x_{n-1} + a_n)(x_n + a_{n-1}) + b)
  \bmod 2^{2w} \text{ div } 2^{2w-m}
{% endlatex %}

Both of these hash functions are universal and guarantee collision probability of at most
{% latex %}2^{-m}{% endlatex %} for any given two inputs.  

## Proof for h<sub>1</sub>

Wölfel[^wolfel] has a rather complicated proof in his thesis of the collision probability, but we
can see this in a simpler way.

First we need a little lemma:

Lemma: If r is an odd number, then {% latex %}f(x) = rx \bmod 2^w{% endlatex %} is a 1-1 correspondence
between w-bit numbers. It also maps odd numbers to odd numbers.

Proof: If {% latex %}rx \equiv ry \pmod {2^w}{% endlatex %}, then {% latex %}2^w | r(x-y){% endlatex %}
and, since r is odd, {% latex %}2^w | (x-y){% endlatex %}, and so {% latex %}x \equiv y \pmod{2^w}{%endlatex%}.
Thus f is a 1-1 function. Also it clearly maps odd numbers to odd numbers. QED.

Take two different numbers x and y. We want to bound hash collision probability for these two inputs.
Let k be the smallest bit position in which x and y differ. Therefore: {% latex %}x-y = r2^k{% endlatex%},
where r is an odd number.

Let {% latex %}g(x) = (ax+b) \bmod 2^w{% endlatex %}. The hash function {% latex %}h_1(x){% endlatex %}
is the top m
bits of {%latex%}g(x){%endlatex%}. Also define D as follows:

{% latex centred %}
D \equiv g(x) - g(y) \equiv (ax + b) - (ay+b) \equiv a(x-y) \equiv ar2^k \pmod{2^w}
{% endlatex %}

By the lemma, since a is random odd and r is odd, D is a random odd integer shifted left by k bits.

Also since b does not appear
in this formula for D, the random variable {% latex %}g(y) = (ay+b)\bmod 2^w{% endlatex %}
is independent of D. This is why we needed this +b term in the hash function.

Let's split D into the top m bits and the rest: {% latex %}D = H 2^{w-m} + L{% endlatex %}.

{% latex centred %}
g(x) \equiv g(y) + D \equiv g(y) + H 2^{w-m} + L
{% endlatex %}

If {% latex %}k \ge w-m{% endlatex %}, then {% latex %}H \neq 0{% endlatex %} and
L = 0. Hashes differ by H and are therefore always different with 100% certainty in this case.

If {% latex %}k \lt w-m{%endlatex%} then H is a uniformly random m-bit random variable
independent of {% latex %}g(y) + L{%endlatex%}. Exactly one value of H
makes the hashes equal, so collision probability is exactly {%latex%}2^{-m}{%endlatex%}.

## Proof for h<sub>2</sub>

Suppose we have two different inputs: {% latex %}(x_1,\ldots,x_n){%endlatex%},
{%latex%}(y_1,\ldots,y_n){%endlatex%}.

Since they are different at some position, we may as well
assume without loss of generality that {%latex%}x_1\ne y_1{%endlatex%}. Again let k bit the first
bit where they differ: {%latex%}x_1-y_1 = r2^k{%endlatex%}.

Define {%latex%}g(x) = (a_1x_1 + \ldots + a_nx_n + b)\bmod 2^{2w}{%endlatex%}.
The hash function {%latex%}h_2(x){%endlatex%} is the top m bits of g(x).

{% latex centred %}
g(x) - g(y) \equiv a_1(x_1-y_1) + (a_2(x_2-y_2) + \ldots + a_n(x_n-y_n)) \equiv a_1r2^k + E \equiv
D + E \pmod{2^{2w}}
{% endlatex %}

By the lemma, D is a random integer shifted left by k bits. It is also independent of E (because
E doesn't depend on {%latex%}a_1{%endlatex%}) and of g(y) (because g(y) has the independent +b term).

Split D into the top m bits and the rest: {%latex%}D = H2^{2w-m} + L{%endlatex%}.
We know that {%latex%}k \lt w \le {2w-m}{%endlatex%}, and therefore
H is a uniformly random number, independent of E, g(y) and L.

{%latex centred %}
g(x) \equiv g(y) + D + E \equiv g(y) + H 2^{w-m} + L + E
{%endlatex%}

There is exactly one value of H that will make the top m bits of g(x) and g(y) match, therefore
collision probability is always exactly {%latex%}2^{-m}{%endlatex%}.

## Proof for h<sub>3</sub>

The proof is very similar as in the previous case.

{% latex centred %}
g(x) - g(y) \equiv (x_1+a_2)(x_2+a_1) - (y_1+a_2)(y_2+a_1) + (\ldots) \equiv
a_1(x_1-y_1) + a_2(x_2-y_2) + (x_1x_2 - y_1y_2) + (\ldots) \equiv
a_1r2^k + E
{% endlatex %}

And the same proof works. We just incorporated the extra (non-random) term {%latex%}(x_1x_2 - y_1y_2){%endlatex%} into E, which doesn't change anything that follows.

## References

[^wolfel]: Wölfel, Philipp. [Über die Komplexität der Multiplikation in eingeschränkten Branchingprogrammmodellen](http://pages.cpsc.ucalgary.ca/~woelfel/paper/diss/index.html). Diss. Universität Dortmund, 2004.
