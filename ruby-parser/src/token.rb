class Token
  def initialize options = {}
    # raise "Unknown type #{options[:type].inspect}" if !options[:type].is_a?(Symbol)
    
    @char_num = options[:char_num]
    @line_num = options[:line_num]
    @type = options[:type]
    @value = options[:value]
  end # initialize

  def char_num
    @char_num
  end # char_num

  def line_num
    @line_num
  end # line_num

  def type
    @type
  end # type

  def value
    @value
  end # value
end # Token