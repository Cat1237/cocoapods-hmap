# frozen_string_literal: true

module HMap
  class PodsSpecification
    attr_reader :workspace_path, :analyze, :app_build_dir, :project_temp_dir

    BUILD_DIR = 'BUILD_DIR'
    PROJECT_TEMP_DIR = 'PROJECT_TEMP_DIR'

    private_constant :BUILD_DIR
    private_constant :PROJECT_TEMP_DIR
    
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
      workspace_dic = xcodebuild('-list', workspace_path)['workspace']
      scheme = workspace_dic['schemes'].first
      build_settings = xcodebuild('analyze', workspace_path, scheme).first['buildSettings']
      @app_build_dir = build_settings[BUILD_DIR]
      @project_temp_dir = build_settings[PROJECT_TEMP_DIR]
    end

    def xcodebuild(action, workspace, scheme = nil)
      command = %W[#{action} -workspace #{workspace} -json]
      command += %W[-scheme #{scheme} -showBuildSettings] unless scheme.nil?
      results = Executable.execute_command('xcodebuild', command, false)
      JSON.parse(results) unless results.nil?
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
