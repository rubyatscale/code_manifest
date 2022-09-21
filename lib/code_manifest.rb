# frozen_string_literal: true

require 'pathname'
require 'yaml'
require_relative 'code_manifest/version'
require_relative 'code_manifest/manifest'

module CodeManifest
  class Error < StandardError; end

  DOTFILE = '.code_manifest.yml'
  KEY_PATTERN = /[a-z_0-9]+/.freeze

  class << self
    def [](name)
      manifests[name.to_s]
    end

    private

    def manifests
      @manifests ||= begin
        manifest_file = traverse_files(DOTFILE, Dir.pwd)

        unless manifest_file
          raise "#{DOTFILE} was not found in your project directory, please check README for instructions."
        end

        root = Pathname.new(manifest_file).dirname

        load_manifest(manifest_file).each_with_object({}) do |(name, patterns), collection|
          next unless name.match?(KEY_PATTERN)

          raise ArgumentError, "#{name} defined multiple times in #{DOTFILE}" if collection.key?(name)

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

    # https://stackoverflow.com/a/71192990
    def load_manifest(file)
      YAML.load_file(file, aliases: true)
    rescue ArgumentError
      YAML.load_file(file)
    end
  end
end
