# frozen_string_literal: true

require_relative 'lib/trinkets/version'

Gem::Specification.new do |spec|
  spec.name = 'trinkets'
  spec.version = Trinkets::VERSION
  spec.authors = %w[SilverPhoenix99 P3t3rU5]
  spec.email = %w[antoniopedrosilvapinto@gmail.com pedro.at.miranda@gmail.com]

  spec.summary = 'Trinkets in your box.'
  spec.description = 'Truly outrageous trinkets.'
  spec.homepage = 'http://nowhere.example.com'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  # spec.metadata['allowed_push_host'] = 'TODO: Set to your gem server "https://example.com"'

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = "TODO: Put your gem's public repo URL here."
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']
end
