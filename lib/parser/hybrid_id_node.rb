require_relative 'base_node.rb'

class HybridIdNode < BaseNode
  # EBNF: HYBRID_ID = ((THIS DOT LOCAL_ID) | LOCAL_ID) {DOT LOCAL_ID}.
  def self.parse lexer
    saved_code_index = lexer.lexem_index
    id = []

    if lexem = lexer.consume([:LOCAL_ID, :THIS])
      id << lexem[:value]
      loop do
        break if !lexer.consume(:DOT)

        lexem = lexer.consume(:LOCAL_ID)
        break if !lexem

        id << lexem[:value]
      end # loop
    end # if

    return id.upcase if !id.empty?

    lexer.lexem_index = saved_code_index
    return
  end # self.parse_hybrid

  # EBNF: HYBRID_ID_LIST = HYBRID_ID {COMMA {EOL} HYBRID_ID}.
  def self.parse_list lexer
    saved_code_index = lexer.lexem_index
    ids = []

    loop do
      if id = self.parse(lexer)
        ids << id
        break if !lexer.consume(:COMMA)
      else
        break
      end # if

      BaseNode.parse_eols(lexer)
    end # loop

    return ids if !ids.empty?
  
    lexer.lexem_index = saved_code_index
    return nil
  end # self.parse_list

  def initialize options = {}
    @value = options[:value].to_s.upcase
    super
  end

  def value
    @value
  end # value
end # HybridIdNode