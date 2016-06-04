Dir["#{File.dirname(__FILE__)}/**/*.rb"].each {|file| require file }

module ModelBuilder

  TABLE_PREFIX = "model_builder/"

  @@dynamic_models ||= []

  def self.build(class_full_name, opts={})
    opts.reverse_merge! get_default_options

    klass = ClassBuilder.build class_full_name, opts

    unless table_already_exists class_full_name
      create_table class_full_name, opts
      define_table_name klass, class_full_name
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

  def self.table_already_exists(class_full_name)
    relevant_database_tables.include? table_name_for(class_full_name)
  end

  def self.relevant_database_tables
    database_tables.select {|table| table.starts_with? TABLE_PREFIX }
  end

  def self.database_tables
    database_connection.tables
  end

  def self.database_connection
    ActiveRecord::Base.connection
  end

  def self.table_name_for(class_full_name)
    table_name = class_full_name.tableize.gsub(/\//,'_')
    "#{TABLE_PREFIX}#{table_name}"
  end

  def self.create_table(class_full_name, opts)
    ActiveRecord::Migration.create_table(table_name_for(class_full_name)) do |migration|
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

  def self.define_table_name(klass, class_full_name)
    klass.table_name = table_name_for(class_full_name)
  end

  def self.define_validations(klass, validations)
    return if validations.nil? or !validations.kind_of?(Array) or validations.empty?
    validations = [validations] unless validations.first.kind_of? Array
    validations.each {|v| klass.validates *v}
  end

  def self.clean
    relevant_database_tables.map {|table| drop_table table }
    @@dynamic_models = []
  end

  def self.dynamic_models
    @@dynamic_models
  end

  def self.drop_table(table)
    ActiveRecord::Migration.drop_table(table)
  end

end
