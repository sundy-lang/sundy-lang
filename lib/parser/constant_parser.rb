module ConstantParser
  # EBNF: CONSTANT_DEFINITION_STATEMENT = LOCAL_ID COLON (INTEGER | FN_CALL_STATEMENT) EOL.
  def consume_constant_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        if value = consume(:INT)
          return {
            type: 'CONSTANT_DEFINITION',
            name: name,
            value_type: 'INT',
            value: value.to_i,
          }
        elsif function_call = consume(:FUNCTION_CALL)
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