module ValueParser
  # EBNF VALUE = FALSE | FLOAT | INT | STRING | TRUE.
  # Return: {type, value}
  def consume_value
    return consume([ :FALSE, :FLOAT, :INT, :STRING, :TRUE ])
  end # consume_value
end # ValueParser