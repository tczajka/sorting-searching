---
title: "Tournament-winning gomoku AI"
---

* TOC
{:toc}

## Introduction

I'm going to describe my Gomoku playing program that I submitted for
[CodeCup 2020](https://www.codecup.nl). The program (named "OOOOO") ended up winning the tournament,
placing first in a field of 58 entries, and winning 98 out of 100 games.

CodeCup is an excellent annual tournament for game AIs organized by the Dutch National Olympiad in
Informatics. Every year they host a tournament for programs playing a game, with a different board
game each time.

In January 2020 the game was Gomoku. It was a bit unusual in that the game chosen
was a well-known game. Usually it's a completely new game, or an obscure game not well known. So I thought
that winning submissions might be some existing programs that were already developed
previously over many years. This turned out not to be the case.

I enjoyed coding this game very much. The game has very simple rules, and allows very interesting algorithmic
ideas.

You can see the results and all the games on the [tournament website](https://www.codecup.nl/competition.php?comp=253).

## Rules

The game was simple "free-style" gomoku played on a 16x16 board. Players alternate placing black
and white stones anywhere on the board, until somebody makes 5 stones in row horizontally, vertically
or diagonally, which wins.

To minimize first-player advantage, "swap rule" is employed. One player makes the first
three moves (black, white, black), and the other player may choose to continue with white, or swap
colors.

## Example game one

Take a look at an [example game](https://www.codecup.nl/showgame.php?ga=154808)
played between OOOOO (black) and Leopold Tschanter's "ltgmk" (white).

The game ended with the following sequence:

![game 1](/assets/images/gomoku/game1.png)

When OOOOO played the move marked as 1, it already knew it was going to win, 13 ply (7 moves) before the game ended.
This despite the fact that the space of possible moves is very large: each player has almost all 256
intersections available each move.

This is a forcing sequence of threats to which defenses are more or less forced.

Move 1 is a diagonal "simple four" threat. 2 is forced, otherwise black will play at 2 and win immediately.

Move 3 is a diagonal "broken three" threat.

This time however, white doesn't have to respond immediately. Instead, he makes a stronger counter-threat
with a simple four at 4. Black has to defend the counter-threat at 5.

Now white has to go back and address the threat at 3. If he ignored the threat, black would make a
diagonal "open four" threat at 6 to which there would be no defense.

So white defends at 6.

Now black makes another simple four at 7. White has to respond at 8.

Now black makes a double "open three" threat at 9. White doesn't have a stronger counter-threat, so
defends one of these open threes at 10.

Black converts the other, undefended open three into an open four with 11. There is no defense to
an open four (other than making an immediate five). White defends on one side with 12, and black
finishes with a five on the other side at 13, winning the game.

Pretty much every gomoku game ends in one of these long forcing threat sequences. It is therefore
essential to be able to find such sequences and defend against opponent's sequences.

## Threats

We categorize threats as follows:
* Winning threats. There are fives and open fours.
* Forcing threats, i.e. opponent must respond. These are: simple fours, open threes, and broken threes.
* Non-forcing threats. These don't require the opponent to respond, but may become forcing threats
  later when additional stones are added.

Threats can also be ordered, by their severity:
* Fives.
* Fours.
* Threes.
This ordering is useful when thinking about counter-threats later. Instead of answering a forcing
threat, one may counter with a more severe counter-threat.

### Five

![fives](/assets/images/gomoku/fives.png)

Fives are pretty self-explanatory. You immediately make five in a row and win. 1, 2, 3 are fives.

### Open four

![open fours](/assets/images/gomoku/open_fours.png)

A standard open four threat looks is a play like 1. Black has no defense. If black plays at a, white
plays at b. If black plays at b, white plays at a. The only way to salvage the game for black would
be to play a more severe counter-threat elsewhere, i.e. a five!

But 1 is not he only pattern like that. 2 and 3 work exactly the same way. They also create two
ways for white to finish the game. Even though they involve 6 and 7 stones rather than 4, I also
call such equivalent patterns "open fours".

### Simple four

![simple fours](/assets/images/gomoku/simple_fours.png)

A simple four is a forcing threat, threatening a five next move, but only in one way. It doesn't
necessarily win, but forces a response.
White plays at 1 or 2, black has to respond at a (or play a more severe threat, i.e. a five).

### Open three

![open threes](/assets/images/gomoku/open_threes.png)

The most common open three is play at 1: three in a row, with two empty spaces on each side. Black has
to defend at b or c (or play a four-threat elsewhere). Otherwise, white will make an open four at
b or c and win.

Open three is a special kind of threat in that four empty spaces are required, but only two of them
are valid defenses for black. For instance, if black tries to defend at a, white still makes an open
four at c and wins.
  
This will be relevant later, when we talk about sequences of threat:
we have to make sure that a and d are still empty when this threat is played, even though black can't
defend there. 

And again, there are other patterns like 2 and 3 above that we call "open threes" even though they
involve more than three white stones. The defining characteristic is that there are four
empty spaces of which white needs to fill any two consecutive ones to win.

The last pattern is my favorite. It plays a role in example game 2 below.

### Broken three

![broken threes](/assets/images/gomoku/broken_threes.png)

Finally we come to the weakest type of forcing threat, but perhaps the most common one: a broken
three.  Here only three empty spots are involved. Black can defend at any one of them, otherwise
white will make an open four at b.

### Non-forcing threats

All types of threats can be described by two numbers: {% latex %}(a,b){% endlatex %} where
{% latex %} 1 \le a \le 5 {% endlatex %} is the threat severity (we already have a stones out of 5),
and {% latex %} 1 \le b \le 6-a {% endlatex %} is the number of possible ways to make a five.

So all the threats types are as follows:

* Winning threats:
  * (5, 1): five
  * (4, 2): open four
* Forcing threats:
  * (4, 1): simple four
  * (3, 3): open three
  * (3, 2): broken three
* Non-forcing threats:
  * (3, 1): simple three
  * (2, 4), (2, 3), (2, 2), (2, 1): a two that can be completed in 4, 3, 2, 1 ways respectively
  * (1, 5), (1, 5), (1, 3), (1, 2), (1, 1): a one that can be completed in 5, 4, 3, 2, 1 ways respectively
* No threat at all

![other threats](/assets/images/gomoku/other_threats.png)

All the above are non-forcing threats. Play at 1 is (3, 1), i.e. a simple three. Play at 2 is a (2, 3),
a two that can be completed in 3 ways. Play at 3 is not a threat at all, because it can't make five
in a row in this direction.

## Example game 2

Let's look at [another game](https://www.codecup.nl/showgame.php?ga=154884) from the tournament.
OOOOO plays black versus Sjoerd Hemminga's SjoerdsGomokuPlayer playing white.

The final forcing sequence that OOOOO employed looks like this:

![game 2](/assets/images/gomoku/game2.png)

Black plays a diagonal broken three at 1, white defends at 2. Black plays another diagonal broken
three at 3, white defends at 4. Black plays a horizontal open three at 5, black defends at 6.

And now comes a pretty double-threat at 7. A standard vertical broken three, and a nice non-standard
horizontal "open three" consisting of four stones, all separated by empty spaces.

White defends the vertical threat at 8, and black converts the undefended horizontal "open three"
into a non-standard "open four" (actually consisting of five stones) with 9. White defends one
of the two spots at 10, and black finishes the job at 11.

## All-defenses trick

## Dependency-based search

## Counter-threats and refutations

## Defenses to potential threat sequences

## Precomputed patterns

## Board representation

### Rotated bitboards

### Immediate threats

## Principal variation search

### Null move forward prunning

## Evaluation

## Opening book

## References

[^allis]: Allis, Louis Victor. Searching for solutions in games and artificial intelligence. Wageningen: Ponsen & Looijen, 1994.
[^book]: Lincke, Thomas R. "Strategies for the automatic construction of opening books." International Conference on Computers and Games. Springer, Berlin, Heidelberg, 2000.
