module ModuleParser
  # EBNF: MODULE_DEFINITION_NODE
  def consume_module_definition
    if name = consume(:LOCAL_ID)
      if consume(:COLON)
        if elements = consume(:MODULE_ELEMENTS)
          return {
            type: 'MODULE_DEFINITION',
            name: name,
            constants: elements[:constants],
            functions: elements[:functions],
            modules: elements[:modules],
          }
        end # if
      end # if
    end # if
  end # consume_module_definition_node

  # EBNF: MODULE_ELEMENTS = {EOLS | CONSTANT_DEFINITION | FUNCTION_DEFINITION | MODULE_DEFINITION}.
  def consume_module_elements
    constants = []
    functions = []
    modules = []

    loop do
      consume(:EOLS)
      if element = consume(:CONSTANT_DEFINITION)
        constants << element
      elsif element = consume(:FUNCTION_DEFINITION)
        functions << element
      elsif element = consume(:MODULE_DEFINITION)
        modules << element
      else
        break
      end # if
    end # loop

    if !constants.empty? || !functions.empty? || !modules.empty?
      return {
        constants: constants,
        functions: functions,
        modules: modules,
      }
    end # if
  end # consume_module_elements
end # ModuleParser