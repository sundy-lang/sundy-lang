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
      body = []

      buffer[:childs].each do |child|
        body << context.parse(
          buffer: child, 
          context: context,
          namespace: namespace,
        )
      end # each  

      context.add_function(namespace, {
        args: buffer[:args],
        body: body,
        return_type: buffer[:return_type],
      })
    end # if
  end # parse
end