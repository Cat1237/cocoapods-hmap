# frozen_string_literal: true

require 'cocoapods'

module HMap
  # A collection of Helper functions used throughout cocoapods-hmap.
  module Helper
    # A collection of Pods Helper functions used throughout cocoapods-hmap.
    module Pods
      HEADER_EXTENSIONS = Pod::Sandbox::FileAccessor::HEADER_EXTENSIONS
      def self.pod_analyze(config)
        podfile = Pod::Podfile.from_file(config.podfile_path)
        lockfile = Pod::Lockfile.from_file(config.lockfile_path)
        Pod::Installer::Analyzer.new(config.sandbox, podfile, lockfile).analyze
      end

      # @!group Private helpers

      # Returns the list of the paths founds in the file system for the
      # attribute with given name. It takes into account any dir pattern and
      # any file excluded in the specification.
      #
      # @param  [Symbol] attribute
      #         the name of the attribute.
      #
      # @return [Array<Pathname>] the paths.
      #
      def self.paths_for_attribute(key, attribute, include_dirs: false)
        file_patterns = key.spec_consumer.send(attribute)
        options = {
          exclude_patterns: key.spec_consumer.exclude_files,
          dir_pattern: Pod::Sandbox::FileAccessor::GLOB_PATTERNS[attribute],
          include_dirs: include_dirs
        }
        extensions = HEADER_EXTENSIONS
        key.path_list.relative_glob(file_patterns, options).map do |f|
          [f, key.path_list.root.join(f)] if extensions.include?(f.extname)
        end.compact
      end

      def self.header_mappings(file_accessor, headers, target)
        consumer = file_accessor.spec_consumer
        header_mappings_dir = consumer.header_mappings_dir
        dir = target.headers_sandbox
        dir_h = Pathname.new(target.product_module_name)
        dir += consumer.header_dir if consumer.header_dir
        mappings = {}
        headers.each do |header|
          next if header.to_s.include?('.framework/')

          sub_dir = [dir, dir_h]
          if header_mappings_dir
            relative_path = header.relative_path_from(file_accessor.path_list.root + header_mappings_dir)
            sub_dir << dir + relative_path.dirname
            sub_dir << dir_h + relative_path.dirname
          else
            relative_path = header.relative_path_from(file_accessor.path_list.root)
            sub_dir << relative_path.dirname
          end
          mappings[header] ||= []
          sub_dir.uniq.each do |d|
            mappings[header] << d + header.basename
          end
          mappings[header] << header.basename
        end
        mappings
      end

      def self.pod_target_source_header(target, hmap_t)
        target.header_mappings_by_file_accessor.keys.flat_map do |key|
          paths_for_attribute(key, hmap_t)
        end
      end

      def self.pod_target_source_header_map(target, hmap_t)
        pod_target_source_header(target, hmap_t).each_with_object({}) do |f, sum|
          file = f[1]
          key = f[0].to_s
          r_key = file.basename.to_s
          sum[r_key] = [key, r_key].uniq
        end
      end
    end
  end
end
