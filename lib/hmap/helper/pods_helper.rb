# frozen_string_literal: true

require 'cocoapods'

module HMap
  # A collection of Pods Helper functions used throughout cocoapods-hmap.
  module Pods
    # mapfile dir name
    # @api private
    HMAP_DIR = 'HMap'
    HEADER_EXTENSIONS = %w[h hh hpp ipp tpp hxx def inl inc].join(',')
    def self.hmap_files_dir
      Pathname(File.join(Pod::Config.instance.sandbox.headers_root, HMAP_DIR))
    end

    def self.pods_hmap_files_dir
      "${PODS_ROOT}/Headers/#{HMAP_DIR}"
    end

    def self.target_support_platforms(spec_path)
      validator = Pod::Validator.new(spec_path, Pod::Config.instance.sources_manager.master.map(&:url))
      validator.platforms_to_lint(validator.spec).map(&:name)
    end

    def self.paths_for_attribute(path)
      return [] unless path.exist?

      path_list = Pod::Sandbox::PathList.new(path)
      path_list.glob("**/*.{#{HEADER_EXTENSIONS}}")
    end

    def self.headers_mappings_by_file_accessor(target, type = :source_files)
      valid_accessors = target.file_accessors.reject { |fa| fa.spec.non_library_specification? }
      valid_accessors.each_with_object({}) do |file_accessor, sum|
        sum[:private_header_files] ||= []
        sum[:public_header_files] ||= []
        sum[:source_files] ||= []
        case type
        when :private_header_files
          sum[:private_header_files] += file_accessor.private_headers
        when :source_files
          header_mappings_dir = file_accessor.spec_consumer.header_mappings_dir
          headers = paths_for_attribute(file_accessor.path_list.root)
          unless header_mappings_dir.nil?
            headers = paths_for_attribute(file_accessor.path_list.root + header_mappings_dir)
          end
          sum[:private_header_files] += file_accessor.private_headers
          sum[:public_header_files] +=  file_accessor.public_headers
          sum[:public_header_files] << target.umbrella_header_path if target.build_as_framework?
          sum[:source_files] << target.prefix_header_path if target.build_as_framework?
          sum[:source_files] += (headers - file_accessor.public_headers - file_accessor.private_headers)
        when :public_header_files
          sum[:public_header_files] += file_accessor.public_headers
          sum[:public_header_files] << target.umbrella_header_path if target.build_as_framework?
        end
      end
    end

    def self.headers_mappings_by_file(target, type = :source_files)
      valid_accessors = target.file_accessors.reject { |fa| fa.spec.non_library_specification? }
      valid_accessors.each_with_object([]) do |file_accessor, sum|
        sum << case type
               when :private_header_files then file_accessor.headers - file_accessor.public_headers
               when :source_files then file_accessor.headers
               when :public_header_files then file_accessor.public_headers
               end
      end.flatten.compact
    end

    def self.xcconfig_path_from(target)
      raise ClassIncludedError.new(target.class, Pod::Target) unless target.is_a?(Pod::Target)

      config_h = Pod::Target.instance_method(:build_settings).bind(target).call
      config_h.each_key do |configuration_name|
        xcconfig = target.xcconfig_path(configuration_name)
        yield(xcconfig, target) if block_given?
      end
    end

    def self.clean_hmap_setting(clean_hmap, *targets)
      return clean_hmap unless clean_hmap

      FileUtils.rm_rf(Pods.hmap_files_dir)
      targets.each { |target| clean_hmap_build_setting(target, log: true) }
      clean_hmap
    end

    def self.clean_hmap_build_setting(targets, log: false)
      puts 'Clean build setting: '.blue if log
      targets.each do |target|
        xcconfig_path_from(target) do |xcconfig|
          HMap::XcodeprojHelper.new(xcconfig).clean_hmap_build_setting_and_save
          puts "\t -xcconfig path: #{xcconfig} clean finish." if log
        end
      end
    end
  end
end
