---
title: "If you need a PRNG, always use a CSPRNG"
---

## Summary

This post is about [Pseudo-Random Number Generators](https://en.wikipedia.org/wiki/Pseudorandom_number_generator), PRNGs for short.

We often want computers to behave randomly, for various reasons:
* Cryptography. Encryption keys need to be random to prevent attackers from guessing them.
* Monte-Carlo simulations. We want to estimate average behavior of some system by random sampling.
* [Monte Carlo algorithms](https://en.wikipedia.org/wiki/Monte_Carlo_algorithm). Certain computational problems are easier to solve with high probability using randomness than deterministically with certainty.
* [Las Vegas algorithms](https://en.wikipedia.org/wiki/Las_Vegas_algorithm). These always produce the correct answer, but their efficiency depends on using randomness.
* Video games. We want elements of the game to behave randomly.
* Art. Predictable patterns are boring.
* Machine learning. We want to initialize neural network weights randomly, and sample data randomly for learning purposes.

Really random bits are hard to come by. You can use various hardware devices to produce "truly random" bits, but it's difficult to do this efficiently in large quantities and without bias. This is why we typically prefer PRNGs instead. Another advantage of PRNGs is that we can easily replay a pseudo-randomly generated sequence without storing all the random bits.

There are various PRNG algorithms available. The question I will try to answer is: which one should you use?

This is a very widely debated issue. Donald Knuth in his classic books [The Art of Computer Programming](https://www-cs-faculty.stanford.edu/~knuth/taocp.html) devotes
a good part of Volume 2 just to this topic. There are a lot of papers analyzing the pros and cons of various algorithms and their potential weak spots. Authors of two popular PRNGs, xoroshiro and PCG, have been each arguing online ([xoroshiro's author vs PCG](https://pcg.di.unimi.it/pcg.php), [PCG's author vs xoroshiro](https://www.pcg-random.org/posts/on-vignas-pcg-critique.html)).

I have already given away my answer is the title. You should **always** use CSPRNGs and ignore all other PRNGs. There is no practical reason to use anything else. If you follow this advice, you can sleep well and ignore all the discussions about PRNG weaknesses because CSPRNGs don't have these weaknesses (as far as we know, at least).

This advice goes somewhat against the common practice and the usual advice. What people will typically say is: use CSPRNGs if you are doing cryptography and need security against adversarial attackers. For all other purposes pick among the "classic" PRNGs.

It sounds reasonable. After all, it's in the name: CSPRNG stands for "cryptographically secure" PRNG. But I will argue that always using CSPRNGs is much superior.
