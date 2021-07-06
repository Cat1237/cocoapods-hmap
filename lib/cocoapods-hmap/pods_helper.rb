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
