module ValueParser
  # EBNF VALUE = FALSE | FLOAT | INT | STRING | TRUE.
  # Return: {type, value}
  def consume_value
    type, value = if value = consume(:INT)
      [ 'I32', value.to_i ]
    elsif value = consume(:FLOAT)
      [ 'F64', value.to_f ]
    elsif value = consume(:STRING)
      [ 'STRING', value.to_s ]
    elsif value = consume(:FALSE)
      [ 'BOOL', false ]
    elsif value = consume(:TRUE)
      [ 'BOOL', true ]
    else
      return
    end # if

    return {
      type: type,
      value: value,
    }
  end # consume_value
end # ValueParser