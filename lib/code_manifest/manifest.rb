# frozen_string_literal: true

require 'set'
require 'digest/md5'
require_relative 'rule'

module CodeManifest
  class Manifest
    attr_reader :root

    def initialize(root, patterns)
      @root = root
      @patterns = patterns.map(&:to_s)
    end

    def files
      @files ||= (inclusion_rules.map(&:files).reduce(Set.new, :merge) - exclusion_rules.map(&:files).reduce(Set.new, :merge)).sort.to_set
    end

    def digest
      @digest ||= begin
        digests = files.map { |file| Digest::MD5.file(root.join(file)).hexdigest }
        Digest::MD5.hexdigest(digests.join)
      end
    end

    private

    def rules
      @rules ||= @patterns.each_with_object([]) do |pattern, rules|
        pattern = pattern.strip
        unless pattern.match?(/\A(#|\z)/)
          rules << Rule.new(root, pattern)
        end
      end
    end

    def inclusion_rules
      @inclusion_rules ||= rules.reject(&:exclude)
    end

    def exclusion_rules
      @exclusion_rules ||= rules.select(&:exclude)
    end
  end
end
