Dir["#{File.dirname(__FILE__)}/**/*.rb"].each {|file| require file }

module ModelBuilder

  @@dynamic_models ||= []

  def self.build(class_full_name, opts={})
    opts.reverse_merge! get_default_options

    already_exists = Object.const_defined? class_full_name
    klass = ClassBuilder.build class_full_name, opts

    unless already_exists
      create_table class_full_name, opts
      define_validations klass, opts[:validates]
    end

    klass
  end

  def self.get_default_options
    {
      superclass: ::ActiveRecord::Base,
      attributes: {}
    }
  end

  def self.create_table(class_full_name, opts)
    ActiveRecord::Migration.create_table(class_full_name.tableize) do |migration|
      create_attributes(migration, opts[:attributes])
    end

    @@dynamic_models << class_full_name
  end

  def self.create_attributes(migration, attributes={})
    attributes.each_pair do |key, value|
      create_attribute(migration, key, value)
    end
  end

  def self.create_attribute(migration, key, opts)
    if opts.is_a?(Hash)
      opts = opts.clone
      type = opts.delete :type
    else
      type = opts
      opts = {}
    end
    migration.send(type, key, opts)
  end

  def self.define_validations(klass, validations)
    return if validations.nil? or !validations.kind_of?(Array) or validations.empty?
    validations = [validations] unless validations.first.kind_of? Array
    validations.each {|v| klass.validates *v}
  end

  def self.clean
    dynamic_models.map {|c| drop_table c }
    @@dynamic_models = []
    ClassBuilder.clean
  end

  def self.dynamic_models
    @@dynamic_models
  end

  def self.drop_table(class_full_name)
    ActiveRecord::Migration.drop_table(class_full_name.tableize)
  end

end
