require_relative 'token.rb'

class Lexer
  def initialize rules # {RULE: TYPE_OR_ACTION}
    @results = []
    @rules = rules
    @stats = {}

    # Checking of rules
    @rules_checked = if @rules.is_a?(Hash) && !@rules.empty?
      @rules.each do |rule, type|
        break if !((type.is_a?(Symbol) || type.is_a?(Proc)) && (rule.is_a?(String) || rule.is_a?(Regexp)))
      end # each

      true
    end # if

  end # initialize

  def gsub from, to, *token_types
    @results.each_with_index do |token, i|
      @results[i] = Token.new(
        char_num: token.char_num, 
        line_num: token.line_num,
        type: token.type, 
        value: token.value.gsub(from, to)
      ) if token_types.include?(token.type)
    end # each

    return self
  end # gsub

  def parse data
    raise("Rules is not acceptable") if !@rules_checked
    
    parsing_started_at = Time.now
    
    accumulator = ''
    char_num = 1
    from_char_num = 1
    from_line_num = 1
    line_num = 1
    token_stats = {}

    (0 .. data.size - 1).each do |i|
      accumulator << data[i]
      rule_found = false

      @rules.each do |rule, type|
        (0 .. accumulator.size - 1).each do |j|
          checking_string = accumulator[j .. accumulator.size - 1]
          if rule.is_a?(String)
            # rule_found = true if rule.index(accumulator) == 0
            if rule == checking_string
              # Save unknown token from the left part of accumulator
              if j > 0
                @results << Token.new(
                  char_num: from_char_num, 
                  line_num: from_line_num,
                  type: nil, 
                  value: accumulator[0 .. j - 1]
                )
                token_stats[nil] ||= 0
                token_stats[nil] += 1
                if data[i] == "\n"
                  from_char_num = 1
                  from_line_num = line_num + 1 
                else
                  from_char_num = char_num + 1
                  from_line_num = line_num  
                end # if
              end # if

              # Save token from the right part of accumulator
              @results << Token.new(
                char_num: from_char_num, 
                line_num: from_line_num,
                type: type, 
                value: checking_string
              )
              token_stats[type] ||= 0
              token_stats[type] += 1
              accumulator = ''
              from_char_num = char_num + 1
              from_line_num = line_num
              if data[i] == "\n"
                from_char_num = 1
                from_line_num = line_num + 1 
              else
                from_char_num = char_num + 1
                from_line_num = line_num  
              end # if
              rule_found = true
              break
            end # if
          else # Regexp
            if checking_string.match(rule)
              rule_found = true
              if (i >= data.size - 1 || !(checking_string + data[i + 1]).match(rule))
                # Save unknown token from the left part of accumulator
                if j > 0
                  @results << Token.new(
                    char_num: from_char_num, 
                    line_num: from_line_num,
                    type: nil, 
                    value: accumulator[0 .. j - 1], 
                  )
                  token_stats[nil] ||= 0
                  token_stats[nil] += 1
                  from_char_num = char_num + 1
                  from_line_num = line_num
                  if data[i] == "\n"
                    from_char_num = 1
                    from_line_num = line_num + 1 
                  else
                    from_char_num = char_num + 1
                    from_line_num = line_num  
                  end # if
                end # if

                # Save token from the right part of accumulator
                @results << Token.new(
                  char_num: from_char_num, 
                  line_num: from_line_num,
                  type: type, 
                  value: checking_string
                )
                token_stats[type] ||= 0
                token_stats[type] += 1
                accumulator = ''
                from_char_num = char_num + 1
                from_line_num = line_num
                if data[i] == "\n"
                  from_char_num = 1
                  from_line_num = line_num + 1 
                else
                  from_char_num = char_num + 1
                  from_line_num = line_num  
                end # if
                rule_found = true
                break
              end # if
            end # if
          end # if
        end # each checking_string

        break if rule_found
      end # each rule

      # puts "#{line_num}:#{char_num} > #{accumulator} > #{@results.last.inspect}"
      if data[i] == "\n"
        char_num = 1
        line_num += 1 
      else
        char_num += 1
      end # if

      # raise("Unknown token at #{line_num}:#{char_num} - #{accumulator}") if !rule_found
    end # each character

    @results << {type: accumulator, value: nil} if !accumulator.empty?

    @stats[:tokens] = token_stats
    @stats[:data_size] = data.size
    @stats[:time] = Time.now - parsing_started_at
    @stats[:speed] = (data.size / @stats[:time]).to_i

    return self
  end # parse

  def parse_file filename
    raise("File not found: #{filename}") if !File.exists?(filename)

    if f = File.new(filename, 'r')
      data = f.read
      f.close
      return parse(data)
    else raise("Can't open the file: #{filename}")
    end # if
  end # parse_file

  def results
    @results
  end # results

  def stats
    @stats
  end # stats

  def tokenize list, *tokenizable_strings
    @results.each_with_index do |token, i|
      @results[i] = Token.new(
        char_num: token.char_num, 
        line_num: token.line_num,
        type: token.value.to_sym
      ) if tokenizable_strings.include?(token.value)
    end # each

    return self
  end # tokenize

  def upcase *token_types
    @results.each_with_index do |token, i|
      @results[i] = Token.new(
        char_num: token.char_num, 
        line_num: token.line_num,
        type: token.type, 
        value: token.value.upcase
      ) if token_types.include?(token.type)
    end # each

    return self
  end # upcase
end # Lexer