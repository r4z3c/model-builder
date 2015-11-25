Dir["#{File.dirname(__FILE__)}/**/*.rb"].each {|file| require file }

module ModelBuilder

  @@dynamic_models ||= []

  def self.build(name, opts={})
    opts.reverse_merge! get_default_options

    already_exists = Object.const_defined? name
    klass = ClassBuilder.build name, opts

    unless already_exists
      create_table klass, opts
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

  def self.create_table(klass, opts)
    ActiveRecord::Migration.create_table(table_name_for(klass)) do |migration|
      create_attributes(migration, opts[:attributes])
    end

    @@dynamic_models << klass
  end

  def self.table_name_for(klass)
    klass.to_s.tableize
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
    list.map {|c| drop_table c }
  end

  def self.list
    @@dynamic_models
  end

  def self.drop_table(klass)
    ActiveRecord::Migration.drop_table(table_name_for(klass))
  end

end
