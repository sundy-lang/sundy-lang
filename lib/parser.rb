require_relative 'parser/module_node.rb'

## EBNF v0.0.1:
#  FILE = {MODULE_ELEMENT} EOF.
#  MODULE_ELEMENT = EOL | FN.
#  FN = LOCAL_ID COLON FN_DESCRIPTION {EOL} FN_BODY {EOL} END LOCAL_ID EOL.
#  FN_DESCRIPTION = LOCAL_ID OPEN_PRIORITY_BRACE {EOL} [FN_ARGS_DECLARATION] {EOL} CLOSE_PRIORITY_BRACE EOL.
#  FN_ARGS_DECLARATION = LOCAL_ID COLON FN_ARG_TYPE {COMMA {EOL} LOCAL_ID COLON FN_ARG_TYPE}.
#  FN_ARG_TYPE = LOCAL_ID [OPEN_PRIORITY_BRACE {EOL} [FN_ARG_TYPE | CONST_VALUE] {EOL} CLOSE_PRIORITY_BRACE].
#  CONST_VALUE = INTEGER.
#  FN_BODY = {RETURN_STATEMENT}.
#  RETURN_STATEMENT = RETURN CONST_VALUE.

# Code example for v0.0.1:
# main: u32(argc: u32, argv: list(string));
#   return 0;
# end main;

class Parser
  def initialize options
    @root_node = {
      type: 'MODULE',
      name: options[:source_name].upcase.gsub('_', '').gsub('/', '.'),
      childs: [],
    }

    @current_node = @root_node
    @lexem_buffer = options[:lexems]
    @lexem_index = 0
  end # initialize

  def ast
    @root_node
  end

  # Get lexems from code buffer
  def consume expected = nil
    lexem = @lexem_buffer[@lexem_index]

    if expected.is_a?(Array)
      lexem = nil if !expected.include?(lexem[:type].to_sym)
    elsif expected.is_a?(Symbol)
      lexem = nil if expected != lexem[:type].to_sym
    end # if

    # if lexem
    #   puts "CONSUMED #{lexem.inspect}"
    # else
    #   puts "CHECKED #{expected.inspect} FROM #{@lexem_buffer[@lexem_index].inspect}"
    # end # if 

    @lexem_index += 1 if lexem

    return lexem
  end # consume

  def current_node
    @current_node
  end # current_node

  def lexem_index
    @lexem_index
  end # lexem_index

  def lexem_index= value
    @lexem_index = value
  end # lexem_index=

  def parse
    while @lexem_index < @lexem_buffer.size
      if element = ModuleNode.parse_element(self, parent: @root_node)
        @root_node[:childs] << element if element.is_a?(Hash)
      else
        raise "Can't parse #{@root_node[:name]} module at #{@lexem_buffer[@lexem_index][:line]}:#{@lexem_buffer[@lexem_index][:col]}"
      end
    end # while
  end # parse

  def root_node
    @root_node
  end # root_node
end # Parser