# frozen_string_literal: true

require_relative 'lib/trinkets/version'

Gem::Specification.new do |spec|
  spec.name = 'trinkets'
  spec.version = Trinkets::VERSION
  spec.authors = %w[SilverPhoenix99 P3t3rU5]
  spec.email = %w[antoniopedrosilvapinto@gmail.com pedro.at.miranda@gmail.com]
  spec.summary = 'Bootleg facets, with new trinkets.'
  spec.description = 'Truly outrageous bootleg facets in your trinkets box.'
  spec.homepage = 'https://github.com/SilverPhoenix99/trinkets'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']   = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/master/README.md"
  spec.files = Dir['{lib/**/*,**/*.md,LICENSE.txt}']
  spec.require_paths = %w[lib/explicit lib/implicit lib/trinkets]

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
end
