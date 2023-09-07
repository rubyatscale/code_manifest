# frozen_string_literal: true

require 'digest/md5'
require_relative 'rule'

module CodeManifest
  class Manifest
    GLOB_OPTIONS = File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB

    attr_reader :rules

    def initialize(patterns)
      @rules ||= Array(patterns).map do |pattern|
        Rule.new(pattern)
      end
    end

    def files
      @files ||= begin
        inclusion_files = Dir.glob(inclusion_rules.map(&:glob), GLOB_OPTIONS, base: CodeManifest.root)
        inclusion_files.delete_if do |file|
          exclusion_rules.any? { |rule| rule.match?(file) }
        end
        files_with_relative_path(inclusion_files).sort!.freeze
      end
    end

    def digest
      @digest ||= begin
        digests = files.map { |file| Digest::MD5.file(CodeManifest.root.join(file)).hexdigest }
        Digest::MD5.hexdigest(digests.join).freeze
      end
    end

    def matches(paths)
      result_paths = Array(paths).select do |path|
        inclusion_rules.any? { |rule| rule.match?(path) }
      end
      result_paths.reject! do |path|
        exclusion_rules.any? { |rule| rule.match?(path) }
      end

      result_paths.sort!
    end

    def matches_all?(paths)
      matches(paths) == paths
    end

    private

    def inclusion_rules
      @inclusion_rules ||= rules.reject(&:exclude)
    end

    def exclusion_rules
      @exclusion_rules ||= rules.select(&:exclude)
    end

    def files_with_relative_path(files)
      prefix = File.join(CodeManifest.root, "/")

      files.filter_map do |file|
        next if File.directory?(file)

        file.delete_prefix(prefix)
      end
    end
  end
end
