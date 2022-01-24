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
## sundy-sample v0.0.8

# 'App' type extends 'Application' standard library type
App: Application {
  # 'App.Meta' extends 'Type' type
  Meta: {
    name: 'sundy-sample'
    iteration: 8
  } Meta

  # Compiler uses first found 'main' method of 'Application' type as an entrypoint function, here it is 'App.main'
  Main: (
    argc: i32, 
    argv: in array(string), 
    result: out i32(123),
  ) {
    # Name recognition steps: method namespace, current type namespace, global namespace
    # for example: 'puts' -> 'Application.puts', 'Meta.name' -> 'Application.Meta.name'.
    # Method call without parameter name is available because it linked to a method with single 'in' parameter.
    puts(Meta.name)

    if (argc > 1) {
      result.set(argc)
      puts("App returns redefined value (which is the same as 'argc' value).")
    } else {
      puts("App returns default value (123).")
    } if

    # This method returns single integer value (123 or argc) because it has single 'out' parameter which has default value (123).
  } Main
} App
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
\\ - BACK_SLASH
}  - CLOSE_BLOCK
]  - CLOSE_FILTER
)  - CLOSE_PRIORITY
:  - COLON
,  - COMMA
/  - DIV
\n - EOL
=  - EQ
<  - LESS
-  - MINUS
>  - MORE
*  - MUL
{  - OPEN_BLOCK
[  - OPEN_FILTER
(  - OPEN_PRIORITY
|  - OR
+  - PLUS
^  - POW
%  - PROCENT
~  - TILDA
```

Reserved words:

```
AND
BREAK
ELSE
FALSE
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
TRUE
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

### Syntax definition

```
(...) - grouping block
[...] - 0 or 1 element
<...> - 0 or more elements
{...} - 1 or more elements

BOOL_STATEMENT = LOCAL_ID (LESS | MORE) INT.
CONSTANT_DEFINITION = LOCAL_ID COLON VALUE EOLS.
CONSTRUCTOR_CALL = THIS METHOD_CALL_ARGS.
ELSE_IF_ELEMENT = ELSE IF [EOLS] IF_CONDITIONS [EOLS] METHOD_DEFINITION_ELEMENTS.
EOLS = {EOL}.
FILE = {TYPE_DEFINITION} EOF.
IF_CONDITIONS = OPEN_PRIORITY [EOLS] BOOL_STATEMENT [EOLS] CLOSE_PRIORITY.
IF_STATEMENT = IF [EOLS] IF_CONDITIONS [EOLS] IF_ELEMENTS <ELSE_IF_ELEMENT> [ELSE [EOLS] METHOD_DEFINITION_ELEMENTS] IF EOLS.
METHOD_CALL = (LOCAL_ID | PARENT_ID | STATIC_ID | THIS_ID) METHOD_CALL_ARGS.
METHOD_CALL_ARG = VALUE | STATIC_ID.
METHOD_CALL_ARGS = OPEN_PRIORITY [EOLS] [METHOD_CALL_ARG <COMMA [EOLS] [METHOD_CALL_ARG]>] [EOLS] CLOSE_PRIORITY.
METHOD_DEFINITION = LOCAL_ID COLON [EOLS] METHOD_DEFINITION_ARGS [EOLS] METHOD_DEFINITION_ELEMENTS LOCAL_ID EOLS.
METHOD_DEFINITION_ARG = LOCAL_ID COLON [EOLS] [IN | OUT | OMNI] METHOD_DEFINITION_ARG_TYPE.
METHOD_DEFINITION_ARG_TYPE = (VALUE | ((LOCAL_ID | STATIC_ID) [OPEN_PRIORITY [METHOD_DEFINITION_ARG_TYPE] CLOSE_PRIORITY])).
METHOD_DEFINITION_ARGS = OPEN_PRIORITY [EOLS] [METHOD_DEFINITION_ARG <COMMA [EOLS] METHOD_DEFINITION_ARG>] [EOLS] CLOSE_PRIORITY.
METHOD_DEFINITION_ELEMENTS = OPEN_BLOCK <[CONSTANT_DEFINITION | IF_STATEMENT | METHOD_CALL | RETURN] EOLS> CLOSE_BLOCK.
TYPE_DEFINITION = LOCAL_ID COLON [EOLS] [TYPE_IDS] [EOLS] TYPE_DEFINITION_ELEMENTS LOCAL_ID EOLS.
TYPE_IDS = (LOCAL_ID | STATIC_ID) <COMMA [EOLS] (LOCAL_ID | STATIC_ID)>.
VALUE = FALSE | FLOAT | INT | STRING | TRUE.
```

### Versions
* v0.0.8 (syntax changes, simple if statement)
* v0.0.7 (+ single function call statements, sandbox show method)
* v0.0.6 (+ define submodules, call function from submodule)
* v0.0.5 (+ define string and f64 local constant)
* v0.0.4 (+ return of result by a function call with i32 arguments or without arguments)
* v0.0.3 (+ call function with i32 argument)
* v0.0.2 (+ define i32 local constant)
* v0.0.1 (ruby lexer, documentation generator and parser, function "main", blank "array", "i32" and "string" type definitions, "return" reserved word)