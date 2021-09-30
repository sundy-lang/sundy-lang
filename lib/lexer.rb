require_relative 'lexem.rb'

class Lexer
  @@available_lexems = {
    /\A##[^\n]*\z/                    => :DOC,
    /\A#![^\n]*\z/                    => :WARN,
    /\A#[^\n]*\z/                     => :COMMENT,
    /\A'([^']|\\')*[']?\z/            => :STRING,
    /\A"([^"]|\\")*["]?\z/            => :STRING,
    /\A`([^`]|\\`)*[`]?\z/            => :SMART_STRING,
    /\A\/([^\/]|\\\/)*[\/]?\z/        => :REGEXP,
    /\A@[a-z0-9_]+\z/i                => :TAG,
    /\A[-]?[0-9_]+.[0-9_]+\z/         => :FLOAT,
    /\A[-]?[0-9_]+\z/                 => :INT,
    /\A0x[0-9a-f_]+\z/i               => :HEX,
    /\A0o[0-7_]+\z/                   => :OCT,
    /\A0b[01]+\z/                     => :BIN,
    /\A[;\r\n]+\z/                    => :EOL,
    /\A[ \t]+\z/                      => :WORD_BREAK,
    /\AELSE\z/i                       => :ELSE,
    /\AEND\z/i                        => :END,
    /\AIF\z/i                         => :IF,
    /\AIMPORT\z/i                     => :IMPORT,
    /\ALOOP\z/i                       => :LOOP,
    /\APARENT\z/i                     => :PARENT,
    /\ARETURN\z/i                     => :RETURN,
    /\ATHIS\z/i                       => :THIS,
    /\A[a-z_][.a-z0-9_]*[?]?\z/i      => :ID,
    ':'                               => :COLON,
    ','                               => :COMMA,
    '('                               => :OPEN_PRIORITY_BRACE,
    ')'                               => :CLOSE_PRIORITY_BRACE,
    '['                               => :OPEN_FILTER_BRACE,
    ']'                               => :CLOSE_FILTER_BRACE,
    '{'                               => :OPEN_BLOCK_BRACE,
    '}'                               => :CLOSE_BLOCK_BRACE,
  }

  def initialize buffer
    @char_buffer = buffer
    @col = 1
    @code = []
    @current_code_index = 0
    @docs = []
    @line = 1
    @warning_comments = []
  end # initialize

  def code
    @code
  end # code

  def code_index
    @current_code_index
  end
  
  def code_index= n
    @current_code_index = n
  end

  def code_inspect
    puts '--BEGIN--'
    @code.each do |r|
      puts "#{r.line}:#{r.col} #{r.type}: #{r.value.inspect}"
    end # each
    puts '--END--'
  end

  def docs
    @docs
  end # docs

  def done?
    @char_buffer.empty?
  end # done?

  def parse
    while parse_next_lexem
    end # while
    return @code
  end # parse

  def parse_next_lexem
    return nil if done?

    found = nil

    loop do
      accumulator = ''
      found = nil
      buffer_col = 0
      buffer_line = 0

      while !@char_buffer.empty?
        accumulator << @char_buffer[0]
        @char_buffer = @char_buffer[1 .. -1]

        @@available_lexems.each do |rule, type|
          if rule.is_a?(String)
            if accumulator == rule
              found = Lexem.new(
                col: @col, 
                line: @line,
                type: type, 
                value: accumulator,
              )
            end # if
          else # Regexp
            if accumulator.match(rule)
              if (@char_buffer.empty? || !(accumulator + @char_buffer[0]).match(rule))
                found = Lexem.new(
                  col: @col, 
                  line: @line,
                  type: type, 
                  value: accumulator,
                )
              end # if cant get more chars or will broke the rule
            end # if we found a rule
          end # if we check string or regexp rule
          break if found
        end # each rule

        if accumulator[-1] == "\n"
          buffer_col = 1
          buffer_line += 1 
        else
          buffer_col += 1
        end # if

        break if found
      end # while character

      if !found
        found = Lexem.new(
          col: @col, 
          line: @line,
          type: nil, 
          value: accumulator, 
        )
      end # if

      if buffer_line > 0
        @col = buffer_col
        @line += buffer_line
      else
        @col += buffer_col
      end # if

      # Value postpocessing
      case found.type
      # Save ID as array of normalized strings
      when :ID then found.value = found.value.upcase.gsub('_', '').split('.')
      # Save string without quotes
      when :SMART_STRING, :STRING then found.value = found.value[1..-2]
      end

      case found.type
      when :COMMENT, :WORD_BREAK
        # puts "📘 #{"%-10s" % "#{found.line}:#{found.col}"} Consumed #{("%-12s" % found.type || 'unknown lexem')} #{found.value.inspect}"
        # Nothing to do
      when :DOC
        # puts "📗 #{"%-10s" % "#{found.line}:#{found.col}"} Consumed #{("%-12s" % found.type || 'unknown lexem')} #{found.value.inspect}"
        @docs << found.value[2..-1]
      when :WARN
        # puts "📕 #{"%-10s" % "#{found.line}:#{found.col}"} Consumed #{("%-12s" % found.type || 'unknown lexem')} #{found.value.inspect}"
        @warning_comments << found.value[2..-1]
      else
        @code << found
        break
      end # case
    end # loop

    return found
  end # parse_next_lexem

  def warning_comments
    @warning_comments
  end # warning_comments
end # Lexer