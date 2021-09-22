class BaseNode
  # EBNF: {EOL}
  def self.parse_eols parser
    i = 0

    loop do
      if parser.consume(:EOL)
        i += 1 
      else
        break
      end # if
    end # loop

    return i > 0 ? true : nil
  end # self.parse_eols
end # BaseNode