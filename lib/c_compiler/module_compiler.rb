module ModuleCompiler
  def compile_module_definition branch
    branch[:modules].each do |mod|
      compile(mod)
    end # each

    branch[:functions].each do |function|
      compile(function)
    end # each
  end # compile_module_definition
end