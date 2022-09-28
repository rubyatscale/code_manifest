# frozen_string_literal: true

module CodeManifest
  class Rule
    attr_reader :exclude, :glob

    def initialize(pattern)
      @exclude = false
      @glob = pattern

      if glob.start_with?("!")
        @exclude = true
        @glob = glob.delete_prefix("!")
      end

      if File.absolute_path?(glob)
        @glob = glob.delete_prefix(File::SEPARATOR)
      else
        @glob = File.join("**", glob)
      end
    end

    def match?(file)
      if File.absolute_path?(file)
        prefix = File.join(CodeManifest.root, "/")
        file = file.delete_prefix(prefix)
      end

      File.fnmatch?(glob, file, Manifest::GLOB_OPTIONS)
    end
  end
end
