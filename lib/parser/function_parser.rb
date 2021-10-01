module FunctionParser
  # EBNF: FUNCTION_DEFINITION = LOCAL_ID COLON FUNCTION_DESCRIPTION EOLS FUNCTION_BODY EOLS END LOCAL_ID EOL.
  def consume_function_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        value_type, args = consume(:FUNCTION_DESCRIPTION)
        if value_type && args
          consume(:EOLS)
          if body = consume(:FUNCTION_BODY)
            consume(:EOLS)
            if consume(:END)
              if end_name = consume(:LOCAL_ID)
                if name == end_name
                  if consume(:EOL)
                    return {
                      type: 'FUNCTION_DEFINITION',
                      name: name,
                      value_type: value_type,
                      args: args,
                      body: body,
                    }
                  end # if
                end # if
              end # if
            end # if
          end # if
        end # if
      end # if
    end # if
  end # consume_function_definition_node

  # EBNF: FN_ARGS_DECLARATION = LOCAL_ID COLON FN_ARG_TYPE {COMMA EOLS LOCAL_ID COLON FN_ARG_TYPE}.
  def consume_function_args_declaration
    args = []

    loop do
      if args.empty? || consume(:COMMA)
        consume(:EOLS)
        if name = consume(:LOCAL_ID)
          if consume(:COLON)
            if type = consume(:FUNCTION_ARG_TYPE)
              args << {
                type: 'FUNCTION_ARG_DEFINITION',
                name: name,
                value_type: type,
              }
            end # if
          end # if
        end # if

        return if !name
      else
        break
      end # if
    end # loop

    return args if !args.empty?
  end # consume_function_args_declaration

  # FUNCTION_ARG_TYPE = LOCAL_ID [OPEN_PRIORITY_BRACE EOLS (FUNCTION_ARG_TYPE | PRIMITIVE_VALUE) EOLS CLOSE_PRIORITY_BRACE].
  def consume_function_arg_type
    if name = consume(:LOCAL_ID)
      if consume(:OPEN_PRIORITY_BRACE)
        consume(:EOLS)
        if value = consume(:FUNCTION_ARG_TYPE)
          consume(:EOLS)

          if consume(:CLOSE_PRIORITY_BRACE)
            return {
              type: 'TYPE',
              name: name,
              body: [ value ],
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
  end # consume_function_arg_type

  # EBNF: FUNCTION_BODY = {CONSTANT_DEFINITION | RETURN | EOL}.
  def consume_function_body
    body = []

    loop do
      if consume(:EOLS)
      elsif statement = consume(:FUNCTION_RETURN)
        body << statement
      elsif statement = consume(:CONSTANT_DEFINITION)
        body << statement
      else break
      end # if
    end # loop

    return body if !body.empty?
  end # consume_function_body

  # EBNF: FUNCTION_DESCRIPTION = LOCAL_ID OPEN_PRIORITY_BRACE EOLS [FUNCTION_ARGS_DECLARATION] EOLS CLOSE_PRIORITY_BRACE EOL.
  def consume_function_description
    if value_type = consume(:LOCAL_ID)
      if consume(:OPEN_PRIORITY_BRACE)
        consume(:EOLS)
        args = consume(:FUNCTION_ARGS_DECLARATION)
        consume(:EOLS)

        if consume(:CLOSE_PRIORITY_BRACE)
          if consume(:EOL)
            return [
              value_type, 
              args
            ]
          end # if
        end # if
      end # if
    end # if
  end # consume_function_description

  # EBNF: FUNCTION_DESCRIPTION = LOCAL_ID OPEN_PRIORITY_BRACE EOLS [FUNCTION_CALL_ARGS] EOLS CLOSE_PRIORITY_BRACE EOL.
  def consume_function_call
    if name = consume(:LOCAL_ID)
      if consume(:OPEN_PRIORITY_BRACE)
        consume(:EOLS)
        args = consume_function_call_args
        consume(:EOLS)

        if consume(:CLOSE_PRIORITY_BRACE)
          if consume(:EOL)
            return {
              type: 'FUNCTION_CALL',
              name: name, 
              body: args,
            }
          end # if
        end # if
      end # if
    end # if
  end # consume_function_call

  # EBNF: FUNCTION_CALL_ARGS = LOCAL_ID {COMMA EOLS LOCAL_ID}.
  def consume_function_call_args
    args = []

    loop do
      if args.empty? || consume(:COMMA)
        consume(:EOLS)
        if name = consume(:LOCAL_ID)
          args << {
            type: 'LOCAL_ID',
            name: name,
          }
        else
          return
        end
      else
        break
      end # if
    end # loop

    return args if !args.empty?
  end # consume_function_call_args

  # EBNF: RETURN = "RETURN" (PRIMITIVE_VALUE | LOCAL_ID) EOL.
  def consume_function_return
    if consume(:RETURN)
      if value = consume(:PRIMITIVE_VALUE)
        return {
          type: 'RETURN',
          value_type: value[:type],
          value: value[:value],
        }
      elsif value = consume(:LOCAL_ID)
        return {
          type: 'RETURN',
          value_type: 'LOCAL_ID',
          value: value,
        }
      end # if
    end # if
  end # consume_function_return
end # FunctionParser