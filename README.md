# sundy-lang
☀️ Sundy - yet another programming language for making your own sand castles 👑

### Goals of Sundy design

* Multi-paradigm general purpose programming language
* Compilation with LLVM backend
* No stop-the-world
* No memory leaks
* No race conditions
* Developer friendly
* Smooth learning curve

### Syntax prototype

```
# Just a useless function in a root of package namespace
main: i32(argc: i32, argv: array(string)) do
  result: 0
  return result
end main

```

### Some thoughts

* UTF-8 as a text encoding
* Using of latin alphabet for a programming language terms, data types and user identifiers
* Reading from left to right, from top to bottom
* Minimum of reserved words (syntax terms and primitive data types)
* Case insensitivity on all terms, data types and identifiers
* Using of underscore character as a visual helper for all words, tags and primitive types
* Using of equality character as a logical instruction
* Seeking of identifiers without a namespace does in a local running block and in a current namespace (module or class), other identifiers should be prefixed by a point character with some namespace or a special object namespace ("this")
* Using semicolons as synonyms for EOL
* Explicit and unambiguous indication of the identifier name in the end of the logic block
* Every file is a package with its own root namespace, file name should be used as a package name
