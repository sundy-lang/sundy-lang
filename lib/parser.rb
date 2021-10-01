## EBNF v0.0.1:
#  FILE = {MODULE_ELEMENT} EOF.
#  MODULE_ELEMENT = EOLS | FUNCTION_DEFINITION.
#  FUNCTION_DEFINITION = ID COLON FUNCTION_DESCRIPTION EOLS FUNCTION_BODY EOLS END ID EOL.
#  FUNCTION_DESCRIPTION = ID OPEN_PRIORITY_BRACE EOLS [FUNCTION_ARGS_DECLARATION] EOLS CLOSE_PRIORITY_BRACE EOL.
#  FUNCTION_ARGS_DECLARATION = ID COLON FUNCTION_ARG_TYPE {COMMA EOLS ID COLON FUNCTION_ARG_TYPE}.
#  FUNCTION_ARG_TYPE = ID [OPEN_PRIORITY_BRACE EOLS [FUNCTION_ARG_TYPE | CONST_VALUE] EOLS CLOSE_PRIORITY_BRACE].
#  PRIMITIVE_VALUE = INTEGER | STRING.
#  FUNCTION_BODY = {RETURN}.
#  RETURN = RETURN PRIMITIVE_VALUE.
#  EOLS = {EOL}.

require_relative 'parser/constant_parser.rb'
require_relative 'parser/function_parser.rb'
require_relative 'parser/module_parser.rb'

class Parser
  include ConstantParser
  include FunctionParser
  include ModuleParser

  def initialize options
    @root_node = {
      type: 'MODULE_DEFINITION',
      name: options[:source_name].upcase.gsub('_', '').gsub('/', '.'),
      constants: {},
      functions: {},
      modules: {},
    }

    @current_node = @root_node
    @lexem_buffer = options[:lexems]
    @lexem_index = 0
    @unexpected_lexem_index = 0
  end # initialize

  def ast
    @root_node
  end

  # Consume one or group of expected lexems from the buffer
  def consume expected, options = {}
    saved_code_index = @lexem_index

    if lexem_types.include?(expected)
      if result = @lexem_buffer[@lexem_index]
        return if expected != result[:type].to_sym
    
        @lexem_index += 1
        return result[:value]
      end # if
    else
      method_name = "consume_#{expected}".downcase.to_sym

      if methods.include?(method_name)
        if result = send(method_name)
          return result
        end # if
      else
        raise "Unknown method '#{method_name}'"
      end # if

      @unexpected_lexem_index = @lexem_index if @lexem_index > @unexpected_lexem_index
      @lexem_index = saved_code_index
      return
    end # if
  end # consume

  # EBNF: EOLS = {EOL}.
  def consume_eols
    i = 0

    loop do
      if consume(:EOL)
        i += 1 
      else
        break
      end # if
    end # loop

    return i > 0 ? true : nil
  end # consume_eols

  # EBNF: LOCAL_ID = {LATIN_LETTER | UNDERSCORE} {LATIN_LETTER | DECIMAL_DIGIT | UNDERSCORE}.
  def consume_local_id
    if id = consume(:ID)
      local_id = id.first
      if id.size == 1 && !reserved_words.include?(local_id)
        return local_id
      end # if
    end # if
  end # consume_local_id

  # EBNF: PRIMITIVE_VALUE = INTEGER.
  def consume_primitive_value
    if value = consume(:INT)
      return value
    end
  end # consume_primitive_value

  def lexem_types
    [
      :DOC,
      :WARN,
      :COMMENT,
      :STRING,
      :STRING,
      :SMART_STRING,
      :REGEXP,
      :TAG,
      :FLOAT,
      :INT,
      :HEX,
      :OCT,
      :BIN,
      :EOL,
      :WORD_BREAK,
      :ELSE,
      :END,
      :IF,
      :IMPORT,
      :LOOP,
      :PARENT,
      :RETURN,
      :THIS,
      :ID,
      :COLON,
      :COMMA,
      :OPEN_PRIORITY_BRACE,
      :CLOSE_PRIORITY_BRACE,
      :OPEN_FILTER_BRACE,
      :CLOSE_FILTER_BRACE,
      :OPEN_BLOCK_BRACE,
      :CLOSE_BLOCK_BRACE,
    ]
  end # lexem_types

  # Parse the buffer
  def parse
    while @lexem_index < @lexem_buffer.size
      if elements = consume(:MODULE_ELEMENTS)
        if elements.is_a?(Hash)
          @root_node[:constants] = elements[:constants]
          @root_node[:functions] = elements[:functions]
          @root_node[:modules] = elements[:modules]
        end # if
      else
        raise "Can't parse lexem at #{@lexem_buffer[@unexpected_lexem_index][:line]}:#{@lexem_buffer[@unexpected_lexem_index][:col]}"
      end
    end # while
  end # parse

  def reserved_words
    [
      'ELSE',
      'END',
      'IF',
      'IMPORT',
      'LOOP',
      'PARENT',
      'PRIVATE',
      'PUBLIC',
      'RETURN',
      'THIS',
    ]
  end # reserved_words
end # Parser