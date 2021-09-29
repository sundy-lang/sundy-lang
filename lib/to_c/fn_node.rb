class FnNode
  def self.parse options
    buffer = Hash[options[:buffer].map{|k,v| [k.to_sym, v]}]
    context = options[:context]
    namespace = options[:namespace]

    if buffer[:name] == 'THIS'
      context.add_constructor(namespace, buffer)
      # TODO
    elsif options[:buffer][0..4] == 'THIS.'
      context.add_method(namespace, buffer)
      # TODO
    else
      namespace = [namespace, buffer[:name]].compact.join('_').gsub('.', '_')

      args = {}
      buffer[:args].each do |arg_name, arg_options|
        arg_type = ToC.get_type(arg_options['name'])

        if arg_options['childs']
          arg_sub_type = ToC.get_type(arg_options['childs'].first['name']) + ' '
        end # if

        case arg_type
        when '[]'
          args[arg_name] = "#{arg_sub_type}#{arg_name}#{arg_type}"
        else
          args[arg_name] = "#{arg_type} #{arg_name}"
        end # case
      end # each

      body = []
      buffer[:childs].each do |child|
        if instruction = context.parse(
          buffer: child, 
          context: context,
          namespace: namespace,
        )
          body << instruction
        else
          raise "Cant't parse function instruction for #{child.inspect}"
        end
      end # each  

      context.add_function(namespace, {
        args: args,
        body: body,
        return_type: buffer[:return_type],
      })
    end # if
  end # parse
end