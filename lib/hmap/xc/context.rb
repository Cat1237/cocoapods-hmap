# frozen_string_literal: true

module HMap
  class Context
    attr_reader :build_root, :hmap_root, :temp_name, :build_dir, :temp_dir

    def initialize(build_root, temp_dir, hmap_root, temp_name, build_dir)
      @build_root = build_root
      @temp_dir = temp_dir
      @hmap_root = hmap_root
      @temp_name = temp_name
      @build_dir = build_dir || ''
    end

    def build_path(platform)
      File.join(build_root, platform.to_s, build_dir)
    end

    def temp_path(platform)
      File.join(temp_dir, platform.to_s, temp_name)
    end
  end
end
