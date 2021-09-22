require_relative 'base_node.rb'

class IntegerNode < BaseNode
  def initialize options = {}
    @value = case options[:from]
    when :BIN then options[:value][2..-1].to_i(2)
    when :OCT then options[:value][2..-1].to_i(8)
    when :HEX then then options[:value][2..-1].to_i(16)
    else # :INTEGER
      options[:value].to_i
    end # case

    super
  end

  def value
    @value
  end # id
end # IntegerNode