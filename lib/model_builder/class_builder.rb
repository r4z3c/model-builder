module ModelBuilder
  module ClassBuilder

    @@dynamic_classes ||= {}

    def self.build(class_full_name, opts={})
      namespace = namespace_from_class_full_name class_full_name
      class_name = class_name_from_class_full_name class_full_name
      return namespace.const_get class_name if namespace.const_defined? class_name

      klass = get_class_from_options opts
      namespace.const_set class_name, klass

      add_class namespace, klass
      include_modules klass, opts[:includes]
      create_accessors klass, opts[:accessors]

      klass
    end

    def self.namespace_from_class_full_name(class_full_name)
      namespace_name = class_namespace_name(class_full_name)
      namespace_name.blank? ? Object : const_get(namespace_name)
    end

    def self.class_namespace_name(class_full_name)
      class_full_name_parts(class_full_name)[0...-1].join '::'
    end

    def self.class_full_name_parts(class_full_name)
      class_full_name.split('::')
    end

    def self.class_name_from_class_full_name(class_full_name)
      class_full_name_parts(class_full_name).last
    end

    def self.get_class_from_options(opts)
      superclass = get_superclass_from_options opts
      superclass.nil? ? Class.new : Class.new(superclass)
    end

    def self.get_superclass_from_options(opts)
      superclass = opts[:superclass]
      superclass.is_a?(String) ? superclass.constantize : superclass
    end

    def self.add_class(mod, klass)
      @@dynamic_classes[mod] = klass
    end

    def self.include_modules(klass, modules)
      return if modules.nil?
      modules = [modules] unless modules.is_a? Array
      modules.each do |m|
        m_const = m.kind_of?(String) ? Object.const_get(m) : m
        klass.send :include, m_const
      end
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
      dynamic_classes.each_pair { |mod, klass| mod.send :remove_const, klass.to_s.gsub(/^.*::/, '') }
      @@dynamic_classes = {}
    end

    def self.dynamic_classes
      @@dynamic_classes
    end

  end
end