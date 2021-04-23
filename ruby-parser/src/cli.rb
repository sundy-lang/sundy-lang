require_relative 'lexer.rb'
require_relative 'sundy.rb'

class Cli
  def initialize
    @params = {}
    key = nil

    ARGV.each do |value|
      if !key
        if value.index('--') == 0
          key = value.upcase[/[A-Z0-9\-]+/]
        else
          usage_info
          raise "Wrong usage!"
        end # if
      else
        if value.index('--') == 0
          @params[key] = nil
          key = value.upcase[/[A-Z0-9\-]+/]
        else
          @params[key] = value
          key = nil
        end # if
      end # if
    end # each
    
    @params[key] = nil if key

    if !@params['--SRC'] || !File.exists?(@params['--SRC'])
      usage_info
      raise 'Wrong usage, no source file!'
    end # if

    if match = @params['--SRC'].upcase.match(/([A-Z0-9_]+)(\.[A-Z]+)*\z/)
      @root_namespace = match[1]
    else
      usage_info
      raise 'Wrong source file name format!'
    end # if

    greeting
  end # initialize

  def compile
    # TO DO

    return self
  end # compile

  def greeting
    puts '🌈 Sundy v0.0.1'
    puts '🛠  by Nick V. Nizovtsev'
    puts "🤠 Process #{@root_namespace} package..."
    puts
  end # greeting

  def grow_ast
    # TO DO

    return self
  end # grow_ast

  def tokenize
    @lexer = Lexer.new(
      Sundy.lexer_rules
    ).parse_file(
      @params['--SRC']
    ).upcase(
      :ID
    ).gsub(
      /_/, '', :ID
    ).tokenize(
      Sundy.reserved_identifiers, :ID
    )

    @tokens = @lexer.results
    @lexer_stats = @lexer.stats

    puts "🤠 Lexer parsing average speed is #{@lexer_stats[:speed]} b/s"
    puts "🤠 Found #{@tokens.size} tokens"

    if @params.has_key?('--VERBOSE')
      Sundy.lexer_rules.values.map{|type| type.is_a?(Symbol) ? type : nil}.compact.sort.uniq.each do |type|
        if @lexer_stats[:tokens][type].to_i > 0
          puts "   #{"%-8d" % @lexer_stats[:tokens][type].to_i} #{type}"
        end # if
      end # each
      puts
    end # if

    if @lexer_stats[:tokens][nil]
      puts '🤠 Unknown tokens:'
      @tokens.each do |token|
        puts "🤠    #{token.value.inspect}" if !token.value
      end # each
      puts
      raise 'Unknown tokens found!' 
    end # if

    if @params['--DOC']
      if f = File.new(@params['--DOC'], 'w')
        @tokens.each do |token|
          if [:DOC].include?(token.type)
            f.puts token.value[2..-1].strip
          end # if
        end # each
        f.close
      else
        raise "Can't save the doc file '#{@params['--DOC']}'"
      end # if
      puts
    end # if

    @code_tokens = []
    previous_value = nil
    @tokens.each do |token|
      if ![nil, :COMMENT, :DOC].include?(token.type) && (previous_value != token.type || ![:EOL].include?(token.type))
        previous_value = token.type
        @code_tokens << token
      end # if
    end # each

    if @params['--LEX']
      if f = File.new(@params['--LEX'], 'w')
        @tokens.each do |token|
          value = token.value.strip
          f.puts "#{token.type}#{value.empty? ? '' : "(#{value})"}"
        end # each
        f.close
      end # if
    end # if

    return self
  end # tokenize

  def transpile
    # TO DO

    return self
  end # transpile

  def usage_info
    puts '🔥  Usage: ./ruby-parser --src examples/hello.sundy --doc tmp/hello.md'
    puts "#{'%10s' % '--src'} source file path"
    puts "#{'%10s' % '--lex'} lexer results file path"
    puts "#{'%10s' % '--doc'} extract special comments to a text file"
    puts "#{'%10s' % '--verbose'} show verbose information"
    puts
  end # usage_info
end