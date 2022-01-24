module ConstantParser
  # EBNF: CONSTANT_DEFINITION = LOCAL_ID COLON VALUE EOLS.
  def consume_constant_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        if value = consume(:VALUE)
          if consume(:EOLS)
            return {
              type: 'CONSTANT_DEFINITION',
              name: name[:value],
              value_type: value[:type],
              value: value[:value],
            }
          end # if
        end # if
      end # if
    end # if
  end # consume_constant_definition
end # ConstantParser