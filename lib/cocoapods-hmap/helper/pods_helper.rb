# frozen_string_literal: true

require 'yaml_vfs'
require 'cocoapods'

module HMap
  # A collection of Helper functions used throughout cocoapods-hmap.
  module Helper
    # A collection of Pods Helper functions used throughout cocoapods-hmap.
    module Pods

      def self.hmap_files_dir
        Pathname(File.join(Pod::Config.instance.sandbox.headers_root, HMAP_DIR))
      end

      def self.vfs_files_dir
        hmap_files_dir.join('vfs')
      end

      def self.hmap_files_paths(name)
        [hmap_files_dir.join("#{name}.hmap"), hmap_files_dir.join("#{name}-iquote.hmap")]
      end

      def self.pods_hmap_files_dir
        "${PODS_ROOT}/Headers/#{HMAP_DIR}"
      end

      def self.write_vfs_yaml(targets)
        es = targets.flat_map do |target|
          if target.build_as_framework?
            spec_path = target.specs.map(&:defined_in_file).uniq.first
            platforms = target_support_platforms(spec_path)
            headers = headers_mappings_by_file_accessor(target)
            headers << target.umbrella_header_path
            Target::FrameworkEntry.new_entrys_from_configurations_platforms(target.user_build_configurations.keys, platforms, target.name, target.product_module_name, target.support_files_dir, headers)
          end
        end.compact
        Target::FrameworkVFS.new(es).write
      end

      def self.target_support_platforms(spec_path)
        validator = Pod::Validator.new(spec_path, Pod::Config.instance.sources_manager.master.map(&:url))
        validator.platforms_to_lint(validator.spec).map(&:name)
      end

      def self.headers_mappings_by_file_accessor(target, type = :source_files)
        valid_accessors = target.file_accessors.reject { |fa| fa.spec.non_library_specification? }
        valid_accessors.each_with_object([]) do |file_accessor, sum|
          sum << case type
                 when :private_header_files then file_accessor.headers - file_accessor.public_headers
                 when :source_files then file_accessor.headers
                 when :public_header_files then file_accessor.public_headers
                 end
        end.flatten
      end

      def self.header_mappings(target, type = :source_files)
        mappings = {}
        h_headers = lambda { |headers, h_type|
          root = Pod::Config.instance.sandbox.root.join(target.headers_sandbox)
          case h_type
          when :private_header_files
            headers << target.prefix_header_path if target.build_as_framework?
            headers.each do |header|
              mappings[HEAD_SEARCH_IQUOTE] ||= []
              mappings[HEAD_SEARCH_IQUOTE] << [header.basename.to_s, "#{header.dirname}/", header.basename.to_s]
              r_header_path = header.relative_path_from(root)
              mappings[HEAD_SEARCH_IQUOTE] << [r_header_path.to_s, "#{header.dirname}/", header.basename.to_s]
            end
          when :public_header_files
            headers << target.umbrella_header_path if target.build_as_framework?
            headers.each do |header|
              mappings[HEAD_SEARCH_IQUOTE] ||= []
              mappings[HEAD_SEARCH_IQUOTE] << [header.basename.to_s, "#{target.product_module_name}/",
                                               header.basename.to_s]
              r_header_path = header.relative_path_from(root)
              mappings[HEAD_SEARCH_IQUOTE] << [r_header_path.to_s, "#{header.dirname}/", header.basename.to_s]
              mappings[HEAD_SEARCH_I] ||= []
              mappings[HEAD_SEARCH_I] << [r_header_path.to_s, "#{header.dirname}/", header.basename.to_s]
              mappings[HEAD_SEARCH_I] << [header.basename.to_s, "#{target.product_module_name}/",
                                          header.basename.to_s]

              mappings[HEAD_SEARCH_I] << ["#{target.product_module_name}/#{header.basename}", "#{header.dirname}/",
                                          header.basename.to_s]
            end
          end
        }

        valid_accessors = target.file_accessors.reject { |fa| fa.spec.non_library_specification? }
        valid_accessors.each do |file_accessor|
          case type
          when :private_header_files then h_headers.call(file_accessor.headers - file_accessor.public_headers,
                                                         :private_header_files)
          when :source_files
            h_headers.call(file_accessor.headers - file_accessor.public_headers, :private_header_files)
            h_headers.call(file_accessor.public_headers, :public_header_files)
          when :public_header_files then h_headers.call(file_accessor.public_headers, :public_header_files)
          end
        end
        mappings
      end
    end
  end
end
