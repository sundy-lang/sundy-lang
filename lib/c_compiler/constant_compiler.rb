module ConstantCompiler
  def parse_constant_definition branch
    case branch[:value_type] || branch[:value][:type]
    when 'FUNCTION_CALL' then "int #{branch[:name]} = #{branch[:value][:full_name]}(#{branch[:value][:body].map{|r| r[:name]}.join(', ')})"
    when 'INT' then "int #{branch[:name]} = #{branch[:value]}"
    when 'LOCAL_ID' then "int #{branch[:name]} = #{branch[:value]}"
    end # case
  end # parse_constant_definition
end # ConstantCompiler