# frozen_string_literal: true

require 'digest/md5'
require_relative 'rule'

module CodeManifest
  class Manifest
    GLOB_OPTIONS = File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB

    attr_reader :root, :rules

    def initialize(root, patterns)
      @root = root
      @rules ||= patterns.map do |pattern|
        Rule.new(root, pattern)
      end
    end

    def files
      @files ||= (inclusion_files - exclusion_files).sort!.freeze
    end

    def digest
      @digest ||= begin
        digests = files.map { |file| Digest::MD5.file(root.join(file)).hexdigest }
        Digest::MD5.hexdigest(digests.join).freeze
      end
    end

    def matches(paths)
      # loop over inclusion rules, keep matches, throw out non-matches
      # loop over exclusion rules, throw out matches
      # return results
    end

    private

    def inclusion_files
      @inclusion_files ||= Dir.glob(inclusion_rules.map(&:glob), GLOB_OPTIONS)
    end

    def inclusion_rules
      @inclusion_rules ||= rules.reject(&:exclude)
    end

    def exclusion_files
      @exclusion_files ||= Dir.glob(exclusion_rules.map(&:glob), GLOB_OPTIONS)
    end

    def exclusion_rules
      @exclusion_rules ||= rules.select(&:exclude)
    end
  end
end
