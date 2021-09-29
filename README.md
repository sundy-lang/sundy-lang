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
## V0.0.3
# Just a useless function
calculate: i32(value: i32)
  return value
end calculate

main: i32(argc: i32, argv: list(string))
  result: calculate(argc)
  return result
end main
```

### Running

Currently Sundy is in active development of design and making a working prototype of transpiler to C based on Ruby.

```sh
./sundy examples v003
```

### Versions
* v0.0.3 (+ call function wtih i32 argument)
* v0.0.2 (+ define i32 local constant)
* v0.0.1 (ruby lexer, documentation generator and parser, function "main", blank "array", "i32" and "string" type definitions, "return" reserved word)