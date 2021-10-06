module ConstantParser
  # EBNF: CONSTANT_DEFINITION_STATEMENT = LOCAL_ID COLON (INT | LOCAL_ID_VALUE | FUNCTION_CALL) EOLS.
  def consume_constant_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        if value = consume(:INT)
          if consume(:EOLS)
            return {
              type: 'CONSTANT_DEFINITION',
              name: name,
              value_type: 'INT',
              value: value.to_i,
            }
          end # if
        end # if

        if value = consume(:LOCAL_ID_VALUE)
          return {
            type: 'CONSTANT_DEFINITION',
            name: name,
            value_type: 'LOCAL_ID',
            value: value,
          }
        end # if

        if function_call = consume(:FUNCTION_CALL)
          return {
            type: 'CONSTANT_DEFINITION',
            name: name,
            value_type: function_call[:value_type],
            value: function_call,
          }
        end # if
      end # if
    end # if
  end # consume_constant_definition
end # ConstantParser