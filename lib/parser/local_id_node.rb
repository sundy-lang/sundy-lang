require_relative 'base_node.rb'

class LocalIdNode < BaseNode
  # EBNF 0.0.1:
  # LOCAL_ID = {LATIN_LETTER | UNDERSCORE} {LATIN_LETTER | DECIMAL_DIGIT | UNDERSCORE}.
  def self.parse parser
    saved_code_index = parser.lexem_index

    if lexem = parser.consume(:LOCAL_ID)
      return lexem[:value].upcase
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse

  # EBNF: LOCAL_ID_LIST = LOCAL_ID {COMMA {EOL} LOCAL_ID}.
  def self.parse_list parser
    saved_code_index = parser.lexem_index
    ids = []

    loop do
      if id = self.parse
        ids << id
        break if !parser.consume(:COMMA)
      else
        break
      end # if

      BaseNode.parse_eols(parser)
    end # loop

    return ids if !ids.empty?
  
    parser.lexem_index = saved_code_index
    return nil
  end # self.parse_list

  def initialize options = {}
    @value = options[:value].to_s.upcase
    super
  end

  def value
    @value
  end # value
end # LocalIdNode