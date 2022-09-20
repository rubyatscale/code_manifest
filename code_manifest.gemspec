# frozen_string_literal: true

require_relative "lib/code_manifest/version"

Gem::Specification.new do |spec|
  spec.name = "code_manifest"
  spec.version = CodeManifest::VERSION
  spec.authors = ['Gusto Engineers']
  spec.email = ['dev@gusto.com']

  spec.summary = "A code manifest"
  spec.description = "A code manifest"
  spec.homepage = "https://github.com/rubyatscale/code_manifest"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7")

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rubyatscale/code_manifest"
  spec.metadata["changelog_uri"] = "https://github.com/rubyatscale/code_manifest/blob/main/CHANGLOG.md"

  spec.files         = Dir["VERSION", "CHANGELOG.md", "LICENSE.txt", "README.md", "lib/**/*", "bin/**/*"]
  spec.bindir        = "exe"
  spec.executables   = Dir["exe/*"].map { |exe| File.basename(exe) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency 'rspec', '~> 3.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
