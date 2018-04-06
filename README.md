# Your master password generator

Cretes a strong master password by selecting random words and inserting
special characters into them.

This is based on the ideas expressed in [xkcd][xkcd] and [Computerphile's
discussion on how to pick passwords][computerphile].

# Building

Requires Haskell. Specifically, you need `ghc` and may need to install extra packages through `cabal install`.

Use `make` to build, or see the makefile for the build steps.

[xkcd]: https://xkcd.com/936/
[computerphile]: https://www.youtube.com/watch?v=3NjQ9b3pgIg&ab_channel=Computerphile
