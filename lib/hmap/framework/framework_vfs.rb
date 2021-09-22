require 'yaml_vfs'

module HMap
  module Target
    # Each fremaework vfs informations
    class FrameworkEntry
      attr_reader :configuration, :platform, :app_build_dir, :project_temp_dir
      attr_accessor :headers_real_paths, :modules_real_paths

      def initialize(configuration, platform, app_build_dir, project_temp_dir)
        @configuration = configuration
        @platform = platform
        @app_build_dir = app_build_dir
        @project_temp_dir = project_temp_dir
        @headers_real_paths = []
        @modules_real_paths = []
      end

      def framework_moduler_path
        File.join(app_build_dir, 'Modules')
      end

      def self.new_from_configuration_platform(configuration, platform, name, framework_name)
        dir = "#{configuration}-#{platform}"
        app_build_dir = File.join(PodsSpecification.instance.app_build_dir, dir, name,
                                  "#{framework_name}.framework")
        project_temp_dir = File.join(PodsSpecification.instance.project_temp_dir, dir, "#{name}.build")
        new(configuration, platform, app_build_dir, project_temp_dir)
      end

      def self.new_entrys_from_configurations_platforms(configurations, platforms, name, framework_name, module_path, headers)
        effective_platforms = Utils.effective_platforms_names(platforms)
        configurations.flat_map do |configuration|
          effective_platforms.map do |platform|
            entry = new_from_configuration_platform(configuration, platform, name, framework_name)
            entry.add_headers_modules(module_path, framework_name, headers)
            entry
          end
        end
      end

      def add_headers_modules(module_path, framework_name, headers)
        has_private_module = module_path.glob('module*.modulemap').length > 1
        e_headers = ->(path, *names) { names.inject(Pathname(path)) { |e, n| e.join(n) } }
        @headers_real_paths += headers
        @headers_real_paths << e_headers.call(app_build_dir, 'Headers', "#{framework_name}-Swift.h")
        @modules_real_paths << e_headers.call(project_temp_dir, 'module.modulemap')
        return unless has_private_module

        @modules_real_paths << e_headers.call(entry.project_temp_dir, 'module.private.modulemap')
      end
    end

    # A collection of Each FrameworkEntrys
    class FrameworkVFS
      attr_reader :entrys

      def initialize(entrys = [])
        @entrys = entrys
      end

      def vfs_path
        return {} if entrys.empty?

        entrys.each_with_object({}) do |entry, paths|
          c = "#{entry.configuration}-#{entry.platform}"
          paths[c] ||= []
          paths[c] << entry
        end
      end

      def vfs_path_by_platform_and_configuration(platform, config)
        return vfs_path if platform.nil? && config.nil?

        key = platform if config.nil?
        key = config if platform.nil?
        vfs_path.select { |k, _| k.include?(key) }
      end

      def write(path)
        vfs_path.each do |key, values|
          es = values.map do |value|
            VFS::FileCollectorEntry.new(Pathname(value.app_build_dir), value.modules_real_paths,
                                        value.headers_real_paths)
          end
          fc = VFS::FileCollector.new(es)
          pa = path.join(key)
          pa.mkpath unless pa.exist?
          fc.write_mapping(pa)
        end
      end
    end
  end
end
