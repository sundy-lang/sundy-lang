class Token
  def initialize options = {}
    raise "Unknown type #{options[:type].inspect}" if !options[:type].is_a?(Symbol)
    
    @type = options[:type]
    @value = options[:value]
  end # initialize

  def type
    @type
  end # type

  def value
    @value
  end # value
end # Token