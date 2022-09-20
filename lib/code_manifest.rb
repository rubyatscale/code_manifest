# frozen_string_literal: true

require 'yaml'
require_relative "code_manifest/version"
require_relative "code_manifest/manifest"

module CodeManifest
  class Error < StandardError; end

  DOTFILE = '.code_manifest.yml'.freeze
  KEY_PATTERN = /[a-z_0-9]+/.freeze

  class << self
    def [](name)
      manifests[name.to_s]
    end

    private

    def manifests
      @manifests ||= begin
        config_file = traverse_files(DOTFILE, Dir.pwd)

        raise "#{DOTFILE} was not found in your project directory, please check README for instructions." unless config_file

        root = Pathname.new(config_file).dirname

        YAML.load_file(config_file).each_with_object({}) do |(name, patterns), collection|
          next unless name.match?(KEY_PATTERN)

          if collection.key?(name)
            raise ArgumentError, "#{name} defined multiple times in #{DOTFILE}"
          end

          collection[name] = Manifest.new(root, patterns)
        end
      end
    end

    def traverse_files(filename, start_dir)
      Pathname.new(start_dir).expand_path.ascend do |dir|
        file = dir.join(filename)
        return file.to_s if file.exist?
      end
    end
  end
end
