# frozen_string_literal: true

require 'digest/md5'
require_relative 'rule'

module CodeManifest
  class Manifest
    GLOB_OPTIONS = File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB

    attr_reader :rules

    def initialize(patterns)
      @rules ||= Array(patterns).map do |pattern|
        Rule.new(CodeManifest.root, pattern)
      end
    end

    def files
      @files ||= (inclusion_files - exclusion_files).sort!.freeze
    end

    def digest
      @digest ||= begin
        digests = files.map { |file| Digest::MD5.file(CodeManifest.root.join(file)).hexdigest }
        Digest::MD5.hexdigest(digests.join).freeze
      end
    end

    def matches(paths)
      result_paths = paths.select do |path|
        inclusion_rules.any? { |rule| rule.match?(path) }
      end
      result_paths.reject! do |path|
        exclusion_files.any? { |rule| rule.match?(path) }
      end

      result_paths.sort!
    end

    private

    def inclusion_files
      @inclusion_files ||= files_with_relative_path(Dir.glob(inclusion_rules.map(&:glob), GLOB_OPTIONS))
    end

    def inclusion_rules
      @inclusion_rules ||= rules.reject(&:exclude)
    end

    def exclusion_files
      @exclusion_files ||= files_with_relative_path(Dir.glob(exclusion_rules.map(&:glob), GLOB_OPTIONS))
    end

    def exclusion_rules
      @exclusion_rules ||= rules.select(&:exclude)
    end

    def files_with_relative_path(files)
      files.map do |file|
        pathname = Pathname.new(file)
        next if pathname.directory?

        pathname.relative_path_from(CodeManifest.root).to_s
      end.compact
    end
  end
end
