# Your master password generator

Cretes a strong master password by selecting random words and inserting
special characters into them.

This is based on the ideas expressed in [xkcd][xkcd] and [Computerphile's
discussion on how to pick passwords][computerphile].

# Example use

Three random words
```
$ ./out/masterpass -f=dict/example
zygotfickknivabbreviera
```

**Five** random words
```
$ ./out/masterpass -f=dict/example -w=5
utandningfickknivzymologiskfickknivzymologisk
```

Five random words **with a random number**.
```
$ ./out/masterpass -f=dict/example -w=5 -n
utandni7ngfickknivzymologiskfickknivzymologisk
-------^
```

Five random words with a random number and **random special character**.
```
$ ./out/masterpass -f=dict/example -w=5 -n -use-specials
utandni7ngfickknivzymologiskfickknivzym;ologisk
       ^                               ^
```

Five random words with a random number and a **special character from a user-supplied list**.
```
$ ./out/masterpass -f=dict/example -w=5 -n -use-specials -s='#$%^&*()'
utandni7ngfickknivzymologiskfickkniv*zymologisk
       ^                            ^
```

Five random words with a random number and a special character from a list, and a random character uppercased.
```
$ ./out/masterpass -f=dict/example -w=5 -n -use-specials -s='#$%^&*()' -u
utandni7ngfickknivzymoloGiskfickkniv*zymologisk
       ^                ^           ^
```



# Building

Requires Haskell. Specifically, you need `ghc` and may need to install extra packages through `cabal install`.

Use `make` to build, or see the makefile for the build steps.

[xkcd]: https://xkcd.com/936/
[computerphile]: https://www.youtube.com/watch?v=3NjQ9b3pgIg&ab_channel=Computerphile
