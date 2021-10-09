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
## V0.0.6
# Just a useless function
mod1:
  mod2:
    calculate: i32(value: i32)
      return value
    end calculate
  end mod2
end mod1

main: i32(argc: i32, argv: list(string))
  string_const: "Hello world!"
  float_const: 3.1415926
  int_const: argc
  result: mod1.mod2.calculate(int_const)
  return result
end main
```

### Running

Currently Sundy is in active development of design and making a working prototype of transpiler to C based on Ruby.

```sh
./sundy examples v003
```

### Versions
* v0.0.6 (+ define submodules, call function from submodule)
* v0.0.5 (+ define string and f64 local constant)
* v0.0.4 (+ return of result by a function call with i32 arguments or without arguments)
* v0.0.3 (+ call function wtih i32 argument)
* v0.0.2 (+ define i32 local constant)
* v0.0.1 (ruby lexer, documentation generator and parser, function "main", blank "array", "i32" and "string" type definitions, "return" reserved word)