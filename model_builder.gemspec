$:.push File.expand_path('../lib', __FILE__)

require 'model_builder/version'

Gem::Specification.new do |s|
  s.name        = 'model-builder'
  s.version     = ModelBuilder::VERSION
  s.authors     = ['r4z3c']
  s.email       = ['r4z3c.43@gmail.com']
  s.homepage    = 'https://github.com/r4z3c/model-builder.git'
  s.summary     = 'Active record runtime model builder'
  s.description = 'Create active record models on the fly'
  s.licenses    = %w(MIT)

  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths = %w(lib)

  s.add_dependency 'bundler', '>= 1'
  s.add_dependency 'activerecord', '>= 4'

  s.add_development_dependency 'sqlite3', '>= 1'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'simplecov', '>= 0'
end
