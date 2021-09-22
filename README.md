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

```ruby
# V0.0.1
# Just a useless function in a root of package namespace
main: i32(argc: i32, argv: array(string)) do
  return 0
end main
```

### Running

Currently Sundy is in active development of design and making a working prototype of compiler based on Ruby & Docker.

```sh
./lexer --in tmp --out tmp hello_world
./parser --in tmp --out tmp hello_world
```

### Versions

* v0.0.1-ruby (ruby lexer, documentation generator and parser, function "main", blank "array", "i32" and "string" type definitions, "return" reserved word)