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

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rubyatscale/code_manifest"
  spec.metadata["changelog_uri"] = "https://github.com/rubyatscale/code_manifest/releases"

  spec.files = Dir["README.md", "lib/**/*"]

  spec.add_dependency "psych", ">= 4.0.0"

  spec.add_development_dependency 'rspec', '~> 3.0'
end
