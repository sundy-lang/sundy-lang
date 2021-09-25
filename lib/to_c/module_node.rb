class ModuleNode
  def self.parse options
    buffer = Hash[options[:buffer].map{|k,v| [k.to_sym, v]}]
    context = options[:context]
    namespace = [options[:namespace], buffer[:name]].compact.join('_').gsub('.', '_')

    buffer[:childs].each do |child|
      context.parse(
        buffer: child, 
        context: context,
        namespace: namespace,
      )
    end # each
  end # self.parse
end