require_relative 'base_node.rb'

class StringNode < BaseNode
  def initialize options = {}
    @value = options[:value].to_s
    super
  end

  def value
    @value
  end # value
end # StringNode