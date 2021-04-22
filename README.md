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
# Just a useless function in a root of package namespace
main: i32(argc: i32, argv: array(string)) do
  result: 0
  return result
end main

# Singletone namespace
World:
  g: 9.8 # Static constant (using f64 type inference)
  
  # Some class (literally is a namespace/package with constructor)
  Animal:
    # Simple constructor without arguments which makes a fairy animal
    This: Animal() do
      this.age: 999_999_999.0
      this.type: @Fairy
      
      # Constructor can skip the value return, it returns the object of it's type by default
    End This
    
    # Second constructor which makes a trivial animal (every function can use named arguments)
    This: (
      age: u8(0.0), # function waits for 8 bit unsigned integer or set "age" to 0
      type: Symbol(@Mammal) # "symbol" type is an integer with syntax sugar, @Mammal is a default value for argument
    ) do
      this.age: age
      this.type: type
    End This
  End Animal
End World
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
