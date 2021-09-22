class Cli
  def initialize options = {}
    @options = options
    @options[:util] ||= 'sundy'
    @options[:extension] ||= 'sundy'

    @params = {
      'IN' => 'tmp',
      'OUT' => 'tmp',
    }
    key = nil
    @source_name = nil

    ARGV.each_with_index do |value, index|
      if ARGV.size - 1 == index
        @source_name = value
      elsif !key
        if value.index('--') == 0
          key = value.upcase[/[A-Z0-9\-]+/][2 .. -1]
        else
          usage_info
          puts "❗️ Wrong usage."
          exit
        end # if
      else
        if value.index('--') == 0
          @params[key] = nil
          key = value.upcase[/[A-Z0-9\-]+/][2 .. -1]
        else
          @params[key] = value
          key = nil
        end # if
      end # if
    end # each
    
    @params[key] = nil if key

    if !@source_name
      usage_info
      puts '❗️ Wrong usage, no source file name.'
      exit
    end # if
  end # initialize

  def destination_path
    @params['OUT']
  end # destination_path

  def release?
    !!@params['RELEASE']
  end # release?

  def source_extension
    @options[:extension]
  end # source_extension

  def source_name
    @source_name
  end # source_name

  def source_path
    @params['IN']
  end # source_path

  def usage_info
    puts "🔥 Usage: ./#{@options[:util]} --in examples --out tmp hello"
    puts "   #{'%-10s' % '--src'} Source file"
    puts "   #{'%-10s' % '--dest'} Output path"
    puts
  end # usage_info
end