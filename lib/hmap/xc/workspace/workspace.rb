# frozen_string_literal: true

require 'hmap/xc/product_helper'
require 'hmap/xc/workspace/project'
require 'hmap/xc/pbx_helper'

module HMap
  class Workspace
    attr_reader :save_setting, :projects

    def self.new_from_xcworkspaces(paths)
      paths.flat_map do |path|
        xc = Xcodeproj::Workspace.new_from_xcworkspace(path)
        schemes = xc.schemes.values.uniq || []
        ss = WorkspaceProductPath.new(path)
        projects = PBXHelper.projects(*schemes)
        new(ss, projects)
      end
    end

    def self.new_from_xcprojects(paths)
      paths.map do |path|
        ss = ProjectProductPath.new(path)
        projects = PBXHelper.projects(path)
        new(ss, projects)
      end
    end

    def initialize(save_setting, projects)
      @save_setting = save_setting
      @projects = projects.map { |project| Project.new(project, self) }
    end

    def build_root
      save_setting.build_root
    end

    def obj_root
      save_setting.obj_root
    end

    def name
      save_setting.name
    end

    def workspace_dir
      File.dirname(save_setting.path)
    end

    def hmap_root
      # dir = build_root.dirname.dirname
      dir = workspace_dir
      File.join(dir, Constants::HMAP_DIR)
    end

    def write_save!
      UserInterface.puts('[hmapfile] Got workspace/project build directory')
      UserInterface.puts("[hmapfile] #{name} hmapfile gen directory: #{hmap_root} ")
      write_hmapfile!
      save_hmap_settings!
    end

    def write_hmapfile!
      UserInterface.puts('[hmapfile] Starting generate hmap file')
      projects.each(&:write_hmapfile!)
    end

    def save_hmap_settings!
      UserInterface.puts('[hmapfile] Saving hmap settings')

      projects.each(&:save_hmap_settings!)
    end

    def remove_hmap_settings!
      UserInterface.puts('[hmapfile] Cleanning hmap settings')
      FileUtils.rm_rf(hmap_root) if Dir.exist?(hmap_root)
      projects.each(&:remove_hmap_settings!)
    end

    def all_target_headers
      @projects.flat_map(&:targets).inject({}) do |sum, entry|
        sum.merge!(entry.all_target_headers) { |_, v1, _| v1 }
      end
    end

    def xcconfig_paths
      return @xcconfig_paths if defined?(@xcconfig_paths)

      @xcconfig_paths = projects.flat_map do |project|
        project.targets.flat_map do |target|
          target.target.build_configurations.map do |configuration|
            next unless configuration.is_a?(Constants::XCBuildConfiguration)

            bcr = configuration.base_configuration_reference
            next if bcr.nil?

            s_path = PBXHelper.group_paths(bcr)
            x = bcr.instance_variable_get('@simple_attributes_hash')['path'] || ''
            path = File.expand_path(File.join(project.project_dir, s_path, x))
            target.xcconfig_paths << path
            path
          end.compact
        end
      end.uniq
    end
  end
end
