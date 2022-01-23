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
      puts "#{lexem_coords} Try to consume #{expected}..." if @debug
      # Consume single lexem
      if available_lexems.include?(expected)
        if lexem = @lexem_buffer[@lexem_index]
          if expected == lexem[:type].to_sym      
            @lexem_index += 1
            puts "#{lexem_coords} Consumed #{expected}: #{lexem[:value].inspect}" if @debug
            return lexem[:value]
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