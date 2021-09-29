require_relative 'to_c/constant_node.rb'
require_relative 'to_c/fn_node.rb'
require_relative 'to_c/module_node.rb'
require_relative 'to_c/return_node.rb'

class ToC
  def self.get_type from
    case from
    when 'F32' then 'float'
    when 'F64' then 'double'
    when 'I8' then 'short int'
    when 'I16' then 'short int'
    when 'I32' then 'int'
    when 'I64' then 'long int'
    when 'LIST' then '[]'
    when 'STRING' then 'char*'
    when 'U8' then 'char'
    when 'U16' then 'short unisgned int'
    when 'U32' then 'unsigned int'
    when 'U64' then 'long unsigned int'
    else from.to_s
    end # case
  end # self.get_type

  def initialize
    @root_name = nil

    @constructors = {}
    @functions = {}
    @methods = {}
  end # initialize

  def add_constructor namespace, options
    @constructors[namespace] = options
  end # add_function

  def add_function namespace, options
    @functions[namespace] = options
  end # add_function

  def add_method namespace, options
    @methods[namespace] = options
  end # add_function

  def parse options = {}
    @root_name ||= options[:buffer]['name']

    options[:context] = self

    case options[:buffer]['type']
    when 'CONSTANT' then ConstantNode.parse(options)
    when 'FN' then FnNode.parse(options)
    when 'MODULE' then ModuleNode.parse(options)
    when 'RETURN' then ReturnNode.parse(options)
    else raise("Unknown node type for #{options.inspect}")
    end # case
  end # parse

  def compile
    code = []

    @functions.each do |name, options|
      code << "#{ToC.get_type(options[:return_type])} #{name}(#{options[:args].values.join(', ')}) {"
      code += options[:body].map{|l| "  #{l};"}
      code << "}"
      code << ''
    end # each

    # Add "main" function if it exists in root module
    if @functions["#{@root_name}_MAIN"]
      options = @functions["#{@root_name}_MAIN"]
      code << "#{ToC.get_type(@functions["#{@root_name}_MAIN"][:return_type])} main(#{options[:args].values.join(', ')}) {"
      code << "  return #{@root_name}_MAIN(#{options[:args].keys.join(', ')});"
      code << "}"
      code << ''
    end # if
    
    code.join("\n")
  end # compile
end # ToC