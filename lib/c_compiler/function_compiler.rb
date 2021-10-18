module FunctionCompiler
  def compile_function_call branch
    if branch[:name][0] == 'SANDBOX'
      case branch[:name][1]
      when 'SHOW'
        @includes << '<stdio.h>' if !@includes.include?('<stdio.h>')
        "printf(\"%s\", #{branch[:body].map{|r| r[:name]}.join(', ')})"
      end # case
    else
      "#{branch[:full_name]}(#{branch[:body].map{|r| r[:name]}.join(', ')})"
    end # if
  end # compile_function_call

  def compile_function_definition branch
    if branch[:name] == 'THIS'
      # TODO
    elsif branch[:name][0..4] == 'THIS.'
      # TODO
    else
      args = {}

      branch[:args].each do |arg|
        arg_type = get_type(arg[:value_type][:name])

        if arg[:value_type][:body]
          arg_sub_type = get_type(arg[:value_type][:body].first[:name]) + ' '
        end # if

        case arg_type
        when '[]'
          args[arg[:name]] = "#{arg_sub_type}#{arg[:name]}#{arg_type}"
        else
          args[arg[:name]] = "#{arg_type} #{arg[:name]}"
        end # case
      end # each

      body = []
      branch[:body].each do |child|
        if instruction = compile(child)
          body << instruction
        else
          raise "Cant't compile function instruction for #{JSON.generate(child)}"
        end
      end # each  

      @functions[branch[:full_name]] = {
        args: args,
        body: body,
        value_type: branch[:value_type],
      }
    end # if
  end # compile_function_definition

  def compile_return branch
    case branch[:value_type]
    when 'INTEGER' then "return #{branch[:value]}"
    when 'LOCAL_ID' then "return #{branch[:value]}"
    end # case
  end # compile_function_return
end