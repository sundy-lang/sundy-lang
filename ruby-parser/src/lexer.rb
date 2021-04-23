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
      @results[i] = Token.new(type: token.type, value: token.value.gsub(from, to)) if token_types.include?(token.type)
    end # each

    return self
  end # gsub

  def parse data
    raise("Rules is not acceptable") if !@rules_checked
    
    parsing_started_at = Time.now
    accumulator = ''
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
              if j > 0
                token_stats[nil] ||= 0
                token_stats[nil] += 1
                @results << Token.new(type: nil, value: accumulator[0 .. j - 1])
              end # if
              @results << Token.new(type: type, value: checking_string)
              token_stats[type] ||= 0
              token_stats[type] += 1
              accumulator = ''
              rule_found = true
              break
            end # if
          else # Regexp
            if checking_string.match(rule)
              rule_found = true
              if (i >= data.size - 1 || !(checking_string + data[i + 1]).match(rule))
                if j > 0
                  token_stats[nil] ||= 0
                  token_stats[nil] += 1
                  @results << Token.new(type: nil, value: accumulator[0 .. j - 1])
                end # if
                @results << Token.new(type: type, value: checking_string)
                token_stats[type] ||= 0
                token_stats[type] += 1
                accumulator = ''
                break
              end # if
            end # if
          end # if
        end # each checking_string

        break if rule_found
      end # each rule

      # raise("Unknown token: #{accumulator}") if !rule_found
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
      @results[i] = Token.new(type: token.value.to_sym) if tokenizable_strings.include?(token.value)
    end # each

    return self
  end # tokenize

  def upcase *token_types
    @results.each_with_index do |token, i|
      @results[i] = Token.new(type: token.type, value: token.value.upcase) if token_types.include?(token.type)
    end # each

    return self
  end # upcase
end # Lexer