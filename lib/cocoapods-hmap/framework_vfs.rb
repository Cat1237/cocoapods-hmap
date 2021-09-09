module HMap
  module Target
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
    end

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

      def write(path = nil)
        vfs_path.each do |key, values|
          es = values.map do |value|
            headers_real_paths = value.headers_real_paths
            modules_real_paths = value.modules_real_paths
            VFS::FileCollectorEntry.new(Pathname(value.app_build_dir), modules_real_paths, headers_real_paths)
          end
          fc = VFS::FileCollector.new(es)
          pa = File.join(Helper::Pods.hmap_files_dir, 'vfs', key)
          pa = File.join(path, key) unless path.nil?
          pa = Pathname(pa)
          pa.mkpath unless pa.exist?
          fc.write_mapping(pa)
        end
      end
    end
  end

  class Specification
    attr_reader :workspace_path, :analyze, :app_build_dir, :project_temp_dir

    BUILD_DIR = 'BUILD_DIR'
    PROJECT_TEMP_DIR = 'PROJECT_TEMP_DIR'

    def self.instance
      @instance ||= new
    end

    def initialize
      @workspace_path = workspace
      @analyze = pod_analyze
      workspace_build_dir
    end

    private

    def workspace_build_dir
      workspace_dic = Helper::Pods.xcodebuild('-list', workspace_path)['workspace']
      scheme = workspace_dic['schemes'].first
      build_settings = Helper::Pods.xcodebuild('analyze', workspace_path, scheme).first['buildSettings']
      @app_build_dir = build_settings[BUILD_DIR]
      @project_temp_dir = build_settings[PROJECT_TEMP_DIR]
    end

    def pod_analyze
      podfile = Pod::Podfile.from_file(Pod::Config.instance.podfile_path)
      lockfile = Pod::Lockfile.from_file(Pod::Config.instance.lockfile_path)
      Pod::Installer::Analyzer.new(Pod::Config.instance.sandbox, podfile, lockfile).analyze
    end

    def workspace
      podfile = Pod::Podfile.from_file(Pod::Config.instance.podfile_path)
      user_project_paths = pod_analyze.targets.map(&:user_project_path).compact.uniq
      if podfile.workspace_path
        declared_path = podfile.workspace_path
        path_with_ext = File.extname(declared_path) == '.xcworkspace' ? declared_path : "#{declared_path}.xcworkspace"
        podfile_dir   = File.dirname(podfile.defined_in_file || '')
        absolute_path = File.expand_path(path_with_ext, podfile_dir)
        Pathname.new(absolute_path)
      elsif user_project_paths.count == 1
        project = user_project_paths.first.basename('.xcodeproj')
        Pod::Config.instance.installation_root + "#{project}.xcworkspace"
      else
        raise Informative, 'Could not automatically select an Xcode ' \
          "workspace. Specify one in your Podfile like so:\n\n"       \
          "    workspace 'path/to/Workspace.xcworkspace'\n"
      end
    end
  end
end
