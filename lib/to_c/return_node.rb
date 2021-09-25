class ReturnNode
  def self.parse options
    buffer = Hash[options[:buffer].map{|k,v| [k.to_sym, v]}]
    
    case buffer[:value_type]
    when 'INTEGER' then "return #{buffer[:value]}"
    end # case
  end # self.parse
end