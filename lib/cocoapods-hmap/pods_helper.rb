# frozen_string_literal: true

require 'yaml_vfs'
require 'cocoapods'

module HMap
  # A collection of Helper functions used throughout cocoapods-hmap.
  module Helper
    # A collection of Pods Helper functions used throughout cocoapods-hmap.
    module Pods
      HEADER_EXTENSIONS = Pod::Sandbox::FileAccessor::HEADER_EXTENSIONS
      # Converts the symbolic name of a platform to a string name suitable to be
      # presented to the user.
      #
      # @param  [Symbol] symbolic_name
      #         the symbolic name of a platform.
      #
      # @return [String] The string that describes the name of the given symbol.
      #
      def self.effective_platform_name(symbolic_name)
        case symbolic_name
        when :ios then %w[iphoneos iphonesimulator]
        when :osx then %w[macosx]
        when :watchos then %w[watchos watchsimulator]
        when :tvos then %w[appletvos appletvsimulator]
        else []
        end
      end

      def self.target_has_private_module(target)
        target.support_files_dir.glob('module*.modulemap').length > 1
      end

      def self.hmap_files_dir
        # puts "Current podfile dir: #{Pod::Config.instance.installation_root}"
        # hmap_files_dir = File.join(Pod::Config.instance.sandbox.headers_root, HMAP_DIR)
        # puts "Current HMap dir: #{hmap_files_dir}"
        # hmap_files_dir
        Pathname(File.join(Pod::Config.instance.sandbox.headers_root, HMAP_DIR))
      end

      def self.pods_hmap_files_dir
        "${PODS_ROOT}/Headers/#{HMAP_DIR}"
      end

      def self.write_vfs_yaml(targets)
        es = targets.flat_map do |target|
          if target.build_as_framework?
            spec_path = target.specs.map(&:defined_in_file).uniq.first
            entrys = target_temp_and_build_dir(target.user_build_configurations.keys, spec_path, target.name,
                                               target.product_module_name)
            headers = headers_mappings_by_file_accessor(target)
            headers << target.umbrella_header_path
            e_headers = ->(path, *names) { names.inject(Pathname(path)) { |e, n| e.join(n) } }
            entrys.each do |entry|
              entry.headers_real_paths += headers
              entry.headers_real_paths << e_headers.call(entry.app_build_dir, 'Headers',
                                                         "#{target.product_module_name}-Swift.h")
              entry.modules_real_paths << e_headers.call(entry.project_temp_dir, 'module.modulemap')
              if target_has_private_module(target)
                entry.modules_real_paths << e_headers.call(entry.project_temp_dir,
                                                           'module.private.modulemap')
              end
            end
          end
        end.compact
        Target::FrameworkVFS.new(es).write
      end

      def self.target_effective_platforms(platforms)
        platforms.flat_map { |name| effective_platform_name(name) }.compact.uniq
      end

      def self.target_temp_and_build_dir(configurations, spec_path, target_name, product_module_name)
        platforms = target_support_platforms(spec_path)
        effective_platforms = Helper::Pods.target_effective_platforms(platforms)
        configurations.flat_map do |config|
          effective_platforms.map do |platform|
            dir = "#{config}-#{platform}"
            app_build_dir = File.join(Specification.instance.app_build_dir, dir, target_name,
                                      "#{product_module_name}.framework")
            project_temp_dir = File.join(Specification.instance.project_temp_dir, dir, "#{target_name}.build")
            Target::FrameworkEntry.new(config, platform, app_build_dir, project_temp_dir)
          end
        end
      end

      def self.xcodebuild(action, workspace, scheme = nil)
        command = %W[#{action} -workspace #{workspace} -json]
        command += %W[-scheme #{scheme} -showBuildSettings] unless scheme.nil?
        results = Executable.execute_command('xcodebuild', command, false)
        JSON.parse(results) unless results.nil?
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
