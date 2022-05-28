# frozen_string_literal: true

module HMap
  class Target
    class TargetContext < Context
      attr_reader :product_name

      def initialize(build_root, temp_dir, hmap_root, temp_name, build_dir, product_name, full_product_name, defines_modules, build_as_framework_swift)
        super(build_root, temp_dir, hmap_root, temp_name, build_dir)
        @full_product_name = full_product_name
        @product_name = product_name
        @defines_modules = defines_modules
        @build_as_framework_swift = build_as_framework_swift
      end

      def build_as_framework_swift?
        @build_as_framework_swift
      end

      def defines_modules?
        @defines_modules
      end

      def build_path(platform)
        path = super(platform)
        File.join(path, @full_product_name)
      end
    end
  end
end
