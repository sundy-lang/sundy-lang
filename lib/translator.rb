class Translator
  def initialize buffer
    @buffer = buffer
    @root_name = nil

    @constructors = {}
    @functions = {}
    @methods = {}
  end # initialize

  def llvm_type from
    case from
    when 'I32' then 'i32'
    else from.to_s
    end # case
  end # llvm_type

  def translate options = {}
    options[:buffer] ||= @buffer
    options[:buffer] = Hash[options[:buffer].map{|k,v| [k.to_sym, v]}]

    @root_name ||= options[:buffer][:name]

    case options[:buffer][:type]
    when 'FUNCTION'
      if options[:buffer][:name] == 'THIS'
        @constructors[options[:namespace]] = options[:buffer]
        # TODO
      elsif options[:buffer][0..4] == 'THIS.'
        @methods[options[:namespace]] = options[:buffer]
        # TODO
      else
        namespace = [options[:namespace], options[:buffer][:name]].compact.join('_').gsub('.', '_')

        @functions[namespace] = {
          args: options[:buffer][:args],
          body: [],
          return_type: options[:buffer][:return_type],
        }
        
        options[:buffer][:body].each do |child|
          translate(buffer: child, namespace: namespace, store: @functions)
        end # each  
      end # if
    when 'MODULE'
      namespace = [options[:namespace], options[:buffer][:name]].compact.join('_').gsub('.', '_')

      options[:buffer][:childs].each do |child|
        translate(buffer: child, namespace: namespace)
      end # each
    when 'RETURN'
      case options[:buffer][:value_type]
      when 'INTEGER'
        options[:store][options[:namespace]][:body] << "ret #{llvm_type(options[:store][options[:namespace]][:return_type])} #{options[:buffer][:value]}"
      end # case
    end # case
  end # translate

  def compile
    code = []
    function_index = 0

    @functions.each do |name, options|
      code << "define #{llvm_type(options[:return_type])} @#{name}() ##{function_index} {"
      code += options[:body].map{|l| "  #{l}"}
      code << "}"
      code << ''
      function_index += 1
    end # each

    # Add "main" function if it exists in root module
    if @functions["#{@root_name}_MAIN"]
      code << "define #{llvm_type(@functions["#{@root_name}_MAIN"][:return_type])} @main() ##{function_index} {"
      code << "  %res = call i32 @#{@root_name}_MAIN()"
      code << "  ret i32 %res"
      code << "}"
      code << ''
      function_index += 1
    end # if
    
    code.join("\n")
  end
end # Translator