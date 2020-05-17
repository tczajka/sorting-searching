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

## Example game

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

### Five

### Open four

### Simple four

### Open three

### Broken three

### Non-forcing threats

## Another game

Funny pattern:
https://www.codecup.nl/showgame.php?ga=154884

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
