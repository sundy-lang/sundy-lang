module TypeParser
  # EBNF TYPE_DEFINITION = LOCAL_ID COLON [EOLS] [TYPE_IDS] [EOLS] TYPE_DEFINITION_ELEMENTS LOCAL_ID EOLS.
  # Return: {type: 'TYPE_DEFINITION', name, parents, childs}
  def consume_type_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        consume(:EOLS)
        parents = consume(:TYPE_IDS)
        consume(:EOLS)
        if childs = consume(:TYPE_DEFINITION_ELEMENTS)
          if name == consume(:LOCAL_ID)
            if consume(:EOLS)
              return {
                type: 'TYPE_DEFINITION',
                name: name,
                parents: parents,
                childs: childs,
              }
            else
              @errors << "[#{lexem_coords}] No EOL at the end of '#{name}' type"
              return
            end
          else
            @errors << "[#{lexem_coords}] Wrond name for end of '#{name}' type"
            return
          end # if
        end # if
      end # if
    end # if
  end # consume_type_definition

  # EBNF: TYPE_DEFINITION_ELEMENTS = OPEN_BLOCK <EOL | CONSTANT_DEFINITION | METHOD_DEFINITION | TYPE_DEFINITION> CLOSE_BLOCK.
  # Return: [...]
  def consume_type_definition_elements
    if consume(:OPEN_BLOCK)
      childs = []
      loop do
        if child = consume([ :CONSTANT_DEFINITION, :METHOD_DEFINITION, :TYPE_DEFINITION ])
          childs << child
        elsif !consume(:EOLS)
          break
        end # if
      end # loop
      if consume(:CLOSE_BLOCK)
        return childs
      end # if
    end # if
  end # consume_type_definition_elements

  # EBNF TYPE_IDS = (LOCAL_ID | STATIC_ID) <COMMA [EOLS] (LOCAL_ID | STATIC_ID)>.
  def consume_type_ids
    types = []
    loop do
      if type = consume(:LOCAL_ID, :STATIC_ID)
        types << type

        if consume(:COMMA)
          consume(:EOLS)
        else
          break
        end # if
      else
        break
      end # if
    end # loop
    return types
  end # consume_type_ids
end # TypeParser