module ModuleCompiler
  def parse_module_definition branch
    branch[:modules].each do |mod|
      parse(mod)
    end # each

    branch[:functions].each do |function|
      parse(function)
    end # each
  end # parse_module_definition
end