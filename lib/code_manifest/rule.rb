# frozen_string_literal: true

module CodeManifest
  class Rule
    attr_reader :exclude, :glob

    def initialize(root, pattern)
      @root = root
      @exclude = false
      @glob = @root

      if pattern.start_with?('!')
        @exclude = true
        pattern = pattern[1..-1]
      end

      if pattern.start_with?('/')
        pattern = pattern[1..-1]
      else
        @glob = @glob.join('**')
      end

      @glob = @glob.join(pattern).to_s
    end

    def match?(file)
      file = File.join(@root, file) unless File.absolute_path?(file)

      File.fnmatch?(glob, file, Manifest::GLOB_OPTIONS)
    end
  end
end
