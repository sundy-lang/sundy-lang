module ModuleCompiler
  def parse_module_definition branch
    branch[:functions].each do |function|
      parse(function)
    end # each
  end # parse_module_definition
end