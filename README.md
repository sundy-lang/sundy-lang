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
## V0.0.7
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

  Sandbox.show(string_const)
  
  result: mod1.mod2.calculate(int_const)
  return result
end main
```

### Running

Currently Sundy is in active development of design and making a working prototype of transpiler to C based on Ruby.

```sh
./sundy examples v007
```

### Lexemes definition

Single-letter lexemes:

```
&  - AND
}  - CLOSE_BLOCK_BRACE
]  - CLOSE_FILTER_BRACE
)  - CLOSE_PRIORITY_BRACE
:  - COLON
,  - COMMA
/  - DIV
\n - EOL
=  - EQ
<  - LESS
-  - MINUS
>  - MORE
*  - MUL
{  - OPEN_BLOCK_BRACE
[  - OPEN_FILTER_BRACE
(  - OPEN_PRIORITY_BRACE
|  - OR
+  - PLUS
^  - POW
%  - PROCENT
\\ - SLASH
~  - TILDA
```

Reserved words:

```
AND
BREAK
ELSE
IF
IN
LOOP
NOT
OR
OMNI
OUT
PARENT
RETURN
THIS
UNTIL
WHILE
XOR
```

Сomplementary lexemes (cut from the program code):

```
COMMENT
DOC
WARN
WORD_BREAK
```

Other lexemes:

```
BIN
FLOAT
HEX
INT
LOCAL_ID
OCT
PARENT_ID
REGEXP
SMART_STRING
STATIC_ID
STRING
TAG
THIS_ID
```

### Versions
* v0.0.7 (+ single function call statements, sandbox show method)
* v0.0.6 (+ define submodules, call function from submodule)
* v0.0.5 (+ define string and f64 local constant)
* v0.0.4 (+ return of result by a function call with i32 arguments or without arguments)
* v0.0.3 (+ call function with i32 argument)
* v0.0.2 (+ define i32 local constant)
* v0.0.1 (ruby lexer, documentation generator and parser, function "main", blank "array", "i32" and "string" type definitions, "return" reserved word)