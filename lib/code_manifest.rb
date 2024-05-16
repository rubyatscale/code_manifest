# frozen_string_literal: true

require 'pathname'
require 'yaml'
require_relative 'code_manifest/version'
require_relative 'code_manifest/manifest'

module CodeManifest
  class Error < StandardError; end

  MANIFEST_FILE = '.code_manifest.yml'
  KEY_PATTERN = /[a-z_0-9]+/.freeze

  class << self
    def [](name)
      manifests[name.to_s]
    end

    def root(start_path: Dir.pwd, reset: false)
      @root = nil if reset
      @root ||= find_root(start_path)
    end

    def load_manifests_from_file(file = nil)
      manifest_file = file || root.join(MANIFEST_FILE)

      # https://stackoverflow.com/a/71192990
      yaml = begin
        YAML.load_file(manifest_file, aliases: true)
      rescue ArgumentError
        YAML.load_file(manifest_file)
      end

      yaml.each_with_object({}) do |(name, patterns), collection|
        next unless name.match?(KEY_PATTERN)

        raise ArgumentError, "#{name} defined multiple times in #{manifest_file}" if collection.key?(name)

        collection[name] = Manifest.new(patterns.flatten)
      end
    end

    private

    def manifests
      @manifests ||= load_manifests_from_file
    end

    def find_root(path)
      Pathname.new(path).expand_path.ascend do |dir|
        return dir if dir.join(MANIFEST_FILE).exist?
      end

      raise "#{MANIFEST_FILE} was not found in your project directory, please check README for instructions."
    end
  end
end
