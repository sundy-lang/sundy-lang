class ConstantNode
  def self.parse options
    buffer = Hash[options[:buffer].map{|k,v| [k.to_sym, v]}]

    case buffer[:value_type]
    when 'FN_CALL' then "int #{buffer[:name]} = #{buffer[:value]['name']}(#{buffer[:value]['childs'].join(', ')})"
    when 'INTEGER' then "int #{buffer[:name]} = #{buffer[:value]}"
    end # case
  end # self.parse
end