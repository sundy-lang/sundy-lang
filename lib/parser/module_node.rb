require_relative 'base_node.rb'
require_relative 'fn_node.rb'

class ModuleNode < BaseNode
  # EBNF 0.0.1:
  # MODULE_ELEMENT = EOL | FN.
  def self.parse_element parser, options = {}
    BaseNode.parse_eols(parser) ||
    FnNode.parse(parser)
  end # parse_element
end # ModuleNode