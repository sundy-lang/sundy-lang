require_relative 'parser/constant_parser.rb'
require_relative 'parser/method_parser.rb'
require_relative 'parser/type_parser.rb'
require_relative 'parser/value_parser.rb'

class Parser
  include ConstantParser
  include MethodParser
  include TypeParser
  include ValueParser

  def initialize options
    @debug = !!options[:debug]
    @errors = []
    @types = []
    @source_name = options[:source_name]
    @consumption_stack = []
    @lexem_buffer = options[:lexems]
    @lexem_index = 0
    @unexpected_lexem_index = 0
  end # initialize

  def available_lexems
    [
      :AND,
      :BACK_SLASH,
      :BIN,
      :BREAK,
      :CLOSE_BLOCK,
      :CLOSE_FILTER,
      :CLOSE_PRIORITY,
      :COLON,
      :COMMA,
      :COMMENT,
      :DIV,
      :DOC,
      :ELSE,
      :EOL,
      :EQ,
      :FALSE,
      :FLOAT,
      :HEX,
      :IF,
      :IN,
      :INT,
      :LESS,
      :LOCAL_ID,
      :LOOP,
      :MINUS,
      :MORE,
      :MUL,
      :NOT,
      :OCT,
      :OMNI,
      :OPEN_BLOCK,
      :OPEN_FILTER,
      :OPEN_PRIORITY,
      :OR,
      :OUT,
      :PARENT,
      :PARENT_ID,
      :PLUS,
      :POW,
      :PROCENT,
      :REGEXP,
      :RETURN,
      :SMART_STRING,
      :STATIC_ID,
      :STRING,
      :TAG,
      :THIS,
      :THIS_ID,
      :TILDA,
      :TRUE,
      :UNTIL,
      :WARN,
      :WHILE,
      :WORD_BREAK,
      :XOR,
    ]
  end # available_lexems

  # Consume one or group of expected lexems from the buffer
  def consume expected_list, options = {}
    saved_code_index = @lexem_index

    expected_list = [ expected_list ] if expected_list.is_a?(Symbol)
    expected_list.each do |expected|
      return if !@errors.empty?
      puts "#{lexem_coords} Try to consume #{expected}..." if @debug
      # Consume single lexem
      if available_lexems.include?(expected)
        if lexem = @lexem_buffer[@lexem_index]
          if expected == lexem[:type].to_sym
            @lexem_index += 1
            puts "#{lexem_coords} Consumed #{expected}: #{lexem[:value].inspect}" if @debug
            return case expected
            when :FALSE then {type: 'BOOL', value: false}
            when :FLOAT then {type: 'F64', value: lexem[:value].to_f}
            when :INT then {type: 'I32', value: lexem[:value].to_i}
            when :STRING then {type: 'STRING', value: lexem[:value].to_s}
            when :TRUE then {type: 'BOOL', value: false}
            else {type: lexem[:type], value: lexem[:value]}
            end #
          end # if
        end # if
      # Consume complex element
      else
        method_name = "consume_#{expected}".downcase.to_sym
  
        if methods.include?(method_name)
          if element = send(method_name)
            puts "#{lexem_coords} Consumed #{expected}: #{element.inspect}" if @debug
            return element
          end # if
        else
          @errors << "[#{lexem_coords}] Unknown method 'Parser.#{method_name}'"
          return
        end # if
      end # if  

      puts "#{lexem_coords} Rollback from #{expected} consumption" if @debug
      # Rollback lexems to the consumption buffer
      @lexem_index = saved_code_index
    end # each
    
    # @errors << "[#{lexem_coords}] Can't consume one of: #{expected_list.join(', ')}"

    return
  end # consume

  # EBNF BOOL_STATEMENT = LOCAL_ID (LESS | MORE) INT.
  def consume_bool_statement
    if left_part = consume(:LOCAL_ID)
      if comparison_type = consume([:LESS, :MORE])
        if right_part = consume(:INT)
          return {
            type: "COMPARISON_#{comparison_type[:type]}",
            left: left_part,
            right: right_part,
          }
        end # if
      end # if
    end # if
  end # consume_bool_statement

  # EBNF ELSE_IF_ELEMENT = ELSE IF [EOLS] IF_CONDITIONS [EOLS] METHOD_DEFINITION_ELEMENTS.
  def consume_else_if_element
    if consume(:ELSE)
      if consume(:IF)
        consume(:EOLS)
        if conditions = consume(:IF_CONDITIONS)
          consume(:EOLS)
          if elements = consume(:METHOD_DEFINITION_ELEMENTS)
            return {
              conditions: conditions,
              elements: elements,
            }
          end # if
        end # if
      end # if
    end # if
  end # consume_else_if_element

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

    return i > 0 ? {type: 'EOLS', value: i} : nil
  end # consume_eols

  # EBNF IF_CONDITIONS = OPEN_PRIORITY [EOLS] BOOL_STATEMENT [EOLS] CLOSE_PRIORITY.
  def consume_if_conditions
    if consume(:OPEN_PRIORITY)
      consume(:EOLS)
      if statement = consume(:BOOL_STATEMENT)
        consume(:EOLS)
        if consume(:CLOSE_PRIORITY)
          return statement
        end # if
      end # if
    end # if
  end # consume_if_conditions

  # EBNF IF_STATEMENT = IF [EOLS] IF_CONDITIONS [EOLS] IF_ELEMENTS <ELSE_IF_ELEMENT> [ELSE [EOLS] METHOD_DEFINITION_ELEMENTS] IF EOLS.
  # Return: {type: 'IF', variants:{conditions, elements}, else:[...]}
  def consume_if_statement
    if consume(:IF)
      consume(:EOLS)
      if conditions = consume(:IF_CONDITIONS)
        consume(:EOLS)
        if elements = consume(:METHOD_DEFINITION_ELEMENTS)
          statement = {
            type: 'IF',
            variants: [
              {
                conditions: conditions,
                elements: elements,    
              },
            ]
          }
          loop do
            if variant = consume(:ELSE_IF_ELEMENT)
              statement[:variants] << variant
            else
              break
            end # if
          end # loop
          if consume(:ELSE)
            consume(:EOLS)
            if elements = consume(:METHOD_DEFINITION_ELEMENTS)
              statement[:else] = elements
            end # if
          end # if
          if consume(:IF)
            return statement
          end # if
        end # if
      end # if
    end # if
  end # consume_if_statement

  def lexem_coords
    i = @lexem_index > 0 ? @lexem_index - 1 : 0
    "#{@lexem_buffer[i][:line]}:#{@lexem_buffer[i][:col]}"
  end

  # Parse the buffer
  def parse
    loop do
      consume(:EOLS)

      if element = consume(:TYPE_DEFINITION)
        @types << element 
      elsif @lexem_index < @lexem_buffer.size
        @errors << "[#{lexem_coords}] Can't parse the type"
      else
        break
      end # if

      if !@errors.empty?
        puts @errors.join("\n")
        raise "'#{@source_name}' parse error at #{lexem_coords}"
      end # if
    end # loop

    puts "#{lexem_coords} Successfully parsed."
  end # parse

  def types
    @types
  end
end # Parser