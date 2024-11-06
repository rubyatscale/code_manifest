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
      @cache = {}
    end

    def files
      @files ||= begin
        matched_files = matches(Dir.glob(inclusion_rules.map(&:glob), GLOB_OPTIONS, base: CodeManifest.root)).uniq
        files_with_relative_path(matched_files).freeze
      end
    end

    def digest
      @digest ||= begin
        digests = files.map { |file| Digest::MD5.file(CodeManifest.root.join(file)).hexdigest }
        Digest::MD5.hexdigest(digests.join).freeze
      end
    end

    def matches(paths)
      Array(paths).select do |path|
        cached_match =
          if @cache.key?(path)
            @cache.fetch(path)
          else
            @cache[path] = [
              inclusion_rules.any? { |rule| rule.match?(path) },
              exclusion_rules.any? { |rule| rule.match?(path) }
            ]
          end
        cached_match.first && !cached_match.last
      end.sort!
    end

    def matches_all?(paths)
      matches(paths).size == paths.size
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
