require_relative 'c_compiler/constant_compiler.rb'
require_relative 'c_compiler/function_compiler.rb'
require_relative 'c_compiler/module_compiler.rb'

class CCompiler
  include ConstantCompiler
  include FunctionCompiler
  include ModuleCompiler

  def initialize options = {}
    @ast = symbolize_hash(options[:ast])
    @ast = link_hash(@ast)

    @current_branch = @ast

    @constants = {}
    @constructors = {}
    @functions = {}
    @methods = {}

    @includes = []
  end # initialize

  def ast
    @ast
  end # ast

  def get_type from
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
    else raise "Unknown type '#{from.inspect}'"
    end # case
  end # get_type

  def compile branch
    method_name = "compile_#{branch[:type]}".downcase.to_sym
puts method_name
    if methods.include?(method_name)
      send(method_name, branch)
    else
      raise "Unknown node type for #{branch.inspect}"
    end # if
  end # compile

  def get_compiled_data
    code = []
    main_function_name = "#{@ast[:name]}_MAIN"

    @functions.each do |name, options|
      code << "#{get_type(options[:value_type])} #{name}(#{options[:args].values.join(', ')}) {"
      code += options[:body].map{|l| "  #{l};"}
      code << "}"
      code << ''
    end # each

    # Add "main" function if it exists in root module
    if @functions[main_function_name]
      main_function = @functions[main_function_name]
      code << "#{get_type(main_function[:value_type])} main(#{main_function[:args].values.join(', ')}) {"
      code << "  return #{main_function_name}(#{main_function[:args].keys.join(', ')});"
      code << "}"
      code << ''
    end # if
    
    code.unshift('')

    @includes.each do |item|
      code.unshift("#include #{item}")
    end # each

    code.join("\n")
  end # get_compiled_data

  def link_hash data, options = {}
    namespace = options[:namespace]
    parent = options[:parent]

    if data.is_a?(Hash)
      result = case data[:type]
      when 'CONSTANT_DEFINITION'
        parent && parent[:type] == 'MODULE_DEFINITION' ? { full_name: [ namespace, data[:name] ].compact.join('_') } : {}
      when 'FUNCTION_CALL'
        { full_name: [ namespace, data[:name] ].compact.join('_') }
      when 'FUNCTION_DEFINITION'
        { full_name: [ namespace, data[:name] ].compact.join('_') }
      when 'MODULE_DEFINITION'
        namespace = [ namespace, data[:name] ].compact.join('_')
        { full_name: namespace }
      else {}
      end # case

      result[:namespace] = namespace
      result[:parent] = parent if parent

      result.merge(
        Hash[data.map{|k,v| [
          k.to_sym, 
          link_hash(v, key: k, namespace: namespace, parent: data)
        ]}]
      )
    elsif data.is_a?(Array)
      data.map{|r| link_hash(r, namespace: namespace, parent: parent)}
    else
      data
    end # if
  end # link_hash

  def symbolize_hash data
    if data.is_a?(Hash)
      Hash[data.map{|k,v| [k.to_sym, symbolize_hash(v)]}]
    elsif data.is_a?(Array)
      data.map{|r| symbolize_hash(r)}
    else
      data
    end # if
  end # symbolize_hash
end # CCompiler