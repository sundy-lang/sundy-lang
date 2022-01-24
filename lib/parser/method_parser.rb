module MethodParser
  # EBNF METHOD_CALL = (LOCAL_ID | PARENT_ID | STATIC_ID | THIS_ID) METHOD_CALL_ARGS.
  # Return: {type: 'METHOD_CALL', name, args}
  def consume_method_call
    if name = consume([ :LOCAL_ID, :PARENT_ID, :STATIC_ID, :THIS_ID ])
      if args = consume(:METHOD_CALL_ARGS)
        return {
          type: 'METHOD_CALL',
          name: name[:value],
          args: args,
        }
      end # if
    end # if
  end # consume_method_call

  # EBNF METHOD_CALL_ARG = (VALUE | LOCAL_ID | STATIC_ID).
  def consume_method_call_arg
    if value = consume([ :VALUE, :LOCAL_ID, :STATIC_ID ])
      return value
    end # if
  end # consume_method_call_arg

  # EBNF METHOD_CALL_ARGS = OPEN_PRIORITY [EOLS] [METHOD_CALL_ARG <COMMA [EOLS] [METHOD_CALL_ARG]>] [EOLS] CLOSE_PRIORITY.
  # Return: [...]
  def consume_method_call_args
    if consume(:OPEN_PRIORITY)
      consume(:EOLS)
      args = []
      loop do
        if arg = consume(:METHOD_CALL_ARG)
          args << arg
          if consume(:COMMA)
            consume(:EOLS)
          else
            break
          end # if
        else
          break
        end # if
      end # loop
      consume(:EOLS)
      if consume(:CLOSE_PRIORITY)
        return args
      end # if
    end # if
  end # consume_method_call_args
  
  # EBNF LOCAL_ID COLON [EOLS] METHOD_DEFINITION_ARGS [EOLS] METHOD_DEFINITION_ELEMENTS LOCAL_ID EOLS.
  # Return: {type: 'METHOD_DEFINITION', name, args, elements}
  def consume_method_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        consume(:EOLS)
        if args = consume(:METHOD_DEFINITION_ARGS)
          consume(:EOLS)
          if elements = consume(:METHOD_DEFINITION_ELEMENTS)
            if end_name = consume(:LOCAL_ID)
              if end_name[:value] == name[:value]
                if consume(:EOLS)
                  return {
                    type: 'METHOD_DEFINITION',
                    name: name[:value],
                    args: args,
                    elements: elements,
                  }
                end # if
              end
            end # if
          end # if
        end # if
      end # if
    end # if
  end # consume_method_definition

  # EBNF METHOD_DEFINITION_ARG = LOCAL_ID COLON [EOLS] [IN | OUT | OMNI] METHOD_DEFINITION_ARG_TYPE.
  # Return: {direction, name, value_type}
  def consume_method_definition_arg
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        consume(:EOLS)
        direction = consume([:IN, :OMNI, :OUT])

        if value_type = consume(:METHOD_DEFINITION_ARG_TYPE)
          return {
            direction: (direction ? direction[:value] : 'IN').upcase,
            name: name[:value],
            value_type: value_type,
          }
        end # if
      end # if
    end # if
  end # consume_method_definition_arg

  # EBNF METHOD_DEFINITION_ARG_TYPE = (VALUE | ((LOCAL_ID | STATIC_ID) [OPEN_PRIORITY [METHOD_DEFINITION_ARG_TYPE] CLOSE_PRIORITY])).
  # Return: {...=>...}
  def consume_method_definition_arg_type
    if value = consume(:VALUE)
      return value[:value] #{ value[:type] => value[:value] }
    elsif type = consume([:LOCAL_ID, :STATIC_ID])
      if consume(:OPEN_PRIORITY)
        sub_type = consume(:METHOD_DEFINITION_ARG_TYPE)
        if consume(:CLOSE_PRIORITY)
          return { type[:value] => sub_type }
        end # if
      else
        return { type[:value] => nil }
      end # if
    end # if
  end # consume_method_definition_arg_type
  
  # EBNF METHOD_DEFINITION_ARGS = OPEN_PRIORITY [EOLS] [METHOD_DEFINITION_ARG <COMMA [EOLS] METHOD_DEFINITION_ARG>] [EOLS] CLOSE_PRIORITY.
  # Return: [...]
  def consume_method_definition_args
    if consume(:OPEN_PRIORITY)
      consume(:EOLS)
      args = []
      loop do
        if arg = consume(:METHOD_DEFINITION_ARG)
          args << arg
          if consume(:COMMA)
            consume(:EOLS)
          else
            break
          end # if
        else
          break
        end # if
      end # loop
      consume(:EOLS)
      if consume(:CLOSE_PRIORITY)
        return args
      end # if
    end # if
  end # consume_method_definition_args

  # EBNF METHOD_DEFINITION_ELEMENTS = OPEN_BLOCK <[CONSTANT_DEFINITION | IF_STATEMENT | METHOD_CALL | RETURN] EOLS> CLOSE_BLOCK.
  # Return: [...]
  def consume_method_definition_elements
    if consume(:OPEN_BLOCK)
      elements = []
      loop do
        if element = consume([ :CONSTANT_DEFINITION, :IF_STATEMENT, :METHOD_CALL, :RETURN ])
          if consume(:EOLS)
            elements << element
          end # if
        elsif !consume(:EOLS)
          break
        end # if
      end # loop
      if consume(:CLOSE_BLOCK)
        return elements
      end # if
    end # if
  end # consume_method_definition_elements
end # MethodParser