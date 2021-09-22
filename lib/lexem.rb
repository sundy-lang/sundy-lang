class Lexem
  def initialize options = {}
    # raise "Unknown type #{options[:type].inspect}" if !options[:type].is_a?(Symbol)
    
    @col = options[:col]
    @line = options[:line]
    @type = options[:type]
    @value = options[:value]
  end # initialize

  def col
    @col
  end # col

  def line
    @line
  end # line

  def type
    @type
  end # type

  def value
    @value
  end # value

  def value= new_value
    @value = new_value
  end # value=
end # Lexem