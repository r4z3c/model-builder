module ModelBuilder
  module ClassBuilder

    @@dynamic_classes ||= []

    def self.build(name, opts={})
      return Object.const_get name if Object.const_defined? name

      klass = get_class_from_options opts
      Object.const_set name, klass

      add_class klass
      create_accessors klass, opts[:accessors]

      klass
    end

    def self.get_class_from_options(opts)
      superclass = get_superclass_from_options opts
      superclass.nil? ? Class.new : Class.new(superclass)
    end

    def self.get_superclass_from_options(opts)
      superclass = opts[:superclass]
      superclass.is_a?(String) ? superclass.constantize : superclass
    end

    def self.add_class(klass)
      @@dynamic_classes << klass
    end

    def self.create_accessors(klass, accessors=[])
      return if accessors.nil?
      accessors = [accessors] unless accessors.is_a? Array
      accessors.each { |accessor| create_accessor(klass, accessor) }
    end

    def self.create_accessor(klass, accessor)
      klass.send 'attr_accessor', accessor unless accessor.nil?
    end

    def self.clean
      list.map {|c| Object.send :remove_const, c.to_s }
      @@dynamic_classes = []
    end

    def self.list
      @@dynamic_classes
    end

  end
end