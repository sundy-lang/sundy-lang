require_relative 'hybrid_id_node.rb'
require_relative 'local_id_node.rb'

class FnNode < BaseNode
  # EBNF 0.0.1:
  # FN = LOCAL_ID COLON FN_DESCRIPTION {EOL} FN_BODY {EOL} END LOCAL_ID EOL.
  def self.parse parser, options = {}
    saved_code_index = parser.lexem_index

    if name = LocalIdNode.parse(parser)
      if parser.consume(:COLON)
        return_type, args = self.parse_description(parser)
        if return_type && args
          BaseNode.parse_eols(parser)
          if body = self.parse_body(parser)
            BaseNode.parse_eols(parser)
            if parser.consume(:END)
              if end_name = LocalIdNode.parse(parser)
                if name == end_name
                  if parser.consume(:EOL)
                    return {
                      type: 'FN',
                      name: name,
                      return_type: return_type,
                      args: args,
                      childs: body,
                    }
                  end # if
                end # if
              end # if
            end # if
          end # if
        end # if
      end # if
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse

  # EBNF 0.0.1:
  # FN_ARGS_DECLARATION = LOCAL_ID COLON FN_ARG_TYPE {COMMA {EOL} LOCAL_ID COLON FN_ARG_TYPE}.
  def self.parse_args_declaration parser
    saved_code_index = parser.lexem_index
    args = {}

    loop do
      if args.empty? || parser.consume(:COMMA)
        BaseNode.parse_eols(parser)
        if name = LocalIdNode.parse(parser)
          if !args[name]
            if parser.consume(:COLON)
              if type = self.parse_arg_type(parser)
                args[name] = type
              end # if
            end # if
          end # if
        end # if

        return if !name
      else
        break
      end # if
    end # loop

    if !args.empty?
      return args
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse_args_declaration

  # EBNF 0.0.1:
  # FN_ARG_TYPE = LOCAL_ID [OPEN_PRIORITY_BRACE {EOL} (FN_ARG_TYPE | CONST_VALUE) {EOL} CLOSE_PRIORITY_BRACE].
  def self.parse_arg_type parser
    saved_code_index = parser.lexem_index

    if name = LocalIdNode.parse(parser)
      if parser.consume(:OPEN_PRIORITY_BRACE)
        BaseNode.parse_eols(parser)
        if value = parser.consume(:INTEGER) ||
                   self.parse_arg_type(parser)
          BaseNode.parse_eols(parser)

          if parser.consume(:CLOSE_PRIORITY_BRACE)
            return {
              type: 'TYPE',
              name: name,
              value: value,
            }
          end # if
        end # if
      else
        return {
          type: 'TYPE',
          name: name,
        }
      end # if
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse_arg_type

  # EBNF 0.0.1:
  # FN_BODY = {RETURN_STATEMENT | EOL}.
  def self.parse_body parser
    saved_code_index = parser.lexem_index
    body = []

    loop do
      if BaseNode.parse_eols(parser)
      elsif sentence = self.parse_return_statement(parser)
        body << sentence
      else break
      end # if
    end # loop

    if !body.empty?
      return body
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse_body

  # EBNF 0.0.1:
  # FN_DESCRIPTION = LOCAL_ID OPEN_PRIORITY_BRACE {EOL} [FN_ARGS_DECLARATION] {EOL} CLOSE_PRIORITY_BRACE EOL.
  def self.parse_description parser
    saved_code_index = parser.lexem_index

    if return_type = LocalIdNode.parse(parser)
      if parser.consume(:OPEN_PRIORITY_BRACE)
        BaseNode.parse_eols(parser)
        args = FnNode.parse_args_declaration(parser)
        # puts '>>>'
        # puts args.inspect
        BaseNode.parse_eols(parser)

        if parser.consume(:CLOSE_PRIORITY_BRACE)
          if parser.consume(:EOL)
            return [
              return_type, 
              args
            ]
          end # if
        end # if
      end # if
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse_description

  # EBNF 0.0.1:
  # RETURN_STATEMENT = RETURN INTEGER EOL.
  def self.parse_return_statement parser
    saved_code_index = parser.lexem_index

    if parser.consume(:RETURN)
      if value = parser.consume(:INTEGER)
        return {
          type: 'RETURN',
          value_type: 'INTEGER',
          value: value[:value].to_i,
        }
      end # if
    end # if

    parser.lexem_index = saved_code_index
    return
  end # self.parse_return_statement

  def initialize options = {}
    super
  end # initialize

  def args
    @args
  end # args

  def name
    @name
  end # name

  def return_type
    @return_type
  end # return_type
end # FnNode